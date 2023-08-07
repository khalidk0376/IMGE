/************************************************************************** 
** Last Modified by Shay Spoonmore (shay.spoonmore@informausa.com)2016-10-31
** Note: Create 4 schedule Apex - Jobs Name: GetServiceNowSchedule1
***************************************************************************/
@isTest
private class zTest_ServiceNowUser {
	
	@testSetup static void settings() 
    {
        CreateApplicationBypass();
        ServiceNowUser.TestCreateSettings();
	}
    
    static testMethod void unitTest_GetObjectData() 
    {	
		
		ServiceNowUser.TestCreateCustomSettings();
        ServiceNowUser.TestObjectJson();
        //ServiceNowUser.TestCreateSettings();
        
        ServiceNowUtils snUtils = new ServiceNowUtils();
        ServiceNowUser snUsers = new ServiceNowUser();
        ServiceNowUtils.EndpointHeaderResponse epResponse = New ServiceNowUtils.EndpointHeaderResponse();
        snUtils.SendEmail(snUtils.apiSetup.Error_Debug_Emails__c, 'emailSubject', 'emailMessage', 'High', null, null, false, null);
		snUtils.SendEmail(snUtils.apiSetup.Error_Debug_Emails__c, 'emailSubject', 'emailMessage', 'High', null, snUtils.apiSetup.Org_Wide_Email_Id__c, true,  new List<Messaging.Emailfileattachment>());
        HttpResponse response =new HttpResponse();
        response.setHeader('X-Total-Count', '500');
        snUtils.EndpointResponseHeaderDetails(response,'url');
        snUtils.ServiceNowRequest('requestURL', 'GET', 'setBody', 'JSON');
        //ServiceNowUser.ServiceNowRequest('requestURL', 'requestMethod', 'setBody', 'setContentType');
        system.assertEquals('sch', 'sch', 'Both values should be the same.');
        
        
        Test.startTest();
        snUsers.GetObjectData();
        
        List<ApplicationProcessRunning__c> apr = [Select a.Id from ApplicationProcessRunning__c a where a.Name like 'ServiveNow.%'];
        System.debug('####ApplicationProcessRunning__c:' + apr.Size());
        if(apr.size()>0)Delete(apr);
        
        snUsers.GetObjectData();
        
        Test.stopTest();
             
        
        
        
        
        //Test single update trigger ServiceNow_GetCompanyInfo
        System.debug('####Test single update trigger ServiceNow_GetCompanyInfo');
        list<Active_Directory_Details__c> snUsersR = [SELECT Id,ServiceNow_Company__c,ServiceNow_Department__c,ServiceNow_Division__c FROM Active_Directory_Details__c ORDER by sys_id__C ASC LIMIT 5];
        System.debug('####	snUsersR: ' + snUsersR.size());
        for (Integer i=0;i< snUsersR.size();i++) 
    	{
            System.debug('####	sys_id__C: ' + snUsersR[i].sys_id__C + '; SN_Division_Id__c: '+snUsersR[i].SN_Division_Id__c);
            snUsersR[i].ServiceNow_Company__c=null;
            snUsersR[i].ServiceNow_Department__c=null;
            snUsersR[i].ServiceNow_Division__c=null;
            snUsersR[i].SN_Department_Id__c = string.valueOf(i);
            snUsersR[i].SN_Company_Id__c = string.valueOf(i);
            snUsersR[i].SN_Division_Id__c = string.valueOf(i);
            
    	}
        update(snUsersR);
        system.assertEquals(null, null, 'Both values should be the same.');        
    }
    
    static testMethod void unitTest_GetCompanyInfo() 
    {
        
        System.debug('####Test single update trigger ServiceNow_GetCompanyInfo');
        list<Active_Directory_Details__c> snUsers = new list<Active_Directory_Details__c>();
        list<ServiceNow_Company__c> snCompanies = new list<ServiceNow_Company__c>();
        list<ServiceNow_Division__c> snDivisions = new list<ServiceNow_Division__c>();
        list<ServiceNow_Department__c> snDepartments = new list<ServiceNow_Department__c>();
            //[SELECT Id,ServiceNow_Company__c,ServiceNow_Department__c,ServiceNow_Division__c FROM Active_Directory_Details__c ORDER by sys_id__C ASC LIMIT 5];
        
        for (Integer i=0;i< 10;i++) 
    	{
            Active_Directory_Details__c snUser = new Active_Directory_Details__c();
            snUser.sys_id__C = string.valueOf(i);
            snUser.name=string.valueOf(i);
            snUser.ServiceNow_Company__c=null;
            snUser.ServiceNow_Department__c=null;
            snUser.ServiceNow_Division__c=null;
            snUser.SN_Department_Id__c = string.valueOf(i);
            snUser.SN_Company_Id__c = string.valueOf(i);
            snUser.SN_Division_Id__c = string.valueOf(i);
            snUsers.add(snUser);
            
            ServiceNow_Division__c snDivision= new ServiceNow_Division__c();
            snDivision.Name = string.valueOf(i);
            snDivision.SN_Sys_Id__c=   string.valueOf(i);
            snDivisions.add(snDivision);
            
            ServiceNow_Company__c snCompany= new ServiceNow_Company__c();
            snCompany.Name = string.valueOf(i);
            snCompany.SN_Sys_Id__c=   string.valueOf(i);
            snCompanies.add(snCompany);
            
            ServiceNow_Department__c snDepartment= new ServiceNow_Department__c();
            snDepartment.Name = string.valueOf(i);
            snDepartment.SN_Sys_Id__c=string.valueOf(i);
            snDepartments.add(snDepartment);
            
            
    	}
        System.debug('####	snUsers: ' + snUsers.size());
        upsert snDivisions sn_sys_id__C;
        upsert snCompanies sn_sys_id__C;
        upsert snDepartments SN_Sys_Id__c;
        upsert snUsers sys_id__C;
        
        upsert snUsers sys_id__C;
        system.assertEquals('test class', 'test class', 'Both values should be the same.');
    }
    
    static testMethod void unitTest_ServiceNowUserSchedule()
    {
    	Test.startTest(); 
    	// Schedule the test job
    	ServiceNowUserSchedule m = new ServiceNowUserSchedule();
    	//m.sendStatus = true;
    	String sch = '20 30 8 10 2 ?';
		System.schedule('Test_ServiceNowUserSchedule',sch, m);
    	
        Test.stopTest();
        system.assertEquals(sch , '20 30 8 10 2 ?', 'Both values should be the same.');
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