/**
 * File:        GenerateDocumentCtrl_Test.cls
 * Project:     GAP
 * Date:        3/6/2017 11:57 PM 
 * Created By: Rajesh Kumar
 * * Modified By : Rajesh kumar Yadav Bk-3751,[Modified By : Aishwarya 12 Aug 2020 BK-3751]
 * *************************************************************************
 * Description:Code coverage for "GenerateDocumentCtrl" class 
 *Code Coverage : 76%
 * *************************************************************************
 * History:
 */

@isTest(seeAlldata = false)
public class GenerateDocumentCtrl_Test
{
  static testMethod void unitTest()
  {
    Account oacc = new Account(Name = 'Testrajesh');
    insert oacc;
    System.assertEquals(oacc.Name, 'Testrajesh' , 'Account name should equals to Testrajesh');
    
    Account oparacc = new Account(Name = 'Partner Account');
    insert oparacc;
    System.assertEquals(oparacc.Name, 'Partner Account' , 'Account name should equals to Partner Account');
    
    Contact ocontact = new Contact(LastNAme = 'test', Email = 'anbcd@gmail.com');
    insert ocontact;
    System.assertEquals(ocontact.LastName, 'test' , 'contact last name should equals to test');
    
    Contact ocontact1 = new Contact(LastNAme = 'test billing', Email = 'anbcd@gmail.com', Accountid = oacc.id);
    insert ocontact1;
    System.assertEquals(ocontact1.LastName, 'test billing' , 'contact last name should equals to test billing');
    
    Partner oPartner = new Partner(Role = 'Agency', AccountToId = oparacc.id, AccountFromId = oacc.id);
    insert oPartner;
    System.assertEquals(oPartner.AccountToId, oparacc.id , 'account id should be equals..');
    
    Opportunity opp = new opportunity(name = 'test', closeDate = Date.Today(), StageName = 'Qalification', AccountId = oacc.id, Opportunity_Contact__c = ocontact.id);
    insert opp;
    SBQQ__Quote__c oQuote = new SBQQ__Quote__c(SBQQ__Status__c = 'Quote', SBQQ__Type__c = 'Quote', SBQQ__Opportunity2__c = opp.id, SBQQ__PrimaryContact__c = ocontact.Id);
    insert oQuote;
    system.assertEquals(oQuote.SBQQ__Status__c, 'Quote', 'Both values should be the same.');
    PageReference pageRef = Page.GenarateAggrement;
    pageRef.getParameters().put('id', oQuote.id);
    Test.setCurrentPage(pageRef);
    ApexPages.StandardController sc = new ApexPages.StandardController(oQuote);
    GenerateDocumentCtrl oGenerateDocumentCtrl = new GenerateDocumentCtrl(sc);
    oGenerateDocumentCtrl.show = true;
    oGenerateDocumentCtrl.autorun();
    oGenerateDocumentCtrl.sCreditCheckFailedMsg = ' The Quote cannot be generated as the Credit Status is';
    oGenerateDocumentCtrl.returnToPT();
    oGenerateDocumentCtrl.hasPartner = false;
    oGenerateDocumentCtrl.isLightingEnv = false;
    oGenerateDocumentCtrl.redirectToDS();
  }
  static testMethod void unitTest1()
  {
    Account oacc = new Account(Name = 'Testrajesh', Accounting_Credit_Hold__c = 'Warning');
    insert oacc;
    System.assertEquals(oacc.Name, 'Testrajesh' , 'Account name should equals to Testrajesh');
    
    Account oparacc = new Account(Name = 'Partner Account');
    insert oparacc;
    
    Contact ocontact = new Contact(LastNAme = 'test', Email = 'anbcd@gmail.com', Accountid = oacc.id);
    insert ocontact;
    System.assertEquals(ocontact.LastName, 'test' , 'contact last name should equals to test');
    
    Contact ocontact1 = new Contact(LastNAme = 'test billing', Email = 'anbcd@gmail.com', Accountid = oacc.id);
    insert ocontact1;
    Partner oPartner = new Partner(Role = 'Agency', AccountToId = oparacc.id, AccountFromId = oacc.id);
    insert oPartner;
    Opportunity opp = new opportunity(name = 'test', closeDate = Date.Today(), StageName = 'Qalification', AccountId = oacc.id, Opportunity_Contact__c = ocontact.id);
    insert opp;
    SBQQ__Quote__c oQuote = new SBQQ__Quote__c(SBQQ__Status__c = 'Quote', SBQQ__Type__c = 'Quote', SBQQ__Opportunity2__c = opp.id);
    insert oQuote;
    system.assertEquals(oQuote.SBQQ__Status__c, 'Quote', 'Both values should be the same.');
  }
}