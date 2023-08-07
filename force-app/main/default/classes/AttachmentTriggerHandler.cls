/**
* Created By    :  Palla Kishore [BK-14823]
* Created On    :  29/09/2021
* @description  :  Moved from trigger to handler
* Trigger       :  tgr_AttachAgreement
* Modified By   :  
**/

public class AttachmentTriggerHandler {
public static void afterAttachmentInsert(list<Attachment> triggernew){
    map<id,Attachment> atchStatMap = new map<id,Attachment>();
    map<id,Attachment> atchOppMap = new map<id,Attachment>();
    map<id,Attachment> atchQuoteMap = new map<id,Attachment>();
    list < agreement__c > lstAgreement = new list < agreement__c > ();
    list < SBQQ__QuoteDocument__c> lstDocs = new List < SBQQ__QuoteDocument__c> ();
    list < attachment > lstAttachmentInsert = new List < Attachment > ();
    list < attachment > lstQuoteAttachment  = new List < Attachment > ();
    list < attachment > lstDocAttachmentInsert = new List < Attachment > ();
    set <id> qtIds = new set<id>();
    set <id> parentIdsSet = new set<id>();
    map<id,id> statOppIdsMap = new map<id,id>();
    set<Id> quoteSet=new set<Id>();

    for(Attachment attch : triggernew){
        // For Status Object attachments
        if(string.valueof(attch.parentid).startswith('a1D') ){ 
            atchStatMap.put(attch.parentid,attch);
        }
        
        // For Opportunity Object attachments
        if(string.valueof(attch.parentid).startswith('006')){
            atchOppMap.put(attch.parentid,attch);
        }
        
        // For Quote Object attachments
        if(string.valueof(attch.parentid).startswith('a0j')){
            atchQuoteMap.put(attch.parentid,attch);
        }
    }
    

    for(SBQQ__Quote__c objQt : [select id,Manual__c from SBQQ__Quote__c where id IN : atchQuoteMap.keyset()]){
        qtIds.add(objqt.id);
    }

    
    //for signed status attachments
    for(dsfs__DocuSign_Status__c obj : [select id,Opportunity_Id__c,dsfs__Envelope_Status__c,Quote__r.SBQQ__Opportunity2__c,Quote__c from dsfs__DocuSign_Status__c where id IN  : atchStatMap.keyset()]){
        if(obj.dsfs__Envelope_Status__c == 'Completed'){
            parentIdsSet.add(obj.id);
            statOppIdsMap.put(obj.id,obj.Quote__r.SBQQ__Opportunity2__c);
            quoteSet.add(obj.Quote__c);
        }
    }

    //to attach note&Attmnt to newly ceated Quote Document by conga
   list<SBQQ__QuoteDocument__c> lstQuoteDoc = [select id from SBQQ__QuoteDocument__c where SBQQ__Quote__c In : quoteSet order by createddate DESC limit 1];
   lstQuoteAttachment = [SELECT id, name,parent.name,LastModifiedDate,Body FROM Attachment WHERE parentId IN: atchStatMap.keySet() Order By LastModifiedDate Desc LIMIT 1 ];
        if(lstQuoteDoc.size() > 0 && lstQuoteAttachment[0].Name.contains('Signed')){
            for(SBQQ__QuoteDocument__c objqd : lstQuoteDoc){
            Attachment oAttachment = new Attachment();
            oAttachment.parentid = objqd.id;
            oAttachment.Name = lstQuoteAttachment[0].Name;
            oAttachment.Body = lstQuoteAttachment[0].Body;
            lstAttachmentInsert.add(oAttachment);
            objqd.SBQQ__AttachmentId__c=lstQuoteAttachment[0].id;
        }
        update lstQuoteDoc;
     }
    
    // For Quote Attachments [Creating Documents and attaching attachments for Manual Contract Process]
    if(atchQuoteMap.keyset().size()>0){
        lstQuoteAttachment =[SELECT id, name,parent.name,LastModifiedDate,Body FROM Attachment WHERE parentId IN: qtIds Order By LastModifiedDate Desc LIMIT 1 ];
        if(lstQuoteAttachment !=null && lstQuoteAttachment.size()>0 && (lstQuoteAttachment[0].Name.contains('Manual'))){
            for(id qtId : atchQuoteMap.keyset()){
                SBQQ__QuoteDocument__c objDoc = new SBQQ__QuoteDocument__c();
                objDoc.Name = 'Doc-'+lstQuoteAttachment[0].Name ;
                objDoc.SBQQ__AttachmentId__c =lstQuoteAttachment[0].id;
                objDoc.SBQQ__Quote__c = qtId;
                if(lstQuoteAttachment[0].Name.contains('Quote')){
                    
                    objDoc.SBQQ__Template__c = 'Quote';
                }
                else{
                    objDoc.SBQQ__Template__c = 'Contract';
                }
                objDoc.Manual__c = true;
                lstDocs.add(objDoc);
            }
        }
        
        if(lstDocs !=null && lstDocs.size()>0){
            insert lstDocs;
        }
        
        for (SBQQ__QuoteDocument__c objDocAtch: lstDocs) {
            Attachment oAttachment = new Attachment();
            oAttachment.parentid = objDocAtch.id;
            oAttachment.Name = lstQuoteAttachment[0].Name;
            oAttachment.Body = lstQuoteAttachment[0].Body;
            lstDocAttachmentInsert.add(oAttachment);
        }
        
        if (lstDocAttachmentInsert != null && lstDocAttachmentInsert.size() > 0) {
            insert lstDocAttachmentInsert;
        }
    }
    
    // For Oppty Attachments [Creating agreements and attaching signed docs]
    if(atchOppMap.keyset().size()>0){
        lstQuoteAttachment =[SELECT id, name,LastModifiedDate,Body FROM Attachment WHERE parentId IN: atchOppMap.keyset() AND name like '%Completed%' Order By LastModifiedDate Desc LIMIT 1 ];
        String sLabel = System.Label.Global_Exhibitions_User_Name;
        String sUserId = [select id from user where Name =:sLabel Limit 1].Id;        
        for(id opIds :atchOppMap.keySet()){
            if(lstQuoteAttachment !=null && lstQuoteAttachment.size()>0){
                Agreement__c objAgree = new Agreement__c();
                objAgree.name = 'Doc-'+ lstQuoteAttachment[0].Name;
                objAgree.Opportunity__c = opIds;
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
        
        if (lstAgreement != null && lstAgreement.size() > 0) {
            insert lstAgreement;
            
            if(lstQuoteAttachment !=null && lstQuoteAttachment.size()>0){
                for (Agreement__c objAgre: lstAgreement){
                    Attachment oAttachment = new Attachment();
                    oAttachment.parentid = objAgre.id;
                    oAttachment.Name = lstQuoteAttachment[0].Name;
                    oAttachment.Body = lstQuoteAttachment[0].Body;
                    lstAttachmentInsert.add(oAttachment);
                }
            }
        }
        
        
        
        if (lstAttachmentInsert != null && lstAttachmentInsert.size() > 0) {
            insert lstAttachmentInsert;
        }
    }
    
    // For Status Agreements [Creating Agreements and attaching signed Documents]
    if(statOppIdsMap.keyset().size()>0){
        lstQuoteAttachment =[SELECT id,parentId,name,LastModifiedDate,Body FROM Attachment WHERE parentId IN: statOppIdsMap.keyset() Order By LastModifiedDate Desc LIMIT 1 ];
        String name=lstQuoteAttachment[0].name;
        String sLabel = System.Label.Global_Exhibitions_User_Name;
        String sUserId = [select id from user where Name =:sLabel Limit 1].Id;
        for(id Ids :parentIdsSet){
            if(lstQuoteAttachment !=null && lstQuoteAttachment.size()>0 && name.contains('Signed')){
                Agreement__c objAgree = new Agreement__c();
                objAgree.name = lstQuoteAttachment[0].Name.removeEnd('.pdf');
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
            else{
                Attachment oAttachment = new Attachment();
                oAttachment.parentid = statOppIdsMap.get(Ids);
                oAttachment.Name = lstQuoteAttachment[0].Name;
                oAttachment.Body = lstQuoteAttachment[0].Body;
                lstAttachmentInsert.add(oAttachment);
            }
        }
        
        if (lstAgreement != null && lstAgreement.size() > 0) {
            insert lstAgreement;
        }
        
        if(lstQuoteAttachment !=null && lstQuoteAttachment.size()>0){
            for (Agreement__c objAgre: lstAgreement) {
                Attachment oAttachment = new Attachment();
                oAttachment.parentid = objAgre.id;
                oAttachment.Name = lstQuoteAttachment[0].Name;
                oAttachment.Body = lstQuoteAttachment[0].Body;
                lstAttachmentInsert.add(oAttachment);
            }
        }
        if (lstAttachmentInsert != null && lstAttachmentInsert.size() > 0) {
            insert lstAttachmentInsert;
        }
   }
  }
}