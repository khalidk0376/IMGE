/**
* File:        tgr_AttachAgreement.tgr
* Project:     GAP
* Date:         8/9/2017
* Test Class : AddAttachmentFileTrigger_Test
* Created By:  Abdul kadir
* *************************************************************************
* Description: For Quote Attachments [Creating Documents and attaching attachments for Manual Contract Process
* *************************************************************************
* History:
Updated by : Abdul Qadir:(GCCW-1421) Add TAT(Turn Around Time) functionality.
* Modified by Palla Kishore on 29 Sep 2021 for ticket : BK-14823
*/
trigger tgr_AttachAgreement on Attachment (after insert) {
   
  if(trigger.isAfter && trigger.isInsert){
  AttachmentTriggerHandler.afterAttachmentInsert(trigger.new);
  
  }
   
}