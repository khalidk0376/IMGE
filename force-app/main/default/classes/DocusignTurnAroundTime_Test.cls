/**
 * File:        DocusignTurnAroundTime_Trig.cls 
 * Project:     GAP
 * Created Date: 31-03-2020
 * Created By:  Rajesh Kumar
 * Modified By:  Rajesh Kumar
 * Test Class: 
 * Coverage: 
 *
 * *************************************************************************
 * @description  we have tracking turn tround time from docusign status..
 * *************************************************************************
 * History:Ticket :BK-3636
 *
*/

@isTest
public class DocusignTurnAroundTime_Test {
    
    static testMethod void documentTAT() {
        Test.startTest();
        Trigger__c trig = new Trigger__c(Name = 'DocusignTurnAroundTime_Trig' , Trigger_Name_Unique__c='DocusignTurnAroundTime_Trig',Enabled__c=true,Object__c='SBQQ__QuoteDocument__c',Run_for_Recordypes__c='All',  Description__c='my test',Execution_Order__c=2, After_Insert__c=true , After_Update__c = true );
        Insert trig;
        Trigger_Recordtype__c rt = new Trigger_Recordtype__c(Enabled__c=true,Recordtype_Id__c=trig.Id,Trigger__c=trig.Id,Parameters__c='param=1;param=2');
        Insert rt;    
        
        TriggerInterface_QuoteDocument triggerInterfaceObj = new TriggerInterface_QuoteDocument();
        
        TriggerInterfaceHelper.runTrigger('DocusignTurnAroundTime_Trig','SBQQ__QuoteDocument__c',1, 'ai', null,null,'All');
        TriggerInterfaceHelper.initTriggerMapAndList('DocusignTurnAroundTime_Trig');
        
        Account oAccount = new Account(Name='Expocad Account', CurrencyIsoCode = 'USD');
        insert oAccount;
        System.assertEquals('Expocad Account', oAccount.name,'Error account is not created');
        
        Contact oCon = new Contact(LastName='ContTest1', Email='test1contact@duptest.com', AccountId = oAccount.Id);
        insert oCon;
        
        Event_Series__c oESeries = new Event_Series__c(name='World of Concrete',Event_Edition_Pool__c='WOC');
        insert oEseries;
        
        Event_Edition__c oEvent = new Event_Edition__c(Name = 'World of Concrete 2017',Tab1__c='Test 1',Tab7__c='Test 7',Part_of_Series__c=oEseries.id, Payment_Schedule__c = '50-50',cutoff_date_1__c = date.today(),Approval_Service_Now_ID__c = '123', CurrencyIsoCode = 'USD',End_Date__C =date.today()+7, Event_Code__c = 'KDB,KDB2', Booth_Type__c = 'Island,Corner,Inline,Custom,Peninsula', No_Of_Corner__c = '0,1,2,3,4', Booth_Size__c = '100 SqFt,400 SqFt,900 SqFt,1600 SqFt,2500 SqFt');
        insert oEvent;
        
        Opportunity oOpportunity = new Opportunity(Name = 'Expocad Opportunity', CloseDate = Date.today(), StageName = 'Proposal', EventEdition__c = oEvent.Id, AccountId = oAccount.Id, Billing_Contact__c = oCon.Id);
        insert oOpportunity;
        
        SBQQ__Quote__c oQuote = new SBQQ__Quote__c(CurrencyIsoCode = 'USD', SBQQ__Status__c = 'Quote Sent', SBQQ__Type__c = 'Quote', SBQQ__Opportunity2__c = oOpportunity.Id, SBQQ__Account__c = oAccount.Id);
        insert oQuote;
        
        Folder folder = [select id from Folder where Folder.name='Conga Preview Documents' LIMIT 1];
        
        
        Document docObj=new Document();
        docObj.Name='test';
        docObj.FolderId = folder.id;
        insert docObj;
        
        Blob b = Blob.valueOf('Test Data');
        
        SBQQ__QuoteDocument__c oQDOC = new SBQQ__QuoteDocument__c();
        oQDOC.name = 'DocFile';
        oQDOC.SBQQ__SignatureStatus__c = 'Sent';
        oQDOC.SBQQ__Quote__c = oQuote.id ;
        Insert oQDOC;

        System.assertEquals('DocFile', oQDOC.Name, 'Test Class has failed');
        
        Attachment oAttach = new Attachment();  
        oAttach.ParentId = oQDOC.id;  
        oAttach.Name = 'Test Attachment for Parent Manual';  
        oAttach.Body = b;   
        insert oAttach; 
       
          
        dsfs__DocuSign_Status__c obj = new dsfs__DocuSign_Status__c ();
        obj.dsfs__Envelope_Status__c = 'Completed';
        obj.CurrencyIsoCode = 'USD';
        obj.Quote__c =oQuote.id;
        insert obj;
        Quote_Template_TAT__c quote = new Quote_Template_TAT__c();
        quote.Name = 'DocFileUpdate';
        quote.Opportunity__c = oOpportunity.id;
        quote.Document_Sent_Date__c = system.now();
        quote.Document_Signed_Date__c = system.now();
        quote.Document_Status__c = 'Sent' ;
        quote.Quote_Document__c  = oQDOC.Id;
        insert quote;
         
        oQDOC.SBQQ__SignatureStatus__c = 'Declined';
        oQDOC.Name = 'DocFileUpdate';
        update oQDOC;

        SBQQ__QuoteDocument__c oQDOC1 = new SBQQ__QuoteDocument__c();
        oQDOC1.name = 'DocFile';
        oQDOC1.SBQQ__SignatureStatus__c = 'sent';
        oQDOC1.SBQQ__Quote__c = oQuote.id ;
        Insert oQDOC1;
        oQDOC1.SBQQ__SignatureStatus__c = 'Complete';
        oQDOC1.SBQQ__Template__c = 'Contract';
        Update oQDOC1;
        Test.stopTest();
    }
    
    
    
    static testMethod void documentTAT1() {
        Test.startTest();
        Trigger__c trig = new Trigger__c(Name = 'DocusignTurnAroundTime_Trig' , Trigger_Name_Unique__c='DocusignTurnAroundTime_Trig',Enabled__c=true,Object__c='SBQQ__QuoteDocument__c',Run_for_Recordypes__c='All',  Description__c='my test',Execution_Order__c=2, After_Insert__c=true , After_Update__c = true );
        Insert trig;
        Trigger_Recordtype__c rt = new Trigger_Recordtype__c(Enabled__c=true,Recordtype_Id__c=trig.Id,Trigger__c=trig.Id,Parameters__c='param=1;param=2');
        Insert rt;    
        
        TriggerInterface_QuoteDocument triggerInterfaceObj = new TriggerInterface_QuoteDocument();
        
        TriggerInterfaceHelper.runTrigger('DocusignTurnAroundTime_Trig','SBQQ__QuoteDocument__c',2, 'ai', null,null,'All');
        TriggerInterfaceHelper.initTriggerMapAndList('DocusignTurnAroundTime_Trig');
        Account oAccount = new Account(Name='Expocad Account', CurrencyIsoCode = 'USD');
        insert oAccount;
        System.assertEquals('Expocad Account', oAccount.name,'Error account is not created');
        
        Contact oCon = new Contact(LastName='ContTest1', Email='test1contact@duptest.com', AccountId = oAccount.Id);
        insert oCon;
        
        Event_Series__c oESeries = new Event_Series__c(name='World of Concrete',Event_Edition_Pool__c='WOC');
        insert oEseries;
        
        Event_Edition__c oEvent = new Event_Edition__c(Name = 'World of Concrete 2017',Tab1__c='Test 1',Tab7__c='Test 7',Part_of_Series__c=oEseries.id, Payment_Schedule__c = '50-50',cutoff_date_1__c = date.today(),Approval_Service_Now_ID__c = '123', CurrencyIsoCode = 'USD',End_Date__C =date.today()+7, Event_Code__c = 'KDB,KDB2', Booth_Type__c = 'Island,Corner,Inline,Custom,Peninsula', No_Of_Corner__c = '0,1,2,3,4', Booth_Size__c = '100 SqFt,400 SqFt,900 SqFt,1600 SqFt,2500 SqFt');
        insert oEvent;
        
        Opportunity oOpportunity = new Opportunity(Name = 'Expocad Opportunity', CloseDate = Date.today(), StageName = 'Proposal', EventEdition__c = oEvent.Id, AccountId = oAccount.Id, Billing_Contact__c = oCon.Id);
        insert oOpportunity;
        
        SBQQ__Quote__c oQuote = new SBQQ__Quote__c(CurrencyIsoCode = 'USD', SBQQ__Status__c = 'Quote Sent', SBQQ__Type__c = 'Quote', SBQQ__Opportunity2__c = oOpportunity.Id, SBQQ__Account__c = oAccount.Id);
        insert oQuote;
        
        Folder folder = [select id from Folder where Folder.name='Conga Preview Documents' LIMIT 1];
        
        Document docObj=new Document();
        docObj.Name='test';
        docObj.FolderId = folder.id;
        insert docObj;
        
        Blob b = Blob.valueOf('Test Data');
        
        
        SBQQ__QuoteDocument__c oQDOC1 = new SBQQ__QuoteDocument__c();
        oQDOC1.name = 'DocFile';
        oQDOC1.SBQQ__Quote__c = oQuote.id ;
        oQDOC1.SBQQ__SignatureStatus__c = 'Sent';
        Insert oQDOC1;      
        System.assertEquals('DocFile', oQDOC1.Name, 'Test Class has failed');
        Attachment oAttach = new Attachment();  
        oAttach.ParentId = oQDOC1.id;  
        oAttach.Name = 'Test Attachment for Parent Manual';  
        oAttach.Body = b;   
        insert oAttach; 
        
        oQDOC1.SBQQ__SignatureStatus__c = 'Completed';
        oQDOC1.SBQQ__Template__c = 'Contract';
       // Update oQDOC1;
        dsfs__DocuSign_Status__c obj = new dsfs__DocuSign_Status__c ();
        obj.dsfs__Envelope_Status__c = 'Completed';
        obj.CurrencyIsoCode = 'USD';
        obj.Quote__c =oQuote.id;
        insert obj;
        Test.stopTest();
    }
}