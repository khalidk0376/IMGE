/*
*Created By Rajesh Girikon
*Date :2/3/2017 
*@Discription - Code coverage for "AttachAggrement" class 
*Code Coverage : 93%
*Modified by Shiv raghav for bk-bk-14852
*/

@isTest
public class AttachAggrement_test {
    // For contracts
    static testMethod void unitTest(){
        User u = [select id, firstname from user where profile.name = 'System Administrator' and isActive= true limit 1];
        System.RunAs(u){
            Pricebook2 pb=new Pricebook2(Name='TestPricebook');
            insert pb;   
            Event_Series__c es = new Event_Series__c();
            es.Name='testt';
            es.Package_Identifier__c='test';
            es.Event_Edition_Pool__c = 'WOC';
            insert es;
            
            Event_Edition__c Mapee = new Event_Edition__c(Name = 'World of Concrete 2017',Tab1__c='Test 1',Tab7__c='Test 7',Part_of_Series__c=es.id, Payment_Schedule__c = '50-50',cutoff_date_1__c = date.today(),Approval_Service_Now_ID__c = '123', CurrencyIsoCode = 'USD',End_Date__C =date.today()+7, Event_Code__c = 'KDB,KDB2', Booth_Type__c = 'Island,Corner,Inline,Custom,Peninsula', No_Of_Corner__c = '0,1,2,3,4', Booth_Size__c = '100 SqFt,400 SqFt,900 SqFt,1600 SqFt,2500 SqFt');
            insert Mapee;
            
            
            Event_Edition__c ee = new Event_Edition__c();
            ee.Name='test';
            ee.Part_of_Series__c=es.Id;
            ee.Tab1__c='ttttt';
            ee.Tab7__c='yyyyyy';
            ee.Event_Edition_Code__c = 'Abc';
            ee.Event_Price_Book__c=pb.Id;
            ee.Payment_Schedule__c = '50-50';
            ee.CutoffDate_1__c = date.today();
            ee.CutoffDate_2__c = date.today();
            ee.CutoffDate_3__c = date.today();
            ee.Cutoff_Date_1__c = date.today();
            ee.Cutoff_Date_3__c = date.today();
            ee.Cutoff_Date_2__c = date.today();
            ee.Mapped_Online_Event__c = Mapee.id;
            insert ee;
            
            Account oacc = new Account (Name = 'Test');
            insert oacc ;
            Contact ocontact = new Contact(LastNAme = 'test', Email = 'anbcd@gmail.com',AccountId=oacc.Id);
            insert ocontact; 
            
            Opportunity Onlineopp = new opportunity(name = 'test', closeDate = Date.Today(), EventEdition__c=Mapee.Id, StageName = 'Contract Sent', AccountId = oacc.id, Opportunity_Contact__c = ocontact.id,Status__c = 'Online Booth Form In Review' , Manual_Contract__c = true);
            insert Onlineopp;
            
            Opportunity opp = new opportunity(name = 'test', closeDate = Date.Today(), Online_Opportunity__c =Onlineopp.id,  EventEdition__c=ee.Id, StageName = 'Contract Sent', AccountId = oacc.id, Opportunity_Contact__c = ocontact.id,Status__c = 'Online Booth Form In Review' , Manual_Contract__c = true);
            insert opp;
            
            System.assertEquals('test', opp.name , 'This test method is failed');
            opp.StageName = 'Contract Sent' ;
            opp.Type = 'New';
            opp.Do_not_activate_Billing__c = true;
            Update opp;
            Agreement__c oaggre = new Agreement__c(name='test',opportunity__c = opp.id);
            insert oaggre;
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
            cDocLink.LinkedEntityId = oaggre.id;//Add attachment parentId
            cDocLink.ShareType = 'V';//V - Viewer permission. C - Collaborator permission. I - Inferred permission.
            cDocLink.Visibility = 'AllUsers';//AllUsers, InternalUsers, SharedUsers
            insert cDocLink;
            Agreement__c oaggre1 = new Agreement__c(name='test1',opportunity__c = opp.id);
            insert oaggre1;
            ApexPages.currentPage().getParameters().put('id',opp.id);
            ApexPages.StandardController sc = new ApexPages.StandardController(opp);
            AttachAggrement  oAttachAgreement = new AttachAggrement(sc);
            oAttachAgreement.fileName='test';                        
            oAttachAgreement.hasPartner = true;
            oAttachAgreement.fileBody=b3;
            oAttachAgreement.Savedoc();
            oAttachAgreement.canceldoc();
        }        
    }
    static testMethod void unitTest2(){
        User u = [select id, firstname from user where profile.name = 'System Administrator' and isActive= true limit 1];
        System.RunAs(u){
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
            ee.Review_by_Sales_Ops_Team__c = true;
            insert ee;


            Account oacc = new Account (Name = 'Test');
            insert oacc ;

            Contact ocontact = new Contact(LastNAme = 'test', Email = 'anbcd@gmail.com',AccountId=oacc.Id);
            insert ocontact; 

            Opportunity opp = new opportunity(name = 'test', closeDate = Date.Today(), EventEdition__c=ee.Id, StageName = 'Contract Sent', AccountId = oacc.id, Opportunity_Contact__c = ocontact.id,Status__c = 'Online Booth Form In Review' , Manual_Contract__c = true);
            insert opp;
            System.assertEquals('test', opp.name , 'This test method is failed');

            opp.StageName = 'Customize';
            opp.Status__c = 'Accounting Rejected';
            opp.Type = 'New Business';
            update opp;
            Agreement__c oaggre = new Agreement__c(name='test',opportunity__c = opp.id);
            insert oaggre;
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
            cDocLink.LinkedEntityId = oaggre.id;//Add attachment parentId
            cDocLink.ShareType = 'V';//V - Viewer permission. C - Collaborator permission. I - Inferred permission.
            cDocLink.Visibility = 'AllUsers';//AllUsers, InternalUsers, SharedUsers
            insert cDocLink;
            Agreement__c oaggre1 = new Agreement__c(name='test1',opportunity__c = opp.id);
            insert oaggre1;

            ApexPages.currentPage().getParameters().put('id',opp.id);
            ApexPages.StandardController sc = new ApexPages.StandardController(opp);
            AttachAggrement  oAttachAgreement = new AttachAggrement(sc);
            oAttachAgreement.fileName='test';           
            oAttachAgreement.hasPartner = true;
            oAttachAgreement.fileBody=b3;
            oAttachAgreement.Savedoc();
            oAttachAgreement.canceldoc();
        }        
    }
}