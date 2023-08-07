/**
 * Project:     GAP
 * Date:        Jan, 22 2019
 * Created By:  Avinash Shukla
 * Test Class:ReleaseBooths_Test
 * *************************************************************************
 * Description: Batch for updation of quote line items to related quote
 * *************************************************************************
 */
public class BatchQLIUpdationProcess implements Database.Batchable<sObject>, Database.Stateful {
    private Set<Id> ebIds;
    private List<SBQQ__QuoteLine__c> qliToUpdateFinal;
    private Map<String, ExpocadBooth__c> boothNumberToEb;
    private Map<String, String> oldToNewBn;
    public BatchQLIUpdationProcess(Map<String, ExpocadBooth__c> mapToUpdateRelatedQLIs, Map<String, String> mapOldBntoNewBn, Set<Id> ebIdsToGetEbmfrom) {
        boothNumberToEb = mapToUpdateRelatedQLIs;
        oldToNewBn = mapOldBntoNewBn;
        ebIds = ebIdsToGetEbmfrom;
        qliToUpdateFinal = qliToProcess();
    }

    Public List<SBQQ__QuoteLine__c> qliToProcess() {
        try {
            List<SBQQ__QuoteLine__c> qliToUpdate = new List<SBQQ__QuoteLine__c>();
            Set<Id> quoteIds = new Set<Id>();
            List<Opportunity_ExpoCAD_Booth_Mapping__c> oppEbm = new List<Opportunity_ExpoCAD_Booth_Mapping__c>();
            for (Opportunity_ExpoCAD_Booth_Mapping__c oEbm : [Select Id, Quote__c from Opportunity_ExpoCAD_Booth_Mapping__c WHERE Status__c = 'Active' AND Expocad_Booth__c IN: ebIds AND Quote__c != NULL]) {
                quoteIds.add(oEbm.Quote__c);
            }
            List<SBQQ__Quote__c> lstQuote = new List<SBQQ__Quote__c>();
            lstQuote = [Select Id, (Select Id, Booth_Type__c, Booth_Number__c, Show_In_Show__c, Booth_Pavilion__c, Booth_Classes__c from SBQQ__LineItems__r) from SBQQ__Quote__c WHERE Id IN : quoteIds];
            for (SBQQ__Quote__c qt : lstQuote) {
                for (SBQQ__QuoteLine__c qli : qt.SBQQ__LineItems__r) {
                    boolean changesMade = false;
                    SBQQ__QuoteLine__c qliTemp = qli;
                    if (boothNumberToEb.containsKey(qli.Booth_Number__c)) {
                        //If booth type was updated
                        If(qliTemp.Booth_Type__c != boothNumberToEb.get(qliTemp.Booth_Number__c).Booth_Type__c) { qliTemp.Booth_Type__c = boothNumberToEb.get(qliTemp.Booth_Number__c).Booth_Type__c; changesMade = true; }
                        //If show in show was updated
                        If(qliTemp.Show_In_Show__c != boothNumberToEb.get(qliTemp.Booth_Number__c).ShowInShow__c) { qliTemp.Show_In_Show__c = boothNumberToEb.get(qliTemp.Booth_Number__c).ShowInShow__c; changesMade = true; }
                        //If booth pavilion was updated
                        If(qliTemp.Booth_Pavilion__c != boothNumberToEb.get(qliTemp.Booth_Number__c).Pavilion__c) {  qliTemp.Booth_Pavilion__c = boothNumberToEb.get(qliTemp.Booth_Number__c).Pavilion__c; changesMade = true; }
                        //If booth classes was updated
                        If(qliTemp.Booth_Classes__c != boothNumberToEb.get(qliTemp.Booth_Number__c).Booth_Classes__c) { qliTemp.Booth_Classes__c = boothNumberToEb.get(qliTemp.Booth_Number__c).Booth_Classes__c; changesMade = true; }
                        //If booth was replaced/booth number was updated.
                        If(oldToNewBn.containsKey(qli.Booth_Number__c)) { If(qliTemp.Booth_Number__c != oldToNewBn.get(qliTemp.Booth_Number__c)) { qliTemp.Booth_Number__c = oldToNewBn.get(qliTemp.Booth_Number__c); changesMade = true; } }

                    }
                    if (changesMade) qliToUpdate.add(qliTemp);
                }
            }
            return qliToUpdate;
        } catch (Exception ex) { Utility.logError(ex.getMessage(), ex.getCause(), ex.getLineNumber(), ex.getStackTraceString(), 'qliToProcess(@BatchUpdateEbMapping.Class)'); return new List<SBQQ__QuoteLine__c>(); }
    }

    public Iterable<sObject> start(Database.BatchableContext bc) { return qliToUpdateFinal; }

    public void execute( Database.BatchableContext bc, List<SObject> scope) { try { update scope; } catch (Exception ex) { Utility.logError(ex.getMessage(), ex.getCause(), ex.getLineNumber(), ex.getStackTraceString(), 'Execute(@BatchUpdateEbMapping.Class)'); } }
    public void finish(Database.BatchableContext bc) {
        System.debug('Batch Completed');
    }
}