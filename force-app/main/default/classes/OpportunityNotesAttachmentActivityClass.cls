/**
 * File:          OpportunityNotesAttachmentActivityClass
 * Project:       GAP
 * Date:          26/12/2018
 * Test Class :   OpportunityNotesAttachmentActivity_Test
 * Created By:    Yash Gupta
 * *************************************************************************
 * @Description: This class is used to insert either notes, attachments,activity or all of them on the basis of multiselect picklist i.e 
                "Copy Notes Attachment Activities" of opportunity.
                As per ticket no.GGCW-2768, I have inserted either notes, attachments,activity or all of them on the basis of multiselect picklist while cloning the opportunity.
 * *************************************************************************
 * History: Modified By Mukesh Gupta[LTN-7], Yesh Gupta[GGCW-2882] 
 * History: BK-3758 Modified By Rajesh Kumar - on 28-05-2020
 * History : BK-9736 Modified By Rajesh Kumar - on 26-10-2020
  */
global class OpportunityNotesAttachmentActivityClass {

    webservice static string oppNotesAttachActivity(String sOppId, String sPickVal, String sOppParentId) {
        /*
            @description: Variables Declaration.
        */
        String sPicklistVal = '';
        String sNoteQuery = '';
        String sAttachmentQuery = '';
        List<Note> lstNewOppNoteInsert = new List<Note>();
        List<Task> lstNewOppTaskInsert = new List<Task>();
        List <ContentVersion> lstcontentversion = new List <ContentVersion> ();
        List<ContentVersion > insertFiles = new List<ContentVersion >();
        List < ContentDocumentLink > lstInsertContentDocumentLink  = new List <ContentDocumentLink> ();
        /*
            @description: Validate Clone Opportunity Id as well as Parent Opportunity Id also split and assign multiselect picklist into string.
        */
        if(String.IsNotBlank(sOppId) && String.IsNotBlank(sOppParentId)){        
            List<String> lstIsPickVal = sPickVal.split(';'); //Activities;Attachment;Notes
            for(String str : lstIsPickVal){ 
                sPicklistVal =  sPicklistVal!=''?sPicklistVal+','+'\''+str+'\'':'\''+str+'\''; 
            }
            /*
                @description: Insert notes in clone opportunity.
            */
            
            if(sPicklistVal.contains('Notes')){
                sNoteQuery = 'select id, Title, Body, OwnerId, ParentId, IsPrivate from Note where ParentId = \''+String.escapeSingleQuotes(sOppParentId)+'\'';
                List<Note> lstParentNoteCheck = Database.Query(sNoteQuery);
                If(lstParentNoteCheck.size() > 0){
                    for(Note n: lstParentNoteCheck){
                        if(n.OwnerId != UserInfo.getUserId()) {
                            sNoteQuery += ' AND IsPrivate = False';                        
                        }
                    }
                }
                List<Note> lstParentNote = Database.Query(sNoteQuery);
                system.debug('sNoteQuery: '+sNoteQuery);
                if(lstParentNote.size() > 0){ 
                    for(Note noTe : lstParentNote){ 
                        Note nT = new Note();
                        nT.Title = noTe.Title;  
                        nT.Body = noTe.Body;
                        nT.IsPrivate = noTe.IsPrivate;
                        nT.OwnerId = noTe.OwnerId;
                        nT.ParentId = sOppId;
                        lstNewOppNoteInsert.add(nT);
                    }
                    if(lstNewOppNoteInsert.size () > 0){
                        insert lstNewOppNoteInsert; 
                    }
                }
                
                
                //Added by Mukesh Gupta
                List<ContentDocumentLink> cdlListToInsert = new List<ContentDocumentLink>();
                List<ContentDocumentLink> cdlList = [SELECT LinkedEntityId, ContentDocumentId, ShareType, Visibility, Id FROM ContentDocumentLink WHERE LinkedEntityId=:sOppParentId AND ContentDocument.FileTYpe='snote'];
                for(ContentDocumentLink cdl : cdlList){
                    cdlListToInsert.add(new ContentDocumentLink(LinkedEntityId = sOppId,ContentDocumentId=cdl.ContentDocumentId,ShareType=cdl.ShareType,Visibility=cdl.Visibility));
                }
                insert cdlListToInsert;
                //End
            }
            
            /*
                @description: Insert Attachment in clone opportunity.
            */

            if(sPicklistVal.contains('Files')){
                List<ContentDocumentLink> cdlListToInsert = new List<ContentDocumentLink>();
                List<ContentDocumentLink> cdlList = [SELECT LinkedEntityId, ContentDocumentId, ShareType, Visibility, Id FROM ContentDocumentLink WHERE LinkedEntityId=:sOppParentId AND ContentDocument.FileTYpe!='snote'];
                for(ContentDocumentLink cdl : cdlList){
                    cdlListToInsert.add(new ContentDocumentLink(LinkedEntityId = sOppId,ContentDocumentId=cdl.ContentDocumentId,ShareType=cdl.ShareType,Visibility=cdl.Visibility));
                }
                insert cdlListToInsert;
            }
            
            /*
                @description: Insert Activity in clone opportunity.
            */
            if(sPicklistVal.contains('Activities')){
                List<Task> lstParentTask = [select id, Subject, Status, OwnerId, WhoId, Priority, TaskSubtype, ActivityDate, WhatId from Task where WhatId=:sOppParentId];        
                if(lstParentTask.size() > 0){ 
                    for(Task tk : lstParentTask){ 
                        Task oTK = new Task();
                        oTK.Subject = tk.Subject;
                        oTK.Status = tk.Status;
                        oTK.OwnerId = tk.OwnerId;
                        oTK.Priority = tk.Priority;
                        oTK.TaskSubtype = tk.TaskSubtype;
                        oTK.ActivityDate = tk.ActivityDate;
                        oTK.WhatId = sOppId;
                        oTK.WhoId= tk.WhoId;
                        lstNewOppTaskInsert.add(oTK);
                    }
                    if(lstNewOppTaskInsert.size() > 0){
                       insert lstNewOppTaskInsert;
                    } 
                }    
            }
        }
        return 'Success';
    }
}