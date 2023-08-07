/**
 * Project:     GAP
 * Date:        Nov, 27 2018
 * Created By:  Avinash Shukla
 * Test Class:  BatchUpdateEbMapping_Test
 * *************************************************************************
 * Description: Batch for Deactivation of all child Opportunity_ExpocadBooth_Mappings__c when any opportunity is closed Lost.
 * *************************************************************************
 * History: Modified by Avinash for Jira Ticket GGCW-2690 on 20/11/2018
 */
public class BatchUpdateEbMapping implements Database.Batchable<sObject>, Database.Stateful {
    public Map<Id, Set<String>> quoteToBoothNumber;
    public EBEnhancementUtil.wrapClass wrapObjN;
    public EBEnhancementUtil.wrapClass wrapObjN2;
    public set<Id> allEbmIds;
    public set<Id> ebmIdsToUdt;
    public set<Id> parentEbm;
    public set<Id> ebmIdsToUdt2;
    public set<Id> parentEbm2;
    public BatchUpdateEbMapping(Set<Id> ebmIdsParam) {
        quoteToBoothNumber = new Map<Id, Set<String>>();
        wrapObjN = new EBEnhancementUtil.wrapClass();
        wrapObjN2 = new EBEnhancementUtil.wrapClass();
        wrapObjN2 = EBEnhancementUtil.getAllConnectedMappingIds(ebmIdsParam);
        wrapObjN = EBEnhancementUtil.getAllConnectedMappingIds(ebmIdsParam);
        System.debug(wrapObjN);

        ebmIdsToUdt = wrapObjN.allEbmToUpdate;
        parentEbm = wrapObjN.parentEbmMapIds;
        allEbmIds = wrapObjN.parentEbmMapIds;
        allEbmIds.addAll(wrapObjN.allEbmToUpdate);

        ebmIdsToUdt2 = new Set<Id>();
        ebmIdsToUdt2 = wrapObjN2.allEbmToUpdate;
        parentEbm2 = new Set<Id>();
        parentEbm2 = wrapObjN2.parentEbmMapIds;

    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'Select Id, Name, Status__C, Quote__c, Booth_Number__c, Related_Opportunity__c from Opportunity_ExpoCAD_Booth_Mapping__c WHERE ID IN : allEbmIds';
        return Database.getQueryLocator(query);
    }

    public void execute( Database.BatchableContext bc, List<Opportunity_ExpoCAD_Booth_Mapping__c> scope) {
        try {
            for (Opportunity_ExpoCAD_Booth_Mapping__c oEbmObj : scope) {
                if (!parentEbm2.contains(oEbmObj.Id)) {
                    oEbmObj.Status__c = 'Inactive';
                    if (quoteToBoothNumber.containsKey(oEbmObj.Quote__c)) {
                        quoteToBoothNumber.get(oEbmObj.Quote__c).add(oEbmObj.Booth_Number__c);
                    } else {
                        Set<String> boothNumberSet = new Set<String>();
                        boothNumberSet.add(oEbmObj.Booth_Number__c);
                        quoteToBoothNumber.put(oEbmObj.Quote__c, boothNumberSet);
                    }
                }
            }
            update scope;
        } catch (Exception ex) { Utility.logError(ex.getMessage(), ex.getCause(), ex.getLineNumber(), ex.getStackTraceString(), 'Execute(@BatchUpdateEbMapping.Class)'); }
    }
    public void finish(Database.BatchableContext bc) {
        System.debug('Batch Completed, Now Calling QLI Booth refernece removal : ');
        if (!quoteToBoothNumber.isEmpty()) { EBEnhancementUtil.removeBNFromQLi(quoteToBoothNumber); }
    }
}