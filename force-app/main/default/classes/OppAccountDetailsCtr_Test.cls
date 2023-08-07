/**
    * Created/Modified By: Girikon(Archit)
    * Created On:          9/8/2017
    * Modified By:    Girikon(Amish) - CCEN 274
    * Modified On:    08/29/2018
    * Description/Purpose: This test class covers the apex class : OppAccountDetailsCtr
    * Methods:             oppAccountDetails_DataInsert, oppAccountDetails_DataInsert, oppAccountDetails_DataInsertwithBranding, oppAccountDetails_DataInsertwithoutBranding
    * Apex Class:          OppAccountDetailsCtr
**/

@isTest
public class OppAccountDetailsCtr_Test {
    public static testMethod void oppAccountDetailsDataInsertWithAgreement()
    {
        Utility.isRebookInProcess = True ;
        // Setup test data
        // This code runs as the system user
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User u = new User(Alias = 'standt', Email='standarduser11@testorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing11', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='standarduserFirst1@testorg.com');
        Event_Edition__c eventEdition;
        Account acc1;
        blng__Invoice__c invoiceObj;
        ExpocadBooth__c oExpocadBooth;
        Contract oContract;
        Event_Settings__c oSetting;
        
        System.runAs(u) 
        {
            // The following code runs as user 'u' 
            
            System.debug('Current User: ' + UserInfo.getUserName());
            System.debug('Current Profile: ' + UserInfo.getProfileId());
            
            acc1 = new Account();
            acc1.Name='acc1';              
            insert acc1;
            
            Contact con = new Contact(LastName='User',FirstName ='Test',AccountId=acc1.id);
            insert con;
            
            eventEdition = new Event_Edition__c(Event_Currency__c='USD',Name='World of Concrete 2017',Event_Code__c='WOC17',End_Date__c=System.Today(),Start_Date__c=System.Today(),Payment_Schedule__c='10-40-50',X50_Cutoff_Date__c=Date.today(),Cutoff_Date_1__c=Date.today(),Cutoff_Date_2__c=Date.today(),CutoffDate_3__c=Date.today());
            insert eventEdition;
            System.assertEquals(eventEdition.Event_Code__c,'WOC17', 'Event Code');
            EventCurrecies__c eventCurrency = new EventCurrecies__c (Name='USD',Event_Edition__c=eventEdition.id);
            insert eventCurrency;
            System.assertEquals(eventCurrency.Name,'USD', 'Event Currency');
            eventEdition.EventCurrency__c = eventCurrency.id;
            update eventEdition;
            System.assert(eventEdition.EventCurrency__c != null, 'Event Currency');
            Id pricebookId = Test.getStandardPricebookId();
            opportunity opp = new opportunity(Name='World of Concrete 2017',EventEdition__c=eventEdition.id,AccountId = acc1.id,Paid_Amount__c=10.00,Amount=20.00,CloseDate=System.Today(),StageName='Needs Assessment',CurrencyIsoCode=eventEdition.EventCurrency__r.Name);
            insert opp;
            System.assert(opp != null, 'opportunity');
            SBQQ__Quote__c oQuote = new SBQQ__Quote__c(SBQQ__Status__c ='Draft',SBQQ__Primary__c =true, CurrencyIsoCode=eventCurrency.name,SBQQ__Type__c='Quote',SBQQ__StartDate__c=System.Today(),SBQQ__Opportunity2__c=opp.id);
            insert oQuote;
            System.assert(oQuote != null, 'SBQQ__Quote');
            System.assert(oQuote.SBQQ__Opportunity2__c == opp.id, 'SBQQ__Quote oppId');
            oExpocadBooth = new ExpocadBooth__c(Booth_Number__c='Test booth 1',Area__c='201',Unit_Type__c='Test Unit',quote__c=oQuote.id,Status__c='Rented');
            insert oExpocadBooth;
            Booth_Size_Badge_Limit__c boothSizeBadgeLimit = new Booth_Size_Badge_Limit__c(Badges_Allowed__c=1.0,Booth_Size_From__c=201.0, Booth_Size_To__c=201.0,Event_Edition__c=eventEdition.id);
            insert boothSizeBadgeLimit;
            Order o = new Order(name='Test1',AccountId=acc1.id,EffectiveDate=system.today(),status='draft', OpportunityId = opp.id);
            insert o;
            //SELECT blng__InvoiceDate__c,Schedule_Number__c,  Name, Id, blng__Order__c, blng__TotalAmount__c, blng__TaxStatus__c, blng__InvoiceStatus__c,blng__TaxAmount__c,blng__Order__r.OpportunityId FROM blng__Invoice__c
            invoiceObj = new blng__Invoice__c(blng__Order__c =o.id,blng__InvoiceDate__c=Date.today(),blng__Account__c=acc1.id);
            insert invoiceObj;
            oContract = new Contract(SBQQ__Opportunity__c=opp.id,AccountId=acc1.id);
            insert oContract;
            
            oSetting = new Event_Settings__c();
            oSetting.Branding_Color__c='Red';
            oSetting.Event_Edition__c=eventEdition.id;
            //oSetting.Event_Edition__r.Event_Code__c=eventEdition.Event_Code__c;
            insert oSetting;
            
            opp.StageName='Closed Won';
            update opp;
            
            System.assert(opp.StageName =='Closed Won', 'StageName is Clsoed Won');
            
            
            Agreement__c agrmnt = new Agreement__c();
            agrmnt.Name='Agreement 1';
            agrmnt.Opportunity__c=Opp.id;
            insert agrmnt;
            
        }
        Test.startTest();
        ApexPages.currentPage().getParameters().put('accountId',acc1.id);
        ApexPages.currentPage().getParameters().put('eventId',eventEdition.id);
        ApexPages.currentPage().getParameters().put('serverURL','test congahhhh');
        OppAccountDetailsCtr oppAccount = new OppAccountDetailsCtr();
        oppAccount.getBoothItems();
        oppAccount.getInvoiceDetails();
        oppAccount.getSortDirection();
        oppAccount.ViewData();
        oppAccount.isShowOneInvoiceDetail();
        oppAccount.sInvoiceId=invoiceObj.id;
        oppAccount.getInvoiceAndProductDetail();
        oppAccount.Beginning();
        oppAccount.Previous();
        oppAccount.Next();
        oppAccount.getPageNumber();
        oppAccount.End();
        oppAccount.getDisableNext();
        oppAccount.getDisablePrevious();
        oppAccount.getTotal_size();
        oppAccount.getTotalPages();
        OppAccountDetailsCtr.convertDate(Date.Today(),false);
        OppAccountDetailsCtr.convertDate(Date.Today(),true);
        oppAccount.BoothItemId = oExpocadBooth.id;
        oppAccount.detailBadges();
        oppAccount.detailBadgesAddButton();
        oppAccount.getOppProducts();
        OppAccountDetailsCtr.getOppAccountDetailsInvoice();
        oppAccount.getInvoiceRecordDetails();
        oppAccount.getInvoiceRecordDetailsForPastInv();
        oppAccount.downloadInvoicePDF();
        
        
        oppAccount.getContractRecord();
        oppAccount.sSelectedContractId=oContract.id;
        oppAccount.getContractDetail();
        oppAccount.isShowOneContactDetail();
        oppAccount.getPaymentRecord();
        
        oppAccount.getPaymentDetail();
        oppAccount.isShowOnePaymentDetailForInvoice();
        oppAccount.isShowOnePaymentDetail();
        oppAccount.sSelectedPaymentId=invoiceObj.id;
        oppAccount.getPaymentDetailForInvoice();
        oppAccount.processPayment();
        
        oppAccount.sInvoiceId =invoiceObj.id;
        oppAccount.isShowOneInvoiceDetailForPayment();
        oppAccount.multipleInvoicePayment();
        OppAccountDetailsCtr.changeDateFormat(Date.Today());
        oppAccount.setSortDirection('ASC');
        oppAccount.getOppBoothDetails();
        oppAccount.getBoothItems2();
        
        Test.stopTest();
    }
}