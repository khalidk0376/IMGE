/**
 * Created/Modified By: Girikon(Archit)
 * Created On:          10/13/2017
 * Description/Purpose: This test class covers the apex class : CustomerProfileDocumentCtrl
 * Methods:             unitTest
 * Apex Class:          CustomerProfileDocumentCtrl
 **/

@isTest
public class CustomerProfileDocumentCtrl_Test 
{
    static testMethod void unitTest() 
    {       
        ExpocadBooth__c oEB = new ExpocadBooth__c(Booth_Number__c='1234',Booth_Logo_Id__c='testId111',Status__c='Rented');
        insert oEB;
        
        Event_Edition__c OEve = new Event_Edition__c(Name='World of Concrete 2017',Event_Code__c='WOC17',End_Date__c=System.Today(),Start_Date__c=System.Today(),Payment_Schedule__c='10-40-50',X50_Cutoff_Date__c=Date.today(),Cutoff_Date_1__c=Date.today(),Cutoff_Date_2__c=Date.today(),CutoffDate_3__c=Date.today());
        insert OEve;
        System.assertEquals(OEve.Event_Code__c,'WOC17', 'Event Code');
        EventCurrecies__c eventCurrency = new EventCurrecies__c (Name='USD',Event_Edition__c=OEve.id);
        insert eventCurrency;
        System.assertEquals(eventCurrency.Name,'USD', 'Event Currency');
        OEve.EventCurrency__c = eventCurrency.id;
        update OEve;
        System.assert(OEve.EventCurrency__c != null, 'Event Currency');
        
        Event_Settings__c eset = new Event_Settings__c();
        eset.Name ='event Setting Test';
        eset.Event_Edition__c = oEve.Id;
        insert eset;
        
        Account acc1 = new Account();
        acc1.Name='acc1';
         insert acc1;
        
        Contact con = new Contact(LastName='User',FirstName ='Test',AccountId=acc1.id);
        insert con;
        
        Exhibiting_Document__c oExDoc = new Exhibiting_Document__c();
        oExDoc.name = 'TestoExDoc';
        oExDoc.Event_Edition__c = OEve.id;
        oExDoc.ExpocadBooth__c=oEB.id;
        oExDoc.Contact__c=con.id;
        insert oExDoc;
        
        AllowedFileTypes__c oAllType = new AllowedFileTypes__c(name='FileTypes',Value__c='pdf');
        insert oAllType;
        
        ApexPages.currentPage().getParameters().put('DocId',oExDoc.id);
        ApexPages.currentPage().getParameters().put('eventId',OEve.id);
        ApexPages.currentPage().getParameters().put('expoId',oEB.id);
        ApexPages.currentPage().getParameters().put('conId',con.id);
        ApexPages.currentPage().getParameters().put('checkRender','true');
        
        Test.StartTest();
        CustomerProfileDocumentCtrl obj = new CustomerProfileDocumentCtrl();
        obj.attName ='UnitTestAttachment.jpg';
        obj.saveDocument();
        obj.attName ='UnitTestAttachment.pdf';
        obj.attBody =Blob.valueOf('Unit Test Attachment Body');
        obj.saveDocument();         
        Test.StopTest();
    }
}