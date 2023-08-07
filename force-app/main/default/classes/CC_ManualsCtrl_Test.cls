@isTest
private class CC_ManualsCtrl_Test {

  @isTest
    static void dataSetUp() 
    {    
        //Create Account
        List<Account> accounts = new List<Account>();
        for(Integer i=0;i<3;i++)
        {
            Account acc = new Account(Name='TstAccFrst' + i, BillingStreet='testStreet',BillingCity='test', BillingState='Delhi', BillingPostalCode='13245', BillingCountry='India');
            accounts.add(acc);    
        }
        insert accounts;
        System.assertNotEquals(null, accounts[1].Name, 'Account Name must not be null');
        
        //create some contacts
        List<Contact> contacts = new List<Contact>();
        for(Integer i=0;i<3;i++)
        {
            Contact con = new Contact(AccountId = accounts[i].Id, FirstName = 'TstConFrst'+i, LastName = 'TstConLst1'+i, Email='test@test.com');
            contacts.add(con);    
        }
        insert contacts;
        System.assertNotEquals(null, contacts[1].LastName, 'Contact Name must not be null');
            
        //Create user
        Profile pro = [SELECT Id FROM Profile WHERE Name = 'Customer Community Login User Custom'];
        User u = new User();
        u.FirstName = 'Garima';
        u.LastName = 'Gupta';
        u.Email = 'test@wexeurope.com';
        u.Username = 'test@wexeurope.com.fghgh';
        u.Alias = 'astest';
        u.ProfileId = pro.Id;
        u.ContactId = contacts[1].id;
        u.TimeZoneSidKey    = 'America/Denver';
        u.LocaleSidKey      = 'en_US';
        u.EmailEncodingKey  = 'UTF-8';
        u.LanguageLocaleKey = 'en_US';
        system.debug('u contains ' + u);
        insert u;
        
        User_Type__c oUT = new User_Type__c(Name='Exhibitor');
        insert oUT;
        
        //create Event_Edition__c
        List<Event_Edition__c> lstEE = new List<Event_Edition__c>();
        for(Integer i=0;i<3;i++)
        {
            Event_Edition__c ee = new Event_Edition__c(Name='Arab Health Exhibition and Congress 2019'+i,Event_Code__c='sbah19',End_Date__c=System.Today(),Start_Date__c=System.Today(),Payment_Schedule__c='50-50',X50_Cutoff_Date__c=System.Today(),Cutoff_Date_1__c=System.Today(),Cutoff_Date_2__c=System.Today(),Event_Currency__c='USD',Cutoff_Date_3__c=System.Today());
            lstEE.add(ee);  
        }
        insert lstEE;
        
        //Create Event_Settings__c
        Event_Settings__c evntSttng = new Event_Settings__c(Name='Test',About_Show__c='Test',Manuals_Title__c='Manuals',Welcome_Text_Manuals__c='Welcome Manuals',Show_Hide_Manual_Agreed__c=true,Deadline_Reached_Message_for_Manuals__c='Test',Event_Edition__c=lstEE[1].id);
        insert evntSttng;
        
        ContactEventEditionMapping__c contMap = new ContactEventEditionMapping__c(SFEventEditionID__c=lstEE[1].id,SFContactID__c=u.ContactId,User_Type__c=oUT.id);
        insert contMap;
        
        Manual__c manual = new Manual__c(Name='test manual',Allow_Submit_After_Deadline__c=true,Manual_Type__c='Link',Required__c=true,Uploaded_Attachment_Id__c='test',Deadline__c=System.Today(),Event_Edition__c=lstEE[1].id);
        insert manual;
        
        Manuals_Permission__c manPerm = new Manuals_Permission__c(Name='test',Active__c=true,Manuals__c=manual.id);
        insert manPerm;
        
        //create User Manual Action
        User_Manual_Action__c userManAct = new User_Manual_Action__c(Name='Test',Account__c=accounts[1].id,Is_Agree__c=false,Is_Viewed__c=true,Manual_Permission__c=manPerm.id,User_Manual_Contact__c=u.ContactId);
        insert userManAct;
        
        User_Manual_Action__c userManActt = new User_Manual_Action__c(Name='Test',Account__c=accounts[1].id,Is_Agree__c=true,Is_Viewed__c=false,Manual_Permission__c=manPerm.id,User_Manual_Contact__c=u.ContactId);
        insert userManActt;
        
        test.startTest();
        System.runAs(u)
        {
           	CC_ManualsCtrl.updateUserAction(userManAct.id,userManAct.Is_Viewed__c,userManAct.Is_Agree__c);
            CC_ManualsCtrl.updateUserAction(userManActt.id,userManActt.Is_Viewed__c,userManActt.Is_Agree__c);
        	CC_ManualsCtrl.getConUserType(lstEE[1].Event_Code__c); 
        }
        
        test.stopTest();
    }
    
}