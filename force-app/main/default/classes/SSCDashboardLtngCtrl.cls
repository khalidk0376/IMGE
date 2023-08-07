/****
Created By    : Yash Gupta
Created On    : 8/5/2019
@description  : This is common class for SSC Dashboard.
Test Class    : SSCDashboardLtngCtrl_Test - 94%
Modified By   : Yash Gupta [10/24/2019]
*****/

public with sharing class SSCDashboardLtngCtrl {

    /*
    * @description [This method is used to fetch record of SSC Team Member.]
    * @param       Nothing
    * @return      [List of SSC_Team_Member__c]
    */
    @AuraEnabled(cacheable=true)
    public static list<SSC_Team_Member__c> getSSCTeamMember() {
        List<SSC_Team_Member__c> getSSCTeamRecord = new List<SSC_Team_Member__c>();
            getSSCTeamRecord = [SELECT Id, Name, SSC_Team__c, SSC_Team__r.Name, Is_SalesOps_Member__c , SSC_Team__r.Event_Series__c,SSC_Team__r.Event_Series__r.Name, SSC_Team_Member__c, SSC_Team_Member__r.Name 
                                FROM SSC_Team_Member__c 
                                WHERE SSC_Team_Member__c = : userInfo.getUserId()];
        return getSSCTeamRecord;
    }
    
    /*
    * @description [This method is used to fetch record of Operation Team Member.]
    * @param       Nothing
    * @return      [List of Operations_Team_Member__c]
    */
    @AuraEnabled(cacheable=true)
    public static list<Operations_Team_Member__c> getOperationTeamMember() {
        List<Operations_Team_Member__c> getOperationTeamRecordList = new List<Operations_Team_Member__c>();
            getOperationTeamRecordList = [SELECT Id,Operations_Team__r.Event_Series__c 
                                          FROM Operations_Team_Member__c
                                          WHERE User_Name__c = : userInfo.getUserId()];
        return getOperationTeamRecordList;
    }

    /**
    *  @description [isSSCBrazilUser() Method query on user object to check is logged in user role is 'SSC-Brazil']
    *  @param     n/a
    *  @return   [return true if logged in user role is 'SSC-Brazil' otherwize false]
    */
    @AuraEnabled(cacheable=true)     
    public static Boolean isSSCBrazilUser(){
        Boolean isBrazilUser = false;
        List<User> userList = [Select Id from User Where Id=:UserInfo.getUserId() AND UserRole.Name='SSC-Brazil'];
        if(userList.size()>0){
            isBrazilUser = true;
        }
        return isBrazilUser;
    }
    /**
     * Add “Last Modified Date” field to the Opportunity Dashboard ONLY for Brazil users. 
     * Modified By Rajesh Kumar - BK-3647 - Date - 03-11-2020
     * 
     */
    @AuraEnabled(cacheable=true)     
    public static Boolean isBrazilUser(){
        Boolean isBrazilUser = false;
        List<User> userList = [Select Id from User Where Id=:UserInfo.getUserId() AND Profile.Name = 'Sales-Brasil'];
        if(userList.size()>0){
            system.debug('userList' + userList);
            isBrazilUser = true;
        }
        return isBrazilUser;
    }
  
    /**
    *  @description [getProductBrasilCondition() This method is used to fetch the product brazil table data on the basis od opportunity Id]
    *  @param     Opportunity Id
    *  @return   [return Map of Sting and sObject]
    */
    @AuraEnabled(cacheable=true)
    public static Object getProductBrasilCondition(String oppId){
        return new Map<String,Object>{
            'isShowProductHeader' => isShowProductHeader(oppId),
            'isShowProductAgg_brasil' =>isVisible('001',oppId),
            'isShowProductAgg_brasil1' =>isVisible('002',oppId),
            'isShowProductAgg_brasil2' =>isVisible('003',oppId),
            'isShowProductAgg_brasil3' =>isVisible('004',oppId),
            'isShowProductAgg_brasil4' =>isVisible('005',oppId),
            'isShowProductAgg_brasil5' =>isVisible('006',oppId),
            'isShowProductAgg_brasil6' =>isVisible('007',oppId),
            'isShowProductAgg_brasil7' =>isVisible('008',oppId),
            'isShowProductAgg_brasil8' =>isVisible('009',oppId),
            'isShowProductAgg_brasil10' =>isVisible('010',oppId),
            'isShowProductAgg_brasil11' =>isVisible('011',oppId),
            'isShowProductAgg_brasil12' =>isVisible('012',oppId),
            'isShowProductAgg_brasil13' =>isVisible('013',oppId),
            'isShowProductAgg_brasil14' =>isVisible('014',oppId),
            'isShowProductAgg_brasil15' =>isVisible('015',oppId),
            'isShowProductAgg_brasil16' =>isVisible('016',oppId),
            'isShowProductAgg_brasil17' =>isVisible('017',oppId),
            'isShowProductAgg_brasil18' =>isVisible('018',oppId),
            'isShowProductAgg_brasil19' =>isVisible('019',oppId),
            'isShowProductAgg_brasil20' =>isVisible('020',oppId),
            'isShowProductAgg_brasil21' =>isVisible('021',oppId),
            'isShowProductAgg_brasil22' =>isVisible('022',oppId),
            'isShowProductAgg_brasil23' =>isVisible('023',oppId),
            'isShowProductAgg_brasil24' =>isVisible('024',oppId),
            'isShowProductAgg_brasil25' =>isVisible('025',oppId),
            'isShowProductAgg_brasil26' =>isVisible('026',oppId)
        };
    }
    
    /**
    *  @description [isVisible() This method is used to fetch the list of Quote Line on the basis of codetype and opportunity id]
    *  @param     Code Type and Opportunity Id
    *  @return   [return boolean value]
    */
    @TestVisible
    private static Boolean isVisible(String codeType,String oppId){
        Boolean isVisible = true;
        List<SObject> objList = [SELECT id 
                                 From SBQQ__QuoteLine__c 
                                 WHERE SBQQ__Quote__r.SBQQ__Opportunity2__c=:oppId 
                                 AND SBQQ__Quote__r.SBQQ__Primary__c=true 
                                 AND SBQQ__Product__r.SAP_Material_Code_Type__c=:codeType];
        if(objList.size()==0){
            isVisible = false;
        }
        return isVisible;
    }
    
    /**
    *  @description [isShowProductHeader() This method is used to fetch the list of Quote Line on the basis of primary checkbox]
    *  @param     N/A
    *  @return   [return boolean value]
    */
  @TestVisible
    private static Boolean isShowProductHeader(String oppId){
        boolean isShowProductHeader = false;
        List<SObject> objList = [SELECT id 
                                 From SBQQ__QuoteLine__c 
                                 WHERE SBQQ__Quote__r.SBQQ__Opportunity2__c=:oppId 
                                 AND SBQQ__Quote__r.SBQQ__Primary__c=true];
        if(objList.size()>0){ isShowProductHeader = false;}
        else{
            isShowProductHeader = true;
        }
        return isShowProductHeader;
    }

    /**
     * @description [Get data from aggrement custom object based on opp id. this method used on pending contract tab on SSC Dashboard]
     * @param  opportunity Id and search key
     * @return   [return List of sObject]
     */
    @AuraEnabled(cacheable=true)
    public static List<SObject> getAgreements(String oppId,String searchValue){
        List<SObject> agreementList;
        if(searchValue==''){ agreementList = [Select Name,Opportunity__r.Name,LastModifiedDate 
                                              FROM Agreement__c 
                                              WHERE Opportunity__c=:oppId];
        } else{
            agreementList = [Select Name,Opportunity__r.Name,LastModifiedDate 
                             FROM Agreement__c
                             WHERE Opportunity__c=:oppId 
                             AND (Name like:String.escapeSingleQuotes(searchValue) OR Opportunity__r.Name like:String.escapeSingleQuotes(searchValue))];
        }
        return agreementList;
    }
    
    /**
    * approveContract Approved contract
    * @param  oppObj Pass opportunity Object
    */
    @AuraEnabled(cacheable=false)
    public static void approveContract(Opportunity oppObj, Boolean isSalesOpsProcess){
        List<Opportunity> lstopp = [Select Id,EventEdition__r.Enabled_for_IOM_Billing__c,Approved_Rejected_At_Sales_Ops__c,Approved_Rejected_By_Sales_Ops__c, No_Billing__c, SBQQ__Ordered__c, Status__c, Manual_Contract_Approved__c,Approved_Rejected_By__c,Address_Validation_Bypass__c from Opportunity where Id =: oppObj.Id];
        system.debug('lstopp ::::'+ lstopp);
        for (Opportunity opp : lstopp){
            system.debug('opp.status__c ::::'+ opp.status__c);
            if(isSalesOpsProcess)
            {
                // Modified By Palla Kishore for the ticket BK-26935
            if(opp.Status__c =='Sales Ops Review - Pending'){
                opp.Approved_Rejected_At_Sales_Ops__c = System.now();
                opp.Status__c = 'Pending Accounting Approval';
                opp.Approved_Rejected_By_Sales_Ops__c = UserInfo.getUserId();
            } else {
                if(opp.Status__c =='Pending Accounting Approval' || opp.Status__c =='Awaiting Payment'){
                throw new AuraHandledException('This Opportunity is already Approved.');
                } else if(opp.Status__c =='Rejected by Sales Ops Team' || opp.Status__c =='Accounting Rejected'){
                throw new AuraHandledException('This Opportunity is already Rejected.');   
                } else {
                    throw new AuraHandledException('This Opportunity is not in Closed Won Stage.'); 
                }
            } 
            // End of BK-26935
            }
            else {
               if(opp.Status__c =='Pending Accounting Approval'){
                // Modified By Palla Kishore for the ticket BK-24173
              if (!opp.No_Billing__c && !opp.Address_Validation_Bypass__c){
                  //Modified by Bharath for GECI-804
                    if(!Opp.EventEdition__r.Enabled_for_IOM_Billing__c){
                        opp.SBQQ__Ordered__c = true;
                      }
                }
                opp.Approved_Rejected_At__c = System.now();
                opp.Status__c = 'Awaiting Payment';
                opp.Manual_Contract_Approved__c = true; 
                opp.Approved_Rejected_By__c = UserInfo.getUserId();
            }
             else {
                if(opp.Status__c =='Awaiting Payment'){
                throw new AuraHandledException('This Opportunity is already Approved.');
                } else if(opp.Status__c =='Accounting Rejected'){
                throw new AuraHandledException('This Opportunity is already Rejected.');   
                } else {
                    throw new AuraHandledException('This Opportunity is not in Closed Won Stage.'); 
                }
            }
           }
            
        }
        try{
            update lstopp;
        } catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    /**
    * getRejectionOptions get all option of rejection response fields
    * @return   return description
    */
    @AuraEnabled(cacheable=true)
    public static Map<String, SchemaUtils.FieldDto> getRejectionOptions(){
        Map<String,String> objectFieldsMap = new Map<String,String> {               
            'Opportunity.Rejection_Responses__c'=>'Rejection_Responses'
                };
                    Map<String, SchemaUtils.FieldDto> fields = new Map<String, SchemaUtils.FieldDto>();
        
        Map<String, SchemaUtils.FieldDto> describes = SchemaUtils.describeSobjects(objectFieldsMap.keySet());
        for (String fieldPath : describes.keySet()) {
            SchemaUtils.FieldDto field = describes.get(fieldPath);
            fields.put(objectFieldsMap.get(fieldPath), field);
        }
        return fields;
    }
    
    /** Modified by Palla Kishore --EMEA-93
    * getRejectionOptions get all option of Sales ops rejection response fields
    * @return   return description
    */
    @AuraEnabled(cacheable=true)
    public static Map<String, SchemaUtils.FieldDto> getSalesOpsRejectionOptions(){
        Map<String,String> objectFieldsMap = new Map<String,String> {               
            'Opportunity.Sales_Ops_Rejection_Reason__c'=>'Rejection_Responses'
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
    * getRejectionOptions get all option of rejection response fields
    * @param  sChangedValueJson Pass Updated Opportunity Id
    * @return   return void
    */
    @AuraEnabled(cacheable=false)
    public static string approveRejectAmmendedOpportunit(String sOppId, string sAction, string sSSCNotes, string sReason){
        List<Change_Request__c> listChangeRequest = [Select Id, Account__c, Account__r.Name, Name, Event_Edition__c, Event_Edition__r.Name, Opportunity__c,  Opportunity__r.Name, Amended_Opportunity__c,Amended_Opportunity__r.Name,Change_Request_Status__c 
                                                     From Change_Request__c
                                                     Where Amended_Opportunity__c=:sOppId 
                                                     order by LastModifiedDate DESC 
                                                     limit 1];
        
        Change_Request__c changeRequest = new Change_Request__c();
        if(!listChangeRequest.isEmpty()){ changeRequest=listChangeRequest[0]; }
        Opportunity toUpdateOpportunity = [Select Id,StageName,Rejection_Responses__c,Sales_Ops_Rejection_Reason__c,SSC_Notes__c,Approved_Rejected_By__c,SBQQ__PrimaryQuote__c , Approved_Rejected_At__c
                                           from Opportunity 
                                           where Id=:sOppId];
        if(sAction=='Approve'){
            changeRequest.Change_Request_Status__c='Completed';
            toUpdateOpportunity.Approved_Rejected_By__c=UserInfo.getUserId();
            toUpdateOpportunity.Approved_Rejected_At__c=System.now();
        } else if(sAction=='Reject'){
            changeRequest.Change_Request_Status__c='Rejected';
            toUpdateOpportunity.StageName='Customize';
            toUpdateOpportunity.Status__c = 'Accounting Rejected';
            toUpdateOpportunity.Approved_Rejected_By__c=UserInfo.getUserId();            
            toUpdateOpportunity.Approved_Rejected_At__c=System.now();
            toUpdateOpportunity.SSC_Notes__c=sSSCNotes;
            toUpdateOpportunity.Rejection_Responses__c=sReason;
        }
        try{
            if(!test.isRunningTest()){ update toUpdateOpportunity; update changeRequest; }
            return toUpdateOpportunity.SBQQ__PrimaryQuote__c;
        }
        catch(Exception e){
            system.debug('e.getMessage(): '+e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }        
    }
    
    /**
    * getPickListValuesIntoList get all option of rejection response fields
    * @param  sChangedValueJson Pass Updated Opportunity Id
    * @return   return void
    */
    @auraEnabled (cacheable=true)
    public static List<String> getPickListValuesIntoList(){
        List<String> pickListValuesList= new List<String>();
        Schema.DescribeFieldResult fieldResult = Opportunity.Rejection_Responses__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            pickListValuesList.add(pickListVal.getLabel());
        }
        return pickListValuesList;        
    }
    // Added By Palla Kishore for the ticket BK-26935
    @AuraEnabled
    public static String getOpportunityStatus(string oppId) {
        system.debug('oppId ::::'+ oppId);
        Opportunity opp = [SELECT StageName, Status__c FROM Opportunity WHERE Id = :oppId];
        system.debug('opp ::::'+ opp);
        return opp.Status__c;
    }   
}