/**
* Project:     Informa Markets
* Date:        Dec, 4 2019
* Created By:  Avinash Shukla
* Test Class:  Opp_Handler_Expocad_Test(100%)
* *************************************************************************
* @description This is Handler for Opportunity Trigger. Is used to automate updation on Expocad records related to Opportunity.
* *************************************************************************
*/
public with sharing class Opp_Handler_Expocad {
    /**
     * @description Perform all Operations on Expocad Object from this method.
     * @param oppNewList New Opportunity List
     * @param oppOldList Old Opportunity List
     * @param oppNewMap  New Opportunity Map
     * @param oppOldMap  Old Opportunity Map
     * @param isAfter    Trigger Event
     * @param isBefore   Trigger Event
     * @param isInsert   Trigger Event
     * @param isUpdate   Trigger Event
     */
    public static void expocadAutomation(List<opportunity> oppNewList, List<opportunity> oppOldList, Map<Id, Opportunity> oppNewMap, Map<Id, Opportunity> oppOldMap, Boolean isAfter, Boolean isBefore, Boolean isInsert, Boolean isUpdate) {
        try {
            if (!Utility.isAmendmentProcess) {
                System.debug('After Update Called ::: Expocad Related');
                // Variable declarations.
                Map<Id, Opportunity> mapPrimaryConChangeOppty = new Map<Id, Opportunity>();
                Set<Id> opptIDsforRent = new Set<Id>();
                Set<Id> opptIDsToRelease = new Set<Id>();
                Set<Id> opptIDsToRentToHold = new Set<Id>();
                List<ExpocadBooth__c> lstEBToUpdate;
                // Variable declarations.

                //Modified by Avinash : GGCW-2690 - Date 291118 Expocad Enhancement
                Set<Id> opptIDsToUdtClosedLost = new Set<Id>() ;
                
                for ( Opportunity opp : oppNewList ) {
                    Opportunity oldOpp = oppOldMap.get( opp.Id );
                    System.debug('Opp Old Status  :::  ' + oldOpp.StageName);
                    System.debug('Opp New Status  :::  ' + opp.StageName);
                    

                    if (opp.Parent_Opportunity__c == null) {
                        if (oldOpp.StageName != 'Closed Won' && opp.StageName == 'Closed Won' && opp.Event_Edition_Booth_Rent_Stage__c == 'On Contract' && opp.Payment_Status__c != 'Invoice' ) {
                            opptIDsforRent.add( opp.Id );
                        } else if ( ( opp.StageName != oldOpp.StageName || opp.Payment_Status__c != oldOpp.Payment_Status__c ) &&
                                    ( opp.StageName == 'Closed Won' || opp.StageName == 'Closed Booked' ) &&
                                    ( oldOpp.Payment_Status__c != 'Partial Paid' || oldOpp.Payment_Status__c != 'Paid' ) &&
                                    ( opp.Payment_Status__c == 'Partial Paid' || opp.Payment_Status__c == 'Paid' ) &&
                                    opp.Event_Edition_Booth_Rent_Stage__c == 'On Payment' ) {
                                        System.debug('Expocad Renting Opportunity Ids.');
                            opptIDsforRent.add( opp.Id );
                        }
                        //Modified by Avinash : GGCW-2690 - Date 291118, Merging lines of code with same logic.
                        //Adding condition for batch to run only when we have a related opportunity being closed lost.
                        if ( oldOpp.StageName != 'Closed Lost' && opp.StageName == 'Closed Lost') {
                            if (opp.SBQQ__PrimaryQuote__c != null) {
                                opptIDsToRelease.add( opp.Id );
                            }
                        }
                        String sStageName = System.Label.Opportunity_Stage_Name_Discover;
                        if (opp.Put_Booth_OnHold__c &&  oldOpp.StageName != sStageName && oldOpp.Status__c != 'Accounting Rejected'  && opp.StageName == sStageName && opp.Status__c == 'Accounting Rejected') {
                            opptIDsToRentToHold.add(opp.Id);
                        }
                    }
                    if (opp.Parent_Opportunity__c  != null && opp.StageName == 'Closed Lost' &&  oldOpp.StageName != 'Closed Lost' ) {
                        opptIDsToUdtClosedLost.add(opp.Id);
                    }
                    if (oldOpp.Opportunity_Contact__c != opp.Opportunity_Contact__c  && opp.Opportunity_Contact__c != null) {
                        mapPrimaryConChangeOppty.put(opp.Id, opp);
                    }
                }
                /*@description This class is using in for update exhibitor comment 2 name Rajesh Kumar Date - 25-08-2020 */
                List<Opportunity > lstopp = [Select Id ,User_Type__r.Name, AccountId, User_Type__c , EventEdition__r.Event_Code__c, StageName FROM  Opportunity WHERE Id IN : oppNewList];
                for ( Opportunity opp : lstopp ) {
                    Opportunity oldOpp = oppOldMap.get( opp.Id );
                    if (opp.User_Type__c != oppOldMap.get(opp.Id).User_Type__c && opp.User_Type__r.Name == 'Agent' && (oppOldMap.get(opp.Id).StageName == 'Closed Won' || oppOldMap.get(opp.Id).StageName == 'Closed Booked') ) {
                        BoothSelectionHlpr.AsyncupdateComment2onExbhitor (opp.AccountId , opp.EventEdition__r.Event_Code__c, Opp.Id); 
                    }
                }

                //BK-2812
                //Modified By Avinash : Removing SOQL 101 Governor limit for Salesforce, Optimisation.
                if ( !opptIDsToRelease.isEmpty() || !opptIDsToRentToHold.isEmpty() || !opptIDsforRent.isEmpty() ) {
                    lstEBToUpdate = new List<ExpocadBooth__c>();
                    Set<String> setPrimaryBooths = new Set<String>( );
                    List<ExpocadBooth__c> lstEbToProcess = new List<ExpocadBooth__c>();
                    if (Schema.sObjectType.ExpocadBooth__c.isAccessible()) {
                        lstEbToProcess = [SELECT Booth_Number__c, Status__c, Opportunity__c, Quote__r.SBQQ__Primary__c FROM ExpocadBooth__c WHERE (Opportunity__c IN :opptIDsToRelease AND Status__c != 'Released') OR (Opportunity__c IN :opptIDsToRentToHold AND Status__c = 'Rented') OR Opportunity__c IN :opptIDsforRent OR Opportunity__c IN : mapPrimaryConChangeOppty.keySet()];
                    }
                    for ( ExpocadBooth__c oEB : lstEbToProcess) {
                        //Release Booths
                        if ( opptIDsToRelease.contains(oEB.Opportunity__c) ) { 
                            System.debug('Opp Booth  :::  ' + oEB.Booth_Number__c + ' ::: Is Being rented');
                            oEB.Status__c = 'Released'; 
                            lstEBToUpdate.add(oEB); 
                        }
                        // Make booths from rented to Added to Quote/Hold for Accounting rejected.
                        else if ( opptIDsToRentToHold.contains(oEB.Opportunity__c) ) { 
                            oEB.Status__c = 'Added To Quote/On Hold'; 
                            lstEBToUpdate.add(oEB); 
                        }
                        //Release booth which are on Hold and rent booths who are added to Quote/Hold
                        else if ( opptIDsforRent.contains(oEB.Opportunity__c) ) {
                            if ( !oEB.Quote__r.SBQQ__Primary__c || ( oEB.Quote__r.SBQQ__Primary__c && oEB.Status__c == 'On Hold' ) ) {
                                oEB.Status__c = 'Released';
                                lstEBToUpdate.add( oEB );
                            } else if ( oEB.Status__c == 'Added To Quote/On Hold' &&  oEB.Quote__r.SBQQ__Primary__c) { 
                                oEB.Status__c = 'Rented'; 
                                lstEBToUpdate.add(oEB); 
                            }
                        }
                        if (mapPrimaryConChangeOppty.keySet().contains(oEB.Opportunity__c)) {
                            oEB.Primary_Contact__c = mapPrimaryConChangeOppty.get( oEB.Opportunity__c ).Opportunity_Contact__c ;
                            lstEBtoUpdate.add( oEB );
                        }
                    }
                    if (!lstEBToUpdate.isEmpty()) { 
                        Update lstEBToUpdate; 
                    }
                }
                //Modified by Avinash : GGCW-2690
                if (!opptIDsToUdtClosedLost.isEmpty()) {
                    Map<Id, Opportunity_ExpoCAD_Booth_Mapping__c> mapAllRelatedEbms = new Map<Id, Opportunity_ExpoCAD_Booth_Mapping__c>([ Select Id from Opportunity_ExpoCAD_Booth_Mapping__c WHERE Opportunity__c IN : opptIDsToUdtClosedLost AND Status__c != 'InActive']);
                    If(!mapAllRelatedEbms.isEmpty()) {
                        /**
                         * Calling the Util Class method to deactivate all the Expocad Mapping Records to InActive.
                         */
                        EBEnhancementUtil.deactivateEBOppMapping(mapAllRelatedEbms.keySet());
                    }
                }
            }
        } catch ( exception ex ) {
            Utility.logError(ex.getMessage(), ex.getCause(), ex.getLineNumber(), ex.getStackTraceString(), 'After update - Opportunity.obj(@Opp_Handler_Expocad.class,expocad_Automation)');
        }
    }
}