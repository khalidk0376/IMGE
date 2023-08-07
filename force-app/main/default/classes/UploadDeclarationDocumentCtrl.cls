/**
 * File:        UploadDeclarationDocumentCtrl.cls
 * Project:     GAP
 * Date:        14th March 2019
 * Created By:  Rajesh Kumar Yadav
 * *************************************************************************
 * @Description This class is used to upload declaration document from Opportunity.
 * *************************************************************************
 * History: Modified By Yash Gupta, As per ticket no [GGCKB-10]
 * Modified By Yash Gupta [10th April 2019], As per ticket no [GGCKB-27]
 */
 
public class UploadDeclarationDocumentCtrl{

    /**
    * currentRecordId
    * @description apex variable
    */
    public String currentRecordId   { get;set;  }

    /**
    * oAtachment
    * @description apex variable
    */
    public Attachment oAtachment    { get;set;  }

    /**
    * fileName
    * @description apex variable
    */
    public String fileName          { get;set;  }

    /**
    * fileBody
    * @description apex variable
    */
    public transient Blob fileBody  { get;set;  }

    /**
    * fileContentType
    * @description apex variable
    */
    public string fileContentType   { get;set;  }
    
    /**
    * sMessage
    * @description apex variable
    */
    public string sMessage          { get; set; }

    /**
    * accountUpdateLst
    * @description apex variable
    */
    List<Opportunity> opportunityUpdateLst = new List<Opportunity>();

    /**
    * @description Constructor declaration
    */
    public UploadDeclarationDocumentCtrl() {
        currentRecordId = ApexPages.currentPage().getParameters().get('oppid');
    }
    
    /**
     * @description this method is used to upload document on attachment. 
     * @return [Current Opportunity Record Id]
     */
    public pagereference uploadDoc(){
        if(String.IsNotBlank(currentRecordId)){
            if(String.isNotBlank(fileName)){   
                try {  
                    List<Opportunity> lstOpportunity = [select id, Tax_Rule_SAP__c from Opportunity where Id=:currentRecordId];
                    if(lstOpportunity.size() > 0){
                        for(Opportunity opp : lstOpportunity){
                            if(opp.Tax_Rule_SAP__c!='UAE VAT Refund'){   
                                opp.Tax_Rule_SAP__c = 'UAE VAT Refund'; 
                            }
                            opportunityUpdateLst.add(opp);
                        }
                        if(opportunityUpdateLst.size() > 0){
                            update opportunityUpdateLst;
                        }
                    }
                    
                    //Added as per ticket - BK-22265
                    //Total Records
        			String ParentId= currentRecordId;
                    Set<Id> sids = new Set<Id>();
        			List <ContentDocumentLink> lstContentDocumentLink = [SELECT Id, LinkedEntityId, ContentDocumentId, Visibility, ShareType FROM ContentDocumentLink  where LinkedEntityId =: ParentId ]; 
        			for (ContentDocumentLink ocontentdocuments : lstContentDocumentLink)
                    {
            			sids.add(ocontentdocuments.ContentDocumentId);
        			}
                    Integer totalRecords = [SELECT COUNT() FROM ContentVersion  Where ContentDocumentId = : sids AND (PathOnClient LIKE '%Declaration Document%' or Title LIKE '%Declaration Document%') ];
                    System.debug('Count pinak'+totalRecords+sids);
                    List<ContentDocument> lstContentDocument = [SELECT Id,Title From ContentDocument where Id =: sids AND Title LIKE '%Declaration Document%'];    
        			
                    //Added Till Here as per - BK-22265
                    
                    ContentVersion cVersion = new ContentVersion();
                    cVersion.ContentLocation = 'S'; //S-Document is in Salesforce. E-Document is outside of Salesforce. L-Document is on a Social Netork.
                    cVersion.PathOnClient = fileName;//File name with extention
                    cVersion.Origin = 'H';//C-Content Origin. H-Chatter Origin.
                    cVersion.OwnerId = Userinfo.getUserId();//Owner of the file
                    cVersion.Title = 'Declaration Document - '+ Date.Today().format();//Name of the file
                    cVersion.VersionData = fileBody;//File content
                    try{
                        insert cVersion; 
                    }catch(Exception e){
                        System.debug('Issue occured >> ' +e.getStackTraceString());
                    }
                   
                    try{
                        Id conDocument = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cVersion.Id].ContentDocumentId;
                        ContentDocumentLink cDocLink = new ContentDocumentLink();  cDocLink.ContentDocumentId = conDocument; cDocLink.LinkedEntityId = lstOpportunity[0].Id; cDocLink.ShareType = 'V';    cDocLink.Visibility = 'AllUsers';
                        insert cDocLink;
                    }catch(Exception e){
                        System.debug('Issue occured >> ' +e.getStackTraceString());
                    }

                    
                    //Added as per ticket - BK-22265
                    List<Opportunity> opportunitiesToUpdate = new List<Opportunity>();
                    List<Opportunity> oppListForUpdate = [select id,Declaration_Document_Uploaded__c,Declaration_Document_Link__c  from Opportunity where Id=:currentRecordId];
                    if(oppListForUpdate.size()>0){
                        
                        List<Id> oppIds = new List<id>();
                        for(Opportunity opp : lstOpportunity){
                            oppIds.add(opp.Id);
                        }
                        System.debug('Testing OppIds '+ oppIds);
                                                
                        
                        List<ContentDocumentLink> contentDocumentList = [Select LinkedEntityId, ContentDocumentId from ContentDocumentLink where LinkedEntityId in :oppIds and ContentDocumentId in (Select Id from ContentDocument where Title like '%Declaration Document%')];
                        System.debug('Testing contentDocumentList : '+contentDocumentList);
                        Map<String,String> OppIdToContentDocId = new Map<String, String>();
                        if(contentDocumentList.size() > 0){
                            for(contentDocumentLink cdl : contentDocumentList){
                                OppIdToContentDocId.put(cdl.LinkedEntityId, cdl.ContentDocumentId);
                            }
                        }                       
                        System.debug('Testing OppIdToContentDocId : '+OppIdToContentDocId);
                        
                        for(Opportunity opp: oppListForUpdate){
                            opp.Declaration_Document_Uploaded__c=True;
                            System.debug('Testing OppIdToContentDocId - '+OppIdToContentDocId);
                            if(OppIdToContentDocId.containsKey(opp.Id)){
                                opp.Declaration_Document_Link__c = Label.base_url +OppIdToContentDocId.get(opp.Id);
                            }
                            opportunitiesToUpdate.add(opp);
                        }
                        
                        if(opportunitiesToUpdate.size() > 0){
                            update opportunitiesToUpdate;
                        }
                    }
                    
                    //Added Till Here as per - BK-22265
                    
                    
                    //Added as per ticket - BK-22265
                    //delete the old records
                    if (!lstContentDocument.isEmpty())
                    {    
                         Delete lstContentDocument;
                         System.debug('Documents Getting Deleted ' );
                    }
                    //Added Till Here as per - BK-22265
                    
                    return new Pagereference('/'+currentRecordId);  
                } catch(exception e) {                        
                    system.debug( 'Message: '+e.getMessage()+' Cause: '+e.getCause()+' Line Number: '+e.getLineNumber()+' Trace: '+e.getStackTraceString() );
                }
            } else {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Warning,'File Name/Attachment File cannot be null. Please provide.');
                ApexPages.addMessage(myMsg);     sMessage = String.valueOf(myMsg);       return null; 
            }    
        }
        return null;
    }

    /**
     * @description this method is used to cancel the attachment. 
     * @return [Current Opportunity Record Id]
     */
    public pagereference cancel(){
        PageReference myVFPage;
        if(String.isNotBlank(currentRecordId)){
            myVFPage = new PageReference('/'+currentRecordId);
            myVFPage.setRedirect(true);
        }
        return myVFPage;
    }
    
}