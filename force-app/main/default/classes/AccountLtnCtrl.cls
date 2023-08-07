/**
* Project:     GAP - Lightning Conversion
* Date:        March, 21 2018
* Created By:  Avinash Shukla
* Test Class:  AccountLtnCtrl_Test
* *************************************************************************
* @description Controller class for AccountDetail lightning components
* *************************************************************************
* History: Changes by Adarsh Sharma [BK-2673]
* BSM-371 Modified by - Garima Gupta Date - 17/11/2020
*/
public class AccountLtnCtrl {
    /**
     * googleMapKey google address integration apex variable
     */
    //private static String googleMapKey = 'AIzaSyAQud6xW4SL3JDPHclvuxogypkqKDfP_xI';
    /** Added Code By Rajesh Kumar - 15-07-2020 */
    private static String googleMapKey = Label.Google_Api_Key;
    /**
     * @description Wrapper class for google address integration
     */
    public class Wrap_CL {
        /**
         * @description Wrapper class for google address integration
         */
        @AuraEnabled public String recordId;
        /**
         * @description Wrapper class for google address integration
         */
        @AuraEnabled public String searchKey;
        /**
         * @description Wrapper class for google address integration
         */
        @AuraEnabled public String placeId;
        /**
         * @description Wrapper class for google address integration
         */
        @AuraEnabled public String accountId;
        /**
         * @description Wrapper class for google address integration
         */
        @AuraEnabled public String oppId;
        /**
         * @description Wrapper class for google address integration
         */
        @AuraEnabled public Contact cont_obj;
        /**
         * @description Wrapper class for google address integration
         */
        @AuraEnabled public Opportunity opp_obj;
        /**
         * @description Wrapper class for google address integration
         */
        @AuraEnabled public String objApi;
        /**
         * @description Wrapper class for google address integration
         */
        @AuraEnabled public String contrfieldApiName;
        /**
         * @description Wrapper class for google address integration
         */
        @AuraEnabled public String depfieldApiName;
    }
    /**
     * @description getting account record
     * @param  recordId account record id
     * @return          Account
     */
    @AuraEnabled
    public static Account getAcDetail(string recordId) {
        System.debug('Test Rajesh Kumar : +=+' + recordId);
        // BillingCountry added by Palla Kishore for the ticket BK-20945
        Account acc = [select id, Name, BillingStreet, Inactive__c, Credit_Status__c, ShippingStreet, Billing_Address_Line_2__c, Shipping_Address_2__c, Business_Partner_Number__c, BillingCity, ShippingCity,
                       BillingCountryCode, ShippingCountryCode, BillingStateCode, ShippingStateCode, BillingPostalCode, ShippingPostalCode, Accounting_Credit_Hold__c,
                       Employees__c, Simples_Nacional__c, Industry__c, Organization_Size_In_Person__c,CR_Expiry__c, CR_Number__c, GAZT_Expiry__c ,GAZT_Number__c,Organization_Business_Vol__c, BillingCountry, Type FROM Account Where id = : recordId]; //Changes done by Adarsh Sharma regarding Ticket No: BK-2673
        return acc;
    }
    /**
     * @description getting current user details
     * @return          User
     */
    @AuraEnabled
    public static user getCurrentUserDtls() {
        User usr = [select id, Name, TimeZoneSidKey, Username, Alias, Country, Email, FirstName, LastName, IsActive, IsPortalEnabled, Profile.Name
                    FROM User Where id = : userInfo.getUserId()];
        return usr;
    }
    /**
     * @description getting Account_Translated_FieldSet__c details
     * @param  recordId account record id
     * @return          Account_Translated_FieldSet__c
     */
    @AuraEnabled
    public static Account_Translated_FieldSet__c getaccTranslatedDetail(String recordId) {
        List<Account_Translated_FieldSet__c> atf = new List<Account_Translated_FieldSet__c>();
        atf = [SELECT Id, Name, Translated_Billing_Address_Line_1__c, Translated_Billing_Address_Line_2__c, Translated_Billing_City__c,
               Translated_Billing_Country__c, Translated_Billing_State_Province__c, Translated_Billing_Zip_Postal_Code__c
               FROM Account_Translated_FieldSet__c WHERE Account__c = : recordId];
        if (!atf.isEmpty()) {return atf[0];}
        return null;
    }
    /**
     * @description getting UserRecordAccess list
     * @param  recordId account record id
     * @return          list of UserRecordAccess
     */
    @AuraEnabled
    public static list<UserRecordAccess> getUserRecordAccess(string recordId) {
        return [SELECT RecordId, HasReadAccess, HasDeleteAccess, HasEditAccess, HasTransferAccess, MaxAccessLevel
                FROM UserRecordAccess WHERE UserId = : userInfo.getUserId() AND RecordId = : recordId ];
    }
    
    /**
     * @description Auto suggestion Web Service
     * @param  parameters SearchAddress , types: Results Types , langug : language for getting the results
     * @return            string
     */
    @AuraEnabled
    public static string getAddressAutoComplete(String parameters) {
        Wrap_CL parameter = (Wrap_CL)JSON.deserialize(parameters, Wrap_CL.class);
        String url = 'https://maps.googleapis.com/maps/api/place/autocomplete/json?input='
                     + EncodingUtil.urlEncode(parameter.searchKey, 'UTF-8')
                     + '&language=en' +
                     + '&key=' + googleMapKey;
        return getHttp(url);
    }
    /**
     * @description get picklist values for the field.
     * @return schema object.
     */
    @AuraEnabled
    public static Map<String, SchemaUtils.FieldDto> getAccountPicklist() {
        Map<String, String> objectFieldsMap = new Map<String, String> {
            'Account.Accounting_Credit_Hold__c' => 'Accounting_Credit_Hold__c',
            'Account.Employees__c' => 'Employees__c',
            'Account.Simples_Nacional__c' => 'Simples_Nacional__c',
            'Account.Industry__c' => 'Industry__c',
            'Account.Organization_Size_In_Person__c' => 'Organization_Size_In_Person__c',
            'Account.Organization_Business_Vol__c' => 'Organization_Business_Vol__c',
            'Account.ShippingCountryCode' => 'ShippingCountryCode',
            'Account.BillingCountryCode' => 'BillingCountryCode',
            'Account.Type' => 'Type'

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
     * @description getting depenedent picklist values
     * @param  parameters country value
     * @return            Map
     */
    @AuraEnabled(cacheable = true)
    public static Map<String, List<String>> getDependentMap(String parameters) {
        Wrap_CL parameter = (Wrap_CL)JSON.deserialize(parameters, Wrap_CL.class);
        return StandContractorCtrl.getDependentMap(parameter.objApi, parameter.contrfieldApiName, parameter.depfieldApiName);
    }
    /**
     * @description Place Details Web Service
     * @param  parameters Unique Place Id , langug : language for getting the results
     * @return            string
     */
    @AuraEnabled
    public static string getAddressDetails(String parameters) {
        Wrap_CL parameter = (Wrap_CL)JSON.deserialize(parameters, Wrap_CL.class);
        String url = 'https://maps.googleapis.com/maps/api/place/details/json?placeid='
                     + parameter.placeId + '&language=en&key=' + googleMapKey;
        return getHttp(url);
    }
    /**
     * @description Common Utility method for making call out
     * @param  url String
     * @return     String
     */
    private static string getHttp(String url) {
        try {
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint(url);
            request.setMethod('GET');
            HttpResponse response = http.send(request);
            return response.getBody();
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    /**
     * @description Get accountTeammember records
     * @param  recordId Account record id
     * @param  offSetValue offset value
     * @return             list of accountteammember
     */
    @AuraEnabled
    public static List<AccountTeamMember> AccountTeams(String recordId, Integer offSetValue) {
        List<AccountTeamMember> acTeams = new List<AccountTeamMember>();
        String query = 'SELECT Id, AccountId, TeamMemberRole, Title, User.Name FROM AccountTeamMember WHERE AccountId = : recordId Order By CreatedDate DESC LIMIT 10';
        if (offSetValue > 0) {
            query = query + ' OFFSET : offSetValue';
        }
        acTeams = Database.query(query);
        return acTeams;
    }

    /**
     * @description Get accountTeammember records
     * @param  recordId Account record id
     * @return          list of accountteammember
     */
    @AuraEnabled
    public static boolean isAMember(String recordId) {
        List<AccountTeamMember> acTeams = new List<AccountTeamMember>();
        String userId = UserInfo.getUserId();
        String query = 'SELECT Id, User.id FROM AccountTeamMember WHERE AccountId = : recordId AND user.Id =: userId';
        acTeams = Database.query(query);
        if (!acTeams.isEmpty()) {
            return true;
        } else {
            return false;
        }
    }

    /**
     * @description Delete selected AccountTeamMember
     * @param recordId AccountTeamMember id
     */
    @AuraEnabled
    public static void deleteAcTeam(String recordId) {
        List<AccountTeamMember> acTeams = new List<AccountTeamMember>();
        if (Schema.sObjectType.AccountTeamMember.isAccessible()) {
            acTeams = [SELECT Id, AccountId, TeamMemberRole, Title, User.Name FROM AccountTeamMember WHERE Id = : recordId];
            If(!acTeams.isEmpty()) {
                delete acTeams;
            }
        }
    }
    /**
     * @description add new accountTeamMember record
     * @param recordId account record id.
     */
    @AuraEnabled
    public static void addNewTeam(String recordId) {
        if (Schema.sObjectType.AccountTeamMember.isAccessible()) {
            AccountTeamMember act = new AccountTeamMember();
            act.AccountId = recordId;
            act.UserId = UserInfo.getUserId();
            act.TeamMemberRole = 'Default Team';
            act.AccountAccessLevel = 'Edit';
            act.OpportunityAccessLevel = 'None';
            act.CaseAccessLevel = 'None';
            insert act;
        }
    }
    /**
     * @description return list of Account_Associations__c records.
     * @param  recordId    account record id
     * @param  offSetValue OffSet value
     * @return             list of Account_Associations__c
     */
    @AuraEnabled
    Public static list<Account_Associations__c> getAccountAssociation(string recordId, Integer offSetValue) {
        list<Account_Associations__c> lstAcAs = new List<Account_Associations__c>();
        String query = 'SELECT Id, Name, Active__c, Expiry_Date__c, Chamber__c, Association_Product__c, Association_Product_EE__c, Association__r.Name, Event_Series__c, Member_Status__c FROM Account_Associations__c WHERE Account__c = : recordId Order By CreatedDate DESC LIMIT 10';
        if (offSetValue > 0) {
            query = query + ' OFFSET : offSetValue';
        }
        lstAcAs = Database.query(query);
        return lstAcAs;
    }
    /**
     * @description get asset record for account
     * @param  recordId account record id
     * @return          list of asset records
     */
    @AuraEnabled
    Public static list<Asset> getAssets(string recordId) {
        list<Asset> lstAsset = new List<Asset>();
        if (Schema.sObjectType.Asset.isAccessible()) {
            lstAsset = [SELECT Id, Name, Event_Edition__r.Name, Product2.Name, Price_Sold_Price__c, Quantity FROM Asset WHERE AccountId = : recordId];
        }
        return lstAsset;
    }
    /**
     * @description returns list of account legal entity
     * @param  recordId account record id
     * @return          list of account legal entity
     */
    @AuraEnabled
    public static List<Account_Legal_Entity__c> getBpNumberRecords(String recordId) {
        if (Schema.sObjectType.Account_Legal_Entity__c.isAccessible()) {
            return [SELECT Id, Name, Business_Partner_Number__c, Active__c, Account__c, Legal_Entity__r.DBA__c, Legal_Entity__r.Informa_Branch__c, Legal_Entity__r.Name FROM Account_Legal_Entity__c WHERE Account__c = : recordId];
        }
        return null;
    }
    /**
     * @description returns list of Lead_Nature_Of_Business_Mapping__c
     * @param  recordId account record id
     * @return          list of Lead_Nature_Of_Business_Mapping__c
     */
    @AuraEnabled
    public static List<Lead_Nature_Of_Business_Mapping__c> getNatureOfBusiness(String recordId) {
        Set<String> oppMappingIds = new Set<String>();
        List<Account> acList = new List<Account>();
        if (Schema.sObjectType.Account.isAccessible() && Schema.sObjectType.Opportunity.isAccessible()) {
            acList = [Select Id, (Select Id, Mapping_ID__c, AccountId from Opportunities) from Account WHERE ID = : recordId];
        }
        for (Opportunity oppObj : acList[0].Opportunities) {
            oppMappingIds.add(oppObj.Mapping_ID__c);
        }
        if (Schema.sObjectType.Lead_Nature_Of_Business_Mapping__c.isAccessible()) {
            return [SELECT Id, Name, Nature_of_Business__c, Nature_of_Business_value__c, Opportunity__r.Name, Opportunity__c FROM Lead_Nature_Of_Business_Mapping__c WHERE (Mapping_ID__c != NULL AND Mapping_ID__c IN : oppMappingIds) OR Opportunity__r.AccountId = : recordId];
        }
        return null;
    }
    /**
     * @description retunrs quote records
     * @param  recordId    account record id
     * @param  offSetValue Offset Parameter
     * @return             list of quotes related to account
     */
    @AuraEnabled(cacheable = true)
    public static List<SBQQ__Quote__c> getQuotes(String recordId, Integer offSetValue) {
        list<SBQQ__Quote__c> lstQt = new List<SBQQ__Quote__c>();
        String query = 'SELECT Id, Name, SBQQ__Account__r.Name, Event_Edition_Name__c, SBQQ__NetAmount__c, SBQQ__Status__c, LastModifiedDate, CreatedDate, SBQQ__Primary__c, SBQQ__PrimaryContact__r.Name, SBQQ__PrimaryContact__c, SBQQ__Opportunity2__c, SBQQ__Opportunity2__r.Name, Billing_Contact__c, Billing_Contact__r.Name FROM SBQQ__Quote__c WHERE (SBQQ__Account__r.Id = : recordId or SBQQ__PrimaryContact__c = : recordId) limit 10';
        if (offSetValue > 0) { query = query + ' OFFSET : offSetValue'; }
        lstQt = Database.query(query);
        return lstQt;
    }
    /**
     * @description returns list of LeadInterestLevelMapping__c
     * @param  recordId account record id
     * @return          list of LeadInterestLevelMapping__c
     */
    @AuraEnabled
    public static List<LeadInterestLevelMapping__c> getInterestLevelMappings(String recordId) {
        Set<String> oppMappingIds = new Set<String>();
        List<Account> acList = new List<Account>();
        if (Schema.sObjectType.Account.isAccessible() && Schema.sObjectType.Opportunity.isAccessible()) {
            acList = [Select Id, (Select Id, Mapping_ID__c, AccountId from Opportunities) from Account WHERE ID = : recordId];
        }
        for (Opportunity oppObj : acList[0].Opportunities) {
            oppMappingIds.add(oppObj.Mapping_ID__c);
        }
        if (Schema.sObjectType.LeadInterestLevelMapping__c.isAccessible()) {
            return [SELECT Id, Name, L1__r.LevelValue__c, L2__r.LevelValue__c, L3__r.LevelValue__c, Mapping_ID__c, SFDCOpportunityID__c, SFDCOpportunityID__r.Name FROM LeadInterestLevelMapping__c WHERE (Mapping_ID__c != NULL AND Mapping_ID__c IN : oppMappingIds) OR SFDCOpportunityID__r.AccountId = : recordId];
        }
        return null;
    }
    /**
     * @description returns list of AccountPartner records
     * @param  recordId account record id
     * @param  offSetValue offset value
     * @return          list of account partner
     */
    @AuraEnabled
    public static list<AccountPartner> getaccountPartner(string recordId, Integer offSetValue) {
        List<AccountPartner> acPartner = new List<AccountPartner>();
        String query = 'SELECT Id, AccountToId, AccountTo.Name, Role, AccountFromId FROM AccountPartner WHERE AccountFromId = : recordId Order By CreatedDate DESC LIMIT 10';
        if (offSetValue > 0) {query = query + ' OFFSET : offSetValue';}
        acPartner = Database.query(query);
        return acPartner;
    }

    /**
     * @description returns list of AccountPartner records
     * @param  objName     object Name
     * @param  fieldNames  Fields Api name
     * @param  compareWith comparing field
     * @param  recordId    Account id
     * @param  pageNumber  Page number paramter
     * @param  pageSize    Page size as in count of records to show
     * @return             None
     */
    @AuraEnabled
    public static LtngUtilityCtrl.RecordDataTableWrapper getRecords(string objName , string fieldNames , string compareWith, string recordId , Decimal pageNumber, Decimal pageSize) {
        //System.debug(objName + fieldNames + compareWith + recordId + pageNumber + pageSize);
        return LtngUtilityCtrl.getRecords(objName, fieldNames, compareWith, recordId, pageNumber, pageSize);
    }
   
       /**
* @description [Fetch Recordtype of the Account]
* Added Method for pass Record Type Ticckt No - BK-4977 by Shiv Raghav - 02-06-2020 */
    @AuraEnabled
    public static Id getRecordType(Id recordId) {
        Account oppList = [select id, recordTypeId from Account where id =: recordId];
        Id recId = oppList.recordTypeId;
        return recId;
    }

    //BSM-371 - Garima Gupta
    /**
    * @description : get custom metadata record based on Country code (MasterLabel) from Custom MetaData type.    
    * @return : Map<String, Google_Place_Api_Field_Mapping__mdt>
    **/
    @AuraEnabled
    public static Map<String , Google_Place_Api_Field_Mapping__mdt> getGoogleApiMetaData(){
        return  OppActionButtonController.getGoogleApiMetaData();
    }
}