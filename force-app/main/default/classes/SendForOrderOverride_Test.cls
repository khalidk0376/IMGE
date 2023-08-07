/**
* File         :   SendForOrderOverride_Test 
* Project      :   GE CRM-IOM
* Created Date :   24th Nov 2022
* Created By   :   Girikon(Ashish)
* Test Class   :   SendForOrderOverride_Test(91%)
* ***************************************************************************
@description : Covrage to Class SendForOrderOverride
*****************************************************************************
* Modification log : 
* 1. Modofied to cover method createCustomBillingScheduleNodes : SendForOrderOverride_Test(98%)
*/
@isTest
private with sharing class SendForOrderOverride_Test {
    private static final String IOM_JSON = '{"Translations":[{"TranslatedBillingCity":"سانتا في","TranslatedContactTitle":"","TranslatedBillingPostalCode":"سبعة وثمانون ألف وخمسة مائة وواح","TranslatedContactLastName":"","TranslatedBillingState":"المكسيك جديدة","TranslatedContactFirstName":"","TranslatedAccountName":"بروه","TranslatedBillingAddressLine1":"121 شارع ساندوفال","TranslatedBillingAddressLine2":"","TranslatedBillingCountry":"الولايات المتحدة الأمريكية","TranslatedContactEmailAddress":""}],"OpportunityLineItem":[{"ProductCode":"GE-P-00011","CRMOLINumber":"0LI-00367","LineDescription":"Space Only","ProductName":"Space Only","StartDate":"2023-06-02 00:00:00","EndDate":"2023-09-02 00:00:00","Quantity":"120.00","ListPrice":"610.00","OpportunityProductName":"Prohaska Industries D-24-01 Space Only","AlternateLanguageLineDesc":"مساحة فقط","TotalPrice":"73200.00","Product2Id":"01t220000049dQRAAY"},{"ProductCode":"GE-P-00009","CRMOLINumber":"0LI-00368","LineDescription":"Compulsory Administration Fee","ProductName":"Compulsory Administration Fee","StartDate":"2023-06-02 00:00:00","EndDate":"2023-09-02 00:00:00","Quantity":"1.00","ListPrice":"250.00","OpportunityProductName":"Prohaska Industries D-24-01 Compulsory Administration Fee","AlternateLanguageLineDesc":"","TotalPrice":"250.00","Product2Id":"01t220000049dQPAAY"},{"ProductCode":"GE-P-00065","CRMOLINumber":"0LI-00369","LineDescription":"Corner Booth Fee","ProductName":"Corner Booth Fee","StartDate":"2023-06-02 00:00:00","EndDate":"2023-09-02 00:00:00","Quantity":"4.00","ListPrice":"0.00","OpportunityProductName":"Prohaska Industries D-24-01 Corner Booth Fee","AlternateLanguageLineDesc":"","TotalPrice":"0.00","Product2Id":"01t220000049dRJAAY"},{"ProductCode":"GE-P-00128","CRMOLINumber":"0LI-00366","LineDescription":"Booth Package LEAP","ProductName":"Booth Package LEAP","StartDate":"2023-06-02 00:00:00","EndDate":"2023-09-02 00:00:00","Quantity":"1.00","ListPrice":"0.00","OpportunityProductName":"Prohaska Industries D-24-01 Booth Package LEAP","AlternateLanguageLineDesc":"","TotalPrice":"0.00","Product2Id":"01t220000049dSKAAY"}],"BillingContact_AccountId":"0012200000gaXPCAA2","BillingContact_SourceContactNumber":"","BillingContact_AccountShippingCity":"","BillingContact_ContactSalutation":"Mr.","BillingContact_AccountBillingPostalCode":"87501","BillingAccount_BillingState":"NM","BillingAccount_SourceAccountNumber":"","OpportunityCurrency":"USD","BillingContact_AccountShippingState":"","BillingContact_ContactEmail":"sneh.prohaska@gmail.com","BillingAccount_Name":"Prohaska Industries","ShippingAccount_BillingCity":"Santa Fe","IOMAccountNumber":"IM-01215","AccountBillingPostalCode":"87501","BillingAccount_ShippingStreet":"","IOMSynchronizationRequestName":"IOMST-000107","ShippingAccount_ShippingCountry":"","BillingAccount_BillingCountry":"US","ShippingAccount_RecordType":"Account Credit Status Unhold","AccountShippingState":"","ShippingAccount_BillingStreet":"121 Sandoval Street","ShippingAccount_Id":"0012200000gaXPCAA2","AccountBillingCity":"Santa Fe","ShippingAccount_ShippingState":"","VATRegistrationNumber":"","BillingContact_ContactMailingCountry":"US","BillingContact_ContactId":"0032200000Rs9UnAAJ","OpportunityName":"Prohaska Industries D-24-01","AccountName":"Prohaska Industries","OrderNumber":"","BillingContact_ContactFirstName":"Sneh","BillingContact_AccountBillingState":"NM","BillingContact_ContactMailingStreet":"121 Sandoval Street","IsBarterOpportunity":"false","IOMOpportunityId":"","BillingAccount_ShippingPostalCode":"","BillingAccount_ShippingCity":"","OpportunityProbability":"100","BillToAccount_VATRegistrationNumber":"","BillingContact_AccountBillingCity":"Santa Fe","BillingContact_IOMAccountNumber":"IM-01215","ShippingAccount_BillingCountry":"US","PaymentSchedule":"","OpportunityId":"00622000008YWRwAAO","OpportunityStageName":"Closed Won","ShippingAccount_Name":"Prohaska Industries","AccountBillingCountry":"US","SourceAccountNumber":"","BillingContact_AccountShippingPostalCode":"","BillingContact_AccountBillingStreet":"121 Sandoval Street","BillingAccount_BillingStreet":"121 Sandoval Street","AccountShippingCountry":"","SourceName":"GE","AccountRecordType":"Account Credit Status Unhold","BillingContact_ContactMailingPostalCode":"87501","BillingAccount_ShippingCountry":"","ShippingAccount_IOMAccountNumber":"IM-01215","ShippingAccount_ShippingCity":"","CustomPaymentScheduleInfo":"","BillingContact_ContactMailingState":"NM","BillingAccount_RecordType":"Account Credit Status Unhold","ShippingAccount_ShippingPostalCode":"","SalesRepName":"Nikhil Kumar","BillingAccount_BillingCity":"Santa Fe","ShippingAccount_ShippingStreet":"","ShipToAccount_VATRegistrationNumber":"","CampaignName":"","BillingContact_AccountShippingStreet":"","AccountId":"0012200000gaXPCAA2","BillingContact_AccountShippingCountry":"","BillingContact_AccountName":"Prohaska Industries","BillingContact_AccountBillingCountry":"USA","ShippingAccount_BillingState":"NM","BillingContact_IsPrimary":"true","BillingContact_ContactTitle":"","OpportunityCloseDate":"2022-11-24 00:00:00","BillingContact_SourceAccountNumber":"","BillingContact_RecordType":"GE","OpportunityAmount":"73450.00","BillingContact_ContactMailingCity":"Santa Fe","BillingAccount_IOMAccountNumber":"IM-01215","BillingAccount_Id":"0012200000gaXPCAA2","ShippingAccount_SourceAccountNumber":"","OpportunityEditionCode":"EME23LEP","BillingContact_ContactIdentifier":"IOM Contact","PONumber":"","BillingAccount_ShippingState":"","BillingContact_ContactLastName":"Prohaska","BillingAccount_BillingPostalCode":"87501","ShippingAccount_BillingPostalCode":"87501","AccountShippingCity":"","AccountShippingStreet":"","AccountBillingStreet":"121 Sandoval Street","AccountBillingState":"NM","Sales Rep":"kumar.nikhil@informa.com","AccountShippingPostalCode":"","IsCustomPayment":"false","BillingContact_ContactMobilePhone":"(505) 983-5155","BillingContact_IOMContactNumber":"","OpportunityContactRole":[]}';
   // Common test setup Data
   @testSetup static void testSetupData() 
   {
        Utility.isRebookInProcess = True ;
        Account oAccount = new Account(Name = 'Expocad Account', CurrencyIsoCode = 'USD', Phone = '2423122323');
        insert oAccount;

        Contact oCon = new Contact(LastName = 'ContTest1', Email = 'test1contact@duptest.com', AccountId = oAccount.Id, MailingStreet = 'Test', MailingCity = 'Test', MailingState = 'Karnataka', MailingCountry = 'India', Phone = '2423122323', AssistantPhone = '2423122323', HomePhone = '2121212121', MobilePhone = '2121212145', OtherPhone = '2154215421');
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
        SBQQ__ProductOption__c oPrdOption2 = new SBQQ__ProductOption__c(SBQQ__Number__c = 5, SBQQ__ConfiguredSKU__c = prd.id, SBQQ__OptionalSKU__c = prd2.id );
        insert oPrdOption2;
        Opportunity oOpportunity = new Opportunity(Name = 'Expocad Opportunity', CloseDate = Date.today(), StageName = 'Proposal', EventEdition__c = oEvent.Id, Event_Series__c = oEventseries.Id, AccountId = oAccount.Id, Billing_Contact__c = oCon.Id);
        oOpportunity.Milestone_1_Percent__c = 50;
        oOpportunity.Milestone_2_Percent__c = 50;
        oOpportunity.Milestone_1_Delivery_Date__c = Date.today().addMonths(6);
        oOpportunity.Milestone_1_Delivery_Date__c = Date.today().addMonths(12);
       	oOpportunity.IOM_Custom_Billing_Info__c = '[{"Date":"2023-01-19","Percent":"50.00","Amount":"0.00","PaymentNumber":1},{"Date":"2023-02-18","Percent":"50.00","Amount":"0.00","PaymentNumber":2}]';
       	insert oOpportunity;
		
       OpportunityLineItem oPplineitem = new OpportunityLineItem (Quantity = 2, OpportunityId = oOpportunity.Id, UnitPrice = 0.01, PriceBookEntryId = pbStndrdPrice2.Id,
                ServiceEndDate__c = date.today(), Run_Date__c = date.today());
        insert oPplineitem;
       
        SBQQ__Quote__c oQuote = new SBQQ__Quote__c(CurrencyIsoCode = 'USD', SBQQ__Status__c = 'Quote Sent', SBQQ__Type__c = 'Quote', SBQQ__Opportunity2__c = oOpportunity.Id, SBQQ__Account__c = oAccount.Id, SBQQ__Primary__c = true);
        //insert oQuote;

        SBQQ__Quote__c oQuote2 = new SBQQ__Quote__c(CurrencyIsoCode = 'USD', SBQQ__Status__c = 'Quote In Review', SBQQ__Type__c = 'Quote', SBQQ__Opportunity2__c = oOpportunity.Id, SBQQ__Account__c = oAccount.Id, SBQQ__Primary__c = true);
        //insert oQuote2;

        SBQQ__QuoteLine__c oQuoteLine = new SBQQ__QuoteLine__c(SBQQ__Quote__c = oQuote.Id, SBQQ__Product__c = prd1.Id, SBQQ__Quantity__c = 2, SBQQ__Number__c = 1, Line_Description__c = 'Test', Booth_Number__c = 'TESTBN3', Booth__c = True);
        //insert oQuoteLine ;

        oEvent.Booth_Product_Type__c = '';
        update oEvent;
    }
    @isTest static void testSendForOrderOverride() 
    {
        Map<string,object> payloadMap = (Map<String, Object>)JSON.deserializeUntyped(IOM_JSON);
        List<Map<String, Object>> childData = new List<Map<String, Object>>();
        for (Object instance : (List<Object>)payloadMap.get('OpportunityLineItem')){
         	childData.add((Map<String, Object>)instance);     
        }
        payloadMap.put('OpportunityLineItem',childData);
        Map<string,string> payloadObjectNodeGroupMap = new Map<string,string> ();
        Opportunity opp = [Select Id from opportunity limit 1];
        
        SendForOrderOverride obj = new SendForOrderOverride();
        obj.overridePayloadJSON(opp.Id, payloadMap);
        obj.overrideGroupNodeLabel(payloadObjectNodeGroupMap);
        
        System.assertEquals('Translations', payloadObjectNodeGroupMap.get('Account_Translated_FieldSet__c-Account__c-AccountId'),'label not updated for IOM');
    }
}