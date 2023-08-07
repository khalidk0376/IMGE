/**
 * File:        FormPermission_handler.cls
 * Project:     GAP
 * Created Date: 11-06-2020
 * Created By:  Rajesh Kumar
 * Modified By:  Rajesh Kumar
 * Test Class: 
 * Coverage: 
 *
 * *************************************************************************
 * @description This class is using in trgFormPermission trigger.
 * *************************************************************************
 * 
 * 
 * History:Ticket :BK-3756
 *
*/

public with sharing class FormPermission_handler {

    public static void trgFormPermission(List<Forms_Permission__c> newFormPermissionLst, Map<Id, Forms_Permission__c > oldmapFormPermissionLst, Boolean isinsert,Boolean isUpdate,Boolean isAfter , Boolean isBefore){

        FormManualsHandler handler = new FormManualsHandler();
        // To avoid Event Edition Forms & User type mapping duplicacy, form permission can be added only once for a User type and Event Edition Form
        if(isBefore && isInsert){
            Boolean checkFormCreation = false;
            FormManualsHandler.runOnce = true;
            for(Forms_Permission__c fp: newFormPermissionLst){
                if(fp.PreventStandContractForm__c == false)
                    checkFormCreation = true;
            }
            if(checkFormCreation == true)
                handler.DuplicateCheckOnFormPermission(newFormPermissionLst); // Calls the handler class
        }
        // To manage formaction records
        if(isAfter && isInsert)
        {
            Boolean checkFormCreation = false;
            for(Forms_Permission__c fp: newFormPermissionLst){
                if(fp.PreventStandContractForm__c == false)
                    checkFormCreation = true;
            }
            if(checkFormCreation == true )
            {
                set<string> FormPrmsnID =  new set<string>();
                for(Forms_Permission__c fp:newFormPermissionLst)
                {
                    FormPrmsnID.add(fp.Id);   
                }
                FormManualsHandler.CreateUserFormAction(FormPrmsnID); //CCEN-447
                //handler.CreateUserFormActionRecords(newFormPermissionLst); // Calls the handler class  
            }    
        }
        
        if(isAfter && isUpdate)
        {
            Boolean checkFormCreation = false;
            Boolean checkRollup = false;
            //FormManualsHandler.runOnce = true; // Comment this line as per ticket CCEN-815
            List<Forms_Permission__c> listFPForProceed = new List<Forms_Permission__c>();
            set<string> FormPrmsnID =  new set<string>();
            List<User> listUser = new List<User>();
            listUser = [Select Id, Profile.Name FROM User where Id =: UserInfo.getUserId() LIMIT 1];

            for(Forms_Permission__c fp: newFormPermissionLst){

                if(fp.PreventStandContractForm__c == false){
                    checkFormCreation = true;
                }

                if(oldmapFormPermissionLst.get(fp.id).Total_User_Count__c != null && oldmapFormPermissionLst.get(fp.id).Total_User_Count__c == fp.Total_User_Count__c && !FormManualsHandler.alreadyProcessed.contains(fp.Id)){
                    checkRollup = true;
                    listFPForProceed.add(fp);
                    FormPrmsnID.add(fp.Id);
                }
            }
            
            if(checkFormCreation == true && checkRollup == true && FormManualsHandler.runOnce == false && listUser[0].Profile.Name != 'Customer Community Login User Custom'){
                //handler.CreateUserFormActionRecords(newFormPermissionLst); // Calls the handler class
                FormManualsHandler.CreateUserFormAction2(FormPrmsnID); //CCEN-447
            }
        }
    }
}