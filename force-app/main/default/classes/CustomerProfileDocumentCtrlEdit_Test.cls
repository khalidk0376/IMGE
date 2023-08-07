/**
 * Created/Modified By: Girikon(Archit)
 * Created On:          10/13/2017
 * Description/Purpose: This test class covers the apex class : CustomerProfileDocumentCtrlEdit
 * Methods:             unitTest
 * Apex Class:          CustomerProfileDocumentCtrlEdit
 **/

@isTest
public class CustomerProfileDocumentCtrlEdit_Test 
{
    static testMethod void unitTest() 
    {       
        ExpocadBooth__c expBooth = new ExpocadBooth__c(Booth_Number__c='1234',Booth_Logo_Id__c='testId111',Status__c='Rented');
        insert expBooth;
        
        Event_Edition__c eventEdition = new Event_Edition__c(Name='World of Concrete 2017',Event_Code__c='WOC17',End_Date__c=System.Today(),Start_Date__c=System.Today(),Payment_Schedule__c='10-40-50',X50_Cutoff_Date__c=Date.today(),Cutoff_Date_1__c=Date.today(),Cutoff_Date_2__c=Date.today(),CutoffDate_3__c=Date.today());
        insert eventEdition;
        System.assertEquals(eventEdition.Event_Code__c,'WOC17', 'Event Code');
        EventCurrecies__c eventCurrency = new EventCurrecies__c (Name='USD',Event_Edition__c=eventEdition.id);
        insert eventCurrency;
        System.assertEquals(eventCurrency.Name,'USD', 'Event Currency');
        eventEdition.EventCurrency__c = eventCurrency.id;
        update eventEdition;
        System.assert(eventEdition.EventCurrency__c != null, 'Event Currency');
        
        Account acc1 = new Account();
        acc1.Name='acc1';
                     
        insert acc1;
        
        Contact con = new Contact(LastName='User',FirstName ='Test',AccountId=acc1.id);
        insert con;
        
        Exhibiting_Document__c oExDoc = new Exhibiting_Document__c();
        oExDoc.name = 'TestoExDoc';
        oExDoc.Event_Edition__c = eventEdition.id;
        oExDoc.ExpocadBooth__c=expBooth.id;
        //oExDoc.Account__c = acc1.id;
        oExDoc.Contact__c=con.id;
        insert oExDoc;
        Blob b3 = Blob.valueOf('Test Data record');
        ContentVersion cVersion = new ContentVersion();
        cVersion.ContentLocation = 'S'; //S-Document is in Salesforce. E-Document is outside of Salesforce. L-Document is on a Social Netork.
        cVersion.PathOnClient = 'Complete.pdf';//File name with extention
        cVersion.Origin = 'H';//C-Content Origin. H-Chatter Origin.
        cVersion.OwnerId = userinfo.getUserId();//Owner of the file
        cVersion.Title ='Completed';//Name of the file
        cVersion.VersionData = b3;//File content
        insert cVersion;
        Id conDocument = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cVersion.Id].ContentDocumentId;
        ContentDocumentLink cDocLink = new ContentDocumentLink();
        cDocLink.ContentDocumentId = conDocument;//Add ContentDocumentId
        cDocLink.LinkedEntityId =  oExDoc.id;//Add Files parentId
        cDocLink.ShareType = 'V';//V - Viewer permission. C - Collaborator permission. I - Inferred permission.
        cDocLink.Visibility = 'AllUsers';//AllUsers, InternalUsers, SharedUsers
        insert cDocLink;
        AllowedImageTypes__c oAllImg = new AllowedImageTypes__c(name='.img');
        insert oAllImg;
        
        Event_Settings__c eset = new Event_Settings__c();
        eset.Name ='event Setting Test';
        eset.Event_Edition__c = eventEdition.Id;
        insert eset;
        
        ApexPages.currentPage().getParameters().put('docId',oExDoc.id);
        ApexPages.currentPage().getParameters().put('eventId',eventEdition.id);
        ApexPages.currentPage().getParameters().put('check','false');
        ApexPages.currentPage().getParameters().put('found','false');
        
        Test.StartTest();
        CustomerProfileDocumentCtrlEdit obj = new CustomerProfileDocumentCtrlEdit();
        obj.fileName ='test.pdf';
        obj.photo =Blob.valueof('adfgdsfgasdfgsadfgsda');
        obj.saveDocument();
        obj.fileName ='test.img';
        obj.saveDocument();        
        Test.StopTest();
    }
}