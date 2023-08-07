/**
* File:        UploadedFiles_Trig
* Project:     Informa Markets
* Date:         15-10-2020
* Test Class : UploadedFiles_Test
* Created By:  Rajesh Kumar
* *************************************************************************
* Description: For Quote Attachments [Creating Documents and attaching attachments for Manual Contract Process : COnverting code from Attachment trigger.
* *************************************************************************

* History: * History:BK- 5975  - Additional Document add in docusign process - By Rajesh Kr.
* Modified by Shiv raghav for bk-bk-14852

*/

public without sharing class UploadedFiles_Trig implements TriggerInterface_ContentDocumentLink.Runnable{
    public map<id,ContentDocumentLink> atchStatMap = new map<id,ContentDocumentLink>();
    public map<id,ContentDocumentLink> atchQuoteMap = new map<id,ContentDocumentLink>();
    public map<id,id> mapEventAttach = new map<id,id>();
    List<Event_Edition__c> objEvntlst = new List<Event_Edition__c>();
    public set <id> setids = new set<id>();
    public set<Id> quoteSet=new set<Id>();
    public set <id> parentIdsSet = new set<id>();
    public map<id,id> statOppIdsMap = new map<id,id>();
    public List < ContentDocumentLink > lstContentDocumentLink  = new List <ContentDocumentLink> ();
    public List < ContentDocumentLink > lstInsertContentDocumentLink  = new List <ContentDocumentLink> ();
    public List < SBQQ__QuoteDocument__c> lstInsertQuoteDocument = new List < SBQQ__QuoteDocument__c> ();
    public List <ContentVersion> lstcontentversion = new List <ContentVersion> ();
    public List < agreement__c > lstAgreement = new List < agreement__c > ();
    
    public void run(TriggerInterface_ContentDocumentLink.Trig trig) {
        if(trig.isInsert){
            for (ContentDocumentLink ocontentDocLink :trig.newList) {               

                // For Status Object attachments
                if(string.valueof(ocontentDocLink.LinkedEntityId).startswith('a1D') ){ 
                    atchStatMap.put(ocontentDocLink.LinkedEntityId,ocontentDocLink);
                }
                // For Quote Object attachments
                if(string.valueof(ocontentDocLink.LinkedEntityId).startswith('a0j')){
                    atchQuoteMap.put(ocontentDocLink.LinkedEntityId,ocontentDocLink);
                }
                
                if(string.valueof(ocontentDocLink.LinkedEntityId).startswith('a1S')){                  
                    mapEventAttach.put(ocontentDocLink.LinkedEntityId,ocontentDocLink.ContentDocumentId);
                }
                
            }           
            
            //for signed status attachments
            for(dsfs__DocuSign_Status__c obj : [select id,Opportunity_Id__c,dsfs__Envelope_Status__c,Quote__r.SBQQ__Opportunity2__c,Quote__r.SBQQ__Opportunity2__r.Online_Opportunity__c,Quote__c from dsfs__DocuSign_Status__c where id IN  : atchStatMap.keyset()]){
                if(obj.dsfs__Envelope_Status__c == 'Completed'){                    
                    parentIdsSet.add(obj.id);                    
                    statOppIdsMap.put(obj.id,obj.Quote__r.SBQQ__Opportunity2__c);
                    //Modified by Shiv raghav for bk-bk-14852
                    if(obj.Quote__r.SBQQ__Opportunity2__r.Online_Opportunity__c != null) {
                        parentIdsSet.add(obj.Quote__r.SBQQ__Opportunity2__r.Online_Opportunity__c);
                        statOppIdsMap.put(obj.Quote__r.SBQQ__Opportunity2__r.Online_Opportunity__c,obj.Quote__r.SBQQ__Opportunity2__r.Online_Opportunity__c);
                    }
                    quoteSet.add(obj.Quote__c);
                }
            }
            //to attach note&Attmnt to newly ceated Quote Document by conga
            if (!quoteSet.isEmpty()){
                list<SBQQ__QuoteDocument__c> lstQuoteDocuments = [select id , SBQQ__Quote__c from SBQQ__QuoteDocument__c  where SBQQ__Quote__c In : quoteSet order by createddate DESC limit 1];
                if(!lstQuoteDocuments.isEmpty()){ 
                    lstContentDocumentLink = [SELECT Id, LinkedEntityId, ContentDocumentId, Visibility, ShareType FROM ContentDocumentLink  where LinkedEntityId IN : atchStatMap.keyset() ]; 
                    if (!lstContentDocumentLink.isEmpty()){
                        for(ContentDocumentLink objContentDocumentLink : lstContentDocumentLink){
                            setids.add(objContentDocumentLink.ContentDocumentId);
                        }       
                        lstcontentversion = [SELECT Id, Title, PathOnClient, VersionData, OwnerId, ContentDocumentId FROM ContentVersion where ContentDocumentId IN: setids  Order By LastModifiedDate Desc LIMIT 1 ];
                        String sLabel = System.Label.Global_Exhibitions_User_Name;
                        String sUserId = [select id from user where Name =:sLabel Limit 1].Id;
                        if (!lstcontentversion.isEmpty() && lstcontentversion[0].Title.contains('Signed')){
                            for (ContentVersion ocontentver : lstcontentversion ){
                                for(id Ids :parentIdsSet){
                                    Agreement__c objAgree = new Agreement__c();
                                    objAgree.name = ocontentver.Title.removeEnd('.pdf');
                                    objAgree.Opportunity__c = statOppIdsMap.get(Ids);
                                    if(String.IsNotBlank(sUserId)){
                                        objAgree.CreatedById = sUserId;                        
                                        objAgree.LastModifiedById = sUserId;
                                    } else {
                                        objAgree.CreatedById = Userinfo.getUserId();
                                        objAgree.LastModifiedById = Userinfo.getUserId();
                                    }
                                    lstAgreement.add(objAgree);
                                }
                            }
                            if (!lstAgreement.isEmpty()){
                                insert lstAgreement;
                                //After saved the Content Verison, get the ContentDocumentId
                                Id conDocument = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:lstcontentversion[0].Id].ContentDocumentId;
                                for (SBQQ__QuoteDocument__c oQuoteDocument : lstQuoteDocuments){
                                    oQuoteDocument.SBQQ__AttachmentId__c = conDocument;
                                    ContentDocumentLink cDocLink = new ContentDocumentLink();
                                    cDocLink.ContentDocumentId = conDocument;//Add ContentDocumentId
                                    cDocLink.LinkedEntityId = oQuoteDocument.Id;//Add attachment parentId
                                    cDocLink.ShareType = 'V';//V - Viewer permission. C - Collaborator permission. I - Inferred permission.
                                    cDocLink.Visibility = 'AllUsers';//AllUsers, InternalUsers, SharedUsers
                                    lstInsertContentDocumentLink.add(cDocLink);
                                }
                                for (SBQQ__QuoteDocument__c oQuoteDocument : lstQuoteDocuments){
                                    oQuoteDocument.SBQQ__AttachmentId__c = conDocument;
                                    ContentDocumentLink cDocLink = new ContentDocumentLink();
                                    cDocLink.ContentDocumentId = conDocument;//Add ContentDocumentId
                                    cDocLink.LinkedEntityId = oQuoteDocument.SBQQ__Quote__c;//Add attachment parentId
                                    cDocLink.ShareType = 'V';//V - Viewer permission. C - Collaborator permission. I - Inferred permission.
                                    cDocLink.Visibility = 'AllUsers';//AllUsers, InternalUsers, SharedUsers
                                    lstInsertContentDocumentLink.add(cDocLink);
                                }
                                for (Agreement__c objAgre: lstAgreement) {
                                    ContentDocumentLink cDocLink = new ContentDocumentLink();
                                    cDocLink.ContentDocumentId = conDocument;//Add ContentDocumentId
                                    cDocLink.LinkedEntityId = objAgre.id;//Add attachment parentId
                                    cDocLink.ShareType = 'V';//V - Viewer permission. C - Collaborator permission. I - Inferred permission.
                                    cDocLink.Visibility = 'AllUsers';//AllUsers, InternalUsers, SharedUsers
                                    lstInsertContentDocumentLink.add(cDocLink);
                                }
                                insert lstInsertContentDocumentLink;
                            }
                            update lstQuoteDocuments;
                        }
                    }
                }
            }
            // For Quote Attachments [Creating Documents and attaching attachments for Manual Contract Process]
            if( atchQuoteMap.keySet().size () > 0 ){
                lstContentDocumentLink = [SELECT Id, LinkedEntityId, ContentDocumentId, Visibility, ShareType FROM ContentDocumentLink  WHERE LinkedEntityId IN : atchQuoteMap.keyset() ]; 
                if (!lstContentDocumentLink.isEmpty()){
                    for(ContentDocumentLink objContentDocumentLink : lstContentDocumentLink){
                        setids.add(objContentDocumentLink.ContentDocumentId);
                    }       
                    lstcontentversion = [SELECT Id, Title, PathOnClient, VersionData, OwnerId, ContentDocumentId FROM ContentVersion where ContentDocumentId IN: setids  Order By LastModifiedDate Desc LIMIT 1 ];
                    if (!lstcontentversion.isEmpty() && lstcontentversion[0].Title.contains('Manual')){
                        for (ContentVersion ocontentver : lstcontentversion ){
                            for(string qtId : atchQuoteMap.keyset()){
                                SBQQ__QuoteDocument__c objDoc = new SBQQ__QuoteDocument__c();
                                objDoc.Name = 'Doc-'+ocontentver.Title ;
                                objDoc.SBQQ__AttachmentId__c =ocontentver.ContentDocumentId;
                                objDoc.SBQQ__Quote__c = qtId;
                                if(ocontentver.Title.contains('Quote')){
                                    
                                    objDoc.SBQQ__Template__c = 'Quote';
                                }
                                else{
                                    objDoc.SBQQ__Template__c = 'Contract';
                                }
                                objDoc.Manual__c = true;
                                lstInsertQuoteDocument.add(objDoc);
                            }
                        }
                    }
                    
                    if(!lstInsertQuoteDocument.isEmpty()){
                        insert lstInsertQuoteDocument;
                        //After saved the Content Verison, get the ContentDocumentId
                        Id conDocument = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:lstcontentversion[0].Id].ContentDocumentId;
                        for (SBQQ__QuoteDocument__c oaddFileinQDoc: lstInsertQuoteDocument) {
                            ContentDocumentLink cDocLink = new ContentDocumentLink();
                            cDocLink.ContentDocumentId = conDocument;//Add ContentDocumentId
                            cDocLink.LinkedEntityId = oaddFileinQDoc.id;//Add attachment parentId
                            cDocLink.ShareType = 'V';//V - Viewer permission. C - Collaborator permission. I - Inferred permission.
                            cDocLink.Visibility = 'AllUsers';//AllUsers, InternalUsers, SharedUsers
                            lstInsertContentDocumentLink.add(cDocLink);
                        }
                        insert lstInsertContentDocumentLink;
                    }
                }
            }

        }

        else if (trig.isDelete){            
            for (ContentDocumentLink ocontentDocLink :trig.oldList) {                   
                if(string.valueof(ocontentDocLink.LinkedEntityId).startswith('a1S')){                   
                    mapEventAttach.put(ocontentDocLink.LinkedEntityId,ocontentDocLink.ContentDocumentId);
                }
            }
        }
        
        if (mapEventAttach.size() > 0){
            try
            {               
                List<Event_Edition__c> lstEventEdition = [SELECT ID, Name, Event_Edition_Image_URL__c FROM Event_Edition__c WHERE ID IN : mapEventAttach.keyset()];                
                
                if (trig.isInsert && lstEventEdition.size() > 0){                
                    for(Event_Edition__c obj : lstEventEdition){                     
                        obj.Event_Edition_Image_URL__c = mapEventAttach.get(obj.id);                     
                        objEvntlst.add(obj);
                    }                
                }
                else if (trig.isDelete && lstEventEdition.size() > 0){
                    List<ContentDocumentLink> lstAttachments = [SELECT  ContentDocument.createddate ,ContentDocumentId, Id FROM ContentDocumentLink WHERE LinkedEntityId = :mapEventAttach.keyset() AND IsDeleted = false order by SystemModstamp DESC limit 1];
                    for(Event_Edition__c obj : lstEventEdition){ 
                        if (lstAttachments.size() > 0){
                            obj.Event_Edition_Image_URL__c = lstAttachments[0].ContentDocumentId;                     
                            objEvntlst.add(obj);
                        }
                        else {
                            obj.Event_Edition_Image_URL__c = '';                     
                            objEvntlst.add(obj);
                        }
                    }               
                }
                if(objEvntlst.size()> 0 ){                   
                    update objEvntlst;
                }
            }
            catch(Exception ex){
                System.debug('Exception is Comming : ' + ex.getMessage());
            }
        }                
    }    
}