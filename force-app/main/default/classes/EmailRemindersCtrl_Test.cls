/**
* Created By:  Girikon(Ashish)
* Created On:  Oct 3 2018
* @description : This test class provide code coverage to "EmailRemindersCtrl" class.
* Apex Class : EmailRemindersCtrl

* Modification Log----- 
* Modified by   : Girikon(Prashant) [CCEN-692],Girikon(Garima) [CCEN-751 April 2 2019]
* Modified On   : March 8 2019
**/
@isTest
public class EmailRemindersCtrl_Test { 
       //SetUp data for test class
       @isTest static void emailRemindersCtrl() {
    
        Account oAccount = new Account(Name = 'Expocad Account', CurrencyIsoCode = 'USD', Phone = '2423122323');
        insert oAccount;
        System.assertNotEquals(null, oAccount.Name,'Account Name should not be null');
        // Commented by Palla Kishore for the Ticket EMEA-208 
        //Account oAccount2 = new Account(Name = 'Expocad Account2', CurrencyIsoCode = 'USD', Phone = '2423122323');
        //insert oAccount2;
        Contact oCon = new Contact(LastName = 'ContTest1', Email = 'test1contact@duptest.com', AccountId = oAccount.Id, MailingStreet = 'Test', MailingCity = 'Test', MailingState='', MailingCountry='India',Phone = '2423122323', AssistantPhone = '2423122323', HomePhone = '2121212121', MobilePhone = '2121212145', OtherPhone = '2154215421');
        insert oCon;
        
        User oUser = [SELECT Id FROM User WHERE Id = : UserInfo.getUserId()];
        AccountTeamMember oAtm =new AccountTeamMember(AccountId = oAccount.id, userId = oUser.id);
        insert oAtm;
        
        Event_Edition__c oEve = new Event_Edition__c(Name='World of Concrete 2017',Event_Code__c='WOC17',End_Date__c=System.Today(),Start_Date__c=System.Today());
        insert oEve; 

         //Create User_Type__c
        User_Type__c oUTExh = new User_Type__c(Name='Exhibitor');
        insert oUTExh;
             
     
        opportunity opp = new opportunity();
        opp.User_Type__c =oUTExh.id;
        opp.Name='World of Concrete 2017';
        opp.EventEdition__c = oEve.id;
        opp.AccountId = oAccount.id;
        opp.Paid_Amount__c=10.00;
        opp.Amount=20.00;
        opp.CloseDate=System.Today();
        opp.StageName='Needs Assessment';
        opp.CurrencyIsoCode=OEve.EventCurrency__r.Name;
        opp.Billing_Contact__c = oCon.id;
        opp.Marketing_Contact__c = oCon.id;
        opp.Opportunity_Contact__c = oCon.id;
        opp.Operations_Contact__c = oCon.id;
        opp.Safety_Contact__c = oCon.id;
        opp.Agreement_Contact__c = oCon.id; 
        opp.Stand_Contractor__c = oCon.id; 
        insert opp;
            
        opp.StageName = 'Closed Won' ;
           update opp;

          //create ExpocadBooth__c
        List<ExpocadBooth__c> lstExpoBooth = new List<ExpocadBooth__c>();
        for(Integer i=0;i<3;i++)
        {
            ExpocadBooth__c eB = new ExpocadBooth__c(Booth_Number__c='TestBoothNo.'+i, status__c = 'Rented',Booth_Product_Type__c = 'Space only',Opportunity__c =opp.id );
            lstExpoBooth.add(eB);   
        }
        insert lstExpoBooth;
           
        //create Opportunity_ExpoCAD_Booth_Mapping__c[CCEN-751] 
        List<Opportunity_ExpoCAD_Booth_Mapping__c> lstOppExpoBooth = new List<Opportunity_ExpoCAD_Booth_Mapping__c>();   
        for(Integer i=0;i<3;i++)
        {
            Opportunity_ExpoCAD_Booth_Mapping__c oEB = new Opportunity_ExpoCAD_Booth_Mapping__c(Expocad_Booth__c= lstExpoBooth[i].id,Opportunity__c =opp.id, Status__c = 'Active');
            lstOppExpoBooth.add(oEB);   
        }
        insert lstOppExpoBooth;
        
        List<ContactEventEditionMapping__c> lstCEEM=new List<ContactEventEditionMapping__c>();
            ContactEventEditionMapping__c cEEM1 = new ContactEventEditionMapping__c(SFEventEditionID__c=oEve.Id, SFContactID__c=oCon.Id, User_Type__c=oUTExh.Id);
            lstCEEM.Add(cEEM1);

            insert lstCEEM ;
           
            //Create global email template code [EWC] Exhibitor Without Contractor
            Email_Templates__c testET0 = new Email_Templates__c();
            testET0.name = 'test email template';
            testET0.Template_Code__c = 'EWC';
            testET0.Content__c = 'testContent';
            testET0.Subject__c = 'Test Template';
            insert testET0;
            
            //Create event edition email template using global email template [EWC]
            Event_Edition_Email_Template__c testEEET0 = new Event_Edition_Email_Template__c();
            testEEET0.Event_Edition__c = OEve.id;
            testEEET0.Subject__c = 'Test Template';
            testEEET0.Email_Template__c = testET0.id;
            testEEET0.Email_Template_Code__c = 'EWC';
            testEEET0.Content__c = 'test email template';
            insert testEEET0;


             //Create global email template code [EPSR]   Exhibitor-pre Show
            Email_Templates__c testET = new Email_Templates__c();
            testET.name = 'test email template';
            testET.Template_Code__c = 'EPSR';
            testET.Content__c = 'testContent';
            testET.Subject__c = 'Test Template';
            insert testET;
            
            //Create event edition email template using global email template [EPSR]
            Event_Edition_Email_Template__c testEEET = new Event_Edition_Email_Template__c();
            testEEET.Event_Edition__c = OEve.id;
            testEEET.Subject__c = 'Test Template';
            testEEET.Email_Template__c = testET.id;
            testEEET.Email_Template_Code__c = 'EPSR';
            testEEET.Content__c = 'test email template';
            insert testEEET;

              /**Stand Contractor Account **/

            List<Account> accounts = new List<Account>();
            for(Integer i=0;i<3;i++)
            {
                Account a = new Account(Name='TestAcc' + i);
                accounts.add(a);    
            }
            insert accounts;
            
            //create some contacts
            List<Contact> contacts = new List<Contact>();
            for(Integer i=0;i<3;i++)
            {
                Contact c = new Contact(AccountId = accounts[i].Id, FirstName = 'TestConFirst'+i, LastName = 'TestConLast'+i, Email='abc@test.com');
                contacts.add(c);    
            }
            insert contacts;



            //create BoothContractorMapping__c list
            List<BoothContractorMapping__c> lstBoothCM = new List<BoothContractorMapping__c>();
        
            BoothContractorMapping__c bcm = new BoothContractorMapping__c(Approved__c=True, Opp_Booth_Mapping__c=lstOppExpoBooth[0].Id, Contact__c=contacts[0].Id,Booth_Design_Status__c='No Design', 
                                                                                Event_Edition__c=oEve.Id, status__c='Rejected');
            lstBoothCM.add(bcm);    
        
            insert lstBoothCM;

               //Create global email template code [CPSR]  Contractor pre-show
            Email_Templates__c testET1 = new Email_Templates__c();
            testET1.name = 'test email template';
            testET1.Template_Code__c = 'CPSR';
            testET1.Content__c = 'testContent';
            testET1.Subject__c = 'Test Template';
            insert testET1;
            
            //Create event edition email template using global email template code [CPSR]
            Event_Edition_Email_Template__c testEEET1 = new Event_Edition_Email_Template__c();
            testEEET1.Event_Edition__c = OEve.id;
            testEEET1.Subject__c = 'Test Template';
            testEEET1.Email_Template__c = testET1.id;
            testEEET1.Email_Template_Code__c = 'CPSR';
            testEEET1.Content__c = 'test email template';
            insert testEEET1;



            //create Stand_Detail__c
            List<Stand_Detail__c> lstStndDtail = new List<Stand_Detail__c>();
                Stand_Detail__c oDetail = new Stand_Detail__c(Account__c=accounts[0].Id,Amount__c = '25',Opp_Booth_Mapping__c = lstOppExpoBooth[0].Id,IsRigging__c=true,IsDoubleDecker__c=true,
                                                            BoothContractorMapping__c=lstBoothCM[0].id ,Contractor_Agreement_CA__c=true, Is_Heavy_Machinery__c=true,IsReceived__c = true,Receipt__c= '27');
                lstStndDtail.add(oDetail);
            
            insert lstStndDtail;

            
               //Create global email template code [CPSR]
            Email_Templates__c testET2 = new Email_Templates__c();
            testET2.name = 'test email template';
            testET2.Template_Code__c = 'CPBR';
            testET2.Content__c = 'testContent';
            testET2.Subject__c = 'Test Template';
            insert testET2;
            
            //Create event edition email template using global email template code [CPSR]
            Event_Edition_Email_Template__c testEEET2 = new Event_Edition_Email_Template__c();
            testEEET2.Event_Edition__c = OEve.id;
            testEEET2.Subject__c = 'Test Template';
            testEEET2.Email_Template__c = testET2.id;
            testEEET2.Email_Template_Code__c = 'CPBR';
            testEEET2.Content__c = 'test email template';
            insert testEEET2;


            


            Test.startTest();
        
            EmailRemindersCtrl.mailExhibitorswithoutContractor(oEve.id,'');
            EmailRemindersCtrl.exhibitorPreShowReminder(oEve.id,'');
            EmailRemindersCtrl.contractorPreShowReminder(oEve.id,'');
            Event_Edition_Email_Template__c eET = EmailRemindersCtrl.getEmailContent(oEve.id,'EPSR');
            EmailRemindersCtrl.updateEmailContent(eET);
            EmailRemindersCtrl.contractorStatusReminder(oEve.Id,'No Design','EPSR','');
            EmailRemindersCtrl.mailExhibitorswithoutProfiles(oEve.id);
            EmailRemindersCtrl.contractorPerformanceBondReminder(oEve.id,'');
            Test.stopTest();


    }     

}