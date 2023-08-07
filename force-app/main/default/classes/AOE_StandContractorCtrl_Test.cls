/**
 * Created By    :  Girikon(Ashish) [C2E-17]
 * Created On    :  21 Aug 2019
 * @description  :  This test class provide code coverage to "AOE_StandContractorCtrl" class.
 * Apex Class    :  AOE_StandContractorCtrl
 **/
@isTest
public class AOE_StandContractorCtrl_Test 
{
	@testSetup
    static void dataSetUp() 
    {    
         //Create Account
        List<Account> accounts = new List<Account>();
        for(Integer i=0;i<3;i++)
        {
            Account a = new Account(Name='TstAccFrst' + i, BillingStreet='testStreet',BillingCity='test', BillingState='Delhi', BillingPostalCode='13245', BillingCountry='India');
            accounts.add(a);    
        }
        insert accounts;
        
        //create some contacts
        List<Contact> contacts = new List<Contact>();
        for(Integer i=0;i<3;i++)
        {
            Contact c = new Contact(AccountId = accounts[i].Id, FirstName = 'TstConFrst'+i, LastName = 'TstConLst1'+i, Email='test@test.com', MobilePhone = '2121212145');
            contacts.add(c);    
        }
        insert contacts;
            
        //Create user
        //Profile pro = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        Profile pro = [SELECT Id FROM Profile WHERE Name = 'Customer Community Login User Custom'];
        User u = new User();

        u.FirstName = 'Sunil';
        u.LastName = 'Bajoliya';
        u.Email = 'test@wexeurope.com';
        u.Username = 'astest@wexeurope.com';
        u.Alias = 'astest';
        u.ProfileId = pro.Id;
        u.ContactId = contacts[1].id;
        u.TimeZoneSidKey    = 'America/Denver';
        u.LocaleSidKey      = 'en_US';
        u.EmailEncodingKey  = 'UTF-8';
        u.LanguageLocaleKey = 'en_US';
        system.debug('u contains ' + u);
        insert u;
        
        //Create User_Type__c
        User_Type__c oUT = new User_Type__c(Name='Stand Contractor');
        insert oUT;
                
        //Insert Quote
        SBQQ__Quote__c oQuote = new SBQQ__Quote__c(SBQQ__Status__c = 'Quote Sent', SBQQ__Type__c = 'Quote', SBQQ__Account__c =accounts[0].Id, CurrencyIsoCode = 'USD', SBQQ__Primary__c = true);
        insert oQuote;
        
        //create ExpocadBooth__c
        List<ExpocadBooth__c> lstExpoBooth = new List<ExpocadBooth__c>();
        for(Integer i=0;i<3;i++)
        {
            ExpocadBooth__c eb = new ExpocadBooth__c(Booth_Number__c='TestBoothNo.'+i,status__c= 'Rented', quote__c = oQuote.id, Related_Opportunity__c = null);
            lstExpoBooth.add(eb);   
        }
        insert lstExpoBooth;
        
        
        //create Event_Edition__c
        List<Event_Edition__c> lstEE = new List<Event_Edition__c>();
        for(Integer i=0;i<3;i++)
        {
            Event_Edition__c ee = new Event_Edition__c(Name='World of Concrete 2017'+i,Event_Code__c='WOC17',End_Date__c=System.Today(),Start_Date__c=System.Today(),Payment_Schedule__c='50-50',X50_Cutoff_Date__c=System.Today(),Cutoff_Date_1__c=System.Today(),Cutoff_Date_2__c=System.Today(),Event_Currency__c='USD',Cutoff_Date_3__c=System.Today());
            lstEE.add(ee);  
        }
        insert lstEE;
        
        
        //Create ContractorService__c
        ContractorService__c cs = new ContractorService__c(Event_Edition__c=LstEE[0].Id);
        insert cs;
        
        //create TempAccount__c
        List<TempAccount__c> lstTempAcc = new List<TempAccount__c>();
        for(Integer i=0;i<3;i++)
        {
            TempAccount__c ta = new TempAccount__c(Name='TestTC'+i,Address__c='Address'+i,State__c='Delhi',Country__c='India',City__c='test', Zip__c='111111');
            lstTempAcc.add(ta); 
        }
        insert lstTempAcc;
        
        //create TempContact__c
        List<TempContact__c> lstTempCon = new List<TempContact__c>();
        for(Integer i=0;i<3;i++)
        {
            TempContact__c tc = new TempContact__c(FirstName__c='TCFrst'+i,LastName__c='TCLst'+i, Account__c=Accounts[i].Id,TempAccount__c=LstTempAcc[i].Id, Phone__c='1234567890',Fax__c='1234567890',Email__c='abc@test.com');
            lstTempCon.add(tc); 
        }
        insert lstTempCon;
        
        //Create Event_Settings__c
        Event_Settings__c evntSttng = new Event_Settings__c(Name='Test',About_Show__c='Test',ShowHours1__c='test',ShowHours2__c='Test',Branding_Color__c='Black',Link_1__c='http://m.www.google.com/',Is_Stand_Design_Visible__c=True,Is_Stand_Detail_Visible__c=True,Is_SubContractors_Visible__c=True,Is_Amount_Visible__c=True,
        Link_2__c='http://m.www.google.com/',Link_3__c='http://m.www.google.com/',Link_4__c='http://m.www.google.com/',Link_1_Label__c='TestLink1',Link_2_Label__c='TestLink2',Link_3_Label__c='TestLink3',Link_4_Label__c='TestLink4',Allowed_Expocad_Product_Types__c = 'ABC',
        FaceBook__c='http://m.www.facebook.com/',LinkedIn__c='http://m.www.linkedin.com/',Twitter__c='http://m.www.Twitter.com/',YouTube__c='http://m.www.youtube.com/',Custom_1_Title__c='CstmTitle',Event_Edition__c=LstEE[0].Id,E_Commerce_Title__c='EC Title',Welcome_Stand_Contractor__c='WSC Test',Disable_this_information__c=True);
        
        insert evntSttng;
        
        //create BoothContractorMapping__c
        List<BoothContractorMapping__c> lstBoothCM = new List<BoothContractorMapping__c>();
        for(Integer i=0;i<3;i++)
        {
            BoothContractorMapping__c bcm = new BoothContractorMapping__c(Approved__c=True, ExpocadBooth__c=LstExpoBooth[i].Id, Contact__c=contacts[i].Id, TempContact__c=lstTempCon[i].Id,Event_Edition__c=lstEE[i].Id);
            lstBoothCM.add(bcm);    
        }
        insert lstBoothCM;
        System.assertNotEquals(lstBoothCM, null,'maping Cannot be Null');
        System.debug('lstBoothCM ' +lstBoothCM);
        
        //create CustomerContractorService__c
        List<CustomerContractorService__c> lstCstmrConSrvc = new List<CustomerContractorService__c>();
        for(Integer i=0;i<3;i++)
        {
            CustomerContractorService__c ccs = new CustomerContractorService__c(BoothContractorMapping__c=lstBoothCM[i].Id,ContractorService__c=cs.Id,Event_Edition__c=lstEE[i].Id);
            lstCstmrConSrvc.add(ccs);   
        }
        insert lstCstmrConSrvc;
        
        //Create opportunity
        Opportunity oOpportunity = new Opportunity(Name = 'Expocad Opportunity', CloseDate = Date.today(),StageName = 'Need Assessment',CurrencyIsoCode = 'USD',
                                                   EventEdition__c = lstEE[0].Id, Operations_Contact__c=contacts[1].id,  AccountId = accounts[0].Id, Billing_Contact__c = contacts[1].id, Opportunity_Contact__c=contacts[1].id); 
        insert oOpportunity;
        
        System.AssertNotEquals(oOpportunity, null,'Opp cannot be null');
        
        oQuote.SBQQ__Opportunity2__c = oOpportunity.Id;
        update oQuote;
        
        oOpportunity.StageName ='Closed Won';
        oOpportunity.SBQQ__PrimaryQuote__c = oQuote.Id;
        //update oOpportunity;
        
        //create ExpocadBooth__c
        List<Opportunity_ExpoCAD_Booth_Mapping__c> lstExpoBoothMaping = new List<Opportunity_ExpoCAD_Booth_Mapping__c>();
        for(Integer i=0;i<3;i++)
        {
            Opportunity_ExpoCAD_Booth_Mapping__c ebm = new Opportunity_ExpoCAD_Booth_Mapping__c(Expocad_Booth__c = lstExpoBooth[i].id,Display_Name__c = 'Test'+i, quote__c = oQuote.id, Opportunity__c = oOpportunity.id,Related_Opportunity__c = null);
            lstExpoBoothMaping.add(ebm);   
        }
        insert lstExpoBoothMaping;
        
        //Create BoothContractorMapping
        BoothContractorMapping__c bcm=new BoothContractorMapping__c();
         bcm.Agent_Contact__c=u.ContactId ;
        bcm.Event_Edition__c=lstEE[0].Id;   
        bcm.Status__c ='Pending';
        insert bcm;        
    }
    @isTest static void validateAgentStandContractor()
    {
        list<Event_Edition__c> lstEE=[SELECT Id, Name, Event_Code__c from Event_Edition__c LIMIT 1];
        list<Account> lstAcc=[SELECT Id, Name from Account LIMIT 1];
        list<Contact> lstCon=[SELECT Id, Name from Contact LIMIT 1];
        list<BoothContractorMapping__c> lstBCM=[SELECT Id FROM BoothContractorMapping__c];
        list<TempAccount__c> lstTmpAcc=[SELECT Id, Name from TempAccount__c LIMIT 1];
        list<ContractorService__c> lstCSs=[SELECT Id from ContractorService__c];
        
        List<Opportunity_ExpoCAD_Booth_Mapping__c> lstExpoBoothMaping =[SELECT Id from Opportunity_ExpoCAD_Booth_Mapping__c];
        list<string> lstEBoothId = new list<string>();
        for(Opportunity_ExpoCAD_Booth_Mapping__c eb: lstExpoBoothMaping)
        {
            lstEBoothId.add(string.valueOf(eb.id)); 
        }
        string bCMIdStrng=string.valueOf(lstBCM[0].Id); // String Value
        list<string> lstCsIDS=new list<string>();
        for(ContractorService__c cs: lstCSs)
        {
            lstCsIDS.add(string.valueOf(cs.Id));
            
        }
        System.assertNotEquals(null, lstEE[0],'No services Found');
        
        Contact con = new Contact(AccountId = lstAcc[0].Id, FirstName = 'TstConFrst', LastName = 'TstConLst1', Email='test@test.com');
        insert con;
        contact con1 =new contact();
        
        Test.startTest();
        Event_Settings__c eventsting 		= 	AOE_StandContractorCtrl.getEventDetails(lstEE[0].Event_Code__c);
        	map<string,list<BoothContractorMapping__c>> mapBth 	= 	AOE_StandContractorCtrl.getAOEBoothsMapping(lstEE[0].Event_Code__c, lstAcc[0].Id);
        	list<account> listAcc 			=	AOE_StandContractorCtrl.getAccountContacts(lstEE[0].Event_Code__c,'');
        	account acc			 			=	AOE_StandContractorCtrl.getAccount(lstEE[0].Event_Code__c,'');
        	list<ContractorService__c> lstCS=   AOE_StandContractorCtrl.getServices(lstEE[0].Event_Code__c);
        	string msg2                     =   AOE_StandContractorCtrl.updateServices(bCMIdStrng,lstEE[0].Id,lstCsIDS);
            list<sObject> lstsObject        =   AOE_StandContractorCtrl.getDuplicateContacts(lstCon[0]);
            map<string,sObject> mapStringSobject    =   AOE_StandContractorCtrl.createTempAccount(lstAcc[0]);
            contact conObj                  =   AOE_StandContractorCtrl.getContactByID(lstCon[0].Id);
            string objStr                   =   AOE_StandContractorCtrl.removeContact(bCMIdStrng);
            list<BoothContractorMapping__c> lstBcmobj = AOE_StandContractorCtrl.getBoothConMapById(bCMIdStrng);
            string objStr3                  =   AOE_StandContractorCtrl.deleteTempAccount(lstTmpAcc[0].Id);
            list<string> lstStr2            =   AOE_StandContractorCtrl.getPicklistValues('Account','billingCountryCode');
            Map<String,List<String>> objResults = AOE_StandContractorCtrl.getDependentMap('Account','billingCountryCode','billingStateCode');
            ContactEventEditionMapping__c conEvM= AOE_StandContractorCtrl.getCurrentUserType(lstEE[0].Event_Code__c);
            AOE_StandContractorCtrl.deleteSubContarctors(bCMIdStrng);
            
            string objString1       =   AOE_StandContractorCtrl.createContactandMapping(con,lstEE[0].Id,lstTmpAcc[0].Id,lstEBoothId,lstCsIDS);
            string objString2       =   AOE_StandContractorCtrl.createContactandMapping(lstCon[0],lstEE[0].Id,lstTmpAcc[0].Id,lstEBoothId,lstCsIDS);
            string objString3       =   AOE_StandContractorCtrl.createContactandMapping(con1,lstEE[0].Id,lstTmpAcc[0].Id,lstEBoothId,lstCsIDS);
            
            
        Test.stopTest();
    }
}