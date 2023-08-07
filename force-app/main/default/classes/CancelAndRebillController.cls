public with sharing class CancelAndRebillController {
   public string orderId {get; set;}
   /*
   public CancelAndRebillController() { 
        //BK-3753 - EmptyStatementBlock Violation Reported so I am commented this block as of now.
   }*/
   
   public CancelAndRebillController (ApexPages.StandardController stController) {
     orderId = ApexPAges.currentPage().getParameters().get('oId');
   }
   
   public PageReference CRebill() {
      
      PageReference pg;
      CancelRebillInvoicesBatch batchJobEUR = new CancelRebillInvoicesBatch(false, 'EUR');
      Id batchJobIdEUR = Database.executeBatch(batchJobEUR, CancelRebillInvoicesBatch.BATCH_SIZE);
      //CancelRebillInvoicesBatch batchJobUSD = new CancelRebillInvoicesBatch(false, 'USD');
      //Id batchJobIdUSD = Database.executeBatch(batchJobUSD, CancelRebillInvoicesBatch.BATCH_SIZE);
      // return new PageReference('/' + orderId);
      return redirectToRecord(orderId);
   }
   public PageReference redirectOrder() {
      return redirectToRecord(orderId);
   }
   public pageReference redirectToRecord(String sRecordId){
        PageReference pageRef = new PageReference('/'+sRecordId);
        return pageRef;
    }
}