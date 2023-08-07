/**
* Project:     GAP
* Date:        25/04/2019
* Created By:  Rajesh Kumar
* Test Class:  addDeleteNotesController_class_test
* *************************************************************************
* @Description Note adding, editing and deleting funcationality in Account , Contact and Opportunity .
* *************************************************************************
* History:
  Modified by : shiv Raghav Sharna - Bk-19031 (Change functionality from notes to enhance notes)
*/

public with sharing class AddDeleteNotesController_class {
    
    @AuraEnabled
    public List<ContentNote> Listnote = new List<ContentNote>();
    @AuraEnabled
    public List<ContentNote> delRec = new List<ContentNote>();
    
    @AuraEnabled
    public static Id saveData (String Title , Blob Body , Boolean IsPrivate, Id ParentId ){
        
        ContentNote noteRecord = new ContentNote();
        noteRecord.Title   = Title;
        noteRecord.Content = body;//Blob.valueOf(body.escapeHTML4());
        insert noteRecord;
        ContentDocumentLink link = new ContentDocumentLink();
        link.ContentDocumentId   = noteRecord.id;
        link.LinkedEntityId      = ParentId;
        link.ShareType           = 'V';
        link.Visibility          = 'InternalUsers';
        insert link;
        return noteRecord.id;
    }
    
    @AuraEnabled
    public static Id EditData (String Title , Blob Body , Id NoteId){
        ContentNote editNotes = [Select Title, Content,Id from ContentNote where Id=:NoteId];        
        editNotes.Title = Title;
        editNotes.Content = Body;
        update editNotes;
        return editNotes.Id;     
    }
    
   
    
    @AuraEnabled
    public static void deleteNotes (Id DelNote){
        
        ContentNote deleteNote = [Select Title, Content, Id from ContentNote where Id=:DelNote];
        if(deleteNote != null){
            delete deleteNote;      
        }
    }
    
    @AuraEnabled
    public static void delSlctRec(String[] slctRec)
    {
        List<ContentNote> listnote=  [SELECT Id FROM ContentNote WHERE Id IN: slctRec];  
        if(listnote.size() > 0){
            delete listnote;
        }
    }
    
    @AuraEnabled
    public static NotesTableWrapper getNoteData(String ParentId, Decimal pageNumber, Decimal pageSize) {

        Integer pSize = (Integer)pageSize;
        Integer pNumber = (Integer)pageNumber;
        
        //Offset for SOQL
        Integer offset = (pNumber-1) * pSize;
        
        Set<Id> contentDocumentIds = new Set<Id>();
        //get all contentdocumentids so that you can query on contentnote
        for(ContentDocumentLink conDoc : [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId  =:ParentId]){
            contentDocumentIds.add(conDoc.ContentDocumentId);
        }
        
        //Total Records
        Integer totalRecords = [SELECT Count() from ContentNote where Id In: contentDocumentIds];//[SELECT COUNT() FROM Note where ParentId =: ParentId];
        Integer recordEnd = pSize * pNumber;
        
        //Instance of Contact DataTable Wrapper Class
        NotesTableWrapper objDT =  new NotesTableWrapper();  
        objDT.pageSize = pSize;
        objDT.pageNumber = pNumber;
        objDT.recordStart = offset + 1;
        objDT.recordEnd = totalRecords >= recordEnd ? recordEnd : totalRecords;
        objDT.totalRecords = totalRecords;
        
        
        //  ContentDocumentLink conDoc = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId  = :ParentId];
        List<ContentNote> cnt = [SELECT Id, Title,CreatedBy.Name,CreatedDate,Owner.name,LastModifiedDate,Content from ContentNote where Id In: contentDocumentIds ORDER By LastModifiedDate DESC LIMIT :pSize];
        objDT.notesList = new List<contenNoteWrapper>();
        for(ContentNote c : cnt){
            objDT.notesList.add(new contenNoteWrapper(c) );
        }
        
        //objDT.notesList = [SELECT id,Body,IsPrivate,Title,CreatedBy.Name,CreatedDate,Owner.name,ParentId,Parent.name,LastModifiedDate FROM Note WHERE ParentId =: ParentId ORDER By LastModifiedDate DESC LIMIT :pSize OFFSET :offset];
        return objDT;
    }
    
    public class contenNoteWrapper{
        @AuraEnabled
        public Id Id {get;set;}
        @AuraEnabled
        public String Title {get;set;}
        @AuraEnabled
        public String CreatedBy {get;set;}
        @AuraEnabled
        public DateTime CretaedDate{get;set;} 
        @AuraEnabled
        public String OwnerName {get;set;}
        @AuraEnabled
        public DateTime LatsModifiedDate {get;set;}
        @AuraEnabled
        public String Content {get;set;}
        
        contenNoteWrapper(ContentNote note){
            this.Id = note.id;
            this.Title = note.title;
            this.CreatedBy = note.CreatedBy.Name;
            this.CretaedDate = note.CreatedDate;
            this.OwnerName = note.Owner.Name;
            this.LatsModifiedDate = note.LastModifiedDate;
            this.Content = note.Content.toString().replaceAll('<[/a-zAZ0-9]*>','');
        }  
    }
    //Wrapper Class For Contact DataTable  
    public class NotesTableWrapper { 
        
        @AuraEnabled
        public Integer pageSize {get;set;}
        @AuraEnabled
        public Integer pageNumber {get;set;}
        @AuraEnabled
        public Integer totalRecords {get;set;}
        @AuraEnabled
        public Integer recordStart {get;set;}
        @AuraEnabled
        public Integer recordEnd {get;set;}
        @AuraEnabled
        public List<contenNoteWrapper> notesList {get;set;}
    }
}