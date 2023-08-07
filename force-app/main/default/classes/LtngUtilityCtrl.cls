/**
* Created By       :   Girikon(Sunil)
* Created On       :   Mar 26 2019
* @description     :   This class is used in Contact details ltng component.          
* Test Class       :   LtngUtilityCtrl_Test 

* Modification log --
* Modified by    History: BK-3758 Modified By Rajesh Kumar - on 28-05-2020, [Aishwarya BK-5341 23 june 2020]   :   
**/
public with sharing class LtngUtilityCtrl {
    /**
* @description [getRecords description]
* @param  objName     [Object api name]
* @param  fieldNames  [Field api names]
* @param  compareWith [Compare field]
* @param  recordId    [Record id]
* @param  pageNumber  [Page Number]
* @param  pageSize    [Page Size]
* @return             [List of sObject]
*/
    @AuraEnabled
    public static RecordDataTableWrapper getRecords(string objName, string fieldNames,string compareWith,string recordId,Decimal pageNumber, Decimal pageSize) {
        
        Integer pSize = (Integer)pageSize;
        Integer pNumber = (Integer)pageNumber;
        
        //Offset for SOQL
        Integer offset = (pNumber - 1) * pSize;
        string strCountQuery='SELECT COUNT() FROM '+String.escapeSingleQuotes(objName); 
        if(string.isNotBlank(compareWith) && string.isNotBlank(recordId))
        {
            strCountQuery=strCountQuery+' where '+String.escapeSingleQuotes(compareWith)+'= :recordId'; 
        }
        //Total Records
        Integer totalRecords = database.countQuery(strCountQuery);
        Integer recordEnd = pSize * pNumber;
        
        //Instance of Contact DataTable Wrapper Class
        RecordDataTableWrapper objDT =  new RecordDataTableWrapper();  
        objDT.pageSize = pSize;
        objDT.pageNumber = pNumber;
        objDT.recordStart = offset + 1;
        objDT.recordEnd = totalRecords >= recordEnd ? recordEnd : totalRecords;
        objDT.totalRecords = totalRecords;
        string strQuery='SELECT '+String.escapeSingleQuotes(fieldNames) +' from '+String.escapeSingleQuotes(objName);
        
        if(string.isNotBlank(compareWith) && string.isNotBlank(recordId))
        {
            strQuery=strQuery+' where '+String.escapeSingleQuotes(compareWith)+'=:recordId ';
        }
        strQuery=strQuery+' Order BY CreatedDate DESC LIMIT :pSize OFFSET :offset';
        
        String query = String.escapeSingleQuotes(strQuery);
        objDT.recordList = Database.query(query);
        return objDT;
    }
    
    //Wrapper Class For Contact DataTable  
    public class RecordDataTableWrapper {
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
        public List<sObject> recordList {get;set;}
    }
    /**
* @description [getRecords description]
* @param  objName      [Object api name]
* @param  fieldNames   [Field api names]
* @param  srchField    [Search field]
* @param  srchText     [Search Text]
* @param  conditions   [where conditions]
* @param  sortBy       [sortBy]
* @param  sortType     [sortType]
* @param  pageNumber   [Page Number]
* @param  pageSize     [Page Size]
* @return              [List of sObject]
*/
    @AuraEnabled
    public static RecordDataTableWrapper getSobjectRecords(string objName, string fieldNames,string srchField,string srchText,string conditions,string sortBy,string sortType,Decimal pageNumber, Decimal pageSize) {
        
        srchText = string.escapeSingleQuotes(srchText);
        srchText ='%'+srchText+'%';
        Integer pSize = (Integer)pageSize;
        Integer pNumber = (Integer)pageNumber;
        
        //Offset for SOQL
        Integer offset = (pNumber - 1) * pSize;
        string strCountQuery='SELECT COUNT(Id) FROM '+String.escapeSingleQuotes(objName); 
        
        if(string.isNotBlank(conditions))
        {
            //strCountQuery=strCountQuery+ ' '+String.escapeSingleQuotes(conditions);
            strCountQuery=strCountQuery+ ' '+ conditions;
        }
        system.debug('##############'+strCountQuery);
        if(string.isNotBlank(srchField) && string.isNotBlank(srchText))
        {
            strCountQuery=strCountQuery+ ' and '+String.escapeSingleQuotes(srchField)+' LIKE \''+String.escapeSingleQuotes(srchText)+'\' ';
        }
        //Total Records
        //Integer totalRecords = database.query(strCountQuery).Size();
        Integer totalRecords = UtilityMethods.getDynamicSobjectList(strCountQuery).size();
        Integer recordEnd = pSize * pNumber;
        //Instance of Contact DataTable Wrapper Class
        RecordDataTableWrapper objDT =  new RecordDataTableWrapper();  
        objDT.pageSize = pSize;
        objDT.pageNumber = pNumber;
        objDT.recordStart = offset + 1;
        objDT.recordEnd = totalRecords >= recordEnd ? recordEnd : totalRecords;
        objDT.totalRecords = totalRecords;
        string strQuery='SELECT '+String.escapeSingleQuotes(fieldNames) +' from '+String.escapeSingleQuotes(objName);
        
        if(string.isNotBlank(conditions))
        {
            //strQuery=strQuery+ ' '+String.escapeSingleQuotes(conditions);
            strQuery=strQuery+ ' '+ conditions;
        }
        if(string.isNotBlank(srchField) && string.isNotBlank(srchText))
        {
            strQuery=strQuery+ ' and '+String.escapeSingleQuotes(srchField)+' LIKE \''+String.escapeSingleQuotes(srchText)+'\' ';
        }
        if(string.isNotBlank(sortBy) && string.isNotBlank(sortType) )
        {
            strQuery=strQuery+' order by '+String.escapeSingleQuotes(sortBy)+' '+ String.escapeSingleQuotes(sortType);
        }
        string spSize = String.valueOf(pSize);
        string soffset = String.valueOf(offset);
        strQuery = strQuery+' LIMIT '+String.escapeSingleQuotes(spSize)+' OFFSET '+String.escapeSingleQuotes(soffset);
        //objDT.recordList = Database.query(strQuery);
        objDT.recordList = UtilityMethods.getDynamicSobjectList(strQuery);
        return objDT;
    }
    /**
* @description [Fetch account contact relationships]
* @param  recordId [Record id to fetch the object record]
* @return          [List of sObject]
*/
    @AuraEnabled
    public static List<sObject> getRecord(String recordId,String objectName,String fields) {
        
        /*changes done by Adarsh regarding ticket No: BK-3090 Start */ 
        if(objectName == 'Contact'){
            Boolean inActiveVal = false;
            String theQuery = 'Select Id,Name,Inactive__c ';
            if(String.isNotBlank(fields))
            {
                fields=','+fields;
                theQuery += fields;
            }
            theQuery += ' from ' +objectName+ ' WHERE Id=:recordId AND Inactive__c =: inActiveVal ' ;
            String theQueryResult = string.escapeSingleQuotes(theQuery);
            return Database.query(theQueryResult);
        }
        /*changes done by Adarsh regarding ticket No: BK-3090 End */ 
        else{
            String theQuery = 'Select Id,Name ';
            if(String.isNotBlank(fields))
            {
                fields=','+fields;theQuery += fields;
            }
            theQuery += ' from ' +objectName+ ' WHERE Id=:recordId';
            String theQueryResult = string.escapeSingleQuotes(theQuery);return Database.query(theQueryResult);
        }
    }
    /**
* @description [Fetch ureent user details]
* @return [user record]
*/
    @AuraEnabled
    public static user getCurrentUserDtls() {
        User usr = [select id,AccountId,ContactId,Name,TimeZoneSidKey,Username,Alias,Country,Email,FirstName,LastName,IsActive,IsPortalEnabled,Profile.Name 
                    FROM User 
                    Where id =: userInfo.getUserId()];
        return usr;
    }
    /**
* @description [Fetch Community URL ]
* @return [String]
*/
    @AuraEnabled
    public static string getCommunityURL() {
        Network myNetwork = [SELECT Id 
                             FROM Network 
                             WHERE Name ='Customer Centre' 
                             LIMIT 1];
        return Network.getLoginUrl(myNetwork.id);   
    }
    /**
* @description [Fetch Event Edition Form record for edit]
* @return [user record]
*/
    @AuraEnabled
    public static Event_Edition_Form__c getEventEditionForm(string Id) {
        Event_Edition_Form__c evntF = [select id,Expocad_Booth_Type__c,Expocad_Product_Type__c
                                       FROM Event_Edition_Form__c
                                       Where id =: Id];
        return evntF;
    }
    /**
* @description [Fetch Event Edition Settings ]
*  @param  Id [Event swtting record  id to fetch the object record]
* @return [Event_Settings__c]
*/
    @AuraEnabled
    public static Event_Settings__c getEventEditionSettings(string Id) {
        Event_Settings__c evntS = [select id,Allotment_By_Booth_Size__c, Allotment_By_Booth_Type__c 
                                   FROM Event_Settings__c 
                                   Where id =: Id];
        return evntS;
    }
    
    /**
* @description [Save file into attachment  ]
*  @param  parentId [prent record  id  under which e need to attach the file]
*  @param  fileName [file name ]
*  @param  base64Data [base64 encoded data for attachment ]
* @return [attachment id ]
*/
    @AuraEnabled
    public static Id saveFileOld(Id parentId, String fileName, String base64Data) {
        base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
        Attachment attach = new Attachment();
        attach.parentId = parentId;
        attach.Body = EncodingUtil.base64Decode(base64Data);
        attach.Name = fileName;
        //attach.ContentType = "image/jpg";
        Insert attach;
        return attach.Id;
    }
    
    @AuraEnabled
        public static Id saveFile(Id parentId, String fileName, String base64Data) {
        base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
        /*Attachment attach = new Attachment();
        attach.parentId = parentId;
        attach.Body = EncodingUtil.base64Decode(base64Data);
        attach.Name = fileName;
        //attach.ContentType = "image/jpg";
        Insert attach; **/
        ContentVersion cVersion = new ContentVersion();
        cVersion.ContentLocation = 'S'; //S-Document is in Salesforce. E-Document is outside of Salesforce. L-Document is on a Social Netork.
        cVersion.PathOnClient = fileName;//File name with extention
        cVersion.Origin = 'H';//C-Content Origin. H-Chatter Origin.
        cVersion.OwnerId = Userinfo.getUserId();//Owner of the file
        cVersion.Title = fileName;//Name of the file
        cVersion.VersionData = EncodingUtil.base64Decode(base64Data);//File content
        insert cVersion;
        Id conDocument = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cVersion.Id].ContentDocumentId;
        ContentDocumentLink cDocLink = new ContentDocumentLink();
        cDocLink.ContentDocumentId = conDocument;//Add ContentDocumentId
        cDocLink.LinkedEntityId = parentId;//Add attachment parentId
        cDocLink.ShareType = 'V';//V - Viewer permission. C - Collaborator permission. I - Inferred permission.
        cDocLink.Visibility = 'AllUsers';//AllUsers, InternalUsers, SharedUsers
        insert cDocLink;
        return conDocument;
    }
    
    
    /**
* @description [get current user type ]
*  @param  eventId [event edition id for whichwe need to fetch user type ]
* @return [ContactEventEditionMapping__c obect record ]
*/
    
    @AuraEnabled
    public static ContactEventEditionMapping__c getCurrentUserType(String eventId)
    {   
        list<ContactEventEditionMapping__c> lstconEvnMp = new list<ContactEventEditionMapping__c>();
        ContactEventEditionMapping__c objConEvnMap= new ContactEventEditionMapping__c();
        if(Schema.sObjectType.ContactEventEditionMapping__c.isAccessible())
        {
            lstconEvnMp = [select Id,User_Type__r.Name,SFContactID__r.Account.Name 
                           from ContactEventEditionMapping__c
                           where (SFEventEditionID__c =:eventId or SFEventEditionID__r.Event_Code__c =:eventId  )  
                           And SFContactID__c in (SELECT Contactid FROM User WHERE Id = : UserInfo.getUserId()) 
                          ];
        }
        
        if(lstconEvnMp.size()>0 )
        {  
            objConEvnMap= lstconEvnMp[0];
        }               
        return objConEvnMap;
    }
    
    /**
* @description [get Agent Event details ]
*  @param  eventId [codefor which e need to fetch event de3tails 
* @return [Event_Settings__c obect record ]
*/
    
    @AuraEnabled
    public static boolean agentEventDetails(String code)
    {   
        boolean liveagentval = false;
        List<Event_Settings__c> evntsttng = new List<Event_Settings__c>();
        evntsttng= [select id , name , Live_Agent_Online__c 
                    from Event_Settings__c 
                    where Event_Edition__r.Event_Code__c=:code 
                    limit 1];
        if(evntsttng.size()>0)
        {
            liveagentval=evntsttng[0].Live_Agent_Online__c;
        }
        return liveagentval;
    }
}