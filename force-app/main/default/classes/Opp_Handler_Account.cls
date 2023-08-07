/**
* Project:     Informa Markets
* Date:        Dec, 9 2019
* Created By:  Avinash Shukla
* Test Class:  Opp_Handler_Account_Test(100%)
* *************************************************************************
* @description This is Handler for Opportunity Trigger. It is used mainly for Account updation.
* *************************************************************************
*/
public with sharing class Opp_Handler_Account {
    /**
     * @description Perform all Operations on Account Object from this method.
     * @param oppNewList New Opportunity List
     * @param oppOldList Old Opportunity List
     * @param oppNewMap  New Opportunity Map
     * @param oppOldMap  Old Opportunity Map
     * @param isAfter    Trigger Event
     * @param isBefore   Trigger Event
     * @param isInsert   Trigger Event
     * @param isUpdate   Trigger Event
     */
    public static void accountAutomation(List<opportunity> oppNewList, List<opportunity> oppOldList, Map<Id, Opportunity> oppNewMap, Map<Id, Opportunity> oppOldMap, Boolean isAfter, Boolean isBefore, Boolean isInsert, Boolean isUpdate) {
        Set<Id> setOpptyId = new Set<Id>();
        for (Opportunity opp : oppNewList) {
            if (isInsert) {
                if ( opp.AccountId != null && opp.EventEdition__c != null ) {
                    setOpptyId.add(opp.id);
                }
            } else if (isUpdate) {
                if ( opp.AccountId != null && opp.EventEdition__c != null && (oppOldMap.get(opp.Id).AccountId != opp.AccountId || oppOldMap.get(opp.Id).EventEdition__c != opp.EventEdition__c ) ) {
                    setOpptyId.add(opp.id);
                }
            }
        }

        /** Account Update Iteration */
        if ( !setOpptyId.isEmpty( ) ) {
            //We have update method for updating business unit and brand to ralted opportunity accunt. : BK -2135 Rajesh Kr - 05-08-2019
            List<Account> lstAccounttoUpdate = new List<Account>( );
            list<Opportunity> oppToProcessOn = new List<Opportunity>();
            oppToProcessOn = [ SELECT Id, AccountId, EventEdition__r.Part_of_Series__r.Brand__r.Name, Account.Brand__c, EventEdition__r.Part_of_Series__r.Brand__r.Business_Unit__c, Account.Business_Unit__c FROM Opportunity WHERE Id In:setOpptyId AND EventEdition__r.Part_of_Series__r.Brand__r.Name != null LIMIT 5000 ];
            for ( Opportunity oTempOpp : oppToProcessOn) {
                if (oTempOpp.AccountId != null) {
                    Account oTempAcc = new Account( );
                    Boolean isFieldUpdated = false;
                    oTempAcc.Id = oTempOpp.AccountId ;
                    if ( String.isBlank(oTempOpp.Account.Brand__c )) {
                        oTempAcc.Brand__c = oTempOpp.EventEdition__r.Part_of_Series__r.Brand__r.Name ;
                        isFieldUpdated = true;
                    } else if (!String.isBlank(oTempOpp.Account.Brand__c )) {
                        Set<String> setBrands = new set<String>( oTempOpp.Account.Brand__c.split(';') );
                        if ( !setBrands.contains(oTempOpp.EventEdition__r.Part_of_Series__r.Brand__r.Name ) ) {
                            oTempAcc.Brand__c = oTempOpp.Account.Brand__c + ';' + oTempOpp.EventEdition__r.Part_of_Series__r.Brand__r.Name ;
                            isFieldUpdated = true;
                        }
                    }
                    if (String.isBlank(oTempOpp.Account.Business_Unit__c)) {
                        if (oTempOpp.EventEdition__r.Part_of_Series__r.Brand__r.Business_Unit__c != '' && oTempOpp.EventEdition__r.Part_of_Series__r.Brand__r.Business_Unit__c != null) {
                            oTempAcc.Business_Unit__c = oTempOpp.EventEdition__r.Part_of_Series__r.Brand__r.Business_Unit__c;
                            isFieldUpdated = true;
                        }
                    } else if (!String.isBlank(oTempOpp.Account.Business_Unit__c)) {
                        Set<String> setBusinessUnit = new set<String>( oTempOpp.Account.Business_Unit__c.split(';'));
                        if (oTempOpp.EventEdition__r.Part_of_Series__r.Brand__r.Business_Unit__c != '' && oTempOpp.EventEdition__r.Part_of_Series__r.Brand__r.Business_Unit__c != null && !setBusinessUnit.contains(oTempOpp.EventEdition__r.Part_of_Series__r.Brand__r.Business_Unit__c ) ) {
                            if (oTempOpp.EventEdition__r.Part_of_Series__r.Brand__r.Business_Unit__c != '' && oTempOpp.EventEdition__r.Part_of_Series__r.Brand__r.Business_Unit__c != null && oTempOpp.EventEdition__r.Part_of_Series__r.Brand__r.Business_Unit__c != '0') {
                                oTempAcc.Business_Unit__c = oTempOpp.Account.Business_Unit__c + ';' + oTempOpp.EventEdition__r.Part_of_Series__r.Brand__r.Business_Unit__c;
                                isFieldUpdated = true;
                            }
                        }
                    }
                    /** Check If any changes are made to the contact Instance and add to the update list*/
                    If(isFieldUpdated) { lstAccounttoUpdate.add( oTempAcc ); }
                }
            }
            /** Update Account Buisness Unit/ Brand */
            if (!lstAccounttoUpdate.isEmpty()) { update lstAccounttoUpdate; }
        }
    }
}