/**
* Class Name:    BatchDeactiveUserBasedOnServiceNow
* Created By :   Adarsh Sharma 
* Created Date : 01/10/2019
* Test Class:    BatchDeactiveUserBasedOnServiceNow_Test
* **************************************************************************************************************************
* @description: This is a Batch Class to Deactivate the User from Org if they are made inactive on Service Now 
* Created By: Adarsh Sharma On 1st Oct 2019 for ticket No :- [BK-2564]
* **************************************************************************************************************************
**/

public class BatchDeactiveUserBasedOnServiceNow implements Database.Batchable<sObject>,Schedulable, Database.Stateful {
    
    public List<Active_Directory_Details__c> listofServiceNowUSer = new List<Active_Directory_Details__c>();   
    public List<User> lstOfUsrDeactivation = new List<User>();   
    public Set<Active_Directory_Details__c> setAD = new Set<Active_Directory_Details__c>();
    Set<string> setupdatedUsrId = new Set<string>(); 
    Map <Id , String > mapUserLst = new Map <Id , String > ();
    Map <String , Active_Directory_Details__c > mapAdLst = new Map <String , Active_Directory_Details__c > ();
    final string sQuery = 'Select id, Active__c, AD_UPN__c , Deactivate_SF_User__c from Active_Directory_Details__c where Active__c = false AND AD_UPN__c != null AND Deactivate_SF_User__c = false';
        
    public Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(sQuery);
    }
    
    public void execute(Database.BatchableContext BC, List<Active_Directory_Details__c> scope){
        try{
            for(Active_Directory_Details__c OAD : scope){
                if (!mapAdLst.containsKey(OAD.AD_UPN__c)){
                     mapAdLst.put(OAD.AD_UPN__c, OAD);
                }
               
            }
            
            if (!mapAdLst.isEmpty()){
                for (User usrs : [Select id, isActive, FederationIdentifier from User where isActive = true and FederationIdentifier IN :mapAdLst.keySet()]){
                    usrs.isActive = false; 
                    lstOfUsrDeactivation.add(usrs);
                    mapUserLst.put(usrs.Id , usrs.FederationIdentifier);
                }
            }
            
            if(!lstOfUsrDeactivation.isEmpty()){
                
                Database.SaveResult [] updateResults = Database.Update(lstOfUsrDeactivation, false);
                
                for(Integer i=0;i<updateResults.size();i++){
                    if (updateResults.get(i).isSuccess()){
                        setupdatedUsrId.add(mapUserLst.get(updateResults.get(i).getId()));
                    }
                }
                if (!setupdatedUsrId.isEmpty()){
                    for (String sTemp : setupdatedUsrId){
                        if (mapAdLst.containskey (sTemp)){
                            Active_Directory_Details__c OAD = mapAdLst.get(sTemp);
                            OAD.Deactivate_SF_User__c = true;
                            setAD.add(OAD);
                        }                   
                    }
                }
            }
            
        }
        catch(Exception ex){
            Utility.logError(ex.getMessage(), ex.getCause(), ex.getLineNumber(),ex.getStackTraceString(), 'Service Now SF User Still Active');
        }
    }
    
    public void finish(Database.BatchableContext BC){ 
        List<Active_Directory_Details__c> lstAD = new List<Active_Directory_Details__c>();
        try{
            if (!setAD.isEmpty()){
                lstAD.addAll(setAD);
                update lstAD;
            }
        }
        catch(Exception ex){       
            Utility.logError(ex.getMessage(), ex.getCause(), ex.getLineNumber(),ex.getStackTraceString(), 'Service Now SF User Still Active');
        }
        
    }
    
    public Void execute(SchedulableContext context){
        BatchDeactiveUserBasedOnServiceNow obj = new BatchDeactiveUserBasedOnServiceNow ();
        database.executebatch(obj,200);
    }
    
    
}