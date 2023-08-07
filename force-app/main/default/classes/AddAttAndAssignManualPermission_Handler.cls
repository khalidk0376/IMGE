/**
 * File:        AddAttAndAssignManualPermission_Handler.cls
 * Project:     GAP
 * Created Date: 11-06-2020
 * Created By:  Rajesh Kumar
 * Modified By:  Rajesh Kumar

 * Test Class: FormManualsHandler_Test

 * Coverage: 
 *
 * *************************************************************************
 * @description This class is using in trgAddAttAndAssignManualPermission trigger.
 * *************************************************************************
 * 
 * 
 * History:Ticket :BK-3756
 *
*/

public with sharing class AddAttAndAssignManualPermission_Handler {

    public static void trgAddAttAndAssignManualPermission(List<Manual__c> newManualLst, Map<Id, Manual__c > mapManualMapLst , Map<Id, Manual__c > oldmapManualMapLst, Boolean isinsert,Boolean isUpdate,Boolean isAfter){

        
        triggersHandler trgHandler = new triggersHandler();
        if(isAfter && isInsert){
            trgHandler.AssignManualPermission(newManualLst,mapManualMapLst.KeySet());  // Call the corresponding handler class     
        }
        
        if(isAfter && isUpdate){
            List<String> UtypeIds = new List<String>();
            List<String> UtypeIdsNew = new List<String>();
            List<String> uncheckUserType = new List<String>();  
            Boolean checkIfExpoFieldModify = false;
            Boolean checkIfUserTypeFieldModify = false; //CCEN-448
            for(Manual__c manual :oldmapManualMapLst.values()){
                String UType = manual.User_Type__c;            
                if(UType != null){
                    UtypeIds = UType.split(';');
                }
            }
            

            //for(Manual__c manual :oldmapManualMapLst.values()){
            for(Manual__c manual :newManualLst){

                String UType = manual.User_Type__c;
                if(UType != null){
                    UtypeIdsNew = UType.split(';'); // split the UserType by ';' as there may be more than one User Type.
                }
                for(String str :UtypeIds){
                    if(!UtypeIdsNew.contains(str)){
                        uncheckUserType.add(str);
                    }     
                }
                if( (oldmapManualMapLst.get(manual.id).Expocad_Booth_Type__c != manual.Expocad_Booth_Type__c) || (oldmapManualMapLst.get(manual.id).Expocad_Product_Type__c != manual.Expocad_Product_Type__c) ){
                    checkIfExpoFieldModify = true;
                }
                if(oldmapManualMapLst.get(manual.id).User_Type__c != manual.User_Type__c){ //CCEN-448
                    checkIfUserTypeFieldModify = true;
                }
            }
            
            if(checkIfUserTypeFieldModify == true || checkIfExpoFieldModify == true){ //CCEN-448

                //trgHandler.AssignManualPermissionRecordsUpdate(Trigger.New, Trigger.NewMap.KeySet(),uncheckUserType);
                trgHandler.AssignManualPermissionRecordsUpdate(newManualLst, mapManualMapLst.keySet(),uncheckUserType);

            }
            
            if(checkIfExpoFieldModify == true){
                DeleteFormsManualsToStandContractor handler = new DeleteFormsManualsToStandContractor();
                handler.deleteManualsToStandContractor(trigger.new);
            }
        }
    }
}