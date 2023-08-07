/**
 * File:        UpdateQuoteOpportunityByDocusign_Test.apxt
 * Project:     GAP
 * Date:        01-04-2020
 * Created By: Rajesh Kumar
 * *************************************************************************
 * @description  When Quote document Sign status is completed then related Quote field primary is update.
 * *************************************************************************
 * History:
 */
 
@isTest(seeAlldata = false)
public class UpdateQuoteOpportunityByDocusign_Test {
    static testMethod void unitTest() {
        Trigger__c trig = new Trigger__c(Name = 'UpdateQuoteOpportunityByDocusign_Trig' , Trigger_Name_Unique__c='UpdateQuoteOpportunityByDocusign_Trig',Enabled__c=true,Object__c='SBQQ__QuoteDocument__c',Run_for_Recordypes__c='All',  Description__c='my test',Execution_Order__c=1, After_Insert__c=true , After_Update__c = true );
        Insert trig;
        Trigger_Recordtype__c rt = new Trigger_Recordtype__c(Enabled__c=true,Recordtype_Id__c=trig.Id,Trigger__c=trig.Id,Parameters__c='param=1;param=2');
        Insert rt;    
        
        TriggerInterface_QuoteDocument triggerInterfaceObj = new TriggerInterface_QuoteDocument();
        
        TriggerInterfaceHelper.runTrigger('UpdateQuoteOpportunityByDocusign_Trig','SBQQ__QuoteDocument__c',1, 'ai', null,null,'All');
        TriggerInterfaceHelper.initTriggerMapAndList('UpdateQuoteOpportunityByDocusign_Trig');  
        Pricebook2 pb=new Pricebook2(Name='TestPricebook');
        insert pb;  
        
        Event_Series__c es = new Event_Series__c();
        es.Name='testt';
        es.Package_Identifier__c='test';
        es.Event_Edition_Pool__c = 'WOC';
        insert es;

        Event_Edition__c ee = new Event_Edition__c();
        ee.Name='test';
        ee.Part_of_Series__c=es.Id;
        ee.Tab1__c='ttttt';
        ee.Tab7__c='yyyyyy';
        ee.Event_Price_Book__c=pb.Id;
        ee.Payment_Schedule__c = '50-50';
        ee.CutoffDate_1__c = date.today();
        ee.CutoffDate_2__c = date.today();
        ee.CutoffDate_3__c = date.today();
        ee.Cutoff_Date_1__c = date.today();
        ee.Cutoff_Date_3__c = date.today();
        ee.Cutoff_Date_2__c = date.today();
        insert ee;

        Account oacc = new Account (Name = 'Test');
        insert oacc ;  
        
        Contact ocontact = new Contact(LastNAme = 'test', Email = 'anbcd@gmail.com',AccountId=oacc.Id);
        insert ocontact; 
        Opportunity opp = new opportunity(name = 'test', Type = 'Existing Business',closeDate = Date.Today(), EventEdition__c=ee.Id, StageName = 'Closed Won', AccountId = oacc.id, Opportunity_Contact__c = ocontact.id);
        insert opp;
        System.assertEquals('test' , opp.Name, 'error in asserts');
        SBQQ__Quote__c oQuote = new SBQQ__Quote__c(SBQQ__Status__c = 'Draft',SBQQ__Type__c = 'Quote',SBQQ__Primary__c = true, SBQQ__Opportunity2__c = opp.id, IsNotGeneralDocument__c = true );
        oQuote.SBQQ__Status__c = 'Contract In Review';
        insert oQuote;
        SBQQ__QuoteDocument__c oQuoteDocument = new SBQQ__QuoteDocument__c ( Name = 'Rajesh' ,Sign_Status__c ='Completed',SBQQ__Template__c = 'Quote', SBQQ__SignatureStatus__c ='Sent',SBQQ__Quote__c =oQuote.id, SBQQ__Opportunity__c = opp.Id );
        insert oQuoteDocument;
          
        SBQQ__QuoteDocument__c oQuoteDocument1 = new SBQQ__QuoteDocument__c ( Name = 'Rajesh' ,Sign_Status__c ='Completed',SBQQ__Template__c = 'Contract', SBQQ__SignatureStatus__c ='Sent',SBQQ__Quote__c =oQuote.id, SBQQ__Opportunity__c = opp.Id );
        insert oQuoteDocument1;
          
        System.assertEquals('Rajesh' , oQuoteDocument.Name, 'quote document isnt inserted');
        oQuote.SBQQ__Status__c = 'Quote Sent';
        Update oQuote;
        oQuoteDocument.SBQQ__Template__c = 'Quote' ;
        oQuoteDocument.SBQQ__SignatureStatus__c = 'Delivered';
        update oQuoteDocument;
        oQuoteDocument.SBQQ__Template__c = 'Quote' ;
        //oQuoteDocument.SBQQ__SignatureStatus__c = 'Completed';
        update oQuoteDocument;

        oQuote.SBQQ__Primary__c = true;
        oQuote.SBQQ__Status__c = 'Contract Sent';
        Update oQuote;
        oQuoteDocument.SBQQ__Template__c = 'Contract' ;
        oQuoteDocument.SBQQ__SignatureStatus__c = 'Delivered';
        update oQuoteDocument;
		System.assertEquals('Rajesh', oQuoteDocument.Name, 'Test Class has failed');
        List<SBQQ__QuoteDocument__c> sBQQQuoteDocuList = new List<SBQQ__QuoteDocument__c>();
        Map<Id, SBQQ__QuoteDocument__c> mapQuoteDocument = new Map<Id, SBQQ__QuoteDocument__c>();
        sBQQQuoteDocuList.add(oQuoteDocument);
        mapQuoteDocument.put(oQuoteDocument.id , oQuoteDocument);
        docuSignAutomateProcessCtrl docAuto = new docuSignAutomateProcessCtrl(sBQQQuoteDocuList, mapQuoteDocument, True, True, True);
        docAuto.onAfterInsertUpdate();
        //docAuto.updateQuoteStatus();
    }
}