/**
* Created By       :   Girikon(Mukesh)
* Created On       :   03/06/2018
* @description     :   This class provides following functionalities:          
*                      Allow to create and get account,contact opportunity, quote record.
*                      There are three AuraEnabled
*                      1. invoke(only use to get record) => cacheable false
*                      2. invokeInsertOrUpdate(only use to insert/update record) => cacheable false(allow DML)
*                      3. getDependentMap(get dependent picklist) => cacheable true(readonly)
*                      There is a Wrapper Class Wrap_CL that is used to get parameters from lightning component
*                      Note: All other methods are private that can't call by outside of class. 
*                      
* Helper Class     :   SchemaUtils,OpportunityNotesAttachmentActivityClass(used to clone activities,notes and attachments)
* Test Class       :   OppActionButtonController_Test(97%)
* Modification log --
* Modified by      :   Girikon(Mukesh)[] ,Adarsh Sharma [BK-2798]
* History: BK-3758 Modified By Rajesh Kumar - on 28-05-2020
* Bk-5832 Modified by - Shiv Raghav Date - 26/6/20202, [BK-6385 Aishwarya 27 July 2020]
*Palla Kishore - 22-10-2021 : [EMEA-24] 
**/
public class OppActionButtonController {
    //private static String GOOGLE_MAP_KEY = 'AIzaSyBnTT6oWLPsLZAQE81qNTIAN3jG_TwFFhs';
    /*
Inner Class Used to get datas from lightning component.
*/
    public class Wrap_CL{
        @AuraEnabled public String recordId;
        @AuraEnabled public String searchKey;
        @AuraEnabled public String objectName;
        @AuraEnabled public String placeId;
        @AuraEnabled public String accountId;
        @AuraEnabled public String oppId;
        @AuraEnabled public AccountContactRelation acc_con_rel_obj;
        @AuraEnabled public Contact cont_obj;
        @AuraEnabled public Partner partner_obj;
        @AuraEnabled public Opportunity opp_obj;
        @AuraEnabled public String objApi;
        @AuraEnabled public String contrfieldApiName;
        @AuraEnabled public String depfieldApiName;
        @AuraEnabled public String fieldName;
        @AuraEnabled public String fieldValue;
    }
    /**
* @description : generic method that are used from multiple ltng components. This method used for only get records.
* @param : action => provide action name
* @param : parameters => all required parameters in string format and it will deserialize to Wrap_CL object.
* @return : return Object it may be map,list,sobject or list of sobject 
**/ 
    @AuraEnabled(cacheable=false)
    public static Object invoke(String action, String parameters) {
        Object response = new Map<String, Object> {'message'=>'Action not found!','type'=>'error'};
            Wrap_CL parameter = (Wrap_CL)JSON.deserialize(parameters, Wrap_CL.class);        
        switch on action {           
            when 'get_account' {
                response = getAccount(parameter);
            }
            when 'get_opportunity'{
                response = getOpp(parameter);   
            }
            when 'get_quote'{
                response = getQuotes(parameter);    
            }
            when 'get_amend_team_member'{
                response = isAmendmentTeamMember(parameter);    
            }
            when 'get_booth'{
                response = getBooths(parameter);    
            }
            when 'get_addresses'{
                response = getAddressAutoComplete(parameter);
            }
            when 'get_address_detail'{
                response = getAddressDetails(parameter);
            }
            when 'get_account_detail'{
                response = getAccountDetail(parameter);   
            }
            when 'get_con_detail'{
                response = getContactDetail(parameter);   
            }
            when 'get_partner_field'{
                response = new Map<String,Object>{
                    'meta'=>getAccountPartnerFieldDetail()
                        };
                            }
            when 'lookup'{
                response = getLookupDatas(parameter);
            }
            when 'get_parent'{
                response = getParentRecord(parameter);
            }
        }
        return response;
    }
    /**
* @description : generic method to get records based on passing parameter.
* @param : recordId 
* @param : objectName
* @param : fields => comma seperated all fields that need to return in soql query.
* @return : return List of sObject
**/ 
    @AuraEnabled
    public static List<sObject> getRecord(String recordId,String objectName,String fields) {
        if(String.isNotBlank(fields)){
            fields=','+fields;  
        }
        return Database.query('Select Id,Name'+string.escapeSingleQuotes(fields)+' from '+string.escapeSingleQuotes(objectName)+' WHERE Id=:recordId');
    }
    /**
* @description : generic method used only for insert and update record.
* @param : action => provide action name
* @param : parameters => all required parameters in string format and it will deserialize to Wrap_CL object.
* @return : return Object it may be map,list,sobject or list of sobject 
**/ 
    @AuraEnabled(cacheable=false)
    public static Object invokeInsertOrUpdate(String action, String parameters) {
        Object response = new Map<String, Object> {'message'=>'Action not found!','type'=>'error'};
            Wrap_CL parameter = (Wrap_CL)JSON.deserialize(parameters, Wrap_CL.class);        
        switch on action {                       
            when 'set_contact'{
                response = createNewContact(parameter); 
            }
            when 'delete_contact'{response = deleteSingleContact(parameter); 
                                 }
            when 'set_opp'{
                response = updateOpp(parameter); 
            }
            when 'opp_clone_related'{
                response = createOppRelatedRecord(parameter); 
            }
            when 'add_partner'{
                response = setPartner(parameter);
            }
            when 'add_acc_con_rel_obj'{
                response = setAccountContactRelation(parameter);   
            }
            when 'Resubmit_Approval'{
                response = updateOppAfterResubmitSSCApproval(parameter);   
            }
        }
        return response;
    }
    
    //Bk-5832 Developed by - Shiv Raghav Date - 26/6/20202
    private static Object updateOppAfterResubmitSSCApproval(Wrap_CL parameter){
        update parameter.opp_obj;
        return parameter.opp_obj;
    }
    
    private static Object getParentRecord(Wrap_CL parameter){
        if(String.isBlank(parameter.recordId)){ throw new AuraHandledException('Contact Id not found!');}
        return [Select Id,Account.Name,AccountId from contact WHERE Id=:parameter.recordId];
    }
    @AuraEnabled 
    public static user fetchUser(){
        User oUser = [select id,Name,TimeZoneSidKey,Username,Alias,Country,Email,FirstName,LastName,IsActive,IsPortalEnabled 
                      FROM User Where id =: userInfo.getUserId()];
        return oUser;
    }
    @AuraEnabled
    public static list<UserRecordAccess> getUserRecordAccess(string recordId) {
        List<UserRecordAccess> getUsrRecord = new List<UserRecordAccess>();
        if (Schema.sObjectType.UserRecordAccess.isAccessible()) {
            getUsrRecord = [SELECT RecordId, HasReadAccess, HasDeleteAccess, HasEditAccess, HasTransferAccess, MaxAccessLevel
                            FROM UserRecordAccess WHERE UserId = : userInfo.getUserId() AND RecordId = : recordId ];
        }
        return getUsrRecord;
    }
    
    @AuraEnabled
    public static String getDefaultEventCurrency (string eventId) {
        String sEventCurrency ;
        if (String.isNotBlank(eventId)){
            Event_Edition__c oEventEdition = [Select Id , EventCurrency__r.Name, EventCurrency__c from Event_Edition__c where Id = : eventId];
            sEventCurrency = oEventEdition.EventCurrency__r.Name;
        } 
        return sEventCurrency;
    }
    private static Object setAccountContactRelation(Wrap_CL parameter){
        try{
            Insert parameter.acc_con_rel_obj;
            return parameter.acc_con_rel_obj;
        }
        catch(Exception e){ system.debug(e.getMessage());throw new AuraHandledException(e.getMessage());}
    }
    private static Object deleteSingleContact(Wrap_Cl parameter){
        try{
            Delete parameter.cont_obj;return null;
        }
        catch(Exception e){ system.debug(e.getMessage());throw new AuraHandledException(e.getMessage());}
    }
    private static Object setPartner(Wrap_CL parameter){
        try{
            Insert parameter.partner_obj;
            return parameter.partner_obj;
        }
        catch(Exception e){  throw new AuraHandledException(e.getMessage());}
    }
    private static List<sObject> getLookupDatas(Wrap_CL parameter){
        string strQuery;
        /*Changes done by Adarsh regarding ticket number BK-2798 START*/
        if (parameter.objectName == 'user'){
            strQuery = 'Select Id, Name, profile.UserLicense.name FROM '+String.escapeSingleQuotes(parameter.objectName)+' ';  
            if(String.isNotBlank(parameter.searchKey)){
                String searchKey = String.escapeSingleQuotes('%'+parameter.searchKey+'%');
                strQuery =strQuery+' WHERE Name LIKE '+'\'%'+String.escapeSingleQuotes(parameter.searchKey)+'%\'';
                strQuery = strQuery+' '+'AND profile.UserLicense.name'+' = '+'\'Salesforce\'' + ' ' + 'Order By Name';
            }
            if(String.isNotBlank(parameter.searchKey) && String.isNotBlank(parameter.fieldValue)){
                // String val = String.escapeSingleQuotes(parameter.fieldValue);
                strQuery =strQuery+' AND '+String.escapeSingleQuotes(parameter.fieldName)+'=\''+String.escapeSingleQuotes(parameter.fieldValue)+'\'';
            }
            if (String.isBlank(parameter.searchKey)){strQuery = strQuery+' '+'WHERE profile.UserLicense.name'+' = '+'\'Salesforce\'' +' '+'Order By Name';  
                                                    } 
        }
        /*Changes done by Adarsh regarding ticket number BK-2798 END*/
        else{
            strQuery = 'Select Id,Name FROM '+String.escapeSingleQuotes(parameter.objectName);   
            if(String.isNotBlank(parameter.searchKey)){
                String searchKey = String.escapeSingleQuotes('%'+parameter.searchKey+'%');
                strQuery =strQuery+' WHERE Name LIKE '+'\'%'+String.escapeSingleQuotes(parameter.searchKey)+'%\'';
            }
            if(String.isNotBlank(parameter.searchKey) && String.isNotBlank(parameter.fieldValue)){
                // String val = String.escapeSingleQuotes(parameter.fieldValue);
                strQuery =strQuery +' AND '+String.escapeSingleQuotes(parameter.fieldName)+'=\''+String.escapeSingleQuotes(parameter.fieldValue)+'\'';
            }
            if(String.isBlank(parameter.searchKey) && String.isNotBlank(parameter.fieldValue)){
                //String val = String.escapeSingleQuotes(parameter.fieldValue);
                strQuery = strQuery +' WHERE '+String.escapeSingleQuotes(parameter.fieldName)+'=\''+String.escapeSingleQuotes(parameter.fieldValue)+'\'';
            }
            strQuery =strQuery +''+' ORDER BY Name ASC LIMIT 10 OFFSET 0';  
        }
        System.debug('strQuery' +strQuery);
        return Database.query(strQuery);
    }
    //BK-4175 - Modified By Rajesh Kr on 26-05-2020 ( I have added code beacuse of Lighting Handler in pass static value but we have add a another scenerio for UK VAT Invoicing then we need to add more than 5 line of code in this method and after this change i have made change in oppactionbuttonhelper.)
    private static Object updateOpp(Wrap_CL parameter){
        List<Opportunity> lstOpp = new List<Opportunity> ();
        if (!Schema.sObjectType.Opportunity.fields.StageName.isAccessible() || !Schema.sObjectType.Opportunity.fields.Status__c.isAccessible() || !Schema.sObjectType.Opportunity.fields.Do_not_activate_Billing__c.isAccessible() || !Schema.sObjectType.Opportunity.fields.Parent_Opportunity__c.isAccessible() || !Schema.sObjectType.Opportunity.fields.Forecast_Category__c.isAccessible()){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Error: Insufficient Access'));
            return null;
        }
        else {
            lstOpp = [Select Id , Name , StageName , Status__c , Do_not_activate_Billing__c  From Opportunity Where Id =: parameter.opp_obj.Id ];
        }
        for (Opportunity opp: lstOpp ){
                    opp.stageName = 'Closed Won';
                    opp.Status__c = 'Awaiting Payment';
           			// Added by Palla Kishore for the ticket BK-27444
            		opp.Forecast_Category__c = 'Closed Won';
            		system.debug('Status__c ::::'+ opp.Status__c);
                    opp.Do_not_activate_Billing__c= true;                 
                }           
        if (!Schema.sObjectType.Opportunity.fields.Do_not_activate_Billing__c.isUpdateable() || !Schema.sObjectType.Opportunity.fields.Status__c.isUpdateable() || !Schema.sObjectType.Opportunity.fields.StageName.isUpdateable() || !Schema.sObjectType.Opportunity.fields.Forecast_Category__c.isUpdateable()){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Error: Insufficient Access'));
            return null;
        }
        update lstOpp;
        return lstOpp;
    }
    private static List<sObject> getBooths(Wrap_CL parameter){
        if(String.isBlank(parameter.oppId)){ throw new AuraHandledException('Opportunity Id not found!');}
        String likeStr = String.escapeSingleQuotes('Booth%');
        String likeStr2='';
        if(String.isNotBlank(parameter.searchKey)){
            likeStr2 = String.escapeSingleQuotes('%'+parameter.searchKey+'%');
            return [Select Booth_Number__c,Booth_Type__c FROM SBQQ__QuoteLine__c WHERE Booth_Number__c Like:likeStr2 AND SBQQ__Quote__r.SBQQ__Opportunity2__c=:parameter.oppId AND Event_Product_Type__c LIKE:likeStr AND SBQQ__Product__r.Name LIKE:likeStr AND SBQQ__Quote__r.SBQQ__Primary__c=true AND Booth_Number__c!='' Limit 10];
        }
        else{
            return [Select Booth_Number__c,Booth_Type__c FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__r.SBQQ__Opportunity2__c=:parameter.oppId AND Event_Product_Type__c LIKE:likeStr AND SBQQ__Product__r.Name LIKE:likeStr AND SBQQ__Quote__r.SBQQ__Primary__c=true AND Booth_Number__c!='' Limit 10];
        }        
    }
    private static List<sObject> isAmendmentTeamMember(Wrap_CL parameters){
        return  [Select Id FROM Amendment_Team_Member__c WHERE User_Name__c=:UserInfo.getUserId() AND Amendment_Team__r.Event_Series__c=:parameters.recordId];
    }
    /**
* @description : get dependent picklist based on objectName,controlling Field Api Name and dependent Field Api Name.    
* @param : parameters => all required parameters in string format and it will deserialize to Wrap_CL object.
* @return : Map<String, List<String>>
**/ 
    @AuraEnabled(cacheable=true)
    public static Map<String, List<String>> getDependentMap(String parameters){
        Wrap_CL parameter = (Wrap_CL)JSON.deserialize(parameters, Wrap_CL.class);        
        return getDependentMap(parameter.objApi,parameter.contrfieldApiName,parameter.depfieldApiName);
    }
    /**
* [Fetch ureent user details]
* @return [user record]
*/
    @AuraEnabled(cacheable=false)
    public static user getCurrentUserDtls() {
        return OpportunityDetailsCtrl.getCurrentUserDtls();
    }
    private static Object createNewContact(Wrap_CL parameter){
        System.debug(parameter.cont_obj);
        try{
            Id devRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Contact_Account_is_unhold').getRecordTypeId();
            parameter.cont_obj.RecordTypeId = devRecordTypeId;
            Upsert parameter.cont_obj;
            return parameter.cont_obj.Id;
        }
        catch(Exception e){  throw new AuraHandledException(e.getMessage());}
    }
    private static Object getQuotes(Wrap_CL parameter){
        if(String.isBlank(parameter.oppId)){ throw new AuraHandledException('Opportunity Id not found!');}
        List<SBQQ__Quote__c> quoteList = [Select Id from SBQQ__Quote__c Where SBQQ__Opportunity2__c=:parameter.oppId];
        return quoteList.size();
    }
    private static List<sObject> getAccountDetail(Wrap_CL parameter){
        List<Account> accList = new List<Account>();
        if(String.isBlank(parameter.accountId)){ throw new AuraHandledException('Account Id not found!');}
        return [Select Id,Name,Address_Verified__c,Inactive__c,BillingCity, BillingStreet, BillingState, BillingPostalCode, BillingStateCode, BillingCountry, BillingCountryCode, Is_Billing_Country_AE__c from Account WHERE Id=:parameter.accountId];
    }
    private static list<UserRecordAccess> getUserRecordAccess(Wrap_CL parameter) {
        return [SELECT RecordId, HasReadAccess, HasDeleteAccess, HasEditAccess, HasTransferAccess, MaxAccessLevel
                FROM UserRecordAccess WHERE UserId =: userInfo.getUserId() AND RecordId =: parameter.recordId];
    } 
    private static Map<String,Object> getContactDetail(Wrap_CL parameter){        
        if(String.isBlank(parameter.recordId)){ throw new AuraHandledException('Account Id not found!');}
        return new Map<String,Object>{
            'con_obj'=>[Select Id, Name, recordTypeId , MailingStreet,MailingCity,MailingStateCode,MailingCountryCode,MailingCountry,MailingState,MailingPostalCode,AccountId,Account.Name,Account.Address_Verified__c,Inactive__c from Contact WHERE Id=:parameter.recordId],
                'profile'=>[Select Name from Profile WHERE id=:UserInfo.getProfileId()].Name,
                'meta' => getContactPicklist(),
                'is_sand'=>[Select IsSandbox FROM Organization][0].IsSandbox
                };
                    }
    private static Map<String, Object> getAccount(Wrap_CL parameter){
        List<Account> accList = new List<Account>();
        if(String.isBlank(parameter.accountId)){ throw new AuraHandledException('Account Id not found!');}
        accList = [Select Id,Name,Address_Verified__c,Inactive__c,BillingCity, BillingStreet , Billing_Address_Line_2__c, BillingState, BillingPostalCode, BillingStateCode, BillingCountry, BillingCountryCode, Is_Billing_Country_AE__c from Account WHERE Id=:parameter.accountId];
        String loggedInUserProfileName = [Select Name from Profile WHERE id=:UserInfo.getProfileId()].Name;        
        List<AllowedProfiles__c> allowedProfileList = [Select Id from AllowedProfiles__c WHERE Name =:loggedInUserProfileName];
        List<User> lstUser = [select Id from User where Id=:UserInfo.getUserId() and UserRole.Name IN ('Sales Mgmt-Arab Health','Sales-Arab Health','Sales Mgmt-EHI Live','Sales-EHI Live','Sales Mgmt-Health GB','Sales-Health GB','Sales Mgmt-Life Sciences ME','Sales-Life Sciences ME','Sales Mgmt-Medic','Sales-Medic East Africa','Sales-Medic West Africa','Sales-North Africa','Sales Mgmt-Medlab Middle East','Sales-Medlab Middle East','Sales Mgmt-City & Trade ME','Sales-City & Trade ME')];
        return new Map<String, Object>{
            'accObj' => accList[0],
                'meta' => getContactPicklist(),
                'profile'=>loggedInUserProfileName,
                'is_sand'=>[Select IsSandbox FROM Organization][0].IsSandbox,
                'is_allow'=>allowedProfileList.size()>0?true:false,
                    'IsUserRole'=>lstUser.size()>0?true:false,
                        'con_record_type_id' => Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Contact_Account_is_unhold').getRecordTypeId()
                        };
                            }
    private static Map<String,Object> getOpp(Wrap_CL parameter){
        List<Opportunity> oppList = new List<Opportunity>();
        if(String.isBlank(parameter.oppId)){ throw new AuraHandledException('Opportunity Id not found!');}

         /*Changes done by Palla Kishore regarding ticket number EMEA-24 ----22/10/2021 (I have added 'Review_by_Sales_Ops_Team__c' field in the query)*/
        oppList = [Select Id,Name,IOM_Sync_Status__c,Amount,Status__c,Review_by_Sales_Ops_Team__c,Manual_Contract__c,RecordTypeId,Parent_Opportunity__c,EventEdition__r.Enabled_for_IOM_Billing__c,Billing_Contact__r.Address_Verified__c,CurrencyIsoCode,isThroughDcousign__c,Revenue_Estimate__c,SBQQ__Contracted__c,Master_Opportunity__c,Event_Series__c,Copy_Notes_Attachment_Activities__c,EventEdition__c,Opportunity_Contact__c,Do_not_activate_Billing__c,Exhibitor_Paid_By__c,Agent_s_Opportunity__c,Operations_Contact__c,Billing_Contact__c,OwnerId, AccountId,Account.Name,Account.inactive__c,PartnerAccountId,StageName,Billing_Contact__r.Account.BillingCountryCode, EventEdition__r.Tax_Rule__c, User_Type__r.Name, SBQQ__Ordered__c, Non_Reseller_Agent__c,Account.Customer_VAT_Number__c, Type, CloseDate from Opportunity WHERE Id=:parameter.oppId];


        List<OpportunityLineItem> lstOppLineItem = [Select Id,  Product2.Event_Product_Type__c from OpportunityLineItem where OpportunityId=:parameter.oppId AND Product2.Event_Product_Type__c = 'Booth'];
        String loggedInUserProfileName = [Select Name from Profile WHERE id=:UserInfo.getProfileId()].Name;        
        List<AllowedProfiles__c> allowedProfileList = [Select Id from AllowedProfiles__c WHERE Name =:loggedInUserProfileName];
        List <User> lstuserrole =  [SELECT UserRoleId,UserRole.Name FROM User WHERE id=:UserInfo.getUserId()];
        return new Map<String,Object>{
            'opp_obj'=>oppList[0],
                'is_allow'=>allowedProfileList.size()>0?true:false,
                    'lstOpportunityLineItem'=>lstOppLineItem.size()>0?true:false,
                        'isCheckProfile'=>loggedInUserProfileName,
                        'access'=> getUserRecordAccess(parameter),
                        'is_sand'=>[Select IsSandbox FROM Organization][0].IsSandbox,
                        'inactive__c' => oppList[0].Account.inactive__c,
                        'sscbrasil' => lstuserrole[0].UserRole.Name
                        };
                            }
    private static Object createOppRelatedRecord(Wrap_CL parameter){
        Object obj;
        if(String.isBlank(parameter.oppId)){ throw new AuraHandledException('Error while cloning opportunity');}        
        if(String.isNotBlank(parameter.depfieldApiName)){
            obj = OpportunityNotesAttachmentActivityClass.oppNotesAttachActivity(parameter.recordId, parameter.depfieldApiName, parameter.oppId);
        }
        return obj;
    }
    private static Map<String, SchemaUtils.FieldDto> getAccountPartnerFieldDetail(){
        Map<String,String> objectFieldsMap = new Map<String,String> {'Partner.Role'=>'Partner_Role'};
            Map<String, SchemaUtils.FieldDto> fields = new Map<String, SchemaUtils.FieldDto>();
        Map<String, SchemaUtils.FieldDto> describes = SchemaUtils.describeSobjects(objectFieldsMap.keySet());
        for (String fieldPath : describes.keySet()) {
            SchemaUtils.FieldDto field = describes.get(fieldPath);
            fields.put(objectFieldsMap.get(fieldPath), field);
        }
        return fields;
    }
    private static Map<String, SchemaUtils.FieldDto> getContactPicklist() {        
        Map<String,String> objectFieldsMap = new Map<String,String> {               
            'Contact.Salutation'=>'Salutation',
                'Contact.Contact_Type__c'=>'Contact_Type',
                'Contact.MailingCountryCode'=>'MailingCountryCode',
                'AccountContactRelation.Roles'=>'Roles'
                };
                    Map<String, SchemaUtils.FieldDto> fields = new Map<String, SchemaUtils.FieldDto>();
        Map<String, SchemaUtils.FieldDto> describes = SchemaUtils.describeSobjects(objectFieldsMap.keySet());
        for (String fieldPath : describes.keySet()) {
            SchemaUtils.FieldDto field = describes.get(fieldPath);
            fields.put(objectFieldsMap.get(fieldPath), field);
        }
        return fields;
    }
    /**
* @description : Auto suggestion Web Service 
* @param : input: SearchAddress , types: Results Types , langug : language for getting the results
* @return : string
**/
    private static string getAddressAutoComplete(Wrap_CL parameter) {
        String url = 'https://maps.googleapis.com/maps/api/place/autocomplete/json?input='
            + EncodingUtil.urlEncode(parameter.searchKey, 'UTF-8')
            + '&language=en'+ 
            + '&key=' + Label.Google_Api_Key;
        return getHttp(url);
    }
    /**
* @description : Place Details Web Service 
* @param : PlaceId: Unique Place Id , langug : language for getting the results
* @return : string
**/ 
    private static string getAddressDetails(Wrap_CL parameter) {
        String url = 'https://maps.googleapis.com/maps/api/place/details/json?placeid='
            +parameter.placeId+'&language=en&key='+ Label.Google_Api_Key;
        return getHttp(url);
    }
    /**
* @description : Common Utility method for making call out
* @param : String
* @return : string
**/    
    private static string getHttp(String url){
        try{            
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint(url);
            request.setMethod('GET');
            HttpResponse response = http.send(request);
            system.debug(response.getBody());
            return response.getBody();
        }
        catch(Exception e){ throw new AuraHandledException(e.getMessage());}
    } 
    // fetch dependent picklist for country and state code CCEN -266    
    private static Map<String, List<String>> getDependentMap(string objApi, string contrfieldApiName,string depfieldApiName) {
        String controllingField = contrfieldApiName.toLowerCase();
        String dependentField = depfieldApiName.toLowerCase();
        Map<String,List<String>> objResults = new Map<String,List<String>>();
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get(objApi);
        Sobject objectName = targetType.newSObject();
        Schema.sObjectType objType = objectName.getSObjectType();
        if (objType==null){
            return objResults;
        }
        Map<String, Schema.SObjectField> objFieldMap = objType.getDescribe().fields.getMap();
        if (!objFieldMap.containsKey(controllingField) || !objFieldMap.containsKey(dependentField)){
            return objResults;     
        }
        Schema.SObjectField theField = objFieldMap.get(dependentField);
        Schema.SObjectField ctrlField = objFieldMap.get(controllingField);
        List<Schema.PicklistEntry> contrEntries = ctrlField.getDescribe().getPicklistValues();
        List<PicklistEntryWrapper> depEntries = wrapPicklistEntries(theField.getDescribe().getPicklistValues());
        List<String> controllingValues = new List<String>();
        for (Schema.PicklistEntry ple : contrEntries) {
            String val = ple.getValue();
            objResults.put(val, new List<String>());
            controllingValues.add(val);
        }
        for (PicklistEntryWrapper plew : depEntries) {
            String val = plew.label+'__$__'+plew.value ;
            String validForBits = base64ToBits(plew.validFor);
            for (Integer i = 0; i < validForBits.length(); i++) {
                String bit = validForBits.mid(i, 1);
                if (bit == '1') {
                    objResults.get(controllingValues.get(i)).add(val);
                }
            }
        }
        return objResults;
    }
    //BK-6385
    @AuraEnabled
    public static String getCurrentUserProfileName(){
        String profileId = UserInfo.getProfileId();
        Profile profile = [SELECT Id, Name FROM Profile WHERE Id =:profileId LIMIT 1];
        return profile.Name;
    }
    @AuraEnabled
    public static Id getRecordType() {
        recordtype recordtypeNameList = [select id, name, DeveloperName, sobjecttype from recordtype where DeveloperName ='IsNotCancelOpportunity' and sobjecttype ='opportunity' limit 1];
        Id recId = recordtypeNameList.id;
        return recId;
    }
    /* added Method for pass Record Type on BK-4977 on RajesH kumar - 02-06-2020 */  
    @AuraEnabled
    public static Id getRecordTypeQuote() {
        recordtype recordtypeNameList = [select id, name, DeveloperName, sobjecttype from recordtype where DeveloperName ='Is_Not_Barter' and sobjecttype ='SBQQ__Quote__c' limit 1];
        Id recId = recordtypeNameList.id;
        return recId;
    }
    @AuraEnabled
    public static Id getRecordTypeContact(Id recordId) {
        Contact conList = [select id, name, recordTypeId from Contact where id =: recordId];
        Id recTypeId = conList.RecordTypeId;
        return recTypeId;
    }
    private static String decimalToBinary(Integer val) {
        String bits = '';
        while (val > 0) {
            Integer remainder = Math.mod(val, 2);
            val = Integer.valueOf(Math.floor(val / 2));
            bits = String.valueOf(remainder) + bits;
        }
        return bits;
    }
    private static String base64ToBits(String validFor) {
        if (String.isEmpty(validFor)) {
            return '';
        }
        String validForBits = '';
        for (Integer i = 0; i < validFor.length(); i++) {
            String thisChar = validFor.mid(i, 1);
            Integer val = BASE64CHARS.indexOf(thisChar);
            String bits = decimalToBinary(val).leftPad(6, '0');
            validForBits += bits;
        }
        return validForBits;
    }
    private static final String BASE64CHARS = '' +
        'ABCDEFGHIJKLMNOPQRSTUVWXYZ' +
        'abcdefghijklmnopqrstuvwxyz' +
        '0123456789+/';    
    private static List<PicklistEntryWrapper> wrapPicklistEntries(List<Schema.PicklistEntry> pLEs) 
    {
        return (List<PicklistEntryWrapper>)
            JSON.deserialize(JSON.serialize(pLEs), List<PicklistEntryWrapper>.class);
    }
    public class PicklistEntryWrapper
    {
        @AuraEnabled public String label;
        @AuraEnabled public String value;
        @AuraEnabled public String validFor;
    }    
    /*BK-4143 - Shiv Raghav Sharma
Description - This method will determine which tab is visible on user type button 
on opportunity Based on current login user */
    @AuraEnabled(cacheable=false)
    public static Map<String , Boolean> getUserTypeButtonAccess() {
        Map<String , Boolean> UserTypeTabPermission = new Map<String , Boolean>();
        User currentloginuser = [Select id, User_Type_Button_Visibility__c from user where id =: UserInfo.getUserId()];
        if(!String.isBlank(currentloginuser.User_Type_Button_Visibility__c))
        {
            UserTypeTabPermission.put('UserTypeButton' , True);
            For(String str : currentloginuser.User_Type_Button_Visibility__c.split(';'))
            {
                if(str == 'Exhibitor Paid By')
                {
                    UserTypeTabPermission.put('Tab1' , True);
                }
                else
                    if(str == 'Expocad Booth Mapping')
                {
                    UserTypeTabPermission.put('Tab2' , True); 
                }
                if(str == 'MPN')
                {
                    UserTypeTabPermission.put('Tab3' , True);
                }
                if(str == 'Expocad On Demand')
                {                  
                    UserTypeTabPermission.put('Tab4' , True);
                }
                if(str == 'CC Mapping')
                {
                    UserTypeTabPermission.put('Tab5' , True);
                }
                if(str == 'CC Data')
                {
                    UserTypeTabPermission.put('Tab6' , True);
                }
            }
            return UserTypeTabPermission;
        }
        else     
        {
            return Null;
        }       
    }
    //BSM-371 - Garima Gupta
    /**
    * @description : get custom metadata record based on Country code (MasterLabel) from Custom MetaData type.    
    * @return : Map<String, Google_Place_Api_Field_Mapping__mdt>
    **/
    @AuraEnabled
    public static Map<String , Google_Place_Api_Field_Mapping__mdt> getGoogleApiMetaData(){
        Map<String , Google_Place_Api_Field_Mapping__mdt> mapGoogleApi = new Map<String , Google_Place_Api_Field_Mapping__mdt>();
        List<Google_Place_Api_Field_Mapping__mdt> lstGoogleApiData = [SELECT Id,MasterLabel, QualifiedApiName, Country__c, State__c, City__c, District__c, Postal_Code__c FROM Google_Place_Api_Field_Mapping__mdt];
        for(Google_Place_Api_Field_Mapping__mdt fieldMap : lstGoogleApiData){
            mapGoogleApi.put(fieldMap.MasterLabel , fieldMap);
        }
        return  mapGoogleApi;
    }
}