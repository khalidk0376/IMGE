/**
 * Created/Modified By: Girikon(Archit)
 * Created On:          10/13/2017
 * Description/Purpose: This test class covers the apex class : CustomerProfileProductListingEditCtrl 
 * Methods:             unitTest
 * Apex Class:          CustomerProfileProductListingEditCtrl 
 **/

@isTest
public class CustomerProfileProductListingEdit_Test 
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
        
        System.assertEquals(con.AccountId,acc1.id,'Contact Account Id');
        
        Exhibitor_Product_Listing__c oExDoc = new Exhibitor_Product_Listing__c();
        oExDoc.name = 'TestoExDoc';
        oExDoc.Event_Edition__c = OEve.id;
        oExDoc.ExpocadBooth__c=oEB.id;
        //oExDoc.Account__c = acc1.id;
        oExDoc.Contact__c=con.id;
        insert oExDoc;
        
        System.assertEquals(oExDoc.Event_Edition__c,OEve.id,'Event Edition');
        System.assertEquals(oExDoc.ExpocadBooth__c,oEB.id,'Expo cad booth');
        //System.assertEquals(oExDoc.Account__c,acc1.id,'Exhibitor Account');
        System.assertEquals(oExDoc.Contact__c,con.id,'Exhibitor contact');
        
        /*Attachment attach=new Attachment();       
        attach.Name='UnitTestAttachment.pdf';
        Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
        attach.body=bodyBlob;
        attach.parentId=oExDoc.id;
        //insert attach;*/
        Attachment attach=new Attachment();
        
        AllowedImageTypes__c oAllType = new AllowedImageTypes__c(name='pdf');
        insert oAllType;
        
        ApexPages.currentPage().getParameters().put('pId',oExDoc.id);
        ApexPages.currentPage().getParameters().put('eventId',OEve.id);
        ApexPages.currentPage().getParameters().put('check','true');
        ApexPages.currentPage().getParameters().put('found','false');
        MAP<string, string> testMap = new MAP<string, string>();
        testMap.put('found','false');
           
        Test.StartTest();
        CustomerProfileProductListingEditCtrl obj = new CustomerProfileProductListingEditCtrl();
        obj.sMessage = '';
        obj.productId = '';
        obj.eventEdition ='';
        obj.ExpocadBooth ='';
        obj.Account ='';
        obj.imageId ='';
        obj.Att =attach;
        obj.fileName ='UnitTestAttachment.jpg';
        obj.saveProductList();
        obj.fileName ='';
        obj.saveProductList();
        obj.fileName ='UnitTestAttachment.pdf';
        obj.Photo =Blob.valueOf('Unit Test Attachment Body');
        obj.saveProductList();
        obj.Cancel();
        Test.StopTest();
    }
}