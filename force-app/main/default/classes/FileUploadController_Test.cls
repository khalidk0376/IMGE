@isTest
public class FileUploadController_Test {
    static testmethod void fileUploadControllerTest(){  
        Account acc= new Account();
        acc.Name='Adarsh';
        insert acc;
        System.assertEquals('Adarsh', acc.Name, 'Hello Test Method is Failed');
        Contact oCon = new Contact(LastName='ContTest1', Email='test1contact@duptest.com', AccountId = acc.Id, MailingStreet = 'Test',MailingCity ='Test',MailingState='',MailingCountry='India');
        insert oCon;
        
        Attachment attmnt = new Attachment();
        
        Blob b = Blob.valueOf('Test Data');
        Blob data = Blob.valueOf('Test base64Data Data');
        attmnt.IsPrivate = true;
        attmnt.ContentType = 'application/pdf';
        attmnt.Name = 'Test attachment';
        attmnt.ParentId = oCon.Id;
        attmnt.Body = b;
        insert attmnt;
        
        Attachment attmnt1 = new Attachment();
        
        Blob b1 = Blob.valueOf('Test Data');
        Blob data1 = Blob.valueOf('Test base64Data Data');
        attmnt1.IsPrivate = true;
        attmnt1.ContentType = 'application/pdf';
        attmnt1.Name = 'Test attachment';
        attmnt1.ParentId = oCon.Id;
        attmnt1.Body = b;
        insert attmnt1;
        
        Test.startTest();
        
        Id parentId = attmnt.ParentId;
        String base64Data= EncodingUtil.base64Encode(data);
        Id attId = attmnt.Id;
        String fileName = 'Test file';
        String contentType = attmnt.ContentType;
        Boolean privateCheck = attmnt.IsPrivate;
        String attBody = EncodingUtil.base64Encode(attmnt.Body);
        
        Id attId1 = attmnt1.Id;
        Id parentId1 = attmnt1.ParentId;
        String fileName1 = 'Test file';
        String attBody1 = EncodingUtil.base64Encode(attmnt1.Body);
        Boolean privateCheck1 = attmnt.IsPrivate;
        
        FileUploadController_class.saveChunk(parentId, fileName, base64Data, contentType, attmnt1.Id);
        FileUploadController_class.getAttachments(parentId,1,10);
        FileUploadController_class.getAttachmentDel(attId);
        FileUploadController_class.EditData(attId1 , parentId1 ,privateCheck1);
        Test.stopTest();
    }
}