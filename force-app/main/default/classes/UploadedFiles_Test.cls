/**
* File:            UploadedFiles_Test.cls
* Project:         informa Market
* Date:            19-10-2020
* Created By:     Rajesh Kumar 
* *************************************************************************
* Description: AddAttachmentFile class
* Code Coverage :
* *************************************************************************
* History:BK- 5975  - Additional Document add in docusign process - By Rajesh Kr.
* Modified by Shiv raghav for bk-bk-14852
*/

@isTest
public class UploadedFiles_Test {
    static testMethod void documentTAT() {
        Test.startTest();
        // Create Trigger test record 
        Trigger__c trig = new Trigger__c(Name = 'UploadedFiles_Trig' , Trigger_Name_Unique__c='UploadedFiles_Trig',Enabled__c=true,Object__c='ContentDocumentLink',Run_for_Recordypes__c='All',  Description__c='my test',Execution_Order__c=2,
                                         After_Insert__c=true);
        Insert trig;
        Trigger_Recordtype__c rt = new Trigger_Recordtype__c(Enabled__c=true,Recordtype_Id__c=trig.Id,Trigger__c=trig.Id,Parameters__c='param=1;param=2');
        Insert rt;    
        //Call event edition trigger interface
        TriggerInterface_ContentDocumentLink obj = new TriggerInterface_ContentDocumentLink();
        
        //Call trigger app handler for insert event
        TriggerInterfaceHelper.runTrigger('UploadedFiles_Trig','UploadedFiles_Trig',1, 'ai', null,null,'All');
        TriggerInterfaceHelper.initTriggerMapAndList('UploadedFiles_Trig');
        Account oAccount = new Account(Name='Expocad Account', CurrencyIsoCode = 'USD');
        insert oAccount;
        System.assertEquals('Expocad Account', oAccount.name,'Error account is not created');
        
        Contact oCon = new Contact(LastName='ContTest1', Email='test1contact@duptest.com', AccountId = oAccount.Id);
        insert oCon;
        
        Event_Series__c oESeries = new Event_Series__c(name='World of Concrete',Event_Edition_Pool__c='WOC');
        insert oEseries;
        
        Event_Edition__c Mapee = new Event_Edition__c(Name = 'World of Concrete 2017',Tab1__c='Test 1',Tab7__c='Test 7',Part_of_Series__c=oEseries.id, Event_Edition_Code__c = 'Abc',Payment_Schedule__c = '50-50',cutoff_date_1__c = date.today(),Approval_Service_Now_ID__c = '123', CurrencyIsoCode = 'USD',End_Date__C =date.today()+7, Event_Code__c = 'KDB,KDB2', Booth_Type__c = 'Island,Corner,Inline,Custom,Peninsula', No_Of_Corner__c = '0,1,2,3,4', Booth_Size__c = '100 SqFt,400 SqFt,900 SqFt,1600 SqFt,2500 SqFt');
        insert Mapee;
        
        Event_Edition__c oEvent = new Event_Edition__c(Name = 'World of Concrete 2017',Mapped_Online_Event__c = Mapee.id,Tab1__c='Test 1',Tab7__c='Test 7',Part_of_Series__c=oEseries.id, Payment_Schedule__c = '50-50',cutoff_date_1__c = date.today(),Approval_Service_Now_ID__c = '123', CurrencyIsoCode = 'USD',End_Date__C =date.today()+7, Event_Code__c = 'KDB,KDB2', Booth_Type__c = 'Island,Corner,Inline,Custom,Peninsula', No_Of_Corner__c = '0,1,2,3,4', Booth_Size__c = '100 SqFt,400 SqFt,900 SqFt,1600 SqFt,2500 SqFt');
        insert oEvent;
       
        Opportunity Onlineopp = new opportunity(name = 'test', closeDate = Date.Today(), EventEdition__c=Mapee.Id, StageName = 'Contract Sent', AccountId = oAccount.id, Opportunity_Contact__c = oCon.id,Status__c = 'Online Booth Form In Review' , Manual_Contract__c = true);
        insert Onlineopp;
        Opportunity oOpportunity = new Opportunity(Name = 'Expocad Opportunity', Online_Opportunity__c =Onlineopp.id, CloseDate = Date.today(), StageName = 'Proposal', EventEdition__c = oEvent.Id, AccountId = oAccount.Id, Billing_Contact__c = oCon.Id);
        insert oOpportunity;
        Blob b3 = Blob.valueOf('Test Data record');
        ContentVersion cVersion = new ContentVersion();
        cVersion.ContentLocation = 'S'; //S-Document is in Salesforce. E-Document is outside of Salesforce. L-Document is on a Social Netork.
        cVersion.PathOnClient = 'Completed Test Signed Attachment for Parent Manual.pdf';//File name with extention
        cVersion.Origin = 'H';//C-Content Origin. H-Chatter Origin.
        cVersion.OwnerId = userinfo.getUserId();//Owner of the file
        cVersion.Title ='Completed Test Signed Attachment for Parent Manual';//Name of the file
        cVersion.VersionData = b3;//File content
        insert cVersion;
        Id conDocument = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cVersion.Id].ContentDocumentId;
        ContentDocumentLink cDocLink = new ContentDocumentLink();
        cDocLink.ContentDocumentId = conDocument;//Add ContentDocumentId
        cDocLink.LinkedEntityId = oOpportunity.id;//Add attachment parentId
        cDocLink.ShareType = 'V';//V - Viewer permission. C - Collaborator permission. I - Inferred permission.
        cDocLink.Visibility = 'AllUsers';//AllUsers, InternalUsers, SharedUsers
        insert cDocLink;
        
        ContentDocumentLink cDocLinkEE = new ContentDocumentLink();
        cDocLinkEE.ContentDocumentId = conDocument;//Add ContentDocumentId
        cDocLinkEE.LinkedEntityId = oEvent.id;//Add attachment parentId
        cDocLinkEE.ShareType = 'V';//V - Viewer permission. C - Collaborator permission. I - Inferred permission.
        cDocLinkEE.Visibility = 'AllUsers';//AllUsers, InternalUsers, SharedUsers
        insert cDocLinkEE;
        
        SBQQ__Quote__c oQuote = new SBQQ__Quote__c(CurrencyIsoCode = 'USD', SBQQ__Status__c = 'Quote Sent', SBQQ__Type__c = 'Quote', SBQQ__Opportunity2__c = oOpportunity.Id, SBQQ__Account__c = oAccount.Id);
        insert oQuote;
        Blob b1 = Blob.valueOf('Test Data record');
        ContentVersion cVersion1 = new ContentVersion();
        cVersion1.ContentLocation = 'S'; //S-Document is in Salesforce. E-Document is outside of Salesforce. L-Document is on a Social Netork.
        cVersion1.PathOnClient = 'Test Attachment for Parent Manual.pdf';//File name with extention
        cVersion1.Origin = 'H';//C-Content Origin. H-Chatter Origin.
        cVersion1.OwnerId = userinfo.getUserId();//Owner of the file
        cVersion1.Title ='Test Attachment for Parent Manual';//Name of the file
        cVersion1.VersionData = b1;//File content
        insert cVersion1;
        Id conDocument1 = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =: cVersion1.Id].ContentDocumentId;
        ContentDocumentLink cDocLink1 = new ContentDocumentLink();
        cDocLink1.ContentDocumentId = conDocument1;//Add ContentDocumentId
        cDocLink1.LinkedEntityId = oQuote.id;//Add attachment parentId
        cDocLink1.ShareType = 'V';//V - Viewer permission. C - Collaborator permission. I - Inferred permission.
        cDocLink1.Visibility = 'AllUsers';//AllUsers, InternalUsers, SharedUsers
        insert cDocLink1;
        
        Folder folder = [select id from Folder where Folder.name='Conga Preview Documents' LIMIT 1];
        Document docObj=new Document();
        docObj.Name='test';
        docObj.FolderId = folder.id;
        insert docObj;
        
        
       
          
        dsfs__DocuSign_Status__c objdoc = new dsfs__DocuSign_Status__c ();
        objdoc.dsfs__Envelope_Status__c = 'Completed';
        objdoc.CurrencyIsoCode = 'USD';
        objdoc.Quote__c =oQuote.id;
        insert objdoc;
        Blob b2 = Blob.valueOf('Test Data record');
        ContentVersion cVersion2 = new ContentVersion();
        cVersion2.ContentLocation = 'S'; //S-Document is in Salesforce. E-Document is outside of Salesforce. L-Document is on a Social Netork.
        cVersion2.PathOnClient = 'Test Signed Attachment for Parent Manual.pdf';//File name with extention
        cVersion2.Origin = 'H';//C-Content Origin. H-Chatter Origin.
        cVersion2.OwnerId = userinfo.getUserId();//Owner of the file
        cVersion2.Title ='Test Signed Attachment for Parent Manual';//Name of the file
        cVersion2.VersionData = b2;//File content
        insert cVersion2;
        Id conDocument2 = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =: cVersion2.Id].ContentDocumentId;
        ContentDocumentLink cDocLink2 = new ContentDocumentLink();
        cDocLink2.ContentDocumentId = conDocument2;//Add ContentDocumentId
        cDocLink2.LinkedEntityId = objdoc.id;//Add attachment parentId
        cDocLink2.ShareType = 'V';//V - Viewer permission. C - Collaborator permission. I - Inferred permission.
        cDocLink2.Visibility = 'AllUsers';//AllUsers, InternalUsers, SharedUsers
        insert cDocLink2;      
        
        SBQQ__QuoteDocument__c oQDOC = new SBQQ__QuoteDocument__c();
        oQDOC.name = 'DocFile';
        oQDOC.SBQQ__SignatureStatus__c = 'Sent';
        oQDOC.SBQQ__Quote__c = objdoc.Quote__c ;
        Insert oQDOC;

        Blob b = Blob.valueOf('Test Data');
        ContentVersion cVersion3 = new ContentVersion();
        cVersion3.ContentLocation = 'S'; //S-Document is in Salesforce. E-Document is outside of Salesforce. L-Document is on a Social Netork.
        cVersion3.PathOnClient = 'Test Signed Attachment for Parent Manual.pdf';//File name with extention
        cVersion3.Origin = 'H';//C-Content Origin. H-Chatter Origin.
        cVersion3.OwnerId = userinfo.getUserId();//Owner of the file
        cVersion3.Title ='Test Signed Attachment for Parent Manual';//Name of the file
        cVersion3.VersionData = b;//File content
        insert cVersion3;
        Id conDocument3 = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =: cVersion3.Id].ContentDocumentId;
        ContentDocumentLink cDocLink3 = new ContentDocumentLink();
        cDocLink3.ContentDocumentId = conDocument3;//Add ContentDocumentId
        cDocLink3.LinkedEntityId = oQDOC.id;//Add attachment parentId
        cDocLink3.ShareType = 'V';//V - Viewer permission. C - Collaborator permission. I - Inferred permission.
        cDocLink3.Visibility = 'AllUsers';//AllUsers, InternalUsers, SharedUsers
        insert cDocLink3;
        
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