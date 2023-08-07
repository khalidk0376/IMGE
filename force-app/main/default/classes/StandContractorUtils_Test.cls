@isTest
public class StandContractorUtils_Test
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
        insert u;
        System.assertNotEquals(null, u.id,'user is not null');

        //Create User_Type__c
        User_Type__c oUT = new User_Type__c(Name='Stand Contractor');
        insert oUT;
        
        //Create User_Type__c
        User_Type__c oUTAgnt = new User_Type__c(Name='Agent');
        insert oUTAgnt;
        
        //create Event_Edition__c        
        Event_Edition__c evntEdtn = new Event_Edition__c(Name='World of Concrete 2017',Event_Code__c='WOC17',End_Date__c=System.Today(),Start_Date__c=System.Today(),Payment_Schedule__c='50-50',X50_Cutoff_Date__c=System.Today(),Cutoff_Date_1__c=System.Today(),Cutoff_Date_2__c=System.Today(),Event_Currency__c='USD',Cutoff_Date_3__c=System.Today());            
        insert evntEdtn;
        
        //Create Event_Settings__c
        Event_Settings__c evntSttng = new Event_Settings__c(Name='Test',About_Show__c='Test',ShowHours1__c='test',ShowHours2__c='Test',Branding_Color__c='Black',Link_1__c='http://m.www.google.com/',Is_Stand_Design_Visible__c=True,Is_Stand_Detail_Visible__c=True,Is_SubContractors_Visible__c=True,Is_Amount_Visible__c=True,Link_2__c='http://m.www.google.com/',Link_3__c='http://m.www.google.com/',Link_4__c='http://m.www.google.com/',Link_1_Label__c='TestLink1',Link_2_Label__c='TestLink2',Link_3_Label__c='TestLink3',Link_4_Label__c='TestLink4',Allowed_Expocad_Product_Types__c = 'Space Only',FaceBook__c='http://m.www.facebook.com/',LinkedIn__c='http://m.www.linkedin.com/',Twitter__c='http://m.www.Twitter.com/',YouTube__c='http://m.www.youtube.com/',Custom_1_Title__c='CstmTitle',Event_Edition__c=evntEdtn.Id,E_Commerce_Title__c='EC Title',Welcome_Stand_Contractor__c='WSC Test',Disable_this_information__c=True);
        
        insert evntSttng;
        
        //Create global email template code [EWC] Exhibitor Without Contractor
        Email_Templates__c testET0 = new Email_Templates__c();
        testET0.name = 'test email template';
        testET0.Template_Code__c = 'ISC';
        testET0.Content__c = 'testContent';
        testET0.Subject__c = 'Test Template';
        insert testET0;
        
        //Create event edition email template using global email template [OPSISC]
        Event_Edition_Email_Template__c testEEET0 = new Event_Edition_Email_Template__c();
        testEEET0.Event_Edition__c = evntEdtn.id;
        testEEET0.Subject__c = 'Test Template';
        testEEET0.Email_Template__c = testET0.id;
        testEEET0.Email_Template_Code__c = 'ISC';
        testEEET0.Content__c = 'test email template';
        insert testEEET0;
        
        //Create opportunity
        Opportunity oOpportunity = new Opportunity(Name = 'Expocad Opportunity', CloseDate = Date.today(),StageName = 'Closed Won',CurrencyIsoCode = 'USD',EventEdition__c = evntEdtn.Id, Operations_Contact__c=contacts[0].id,  AccountId = accounts[0].Id, Billing_Contact__c = contacts[1].id, Opportunity_Contact__c=contacts[1].id ,User_Type__c=oUTAgnt.id); 
        insert oOpportunity;
        
        Opportunity oOpportunity1 = new Opportunity(Name = 'Expocad Opportunity', CloseDate = Date.today(),StageName = 'Need Assessment',CurrencyIsoCode = 'USD',EventEdition__c = evntEdtn.Id, Operations_Contact__c=contacts[0].id,  AccountId = accounts[0].Id, Billing_Contact__c = contacts[1].id,  Parent_Opportunity__c=oOpportunity.id, Opportunity_Contact__c=contacts[1].id); 
        insert oOpportunity1;
        //Create Quote            
        SBQQ__Quote__c oQuote = new SBQQ__Quote__c();
        oQuote.SBQQ__Account__c = accounts[0].Id;
        oQuote.SBQQ__Status__c = 'Draft';
        oQuote.SBQQ__Type__c = 'Quote';
        oQuote.SBQQ__StartDate__c = date.today();
        oQuote.Alternate_Currency2__c = 'EUR';
        oQuote.SBQQ__Opportunity2__c = oOpportunity1.Id;
        oQuote.CurrencyIsoCode='BRL';
        insert oQuote;
         
         Test.startTest();
        oOpportunity1.SBQQ__PrimaryQuote__c = oQuote.Id;
        oOpportunity1.StageName='Closed Won';
    update oOpportunity1;
        
        //create ExpocadBooth__c
        List<ExpocadBooth__c> lstExpoBooth = new List<ExpocadBooth__c>();
        for(Integer i=0;i<3;i++)
        {
            ExpocadBooth__c eb = new ExpocadBooth__c(Booth_Number__c='TestBoothNo.'+i,status__c= 'Rented', quote__c = oQuote.id,Display_Name__c = 'test' ,Related_Opportunity__c = null , Area__c='30' ,Matched_Product_Name__c=evntSttng.Allowed_Expocad_Product_Types__c, Booth_Classes__c='abc');
            lstExpoBooth.add(eb);   
        }
        insert lstExpoBooth;
        
        //create ExpocadBooth__c
        List<Opportunity_ExpoCAD_Booth_Mapping__c> lstExpoBoothMaping = new List<Opportunity_ExpoCAD_Booth_Mapping__c>();
        for(Integer i=0;i<3;i++)
        {
            Opportunity_ExpoCAD_Booth_Mapping__c ebm = new Opportunity_ExpoCAD_Booth_Mapping__c(Status__c='Active',Expocad_Booth__c = lstExpoBooth[i].id,Display_Name__c = 'Test'+i, quote__c = oQuote.id, Opportunity__c = oOpportunity1.id,Related_Opportunity__c = null );
            lstExpoBoothMaping.add(ebm);   
        }
        insert lstExpoBoothMaping;
        
        TempContact__c tcon  = new TempContact__c(Account__c = accounts[0].id ,FirstName__c='TCFrst',LastName__c='TCLst',Phone__c='1234567890',Fax__c='1234567890',Email__c='abc@test.com');
        insert tcon;
        
        //create BoothContractorMapping__c 
        BoothContractorMapping__c bcm = new BoothContractorMapping__c(Status__c = 'Pending',TempContact__c =tcon.id,Event_Edition__c=evntEdtn.Id,Opp_Booth_Mapping__c = lstExpoBoothMaping[0].id ,Rejection_Reason__c='rejected');
        insert bcm;
        list<string> expoBth = new list<string>();
        for(Opportunity_ExpoCAD_Booth_Mapping__c lstoppexpoBooth :lstExpoBoothMaping)
        {
         expoBth.add(lstoppexpoBooth.id);   
        }
        StandContractorUtils.sendEmailToContractorByCode(evntEdtn.id,'ISC', contacts[0],expoBth) ;
        
        Test.stopTest();
        
    }
    @isTest static void validateCustomerBooths()
    {
        test.startTest();
        Account acc = [select id from account where name = 'TstAccFrst0'];
        System.assertNotEquals(null, acc.id,'Account is not null');
        Event_Edition__c evntEdtn = [select id,Event_Code__c from Event_Edition__c limit 1];
        List<Opportunity_ExpoCAD_Booth_Mapping__c> lstExpoBoothMaping = new List<Opportunity_ExpoCAD_Booth_Mapping__c>();
        lstExpoBoothMaping = StandContractorUtils.getCustomerBooths(acc.Id, evntEdtn.Event_Code__c);
       
        BoothContractorMapping__c bcm = [select id from BoothContractorMapping__c limit 1];
        string str = StandContractorUtils.approveStandContractor(bcm.Id,'Ops Admin');  
        StandContractorUtils.getPavilionSpaceExhibitorsBooths(evntEdtn.Event_Code__c,acc.id,'test');
        test.stopTest();              
    }
    @isTest static void validateApproveCons()
    {
        Test.startTest();
        Event_Edition__c evntEdtn = [select id,Event_Code__c from Event_Edition__c limit 1];
        Opportunity_ExpoCAD_Booth_Mapping__c oppBth =  [select id from Opportunity_ExpoCAD_Booth_Mapping__c where Display_Name__c != null limit 1];
        Contact con  =  [select id from contact where lastname = 'TstConLst12' limit 1];
        System.assertNotEquals(null, con.id,'Contact is not null');
        TempAccount__c tmpAcc = new TempAccount__c(Name='TestTC',Address__c='Address',State__c='Delhi',Country__c='India',City__c='test', Zip__c='111111');
        insert tmpAcc ;
        
        TempContact__c tmpCon = new TempContact__c(FirstName__c='TCFrst',LastName__c='TCLst',TempAccount__c = tmpAcc.id, Phone__c='1234567890',Fax__c='1234567890',Email__c='abc@test.com');
        insert tmpCon ;
        
        //create BoothContractorMapping__c 
        BoothContractorMapping__c bcm = new BoothContractorMapping__c(Status__c = 'Pending',TempContact__c = tmpCon.id,Event_Edition__c=evntEdtn.Id,Opp_Booth_Mapping__c = oppBth.id);
        insert bcm;
        
        //create BoothContractorMapping__c 
        BoothContractorMapping__c bcmCon = new BoothContractorMapping__c(Status__c = 'Pending',Contact__c = con.id,Event_Edition__c=evntEdtn.Id,Opp_Booth_Mapping__c = oppBth.id);
        insert bcmCon;
        
        string str = StandContractorUtils.approveStandContractor(bcm.Id,'Ops Admin');
        string str1 = StandContractorUtils.approveStandContractor(bcmCon.Id,'Ops Admin');
        List<BoothContractorMapping__c> lstBcm = StandContractorUtils.getSingleContractorDetail(bcm.Id);
        test.stopTest();
    }
    @isTest static void validateApproveConsuser()
    {   
        Test.startTest();     
        Event_Edition__c evntEdtn = [select id,Event_Code__c from Event_Edition__c limit 1];
        Opportunity_ExpoCAD_Booth_Mapping__c oppBth =  [select id from Opportunity_ExpoCAD_Booth_Mapping__c where Display_Name__c != null limit 1 ];
        Contact con  =  [select id from contact where lastname = 'TstConLst11' limit 1];
        Contact con1  =  [select id from contact where lastname = 'TstConLst10' limit 1];
        System.assertNotEquals(null, con.id,'contact is not null');
        //create ContactEventEditionMapping__c
        ContactEventEditionMapping__c conEmp = new ContactEventEditionMapping__c(SFContactID__c = con1.id,SFEventEditionID__c = evntEdtn.Id);
        insert conEmp;
        
        //create BoothContractorMapping__c 
        BoothContractorMapping__c bcm = new BoothContractorMapping__c(Status__c = 'Pending',Contact__c = con1.id,Event_Edition__c=evntEdtn.Id,Opp_Booth_Mapping__c = oppBth.id);
        insert bcm;
        
        //create BoothContractorMapping__c
        BoothContractorMapping__c bcmCon = new BoothContractorMapping__c(Status__c = 'Pending',Contact__c = con.id,Event_Edition__c=evntEdtn.Id,Opp_Booth_Mapping__c = oppBth.id);
        insert bcmCon;
        
        
        string str = StandContractorUtils.approveStandContractor(bcm.Id,'Ops Admin');
        string str1 = StandContractorUtils.approveStandContractor(bcmCon.Id,'Ops Admin');
        StandContractorUtils.createContractorUser(con.id,evntEdtn.id);
        // Added by Palla Kishore for the ticket BK-19602
        system.debug('str@@@@'+str);
        system.assertEquals('Successfully  Approved!', str, 'Here value is not same ');
        test.stopTest();
    }
    @isTest static void validateDesignAndDetail()
    { 
    Test.startTest();
    Opportunity_ExpoCAD_Booth_Mapping__c oppBth =  [select id from Opportunity_ExpoCAD_Booth_Mapping__c where Display_Name__c != null And Opportunity__c != null  limit 1 ];
    BoothContractorMapping__c bcmCon = [select id from BoothContractorMapping__c limit 1];  
        Account acc = [select id from Account limit 1];
        Event_Edition__c edtn = [select id,Event_Code__c From Event_Edition__c limit 1];
        StandContractorUtils.getBoothsMappingFromAccId(edtn.Event_Code__c,acc.id);

        //create Stand_Design__c list
        List<Stand_Design__c> lstStndDesign = new List<Stand_Design__c>();
        for(Integer i=0;i<1;i++)
        {
            Stand_Design__c oDesign = new Stand_Design__c(Account__c = acc.Id,Event_Edition__c = edtn.id,Opp_Booth_Mapping__c = oppBth.Id,BoothContractorMapping__c = bcmCon.id,Booth_Design_Status__c='Tentative Approval',Booth_Design_Submitted_On__c=system.today(),Submitted_to_Venue_On__c=system.today(),Is_Rejected__c=false);
            lstStndDesign.add(oDesign);
        }
        insert lstStndDesign;
        //create Stand_Detail__c
        List<Stand_Detail__c> lstStndDtail = new List<Stand_Detail__c>();
        for(Integer i=0;i<1;i++)
        {
            Stand_Detail__c oDetail = new Stand_Detail__c(Account__c = acc.Id,Amount__c = '25',Event_Edition__c = edtn.id,Opp_Booth_Mapping__c = oppBth.Id,BoothContractorMapping__c = bcmCon.id,IsRigging__c=true,IsDoubleDecker__c=true,Contractor_Agreement_CA__c=true, Is_Heavy_Machinery__c=true,IsReceived__c = true,Receipt__c= '27');
            lstStndDtail.add(oDetail);
        }
        insert lstStndDtail;
        
        list<Stand_Design__c> lstDesign     = StandContractorUtils.getSingleStandDesign(oppBth.Id, acc.Id, edtn.Id, '');
        list<Stand_Design__c> lstDesignAgn  = StandContractorUtils.getSingleStandDesign(oppBth.Id, acc.Id, edtn.Id,acc.Id);
        
        List<Stand_Detail__c> lstStndDtails  = StandContractorUtils.getSingleStandDetail(oppBth.Id, acc.Id, edtn.Id, '');
        List<Stand_Detail__c> lstStndDtailsAgn =  StandContractorUtils.getSingleStandDetail(oppBth.Id, acc.Id, edtn.Id,acc.Id);
        
        Map<String,Stand_Detail__c> mapAccStndDetail = StandContractorUtils.getAllStandDetail(edtn.Event_Code__c);
        Map<String,Stand_Design__c> mapAccStndDesign = StandContractorUtils.getAllStandDesign(edtn.Event_Code__c);
        
        //Id attId = StandContractorUtils.saveStandDesignChunk(bcmCon.id, 'xys', 'text',null,'Non Complex', string.valueOf(oppBth.Id), 'Text',acc.Id, string.valueOf(edtn.Id),'');
        //Id attId2 = StandContractorUtils.saveStandDesignChunk(bcmCon.id, 'xys', 'text',attId,'Non Complex', string.valueOf(oppBth.Id), 'Text',acc.Id, string.valueOf(edtn.Id),'');
        //System.assertNotEquals(null,attId,'Stand design chunk is not null');
        Test.stopTest();
    }
}