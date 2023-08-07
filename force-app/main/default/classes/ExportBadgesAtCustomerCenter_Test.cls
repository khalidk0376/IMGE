/**
 * Created/Modified By: Girikon(Aishwarya)
 * Created On:          12/12/2018
 * Modified On:         
 * Description/Purpose: This test class covers the apex class : ExportBadgesAtCustomerCenter
 * Apex Class:          ExportBadgesAtCustomerCenter
**/
@isTest
public class ExportBadgesAtCustomerCenter_Test{
    
     public static testMethod void exportBadgesDataInsert()
     {
         Event_Series__c oEventseries = new Event_Series__c(Name = 'World Of Concrete', CurrencyISOCode = 'USD', Package_Identifier__c = 'WOC', Event_Edition_Pool__c = 'WOC');
         insert oEventseries;
         Event_Edition__c oEvent = new Event_Edition__c(Name = 'World of Concrete 2017', Tab7__c = 'Test',Tab1__c = 'Test', Approval_Service_Now_ID__c = '123', CurrencyIsoCode = 'USD', Event_Code__c = 'KDB,KDB2', Booth_Type__c = 'Island,Corner,Inline,Custom,Peninsula', No_Of_Corner__c = '0,1,2,3,4', Booth_Size__c = '100 SqFt,400 SqFt,900 SqFt,1600 SqFt,2500 SqFt', Booth_Product_Type__c = 'Barter Shell Scheme', Start_Date__c = Date.today(),Part_of_Series__c = oEventseries.id);
         insert oEvent;
         System.assertEquals(oEvent.Event_Code__c,'KDB,KDB2', 'Event Code');
         
         Test.startTest();
             
             Account oAccount = new Account(Name = 'Expocad Account', CurrencyIsoCode = 'USD');
             insert oAccount;
             System.AssertNotEquals(oAccount , null , 'Test class failed');
             Contact oCon = new Contact(LastName = 'ContTest1', Email = 'test1contact@duptest.com', AccountId = oAccount.Id, MailingStreet = 'Test', MailingCity = 'Test', MailingState='',MailingCountry='India');
             insert oCon;
             ApexPages.currentPage().getParameters().put('Id',oEvent.Id);
             ApexPages.currentPage().getParameters().put('accId',oAccount.Id);
             
             /*SBQQ__Quote__c oQuote = new SBQQ__Quote__c();
             oQuote.CurrencyIsoCode = 'USD';
             oQuote.SBQQ__Status__c = 'Quote Sent';
             oQuote.SBQQ__Type__c = 'Quote';
             oQuote.SBQQ__Account__c = acc.Id;
             oQuote.SBQQ__Primary__c = true;
             insert oQuote;*/
             
             
             
             ExportBadgesAtCustomerCenter ex1 = new ExportBadgesAtCustomerCenter();
             ex1.getthousandBlocks();
             Opportunity oOpportunity = new Opportunity(Name = 'Expocad Opportunity', CloseDate = Date.today(), StageName = 'Proposal', EventEdition__c = oEvent.Id, Event_Series__c = oEventseries.Id, AccountId = oAccount.Id, Billing_Contact__c = oCon.Id,Exhibitor_Paid_By__c = 'Exhibitor Paid by Exhibitor');
             insert oOpportunity;
             SBQQ__Quote__c oQuote = new SBQQ__Quote__c(CurrencyIsoCode = 'USD', SBQQ__Status__c = 'Quote Sent', SBQQ__Type__c = 'Quote', SBQQ__Opportunity2__c = oOpportunity.Id, SBQQ__Account__c = oAccount.Id, SBQQ__Primary__c = true);
             insert oQuote;
             ExpocadBooth__c oExpBooth = new ExpocadBooth__c();
             oExpBooth.Booth_Number__c='17';
             oExpBooth.Area__c='1100';
             oExpBooth.Unit_Type__c='SqFt';
             oExpBooth.Status__c ='Rented';
             oExpBooth.Quote__c = oQuote.Id;
             insert oExpBooth;
             System.assertEquals(oExpBooth.Unit_Type__c,'SqFt', 'Unit type');
             Opportunity_ExpoCAD_Booth_Mapping__c oEM = new Opportunity_ExpoCAD_Booth_Mapping__c(Opportunity__c = oOpportunity.Id, Quote__c=oQuote.Id,Expocad_Booth__c=oExpBooth.ID);
             insert oEM;
             Exhibitor_Badge__c badge1 = new Exhibitor_Badge__c();
             badge1.Name = 'Test';
             badge1.Event_Edition__c=oEvent.id;
             badge1.ExpocadBooth__c=oExpBooth.id;
             badge1.Account__c = oAccount.id;
             badge1.Opp_Booth_Mapping__c =oEM.id; 
             insert badge1;
             ExportBadgesAtCustomerCenter ex = new ExportBadgesAtCustomerCenter();
             
             ApexPages.currentPage().getParameters().put('Id',oEvent.Id);
             ApexPages.currentPage().getParameters().put('accId',oAccount.Id);
             ApexPages.currentPage().getParameters().put('exBoothId',badge1.ExpocadBooth__c);
             ex.getthousandBlocks();
         Test.stopTest();

     }
}