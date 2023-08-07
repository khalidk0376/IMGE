/**
 * Created/Modified By: Girikon(Aishwarya Kumar)
 * Created On:          23/05/2017
 * Modified On:         19/07/2018
 * Description/Purpose: The purpose of this trigger is - To create form permission records on basis of the User Type selected in the Event Edition Form and to prevent user to create
                        Event edition form record with the similar name and event edition.
 * Test Class :         triggersHandler_Test (100%)
 * Last Modified By :   Aishwarya/CCEN-447
 * Modified By Rajesh Kumar - BK-3756 - 11-06-2020
 **/
trigger trgCreateFormPermissionRecords on Event_Edition_Form__c (before insert, after insert, after update) {

    CreateFormPermissionRecords_handler.trgCreateFormPermissionRecords(trigger.new, trigger.newMap, trigger.oldMap , trigger.isinsert, trigger.isUpdate, trigger.isAfter, trigger.isBefore);

}