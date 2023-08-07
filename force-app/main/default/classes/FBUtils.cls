/**
 * Created/Modified By: Girikon(Mahesh/Divaker)
 * Created On:          26 Apr 2018
 * Description/Purpose: Inserting Record  
 * Test Class:  FBUtilTest
 * Code Coverage: 78%
**/
public with sharing class FBUtils {

    public static FBResponse insertRecords(String objectName,Map<Integer,List<KeyValuePair>> recordsToInsert)
    {
        Schema.SObjectType obj = Schema.getGlobalDescribe().get(objectName);
        List<sObject> recordToInsertList = new List<sObject>();
        FBResponse response = new FBResponse();
        String flsError='';
        
        for(Integer key : recordsToInsert.keySet())
        {
            sObject genericObj = obj.newSObject();
            for(KeyValuePair keyValueObj : recordsToInsert.get(key)){                
                //Check FLS
                if(isSafeField(objectName,keyValueObj.fieldName,false,true,false,false)){
                    genericObj.put(keyValueObj.fieldName,keyValueObj.fieldValue);
                }else{
                    if(flsError.trim()==''){
                        flsError = keyValueObj.fieldName;
                    }
                    else{
                        flsError = flsError + ', '+ keyValueObj.fieldName;
                    }
                }
            }
            recordToInsertList.add(genericObj);
        }
        try
        {
            system.debug(flsError);
            //insert record if All fields are createable
            if(flsError==''){
                Database.insert(recordToInsertList, true);
                response.isSuccess=true; 
                response.firstRecordId = recordToInsertList[0].Id;
            }
            else{
                response.isSuccess=false;
                response.flsError = 'You do not have permission to modify '+flsError+' field(s).';
            }
            
        }
        catch(Exception e)
        {
            response.isSuccess=false;
            response.message = e.getMessage();
        }
        return response;
    }
    

    public static List<wrp_cl> getSelectedProfileToCommunity(String networkId)
    {
        Map<Id,Profile> profileMap = new Map<Id,Profile>([Select id,Name from Profile]);
        List<wrp_cl> wplist = new List<wrp_cl>();
        //ParentId is the profile id 
        for(NetworkMemberGroup nmgObj : [SELECT ParentId FROM NetworkMemberGroup WHERE NetworkId=:networkId AND AssignmentStatus='Added'])
        {
            wplist.add(new wrp_cl(nmgObj.ParentId,profileMap.get(nmgObj.ParentId).Name));
        }
        return wplist; 
    }

    public class wrp_cl
    {
        @AuraEnabled public String profileName;
        @AuraEnabled public String profileId;
        public wrp_cl(String profileId,String profileName){
            this.profileName = profileName;
            this.profileId   = profileId;
        }
    }

    
     //Set record id for each record
   public static FBResponse updateRecords(String objectName,Map<Integer,List<KeyValuePair>> recordsToInsert)
    {        
        Schema.SObjectType obj = Schema.getGlobalDescribe().get(objectName);
        List<sObject> recordToInsertList = new List<sObject>();
        FBResponse response = new FBResponse();
        String flsError='';
        
        for(Integer key : recordsToInsert.keySet())
        {
            sObject genericObj = obj.newSObject();
            for(KeyValuePair keyValueObj : recordsToInsert.get(key)){                
                //Check FLS
                if(isSafeField(objectName,keyValueObj.fieldName,false,false,true,false) || (keyValueObj.fieldName=='Id')){
                    genericObj.put(keyValueObj.fieldName,keyValueObj.fieldValue);
                }else{
                    if(flsError==''){
                        flsError = keyValueObj.fieldName;
                    }
                    else{
                        flsError = ', '+keyValueObj.fieldName;
                    }
                }
            }
            recordToInsertList.add(genericObj);
        }
        try
        {
            //insert record if All fields are createable
            system.debug('recordToInsertList'+recordToInsertList);
            if(flsError==''){
                Database.update(recordToInsertList, true);
                response.isSuccess=true;    
            }
            else{
                response.isSuccess=false;
                response.flsError = 'You do not have permission to modify '+flsError+' field(s).';
            }
            
        }
        catch(Exception e)
        {
            response.isSuccess=false;            
            response.message = e.getMessage();
        }
        return response;
    }
    
    public static List<sObject> getRecords(String objectName,String flsFields,String query)
    {
        system.debug('flsFields'+flsFields);
        system.debug('flsFields'+query);
        system.debug('objectName'+objectName);
        String childObj='';
        Boolean isAccessible=true;
        for(String fieldName : flsFields.split(',')){
            childObj='';
            if(fieldName.indexOf('__r.')>0)
            {
           
                childObj  = fieldName.split('\\.')[0]+'_gkn';
                fieldName = fieldName.split('\\.')[1];
                 system.debug('fieldName '+fieldName );
                childObj = childObj.replace('__r_gkn','__c');
                if(!isSafeField(childObj,fieldName,true,false,false,false)){
                    isAccessible = false;
                }
            }
            else
            {      
                if(!isSafeField(objectName,fieldName,true,false,false,false)){
                    isAccessible = false;
                }
            }
        }
        if(isAccessible){   
        system.debug('testisAccessibleA') ;        
            return Database.query(query);   
        }else{
        system.debug('NottestisAccessibleA') ; 
            return new List<sObject>();
        }
    }
    
    public static boolean isSafeField(String objectName,String fieldName,Boolean checkAccessible,Boolean checkCreateable,Boolean checkUpdatable,Boolean checkDeleteable){            
        
        try
        {
            Map <String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
            Transient SObjectType myObj = schemaMap.get(objectName);
            
            if(checkDeleteable)
            {
                return myObj.getDescribe().isDeletable();
            }
            else if (myObj.getDescribe().isAccessible()) 
            {
                if(!myObj.getDescribe().fields.getMap().containsKey(fieldName)){
                    return false;
                }            
                if(checkAccessible)
                {
                    return myObj.getDescribe().fields.getMap().get(fieldName).getDescribe().isAccessible();
                }
                else if(checkCreateable)
                {
                    return myObj.getDescribe().fields.getMap().get(fieldName).getDescribe().isCreateable();
                }
                else if(checkUpdatable)
                {
                    return myObj.getDescribe().fields.getMap().get(fieldName).getDescribe().isUpdateable();
                }
            }
        }
        catch(Exception e)
        {
            System.debug(e.getMessage()+', Line: '+e.getLineNumber());
        }
        return false;
    }
    
    public static boolean isAccessible(String objectName,String fieldName)
    {   
        Map <String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Transient SObjectType myObj = schemaMap.get(objectName);
        
        if (myObj.getDescribe().isAccessible()) 
        {
            for(String fname : fieldName.split(','))
            {
                fname = fname.trim().toLowerCase();
                if(!myObj.getDescribe().fields.getMap().containsKey(fname)){                    
                    return false;
                }
                if(myObj.getDescribe().fields.getMap().get(fname).getDescribe().isAccessible()==false){
                    return false;
                }
            }
            return true;
        }
        return false;
    }

    public static boolean isCreateable(String objectName,String fieldName)
    {   
        Map <String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Transient SObjectType myObj = schemaMap.get(objectName);
        
        if(myObj.getDescribe().isCreateable()) 
        {
            for(String fname : fieldName.split(','))
            {
                fname = fname.trim().toLowerCase();
                if(!myObj.getDescribe().fields.getMap().containsKey(fname)){
                    return false;
                }
                if(myObj.getDescribe().fields.getMap().get(fname).getDescribe().isCreateable()==false){
                    return false;
                }
            }
            return true;
        }
        return false;
    }
    public static boolean isUpdateable(String objectName,String fieldName)
    {   
        Map <String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Transient SObjectType myObj = schemaMap.get(objectName);
        
        if(myObj.getDescribe().isUpdateable()) 
        {
            for(String fname : fieldName.split(','))
            {                
                fname = fname.trim().toLowerCase();
                if(!myObj.getDescribe().fields.getMap().containsKey(fname)){
                    return false;
                }
                if(myObj.getDescribe().fields.getMap().get(fname).getDescribe().isUpdateable()==false){
                    return false;
                }
            }
            return true;
        }
        return false;
    }
    public class FBResponse{
        public Boolean isSuccess;
        public String message;
        public String firstRecordId;
        public String flsError;
         //CCEN747 changes Starts..
        public id responseId;
        public String responseValue;
        public id firstId;
         //CCEN747 changes Starts..
    }
    
    public class KeyValuePair{
        public string fieldName;
        public Object fieldValue;
        public KeyValuePair(string fieldName,Object fieldValue){
            this.fieldName = fieldName;
            this.fieldValue = fieldValue;
        }
    }    
}