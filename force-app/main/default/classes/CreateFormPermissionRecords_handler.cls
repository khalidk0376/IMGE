/**
 * File:        CreateFormPermissionRecords_handler.cls
 * Project:     GAP
 * Created Date: 11-06-2020
 * Created By:  Rajesh Kumar
 * Modified By:  Rajesh Kumar
 * Test Class: triggersHandler_Test
 * Coverage: 
 *
 * *************************************************************************
 * @description This class is using in trgCreateFormPermissionRecords trigger.
 * *************************************************************************
 * 
 * 
 * History:Ticket :BK-3756
 *
*/

public with sharing class CreateFormPermissionRecords_handler {


    public static void trgCreateFormPermissionRecords(List<Event_Edition_Form__c> newEventEditionFormLst, Map<Id, Event_Edition_Form__c > mapEventEditionFormMapLst , Map<Id, Event_Edition_Form__c > oldmapEventEditionFormMapLst, Boolean isinsert,Boolean isUpdate,Boolean isAfter , Boolean isBefore){


        triggersHandler otriggersHandler = new triggersHandler();
        if(isBefore && isInsert){
            otriggersHandler.CheckDuplicateFormPermissionRecords(newEventEditionFormLst); // Calls the associated otriggersHandler class
        }
        
        if(isAfter && isInsert){
            otriggersHandler.CreateFormPermissionRecords(newEventEditionFormLst, mapEventEditionFormMapLst.KeySet()); // Calls the associated otriggersHandler class
        }
        
        if(isAfter && isUpdate){
            //Boolean ifUserTypeUpdate = false;
            List<String> UtypeIds = new List<String>();
            List<String> UtypeIdsNew = new List<String>();
            List<String> uncheckUserType = new List<String>();  
            Boolean checkIfExpoFieldModify = false;
            Boolean checkIfUserTypeFieldModify = false;
            for(Event_Edition_Form__c eef :oldmapEventEditionFormMapLst.values()){
                String UType = eef.User_Type__c;            
                if(UType != null){
                    UtypeIds = UType.split(';');
                }
            }
            
            for(Event_Edition_Form__c eef :newEventEditionFormLst){
                String UType = eef.User_Type__c;
                if(UType != null){
                    UtypeIdsNew = UType.split(';'); // split the UserType by ';' as there may be more than one User Type.
                }
                for(String str :UtypeIds){
                    if(!UtypeIdsNew.contains(str)){
                        uncheckUserType.add(str);
                    }
                }
                if( (oldmapEventEditionFormMapLst.get(eef.id).Expocad_Booth_Type__c != eef.Expocad_Booth_Type__c) || (oldmapEventEditionFormMapLst.get(eef.id).Expocad_Product_Type__c != eef.Expocad_Product_Type__c) ){
                    checkIfExpoFieldModify = true;
                }
                if(oldmapEventEditionFormMapLst.get(eef.id).User_Type__c != eef.User_Type__c){ //CCEN-447
                    checkIfUserTypeFieldModify = true;
                }
                
            }
            if(checkIfUserTypeFieldModify == true || checkIfExpoFieldModify == true){ //CCEN-447
                otriggersHandler.CreateFormPermissionRecordsUpdate(newEventEditionFormLst, mapEventEditionFormMapLst.KeySet(),uncheckUserType);
            }
            if(checkIfExpoFieldModify == true){
                DeleteFormsManualsToStandContractor oDeleteFormsManualsToStandContractor = new DeleteFormsManualsToStandContractor();
                oDeleteFormsManualsToStandContractor.deleteFormsToStandContractor(newEventEditionFormLst);
            }
        }


    }
}