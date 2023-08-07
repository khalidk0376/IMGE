/**
 * Created/Modified By: Girikon(Aishwarya)/Aishwarya
 * Created On:          24/05/2017
 * Modified On:         18/07/2018
 * Description/Purpose: To Insert Manual Permission record 
 * Test Class:          FormManualsHandler_Test 100%)
 * Last Modified By :   Aishwarya/CCEN-448
 * Modified By Rajesh Kumar : BK-3756  - 11-06-2020
 **/
trigger trgAddAttAndAssignManualPermission on Manual__c (after insert, after update)
{

    AddAttAndAssignManualPermission_Handler.trgAddAttAndAssignManualPermission(trigger.new, trigger.newMap,trigger.oldMap , trigger.isinsert, trigger.isUpdate,trigger.isAfter);

}