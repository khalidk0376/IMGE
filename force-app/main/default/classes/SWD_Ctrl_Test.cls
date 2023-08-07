/**
* File:        
* Project:    
* Date :      
* Created By:  
* *************************************************************************
* Description: Discription - 
*
* *************************************************************************
* History:
* Modified By : Rajesh kumar Yadav Bk-3751, [Modified By : Aishwarya 12 Aug 2020 BK-3751]
*/
@isTest(seeAlldata = false)
public class SWD_Ctrl_Test {
  static testMethod void unitTest() {
    Account oacc = new Account (Name = 'Testrajesh' );
    insert oacc ;
    system.assertEquals(oacc.Name, 'Testrajesh', 'Both values should be the same.');
    Account oparacc = new Account (Name = 'Partner Account');
    insert oparacc ;
    Contact ocontact = new Contact(LastNAme = 'test' ,Email = 'anbcd@gmail.com' ,Accountid =oacc.id );
    insert ocontact;
    system.assertEquals(ocontact.LastName, 'test', 'Both values should be the same.');
    Contact ocontact1 = new Contact(LastNAme = 'test billing' ,Email = 'anbcd@gmail.com' ,Accountid =oacc.id );
    insert ocontact1;
    Partner oPartner = new Partner(Role = 'Agency', AccountToId = oparacc.id, AccountFromId = oacc.id);
    insert oPartner;
    Opportunity opp = new opportunity (name = 'test' , closeDate = Date.Today(), StageName= 'Qalification' , AccountId = oacc.id ,Opportunity_Contact__c = ocontact.id , Billing_Contact__c = ocontact1.id);
    insert opp;
    system.assertEquals(opp.Name, 'test', 'Both values should be the same.');
    SBQQ__Quote__c oQuote = new SBQQ__Quote__c(SBQQ__Status__c = 'Quote',SBQQ__Type__c = 'Quote', SBQQ__Opportunity2__c = opp.id);
    insert oQuote;
    system.assertEquals(oQuote.SBQQ__Status__c, 'Quote', 'Both values should be the same.');
    SBQQ__QuoteDocument__c oQuoteDocument = new SBQQ__QuoteDocument__c ( Name = 'Rajesh' ,Sign_Status__c ='Completed',SBQQ__Quote__c =oQuote.id );
    insert oQuoteDocument;
    system.assertEquals(oQuoteDocument.Sign_Status__c, 'Completed', 'Both values should be the same.');
    PageReference pageRef = Page.SendDocusign;
    pageRef.getParameters().put('id',oQuoteDocument.id);
    Test.setCurrentPage(pageRef);
    ApexPages.StandardController sc = new ApexPages.StandardController(oQuoteDocument);
    SWD_Ctrl oSWD_Ctrl = new SWD_Ctrl(sc);
    oSWD_Ctrl.autorun();
    oSWD_Ctrl.sCreditCheckFailedMsg = ' The Quote cannot be generated as the Credit Status is';
    oSWD_Ctrl.returnToPT();
    oSWD_Ctrl.hasPartner = false;
    oSWD_Ctrl.isLightingEnv= false;
    oSWD_Ctrl.redirectToDS();
  }
  static testMethod void unitTest1() {
    Account oacc = new Account (Name = 'Testrajesh' , Accounting_Credit_Hold__c = 'Warning');
    insert oacc ;
    system.assertEquals(oacc.Name, 'Testrajesh', 'Both values should be the same.');
    Account oparacc = new Account (Name = 'Partner Account');
    insert oparacc ;
    Contact ocontact = new Contact(LastNAme = 'test' ,Email = 'anbcd@gmail.com' ,Accountid =oacc.id );
    insert ocontact;
    system.assertEquals(ocontact.LastName, 'test', 'Both values should be the same.');
    Contact ocontact1 = new Contact(LastNAme = 'test billing' ,Email = 'anbcd@gmail.com' ,Accountid =oacc.id );
    insert ocontact1;
    Partner oPartner = new Partner(Role = 'Agency', AccountToId = oparacc.id, AccountFromId = oacc.id);
    insert oPartner;
    Opportunity opp = new opportunity (name = 'test' , closeDate = Date.Today(), StageName= 'Qalification' , AccountId = oacc.id ,Opportunity_Contact__c = ocontact.id , Billing_Contact__c = ocontact1.id);
    insert opp;
    system.assertEquals(opp.Name, 'test', 'Both values should be the same.');
    SBQQ__Quote__c oQuote = new SBQQ__Quote__c(SBQQ__Status__c = 'Quote',SBQQ__Type__c = 'Quote', SBQQ__Opportunity2__c = opp.id);
    insert oQuote;
    system.assertEquals(oQuote.SBQQ__Status__c, 'Quote', 'Both values should be the same.');
    SBQQ__QuoteDocument__c oQuoteDocument = new SBQQ__QuoteDocument__c ( Name = 'Rajesh' ,Sign_Status__c ='Completed',SBQQ__Quote__c =oQuote.id );
    insert oQuoteDocument;
    system.assertEquals(oQuoteDocument.Sign_Status__c, 'Completed', 'Both values should be the same.');
  }
}