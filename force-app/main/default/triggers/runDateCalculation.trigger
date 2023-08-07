/**
 * File:        runDateCalculation.tgr
 * Project:     GAP
 * Date:        17/10/2017
 * Created By:  Abdul Kadir
 * Test Class:  RunDateCalculation_test
 * *************************************************************************
 * Description: to impose run date functionality on Opportunity Line Items.
 * *************************************************************************
 * History:Modified BY Rajesh Kumar - Date - 10-06-2020 - BK-3756
 */
trigger runDateCalculation on OpportunityLineItem(before insert , after update) {
    RunDateCalculation_handler.runDateCalculation(trigger.new , trigger.oldMap , trigger.isInsert, trigger.isUpdate,trigger.isAfter,trigger.isBefore);
}