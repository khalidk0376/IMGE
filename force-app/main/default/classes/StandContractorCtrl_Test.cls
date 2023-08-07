/**
 * Created By    :  Girikon(Sunil)
 * Created On    :  04/16/2018
 * Modified by   :  
 * Modified On   : 
 * @description  :  This test class provide code coverage to "StandContractorCtrl" class.
 * Apex Class    :  StandContractorCtrl
 **/
 
@isTest
private class StandContractorCtrl_Test
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
            Contact c = new Contact(AccountId = accounts[i].Id, FirstName = 'TstConFrst'+i, LastName = 'TstConLst1'+i, Email='test@test.com');
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
        
        Event_Series__c oEventseries = new Event_Series__c(Name = 'World Of Concrete', CurrencyISOCode = 'USD', Package_Identifier__c = 'WOC', Event_Edition_Pool__c = 'WOC');
        oEventseries.Status__c = 'Active';
        insert oEventseries;
        
        //create Event_Edition__c
        List<Event_Edition__c> lstEE = new List<Event_Edition__c>();
        for(Integer i=0;i<3;i++)
        {
            Event_Edition__c ee = new Event_Edition__c(Name='World of Concrete 2017'+i,Event_Code__c='WOC17',End_Date__c=System.Today(),Start_Date__c=System.Today(),Payment_Schedule__c='50-50',X50_Cutoff_Date__c=System.Today(),Cutoff_Date_1__c=System.Today(),Cutoff_Date_2__c=System.Today(),Event_Currency__c='USD',Cutoff_Date_3__c=System.Today());
            ee.Part_of_Series__c = oEventseries.Id;
            lstEE.add(ee);  
        }
        lstEE[0].Event_Edition_Status__c = 'Confirmed';
        lstEE[0].Event_Code__c = 'test';
        lstEE[1].Event_Edition_Status__c = 'Confirmed';
        lstEE[1].Event_Code__c = 'test';
        lstEE[2].Event_Edition_Status__c = 'Confirmed';
        lstEE[2].Event_Code__c = 'test';
      //  lstEE[3].Event_Edition_Status__c = 'Confirmed';
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
        System.assertNotEquals(lstBoothCM, null,'should not be null');
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
        
        System.AssertNotEquals(oOpportunity, null,'opportunity should not be null');
        
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
        
        
        test.startTest();
        StandContractorCtrl.getPavilionSpaceExhibitors(lstEE[0].Event_Code__c,accounts[0].Id,'test');
        StandContractorCtrl.getOppBoothformAccount(lstEE[0].Event_Code__c,accounts[0].Id);
        StandContractorCtrl.getBoothsMapping(lstEE[0].Event_Code__c);
        StandContractorCtrl.PrefContractors(lstEE[0].Event_Code__c,'test');
        StandContractorCtrl.getDepndentCustom('AF');
        test.stopTest();
    }
    
    @isTest static void validateCreateContactandMapping()
    {
        list<contact> lstCon=[ select Id, FirstName,lastName,AccountId,Email from contact where FirstName = 'TstConFrst1' limit 1];
        System.assertNotEquals(null, lstCon[0],'contact should not be null');
        contact objCon=lstCon[0];
        string strConId=string.valueOf(objCon.Id); 
        
        string srchString='test';
        
        list<Event_Edition__c> lstEE=[SELECT Id, Name, Event_Code__c from Event_Edition__c LIMIT 1];
        System.assertNotEquals(null, lstEE[0],'event edition should not be null');
        string evntId=string.valueOf(lstEE[0].id);
        
        list<Event_Edition__c> lstEE1=[SELECT Id, Name, Event_Code__c from Event_Edition__c LIMIT 1];
        System.assertNotEquals(null, lstEE1[0],'event edition should not be null');
        string evntCode=lstEE1[0].Event_Code__c;
        list<TempAccount__c> lstTmpAcc=[SELECT Id, Name from TempAccount__c LIMIT 1];
        System.assertNotEquals(null, LstTmpAcc[0],'should not be null');
        string tempAccId=string.valueOf(LstTmpAcc[0].Id);
        test.startTest();
        List<Opportunity_ExpoCAD_Booth_Mapping__c> lstExpoBoothMaping =[SELECT Id from Opportunity_ExpoCAD_Booth_Mapping__c];
        list<string> lstEBoothId = new list<string>();
        for(Opportunity_ExpoCAD_Booth_Mapping__c eb: lstExpoBoothMaping)
        {
            lstEBoothId.add(string.valueOf(eb.id)); 
        }
        list<ContractorService__c> lstCS=[SELECT Id from ContractorService__c];
        list<string> lstCsIDS=new list<string>();
        for(ContractorService__c cs: lstCS)
        {
            lstCsIDS.add(string.valueOf(cs.Id));
            
        }
        contact con1 =new contact();
        
        list<BoothContractorMapping__c> lstBCM=[SELECT Id FROM BoothContractorMapping__c];
        string bCMIdStrng=string.valueOf(lstBCM[0].Id);
        list<Account> lstAcc=[SELECT Id,Name,BillingStreet,BillingCity,BillingState,BillingPostalCode,BillingCountry from account];
        Account acc=LstAcc[0];
        Account acc1=new account();
        acc1.name='abc';
        insert acc1;
        list<account> lstAccount=[select id from Account limit 1];
        Contact con = new Contact(AccountId = lstAccount[0].Id, FirstName = 'TstConFrst', LastName = 'TstConLst1', Email='test@test.com');
        insert con;         
        
        Event_Settings__c testEvntSttng=StandContractorCtrl.getEventDetails(EvntCode);
        list<account> lstAccnt=StandContractorCtrl.getAccountContacts(EvntCode,SrchString);
        Account objAcc=StandContractorCtrl.getAccount(EvntCode,SrchString);
        list<ExpocadBooth__c> lstEB=StandContractorCtrl.getBooths(EvntCode);
        map<string,list<BoothContractorMapping__c>> mapStrngAndBCM=StandContractorCtrl.getBoothsMapping(EvntCode);
        string objString1=StandContractorCtrl.createContactandMapping(con,EvntId,TempAccId,lstEBoothId,lstCsIDS,false);
        string objString2=StandContractorCtrl.createContactandMapping(ObjCon,EvntId,TempAccId,lstEBoothId,lstCsIDS,false);
        string objString3=StandContractorCtrl.createContactandMapping(con1,EvntId,TempAccId,lstEBoothId,lstCsIDS,false);
        string objString4=StandContractorCtrl.updateServices(bCMIdStrng,EvntId,lstCsIDS);
        list<sObject> lstsObject1=StandContractorCtrl.getDuplicateRecords(Acc); 
        list<sObject> lstsObject2=StandContractorCtrl.getDuplicateContacts(con);
        map<string,sObject> mapStringSobject=StandContractorCtrl.createTempAccount(Acc);
        map<string,sObject> mapStringSobject2=StandContractorCtrl.createTempAccount(Acc1);
        contact objCon1=StandContractorCtrl.getContactByID(strConId);
        list<ContractorService__c> lstCS4=StandContractorCtrl.getServices(EvntCode);
        string objStr=StandContractorCtrl.removeContact(bCMIdStrng);
        string objStr3=StandContractorCtrl.deleteTempAccount(TempAccId);
        list<string> lstStr2=StandContractorCtrl.getPicklistValues('Account','billingCountryCode');
        list<string> lstBoothIds = new list<string>();
        
        for(ExpocadBooth__c  ec : [select id,Booth_Number__c from ExpocadBooth__c where Booth_Number__c like 'TestBoothNo%'])
        {
            lstBoothIds.add(ec.id);
        }
        StandContractorCtrl.getCurrentUserType(lstEE1[0].Event_Code__c);
        StandContractorCtrl.getBoothsMappingPavillion(lstEE1[0].Event_Code__c);        
        //UtilityMethods.sendEmailByCode(LstEE1[0].Id,'ISC',con,lstBoothIds); 
        Map<String,List<String>> objResults = StandContractorCtrl.getDependentMap('Account','billingCountryCode','billingStateCode');
        test.stopTest();
    }
}