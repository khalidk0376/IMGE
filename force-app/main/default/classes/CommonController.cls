/**
 * Created By       :   Girikon(Mukesh[STL-16])
 * Created On       :   07/23/2019
 * @description     :   This controller defined auraEnabled action that called from each lwc component
 * Test Class       :   CommonController_Test(91%)
 * Modified by      :   Girikon(Yash Gupta)[10/23/2019]
 **/

public with sharing class CommonController {
    
    /**
     * @description [Check user access]
     * @param  recordId [Record Id to check access permission]
     * @return          [List of UserRecordAccess]
     */
    @AuraEnabled(cacheable=true)
    public static list<UserRecordAccess> getUserRecordAccess(string recordId) {
        List<UserRecordAccess> getUsrRecord = new List<UserRecordAccess>();
        if (Schema.sObjectType.UserRecordAccess.isAccessible()) {
            getUsrRecord = [SELECT RecordId, HasReadAccess, HasDeleteAccess, HasEditAccess, HasTransferAccess, MaxAccessLevel
                            FROM UserRecordAccess
                            WHERE UserId = : userInfo.getUserId() 
                            AND RecordId = : recordId ];
        }
        return getUsrRecord;
    }
    
    /**
     * @description [This method will get the list of order on the basis of param account Id and Ordernumber]
     * @param  recordId [Account Record Id]
     * @return          [List of Order]
     */
    @AuraEnabled(cacheable=true)
    public static list<Order> getOrderList(String recordId) {
        List<Order> getOrderRecord = new List<Order>();
        if (Schema.sObjectType.Order.isAccessible()) {
            getOrderRecord = [SELECT Id, AccountId, Account.Name, Opportunity.AccountId
                              FROM Order 
                              WHERE OrderNumber!=null 
                              AND (AccountId = : recordId OR Opportunity.AccountId = : recordId)];
        }
        return getOrderRecord;
    }

    /**
     * @description [Get record count]
     * @param  objectName [Pass object api name]
     * @param  condtion [pass if any]
     * @return  Integer [record count]
     */
    @AuraEnabled(cacheable=true)
    public static Integer getRecordCount(String objectName,String condtion){
        if(condtion!=''){
            condtion = ' WHERE '+condtion; 
        }
        return Database.countQuery('Select count() from '+objectName+condtion);
    }
    
    /**
     * @description [This method will get the list of Review Team member]
     * @param       [None]
     * @return      [List of Online_Booth_Contract_Review_Team_Member__c]
     */
    /*@AuraEnabled(cacheable=true)
    public static list<Online_Booth_Contract_Review_Team_Member__c> getReviewTeamMembList() {
        List<Online_Booth_Contract_Review_Team_Member__c> getReviewTeamMembRecord = new List<Online_Booth_Contract_Review_Team_Member__c>();
        if (Schema.sObjectType.Online_Booth_Contract_Review_Team_Member__c.isAccessible()) {
            getReviewTeamMembRecord = [SELECT Id,Review_Team__c,Review_Team_Member_User__c,Review_Team__r.Event_Series__c 
                                       From Online_Booth_Contract_Review_Team_Member__c 
                                       WHERE Review_Team_Member_User__c =: Userinfo.getUserId()];
        }
        return getReviewTeamMembRecord;
    }

    /**
     * @description [This method used to check field update permission]
     * @param       [objectName api name, fieldName fieldApiName]     
     * @return      [List of Online_Booth_Contract_Review_Team_Member__c]
     */
    @AuraEnabled(cacheable=true)
    public static Boolean isUpdateable(String objectName,String fieldName){
        SObjectType sObjectTypeObj = Schema.getGlobalDescribe().get(objectName);
        Boolean isUpdate = false;
        if(sObjectTypeObj.getDescribe().isUpdateable()){
            isUpdate = sObjectTypeObj.getDescribe().fields.getMap().get(fieldName).getDescribe().isUpdateable();
        }
        return isUpdate;
    }

    /**
     * @description [This method used to check field insert permission]
     * @param       [objectName api name, fieldName fieldApiName]     
     * @return      [List of Online_Booth_Contract_Review_Team_Member__c]
     */
    @AuraEnabled(cacheable=true)
    public static Boolean isCreateable(String objectName,String fieldName){
        SObjectType sObjectTypeObj = Schema.getGlobalDescribe().get(objectName);
        Boolean isUpdate = false;
        if(sObjectTypeObj.getDescribe().isUpdateable()){
            isUpdate = sObjectTypeObj.getDescribe().fields.getMap().get(fieldName).getDescribe().isCreateable();
        }
        return isUpdate;
    }
    
    /**
    * getDeclinedOptions get all option of declined reason fields of online booth capture.
    * @return   return description
    */
    /*@AuraEnabled(cacheable=true)
    public static Map<String, SchemaUtils.FieldDto> getDeclinedOptions(){
        Map<String,String> objectFieldsMap = new Map<String,String> {               
            'Online_Booth_Capture__c.Reason_Of_Declined__c'=>'Reason_Of_Declined'
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
     * @Name: convertToOppBtnCondition()
     * Description: Get all render logic for "convert to opportunity" button on /lightning/cmp/c__OnlineBoothRequest page. This method called from onlineBoothRequestLwc Component.
     * @param recordId of "Online Booth Capture" custom object.
     * @return   return Map of object
     */
   /* @AuraEnabled(cacheable = true)
    public static Map<String,Object> convertToOppBtnCondition(String recordId){
        Map<String,Object> objMap = new Map<String,Object>{
            'btn1' => false,
            'btn2' => false,
            'btn3' => false,
            'btn4' => false,
            'btn5' => false
        };

        //Online Booth Capture
        List<Online_Booth_Capture__c> obcList = [SELECT Id,Contract_Completed__c,Account__c 
                                                 FROM Online_Booth_Capture__c 
                                                 WHERE Id=:recordId];

        //address verified
        List<Online_Booth_Published_Profile__c> obppList = [SELECT Id FROM Online_Booth_Published_Profile__c 
                                                            WHERE Address_Verified__c = true 
                                                            AND Booth_Capture__c=:recordId];

        //Booth_Application__c
        List<Booth_Application__c> boothAppList = [SELECT Id,Selected_Booth_Id__c FROM Booth_Application__c
                                                   WHERE Online_Booth_Capture__c=:recordId];

        //button 1 render condition => (obppList has no data row and obcList[0].Contract_Completed__c==true)
        if(obppList.isEmpty() && !obcList.isEmpty() && obcList[0].Contract_Completed__c){
            objMap.put('btn1',true);
        }

        //button 2 render condition => (obppList has data rows AND obcList[0].Account__c==null AND obcList[0].Contract_Completed__c==true AND boothAppList[0].Selected_Booth_Id__c==null)
        if(!obppList.isEmpty() && !obcList.isEmpty() && obcList[0].Account__c==null && obcList[0].Contract_Completed__c && !boothAppList.isEmpty() && boothAppList[0].Selected_Booth_Id__c==null){
            objMap.put('btn2',true);
        }

        //button 3 render condition => (obppList has data rows AND obcList[0].Account__c==null AND boothAppList[0].Selected_Booth_Id__c!=null AND obcList[0].Contract_Completed__c==true)
        if(!obppList.isEmpty() && !obcList.isEmpty() && obcList[0].Account__c==null && obcList[0].Contract_Completed__c && !boothAppList.isEmpty() && boothAppList[0].Selected_Booth_Id__c!=null){
            objMap.put('btn3',true);
        }

        //button 4 render condition => (obppList has data rows AND obcList[0].Account__c=!=null AND boothAppList[0].Selected_Booth_Id__c!=null AND obcList[0].Contract_Completed__c==true)
        if(!obppList.isEmpty() && !obcList.isEmpty() && obcList[0].Account__c!=null && obcList[0].Contract_Completed__c && !boothAppList.isEmpty() && boothAppList[0].Selected_Booth_Id__c!=null){
            objMap.put('btn4',true);
        }

        //button 5 render condition => (obppList has data rows AND obcList[0].Account__c=!=null AND boothAppList[0].Selected_Booth_Id__c==null AND obcList[0].Contract_Completed__c==true)
        if(!obppList.isEmpty() && !obcList.isEmpty() && obcList[0].Account__c!=null && obcList[0].Contract_Completed__c && !boothAppList.isEmpty() && boothAppList[0].Selected_Booth_Id__c==null){
            objMap.put('btn5',true);
        }
        return objMap;
    }*/
}