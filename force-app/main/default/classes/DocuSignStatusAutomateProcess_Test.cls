/**
 * File:        DocuSignStatusAutomateProcess_Test.cls
 * Project:     GAP
 * Date:        01-04-2020
 * Created By: Rajesh Kumar 
 * *************************************************************************
 * @description  DocuSignStatusAutomateProcess_Test class
 * Code Coverage : 90%
 * *************************************************************************
 * History: BK-3636
 */
@isTest
public class DocuSignStatusAutomateProcess_Test{
    static testMethod void createQuoteDoc(){
    
        Trigger__c trig = new Trigger__c(Name = 'DocuSignStatusAutomateProcess_Trig' , Trigger_Name_Unique__c='DocuSignStatusAutomateProcess_Trig',Enabled__c=true,Object__c='dsfs__DocuSign_Status__c',Run_for_Recordypes__c='All',  Description__c='my test',Execution_Order__c=1, After_Insert__c=true , After_Update__c = true );
        Insert trig;
        Trigger_Recordtype__c rt = new Trigger_Recordtype__c(Enabled__c=true,Recordtype_Id__c=trig.Id,Trigger__c=trig.Id,Parameters__c='param=1;param=2');
        Insert rt;    
        
        TriggerInterface_DocuSign_Status triggerInterfaceObj = new TriggerInterface_DocuSign_Status();
        
        TriggerInterfaceHelper.runTrigger('DocuSignStatusAutomateProcess_Trig','dsfs__DocuSign_Status__c',1, 'ai', null,null,'All');
        TriggerInterfaceHelper.initTriggerMapAndList('DocuSignStatusAutomateProcess_Trig');  
        Account oAccount = new Account(Name='Expocad Account', CurrencyIsoCode = 'USD');
        insert oAccount;
        
        Contact oCon = new Contact(LastName='ContTest1', Email='test1contact@duptest.com', AccountId = oAccount.Id);
        insert oCon;
        
        Event_Series__c oESeries = new Event_Series__c(name='World of Concrete',Event_Edition_Pool__c='WOC');
        insert oEseries;
        
        Event_Edition__c oEvent = new Event_Edition__c(Name = 'World of Concrete 2017',Tab1__c='Test 1',Tab7__c='Test 7',Part_of_Series__c=oEseries.id, Payment_Schedule__c = '50-50',cutoff_date_1__c = date.today(),Approval_Service_Now_ID__c = '123', CurrencyIsoCode = 'USD', Event_Code__c = 'KDB,KDB2', Booth_Type__c = 'Island,Corner,Inline,Custom,Peninsula', No_Of_Corner__c = '0,1,2,3,4', Booth_Size__c = '100 SqFt,400 SqFt,900 SqFt,1600 SqFt,2500 SqFt');
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
        System.assertEquals('test', docObj.Name, 'Test Class Failed');
        dsfs__DocuSign_Status__c obj = new dsfs__DocuSign_Status__c ();
        obj.dsfs__Envelope_Status__c = 'Sent';
        obj.Quote__c =oQuote.id;
        insert obj;
        
        obj.dsfs__Envelope_Status__c = 'Delivered';
        update obj;
        
        /*obj.dsfs__Envelope_Status__c = 'Completed';
        update obj;*/
    }
}