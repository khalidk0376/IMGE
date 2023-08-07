/**
* File:        AttachAggrement.cls
* Project:     GAP
* Date:        2/3/2017 1:04 AM
* Test Class : AttachAggrement_test
* Created By:  Rajesh Kumar
* Modified By: Akshi Arora for BK-2250 on 27/08/2019 and for BK-3346.
* Modified By :Shiv Raghav Sharma INC0011779 (View State Error)
* *************************************************************************
* @Discription - Attach file when click "Attach Agreement" button in opportunity object and  checkbox "contract attached" checked or StageName is ClosedWon.
* *************************************************************************
* Modified By Rajesh Kumar : BK-11940 - 20-01-2021
* History: Modified by Rajesh Kumar - BK-9736 on Date - 26-10-2020
* Modified By Rajesh Kumar for COde coverage.
* Modified by Shiv raghav for bk-bk-14852

*/

public with sharing class AttachAggrement {
    public String oppid {get; set;}
    //Modified By : Shiv Raghav Sharma INC0011779 (View State Error)
    public transient String fileName {get; set;}
    public transient Blob fileBody {get; set;}
    public transient string fileContentType {get; set;}
    // End --------Modified By : Shiv Raghav Sharma INC0011779 (View State Error)
    public List<Opportunity> lstopportunity {get; set;}
    public List <Opportunity> lstopportunities {get; set;}
    public Opportunity  objOpportunity {get; set;}
    public string sMessage {get; set;}
    public transient Boolean hasPartner {get; set;}
    public list <Opportunity> oppListUpdate = new list<Opportunity>();
    public pagereference oppRedirect;
    public String sLabel;
    public String sUserId;
    public List<Agreement__c> listofaggrement = new List<Agreement__c>(); 

    public AttachAggrement(ApexPages.StandardController controller) {
        oppid = ApexPages.currentPage().getParameters().get('id').escapeHtml4();
        oppListUpdate = new list<Opportunity>();
    }
    // Agreement record created after the attachment will upload from Attach Aggreement Button.
    public Pagereference savedoc() {
        Boolean isSuccess = false;
        Set<Id> ids = new set<Id>();
        Application_Bypass__c appBypass = Application_Bypass__c.getInstance();
        if ((fileBody != null)  && (fileName != NULL && fileName != '')) {
            if(fileName.removeEnd('.pdf').length() > 80){
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'File name exceeds 80 characters, please rename file to less than 80 characters and attach to opportunity.');                        ApexPages.addMessage(myMsg); sMessage = String.valueOf(myMsg);    return null;
            }
            else if (oppid != null) {
                //Always Return Offline Opportunity Record Ids.
                lstopportunity = [SELECT id, StageName, Status__c, Manual_Contract__c , Online_Opportunity__c,Online_Opportunity__r.StageName  from Opportunity where Id = : oppid ];
                objOpportunity = lstopportunity.get(0);

                if (objOpportunity.Manual_Contract__c == false) { 
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Contract is not allowed to upload if is it not generated manually');
                    ApexPages.addMessage(myMsg);  sMessage = String.valueOf(myMsg); return null;
                }
                else {                
                    sLabel = System.Label.Global_Exhibitions_User_Name;
                    sUserId = [select id from user where Name = :sLabel Limit 1].Id;
                }
                
                //Get Offline and Online Opportunity record ids.
                for (Opportunity oppids : lstopportunity){
                    if (oppids.Online_Opportunity__c != null){                    
                        ids.add(oppids.Online_Opportunity__c);    
                        ids.add(oppids.Id);
                    }
                    else{
                        ids.add(oppids.Id);
                    }
                }
                if (!ids.isEmpty()){
                    //get offline and Online Opportunity id with this query.
                    lstopportunities = [SELECT id, StageName, Status__c, Manual_Contract__c ,Do_not_activate_Billing__c, Online_Opportunity__c,Review_by_Sales_Ops_Team__c  from Opportunity where Id IN : ids ];                        
                   // bk-14852 creating two agrrement for offline and online opp
                    for(Opportunity opps : lstopportunities ){
                        Agreement__c oaggrement = new Agreement__c();
                        oaggrement.opportunity__c = opps.id;
                        if (String.IsNotBlank(sUserId)) {
                            oaggrement.CreatedById = sUserId;
                            oaggrement.LastModifiedById = sUserId; 
                        } 
                        else { 
                            oaggrement.CreatedById = Userinfo.getUserId();   
                            oaggrement.LastModifiedById = Userinfo.getUserId();
                        }                
                        oaggrement.name = fileName.removeEnd('.pdf'); 
                        listofaggrement.add(oaggrement); 
                    }
                    if(!listofaggrement.isEmpty()){
                       upsert listofaggrement;//BK-17345 Changed to 'upsert' instead of 'insert' to allow list of records
                        ContentVersion cVersion = new ContentVersion();
                        cVersion.ContentLocation = 'S'; //S-Document is in Salesforce. E-Document is outside of Salesforce. L-Document is on a Social Netork.
                        cVersion.PathOnClient = fileName;//File name with extention
                        cVersion.Origin = 'H';//C-Content Origin. H-Chatter Origin.
                        cVersion.OwnerId = Userinfo.getUserId();//Owner of the file
                        cVersion.Title = fileName.removeEnd('.pdf');//Name of the file
                        cVersion.VersionData = fileBody;//File content
                        insert cVersion;
                        Id conDocument = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cVersion.Id].ContentDocumentId;
                        List<ContentDocumentLink> listofdocuments = new List<ContentDocumentLink>();
                      // bk-14852 creating two Attachments for offline and online opp
                        for(Agreement__c agg : listofaggrement){
                            ContentDocumentLink cDocLink = new ContentDocumentLink();
                            cDocLink.ContentDocumentId = conDocument;//Add ContentDocumentId
                            cDocLink.LinkedEntityId = agg.id;//Add attachment parentId
                            cDocLink.ShareType = 'V';//V - Viewer permission. C - Collaborator permission. I - Inferred permission.
                            cDocLink.Visibility = 'AllUsers';//AllUsers, InternalUsers, SharedUsers
                            listofdocuments.add(cDocLink);
                        }
                        if(!listofdocuments.isEmpty()) {
                            insert listofdocuments;
                            // Modified by Palla Kishore for the ticket :: BK-21782
                            if ((objOpportunity.StageName  == 'Contract Sent' || objOpportunity.status__c == 'Accounting Rejected' || objOpportunity.Status__c == 'Rejected by Sales Ops Team') && objOpportunity.Manual_Contract__c == true && !listofdocuments.isEmpty() ) {
                                for (Opportunity oppUpdate : lstopportunities){
                                    if(oppUpdate.StageName != 'Closed Won'){
                                        oppUpdate.Contract_Attached__c = true; 
                                        //Fixing After/Before Update values for Opportunity Trigger. BK-2992 Avinash Shukla
                                        //oppUpdate.SBQQ__Contracted__c = true;
                                        oppUpdate.Update_Contracted__c  = true;
                                        oppUpdate.Manual_Date_Time__c = system.now() - 0.03800;
                                        oppUpdate.StageName = 'Closed Won';
                                        oppUpdate.Contract_Sign_Status__c = 'Signed';
                                        if(oppUpdate.Do_not_activate_Billing__c){
                                            // Modified by Palla Kishore for the ticket BK-26535
                                            oppUpdate.Status__c = 'Do Not Bill Status';
                                        }
                                        else {
                                            if(oppUpdate.Review_by_Sales_Ops_Team__c){
                                                oppUpdate.Status__c = 'Sales Ops Review - Pending';
                                            }else{
                                                oppUpdate.status__c = 'Pending Accounting Approval'; 
                                            }
                                        }                                       
                                        Utility.byPassClosedWon = true;
                                        oppListUpdate.add(oppUpdate);
                                    }
                                }
                                //Database.SaveResult[] srList = Database.update(oppListUpdate, false);
                                try{
                                    
                                    update oppListUpdate;
                                    
                                    if(objOpportunity.StageName  == 'Contract Sent') {
                                        updateQuoteAction.updateQuoteAttachAggrement(objOpportunity.Id);
                                    }
                                    oppRedirect = new pagereference('/' + oppid);
                                    return oppRedirect;
                                    
                                }
                                catch (exception e){ 
                                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'The User is not authorized to perform this action'); ApexPages.addMessage(myMsg);            sMessage = String.valueOf(myMsg); return null;
                                }
                                
                            }
                        }
                    }  
                }
            }
        } 
        else{
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'File Name/Attachment File cannot be null. Please provide. ');
            ApexPages.addMessage(myMsg); sMessage = String.valueOf(myMsg);  return null;
        } 
        return null;                    
    }
    
    public Pagereference canceldoc() {
        oppRedirect = new pagereference('/' + oppid);
        return oppRedirect;
    }
}