/**
 * Created By   :   Girikon(Sunil)[CCEN-304],[CCEN-291]
 * Created On   :   10/09/2018
 * @description  :   Allow ops admin to assign stand contractors on the behalf of exhibitors.
 * Test Class   :   ExhibitorsWithoutContractorsCtrl_Test(93%)
 
 * Modification log --
 * Modified by :  Girikon(Sunil)[CCEN-414], Girikon(Prashant)[CCEN-682 (Mar 22 2019)] Girikon(Rajeev)[Bk-2345() ,Bk-2347(Oct 9 2019)]
 * Modified On: 12/14/2018
 * Modofied by : Himanshu [BK -2173] on 02/09/2019 
 **/
public without sharing class ExhibitorsWithoutContractorsCtrl
{   
    @AuraEnabled//Fetch exhibitors with out contractors [CCEN-414]
    public static ExhibitorsWrapper getExhibitors(String eventId,string column, string order,string srchText,Decimal pageNumber, Decimal pageSize,String matchProductOption )
    {         
        eventId = String.escapeSingleQuotes(eventId);
        column = String.escapeSingleQuotes(column);
        order = String.escapeSingleQuotes(order);

        Integer pSize = (Integer)pageSize;
        Integer pNumber = (Integer)pageNumber;
         
        //Offset for SOQL
        Integer offset = (pNumber - 1) * pSize;
                
        string strQuery='select id,Display_Name__c,Booth_Number__c,Expocad_Booth__r.Matched_Product_Name__c,Opportunity__r.Account.Name,Opportunity__r.Operations_Contact__r.email,Opportunity__r.Operations_Contact__r.phone,Opportunity__r.Operations_Contact__r.MobilePhone,(select Note__c from Notes__r order by createddate desc limit 1) ';
        
        string sCountAndQuery = ' from Opportunity_ExpoCAD_Booth_Mapping__c where Status__c = \'Active\' And Expocad_Booth__r.Status__c = \'Rented\' And (Opportunity__r.User_Type__r.name = \'Exhibitor\' or Opportunity__r.User_Type__r.name = \'Agent Owned Exhibitor\' ) And (Opportunity__r.StageName = \'Closed Won\' OR Opportunity__r.StageName = \'Closed Booked\') And Opportunity__r.EventEdition__c=\''+String.escapeSingleQuotes(eventId) +'\'  And id not In (select Opp_Booth_Mapping__c from BoothContractorMapping__c WHERE Event_Edition__c=\''+String.escapeSingleQuotes(eventId) +'\' and Opp_Booth_Mapping__r.Opportunity__c!= NULL And Opp_Booth_Mapping__r.Expocad_Booth__c != NULL And Opp_Booth_Mapping__r.Status__c = \'Active\' And Opp_Booth_Mapping__r.Expocad_Booth__r.status__c = \'Rented\' And (Contact__c != NULL AND Approved__c = TRUE)) ';
        //BK - 2173
        String matchProductList = '';
        
        //Added this for making matchProductList options dropdown multi select
        for(String s : matchProductOption.split(',')){
            if(matchProductList==''){
                matchProductList='\''+s+'\'';    
            }else{
                matchProductList+=',\''+s+'\'';
            }
        }
        
        if(matchProductOption !='All'){           
            sCountAndQuery += ' And Expocad_Booth__r.Matched_Product_Name__c IN ('+matchProductList+')';    
        }
        
        // End of BK -2173
        if(String.isNotBlank(srchText))
        { 
            srchText = srchText.trim();
            srchText = String.escapeSingleQuotes(srchText);
            sCountAndQuery=sCountAndQuery+' and (Opportunity__r.Account.Name like \'%'+srchText+'%\' or Account__r.Name like \'%'+srchText+'%\' or Display_Name__c like \'%'+srchText+'%\' or Booth_Number__c like \'%'+srchText+'%\' )';
        }
       
        //Total Records
        Integer totalRecords = (Integer)getTotalRows(sCountAndQuery);
        Integer recordEnd = pSize * pNumber;
 
        //Instance of Contact DataTable Wrapper Class
        ExhibitorsWrapper objDT =  new ExhibitorsWrapper();  
        objDT.pageSize = pSize;
        objDT.pageNumber = pNumber;
        objDT.recordStart = offset + 1;
        objDT.recordEnd = totalRecords >= recordEnd ? recordEnd : totalRecords;
        objDT.totalRecords = totalRecords;
        strQuery=strQuery+sCountAndQuery;
        if(String.isNotBlank(column) && String.isNotBlank(order))
        {  
            strQuery=strQuery+' order by '+column+' '+order + ' NULLS LAST ';
        }
        if(pSize>0)
        {  
            strQuery=strQuery+' LIMIT '+ pSize +' OFFSET ' + offset  ;
        }
        // To remove the SOQL Injection Violation [CCEN-682]
        objDT.lstExpocadBooth = UtilityMethods.getDynamicSobjectList(strQuery);
        return objDT;
    }
    @AuraEnabled
    public static Integer getTotalRows(String sCountQuery)
    {
        return database.countQuery('select count() '+sCountQuery);
    }
    //Wrapper Class For Exhibitors DataTable  
    public class ExhibitorsWrapper {
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
        public List<sObject> lstExpocadBooth {get;set;}
    }
    
    @AuraEnabled //Fetch contractor accounts with contacts
    public static list<account> getAccountContacts(String eventId,String srchText)
    {
        list<account> lstacc = StandContractorCtrl.getAccountContacts(eventId,srchText);
        return lstacc;
    }
    @AuraEnabled //Search contractor account
    public static account getAccount(String sEventcode,String srchText)
    {
        account acc= new account();
        acc = StandContractorCtrl.getAccount(sEventcode,srchText); 
        return acc;
    }
    @AuraEnabled //Fetch contractor contacts
    public static contact getContactByID(String contactId)
    { 
        contact con =  StandContractorCtrl.getContactByID(contactId);
        return con;
    }
    @AuraEnabled //Fetch event setiings
    public static Event_Settings__c getEventDetails(String eventId)
    {
        Event_Settings__c eventSetting = new Event_Settings__c ();
        if(string.isNotBlank(eventId) && Schema.sObjectType.Event_Settings__c.isAccessible())    
        { 
            eventSetting = [SELECT Id,Disable_this_information__c,Event_Edition__c 
                            FROM Event_Settings__c 
                            WHERE Event_Edition__c =:eventId 
                            limit 1];
        }
        return eventSetting;
    }
    @AuraEnabled //Fetch contractor services
    public static list<ContractorService__c> getServices(String eventId)
    {
        list<ContractorService__c> lstSonServices = new list<ContractorService__c>();
        if(string.isNotBlank(eventId) && Schema.sObjectType.ContractorService__c.isAccessible())
        {
            lstSonServices = [SELECT Id, Name, Event_Edition__c,Contractor_Service__c, Visible__c 
                              FROM ContractorService__c 
                              where Visible__c=true
                              and Event_Edition__c =:eventId 
                              order by createddate desc 
                              limit 100];
        }
        return lstSonServices;
    }
    @AuraEnabled //Fetch duplicate accounts
    public static List<sObject> getDuplicateContacts(contact con) 
    {
        List<sObject> lstDupCon = StandContractorCtrl.getDuplicateContacts(con);
        return lstDupCon;
    }
    //Create contractor company temporary contact, servives mapping, booth mapping
    //Check exisitng mapping 
    @AuraEnabled
    public static string createContactandMapping(contact con,string sEventId,string tempAccount,list<string> lstBoothIds,list<string> lstServices)
    {
        return StandContractorCtrl.createContactandMapping(con,sEventId,tempAccount,lstBoothIds,lstServices,false);
    } 
    @AuraEnabled //Delete temp account
    public static string deleteTempAccount(String tempAccId)
    {
        return StandContractorCtrl.deleteTempAccount(tempAccId);
    }
    @AuraEnabled //Create temporary contractor company
    public static map<string,sObject>  createTempAccount(account acc)
    {
        map<string,sObject> maptemp=new map<string,sObject>();
        TempAccount__c newTempAcc=new TempAccount__c();
        //Check duplicate reord
        list<sObject> lstResults = StandContractorCtrl.getDuplicateRecords(acc);
        if(lstResults.size()>0)
        {
                maptemp.put('error',lstResults[0]);
        }
        else if(Schema.sObjectType.TempAccount__c.IsCreateable())
        {
            //Create new record
            newTempAcc.Name=acc.Name;
            newTempAcc.Address__c=acc.BillingStreet;
            newTempAcc.City__c=acc.BillingCity;
            newTempAcc.State__c=acc.BillingState;
            newTempAcc.Zip__c=acc.BillingPostalCode;    
            newTempAcc.Country__c=acc.BillingCountry;
            insert newTempAcc;
            maptemp.put('success',newTempAcc);
        }
        return maptemp;
    }
    @AuraEnabled //fetch picklist values.
    public static List<String> getPicklistValues(String objApi,String fieldName)
    { 
        List<String> lstPickvals=new List<String>();    
        lstPickvals = UtilityMethods.getPicklistValues(objApi,fieldName);
        return lstPickvals;  
    }
    // fetch dependent picklist for country and state code [(CCEN -266)]
    @AuraEnabled // Fetch custom picklist values from custom Setting mdt related code towards country[(BK-2347)]
    public static String getDepndentCustomVal(String cCountryCode)
    { 
        String cMobileCode ='';
        List<Dependent_Picklist_Setting__mdt> threatMappings = [SELECT MasterLabel,Controlling_Field_Code__c ,Dependent_Field_Code__c  
                                                                FROM Dependent_Picklist_Setting__mdt 
                                                                Where Controlling_Field_Code__c=:cCountryCode
                                                                Limit 1];
        if(threatMappings.size()>0)
        {
           cMobileCode = threatMappings[0].Dependent_Field_Code__c; 
        }
       return cMobileCode;
    }
    @AuraEnabled // Fetch custom picklist values from custom Setting mdt related code towards country[(BK-2347)]
    public static String getCountryRelatdCode(String cCountryName)
    { 
        String cCountryNameReltdCode ='';
        List<Dependent_Picklist_Setting__mdt> cCodeMappings = [SELECT MasterLabel,Controlling_Field_Code__c ,Dependent_Field_Code__c ,CountryName__c  
                                                               FROM Dependent_Picklist_Setting__mdt 
                                                               where CountryName__c=:cCountryName 
                                                               limit 1];
        if(cCodeMappings.size()>0)
        {
           cCountryNameReltdCode = cCodeMappings[0].Dependent_Field_Code__c; 
        }
       return cCountryNameReltdCode;
    }
    @AuraEnabled  // Fetch Dependent map ]
    public static Map<String, List<String>> getDependentMap(string objApi, string contrfieldApiName,string depfieldApiName) {
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
    public static String base64ToBits(String validFor) {
        if (String.isEmpty(validFor))
        {
             return '';
        }
        String validForBits = '';
        for (Integer i = 0; i < validFor.length(); i++)
        {
            String thisChar = validFor.mid(i, 1);
            Integer val = BASE64CHARS.indexOf(thisChar);
            String bits = decimalToBinary(val).leftPad(6, '0');
            validForBits += bits;
        }
        return validForBits;
    }
    //  Convert decimal or integer value to binary 
    public static String decimalToBinary(Integer val) {
        String bits = '';
        while (val > 0) {
            Integer remainder = Math.mod(val, 2);
            val = Integer.valueOf(Math.floor(val / 2));
            bits = String.valueOf(remainder) + bits;
        }
        return bits;
    }
    private static final String BASE64CHARS = '' +
        'ABCDEFGHIJKLMNOPQRSTUVWXYZ' +
        'abcdefghijklmnopqrstuvwxyz' +
        '0123456789+/';

    private static List<PicklistEntryWrapper> wrapPicklistEntries(List<Schema.PicklistEntry> pLEs) {
        return (List<PicklistEntryWrapper>)
            JSON.deserialize(JSON.serialize(pLEs), List<PicklistEntryWrapper>.class);
    }
    public class PicklistEntryWrapper{
        public String label {get;set;}
        public String value {get;set;}
        public String validFor {get;set;}
        
    }
    
    //BK -2173
    @AuraEnabled // get aggregrate result from booth contract mapping object 
    public static Map<String, String> getAggregateResult(String sEventId) 
    {
        Map<String, String> sdsObjMap = new Map<String, String>();
        AggregateResult []arObjList = new list<AggregateResult>();
        if(Schema.sObjectType.BoothContractorMapping__c.isAccessible()) // EXPOCAD Change CCEN-753
        {
            arObjList = [SELECT count(id), Booth_Design_Status__c 
                         FROM BoothContractorMapping__c 
                         WHERE Event_Edition__c=:sEventId 
                         And ((Opp_Booth_Mapping__r.Opportunity__c!= NULL and Opp_Booth_Mapping__r.status__c = 'Active' And Opp_Booth_Mapping__r.Expocad_Booth__r.status__c = 'Rented' ) 
                         OR (IsManagedbyAgent__c = true And ExpocadBooth__c = null)) 
                         AND (Contact__c != NULL AND Approved__c = TRUE) 
                         Group by Booth_Design_Status__c];
        }        
        String status='';
        for(AggregateResult arObj : arObjList)
        {
            status = String.valueOf(arObj.get('Booth_Design_Status__c'));
            if(status!=null && status!='')
            {
                sdsObjMap.put(status, String.valueOf(arObj.get('expr0')));
            }
        }
        return sdsObjMap;
    } 
    
    
    public class StandDesignStatus
    {
        @AuraEnabled public String key;      
        @AuraEnabled public Integer value; 
    }

   @AuraEnabled // get designation info  with count of designation  for opportunity expocad booth mapping 
    public static List<StandDesignStatus>  getDesignationInfo(String sEventId)
    {
        List<StandDesignStatus> sdsObjList = new List<StandDesignStatus>();
        
        // Added Matched_Product_Name__c to show the count in Designation info of only those which have the substring 'Space Only' in it. [CCEN-593]
        StandDesignStatus obj = new StandDesignStatus();
        obj.key='Total Number of Exhibitors';  // EXPOCAD Change CCEN-753
        String totalExhibitors = 'select count() from Opportunity_ExpoCAD_Booth_Mapping__c where Status__c =  \'Active\' And Expocad_Booth__r.Status__c = \'Rented\' And Opportunity__r.EventEdition__c = \''+String.escapeSingleQuotes(sEventId)+'\' And Opportunity__c != null And Opportunity__r.Operations_Contact__c != null  And (Opportunity__r.StageName = \'Closed Won\' or Opportunity__r.StageName = \'Closed Booked\') And (Opportunity__r.User_Type__r.name = \'Exhibitor\' or Opportunity__r.User_Type__r.name = \'Agent Owned Exhibitor\' )  And Expocad_Booth__r.Matched_Product_Name__c LIKE \'%'+ 'Space Only'+'%\'';        
        obj.value=Database.countQuery(totalExhibitors);
        sdsObjList.add(obj); 

        StandDesignStatus obj2 = new StandDesignStatus();
        obj2.key='Exhibitors without Contractors';  // EXPOCAD Change CCEN-753
        String exhWithoutContractors = 'select count() from Opportunity_ExpoCAD_Booth_Mapping__c where  Status__c =  \'Active\' And Expocad_Booth__r.Status__c = \'Rented\' And Opportunity__r.EventEdition__c = \''+String.escapeSingleQuotes(sEventId)+'\' And Opportunity__c != null And Opportunity__r.Operations_Contact__c != null  And (Opportunity__r.StageName = \'Closed Won\' or Opportunity__r.StageName = \'Closed Booked\') And (Opportunity__r.User_Type__r.name = \'Exhibitor\' or Opportunity__r.User_Type__r.name = \'Agent Owned Exhibitor\' ) And id not In (select Opp_Booth_Mapping__c from BoothContractorMapping__c  where Event_Edition__c =\''+String.escapeSingleQuotes(sEventId)+'\' and (Opp_Booth_Mapping__r.Opportunity__c!= NULL and Opp_Booth_Mapping__r.Expocad_Booth__r.status__c = \'Rented\' And Opp_Booth_Mapping__r.Status__c =  \'Active\' )AND (Contact__c != NULL AND Approved__c = TRUE)) And Expocad_Booth__r.Matched_Product_Name__c LIKE \'%'+ 'Space Only'+'%\'';
        obj2.value=Database.countQuery(exhWithoutContractors);         
        sdsObjList.add(obj2);
         
        return sdsObjList; 
    } 
    //End of BK - 2173
    //Starts with Regarding Ticket BK-2345
    @AuraEnabled
    public static List<account> PrefContractors(string EventCode , string srchText)
    {
        List<String> tempList = new List<String>();
        Event_Edition__c evntEdtn = new Event_Edition__c();
        evntEdtn=[select id , name , Preferred_Contractors__c from Event_Edition__c where id=:EventCode];
        if(evntEdtn.Preferred_Contractors__c!=null)
        {
            tempList.addall(evntEdtn.Preferred_Contractors__c.split(';'));
        }
        
        String strQuery = 'select Id,Name,BillingCountry,(select Id,Name,Contact_Type__c  from contacts) from account where id IN:tempList';       
        if(String.isNotEmpty(srchText)) 
        {
            string whereClause = '%' + String.escapeSingleQuotes(srchText) + '%';
            strQuery+=' and Name like :whereClause ';
        }
        strQuery+=' order by name asc limit 100';
        list<account> preferrdAccs = new list<account>();
        preferrdAccs = Database.query(strQuery);  
        return preferrdAccs;
    }
    //Regarding Ticket STL-231

    @AuraEnabled// Check is org sandbox or prod
    public static Boolean isSandbox(){
        Boolean isSandBox = true;
        List<Organization> orgList = [Select ID, IsSandBox 
                                      from Organization 
                                      limit 1];
        if(!orgList.isEmpty()){
            isSandBox = orgList[0].IsSandBox;
        }
        return isSandBox;
    }
}