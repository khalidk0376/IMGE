public with sharing class ManualPermission_handler {

    public static void trgManualPermission(List<Manuals_Permission__c> newManualPermissionLst, Map<Id, Manuals_Permission__c > oldmapManualPermissionLst, Boolean isinsert,Boolean isUpdate,Boolean isAfter , Boolean isBefore){


        FormManualsHandler handler = new FormManualsHandler();
        //FormManualsHandler.runOnceForManual = true;
        // To avoid Manual & User type mapping duplicacy, Manual permission can be added only once for a User type and Event Edition Form
        if(isBefore && isInsert){
            Boolean checkManualCreation = false;
            FormManualsHandler.runOnceForManual = true; //CCEN-614
            for(Manuals_Permission__c manual :newManualPermissionLst){
                if(manual.PreventStandContractManual__c == false){
                    checkManualCreation = true;
                }
            }
            if(checkManualCreation == true){
                handler.DuplicateCheckOnManualPermission(newManualPermissionLst);
            } 
        }
        // To manage Manual action records
        if(isAfter && isInsert){
            Boolean checkManualCreation = false;
            for(Manuals_Permission__c manual :newManualPermissionLst){
                if(manual.PreventStandContractManual__c == false){
                    checkManualCreation = true;
                }   
            }
            if(checkManualCreation == true){
                set<string> ManualPrmsnID =  new set<string>();
                for(Manuals_Permission__c mp:newManualPermissionLst)
                {
                    ManualPrmsnID.add(mp.Id);   
                }
                FormManualsHandler.CreateUserManualAction(ManualPrmsnID); //CCEN-448
            }
        }
        
        if(isAfter && isUpdate){
            Boolean checkManualCreation = false;
            Boolean checkRollup = false;
            // CCEN-736 added condition for preventing the trigger to fire twice
            //FormManualsHandler.runOnceForManual = true; // Comment this line as per ticket CCEN-815
            List<Manuals_Permission__c> listMPForProceed = new List<Manuals_Permission__c>();
            set<string> ManualPrmsnID =  new set<string>();
            List<User> listUser = new List<User>();
            listUser = [Select Id, Profile.Name FROM User where Id =: UserInfo.getUserId() LIMIT 1];
            for(Manuals_Permission__c manual :newManualPermissionLst) {
                if(manual.PreventStandContractManual__c == false){
                    checkManualCreation = true;
                }
                if(oldmapManualPermissionLst.get(manual.id).Total_User_Count__c != null && oldmapManualPermissionLst.get(manual.id).Total_User_Count__c == manual.Total_User_Count__c && !FormManualsHandler.alreadyProcessed.contains(manual.Id))
                {
                    checkRollup = true;
                    listMPForProceed.add(manual);
                    ManualPrmsnID.add(manual.Id);
                }
            }            
            // calls the handler class
            if(checkManualCreation == true && checkRollup == true && FormManualsHandler.runOnceForManual == false && listUser[0].Profile.Name != 'Customer Community Login User Custom')
            {
                FormManualsHandler.CreateUserManualAction2(ManualPrmsnID); // CCEN-448
            }
        }
    }
}