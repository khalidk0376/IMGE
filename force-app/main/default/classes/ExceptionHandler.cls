/**
 * Created By   :   Girikon(Mahesh)[Regarding:-(TES-15)]
 * Created On   :   May 03 2019
 * @description :   [For Handing the Exceptions]
 * Test Class   :   ExceptionHandler_Test
 * Modification Log----- 
 * Modified by  :   
 **/
public  class ExceptionHandler {
 
    public static Boolean dmlAsQueueable;
    private static  String lineBreak = '\n\n';
 
    /* @TestVisible
    private static  Integer emailsProcessed = 0;
 
    @TestVisible
    private static  List<Messaging.SingleEmailMessage> emails; */
 
    public static esso_ErrorLog__c capture(Type objectType, Exception ex /* , Boolean emailNow = false */){
 
        return process(objectType, ex, null, null, null /*, emailNow */, null, null, null, null);
    }
 
    public static esso_ErrorLog__c capture(Type objectType, Exception ex, String customMsg /* , Boolean emailNow = false */){
 
        return process(objectType, ex, null, customMsg, null /*, emailNow */, null, null, null, null);
    }
 
    public static esso_ErrorLog__c capture(Type objectType, Exception ex, String operationType, String customMsg, Map<String, object> erroredData, String contextualObj, String contextualRecord, String contextualRelationRecord, String contactId) {
 
        return process(objectType, ex, operationType, customMsg, erroredData, contextualObj, contextualRecord, contextualRelationRecord, contactId);
    }
 
    public static esso_ErrorLog__c capture(Type objectType, Exception ex, String operationType, Map<String, object> erroredData /* , Boolean emailNow = false */){
 
        return process(objectType, ex, operationType, null, erroredData /*, emailNow */, null, null, null, null);
    }
 
    public static esso_ErrorLog__c capture(Type objectType, Exception ex, String operationType, String customMsg, Map<String, object> erroredData /* , Boolean emailNow = false */){
 
        return process(objectType, ex, operationType, customMsg, erroredData /*, emailNow */, null, null, null, null);
    }
 
    public static esso_ErrorLog__c capture(Type objectType, String customMsg/* , Boolean emailNow = false */){
 
        return process(objectType, null, null, customMsg, null /*, emailNow */, null, null, null, null);
    }
    public static esso_ErrorLog__c capture(Type objectType, String customMsg, Map<String, object> erroredData/* , Boolean emailNow = false */){
 
        return process(objectType, null, null, customMsg, erroredData /*, emailNow */, null, null, null, null);
    }
 
    private static esso_ErrorLog__c process(Type objectType, Exception ex, String operationType, String customMsg, Map<String, object> erroredData /* , Boolean emailNow = false */, String contextualObj, String contextualRecord, String contextualRelationRecord, String contactId){
         
        String errorOperationType
            = (String.isNotBlank(operationType)) ? operationType : 'UNDEFINED';
         
        String errorName
            = 'OPERATION/DML: ' + errorOperationType + ' [' + System.now() + ']';
         
        String errorCause
            = ex != null && ex.getCause() != null
                ? ex.getCause().getMessage().length() > 255
                    ? ex.getCause().getMessage().substring(0, 250) + '...'
                    : ex.getCause().getMessage()
                : '';
         
        String errorMessage        
            = ex != null
                ? ex.getMessage().length() > 255
                    ? ex.getMessage().substring(0, 250) + '...'
                    : ex.getMessage()
                : '';
         
        esso_ErrorLog__c errorLog = new esso_ErrorLog__c(Name = errorName
            , Cause__c                      = errorCause
            , Message__c                    = errorMessage
           //CustomMessage__c              = customMsg
            , OperationType__c              = errorOperationType
            , ExceptionType__c              = ex != null ? ex.getTypeName() : null
            , Class__c                      = objectType.getName()
            , LineNumber__c                 = ex != null ? ex.getLineNumber() : null
            , Contextual_Object__c          = contextualObj != null ? contextualObj : null
            , Contextual_Record__c          = contextualRecord != null ? contextualRecord : null
            , Contextual_Relation_Record__c = contextualRelationRecord != null ? contextualRelationRecord : null
            , Contact__c                    = contactId
            , StackTrace__c                 = ex != null ? ex.getStackTraceString() : null);
 
        if(dmlAsQueueable == null || dmlAsQueueable == false){
            insert errorLog;
        }
        List <ContentVersion> insertFiles = new List <ContentVersion>();
        List <ContentDocumentLink> lstInsertContentDocumentLink = new List<ContentDocumentLink>();
        if (erroredData != null) {
            for(String fileName : erroredData.keySet()) {
                Object fileObject = erroredData.get(fileName);
                if (fileObject != null) {
                    ContentVersion cVersion = new ContentVersion();
                    cVersion.ContentLocation = 'S'; //S-Document is in Salesforce. E-Document is outside of Salesforce. L-Document is on a Social Netork.
                    cVersion.PathOnClient = fileName + '.txt';//File name with extention
                    cVersion.Origin = 'H';//C-Content Origin. H-Chatter Origin.
                    cVersion.OwnerId = UserInfo.getUserId();//Owner of the file
                    cVersion.Title = fileName + '.txt';//Name of the file
                    cVersion.VersionData = Blob.valueOf(JSON.serializePretty(fileObject));//File content
                    insertFiles.add(cVersion);
                }
            }
        }
     
        if(dmlAsQueueable == null || dmlAsQueueable == false){
            if (!insertFiles.isEmpty()){
                insert insertFiles;
                system.debug('insertFiles' + insertFiles);
                set<Id> setcontentdocumentids = new set<Id>();
                for (ContentVersion oContentVersion : insertFiles ){
                    setcontentdocumentids.add(oContentVersion.ContentDocumentId);
                }
                //Id conDocument = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:insertFiles[0].Id].ContentDocumentId;
                for (ContentVersion oContentVersion : [SELECT ContentDocumentId FROM ContentVersion WHERE ContentDocumentId IN : setcontentdocumentids]){
                    ContentDocumentLink cDocLink = new ContentDocumentLink();
                    cDocLink.ContentDocumentId =oContentVersion.ContentDocumentId;//Add ContentDocumentId
                    cDocLink.LinkedEntityId = errorLog.Id;//Add. attachment parentId
                    cDocLink.ShareType = 'V';//V - Viewer permission. C - Collaborator permission. I - Inferred permission.
                    cDocLink.Visibility = 'AllUsers';//AllUsers, InternalUsers, SharedUsers
                    lstInsertContentDocumentLink.add(cDocLink);
                }
                
            }
            if (!lstInsertContentDocumentLink.isEmpty()){
                insert lstInsertContentDocumentLink;
            }
        }
 
        if(dmlAsQueueable != null && dmlAsQueueable == true){
            ID jobID = System.enqueueJob(new DmlQueueableHandler(errorLog, insertFiles));
        }
        return errorLog;
    }
 
 
    public class DmlQueueableHandler implements Queueable{
        public esso_ErrorLog__c errorLog;
        List <ContentVersion> insertFiles ;
        List <ContentDocumentLink> lstInsertContentDocumentLink = new List <ContentDocumentLink>();
        public  DmlQueueableHandler(esso_ErrorLog__c errorLog, List<ContentVersion> insertFiles){
            this.errorLog = errorLog;
            this.insertFiles = insertFiles;
        }
 
        public void execute(QueueableContext context) {
            if(!insertFiles.isEmpty()){
                insert insertFiles;
                set<Id> setcontentdocumentids = new set<Id>();
                for (ContentVersion oContentVersion : insertFiles ){
                    setcontentdocumentids.add(oContentVersion.ContentDocumentId);
                }
                //Id conDocument = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:insertFiles[0].Id].ContentDocumentId;
                for (ContentVersion oContentVersion : [SELECT ContentDocumentId FROM ContentVersion WHERE ContentDocumentId IN : setcontentdocumentids]){
                    ContentDocumentLink cDocLink = new ContentDocumentLink();
                    cDocLink.ContentDocumentId =oContentVersion.ContentDocumentId;//Add ContentDocumentId
                    cDocLink.LinkedEntityId = errorLog.Id;//Add. attachment parentId
                    cDocLink.ShareType = 'V';//V - Viewer permission. C - Collaborator permission. I - Inferred permission.
                    cDocLink.Visibility = 'AllUsers';//AllUsers, InternalUsers, SharedUsers
                    lstInsertContentDocumentLink.add(cDocLink);
                }
                if (!lstInsertContentDocumentLink.isEmpty()){
                    insert lstInsertContentDocumentLink;
                }
            }
        }
    }
 
 
    /* private static void process(Type objectType, Exception ex, String operationType, String customMsg, Map<String, object> erroredData, Boolean emailNow){
 
        String subject  = getSubject(objectType, ex);
        String msg      = (ex != null) ? processException(objectType, ex, operationType) : '';
 
        msg += (String.isNotBlank(customMsg)) ? lineBreak + 'Custom Error: ' + customMsg : '';
         
          
        addEmail(subject, msg, erroredData);
 
        if(emailNow != null && emailNow){
            sendEmails();
        }
    }
 
    private static String processException(Type objectType, Exception ex, String operationType){
 
        String msg = (String.isNotBlank(operationType))  ? 'OPERATION/DML: ' + operationType + lineBreak : '';
 
        msg += 'Exception Type: '   + ex.getTypeName()          + lineBreak;
        msg += 'Cause: '            + ex.getCause()             + lineBreak;
        msg += 'Class: '            + objectType.getName()      + lineBreak;
        msg += 'Line number: '      + ex.getLineNumber()        + lineBreak;
        msg += 'Message: '          + ex.getMessage()           + lineBreak;
        msg += 'Stack Trace: '      + ex.getStackTraceString()  + lineBreak;
 
 
        if(ex.getTypeName().equals('System.DmlException')){
             
            msg += lineBreak + 'DmlException Details' + lineBreak;
 
            for(Integer i = 0; i < ex.getNumDml(); i++){
 
                msg += 'DML row Index: '    + ex.getDmlIndex(i)     + lineBreak;
                msg += 'DML Id: '           + ex.getDmlId(i)        + lineBreak;
                msg += 'DML Type: '         + ex.getDmlType(i)      + lineBreak;
                msg += 'DML Message: '      + ex.getDmlMessage(i)   + lineBreak;
                msg += 'DML Field Names: '  + String.join(ex.getDmlFIeldNames(i), ', ') + lineBreak;
 
            }
        }
 
        System.debug('ExceptionHandler msg: ' + msg);
 
        return msg;
    } */
 
    /* private static String getSubject(Type objectType, Exception ex){
 
        return 'Salesforce' + (Utility.isRunningInSandbox() ? ' sandbox ' : ' ') + (ex != null ? ex.getTypeName() : 'error' ) + ' in ' + objectType.getName();
    }
 
    private static void addEmail(String subject, String msg, Map<String, object> erroredData){
 
        if(emails == null){
            emails = new List<Messaging.SingleEmailMessage>();
        }
 
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new String[]{'infoapps+sfdc' + (Utility.isRunningInSandbox() ? '-sbx' : '') + '-apex-exc@test-org.com'});
        mail.setSubject(subject);
        mail.setPlainTextBody(msg);
 
        if(erroredData != null && !erroredData.isEmpty()){
 
            List<Messaging.EmailFileAttachment> emailAttachments = new List<Messaging.EmailFileAttachment>();
             
            for(String fileName : erroredData.keySet()){
                 
                Messaging.EmailFileAttachment emailAttachment = new Messaging.EmailFileAttachment();
 
                 
                String  objectAsString = '';
 
                if(erroredData.get(fileName) instanceof Blob){
                    Blob newBlob = (Blob)erroredData.get(fileName);
 
                    objectAsString = newBlob.toString();
                }else{
                    objectAsString = JSON.serializePretty(erroredData.get(fileName));
                }
 
                //String objectAsString = () ? erroredData.get(fileName).toString() : JSON.serializePretty(erroredData.get(fileName));
                 
                //Blob attachmentValue = (erroredData.get(fileName) instanceof Blob) ? Blob.valueOf(Blob.valueOf() : Blob.valueOf(JSON.serializePretty(erroredData.get(fileName)));
 
                Blob attachmentValue = Blob.valueOf(objectAsString);
 
                emailAttachment.setBody(attachmentValue);
                emailAttachment.setFileName(fileName +'.txt');
 
                emailAttachments.add(emailAttachment);
            }
 
            mail.setFileAttachments(emailAttachments);
        }
 
        emails.add(mail);
    }
 
    // When calling this method make sure this is done after a Database.rollback(sp) call as the rollback will stop the emails from being sent
    public static void sendEmails(){
 
        System.debug('*** ExceptionHandler emails: ' + emails);
 
        if(emails != null && !emails.isEmpty()){
 
            emailsProcessed += emails.size();
 
            Messaging.sendEmail(emails);
 
            // Sets the list back to null so same messages are not sent again
            emails = null;
        }
    } */
}