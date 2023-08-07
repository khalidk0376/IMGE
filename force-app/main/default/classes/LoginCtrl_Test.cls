/**
 * Created/Modified By: Girikon(Archit)
 * Created On:          5/29/2017 
 * @description  : This test class covers the apex class : LoginCtrl
 * Methods:             LoginCtrlDataInsert
 * Apex Class:          LoginCtrl (87%)
**/
/***********************************
Created By - Archit
Test class for - LoginCtrl Class
************************************/
@isTest
private class LoginCtrl_Test
{
    public static testMethod void loginCtrlDataInsert()
    {
        // Setup Test Data 
        // This code runs as the system user
        Account acc = new Account(name='acc1');
        insert acc;
        
        User_Type__c uType = new User_Type__c(Name ='Contractor');
        insert UType;        
        Contact con = new Contact(LastName='User',FirstName ='Test', Type__c=UType.Id,AccountId =acc.Id);
        insert con;
        String commUsrProfile='';
        If(Label.Community_User_Profile!= NULL)
        {
            commUsrProfile= Label.Community_User_Profile;
        }            
        else
        {
            commUsrProfile='Customer Community Login User Custom';
        }            
        //Profile p = [SELECT Id FROM Profile WHERE Name='Customer Community Login User Custom']; 
        Profile p = [SELECT Id FROM Profile WHERE Name=:commUsrProfile]; 
        User u = new User(Alias = 'standt', Email='davidjones@test.com', 
        EmailEncodingKey='UTF-8', LastName='Kumar', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = p.Id,ContactID=con.id,
        TimeZoneSidKey='America/Los_Angeles', UserName='CommunityUser1@testorg.com');
        insert u; 
        System.assertEquals(u.ContactID,con.id, 'Same contact');
        Event_Edition__c oEve;
        Event_Settings__c objSetting;     

        CC_community_Setting__c ccstng = new CC_community_Setting__c();
        ccstng.name = 'Customer Center';
        ccstng.Admin_Email__c = 'testabc@abc.com';
        ccstng.Under_Maintenance__c = false;
        insert ccstng;
        
        System.runAs(u) 
        {                          
            //Create conga template
            APXTConga4__Conga_Template__c congaTemp=new APXTConga4__Conga_Template__c(APXTConga4__Name__c='Test Cong Template');
            Insert congaTemp;
            
            //Insert event edition image
            /*List<Document> documents = [SELECT Id, FolderId, Folder.Name FROM Document WHERE Folder.Name ='Images' LIMIT 1];
            system.debug('**'+documents[0].FolderId + '***'+'documents');*/
            Document d = new Document(); 
            d.Name = 'TEV17-Event-Image'; 
            d.FolderId = UserInfo.getUserId();//documents[0].FolderId;
            d.IsPublic = true; 
            d.Body =Blob.valueOf('Some Text'); 
            d.ContentType = 'image/jpeg';
            insert d;
            
            Brand__c oBrand = new Brand__c(Name = 'World of Concrete', SSC_Email_Distribution_ID__c = 'test@test.tst');
            insert oBrand;
    
            Event_Series__c oEventseries = new Event_Series__c(Name = 'World Of Concrete', Status__c = 'Active', CurrencyISOCode = 'USD', Package_Identifier__c = 'WOC', Brand__c = oBrand.id, Event_Edition_Pool__c = 'WOC');
            insert oEventseries;
      
            OEve = new Event_Edition__c(Name='Test Event 2017',Part_of_Series__c = oEventseries.ID,Event_Code__c='TEV17',End_Date__c=System.Today(),Start_Date__c=System.Today(),Event_Edition_Status__c='Confirmed',Contract_Template__c=congaTemp.Id,Event_Website__c='http://www.testevent.com',Event_Edition_Image_URL__c=d.Id,Invoice_From_Email_ID__c='Test',Max_Hold_Booth__c=50,Max_Hold_Days__c=10,Measurement__c='Feet',Next_Edition__c='2019',Payment_Schedule__c='50-50',Quote_Template__c=congaTemp.Id,Venue__c='Test',Year__c='2018',Event_Currency__c='USD',Cutoff_Date_1__c=  System.today() + 5,Informa_Logo__c=d.Id);
            insert OEve;
            System.assertEquals(OEve.Event_Code__c,'TEV17', 'Event Code');
            
            ContactEventEditionMapping__c objConEvtEdtsn = new ContactEventEditionMapping__c();
            objConEvtEdtsn.SFContactID__c = con.id;
            objConEvtEdtsn.SFEventEditionID__c = OEve.id;
            objConEvtEdtsn.Status__c = true;
            insert objConEvtEdtsn; 
            
            objSetting = new Event_Settings__c();
            objSetting.Branding_Color__c = 'RED';
            objSetting.Event_Edition__c = OEve.id;
            objSetting.Is_Event_Edition_Live__c =true;
            objSetting.Send_Welcome_Email__c=true;
            insert objSetting;
        }
        
        ApexPages.currentPage().getHeaders().put('Host','');
        PageReference pageRef = new PageReference('/UserLogin');
        Test.setCurrentPage(pageRef);
        apexpages.currentpage().getparameters().put('eventcode','');
        apexpages.currentpage().getparameters().put('reset','1');
        LoginCtrl oLoginCtrl6 = new LoginCtrl();        
        oLoginCtrl6.username = 'Test@testorg.com';
        oLoginCtrl6.password ='Test12345';     
        oLoginCtrl6.login();
        oLoginCtrl6.getOrgId();
        
        pageRef = new PageReference('/UserLogin?startURL=%2FCustomerProfile%3Feventcode%3DTEV17');
        Test.setCurrentPage(pageRef);
        apexpages.currentpage().getparameters().put('er','iunp');
        LoginCtrl oLoginCtrl = new LoginCtrl();
        apexpages.currentpage().getparameters().put('er','iufte');
        LoginCtrl oLoginCtrl1 = new LoginCtrl();
        apexpages.currentpage().getparameters().put('er','iu');
        LoginCtrl oLoginCtrl2 = new LoginCtrl();
        apexpages.currentpage().getparameters().put('eventcode','');
        LoginCtrl oLoginCtrl4 = new LoginCtrl();
        apexpages.currentpage().getparameters().put('eventcode','WOCC17');
        LoginCtrl oLoginCtrl5 = new LoginCtrl();
        oLoginCtrl5.getSiteURL();
        
        oLoginCtrl.username = u.UserName;
        oLoginCtrl.password ='Test12345';        
        apexpages.currentpage().getparameters().put('eventcode',OEve.Event_Code__c);
        oLoginCtrl.login();        
        oLoginCtrl.forgotPassword();
        oLoginCtrl.resetPassword();
        oLoginCtrl.username = 'Test';
        oLoginCtrl.resetPassword();
        oLoginCtrl.username = '';
        oLoginCtrl.resetPassword();
        system.runAs(u){
        	oLoginCtrl.redirectToHome();
        }
    }    
}