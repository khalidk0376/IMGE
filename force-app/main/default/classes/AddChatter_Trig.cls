/**
* File:        AddChatter_Trig.cls
* Project:     GAP
* Created Date: 14/05/2019
* Created By:  Rajesh Kumar
* Modified By:  Rajesh Kumar
* Test Class: AddChatter_Test
* Coverage: 
*
* *************************************************************************
* @description This class is using in "WorkOrderTriggerMerge" Trigger.
* *************************************************************************
* History:Ticket :GGCkB-76, Adarsh:BK-2701
* Last Modified :BK-10856 Rajesh Kumar Yadav
*/


public without sharing class AddChatter_Trig implements TriggerInterface_WorkOrder.Runnable {
    
    private list<EntitySubscription> eslist  = new list<EntitySubscription>();
    private set<Id> oppids = new set<Id>();
    private set<Id> setWoOwnerId = new set<Id>();
    private Integer sizeofEntitySubscription  = 0;
    //private list<Attachment > lstAttachmentInsert   = new list<Attachment >();
	public List < ContentDocumentLink > lstContentDocumentLink  = new List <ContentDocumentLink> ();
	public List < ContentDocumentLink > lstInsertContentDocumentLink  = new List <ContentDocumentLink> ();
    public void run(TriggerInterface_WorkOrder.Trig trig) {
        
        if (trig.isInsert && trig.isAfter){
            for(WorkOrder wo : trig.newList){
                oppids.add(wo.Opportunity__c);
                setWoOwnerId.add(wo.OwnerId); 
            }
            /*Changes done regarding Ticket No: BK-2701	START*/ 
            List<EntitySubscription> eSListToDelete = new List<EntitySubscription>([SELECT id FROM EntitySubscription WHERE SubscriberId IN: setWoOwnerId AND ParentId IN (SELECT Id FROM WorkOrder) Order by CreatedDate asc LIMIT 5000]);
            if (setWoOwnerId.Size() > 0){
                try{
                    if (eSListToDelete.size() < 500) {
                        for(WorkOrder wo : trig.newList){
                            EntitySubscription es = new EntitySubscription();
                            es.ParentId = wo.Id;
                            es.SubscriberId = wo.OwnerId;
                            eslist.add(es);
                        }
                    }
                    
                    else if (eSListToDelete.size() >= 500) {If(!eSListToDelete.isEmpty()) { Delete eSListToDelete; }for(WorkOrder wo : trig.newList){ EntitySubscription es = new EntitySubscription();es.ParentId = wo.Id;es.SubscriberId = wo.OwnerId;eslist.add(es);
                        }
                    }
                    if (!eslist.isEmpty() && !Test.isRunningTest()){ insert eslist; }  
                    /*Changes done regarding Ticket No: BK-2701	STOP*/
                }
                catch(Exception exp){
                    System.debug('Cause of Exception is:' + exp.getCause() + 'Exception at line number:' + exp.getLineNumber());
                }
            }
            //Create Attachment in newly created work order.
            if (oppids.size() > 0){
				List<Agreement__c> lstAgreement = new List<Agreement__c>();
				Set<Id> ids = new Set<Id>();
				lstAgreement = [Select Id from Agreement__c Where Opportunity__c IN : oppids];
				for (Agreement__c oAgreement : lstAgreement ){
					ids.add(oAgreement.Id);
				}
				if (ids.size() > 0){
					lstContentDocumentLink = [ SELECT Id, LinkedEntityId, ContentDocumentId, Visibility, ShareType FROM ContentDocumentLink  WHERE LinkedEntityId IN : ids ]; 
					if (!lstContentDocumentLink.isEmpty()){
						for(WorkOrder wo : trig.newList){
							for(ContentDocumentLink objContentDocumentLink : lstContentDocumentLink){
								ContentDocumentLink cDocLink = new ContentDocumentLink();
								cDocLink.ContentDocumentId = objContentDocumentLink.ContentDocumentId;//Add ContentDocumentId
								cDocLink.LinkedEntityId = wo.Id;//Add attachment parentId
								cDocLink.ShareType = 'V';//V - Viewer permission. C - Collaborator permission. I - Inferred permission.
								cDocLink.Visibility = 'AllUsers';//AllUsers, InternalUsers, SharedUsers
								lstInsertContentDocumentLink.add(cDocLink);
							} 
						}
					}
				}
                /*list<Attachment > listAttachments=[select id,name,body from Attachment where parentId IN (Select Id from Agreement__c Where Opportunity__c IN : oppids)]; 
                if (!listAttachments.isEmpty()){
                    for(WorkOrder wo : trig.newList){
                        for(Attachment att : listAttachments){
                            Attachment oAttachment = new Attachment();
                            oAttachment.parentid = wo.id;
                            oAttachment.Name = att.Name.contains('.pdf')? att.name:att.name+'.pdf';
                            oAttachment.Body = att.Body;
                            lstAttachmentInsert.add(oAttachment);
                        }          
                    }
                }*/
            }   
            if(!lstInsertContentDocumentLink.isEmpty()){
                insert lstInsertContentDocumentLink;
            }
        }
        //calling before delete event.
        if (trig.isDelete && trig.isBefore){
            //Diffrent user not able to delete work order.
            for(WorkOrder wo : trig.oldMap.values()){ 
                if(wo.OwnerID != UserInfo.getUserId()){
                    wo.adderror('You can only delete the record which is Owned by you.');
                }
            }
        }
    }
}