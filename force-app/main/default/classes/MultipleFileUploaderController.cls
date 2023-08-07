/**********************************
Created By   :   Palla Kishore
Created Date :   19th Aug 2022
Name         :   MultipleFileUploaderController
Description  :   Controller Class to MultipleFileUploader
handle basic functions for Generic Component to Upload Files like - 
get Existing Files and delete Files if necessary  
Test Class   : MultipleFileUploaderController_test (93%)
****************************************************/

public with sharing class MultipleFileUploaderController {
/*****************************************************************************************************************************************************
* Description   	:   Method that provides all existing Files attached on sObject via sObject Id
* Input Parameter	:	ID
* return type   	:   List<ContentDocument>
*/
    @AuraEnabled
    public static List<ContentDocument> getAllFilesOnsObjectRecord(Id sObjectId){
        List<ContentDocument> contentDocumentListToReturn = new List<ContentDocument>();
        List<ContentDocumentLink> contentDocLinkOnsObjectList = new List<ContentDocumentLink>();

//query for the ContentDocumentLink for provided sObject ID
        contentDocLinkOnsObjectList = [Select id, ContentDocumentId, LinkedEntityId From ContentDocumentLink Where LinkedEntityId =: sObjectId];
        Set<Id> contentDocIdSet = new Set<Id>();

//check if the ContentDocumentLinks for provided sObject Id is found
        if(contentDocLinkOnsObjectList != null && !contentDocLinkOnsObjectList.isEmpty()){
            for(ContentDocumentLink conDocLink : contentDocLinkOnsObjectList){
                //get contentDocument Ids from the ContentDocumentLinks found on the sObject record
                contentDocIdSet.add(conDocLink.ContentDocumentId);
            }
        }

//check contentDocumentIds Set is not empty
        if(contentDocIdSet != null && !contentDocIdSet.isEmpty()){
//get all ContentDocuments on the sObject record
            contentDocumentListToReturn = [Select id, Title From ContentDocument Where ID IN :contentDocIdSet];
        }

//check if the contentDocument List that needs to be returned is not Empty
        if(contentDocumentListToReturn != null && !contentDocumentListToReturn.isEmpty()){
            return contentDocumentListToReturn;
        } else{
            return null;
        }
    }

     /* Fetch Account Name throgh opp Id  BK-22967 By Faisal Khan on 01-09-2022 */
    @auraEnabled
    public static String getAccountName(Id recordId){
        opportunity op = [SELECT Id, AccountId,Account.Name, Name FROM Opportunity where Id =: recordId];
         return op.Account.Name;
    }
    
    @auraEnabled
    public static String getCurrentUserName(){
        User u = [select id,name from user where id = : userinfo.getUserId()];
        return u.Name;
        
    }
    
    @auraEnabled 
    public static void updateCurrentDoc(String docId,String userName){
        contentDocument cd= [select id,Title from contentDocument where id  = : docId];
        //Date dToday = Date.today();
		//String dateStr = dToday.year() + '-' + dToday.month() + '-' + dToday.day();
		
        DateTime dt = DateTime.now();
        String dateStr = dt.format('yyyy-MM-dd hh:mm:ss');

        cd.Title = 'Document_'+userName+'_'+ dateStr;
        update cd;
    }
/*****************************************************************************************************************************************************
* Description   	:   Method to delete uploaded files from sObject record.
* Input Parameter	:	String (JSON formatted Content Document IDs)
* return type   	:   void
*/
    @AuraEnabled
    public static void deleteFiles(String filesIdArrStr){
        List<ContentDocument> contentDocumentToDelete = new List<ContentDocument>();
        Set<Id> filesIdSet = new Set<Id>();

//check if the JSON formatted String of ContentDocument Ids is not Blank
        if(filesIdArrStr != null && filesIdArrStr != ''){
//get all ContentDocument Ids in a set
            filesIdSet = (Set<Id>)JSON.deserialize(filesIdArrStr, Set<Id>.class);
        }

        //check if the ContentDocument Ids set is not empty    	
        if(filesIdSet != null && !filesIdSet.isEmpty()){

//query to get all ContentDocument that needs to be deleted
            contentDocumentToDelete = [Select id From ContentDocument Where Id IN :filesIdSet];
            if(contentDocumentToDelete != null && !contentDocumentToDelete.isEmpty()){
                try{
                    delete contentDocumentToDelete;
                } catch(Exception ex){
                    System.debug('Exception--'+ex.getMessage());
                }	
            }
        }        
       
}
}