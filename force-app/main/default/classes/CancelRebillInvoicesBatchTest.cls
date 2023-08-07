/**
 * Created by stevelohrenz on 7/21/17.
 */

@IsTest
private class CancelRebillInvoicesBatchTest {

    @testSetup
    public static void setupData() {
        TestUtilities.createCSIntegrationSettings();
        TestUtilities.createCSBatchSettings();
    }

    @IsTest
    static void testExecuteMethod() {
        Map<String, SObject> sbObjectMap = TestUtilities.createToInvoiceStack(false);
        blng__Invoice__c anInvoice = (blng__Invoice__c) sbObjectMap.get(TestUtilities.INVOICE);

        CancelRebillInvoicesBatchDataMockImpl mockImpl = new CancelRebillInvoicesBatchDataMockImpl();
        CancelRebillInvoicesBatch batchJob2 = new CancelRebillInvoicesBatch(True,'USD');
        CancelRebillInvoicesBatch batchJob = new CancelRebillInvoicesBatch(false, 0, 'USD', mockImpl);
        //Database.BatchableContext batchableContext = new Database.BatchableContext();
        batchJob.execute(null, new List<blng__Invoice__c> {anInvoice});
        
        Batch_Settings__c btch = new Batch_Settings__c();
        btch.name='CancelRebillInvoicesBatch';
        btch.No_of_Days_to_add_in_TargetDate__c=700;
        insert btch;
        
        Test.startTest();
        Utility.isRebookInProcess = True ;
        
        Pricebook2 pb = new Pricebook2();
        pb.Name = 'TestPricebook';
        insert pb;
        System.assertEquals(pb.Name, 'TestPricebook', 'pricebook name equals to TestPricebook');
        
        Account acct = new Account();
        acct.Name = 'testAccount'; 
        acct.CurrencyIsoCode = 'EUR';
        insert acct;
        System.assertEquals(acct.Name, 'testAccount', 'Account name equals to testAccount');
        
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
        ee.Year__c = '2020';
        insert ee;
        System.assertEquals(ee.Name, 'TestEvent', 'Event Edition name equals to TestEvent');
        
        Opportunity oppty1 = new Opportunity(Name = 'testOpp', EventEdition__c = ee.Id);
        oppty1.AccountId = acct.Id;
        oppty1.StageName ='Discover';
        oppty1.CloseDate = date.today();
        
      //  oppty1.IsCreatedByReviewProcess__c=false;
      //  oppty1.Manual_Contract__c = true;
        insert oppty1;
        System.assertEquals(oppty1.AccountId, acct.Id, 'Account id must be equals');
        
        Contract contracts=new Contract();
        contracts.StartDate = Date.today();
        contracts.AccountId = acct.Id;
        contracts.Status = 'Draft';
        contracts.StartDate = Date.today();
        Insert contracts;
        
        order ord = new order( Status='draft');
        ord.EffectiveDate  = Date.today();
        ord.AccountId = acct.Id;
        ord.OpportunityId = oppty1.Id;
        ord.BillToContactId = oppty1.Billing_Contact__c;
        ord.ContractId = contracts.Id;
        Insert ord; 
        System.assertEquals(ord.AccountId, acct.Id, 'Order Account id must be equals');
         
        blng__Invoice__c invoice = TestUtilities.createInvoice(acct, ord, true, 'AAADEDEDDE');
        blng__Invoice__c oInvoice = [SELECT Id, Cancel_and_Rebill__c,  blng__InvoiceStatus__c FROM blng__Invoice__c LIMIT 1];
        
        System.debug('oInvoice' + oInvoice);
        blng__Invoice__c inv = new blng__Invoice__c();
        inv.blng__Account__c=acct.id;
        inv.Cancel_and_Rebill__c = false;
        inv.blng__InvoiceStatus__c = 'Posted';
        inv.Invoice_Heirarchy__c='Child Invoice';
        inv.blng__InvoiceStatus__c='Draft';
        inv.blng__InvoiceDate__c  =System.today();
        inv.Schedule_Number__c =2;
        inv.Invoice_lines_updated__c=false;
        insert inv;
        System.assertEquals(inv.blng__Account__c, acct.Id, 'Invoice Account id must be equals'); 
        
        CancelRebillInvoicesBatch.CancelRebillInvoicesBatchDataDefaultImpl objIntnce = new CancelRebillInvoicesBatch.CancelRebillInvoicesBatchDataDefaultImpl();
        //objIntnce.performaCreditInvoice(inv);
        
        batchJob.finish(null);
        batchJob.rescheduleThis();
        System.assertEquals(1, mockImpl.performedCancelRebill.size() , 'Mock record is essential');
    }

    @IsTest
    static void testCancelRebillInvoicesBatchScheduableEUR() {
        Test.startTest();
        String jobId = System.schedule('testContractBatchableScheduableEUR', '0 0 0 3 9 ? 2022', new CancelRebillInvoicesScheduableEUR());
        System.assertNotEquals(null, jobId , 'Job id cannot be null');
        Test.stopTest();
    }

    @IsTest
    static void testCancelRebillInvoicesBatchScheduableGBP() {
        Test.startTest();
        String jobId = System.schedule('testContractBatchableScheduableGBP', '0 0 0 3 9 ? 2022', new CancelRebillInvoicesScheduableGBP());
        System.assertNotEquals(null, jobId , 'Job id cannot be null');
        Test.stopTest();
    }

    @IsTest
    static void testCancelRebillInvoicesBatchScheduableUSD() {
        Test.startTest();
        String jobId = System.schedule('testContractBatchableScheduableUSD', '0 0 0 3 9 ? 2022', new CancelRebillInvoicesScheduableUSD());
        System.assertNotEquals(null, jobId , 'Job id cannot be null');
        Test.stopTest();
    }

    @IsTest
    static void testCancelRebillInvoicesBatchScheduableBRL() {
        Test.startTest();
        String jobId = System.schedule('testContractBatchableScheduableBRL', '0 0 0 3 9 ? 2022', new CancelRebillInvoicesScheduableBRL());
        System.assertNotEquals(null, jobId , 'Job id cannot be null');
        Test.stopTest();
    }

    @IsTest
    static void testCancelRebillInvoicesBatchScheduableAED() {
        Test.startTest();
        String jobId = System.schedule('testContractBatchableScheduableAED', '0 0 0 3 9 ? 2022', new CancelRebillInvoicesScheduableAED());
        System.assertNotEquals(null, jobId , 'Job id cannot be null');
        Test.stopTest();
    }

    public class CancelRebillInvoicesBatchDataMockImpl implements CancelRebillInvoicesBatch.CancelRebillInvoicesBatchDataInterface {

        public List<blng__Invoice__c> performedCancelRebill = new List<blng__Invoice__c>();
        blng__InvoiceScheduler__c insertedInvoiceScheduler;

        public void performaCreditInvoice(blng__Invoice__c anInvoice) {
            performedCancelRebill.add(anInvoice);
        }

        public void insertInvoiceScheduler(blng__InvoiceScheduler__c anInvoiceScheduler) {
            insertedInvoiceScheduler = anInvoiceScheduler;
        }
    }
}