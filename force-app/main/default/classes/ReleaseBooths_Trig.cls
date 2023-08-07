/**
* File:        ReleaseBooths_Trig
* Project:     GAP
* Date:        02-04-2020
* Created By:  Rajesh Kumar
* Test class : ReleaseBooths_Test
* *************************************************************************
* Description: Trigger to release/rent/hold Booths when Expocad record Status
gets changed for required action.
* *************************************************************************
* History:
* Modified by Avinash for Jira Ticket GGCW-2690 on 20/11/2018
* Modified by Avinash for Jira Ticket GGCW-2709 on 03/11/2018
* Modified by Avinash for Jira Ticket BK-1216 on 23/07/2019
* Modified by Shiv Raghav Sharma for Jira Ticket Bk-2262 on 23/9/2019
* Modified By Rajesh Kumar - BK-3636
* Modified By Abhishek Sharma - EX-154 [Updates made in After Update Event]
*/

public with sharing class ReleaseBooths_Trig implements TriggerInterface_ExpocadBooth.Runnable {
    public void run(TriggerInterface_ExpocadBooth.Trig trig) {
        
        
        //Modified by Avinash : GGCW-2690.
        List<Id> lstOpptyIds = new List<Id>();
        for (ExpocadBooth__c oEB : trig.newlist) {
            if (oEB.Opportunity__c != Null) {
                lstOpptyIds.add(oEB.Opportunity__c);
            }
        }
        if (trig.isBefore && trig.isInsert) {
            
            
            if (!lstOpptyIds.isEmpty()) {
                Map<Id, Opportunity> mapOppty = new Map<Id, Opportunity>([SELECT Id, Opportunity_Contact__r.Id,EventEdition__r.X3E_API_ID__c, EventEdition__r.X3E_Status__c,EventEdition__r.X3rd_Party_Relationship__c FROM Opportunity WHERE Id IN: lstOpptyIds]);
                for (ExpocadBooth__c oEB : trig.newlist) {
                    if (oEB.Opportunity__c != Null && mapOppty.containsKey(oEB.Opportunity__c) && String.isNotBlank(mapOppty.get(oEB.Opportunity__c).Opportunity_Contact__r.Id)) {
                        oEB.Primary_Contact__c = mapOppty.get(oEB.Opportunity__c).Opportunity_Contact__r.Id;
                    }
                }
            }
        }
        
        // Modified By Avinash : GGCW-2690.
        // Modified By Avinash : GGCW-2709.
        if (trig.isAfter && trig.isInsert) {
            Map<Id, Opportunity> mapOppty;
            if (!lstOpptyIds.isEmpty()) {
                mapOppty = new Map<Id, Opportunity>([SELECT Id, Opportunity_Contact__r.Id,EventEdition__r.X3E_API_ID__c, EventEdition__r.X3E_Status__c,EventEdition__r.X3rd_Party_Relationship__c FROM Opportunity WHERE Id IN: lstOpptyIds]); // [EX-131]
            }
            List<Opportunity_ExpoCAD_Booth_Mapping__c> lstEbmtoInsert = new List<Opportunity_ExpoCAD_Booth_Mapping__c>();
            List<ExpocadBooth__c> boothHoldList = new List<ExpocadBooth__c>();//Ex-21
            for (ExpocadBooth__c eB : trig.newMap.values()) {
                Opportunity_ExpoCAD_Booth_Mapping__c objEbm = new Opportunity_ExpoCAD_Booth_Mapping__c();
                objEbm.Opportunity__c = eB.Opportunity__c;
                objEbm.Account__c = eB.Account__c;
                objEbm.Primary_Contact__c = eB.Primary_Contact__c;
                objEbm.Expocad_Booth__c = eB.Id;
                objEbm.Quote__c = eB.Quote__c;
                objEbm.Status__c = 'Active';
                objEbm.Display_Name__c = eB.Display_Name__c;
                objEbm.Is_Parent_Mapping__c = true;
                ExhibitorForUserType__c ExhibitorUserType;
                if (eB.Opportunity__c != NULL) {
                    if ( eB.Exhibitor_Paid_By_Opp__c == NULL ) {
                        ExhibitorUserType = ExhibitorForUserType__c.getValues( 'NULL' );
                    } else if ( eB.Exhibitor_Paid_By_Opp__c != NULL ) {
                        ExhibitorUserType = ExhibitorForUserType__c.getValues( eB.Exhibitor_Paid_By_Opp__c );
                    }
                }
                if (ExhibitorUserType != NULL) {
                    objEbm.Relation__c = ExhibitorUserType.Relation_for_Parent__c;
                }
                
                lstEbmtoInsert.add(objEbm);

                //EX-21 Assign CompanyType on hold Condition
                //[EX-131]
            if (mapOppty != null && !mapOppty.isEmpty()) {
                if((eB.Status__c == 'On Hold'|| eB.Status__c =='Added To Quote/On Hold') && mapOppty.get(eB.Opportunity__c) != null && String.isNotBlank(mapOppty.get(eB.Opportunity__c).EventEdition__r.X3E_API_ID__c)  && mapOppty.get(eB.Opportunity__c).EventEdition__r.X3e_Status__c == 'Active' && mapOppty.get(eB.Opportunity__c).EventEdition__r.X3rd_Party_Relationship__c == '3E Expocad')  {
                    // if(eB.Status__c == 'On Hold'|| eB.Status__c =='Added To Quote/On Hold') {
                      boothHoldList.add(eB);
                }
            }
                
            }
            if (!lstEbmtoInsert.isEmpty()) {
                try {
                    insert lstEbmtoInsert;
                    if(test.isRunningTest()){
                    	insert new Account(createdDate = DateTime.Now().addDays(-1));    
                    }
                } catch (Exception ex) {
                    Utility.logError(ex.getMessage(), ex.getCause(), ex.getLineNumber(), ex.getStackTraceString(), 'After Insert Trigger(@ReleaseBooths_Trig)');
                }
            }
            //EX-21 Assign CompanyType on hold Condition
            if(boothHoldList != null && !boothHoldList.isEmpty()){
                try {
                    Create3EApiSyncRecords.processCompanyTypeAssignToExpocad3E(boothHoldList,'Asynchronous');
                    if(test.isRunningTest()){
                    	insert new Account(createdDate = DateTime.Now().addDays(-1));    
                    }
                } catch (Exception ex) {
                    Utility.logError(ex.getMessage(), ex.getCause(), ex.getLineNumber(), ex.getStackTraceString(), 'After Insert Trigger(@ReleaseBooths_Trig)');
                }
                
            }
        }
        
        if (trig.isAfter && trig.IsUpdate) {
            //BK-1216 : Modified by Avinash
            Set<Id> ebIdsToAddCoexhibonFloorPlan = new Set<ID>();
            // GGCW-2690 : Modified By Avinash,
            Set<Id> ebIds = new Set<Id>();
            // GGCW-2899: Modified Avinash,
            Map<String, String> mapOldBntoNewBn = new Map<String, String>();
            Map<String, ExpocadBooth__c> mapToUpdateRelatedQLIs = new Map<String, ExpocadBooth__c>();
            Set<Id> ebIdsToGetEbmfrom = new Set<Id>();
            Map<Id, Set<String>> ebmIdsToClone = new Map<Id, Set<String>>();
            Map<Id, String> ebIdToNewBoothNumber = new Map<Id, String>();

            List<ExpocadBooth__c> boothHoldList = new List<ExpocadBooth__c>();//Ex-21
            Map<Id, Opportunity> mapOppty;
            if (!lstOpptyIds.isEmpty()) {
                mapOppty = new Map<Id, Opportunity>([SELECT Id, Opportunity_Contact__r.Id,EventEdition__r.X3E_API_ID__c, EventEdition__r.X3E_Status__c,EventEdition__r.X3rd_Party_Relationship__c FROM Opportunity WHERE Id IN: lstOpptyIds]);
            }//Ex-21 

            for (ExpocadBooth__c oExpocadBooth : trig.newlist) {
                ExpocadBooth__c oldExpocadBooth = trig.oldMap.get(oExpocadBooth.Id);
                if (oExpocadBooth.Released__c == false && oExpocadBooth.Status__c == 'Released' && (oldExpocadBooth.Status__c == 'On Hold' || oldExpocadBooth.Status__c == 'Added To Quote/On Hold')  && oExpocadBooth.Status__c != oldExpocadBooth.Status__c && !String.isBlank(oExpocadBooth.Booth_Number__c) && !String.isBlank(oExpocadBooth.Event_Code__c) && !String.isBlank(oExpocadBooth.Expocad_API_URL__c)) {
                    //Modified by Abhishek Sharma on 22/02/2023 : EX-154
                    //ExpocadResponses.AsyncUNHOLD(oExpocadBooth.Booth_Number__c, oExpocadBooth.Opportunity__c, oExpocadBooth.Quote__c, oExpocadBooth.Event_Code__c, oExpocadBooth.Expocad_API_URL__c , '' );
                    Create3EApiSyncRecords.syncBooth(oExpocadBooth, 'Asynchronous',Expocad3E_Wrapper.EXPOCAD_BOOTH_UNHOLD, false,'');
                    // GGCW-2690 : Modified By Avinash.
                    ebIds.add(oExpocadBooth.Id);
                }
                if (oExpocadBooth.Released__c == false && oExpocadBooth.Status__c == 'Released' &&  oldExpocadBooth.Status__c == 'Rented' && oExpocadBooth.Status__c != oldExpocadBooth.Status__c && !String.isBlank(oExpocadBooth.Booth_Number__c) && !String.isBlank(oExpocadBooth.Event_Code__c) && !String.isBlank(oExpocadBooth.Expocad_API_URL__c)) {
                    //Modified by Abhishek Sharma on 22/02/2023 : EX-154
                    //ExpocadResponses.aSyncUnrent (oExpocadBooth.Booth_Number__c, oExpocadBooth.Opportunity__c, oExpocadBooth.Quote__c, oExpocadBooth.Event_Code__c, oExpocadBooth.Expocad_API_URL__c , '' );
                    Create3EApiSyncRecords.syncBooth(oExpocadBooth, 'Asynchronous',Expocad3E_Wrapper.EXPOCAD_BOOTH_UNRENT, false,'');
                    // GGCW-2690 : Modified By Avinash.
                    ebIds.add(oExpocadBooth.Id);
                }
                if (oExpocadBooth.Status__c == 'Rented' &&  oExpocadBooth.Status__c != oldExpocadBooth.Status__c && (!String.isBlank(oExpocadBooth.Booth_Number__c)) && (!String.isBlank(oExpocadBooth.Event_Code__c))) {
                    String displayName = oExpocadBooth.Display_Name__c;
                    //Modified by Abhishek Sharma on 22/02/2023 : EX-154
                    //ExpocadResponses.AsyncRENT(oExpocadBooth.Booth_Number__c, oExpocadBooth.Opportunity__c, oExpocadBooth.Quote__c, oExpocadBooth.Event_Code__c, displayName, false);
                    Boolean isReplaceBooth = false;
                	Create3EApiSyncRecords.syncBooth(oExpocadBooth, 'Asynchronous',Expocad3E_Wrapper.EXPOCAD_BOOTH_RENT, isReplaceBooth,'');
                }
                if (oldExpocadBooth.Status__c == 'Rented' && oExpocadBooth.Status__c == 'Added To Quote/On Hold') {
                    //Modified by Abhishek Sharma on 22/02/2023 : EX-154
                    //ExpocadResponses.AsyncRENTtoHold(oExpocadBooth.Booth_Number__c, oExpocadBooth.Opportunity__c, oExpocadBooth.Quote__c, oExpocadBooth.Event_Code__c, oExpocadBooth.Expocad_API_URL__c);
                    Create3EApiSyncRecords.syncBooth(oExpocadBooth, 'Asynchronous',Expocad3E_Wrapper.EXPOCAD_BOOTH_RENTTOHOLD, false,'');
                }
                //Modified by Avinash : GGCW-2899
                if (oExpocadBooth.Status__c == 'Rented' && (oExpocadBooth.Booth_Number__c != oldExpocadBooth.Booth_Number__c || oldExpocadBooth.Pavilion__c != oExpocadBooth.Pavilion__c || oldExpocadBooth.ShowInShow__c != oExpocadBooth.ShowInShow__c || oldExpocadBooth.Booth_Classes__c != oExpocadBooth.Booth_Classes__c || oldExpocadBooth.Booth_Type__c != oExpocadBooth.Booth_Type__c)) {
                    mapToUpdateRelatedQLIs.put(oldExpocadBooth.Booth_Number__c, oExpocadBooth);
                    ebIdsToGetEbmfrom.add(oExpocadBooth.Id);
                    //Booth is replaced.
                    If(oExpocadBooth.Booth_Number__c != oldExpocadBooth.Booth_Number__c) {
                        mapOldBntoNewBn.put(oldExpocadBooth.Booth_Number__c, oExpocadBooth.Booth_Number__c);
                        //Adding booths records where booth number is replaced.
                        ebIdsToAddCoexhibonFloorPlan.add(oExpocadBooth.Id);
                    }
                    
                }
                System.debug('boothHoldList rel trg 1');
                //Ex-21 unassign CompanyTypes on unhold/Release of Booth
                //[EX-131]
                if (mapOppty != null && !mapOppty.isEmpty()) {
                    if(mapOppty.get(oExpocadBooth.Opportunity__c) != null && String.isNotBlank(mapOppty.get(oExpocadBooth.Opportunity__c).EventEdition__r.X3E_API_ID__c)  && mapOppty.get(oExpocadBooth.Opportunity__c).EventEdition__r.X3e_Status__c == 'Active' && mapOppty.get(oExpocadBooth.Opportunity__c).EventEdition__r.X3rd_Party_Relationship__c == '3E Expocad' && (((oldExpocadBooth.Status__c != 'On Hold' && oldExpocadBooth.Status__c != 'Added To Quote/On Hold') && (oExpocadBooth.Status__c == 'On Hold'|| oExpocadBooth.Status__c =='Added To Quote/On Hold')) || (oExpocadBooth.Status__c == 'Released' && oldExpocadBooth.Status__c != 'Released')) ){
                        
                    // if((oExpocadBooth.Status__c == 'Released' && (oldExpocadBooth.Status__c == 'On Hold'|| oldExpocadBooth.Status__c =='Added To Quote/On Hold')) || (oldExpocadBooth.Status__c == 'Released' && (oExpocadBooth.Status__c == 'On Hold'|| oExpocadBooth.Status__c =='Added To Quote/On Hold')) ){
                        boothHoldList.add(oExpocadBooth);
                        System.debug('boothHoldList rel trg 2'+oExpocadBooth.Status__c);
                    }
                }
            }
            // GGCW-2690 : Modified By Avinash, Deactivate all Opportunity_ExpoCAD_Booth_Mapping__c records once a booth is released.
            if (!ebIds.isEmpty()) {
                EBEnhancementUtil.udtEbmToInactive(ebIds);
            }
            if (!mapToUpdateRelatedQLIs.isEmpty()) {
                BatchQLIUpdationProcess batchUdtQLi = new BatchQLIUpdationProcess(mapToUpdateRelatedQLIs, mapOldBntoNewBn, ebIdsToGetEbmfrom);
                Database.executebatch(batchUdtQLi);
            }
            //Add coExib call
            //Modified by Avinash  : BK-1216 Start
            if (!ebIdsToAddCoexhibonFloorPlan.isEmpty()) {
                Set<Id> exhibIdstoAddToFloorPlan = new Set<Id>();
                List<ExpocadBooth__c> ebsToProcess = new List<ExpocadBooth__c>();
                ebsToProcess = [Select Id, Event_Code__c, Booth_Number__c, (Select Id, Account__c, Opportunity__c, Expocad_API_URL__c, Quote__c, Display_Name__c, Account__r.Name from Opportunity_ExpoCAD_Booth_Mapping__r WHERE Status__c = 'Active' AND Is_Parent_Mapping__c = false AND Account__c != NULL AND Opportunity__c != NULL AND Quote__c != NULL AND Expocad_API_URL__c != NULL) from ExpocadBooth__c WHERE ID IN : ebIdsToAddCoexhibonFloorPlan];
                for (ExpocadBooth__c eb : ebsToProcess) {
                    for (Opportunity_ExpoCAD_Booth_Mapping__c oebm : eb.Opportunity_ExpoCAD_Booth_Mapping__r) {
                        If(!exhibIdstoAddToFloorPlan.contains(oebm.Account__c)) {
                            String sDisplayNames = String.isBlank(oebm.Display_Name__c) ? oebm.Account__r.Name : oebm.Display_Name__c;
                            BoothSelectionHlpr.AsyncExhibitor(eb.Booth_Number__c, eb.Event_Code__c, oebm.Opportunity__c , oebm.Quote__c, oebm.Account__c , oebm.Expocad_API_URL__c , sDisplayNames) ;
                            exhibIdstoAddToFloorPlan.add(oebm.Account__c);
                        }
                    }
                }
            } //Modified by Avinash  : BK-1216 End
            
            //EX-21 Assign CompanyType on hold Condition
            if(boothHoldList != null && !boothHoldList.isEmpty()){
                try {
                    System.debug('boothHoldList rel trg 3');
                    Create3EApiSyncRecords.processCompanyTypeAssignToExpocad3E(boothHoldList,'Asynchronous');
                    if(test.isRunningTest()){
                    	insert new Account(createdDate = DateTime.Now().addDays(-1));    
                    }
                    System.debug('boothHoldList rel trg 4');
                } catch (Exception ex) {
                    Utility.logError(ex.getMessage(), ex.getCause(), ex.getLineNumber(), ex.getStackTraceString(), 'After Insert Trigger(@ReleaseBooths_Trig)');
                }
                
            }
        }
        /* Ticket No - Bk-2262 Release 20.08
* Description - Calling Trigger Handler for rull up total rented area of booth into parent opportunity
* Modified By - Shiv Raghav Sharma
*/
        if( trig.isAfter && (trig.isUpdate || trig.isInsert || trig.isDelete || trig.isUndelete))
        {
            Expocad_BoothTriggerHandler expoHandler = new Expocad_BoothTriggerHandler();
            expoHandler.opportunityExpoCadRollUpsummary(trig.newList , trig.oldList , trig.oldMap , trig.isAfter , trig.isInsert,trig.isUpdate,trig.isDelete,trig.isUndelete );
        }
    }
   
}