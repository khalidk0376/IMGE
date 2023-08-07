/**
* Project:     GAP
* Date:        25/04/2019
* Created By:  Rajesh Kumar
* Class:  addDeleteNotesController_class
* Modified By : Rajesh kumar Yadav Bk-3751
  Modified by : shiv Raghav Sharna - Bk-19031 (Change functionality from notes to enhance notes)
*/

@isTest
public class AddDeleteNotesController_class_test {

    public static List <String> noteLst = new List<String>();
    static testmethod void addDeleteNotesController_class(){
        
        Account acc= new Account();
        acc.Name='Adarsh';
        insert acc;
        system.assertEquals(acc.Name, 'Adarsh', 'Both values are same.');
        
        Contact oCon = new Contact(LastName='ContTest1', Email='test1contact@duptest.com', AccountId = acc.Id, MailingStreet = 'Test',MailingCity ='Test',MailingState='',MailingCountry='India');
        insert oCon;
        
        ContentNote noteRecord = new ContentNote();
        noteRecord.Title   = 'TestNotes';
        noteRecord.Content = Blob.valueOf('Test Body');
        insert noteRecord;
        
        ContentDocumentLink link = new ContentDocumentLink();
        link.ContentDocumentId   = noteRecord.id;
        link.LinkedEntityId      = oCon.Id;
        link.ShareType           = 'V';
        link.Visibility          = 'InternalUsers';
        insert link;
        
        system.assertEquals(noteRecord.Title, 'TestNotes', 'Both values are same.');
        
        ContentNote noteRecord1 = new ContentNote();
        noteRecord1.Title   = 'TestNotes';
        noteRecord1.Content = Blob.valueOf('Test Body');
        insert noteRecord1;
      
        system.assertEquals(noteRecord1.Title, 'TestNotes', 'Equals');
        
        Id parent = oCon.Id;
        String title = noteRecord.Title;
        blob body = noteRecord.Content;
        Boolean privat = False;
        
        addDeleteNotesController_class.saveData(title,body,privat,parent);
        
        noteRecord.Content = Blob.valueOf('Test Body11');
        update noteRecord;
        
        Id noteId = noteRecord.Id;
        Id noteId1 = noteRecord1.Id;
        Test.startTest();
            
        noteLst.add(noteId);
        noteLst.add(noteId1);
        addDeleteNotesController_class.EditData(title,body,noteId);
        addDeleteNotesController_class.deleteNotes(noteId);
        addDeleteNotesController_class.delSlctRec(noteLst);
        addDeleteNotesController_class.getNoteData(parent, 1, 10);
        
        Test.stopTest();	
    }
}