/**
 * File:        UpdateQuoteOpportunityByDocusign_Trig.cls 
 * Project:     GAP
 * Created Date: 31-03-2020
 * Created By:  Rajesh Kumar
 * Modified By:  Rajesh Kumar
 * Test Class: UpdateQuoteOpportunityByDocusign_Test
 * Coverage: 
 *
 * *************************************************************************
 * @description  When Quote document Sign status is completed then related Quote field primary is update.
 * *************************************************************************
 * History:Ticket :BK-3636
 *
*/

public with sharing class UpdateQuoteOpportunityByDocusign_Trig implements TriggerInterface_QuoteDocument.Runnable {
    public void run(TriggerInterface_QuoteDocument.Trig trig){
        DocuSignAutomateProcessCtrl odocuSignAutomateProcessCtrl = new DocuSignAutomateProcessCtrl(trig.newList, trig.oldMap, trig.isInsert, trig.isUpdate, trig.isAfter);
        odocuSignAutomateProcessCtrl.onAfterInsertUpdate();
    }
}