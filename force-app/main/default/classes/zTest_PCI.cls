/************************************************************************** 
** 
** Last Modified by Shay Spoonmore (shay.spoonmore@informausa.com)2012-02-14, [Aishwarya 31 Aug 2020 BK-6577]
**   
Ticket No.-BK-14522 Updating API Version
***************************************************************************/ 
@isTest
private class zTest_PCI {
    
    static PCI_Scanner__c psSetting =new PCI_Scanner__c();
    //static User testUser =insertUser();
    
    @testSetup static void Settings() 
    {
        CreateApplicationBypass();
        psSetting =CreatePCISetting();    
    }
    
    static testMethod void PCIScanHistoryRelationship() 
    {
        
        User testUser =insertUser();
        PCI_Credit_Card_Numbers__c pciCCN = new PCI_Credit_Card_Numbers__c
            (
                CCN_Last_4_Digits__c  = '0140'
                , CCN_Length__c =13
                , CCN_Type__c = 'Unknown'
                , CNN_Match_Length__c=true
                , CNN_Match_Luhn__c=true
                , Field_Name__c='Federal_Tax_ID__c'
                , Field_Value__c='#########0140'
                , PCI_Scan_History__c = null
                , Record_Action__c = 'False Positive'
                //, Record_Created_Date__c = ''
                , Record_Group__c = null
                //  , Record_Id__c = '0016000000I739EAAR'
                //, Record_Last_Modified__c = 
                //, Record_Last_Modified_Date__c
                //  , Record_Owner__c = testUser.Id //'005600000011f8EAAQ'
                //, Record_ParentId__c
                //   , Record_RecordTypeId__c = '01260000000DS9CAAW'
                //, Record_RecordTypeName__c
                //, Record_URL__c
                //, System_Action_Description__c
                //, System_BU__c
                , System_CCN_Id__c = 'XAfter'
                , System_Scan_Id__c = 'XAfter'
                //, System_Time_Stamp__c
                
            );
        insert pciCCN;
        
        
        PCI_Scan_History__c pciHistory = new PCI_Scan_History__c
            (
                //Record_Last_Success__c
                //, 
                //    Record_Last_Success_Id__c ='0016000000HdgkOAAR'
                Record_Object__c = 'Account',
                //, Scan_Begin__c
                Scan_CCN_Found__c =58.0,
                //, Scan_End__c
                //, Scan_Failure__c
                //, Scan_Failure_Message__c
                //, Scan_Finished__c
                //, Scan_Last__c
                Scan_Records_Found__c =215560,
                Scan_Records_Processed__c =215560,
                Scan_Retried__c =0,
                Scan_Running__c = false,
                System_Scan_Id__c = 'XAfter'
            );
        insert pciHistory;
        Map<String,Id> mapIds = new Map<String,Id>();
        List<string> systemScanIds = new List<string>();
        systemScanIds.add('XAfter');
        mapIds.put('XAfter', pciHistory.Id);
        
        Test.StartTest();
        
        String query = 'Select Id,System_Scan_Id__c  from PCI_Credit_Card_Numbers__c Where System_Scan_Id__c IN (\'XAfter\')';
        System.debug('*****SELECT=' + query);
        PCIScanHistoryRelationship checkCNN = new PCIScanHistoryRelationship();
        checkCNN.query = query;
        checkCNN.isTesting = True;
        checkCNN.systemScanIds = systemScanIds ; 
        checkCNN.mapIds = mapIds;
        ID batchprocessid = Database.executeBatch(checkCNN);
        Test.StopTest();
        
        System.AssertEquals(database.countquery('Select count() from PCI_Credit_Card_Numbers__c Where System_Scan_Id__c IN (\'XAfter\')'), 1 , 'The query must fetch a record and the record must not be null');
        
        
        
        
    }
    
    
    static testMethod void PCIOwnershipTrigger_FalsePositive() 
    {
        // Create Trigger test record 
        Trigger__c trig = new Trigger__c(Name = 'PCIOwnership_Trig' , Trigger_Name_Unique__c='PCIOwnership_Trig',Enabled__c=true,Object__c='PCI_Credit_Card_Numbers__c',Run_for_Recordypes__c='All',  Description__c='my test',Execution_Order__c=1,before_Insert__c=true , before_Update__c = true);
        Insert trig;
        Trigger__c trig2 = new Trigger__c(Name = 'PCICreditCardRelationship_Trig' , Trigger_Name_Unique__c='PCICreditCardRelationship_Trig',Enabled__c=true,Object__c='PCI_Credit_Card_Numbers__c',Run_for_Recordypes__c='All',  Description__c='my test',Execution_Order__c=2, before_Insert__c=true , before_Update__c = true);
        Insert trig2;
        Trigger_Recordtype__c rt = new Trigger_Recordtype__c(Enabled__c=true,Recordtype_Id__c=trig.Id,Trigger__c=trig.Id,Parameters__c='param=1;param=2');
        Insert rt;    
        //Call event edition trigger interface
        TriggerInterface_PCICreditCardNumber obj = new TriggerInterface_PCICreditCardNumber();
        //TriggerInterface_PCICreditCardNumber.Runnable  interfaceREF =  new TriggerInterface_PCICreditCardNumber.Runnable ();
        //interfaceREF.run(TriggerInterface_PCICreditCardNumber.Trig);
        
        //Call trigger app handler for insert event
        TriggerInterfaceHelper.runTrigger('PCIOwnership_Trig','PCI_Credit_Card_Numbers__c',1, 'bi', null,null,'All');
        //Call trigger app handler for insert event
        TriggerInterfaceHelper.runTrigger('PCICreditCardRelationship_Trig','opportunity',2, 'bi', null,null,'All');

        User testUser =insertUser();
        PCI_Scan_History__c pciHistory = new PCI_Scan_History__c
            (
                //Record_Last_Success__c
                //, 
                // Record_Last_Success_Id__c ='0016000000HdgkOAAR'
                Record_Object__c = 'Account'
                //, Scan_Begin__c
                , Scan_CCN_Found__c =58.0
                //, Scan_End__c
                //, Scan_Failure__c
                //, Scan_Failure_Message__c
                //, Scan_Finished__c
                //, Scan_Last__c
                , Scan_Records_Found__c =215560
                , Scan_Records_Processed__c =215560
                , Scan_Retried__c =0
                , Scan_Running__c = false
                , System_Scan_Id__c = 'X188'
                
            );
        insert pciHistory;
        
        System.assertEquals(pciHistory.Record_Object__c , 'Account', 'record object must be account');
        
        PCI_Credit_Card_Numbers__c pciCCN = new PCI_Credit_Card_Numbers__c
            (
                CCN_Last_4_Digits__c  = '0140'
                , CCN_Length__c =13
                , CCN_Type__c = 'Unknown'
                , CNN_Match_Length__c=true
                , CNN_Match_Luhn__c=true
                , Field_Name__c='Federal_Tax_ID__c'
                , Field_Value__c='#########0140'
                //, PCI_Scan_History__c
                , Record_Action__c = 'False Positive'
                //, Record_Created_Date__c = ''
                , Record_Group__c = null
                // Record_Id__c = '0016000000I739EAAR'
                //, Record_Last_Modified__c = 
                //, Record_Last_Modified_Date__c
                , Record_Owner__c = testUser.Id //'005600000011f8EAAQ'
                //, Record_ParentId__c
                // Record_RecordTypeId__c = '01260000000DS9CAAW'
                //, Record_RecordTypeName__c
                //, Record_URL__c
                //, System_Action_Description__c
                //, System_BU__c
                , System_CCN_Id__c = 'X2129'
                , System_Scan_Id__c = 'X188'
                //, System_Time_Stamp__c
                
            );
        insert pciCCN;
        
        PCI_Credit_Card_Numbers__c pciCCN1 = new PCI_Credit_Card_Numbers__c
            (
                CCN_Last_4_Digits__c  = '0140'
                , CCN_Length__c =13
                , CCN_Type__c = 'Unknown'
                , CNN_Match_Length__c=true
                , CNN_Match_Luhn__c=true
                , Field_Name__c='Federal_Tax_ID__c'
                , Field_Value__c='#########0140'
                //, PCI_Scan_History__c
                , Record_Action__c = 'Pending'
                //, Record_Created_Date__c = ''
                , Record_Group__c = null
                // Record_Id__c = '0016000000I739EAAR'
                //, Record_Last_Modified__c = 
                //, Record_Last_Modified_Date__c
                , Record_Owner__c = testUser.Id //'005600000011f8EAAQ'
                //, Record_ParentId__c
                // Record_RecordTypeId__c = '01260000000DS9CAAW'
                //, Record_RecordTypeName__c
                //, Record_URL__c
                //, System_Action_Description__c
                //, System_BU__c
                , System_CCN_Id__c = 'X2130'
                , System_Scan_Id__c = 'X188'
                //, System_Time_Stamp__c
                
            );
        
        insert pciCCN1;
        
        
        
        Account account = setupTestAccount('TEST_1_' + pciCCN1.Id);
        PCI_Credit_Card_Numbers__c pciCCNUpdate = [SELECT Id, Record_Action__c, Record_Id__c FROM PCI_Credit_Card_Numbers__c Where Id=: pciCCN1.Id];
        //PCIUpdateRemoveRecord trigger
        pciCCNUpdate.Record_Action__c = 'No Credit Card - Deleted Record';
        pciCCNUpdate.Object_Name__c = 'Account';
        Update pciCCNUpdate;
        //pciCCNUpdate.Object_Name__c = 'Account';
        pciCCNUpdate.Record_Id__c = account.Id;
        Database.SaveResult sr = Database.update(pciCCNUpdate,false);
        //for (Database.SaveResult sr : srList) 
        //{
        if (sr.isSuccess()) 
        {
            // Operation was successful, so get the ID of the record that was processed
            System.debug('Successfully inserted account. Account ID: ' + sr.getId());
        }
        else 
        {
            // Operation failed, so get all errors
            for(Database.Error err : sr.getErrors()) {
                System.debug('The following error has occurred.');
                System.debug(err.getStatusCode() + ': ' + err.getMessage());
                System.debug('fields that affected this error: ' + err.getFields());
            }
        }
        //} 
        
    }
    
    static testMethod void PCIOwnershipTrigger_Removed() 
    {
        User testUser =insertUser();
        //////// For Task and event object
        PCI_Credit_Card_Numbers__c pciCCNTask = new PCI_Credit_Card_Numbers__c
            (
                CCN_Last_4_Digits__c  = '0140'
                , Object_Name__c= 'Task'
                , CCN_Length__c =13
                , CCN_Type__c = 'Unknown'
                , CNN_Match_Length__c=true
                , CNN_Match_Luhn__c=true
                , Field_Name__c='Name'
                , Field_Value__c='#########0140'
                , Record_Action__c = 'Removed'
                , Record_Group__c = null
                // Record_Id__c = '0016000000I739EAAR'
                , Record_Owner__c = testUser.Id 
                , System_CCN_Id__c = 'X21301'
                , System_Scan_Id__c = 'X1881'
            );
        
        insert pciCCNTask;
        Account account = setupTestAccount('TEST_1_' + pciCCNTask.Id);
        Task testTask = new Task(Subject='Test PCI',OwnerId=testUser.Id,WhatId=account.Id,CurrencyIsoCode=UserInfo.getDefaultCurrency(),ActivityDate=system.today(),Priority='Normal',Status='Open');
        Insert testTask;
        System.assertEquals(testTask.Subject, 'Test PCI', 'Tasksubject must not be blank.');
        pciCCNTask.Record_Id__c =testTask.id;
        //    update pciCCNTask;
        
        // For Event
        Event testEvent = new Event(Subject='Test PCI',OwnerId=testUser.Id,WhatId=account.Id,CurrencyIsoCode=UserInfo.getDefaultCurrency(),ActivityDate=system.today(),DurationInMinutes=60,ActivityDateTime=system.now());
        Insert testEvent;
        pciCCNTask.Record_Id__c =testEvent.id;
        pciCCNTask.Object_Name__c='Event';
        //   update pciCCNTask;
        
    }
    
    static testMethod void PCIOwnershipTrigger_Owner() 
    {
        // line 188 & 189
        // Create Trigger test record 
        Trigger__c trig = new Trigger__c(Name = 'PCIUpdateRemoveRecord_Trig' , Trigger_Name_Unique__c='PCIUpdateRemoveRecord_Trig',Enabled__c=true,Object__c='PCI_Credit_Card_Numbers__c',Run_for_Recordypes__c='All',  Description__c='my test',Execution_Order__c=1,before_Insert__c=true , After_Update__c = true);
        Insert trig;
        Trigger_Recordtype__c rt = new Trigger_Recordtype__c(Enabled__c=true,Recordtype_Id__c=trig.Id,Trigger__c=trig.Id,Parameters__c='param=1;param=2');
        Insert rt;    
        //Call event edition trigger interface
        TriggerInterface_PCICreditCardNumber obj = new TriggerInterface_PCICreditCardNumber();
        
        //Call trigger app handler for insert event
        TriggerInterfaceHelper.runTrigger('PCIUpdateRemoveRecord_Trig','PCI_Credit_Card_Numbers__c',1, 'au', null,null,'All');
        PCI_Credit_Card_Numbers__c pciCCN = new PCI_Credit_Card_Numbers__c
            (
                CCN_Last_4_Digits__c  = '0140'
                , CCN_Length__c =13
                , CCN_Type__c = 'Unknown'
                , CNN_Match_Length__c=true
                , CNN_Match_Luhn__c=true
                , Field_Name__c='Federal_Tax_ID__c'
                , Field_Value__c='#########0140'
                //, PCI_Scan_History__c
                , Record_Action__c = 'False Positive'
                //, Record_Created_Date__c = ''
                , Record_Group__c = null
                // Record_Id__c = '0016000000I739EAAR'
                //, Record_Last_Modified__c = 
                //, Record_Last_Modified_Date__c
                //, Record_Owner__c = '005600000011f8EAAQ'
                //, Record_ParentId__c
                //, Record_RecordTypeId__c = '01260000000DS9CAAW'
                //, Record_RecordTypeName__c
                //, Record_URL__c
                //, System_Action_Description__c
                //, System_BU__c
                , System_CCN_Id__c = 'EmptyRecordtype'
                , System_Scan_Id__c = 'X188'
                //, System_Time_Stamp__c
                
            );
        insert pciCCN;
        
        //RecordType rt = new RecordType (Name = 'xxxx - test Account',SobjectType = 'Account' );
        //insert rt;
        //Line 200 201
        PCI_Credit_Card_Numbers__c pciCCN1 = new PCI_Credit_Card_Numbers__c
            (
                CCN_Last_4_Digits__c  = '0140'
                , CCN_Length__c =13
                , CCN_Type__c = 'Unknown'
                , CNN_Match_Length__c=true
                , CNN_Match_Luhn__c=true
                , Field_Name__c='Federal_Tax_ID__c'
                , Field_Value__c='#########0140'
                //, PCI_Scan_History__c
                , Record_Action__c = 'False Positive'
                //, Record_Created_Date__c = ''
                , Record_Group__c = null
                // Record_Id__c = '0016000000I739EAAR'
                //, Record_Last_Modified__c = 
                //, Record_Last_Modified_Date__c
                //, Record_Owner__c = '005600000011f8EAAQ'
                //, Record_ParentId__c
                //, Record_RecordTypeId__c = '01260000000DKFaAAO'
                //Record_RecordTypeId__c = '01260000000DK14'
                //, Record_RecordTypeName__c
                //, Record_URL__c
                //, System_Action_Description__c
                //, System_BU__c
                , System_CCN_Id__c = 'EmptyRecordtype1'
                , System_Scan_Id__c = 'X188'
                //, System_Time_Stamp__c
                
            );
        insert pciCCN1;
        
        PCI_Credit_Card_Numbers__c pciCCNOpp = new PCI_Credit_Card_Numbers__c
            (
                CCN_Last_4_Digits__c  = '0140'
                , CCN_Length__c =13
                , CCN_Type__c = 'Unknown'
                , CNN_Match_Length__c=true
                , CNN_Match_Luhn__c=true
                , Object_Name__c = 'OpportunityLineItem'
                ,Field_Name__c='Billing_Notes__C'
                , Field_Value__c='#########0140'
                //, PCI_Scan_History__c
                , Record_Action__c = 'Pending'
                //, Record_Created_Date__c = ''
                , Record_Group__c = null
                , Record_Id__c = CreateOpportunityLintItem()
                //, Record_Last_Modified__c = 
                //, Record_Last_Modified_Date__c
                //, Record_Owner__c = '005600000011f8EAAQ'
                //, Record_ParentId__c
                //, Record_RecordTypeId__c = '01260000000DKFaAAO'
                //Record_RecordTypeId__c = '01260000000DK14'
                //, Record_RecordTypeName__c
                //, Record_URL__c
                //, System_Action_Description__c
                //, System_BU__c
                , System_CCN_Id__c = 'OpportunityLineItem'
                , System_Scan_Id__c = 'X188'
                //, System_Time_Stamp__c
                
            );
        insert pciCCNOpp;
        
        PCI_Credit_Card_Numbers__c pciCCNCaseComment = new PCI_Credit_Card_Numbers__c
            (
                CCN_Last_4_Digits__c  = '0140'
                , CCN_Length__c =13
                , CCN_Type__c = 'Unknown'
                , CNN_Match_Length__c=true
                , CNN_Match_Luhn__c=true
                , Object_Name__c = 'CaseComment'
                ,Field_Name__c='CommentBody'
                , Field_Value__c='#########0140'
                //, PCI_Scan_History__c
                , Record_Action__c = 'Pending'
                //, Record_Created_Date__c = ''
                , Record_Group__c = null
                , Record_Id__c = CreateCaseComment()
                //, Record_Last_Modified__c = 
                //, Record_Last_Modified_Date__c
                //, Record_Owner__c = '005600000011f8EAAQ'
                //, Record_ParentId__c
                //, Record_RecordTypeId__c = '01260000000DKFaAAO'
                //Record_RecordTypeId__c = '01260000000DK14'
                //, Record_RecordTypeName__c
                //, Record_URL__c
                //, System_Action_Description__c
                //, System_BU__c
                , System_CCN_Id__c = 'CaseComment'
                , System_Scan_Id__c = 'X188'
                //, System_Time_Stamp__c
                
            );
        
        insert pciCCNCaseComment;
        
        //Test trigger PCIUpdateRemoveRecord
        OpportunityLineItem OppDelete = [Select Id From OpportunityLineItem Where Id =:pciCCNOpp.Record_Id__c];
        
        pciCCNOpp.Record_Action__c = 'Had Credit Card - Deleted Record';
        try
        {
            Update pciCCNOpp;
        }
        Catch (Exception e)
        { 
            System.assert(e.getMessage().contains('The record exists, Please select the appropriate value after you review'),e.getMessage());
        }
        
        Delete OppDelete;
        Update pciCCNOpp;//line 36
        
        
        pciCCNOpp.Record_Action__c = 'Removed';
        string error ='';
        try
        {
            Update pciCCNOpp;
        }
        Catch (Exception e)
        { 
            //       System.assert(e.getMessage().contains('System.QueryException: List has no rows for assignment to SObject'),e.getMessage());
            error = e.getMessage();
        }
    }
    
    static testMethod void PCIEmail() 
    {
        //INsert PCI data
        
        PCI_Credit_Card_Numbers__c pciCCNCaseComment = new PCI_Credit_Card_Numbers__c
            (
                CCN_Last_4_Digits__c  = '0140'
                , CCN_Length__c =13
                , CCN_Type__c = 'Unknown'
                , CNN_Match_Length__c=true
                , CNN_Match_Luhn__c=true
                , Object_Name__c = 'CaseComment'
                ,Field_Name__c='CommentBody'
                , Field_Value__c='#########0140'
                //, PCI_Scan_History__c
                , Record_Action__c = 'Pending'
                //, Record_Created_Date__c = ''
                , Record_Group__c = null
                , Record_Id__c = CreateCaseComment()
                //, Record_Last_Modified__c = 
                //, Record_Last_Modified_Date__c
                //, Record_Owner__c = '005600000011f8EAAQ'
                //, Record_ParentId__c
                //, Record_RecordTypeId__c = '01260000000DKFaAAO'
                //Record_RecordTypeId__c = '01260000000DK14'
                //, Record_RecordTypeName__c
                //, Record_URL__c
                //, System_Action_Description__c
                //, System_BU__c
                , System_CCN_Id__c = 'CaseComment'
                , System_Scan_Id__c = 'X188111'
                //, System_Time_Stamp__c
                
            );
        
        insert pciCCNCaseComment;
        System.assertEquals(pciCCNCaseComment.Field_Name__c , 'CommentBody' , 'PCI case comment field cannot be blank');
        
        //get Queue
        List<PCI_Business_Ownership__c> pciBusinessOwners = new List<PCI_Business_Ownership__c>();
        List<Group> pciGroups = [Select g.Id, g.Name from Group g where g.Name LIKE '%PCI CCN'];
        Map <String,String> mapQueue= new Map <String,String>();
        for (Group pciGroup : pciGroups)
        {
            String[] bu = pciGroup.Name.split('-', 2);
            //System.debug('######DEBUG: pciGroup'+ pciGroup.Name +':' + bu[0]);
            //System.debug('######DEBUG: MATCH Queue'+ pciGroup.Name +':' + mapBusinessOwners(bu[0]));
            
            PCI_Business_Ownership__c pciBusinessOwner = new PCI_Business_Ownership__c();
            pciBusinessOwner.Business_Queue__c= pciGroup.Name;
            pciBusinessOwner.Mapping__c = bu[0];
            pciBusinessOwner.PCI_Contact_Email__c = 'Test@Test.org';
            pciBusinessOwner.Name = bu[0];
            
            pciBusinessOwners.add(pciBusinessOwner);
            
            mapQueue.put(pciGroup.Id  , pciGroup.Name);
        }
        
        insert pciBusinessOwners;
        
        
        Test.startTest();
        // Schedule the test job
        PCIEmail_ScheduledEmailAlert m = new PCIEmail_ScheduledEmailAlert();
        String sch = '20 30 8 10 2 ?';
        System.schedule('PCIEmailScheduledEmailAlertTest',sch, m);
        
        
        Test.stopTest();    
        
    }
    
    private static String CreateCaseComment(){
        Case c = new Case();
        c.Description= 'PCI Test ';
        c.Subject = 'PCI Test ';
        
        insert c;
        CaseComment cc = new CaseComment(
            CommentBody = 'PCI Test '
            , ParentId = c.id
        );
        insert cc;
        
        return cc.id;
    }
    
    private static String CreateOpportunityLintItem()
    {
        //Pricebook2 s = [select id from Pricebook2 where IsStandard = true ];
        //System.debug('*****Pricebook2=' + s.Id);
        //Select p.Name, p.IsActive, p.Id, p.Description From Pricebook2 p
        
        //Pricebook2 s = new Pricebook2(Name = 'PCI', IsActive =true, Description='PCI', isStandard=true);  
        //insert s; 
        
        Product2 p1 = new Product2(
            name='PCI',
            //   ISBN__c='1234', //@@Avi commneted
            IsActive=true,
            Description='My Product',
            // RecordTypeId='01260000000DTeK', //@@Avi commneted
            ProductCode='12345'
            //  UK_Inventory_Status__c = 'Available',  //@@Avi commneted
            //  UK_Publication_Date__c = system.now().date().addDays(-1),   //@@Avi commneted
            //  US_Inventory_Status__c = 'Available',   //@@Avi commneted
            //  US_Publication_Date__c = system.now().date().addDays(-1)   //@@Avi commneted
        );
        insert p1;
        
        // create the pricebookentry
        PricebookEntry pbe1 = new PricebookEntry(
            CurrencyIsoCode = UserInfo.getDefaultCurrency(),//'EUR',
            Pricebook2Id=Test.getStandardPricebookId(),
            Product2Id=p1.id, 
            UnitPrice=0.00, 
            IsActive=true, 
            UseStandardPrice=false
        );
        
        insert pbe1;
        
        
        
        String locale = 'AMERICAS';
        
        Account account = setupTestAccount('TEST_PCI_' + locale);
        Id contactId = createAccountAndContact('TestPCI@test.com', locale);
        Opportunity opp = setupTestOpportunity('TEST_PCI' + locale, account.Id,contactId );
        
        OpportunityLineItem oppProduct = setupOppLineItemsRecepinet(opp.Id,contactId, pbe1.Id);
        
        return oppProduct.Id;
    }
    
    
    private static Opportunity setupTestOpportunity(String oppName, ID accountId,ID contactID) {
        
        Opportunity opp = new Opportunity(
            name=oppName,
            Type = 'New Business',
            stagename='Identified / Qualified - 0%',
            Probability=0,
            closedate=Date.newInstance(2011, 01, 01),
            CurrencyIsoCode = UserInfo.getDefaultCurrency(),
            accountId=accountId
        );
        insert opp;
        Insert new OpportunityContactRole(OpportunityId=opp.id,ContactId=contactID,IsPrimary=true,Role='Buyer');
        //opp.Probability=80;
        //opp.Primary_Contact_Assigned__c=true;
        update opp; // to fire the opportunity trigger that will overcome the validation for primary contact
        return opp;
    }     
    
    private static OpportunityLineItem setupOppLineItemsRecepinet(ID opportunityId, ID recipientId, ID pricebookId) { 
        OpportunityLineItem oli = new OpportunityLineItem();
        oli.OpportunityId = opportunityId;
        oli.Quantity = 1;
        //oli.Est_Training_Pop__c = 1; //@@Avi commented
        // oli.Unit_Material_Cost__c = 1;  //@@Avi commented
        // oli.Gross_Cost__c = 1; //@@Avi commented
        //  oli.Preparation_Cost__c = 1;  //@@Avi commented
        // oli.Instructor_Fee__c = 1;  //@@Avi commented
        oli.TotalPrice = 2;
        oli.PricebookEntryId = pricebookId;
        //  oli.Recipient__c = recipientId; //@@Avi commented
        //oli.CurrencyIsoCode = '';
        // insert the opportunity line item
        insert oli;
        return oli;   
    }
    
    public static String CreateAccountAndContact(String email, String Locale) {
        
        // Account a = new Account(name = 'New Account' + Locale, Locale__c = Locale); //@@Avi remove local field
        Account a = new Account(name = 'New Account' + Locale);
        insert a;
        
        Contact c = new Contact(
            FirstName = 'Test Contact' + Locale ,
            LastName = 'Test Last Name'+ Locale ,
            Salutation='Mr.',
            Email = Locale + email,
            AccountId = a.Id        
        );
        insert c;
        return c.Id;    
        
    }
    
    private static Account setupTestAccount(String accountName) 
    {
        Account a = new Account(name=accountName,
                                //OwnerId=userId,
                                BillingStreet='1234 Main Street');  
        insert a;
        return a;
    } 
    
    public static User insertUser(){
        
        Organization o = [SELECT Country,Id,InstanceName,IsSandbox,Name,State FROM Organization limit 1]; 
        User u = new User(alias='test', email='test@example.com', firstname='Testing',
                          emailencodingkey='UTF-8', lastname='Testing', languagelocalekey=Userinfo.getLanguage(), 
                          localesidkey=Userinfo.getLocale(), country=o.Country,
                          username='test@example.com.informaplc' + system.now().second() + system.now().millisecond() + math.random(),
                          timezonesidkey=Userinfo.getTimeZone().getID(),
                          profileid=system.UserInfo.getProfileId(), //System Administrator
                          
                          Active_Directory_Username__c='testinguser1' + system.now().second() + system.now().millisecond(),
                          Active_Directory_OU__c='ukcorplan');
        insert u;    
        return u;
    }
    
    public static PCI_Scanner__c CreatePCISetting(){
        
        user u =insertUser();
        PCI_Scanner__c pcSetting = new PCI_Scanner__c(Name='PCI Defaults',Default_Ownership_Name__c='Test Default',Default_User_Queue__c=u.Id,
                                                      Error_Emails__c='do_not_reply.sfdc@informausa.com');
        Insert pcSetting;
        return pcSetting;                                    
    }
    
    public static void CreateApplicationBypass()
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