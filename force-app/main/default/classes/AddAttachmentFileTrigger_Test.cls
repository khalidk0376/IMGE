/**
* File:            AddAttachmentFile_Test.cls
* Project:         GAP
* Date:            9/9/16
* Created By:     Rajesh Kumar 
* *************************************************************************
* Description: AddAttachmentFile class
* Code Coverage :
* *************************************************************************
* History:
*/


@isTest
public class AddAttachmentFileTrigger_Test {
    
    static testMethod void documentTAT() {
        Test.startTest();
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
        Blob b3 = Blob.valueOf('Test Data record');
        Attachment oAttach3 = new Attachment();  
        oAttach3.ParentId = oOpportunity.id;  
        oAttach3.Name = 'Completed Test Signed Attachment for Parent Manual';  
        oAttach3.Body = b3;   
        insert oAttach3; 
        
        SBQQ__Quote__c oQuote = new SBQQ__Quote__c(CurrencyIsoCode = 'USD', SBQQ__Status__c = 'Quote Sent', SBQQ__Type__c = 'Quote', SBQQ__Opportunity2__c = oOpportunity.Id, SBQQ__Account__c = oAccount.Id);
        insert oQuote;
        Blob b1 = Blob.valueOf('Test Data record');
        Attachment oAttach1 = new Attachment();  
        oAttach1.ParentId = oQuote.id;  
        oAttach1.Name = 'Test Attachment for Parent Manual';  
        oAttach1.Body = b1;   
        insert oAttach1; 
        
        Folder folder = [select id from Folder where Folder.name='Conga Preview Documents' LIMIT 1];
        
        
        Document docObj=new Document();
        docObj.Name='test';
        docObj.FolderId = folder.id;
        insert docObj;
        
        
       
          
        dsfs__DocuSign_Status__c obj = new dsfs__DocuSign_Status__c ();
        obj.dsfs__Envelope_Status__c = 'Completed';
        obj.CurrencyIsoCode = 'USD';
        obj.Quote__c =oQuote.id;
        insert obj;
        Blob b2 = Blob.valueOf('Test Data record');
        Attachment oAttach2 = new Attachment();  
        oAttach2.ParentId = obj.id;  
        oAttach2.Name = 'Test Signed Attachment for Parent Manual';  
        oAttach2.Body = b1;   
        insert oAttach2; 
         
        
        SBQQ__QuoteDocument__c oQDOC = new SBQQ__QuoteDocument__c();
        oQDOC.name = 'DocFile';
        oQDOC.SBQQ__SignatureStatus__c = 'Sent';
        oQDOC.SBQQ__Quote__c = obj.Quote__c ;
        Insert oQDOC;

        Blob b = Blob.valueOf('Test Data');
        Attachment oAttach = new Attachment();  
        oAttach.ParentId = oQDOC.id;  
        oAttach.Name = 'Test Signed Attachment for Parent Manual';  
        oAttach.Body = b;   
        insert oAttach;
        Quote_Template_TAT__c Quote = new Quote_Template_TAT__c();
        Quote.Name = 'DocFileUpdate';
        Quote.Opportunity__c = oOpportunity.id;
        Quote.Document_Sent_Date__c = system.now();
        Quote.Document_Signed_Date__c = system.now();
        
        insert Quote;
         
        oQDOC.SBQQ__SignatureStatus__c = 'Sent1';
        oQDOC.Name = 'DocFileUpdate';
        update oQDOC;
        System.assertEquals('Sent1', oQDOC.SBQQ__SignatureStatus__c , 'Error');
        
        Test.stopTest();
    }
}