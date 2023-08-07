/**
* File:        EBEnhancementUtil.cls
* Project:     GAP
* Date:        Nov 22, 2018
* Created By:  Avinash Shukla
* Test class : EbEnhancementUtil_Test
* *************************************************************************
* Description: Util class for new EB enhancement, Sprint 49, GGCW-2690,2692.
* *************************************************************************
* * Modified By Avinash Shukla (Parent_opportunity__c, User_Type__r.Name fields to the Opportunity object Query, FOR BK-2896) 12-02-2020
* History:
*/
public class EBEnhancementUtil {
    // Wrapper class to hold two sets of ids.
    public class wrapClass {
        public Set<Id> parentEbmMapIds;
        public Set<Id> allEbmToUpdate;

        public wrapClass() {
            parentEbmMapIds = new Set<Id>();
            allEbmToUpdate = new Set<Id>();
        }
    }


    /**
     * [udtEbmToInactive : Method to update status of Opportunity_ExpoCAD_Booth_Mapping__c to inactive when corresponding booth is released.]
     * @param ebIds [set of expocadBooth__c Ids]
     */
    public static void udtEbmToInactive(Set<Id> ebIds) {
        if (!ebIds.isEmpty()) {
            List<Opportunity_ExpoCAD_Booth_Mapping__c> lstEbmToInactive = new List<Opportunity_ExpoCAD_Booth_Mapping__c>();
            lstEbmToInactive = [Select Id, Status__c from Opportunity_ExpoCAD_Booth_Mapping__c
                                WHERE Expocad_Booth__c IN : ebIds AND Status__c = 'Active' LIMIT 1000];
            if (!lstEbmToInactive.isEmpty()) {
                for (Opportunity_ExpoCAD_Booth_Mapping__c oEbm : lstEbmToInactive) {
                    oEbm.Status__c = 'Inactive';
                }
                update lstEbmToInactive;
            }
        }
    }

    /**
     * [deactivateEBOppMapping : Method to update status of Expocad and Opportunity mapping records to Inactive.]
     * @param  ebIds        [ExpocadBooth__c record ids]
     * @param  OpportunityId [Related Opportunity of ExpocadBooth__c record]
     * @return              [None]
     */
    Public static void deactivateEBOppMapping(Set<Id> ebmIds) {
        try {
            List<Opportunity_ExpoCAD_Booth_Mapping__c> ebtoUdt = new List<Opportunity_ExpoCAD_Booth_Mapping__c>();
            wrapClass wrapObj = new wrapClass();
            wrapObj = getAllConnectedMappingIds(ebmIds);
            System.debug('Wrap responce === ' + wrapObj);
            if (!wrapObj.allEbmToUpdate.isEmpty()) {
                List<Opportunity_ExpoCAD_Booth_Mapping__c> oppEbMappingsToUdt = new List<Opportunity_ExpoCAD_Booth_Mapping__c>();
                oppEbMappingsToUdt = [Select Id, Status__c from Opportunity_ExpoCAD_Booth_Mapping__c WHERE ID IN : wrapObj.allEbmToUpdate];
                System.debug('Deactivate Records === ' + oppEbMappingsToUdt);
                if (!oppEbMappingsToUdt.isEmpty()) {
                    for (Opportunity_ExpoCAD_Booth_Mapping__c oEbm : oppEbMappingsToUdt) {
                        oEbm.Status__c = 'Inactive';
                        ebtoUdt.add(oEbm);
                    }
                }
            }
            /*
            if (!wrapObj.parentEbmMapIds.isEmpty()) {
                List<Opportunity_ExpoCAD_Booth_Mapping__c> oppEbMappingsRemoveRel = new List<Opportunity_ExpoCAD_Booth_Mapping__c>();
                oppEbMappingsRemoveRel = [Select Id, Related_Opportunity__c from Opportunity_ExpoCAD_Booth_Mapping__c WHERE ID IN :wrapObj.parentEbmMapIds];
                System.debug('Relation Removal Records === ' + oppEbMappingsRemoveRel);
                if (!oppEbMappingsRemoveRel.isEmpty()) {
                    for (Opportunity_ExpoCAD_Booth_Mapping__c oEbm : oppEbMappingsRemoveRel) {
                        if (oEbm.Related_Opportunity__c != NULL) {
                            oEbm.Related_Opportunity__c = NULL;
                            ebtoUdt.add(oEbm);
                        }
                    }
                    //update oppEbMappingsRemoveRel;
                }
            }
            */
            if (!ebtoUdt.isEmpty()) {
                update ebtoUdt;
            }
        } catch (Exception exe) {
            System.debug('Exception === ' + exe);
        }
    }

    /*
     * [ebListFromEbm : Method is used to return list of Eb records related to Ebm(Expocad opportunity mappings) selected]
     * @param  ebIds [List of ExpocadBooth__c ids]
     * @return       [List<ExpocadBooth__c>]
     */
    public static list<ExpocadBooth__c> ebListFromEbm (Set<Id> ebIds) {
        List<ExpocadBooth__c> ebList = new List<ExpocadBooth__c>();
        ebList = [SELECT id, Display_Name__c, Selected__c, Matched_Product_Name__c, Quote__r.Name, Quote__r.SBQQ__Primary__c,
                  User__r.Name, Area__c, Unit_Type__c, Open_Corners__c, Booth_Type__c, Booth_Number__c, Dimensions__c, Last_Action_Date__c,
                  Status__c, Opportunity__c, Account__c, Related_Opportunity__c, Related_Opportunity__r.Name, Opportunity__r.Name,
                  ShowInShow__c, Pavilion__c, Booth_Classes__c, Primary_Contact__r.Name, Primary_Contact__c, BoothContact__r.Name,
                  Booth_Product_Type_EE__c from ExpocadBooth__c WHERE ID IN: ebIds];
        return ebList;
    }

    /**
     * [ebListFromEbm : Method is used to return list of Opp records related to Ebm(Expocad opportunity mappings) selected]
     * @param  ebIds [List of Opportunities ids]
     * @return       [List<Opportunity>]
     */

    public static list<Opportunity> OpListFromEB (Set<Id> opIds) {
        List<Opportunity> opLists = new List<Opportunity>();
        opLists = [SELECT id, SBQQ__PrimaryQuote__c , AccountId , Parent_opportunity__c, User_Type__r.Name, Account.Name ,  Billing_Contact__c , EventEdition__c, EventEdition__r.Expocad_API_Url__c FROM Opportunity  WHERE ID IN: opIds];
        return opLists;
    }

    /**
     * [getAllConnectedMappingIds : Recursion method to get connected list of mapping records to deactivate.]
     * @param  selectedMappingIds [Opportunity_ExpoCAD_Booth_Mapping__c Ids selected for unrenting.]
     * @return                    [set of Opportunity_ExpoCAD_Booth_Mapping__c Ids]
     */
    public static wrapClass getAllConnectedMappingIds(Set<Id> selectedMappingIds) {
        wrapClass wrapObj = new wrapClass();
        wrapObj.allEbmToUpdate = selectedMappingIds;
        Set<Id> selectedIdsChild = new Set<Id>();
        for (Opportunity_ExpoCAD_Booth_Mapping__c oppMaps : [Select Id, Name, Parent_Opp_EB_Mapping__c,
                (Select Id, Name from Opportunity_ExpoCAD_Booth_Mapping__r WHERE Status__c = 'Active')
                from Opportunity_ExpoCAD_Booth_Mapping__c WHERE ID IN : wrapObj.allEbmToUpdate]) {
            if (!oppMaps.Opportunity_ExpoCAD_Booth_Mapping__r.isEmpty()) {
                // Adding the first intance id to the set as one mapping will be conncted and active to only one mapping.
                for (Opportunity_ExpoCAD_Booth_Mapping__c oppMapsObj : oppMaps.Opportunity_ExpoCAD_Booth_Mapping__r)
                    selectedIdsChild.add(oppMapsObj.Id);
            }
            if (oppMaps.Parent_Opp_EB_Mapping__c != NULL) {
                wrapObj.parentEbmMapIds.add(oppMaps.Parent_Opp_EB_Mapping__c);
            }
        }
        if (!selectedIdsChild.isEmpty()) {
            wrapObj.allEbmToUpdate.addAll(getAllConnectedMappingIds(selectedIdsChild).allEbmToUpdate);
        }
        System.debug('wrapObj === ' + wrapObj);
        return wrapObj;
    }

    /**
     * [removeBNFromQLi Method to remove booth number reference from quote line items]
     * @param quoteIdToBoothName [Map of quote ids to set of booth numbers to remove reference from quote line item.]
     */
    public static void removeBNFromQLi(Map<Id, Set<String>> quoteIdToBoothName) {
        List<SBQQ__QuoteLine__c> qliToUpdate = new List<SBQQ__QuoteLine__c>();
        List<SBQQ__Quote__c> allQlis = new List<SBQQ__Quote__c>();
        allQlis = [Select Id, (Select Id, Booth_Number__c from SBQQ__LineItems__r) from SBQQ__Quote__c WHERE ID IN : quoteIdToBoothName.keyset()];
        for (SBQQ__Quote__c sbqq : allQlis) {
            if (!sbqq.SBQQ__LineItems__r.isEmpty()) {
                for (SBQQ__QuoteLine__c qliObj : sbqq.SBQQ__LineItems__r) {
                    if (quoteIdToBoothName.containsKey(sbqq.Id)) {
                        if (quoteIdToBoothName.get(sbqq.Id).contains(qliObj.Booth_Number__c)) {
                            qliObj.Booth_Number__c = NULL;
                            qliToUpdate.add(qliObj);
                        }
                    }
                }
            }
        }
        update qliToUpdate;
    }
    /**
     * [udtEbMPN description]
     * @param ebId [description]
     * @param bPT  [description]
     */
    @future
    public static void udtEbMPN(String ebId, String selectedBpt,String sProdFromExpocad) {
        try {
            List<ExpocadBooth__c> ebList = new LIst<ExpocadBooth__c>();
            List<Booth_Product_Type_Configuration__c> bPtc = new List<Booth_Product_Type_Configuration__c>();
            ebList = [Select Id, Matched_Product_Name__c, Booth_Product_Type_EE__c, Booth_Product_Type__c from ExpocadBooth__c WHERE ID = : ebId];
            bPtc = [Select Id, Name, Matched_Product_Name__c from Booth_Product_Type_Configuration__c WHERE Booth_Product_Type__c = : selectedBpt];

            if (!bPtc.isEmpty() && !ebList.isEmpty()) {
                ebList[0].Booth_Product_Type_EE__c = selectedBpt;
                ebList[0].Matched_Product_Name__c = bPtc[0].Matched_Product_Name__c;
                ebList[0].Booth_Product_Type__c = sProdFromExpocad;
                update ebList[0];
            }
        } catch (Exception ex) {Utility.logError(ex.getMessage(), ex.getCause(), ex.getLineNumber(), ex.getStackTraceString(), 'udtEbMPN(@EBEnhancementUtil.Class)'); }
    }
}