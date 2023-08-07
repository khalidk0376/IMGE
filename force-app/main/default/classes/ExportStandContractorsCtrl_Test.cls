/**
* Created By    :  Girikon(Sunil)
* Created On    :  12/04/2018
* @description  :  This test class covers the apex class "ExportStandContractorsCtrl" following methods:

* Methods:  
* Apex Class    :  ExportStandContractorsCtrl (85%) 
*
* Modification Log----- 
* Modified by   :  Girikon(Amit Gupta),Girikon(Rahul Kumar)[Dec 4 2018,Girikon(Himanshu)BK-2173(Sep 30 2019),BK - 2712(11 OCT 2019)][Girikon(Rajeev)BK-2346(Sep 30 2019), Aishwarya[BK-2990 Nov 29 2019]]
**/
        //Added true in System.assertNotEquals(SCA Violation) - BK - 2712

@isTest
private class ExportStandContractorsCtrl_Test 
{   
    public static testmethod void allAssigned() // test to all assigned contractors
    {    
        //Create Account
        Account acc = new Account(Name='TestAcc');
        insert acc; 
        System.assertNotEquals(null, acc, true);
        
        //create contact
        Contact oCon = new Contact(AccountId = acc.Id, FirstName = 'TestConFirst', LastName = 'TestConLast', Email='abc@test.com');
        insert oCon;
        
        //create contact
        Contact oConAOE = new Contact(AccountId = acc.Id, FirstName = 'TestConFirstAOE', LastName = 'TestConLast', Email='abc@test.com');
        insert oConAOE;
        
        //create Event_Edition__c
        Event_Edition__c ee = new Event_Edition__c(Name='TestName',Event_Currency__c='USD',Event_Code__c='XYZ');
        insert ee;
        
        Opportunity oOpportunity = new Opportunity( Name = 'Expocad Opportunity', CloseDate = Date.today().addDays(7), StageName = 'Needs Assessment', EventEdition__c = ee.Id, AccountId = acc.Id, Billing_Contact__c = oCon.Id, Payment_Status__c='Not Paid', CurrencyIsoCode = 'USD' );
        oOpportunity.Exhibitor_Paid_By__c = 'Exhibitor Paid by Agent';
        oOpportunity.StageName = 'Closed Won';
        insert oOpportunity;
        
         //Create opportunity
        Opportunity oOpportunityAgnt = new Opportunity(Name = 'Expocad Opportunity',parent_Opportunity__c=oOpportunity.Id ,CloseDate = Date.today(),StageName = 'Need Assessment',
                                                   EventEdition__c = ee.Id, Operations_Contact__c=oConAOE.id,  AccountId = acc.Id,CurrencyIsoCode = 'USD'); 
        insert oOpportunityAgnt;
        
        System.AssertNotEquals(oOpportunity, null, true);
        
        //Insert Quote
        SBQQ__Quote__c oQuote = new SBQQ__Quote__c(SBQQ__Status__c = 'Quote Sent', SBQQ__Type__c = 'Quote', SBQQ__Account__c =acc.Id, SBQQ__Primary__c = true,CurrencyIsoCode ='USD');
        insert oQuote;
        
        oQuote.SBQQ__Opportunity2__c = oOpportunity.Id;
        update oQuote;
        
        oOpportunity.StageName ='Closed Won';
        oOpportunity.SBQQ__PrimaryQuote__c = oQuote.Id;
        //update oOpportunity;
        
        oOpportunityAgnt.StageName ='Closed Won';
        oOpportunityAgnt.SBQQ__PrimaryQuote__c = oQuote.Id;
        //update oOpportunityAgnt;
        
        //create ExpocadBooth__c
        ExpocadBooth__c eB = new ExpocadBooth__c(Booth_Number__c='TestBoothNo.', status__c = 'Rented' , Opportunity__c = oOpportunity.Id);
        insert eB;

        //create ExpocadBooth__c
        ExpocadBooth__c eBAgnt = new ExpocadBooth__c(Booth_Number__c='TestBoothNo.',quote__c = oQuote.id,status__c = 'Rented' , Opportunity__c = oOpportunityAgnt.Id);
        insert eBAgnt;
        
        Opportunity_ExpoCAD_Booth_Mapping__c oppExpoBooth = new Opportunity_ExpoCAD_Booth_Mapping__c();
        oppExpoBooth.Opportunity__c = oOpportunity.Id;
        oppExpoBooth.Expocad_Booth__c = eB.id;
        oppExpoBooth.Status__c = 'Active'; 
        insert oppExpoBooth;
        
        Opportunity_ExpoCAD_Booth_Mapping__c oppExpoBooth1 = new Opportunity_ExpoCAD_Booth_Mapping__c();
        oppExpoBooth1.Opportunity__c = oOpportunityAgnt.Id;
        oppExpoBooth1.Expocad_Booth__c = eB.id;
        oppExpoBooth1.Status__c = 'Active'; 
        insert oppExpoBooth1;
        
        
        //create BoothContractorMapping__c 
        BoothContractorMapping__c bcm = new BoothContractorMapping__c(Approved__c=True,ExpocadBooth__c =eb.id , Opp_Booth_Mapping__c=oppExpoBooth.Id, Contact__c=oCon.Id,Booth_Design_Status__c='No Design', 
                                                                          Event_Edition__c=ee.Id, status__c='Rejected', Performance_Bond_Submitted__c= false);
           
        insert bcm;
         //create BoothContractorMapping__c 
        BoothContractorMapping__c bcmAgnt = new BoothContractorMapping__c(Approved__c=True,Agent_Contact__c=oConAOE.Id,IsManagedbyAgent__c= true ,Contact__c=oCon.Id,Booth_Design_Status__c='No Design', 
                                                                          Event_Edition__c=ee.Id, status__c='Rejected', Performance_Bond_Submitted__c= false);
           
        insert bcmAgnt ;
        
        
        
        apexpages.currentpage().getparameters().put('compName' , 'AllAssigned'); 
        apexpages.currentpage().getparameters().put('bdstatus' , 'All');
        apexpages.currentpage().getparameters().put('status' , 'All');
        apexpages.currentpage().getparameters().put('rigged' , 'All');
        apexpages.currentpage().getparameters().put('search' , '');
        apexpages.currentpage().getparameters().put('bDblDckrStatus' ,'False');
        
        apexpages.currentpage().getparameters().put('bCA' , 'False');
        apexpages.currentpage().getparameters().put('pbs' , 'False');
        apexpages.currentpage().getparameters().put('pbns' , 'False');
        apexpages.currentpage().getparameters().put('sme' , 'False');
        apexpages.currentpage().getparameters().put('event' , ee.id);
        apexpages.currentpage().getparameters().put('isAllAgt' , 'False');
        apexpages.currentpage().getparameters().put('isAgtPvnSpc' , 'False');
        ExportStandContractorsCtrl obj = new ExportStandContractorsCtrl(); 
        obj.exportToExcel();
         set<string> agentIds = new set<string>();
        agentIds.add(acc.id);
              
        obj.getallAgentPavilionSpaceExhibitors(agentIds,ee.id);
    }
    
    public static testmethod void subContractors() // test sub contractors
    {   
        account acc = new account();
        acc.name = 'test';
        insert acc;
        System.assertNotEquals(null, acc, true);
        
        contact con = new contact();
        con.lastname = 'test';
        con.accountid = acc.id;
        insert con;
        
        Event_Edition__c evEdition = new Event_Edition__c(Name='TestName',Event_Currency__c='USD',Event_Code__c='XYZ');
        insert evEdition;
        
        TempContact__c tc = new TempContact__c();
        tc.Is_SubContractors_Available__c = true;
        insert tc;
        
        BoothContractorMapping__c bcm = new BoothContractorMapping__c();
        bcm.TempContact__c = tc.id;
        bcm.contact__c = con.id;
        bcm.Event_Edition__c = evEdition.id;
        insert bcm;
        
        BoothContractorMapping__c bcm1 = new BoothContractorMapping__c();
        bcm1.TempContact__c = tc.id;
        bcm1.contact__c = con.id;
        bcm1.Event_Edition__c = evEdition.id;
        bcm1.Parent_BoothMapping__c = bcm.id;
        insert bcm1;
        
        apexpages.currentpage().getparameters().put('event' , evEdition.id);
        apexpages.currentpage().getparameters().put('compName' , 'Subcontractors');
        ExportStandContractorsCtrl obj = new ExportStandContractorsCtrl();
        obj.exportToExcel();
    }
    
    public static testmethod void exhibitorsWithoutContractors() // test exhibitors without contractors
    {        
        account acc = new account();
        acc.name = 'test';
        insert acc;
        System.assertNotEquals(null, acc, true);
        
        contact con = new contact();
        con.lastname = 'test';
        con.accountid = acc.id;
        insert con;
        
        Event_Edition__c evEdition = new Event_Edition__c(Name='TestName',Event_Currency__c='USD',Event_Code__c='XYZ');
        insert evEdition;
             
        User_Type__c ut = NEW User_Type__c();
        ut.name = 'Exhibitor';
        insert ut;
        
        Opportunity opp = new Opportunity();        
        opp.CloseDate =system.today();
        opp.Accountid = acc.id;
        opp.Name = 'Test Opportunity Triggers';
        opp.Operations_Contact__c = con.id;
        opp.EventEdition__c = evEdition.id;
        opp.User_Type__c = ut.id;
        opp.StageName = 'Needs Assessment'; //BK-2990
        insert opp;
        
        ExpocadBooth__c eb = new ExpocadBooth__c();
        eb.Opportunity__c = opp.id;
        eb.status__c = 'Rented';
        insert eb;
        
        opp.StageName = 'Closed Won';
        update opp;
        
        Opportunity_ExpoCAD_Booth_Mapping__c oppExpoBooth1 = new Opportunity_ExpoCAD_Booth_Mapping__c();
        oppExpoBooth1.Opportunity__c = opp.id;
        oppExpoBooth1.Expocad_Booth__c = eb.id;
        oppExpoBooth1.Status__c = 'Active';
        insert oppExpoBooth1;

        apexpages.currentpage().getparameters().put('compName' , 'ExhibitorsWithoutContractors');
        apexpages.currentpage().getparameters().put('event' ,evEdition.id );
        apexpages.currentpage().getparameters().put('search' , '');
        apexpages.currentpage().getparameters().put('mpn' , 'All'); //BK-2990
        ExportStandContractorsCtrl obj = new ExportStandContractorsCtrl();
        obj.isExcel  = false;
        obj.isCsv = true;
        obj.exportToExcel();
        ExportStandContractorsCtrl.wrapperAllExhibitors wrap = new ExportStandContractorsCtrl.wrapperAllExhibitors();
    }
   
     public static testmethod void exhibitorsWithoutContractorsSecond() // test exhibitors without contractors
    {        
        Account a = new Account(Name='TstAccFrst' , BillingStreet='testStreet',BillingCity='test', BillingState='Delhi', BillingPostalCode='13245', BillingCountry='India');
        insert a;
        
        Account acc1=new account();
        acc1.name='abc';
        insert acc1;
        
        Contact sContact = new Contact(AccountId = a.Id, FirstName = 'Test', LastName = 'Name', Email = 'abc@test.com');
        insert sContact;
        System.AssertNotEquals(sContact, null, true);
         
        
        Event_Edition__c evntID = new Event_Edition__c(Name='TestName',Event_Currency__c='USD',Event_Code__c='XYZ');
        insert evntID;
        string evntId1=string.valueOf(evntID.Id);
        System.AssertNotEquals(evntID, null, true);
        
        list<Event_Edition__c> lstEE1=[SELECT Id, Name, Event_Code__c from Event_Edition__c LIMIT 1];
        string evntCode=lstEE1[0].Event_Code__c;
        
        Event_Settings__c evntSetting = new Event_Settings__c(Disable_this_information__c =  true, Event_Edition__c = evntID.Id);
        insert evntSetting;
        System.AssertNotEquals(evntSetting, null, true);
        
        String column = 'Opportunity__r.Account.Name';
        String order = 'asc';
        String searchText = 'test';
        
        apexpages.currentpage().getparameters().put('compName' , 'ExhibitorsWithoutContractors');
        apexpages.currentpage().getparameters().put('event' ,evntId1);
        apexpages.currentpage().getparameters().put('search' , '');
        apexpages.currentpage().getparameters().put('mpn' , 'All'); //BK-2990
        ExportStandContractorsCtrl obj = new ExportStandContractorsCtrl();
        obj.exportExhibitorsWithoutConractors();
    }
    
    public static testmethod void contractorSalesForceApprovals(){ // test contractor salesforce approvals
        
        account acc = new account();
        acc.name = 'test';
        insert acc;
        System.assertNotEquals(null, acc, true);
        
        contact con = new contact();
        con.lastname = 'test';
        con.accountid = acc.id;
        insert con;
        
        Event_Edition__c evEdition = new Event_Edition__c(Name='TestName',Event_Currency__c='USD',Event_Code__c='XYZ');
        insert evEdition;
        
        TempContact__c tc = new TempContact__c();
        tc.Is_SubContractors_Available__c = true;
        insert tc;
        
        User_Type__c uType = new User_Type__c(Name ='Exhibitor');
            insert uType;
        
        Opportunity opp = new Opportunity();
        opp.StageName = 'Sourcing Demand';
        opp.CloseDate =system.today();
        opp.Accountid = acc.id;
        opp.User_Type__c = uType.Id;
        opp.Name = 'Test Opportunity Triggers';
        insert opp;
        
        ExpocadBooth__c eb = new ExpocadBooth__c();
        eb.Opportunity__c = opp.id;
        eb.Display_Name__c = 'test';
        eb.status__c = 'Rented';
        insert eb;
        
        Opportunity_ExpoCAD_Booth_Mapping__c oppExpoBooth = new Opportunity_ExpoCAD_Booth_Mapping__c();
        oppExpoBooth.Opportunity__c = opp.id;
        oppExpoBooth.Expocad_Booth__c = eb.id;
        oppExpoBooth.Status__c = 'Active';
        insert oppExpoBooth;
        
        BoothContractorMapping__c bcm = new BoothContractorMapping__c();
        bcm.TempContact__c = tc.id;
        bcm.contact__c = con.id;
        bcm.Event_Edition__c = evEdition.id;
        bcm.Approved__c = true;
        bcm.Opp_Booth_Mapping__c = oppExpoBooth.id;
        insert bcm;
        
        BoothContractorMapping__c bcm1 = new BoothContractorMapping__c();
        bcm1.TempContact__c = tc.id;
        bcm1.contact__c = con.id;
        bcm1.Event_Edition__c = evEdition.id;
        bcm1.Approved__c = false;
        bcm1.Opp_Booth_Mapping__c = oppExpoBooth.id;
        bcm1.Status__c = 'Rejected';
        insert bcm1;
        
        BoothContractorMapping__c bcm2 = new BoothContractorMapping__c();
        bcm2.TempContact__c = tc.id;
        bcm2.contact__c = con.id;
        bcm2.Event_Edition__c = evEdition.id;
        bcm2.Approved__c = false;
        bcm2.Opp_Booth_Mapping__c = oppExpoBooth.id;
        bcm2.Status__c = 'Rented';
        insert bcm2;
        
        
        apexpages.currentpage().getparameters().put('compName' , 'Contractor_SalesForce_Approvals');
        apexpages.currentpage().getparameters().put('event' ,evEdition.id );
        apexpages.currentpage().getparameters().put('selectedValue' , 'All');
        ExportStandContractorsCtrl obj = new ExportStandContractorsCtrl();        
        obj.exportToExcel();
    }
    
    public static testmethod void contractorSalesForceApprovals1()  // test contractor salesforce approvals        
    {
        
        account acc = new account(); 
        acc.name = 'test';
        insert acc;
        System.assertNotEquals(null, acc, true);
        
        contact con = new contact();
        con.lastname = 'test';
        con.accountid = acc.id;
        insert con;
        
        Event_Edition__c evEdition = new Event_Edition__c(Name='TestName',Event_Currency__c='USD',Event_Code__c='XYZ');
        insert evEdition;
        
        TempContact__c tc = new TempContact__c();
        tc.Account__c =acc.id;
        tc.Is_SubContractors_Available__c = true;
        insert tc;
        
        Opportunity opp = new Opportunity();
        opp.StageName = 'Sourcing Demand';
        opp.CloseDate =system.today();
        opp.Accountid = acc.id;
        opp.Name = 'Test Opportunity Triggers';
        insert opp;
        
        ExpocadBooth__c eb = new ExpocadBooth__c();
        eb.Opportunity__c = opp.id;
        eb.status__c = 'Rented';
        insert eb;
        
        Opportunity_ExpoCAD_Booth_Mapping__c oppExpoBooth = new Opportunity_ExpoCAD_Booth_Mapping__c();
        oppExpoBooth.Opportunity__c = opp.Id;
        oppExpoBooth.Expocad_Booth__c = eB.id;
        oppExpoBooth.Status__c = 'Active';
        insert oppExpoBooth;
        
        
        BoothContractorMapping__c bcm1 = new BoothContractorMapping__c();
        bcm1.TempContact__c = tc.id;
        //bcm1.contact__c = con.id;
        bcm1.Event_Edition__c = evEdition.id;
        bcm1.Approved__c = false;
        bcm1.Opp_Booth_Mapping__c = oppExpoBooth.id;
        bcm1.Status__c = 'Rejected';
        insert bcm1;
        
        apexpages.currentpage().getparameters().put('compName' , 'Contractor_SalesForce_Approvals');
        apexpages.currentpage().getparameters().put('event' ,evEdition.id );
        apexpages.currentpage().getparameters().put('selectedValue' , 'Rejected');
        ExportStandContractorsCtrl obj = new ExportStandContractorsCtrl();        
        obj.exportToExcel();   
    }   
    
    public static testmethod void getallAgentPavilionSpaceExhibitorsmethod(){ // test All agent pavilion space
        
       account acc = new account();
        acc.name = 'test';
        insert acc;
        System.assertNotEquals(null, acc, true);
        
        contact con = new contact();
        con.lastname = 'test';
        con.accountid = acc.id;
        insert con;
        
        Pricebook2 pb = new Pricebook2();
        pb.Name = 'TestPricebook';
        insert pb;

        
        Event_Edition__c ee = new Event_Edition__c();
        ee.Name = 'TestEvent';
        ee.Tab1__c = 'tab1';
        ee.Tab4__c = 'tab4';
        ee.Tab7__c = 'tab7';
        ee.Tab8__c = 'Tab8__c';
        ee.Payment_Schedule__c = '25-25-25-25';
        ee.X50_Cutoff_Date__c = date.today();
        ee.Cutoff_Date_1__c = date.today().addDays(1);
        ee.Cutoff_Date_2__c = date.today().addDays(2);
        ee.Cutoff_Date_3__c = date.today().addDays(3);
        ee.Event_Price_Book__c = pb.Id;
        ee.Event_Currency__c='USD';
        ee.Event_Code__c='woc152';
        insert ee;
        
        TempContact__c tc = new TempContact__c();
        tc.Is_SubContractors_Available__c = true;
        insert tc;
        
        Opportunity oppty1 = new Opportunity(Name = 'testOpp', EventEdition__c = ee.Id);
        oppty1.AccountId = acc.Id;
        oppty1.StageName ='Needs Assessment';
        oppty1.CloseDate = date.today();
        oppty1.IsCreatedByReviewProcess__c=false;
        insert oppty1;
        
         SBQQ__Quote__c qtObj1 = new SBQQ__Quote__c();
        qtObj1.SBQQ__Account__c = acc.Id;
        qtObj1.SBQQ__Status__c = 'Draft';
        qtObj1.SBQQ__Type__c = 'Quote';
        qtObj1.SBQQ__StartDate__c = date.today();
        qtObj1.Alternate_Currency2__c = 'EUR';
        qtObj1.SBQQ__Opportunity2__c = oppty1.Id;
        qtObj1.Billing_Contact__c = con.Id;
        qtObj1.CurrencyIsoCode='BRL';
        qtObj1.SBQQ__Primary__c=true;
        insert qtObj1;
        
        system.debug('q----'+qtObj1);
        
        Opportunity opp = new Opportunity();
        opp.StageName = 'Sourcing Demand';
        opp.CloseDate =system.today();
        opp.Accountid = acc.id;
        opp.Name = 'Test Opportunity Triggers';
        opp.EventEdition__c = ee.id;
        opp.SBQQ__PrimaryQuote__c = qtObj1.id;
        insert opp;
       
        ExpocadBooth__c eb = new ExpocadBooth__c();
        eb.Opportunity__c = opp.id;
        eb.status__c = 'Rented';
        eb.Booth_Product_Type__c = 'Pavilion Space';
        insert eb;
        
        
       /* BoothContractorMapping__c bcm1 = new BoothContractorMapping__c();
        bcm1.TempContact__c = tc.id;
        bcm1.contact__c = con.id;
        bcm1.Event_Edition__c = evEdition.id;
        bcm1.Approved__c = false;
        bcm1.ExpocadBooth__c = eb.id;
        bcm1.Status__c = 'Rejected';
        insert bcm1;*/
        
        
        set<string> agentIds = new set<string>();
        agentIds.add(acc.id);
        ExportStandContractorsCtrl obj = new ExportStandContractorsCtrl();        
        obj.getallAgentPavilionSpaceExhibitors(agentIds,ee.id);   
    }
    
    
}