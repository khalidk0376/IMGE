/**
 * Test class for the invoice run trigger.
 * @Author      : Abdul Kadir
 * @Date        : 29/Apr/2018
 * Apex Class : calculatePercentageAmount
 * * Modified By : Rajesh kumar Yadav Bk-3751,[Modified By : Aishwarya 12 Aug 2020 BK-3751]
 */
@IsTest
private class calculatePercentageAmount_test{
    @isTest static void Test_checkRecursive() 
    {
    Decimal Amount = 12.67; 
    String sPaymentSch ='50-50'; 
    String per  = '1';
    calculatePercentageAmount oclperamt = new calculatePercentageAmount();
    // pass values resource for this method in class
    oclperamt.getTax(Amount,sPaymentSch,per);
    //create account
    Account oAccount = new Account(Name='Expocad Account', CurrencyIsoCode = 'USD');
    insert oAccount;
    system.assertEquals(oAccount.Name, 'Expocad Account', 'Both values should be the same.');
    
    //create contact 
    Contact oCon = new Contact(LastName='ContTest1', Email='test1contact@duptest.com', AccountId = oAccount.Id, MailingStreet = 'Test',MailingCity ='Test',MailingState='Bihar',MailingCountry='India');
    insert oCon;
    system.assertNotEquals(oCon.Id, null, 'Id cannot be null');
    //create brand
    Brand__c oBrand = new Brand__c(Name='Arab Health', SSC_Email_Distribution_ID__c = 'test@test.tst');
    insert oBrand;
    //create Event series.
    Event_Series__c oEventseries = new Event_Series__c(Name = 'Arab Health', Company_Country__c = 'INDIA' , CurrencyISOCode = 'USD', Package_Identifier__c = 'ARBHL', Brand__c=oBrand.id , Event_Edition_Pool__c = 'ARBHL');
    insert oEventseries; 
    //Create Event edition
    Event_Edition__c edi = new Event_Edition__c ();
    edi.name = 'Arab Health Exhibition and Congress 2020';
    edi.Approval_Service_Now_ID__c = '123';
    edi.Alternate_Currency__c = 'AED';
    edi.CurrencyIsoCode='USD';
    edi.Tab1__c='Test';
    edi.Tab7__c = 'test1';
    edi.Part_of_Series__c = oEventseries.id;
    edi.Event_Edition_Status__c = 'Completed';
    edi.Payment_Schedule__c = '50-50';
    edi.Cutoff_Date_1__c = Date.Today();
    insert edi;
    system.assertEquals(edi.Alternate_Currency__c, 'AED', 'Both values should be the same.');
    //create Opportunity 
    Opportunity oOpportunity = new Opportunity(Name = 'Test Opportunity', CloseDate = Date.today(), StageName = 'Proposal', EventEdition__c = edi.Id, Event_Series__c = oEventseries.Id, AccountId = oAccount.Id, Billing_Contact__c = oCon.Id, status__c = 'Needs Assessment' , Opportunity_Contact__c = oCon.Id);
    insert oOpportunity;
    system.assertEquals(oOpportunity.StageName, 'Proposal', 'Both values should be the same.');
    // Quote Create 
    SBQQ__Quote__c oQuote = new SBQQ__Quote__c(CurrencyIsoCode = 'USD', SBQQ__Status__c = 'Quote Sent', SBQQ__Type__c = 'Quote', SBQQ__Opportunity2__c = oOpportunity.Id, SBQQ__Account__c = oOpportunity.AccountId, SBQQ__Primary__c = true);
    insert oQuote;
    system.assertEquals(oQuote.SBQQ__Status__c, 'Quote Sent', 'Both values should be the same.');
    /*select id,Name,ISO_Code_Logo__c,CurrencyIsoCode,Product_Attachments__c,SBQQ__PrimaryContact__c,Primary_Contact_Info__c,documentType__c,Next_Version__c,conga_quote_template_id__c,term_conditionIds__c,conga_contract_template_id__c,Quote_Event_Edition__c,Is_a_Local_Company__c , Payment_Schedule_amount__c, Payment_Schedule_percent1__c, Payment_Schedule_percent__c ,Cutoff_Date__c , Cutoff_Date_1__c , Cutoff_Date_2__c , Cutoff_Date_3__c , SBQQ__NetAmount__c ,ISO_Code__c ,Payment_Schedule_amount1__c , SBQQ__Opportunity2__c , EE_Payment_Schedule__c ,SBQQ__Opportunity2__r.EventEdition__c, Payment_Schedule_Revised__c,InvoicetoStartDate__c,Invoice_to_Start_Date_Cut_Off_Date1__c,Invoice_to_Start_Date_Cut_Off_Date2__c,Invoice_to_Start_Date_Cut_Off_Date3__c, Invoice_to_be_issued_before_in_Days__c,SBQQ__Opportunity2__r.stageName,SBQQ__Status__c, SBQQ__Opportunity2__r.Is_Barter_Opportunity__c,SBQQ__Opportunity2__r.Custom_Payment__c,invoice_payment1__c,invoice_payment2__c,invoice_payment3__c,invoice_payment4__c,invoice_payment5__c,invoice_payment6__c,invoice_payment7__c,invoice_payment8__c,invoice_payment9__c,invoice_payment10__c,invoice_payment11__c,invoice_payment12__c, ES_Company_Country__c from SBQQ__Quote__c where id =:quoteId limit 1 */
    String QuoteId = oQuote.id;
    oclperamt.cutoffDates(oQuote.Id);
    }
}