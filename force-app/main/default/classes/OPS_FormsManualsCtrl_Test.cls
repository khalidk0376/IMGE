@isTest
public class OPS_FormsManualsCtrl_Test {
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
       
        Form__c form = new Form__c(Name='test manual',Allow_Submit_After_Deadline__c=true,Doc_Type__c='Link',Uploaded_Attachment_Id__c='test',Deadline__c=System.Today());
        insert form;
       
        Event_Edition_Form__c eventForm = new Event_Edition_Form__c(Name='test manual',Allow_Submit_After_Deadline__c=true,Form_Type__c='Link',Mandatory__c=true,Deadline__c=System.Today(),Event_Edition__c=lstEE[1].id,Forms__c=form.id);
        insert eventForm;
        
        Manuals_Permission__c manPerm = new Manuals_Permission__c(Name='test',Active__c=true,Manuals__c=manual.id);
        insert manPerm;
       
       Forms_Permission__c formPerm = new Forms_Permission__c(Active__c=true,Event_Edition_Form__c=eventForm.id,User_Type__c=oUT.id);
        insert formPerm;
        
        //create User Manual Action
        User_Manual_Action__c userManAct = new User_Manual_Action__c(Name='Test',Account__c=accounts[1].id,Is_Agree__c=false,Is_Viewed__c=true,Manual_Permission__c=manPerm.id,User_Manual_Contact__c=u.ContactId);
        insert userManAct;
        
        User_Manual_Action__c userManActt = new User_Manual_Action__c(Name='Test',Account__c=accounts[1].id,Is_Agree__c=true,Is_Viewed__c=false,Manual_Permission__c=manPerm.id,User_Manual_Contact__c=u.ContactId);
        insert userManActt;
       
        User_Form_Action__c userformAct = new User_Form_Action__c(Name='Test',Account__c=accounts[1].id,Is_Viewed__c=true,Is_Filled_Up__c=false,Form_Permission__c=formPerm.id);
        insert userformAct;
        
        //User_Form_Action__c userformAct1 = new User_Form_Action__c(Name='Test',Account__c=accounts[1].id,Is_Agree__c=true,Is_Viewed__c=false,Manual_Permission__c=manPerm.id,User_Manual_Contact__c=u.ContactId);
        //insert userformAct1;
       
        test.startTest();
        System.runAs(u)
        {
            //OPS_FormsManualsCtrl  obj = new OPS_FormsManualsCtrl();
            List<User_Manual_Action__c> userAction = new List<User_Manual_Action__c>();
            List<User_Form_Action__c> userFormAction = new List<User_Form_Action__c>();
            string objName = 'Manuals_Permission__c';
            string fields = 'Manuals__c,Manuals__r.Name,Manuals__r.Required__c,Manuals__r.ManualType__c,SUM(Total_User_Count__c),SUM(Total_User_Viewed__c),SUM(Total_User_Agreed__c) ';
            string searchField = 'Manuals__r.Name';
             string searchField2 = 'Manuals__r.Name,Manuals__r.ManualType__c';
            string searchText = 'Search';
            string groupByFields = 'group by Manuals__r.Name,Manuals__c,Manuals__r.Event_Edition__c,Manuals__r.Required__c,Manuals__r.ManualType__c';
            string condition = 'where active__c=true and Manuals__c!=\'\' and Manuals__r.Event_Edition__c =\'' + lstEE[0].id + '\' ';
            string sortBy = 'Manuals__r.Name';
            string sortType = 'asc';
            decimal pageNo = 1;
            decimal pageSize = 2;
            Boolean testVar;
            Boolean testVarForm;
            userAction = OPS_FormsManualsCtrl.getUserManualAction(manual.Id);
            userFormAction = OPS_FormsManualsCtrl.getUserFormAction(eventForm.Id);
            List<String> cList= new  List<String>();
            cList.Add(String.valueOf(contacts[0].Accountid));
            string accIDs=System.JSON.serialize(cList);
            testVar = OPS_FormsManualsCtrl.SingleManualReminderEmail(lstEE[0].id,accIDs,manual.id);
            testVarForm = OPS_FormsManualsCtrl.SingleFormReminderEmail(lstEE[0].id,accIDs,eventForm.id);
            User_Form_Action__c obj1 = new User_Form_Action__c();
            OPS_FormsManualsCtrl.approveAndRejectFormSendEmail('Approved','test',lstEE[0].id,userformAct.id,eventForm.id,userformAct);
            OPS_FormsManualsCtrl.approveAndRejectFormSendEmail('Rejected','test',lstEE[0].id,userformAct.id,eventForm.id,userformAct);
            OPS_FormsManualsCtrl.RecordDataTableWrapper wrap = OPS_FormsManualsCtrl.getAggregateRecords(objName,fields,searchField,searchText,condition,groupByFields,sortBy,sortType,pageNo,pageSize);
            OPS_FormsManualsCtrl.RecordDataTableWrapper wrap2 = OPS_FormsManualsCtrl.getAggregateRecords(objName,fields,searchField2,searchText,condition,groupByFields,sortBy,sortType,pageNo,pageSize);
        }
         test.stopTest();
   }
        

}