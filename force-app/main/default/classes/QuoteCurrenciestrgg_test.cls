/**
 * File:        QuoteCurrenciestrgg.apxt
 * Project:     GAP
 * Date:        3/1/2017 6:24 AM
 * Created By: Rajesh Kumar
  * Code Coverage:   85%
 * *************************************************************************
 * Description: Fetch Currency type in currency type object and calculate conversion rate as per alternate currency.
 * *************************************************************************
 * History:
 * * Modified By : Rajesh kumar Yadav Bk-3751,[Modified By : Aishwarya 12 Aug 2020 BK-3751]
 */


@isTest
public class QuoteCurrenciestrgg_test {
static testMethod void Test_QuoteCurrenciestrgg()
    {
        
            Pricebook2 pb=new Pricebook2(Name='TestPricebook');
            insert pb;
            
            Product2 prd1 = new Product2(Name = 'Linear Booth',Family = 'Booth', Number_of_Corners__c = 0);
            insert prd1;
            system.assertEquals(prd1.Name, 'Linear Booth', 'Both values should be the same.');
            
            APXTConga4__Conga_Template__c congaTemp = new APXTConga4__Conga_Template__c();
            congaTemp.APXTConga4__Name__c = 'Test Template';
            congaTemp.APXTConga4__Template_Type__c = 'Document';
            congaTemp.APXTConga4__Template_Group__c = 'Term&Condition';
            insert congaTemp;

            Account oacc = new Account(Name = 'Testrajesh'); 
            insert oacc;
            system.debug('testclassafter insert');
            Account oacc1 = new Account(Name = 'Testrajeshpartner'); 
            insert oacc1;
            system.debug('testclassafter insert');
            
            Event_Series__c es = new Event_Series__c();
            es.Name='testt';
            es.Package_Identifier__c='test';
            es.Event_Edition_Pool__c = 'WOC';
            insert es;
            system.assertEquals(es.Package_Identifier__c, 'test', 'Both values should be the same.');
            
            Event_Edition__c ee = new Event_Edition__c();
            ee.Name='test';
            ee.Part_of_Series__c=es.Id;
            ee.Tab1__c='ttttt';
            ee.Tab7__c='yyyyyy';
            ee.Event_Price_Book__c=pb.Id;
            ee.Payment_Schedule__c = '50-50';
            ee.Year__c='2020';
            ee.CutoffDate_1__c = date.today();
            ee.CutoffDate_2__c = date.today();
            ee.CutoffDate_3__c = date.today();
            
            ee.Cutoff_Date_1__c = date.today();
            ee.Cutoff_Date_3__c = date.today();
            ee.Cutoff_Date_2__c = date.today();
            ee.Quote_Template__c = congaTemp.id;
            ee.Contract_Template__c= congaTemp.id;
            ee.Terms_Condition_Template__c=congaTemp.id;
            ee.Alternative_Terms_Condition_Template__c=congaTemp.id;   
            insert ee;
            system.assertEquals(ee.Payment_Schedule__c, '50-50', 'Both values should be the same.');
            
            EventCurrecies__c EC = new EventCurrecies__c();
            EC.name = 'USD';
            insert EC;
            
            Contact ocontact = new Contact(LastNAme = 'test', Email = 'anbcd@gmail.com',AccountId=oacc.Id);
            insert ocontact; 
            system.assertEquals(ocontact.LastName, 'test', 'Both values should be the same.');
            
            Opportunity opp = new opportunity(name = 'test', closeDate = Date.Today(), Billing_Contact__c  =ocontact.id,  EventEdition__c=ee.Id, StageName = 'Closed Won', AccountId = oacc.id, Opportunity_Contact__c = ocontact.id,Status__c = 'Online Booth Form In Review' , Partner_Account__c = oacc1.id);
            insert opp;
            
            Opportunity opp1 = new opportunity(name = 'test1', closeDate = Date.Today(), Billing_Contact__c  =ocontact.id,  EventEdition__c=ee.Id, StageName = 'Closed Won', AccountId = oacc.id, Opportunity_Contact__c = ocontact.id,Status__c = 'Online Booth Form In Review' , Partner_Account__c = oacc1.id, Exhibitor_Paid_By__c = 'Delegate Sales');
            insert opp1;
        
            test.startTest();
            SBQQ__Quote__c oQuote = new SBQQ__Quote__c(SBQQ__Status__c = 'Draft',EventCurrency__c =ec.id,SBQQ__Primary__c = false, SBQQ__Type__c = 'Quote', SBQQ__Opportunity2__c = opp.id,SBQQ__PrimaryContact__c =ocontact.Id , Alternate_Currency2__c = 'BRL' , SBQQ__Partner__c =oacc1.id );
            insert oQuote;
            
            SBQQ__Quote__c oQuote1 = new SBQQ__Quote__c(SBQQ__Status__c = 'Draft',EventCurrency__c =ec.id,SBQQ__Primary__c = false, SBQQ__Type__c = 'Quote', SBQQ__Opportunity2__c = opp1.id,SBQQ__PrimaryContact__c =ocontact.Id , Alternate_Currency2__c = 'BRL' , SBQQ__Partner__c =oacc1.id );
            insert oQuote1;
        
            Utility.quoteTriggerMargeisFirstTimeBefore = false;
            system.assertEquals(oQuote.SBQQ__Status__c, 'Draft', 'Both values should be the same.');
            SBQQ__QuoteLine__c oQuoteLine = new SBQQ__QuoteLine__c(SBQQ__Quote__c = oQuote.Id, SBQQ__Product__c = prd1.Id, SBQQ__Quantity__c = 2, SBQQ__Number__c = 1, Line_Description__c = 'Test', Booth_Number__c = 'TESTBN3', Booth__c = True);
            insert oQuoteLine;
            system.assertEquals(oQuoteLine.SBQQ__Product__c, prd1.Id, 'Both values should be the same.'); 
            oQuote.Alternate_Currency2__c = 'AED';
            update oQuote;
            oQuote1.Alternate_Currency2__c = 'AED';
            update oQuote1;
            
            test.StopTest();         
    } 
}