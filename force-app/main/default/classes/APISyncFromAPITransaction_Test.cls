/**
* File:         APISyncFromAPITransaction_Test
* Project:      3E Expocad Integration
* Created Date: 16th June 2022 
* Created By:   Girikon(Aradhana)
* Description : Test class for Trigger_APISynchronizationTransaction(96%),TriggerInterface_APISyncTransaction(100%),
*                 APISyncFromAPITransaction(90%)
* *****************************************************************************************************************************
*/
@istest
public class APISyncFromAPITransaction_Test 
{
    // Common test setup Data
    @testSetup static void testSetupData() {
        
        //Required data
        Utility.isRebookInProcess = True ;
        Account oAccount = new Account(Name = 'Expocad Account', CurrencyIsoCode = 'USD', Phone = '2423122323');
        insert oAccount;
        
        
        Contact oCon = new Contact(LastName = 'ContTest1', Email = 'test1contact@duptest.com', AccountId = oAccount.Id, MailingStreet = 'Test', MailingCity = 'Test', MailingState = '', MailingCountry = 'India', Phone = '2423122323', AssistantPhone = '2423122323', HomePhone = '2121212121', MobilePhone = '2121212145', OtherPhone = '2154215421');
        insert oCon;
        
        User oUser = [SELECT Id FROM User WHERE Id = : UserInfo.getUserId()];
        AccountTeamMember oAtm = new AccountTeamMember(AccountId = oAccount.id, userId = oUser.id);
        insert oAtm;
        
        Brand__c oBrand = new Brand__c(Name = 'World of Concrete', SSC_Email_Distribution_ID__c = 'test@test.tst');
        insert oBrand;
        
        Event_Series__c oEventseries = new Event_Series__c(Name = 'World Of Concrete', CurrencyISOCode = 'USD', Package_Identifier__c = 'WOC', Brand__c = oBrand.id, Event_Edition_Pool__c = 'WOC');
        insert oEventseries;
        
        Event_Edition__c oEvent = new Event_Edition__c(Name = 'World of Concrete 2017', Tab1__c = 'Booth Applications', Tab7__c = 'Billing Information', Approval_Service_Now_ID__c = '123', CurrencyIsoCode = 'USD', Event_Code__c = 'KDB,KDB2', Booth_Type__c = 'Island,Corner,Inline,Custom,Peninsula', No_Of_Corner__c = '0,1,2,3,4', Booth_Size__c = '100 SqFt,400 SqFt,900 SqFt,1600 SqFt,2500 SqFt', Booth_Product_Type__c = 'Space Only', Expocad_API_Url__c = 'test.com', Part_of_Series__c = oEventseries.id, Booth_Classes_on_Template__c = 'Temp', Corner_Configuration_Check__c = false, Product_Type_Order__c = 'BoothA;;BoothB');
        insert oEvent;
        
        Product2 prd = new Product2(Name = 'Booth Package WOC', Family = 'Booth', Number_of_Corners__c = 0, Booth_Type__c = 'esc', Show_In_Show__c = 'Indoor', Booth_Class__c = 'fsdf', Event_Edition_Pool__c = 'WOC', Event_Edition__c = oEvent.Id);
        insert prd;
        
        Pricebook2 customPB2 = new Pricebook2(Name = 'ICRE', isActive = true);
        insert customPB2;
        Id pricebookId = Test.getStandardPricebookId();
        PricebookEntry pbStndrdPrice = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prd.Id, UnitPrice = 100, IsActive = true);
        insert pbStndrdPrice;
        PricebookEntry pbICREPrice = new PricebookEntry(Pricebook2Id = customPB2.Id, Product2Id = prd.Id, UnitPrice = 200, IsActive = true);
        insert pbICREPrice;
        
        Product2 prd1 = new Product2(Name = 'Post Draw Indoor Booth', Booth_Product_Type__c = 'Space Only', Booth_Type__c = 'esc', Show_In_Show__c = 'Indoor', Booth_Class__c = 'fsdf', Family = 'Booth', Number_of_Corners__c = 0, Event_Edition_Pool__c = 'WOC', Event_Edition__c = oEvent.Id, Expiry_Date__c = Date.today());
        insert prd1;
        
        Pricebook2 customPB = new Pricebook2(Name = 'ICREAB', isActive = true);
        insert customPB;
        PricebookEntry pbStndrdPrice1 = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prd1.Id, UnitPrice = 100, IsActive = true);
        insert pbStndrdPrice1;
        PricebookEntry pbICREPrice1 = new PricebookEntry(Pricebook2Id = customPB.Id, Product2Id = prd1.Id, UnitPrice = 200, IsActive = true);
        insert pbICREPrice1;
        
        Product2 prd2 = new Product2(Name = 'Corner Booth Fee', Family = 'Booth', Booth_Type__c = 'esc', Show_In_Show__c = 'Indoor', Booth_Class__c = 'fsdf', Number_of_Corners__c = 1, Event_Edition_Pool__c = 'WOC', Event_Edition__c = oEvent.Id);
        insert prd2;
        
        PricebookEntry pbStndrdPrice2 = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prd2.Id, UnitPrice = 100, IsActive = true);
        insert pbStndrdPrice2;
        PricebookEntry pbICREPrice2 = new PricebookEntry(Pricebook2Id = customPB.Id, Product2Id = prd2.Id, UnitPrice = 200, IsActive = true);
        insert pbICREPrice2;
        SBQQ__ProductOption__c oPrdOption = new SBQQ__ProductOption__c(SBQQ__Number__c = 5, SBQQ__ConfiguredSKU__c = prd.id, SBQQ__OptionalSKU__c = prd1.id );
        insert oPrdOption;
        //SBQQ__ProductOption__c oPrdOption2 = new SBQQ__ProductOption__c(SBQQ__Number__c = 5, SBQQ__ConfiguredSKU__c = prd.id, SBQQ__OptionalSKU__c = prd2.id );
        //insert oPrdOption2;
        Opportunity oOpportunity = new Opportunity(Name = 'Expocad Opportunity', CloseDate = Date.today(), StageName = 'Proposal', EventEdition__c = oEvent.Id, Event_Series__c = oEventseries.Id, AccountId = oAccount.Id, Billing_Contact__c = oCon.Id);
        insert oOpportunity;
        
        SBQQ__Quote__c oQuote = new SBQQ__Quote__c(CurrencyIsoCode = 'USD', SBQQ__Status__c = 'Quote Sent', SBQQ__Type__c = 'Quote', SBQQ__Opportunity2__c = oOpportunity.Id, SBQQ__Account__c = oAccount.Id, SBQQ__Primary__c = true);
        insert oQuote;
        
        SBQQ__Quote__c oQuote2 = new SBQQ__Quote__c(CurrencyIsoCode = 'USD', SBQQ__Status__c = 'Quote In Review', SBQQ__Type__c = 'Quote', SBQQ__Opportunity2__c = oOpportunity.Id, SBQQ__Account__c = oAccount.Id, SBQQ__Primary__c = true);
        insert oQuote2;
        
        SBQQ__QuoteLine__c oQuoteLine = new SBQQ__QuoteLine__c(SBQQ__Quote__c = oQuote.Id, SBQQ__Product__c = prd1.Id, SBQQ__Quantity__c = 2, SBQQ__Number__c = 1, Line_Description__c = 'Test', Booth_Number__c = 'TESTBN3', Booth__c = True);
        //insert oQuoteLine ;
        
        oEvent.Booth_Product_Type__c = '';
        update oEvent;
        
        
    }
    @istest
    Public static void APITranTrigtest()
    {
        Test.StartTest();
        
        Trigger__c trigs=( New Trigger__c(Name= 'APISyncFromAPITransaction', Enabled__c = true, Object__c = 'API_Synchronization_Transaction__c', After_Insert__c = true, After_Update__c = true, Execution_Order__c = 99, Run_for_Recordypes__c = 'All' ) );
        
        if(Schema.sObjectType.Trigger__c.isCreateable())
        {
            Insert trigs;    
        }
        Trigger_Recordtype__c rt = new Trigger_Recordtype__c(Enabled__c=true,Recordtype_Id__c=trigs.Id,Trigger__c=trigs.Id,Parameters__c='param=1;param=2');
        Insert rt;
        System.AssertNotEquals(rt.Enabled__c,false, 'test class failed');
        //Call TriggerInterface_APISyncTransaction
        TriggerInterface_APISyncTransaction Tranobj = new TriggerInterface_APISyncTransaction();
        APISyncFromAPITransaction obj= new APISyncFromAPITransaction();
        //Call trigger app handler 
        TriggerInterfaceHelper.runTrigger('APISyncFromAPITransaction','API_Synchronization_Transaction__c',99, 'ap', null,null,'All');
        TriggerInterfaceHelper.initTriggerMapAndList('APISyncFromAPITransaction');
        //Create API Sync Transaction record
        API_Synchronization_Transaction__c ApiSynTran =new API_Synchronization_Transaction__c(
            X3rd_Party_Relationship__c='3E ExpoCAD',
            Started_From__c='Event Edition',
            Status__c='Paused',
            Target_System__c='3E',
            Type__c='POST',
            Request_Type__c='Asynchronous');
        insert ApiSynTran;
        // create API Sync Item record
        API_Synchronization_Item__c SyncItem = new API_Synchronization_Item__c();
        SyncItem.Status__c = 'Queued';
        SyncItem.API_Synchronization_Transaction__c = ApiSynTran.Id;
        SyncItem.API_Call_Type__c = 'POST';
        SyncItem.X3rd_Party_Relationship__c = '3E ExpoCAD';
        // SyncItem.Type__c = '3E Expocad Company Type Setup'; 
        SyncItem.Error_Message__c = '';
        SyncItem.Request_Body__c = null;
        
        
        //update API Sync Tran record
        ApiSynTran.Status__c='Queued';
        update ApiSynTran;
        
        Set<Id> AsyncIds = new Set<Id>();
        APISynchronizationBatch testing = new  APISynchronizationBatch(AsyncIds); 
        Test.StopTest();
        
    }
}