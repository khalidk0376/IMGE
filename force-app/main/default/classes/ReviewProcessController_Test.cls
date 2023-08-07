/**
 * Created/Modified By: Girikon(Archit)
 * Created On:          9/9/2017
 * Description/Purpose: This test class covers the apex class : ReviewProcessController
 * Methods:             ReviewProcess_test
 * Apex Class:          ReviewProcessController
**/

@isTest(seeAlldata = false)
public class ReviewProcessController_Test {
    static testMethod void ReviewProcess_test(){
        User u = new User(
        ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id,
        LastName = 'last',
        Email = 'puser_rpc@test.com',
        Username = 'puser_rpc@test.com' + System.currentTimeMillis(),
        CompanyName = 'TEST',
        Title = 'title',
        Alias = 'alias',
        TimeZoneSidKey = 'America/Los_Angeles',
        EmailEncodingKey = 'UTF-8',
        LanguageLocaleKey = 'en_US',
        LocaleSidKey = 'en_US'
        );
        
        System.runAs(u)
        {            
            Account acc = new Account();
            acc.name = 'test acc';
            insert acc;
            
            Contact con = new Contact();
            con.lastname = 'test con123445';
            con.MailingCountry = 'USA';
            con.MailingState = 'Texas';
            con.Contact_type__c = 'Invoice Contact';
            con.AccountId = acc.id;
            con.MobilePhone = '2121212145';
            insert con;
            
            Event_Edition__c oEventEdition = new Event_Edition__c(name = 'World Of Concrete',Event_Code__c='woc17', Tab1__c='test',Tab7__c='testtt',Approval_Service_Now_ID__c = 'test');
            insert oEventEdition;
            System.assertEquals('World Of Concrete', oEventEdition.name, 'Here value is not same');



            
            Product2 prd1 = new Product2(Name = 'Linear Booth',Family = 'Booth',Product_Brand__c=oEventEdition.name,To_Be_Dispalyed_On_OBC__c = true,Expired__c='No', Number_of_Corners__c = 0, Event_Edition_Pool__c = 'WOC');
            insert prd1;

            
            Pricebook2 customPB = new Pricebook2(Name='ICRE', isActive=true);
            insert customPB;
            
            Pricebook2 stdPB = new Pricebook2(Name='ICRE2', isActive=true);
            insert stdPB;
            
            Id pricebookId = Test.getStandardPricebookId();
            
            PricebookEntry StndrdPrice = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prd1.Id,UnitPrice = 100, IsActive = true);
            insert StndrdPrice;
            
            ICRE__c objicre = new ICRE__c();
            objicre.PBName__c = stdpb.id;
            objicre.PBName__c = stdpb.id;
            objicre.Product__c = prd1.id;
            objicre.active__c = true;
            insert objicre;
            
            Event_Series__c oEventseries = new Event_Series__c(Name = 'World Of Concrete', CurrencyISOCode = 'USD', Package_Identifier__c = 'WOC');
            insert oEventseries;

            Opportunity oOpportunity = new Opportunity(Name = 'Expocad Opportunity', CloseDate = Date.today(),StageName = 'Proposal', EventEdition__c = oEventEdition.Id, Event_Series__c = oEventseries.Id, AccountId = acc.Id, Billing_Contact__c = Con.Id);
            //insert oOpportunity;
            
            /*SBQQ__Quote__c oQuote = new SBQQ__Quote__c(CurrencyIsoCode = 'USD', SBQQ__Status__c = 'Quote Sent', SBQQ__Type__c = 'Quote', SBQQ__Opportunity2__c = oOpportunity.id, SBQQ__Account__c = acc.Id);
            insert oQuote;
            
            SBQQ__QuoteLine__c oQuoteLine = new SBQQ__QuoteLine__c(SBQQ__Quote__c = oQuote.Id, SBQQ__Product__c = prd1.Id, SBQQ__ListPrice__c=10.10, SBQQ__Quantity__c = 2, SBQQ__Number__c = 1, Line_Description__c = 'Test', Booth_Number__c = 'TESTBN3', Booth__c = True);
            insert oQuoteLine ;*/
            
            Integration_Service__c oCyberSourceCredential = new Integration_Service__c();
            oCyberSourceCredential.Name= 'Cybersource';
            oCyberSourceCredential.User_Name__c = 'girikon'; 
            oCyberSourceCredential.Password__c = 'o5gXfifvSKndciK';
            oCyberSourceCredential.End_Point_Url__c = 'https://paymentservicestest.informa.com';
            Insert oCyberSourceCredential;
            
            //Test.setMock(HttpCalloutMock.class, new ReviewProcessMock());
            Customer_Center_Cart_Master__c custCentCartMaster = new Customer_Center_Cart_Master__c(IsProcessed__c=false,Payment_Type__c='Credit Card',Event_Edition__c =oEventEdition.id);
            insert custCentCartMaster;
            
             Product2 prd = new Product2(Name = 'Booth Package WOC',Family = 'Booth',Number_of_Corners__c = 0,Booth_Type__c='esc', Booth_Class__c='fsdf', Event_Edition_Pool__c = 'WOC', Product_Brand__c = 'World of Concrete 2017');
            insert prd;
            Customer_Center_Cart__c CCCart = new Customer_Center_Cart__c();
            CCCart.Customer_Center_Cart_Master__c = custCentCartMaster.Id;
            CCCart.Event_Edition__c = oEventEdition.id;
            CCCart.Contact__c = con.id;
            CCCart.Product__c = prd.id;
            CCCart.Tax_Rate__c = 30;
            CCCart.Rate__c = 100;
            CCCart.Price__c = 200;
            CCCart.Quantity__c = 1000;
            insert CCCart;
            
            Customer_Transaction_Detail__c  custTranDetail = new Customer_Transaction_Detail__c(Contact__c = con.id,User__c =u.id,Total_Amount__c=100.00,Customer_Center_Cart_Master__c=custCentCartMaster.id,CS_Payment_Token_ID__c='5053803328296785004107');   
            insert custTranDetail  ; 
            
            ApexPages.currentPage().getParameters().put('eventId',oEventEdition.id);
            ApexPages.currentPage().getParameters().put('transId',custTranDetail.id);
            ReviewProcessController reviewProces = new ReviewProcessController();
            reviewProces.opp=oOpportunity;
            reviewProces.updateTransaction(custCentCartMaster.id,oOpportunity.id);
            reviewProces.save();
        }
    }
}