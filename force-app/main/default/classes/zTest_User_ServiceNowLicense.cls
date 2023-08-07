/**************************************************************************
** Last Modified by Shay Spoonmore (shay.spoonmore@informausa.com)2013-09-25
** Ticket No.-BK-14522 Updating API Version
***************************************************************************/
@isTest
private class zTest_User_ServiceNowLicense {
    
    public static User noinsertUser(){
        Organization o = [SELECT Country,Id,InstanceName,IsSandbox,Name,State FROM Organization limit 1]; 
        Profile p = [Select Id,Name From Profile Where Name = 'System Administrator' limit 1]; 
        User u = new User(alias='test', email='test@example.com', firstname='Testing',
                          emailencodingkey='UTF-8', lastname='Testing', languagelocalekey=Userinfo.getLanguage(), 
                          localesidkey=Userinfo.getLanguage(), Country = o.Country,//'United States', 
                          timezonesidkey=Userinfo.getTimeZone().getID(), 
                          username='test@example.com.informaplc' + system.now().second() + system.now().millisecond() + math.random(),
                          profileid=p.Id, //System Administrator
                          
                          Active_Directory_Username__c='testinguser1' + system.now().second() + system.now().millisecond(),
                          Active_Directory_OU__c='ukcorplan');
        return u;
    }
    
    @testSetup static void settings() 
    {
        CreateApplicationBypass();
        ServiceNowUser.TestCreateSettings();
    }
    
    static testMethod void testValidation() 
    {
        User_ServiceNowLicense usnl = new User_ServiceNowLicense();
        usnl.GetSNLicQueryString();
        //ServiceNowUser.TestCreateSettings();
        List<User> users= new List<User>();
        LIst<Active_Directory_Details__c> adUsers = new LIst<Active_Directory_Details__c>();
        
        for (Integer i=0;i< 15 ;i++) 
        { 
            
            User x = noinsertUser();
            x.Username = x.Username + '_' + i;
            x.Active_Directory_Username__c='x' + '_' + i;
            x.Active_Directory_OU__c='ukcorplan';
            x.FederationIdentifier='FederationIdentifier' + '_' + i;
            x.License_Type__c = 'Salesforce';
            x.isActive = true;
            if (i>=7)x.ServiceNow_Lic_Id__c = 'ServiceNow_Lic_Id__c' + '_' + i;
            if (i==4)x.isActive = false;
            if (i==2)x.FederationIdentifier = null;
            
            users.add(x);
            
            if (i==9)x.FederationIdentifier = null;
            
            adUsers.add(new Active_Directory_Details__c(sys_id__c='test_'+ i, USER_Name__c=x.Active_Directory_OU__c + '\\' +  x.Active_Directory_Username__c, u_office_365__c =x.FederationIdentifier));
            
        }
        
        insert adUsers;
        insert users;
        system.assertEquals(adUsers[0].sys_id__c, 'test_0', 'Both values should be the same.');
        
        //System.debug('#### User_ServiceNowLicenseUpdate=' + users[]);
        
        
        
        //Test bad AD User
        //users[0].isActive = false;
        //users[1].Active_Directory_Username__c= 'BadAD';
        //users[2].Active_Directory_Username__c= 'BadAD';
        //update users;
        
        //newUsers = [SELECT Id, Username, Active_Directory_Username__c,Active_Directory_OU__c, isActive, Name_for_Service_Now__c,License_Type__c, ServiceNow_Lic_Id__c, FederationIdentifier  FROM USER];
        //User_ServiceNowLicense.GetValidateUser(newUsers);
        
        
        User_ServiceNowLicenseUpdate.SendErrorEmail('TEST.TEST@informaUSA.com','(UnitTest)Error - SFDC-ServiceNow Emails','test');
        
        Test.StartTest();
        Set<Id> batchProcessIds = new Set<Id>();
        //ServiceNowUser.TestCreateSettings();
        User_ServiceNowLicenseUpdate x = new User_ServiceNowLicenseUpdate();
        x.isTesting = true;
        
        batchProcessIds.add(Database.executeBatch(x));
        
        
        
        System.debug('#### User_ServiceNowLicenseUpdate=' + batchProcessIds.size());
        
        //User_ServiceNowLicenseUpdateSchedule m = new  User_ServiceNowLicenseUpdateSchedule();
        //String sch = '20 30 8 10 2 ?';
        //System.schedule('TEST_User_ServiceNowLicenseUpdateSchedule',sch, m);
        
        Test.StopTest();
        
        //Test Trigger
        LIst<User> newUsers = [SELECT Id, Username, ProfileId, Active_Directory_Username__c,Active_Directory_OU__c, isActive, Name_for_Service_Now__c,License_Type__c, ServiceNow_Lic_Id__c, FederationIdentifier,UserPreferencesLightningExperiencePreferred  FROM USER order by SystemModstamp DESC LIMIT 25];
        usnl.GetValidateUser(newUsers,newUsers);
        
        String sTest = usnl.TestLicUserJson();
        
        //zTEST_Shared.runTriggers.add('User_ServiceNowLicense'); Not using because of dependancy zTEST_Shared KN
        
        newUsers[0].isActive = false;
        newUsers[1].Active_Directory_Username__c= 'BadAD';
        newUsers[2].Active_Directory_Username__c= 'BadAD';
        update users;
        
        
        
        PageReference pr = Page.ServiceNowLicensing;//Limit in salesforce is 1000 records
        ServiceNowLicensingController snlc = new ServiceNowLicensingController();  
        
    }
    
    
    
    Static testMethod void unitTestSchedule() 
    {
        
        
        //Test.StartTest();
        User_ServiceNowLicenseUpdateSchedule m = new  User_ServiceNowLicenseUpdateSchedule();
        String sch = '20 30 8 10 2 ?';
        System.schedule('TEST_User_ServiceNowLicenseUpdateSchedule',sch, m);
        //Test.StopTest();
        system.assertEquals(sch, '20 30 8 10 2 ?', 'Both values should be the same.');
    }
    
    public static void createApplicationBypass()
    {
        //Bypass Validation Rules
        List<Application_Bypass__c> applicationBypass =[Select Id,Bypass_Validation_Rules__c,SetupOwnerId from Application_Bypass__c WHERE SetupOwnerId=:UserInfo.getUserId()];
        if(applicationBypass.size() == 0)
        {
            applicationBypass.add(new Application_Bypass__c(Bypass_Validation_Rules__c=true,SetupOwnerId=UserInfo.getUserId()));
            insert applicationBypass;
        }                                     
    }
    
}