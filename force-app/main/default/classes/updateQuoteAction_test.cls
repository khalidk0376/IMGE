/**
 * File:            updateQuoteAction_test.cls
 * Project:         GAP
 * Date:            2/20/2017 5:52 AM
 * Created By: Abdul Kadir
 * *************************************************************************
 * Description: updateQuoteAction class
 * Code Coverage :100%
 * *************************************************************************
 * History:
 * * Modified By : Rajesh kumar Yadav Bk-3751,[Modified By : Aishwarya 12 Aug 2020 BK-3751]
 */

@isTest
public class updateQuoteAction_test{
    
    static testmethod void unittest1(){
     
         Pricebook2 pb=new Pricebook2(Name='TestPricebook');
         insert pb;
         System.assertEquals(pb.Name, 'TestPricebook', 'Both values should be the same.');
         
         Event_Edition__c ee = new Event_Edition__c();
         ee.Name='TestEvent';
         ee.Tab1__c='tab1';
         ee.Tab4__c='tab4';
         ee.Tab7__c='tab7';
         ee.Tab8__c='Tab8__c';
                   
         ee.Event_Price_Book__c=pb.Id;
         insert ee;
         System.assertEquals(ee.Name, 'TestEvent', 'Both values should be the same.');
         
         APXTConga4__Conga_Template__c ct=new APXTConga4__Conga_Template__c(APXTConga4__Name__c='test');
         insert ct;
         
         National_Contract_Template__c nct=new National_Contract_Template__c();
         nct.Event_Edition__c=ee.Id;
         nct.Conga_Template__c=ct.Id;
         nct.Term_Conditions__c=ct.Id;
         insert nct;
         System.assertEquals(nct.Event_Edition__c, ee.Id, 'Event edition must be the same.');
         
         Account acct=new Account(Name='testAccount',CurrencyIsoCode='EUR');
         insert acct;
         System.assertEquals(acct.Name, 'testAccount', 'Both values should be the same.');
         
         Opportunity oppty=new Opportunity(Name='testOpp',EventEdition__c=ee.Id);
         oppty.AccountId=acct.Id;
         oppty.StageName='Closed Won';
         oppty.CloseDate=date.today();
         oppty.Not_a_Brazilian_Company__c = true;
         insert oppty;
         System.assertEquals(oppty.StageName, 'Closed Won', 'Stage is closed won');
         
         SBQQ__Quote__c qtObj=new SBQQ__Quote__c();
         qtObj.SBQQ__Account__c=acct.Id;
         qtObj.SBQQ__Status__c='Draft';
         qtObj.SBQQ__Type__c='Quote';
         qtObj.SBQQ__StartDate__c=date.today();
         qtObj.Alternate_Currency2__c='EUR';
         qtObj.SBQQ__Opportunity2__c=oppty.Id;
         qtObj.SBQQ__Primary__c=false;
         insert qtObj;
         System.assertEquals(qtObj.SBQQ__Status__c, 'Draft', 'Status should be Draft.');
          
        SBQQ__Quote__c qtObj2=new SBQQ__Quote__c();
         qtObj2.SBQQ__Account__c=acct.Id;
         qtObj2.SBQQ__Status__c='Draft';
         qtObj2.SBQQ__Type__c='Quote';
         qtObj2.SBQQ__StartDate__c=date.today();
         qtObj2.Alternate_Currency2__c='EUR';
         qtObj2.SBQQ__Opportunity2__c=oppty.Id;
         qtObj2.SBQQ__Primary__c=true;
         insert qtObj2;
         system.assertEquals(qtObj2.SBQQ__Status__c, 'Draft', 'Both values should be the same.');
         set<ID> ids=new set<ID>();
         ids.add(oppty.Id);
        
         updateQuoteAction.updateQuoteAttachAggrement(oppty.Id);
         UpdateQuoteDocReleaseBooth objclass = new UpdateQuoteDocReleaseBooth (ids);//updateQuote(ids);
         }
}