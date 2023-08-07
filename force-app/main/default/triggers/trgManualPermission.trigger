/**
 * Created/Modified By  : Girikon(Aishwarya)
 * Created On           : 01/07/2018
 * Modified On          :         
 * @description         : To perform activities on Manual Permission
 * Test Class           : FormManualsHandler_Test
 * LastModifiedBy       : Girikon[Aishwarya CCEN-448, CCEN-614 Feb 06 2019, CCEN-736 May 2 2019, CCEN-815 June 13 2019]
 * Modified By Rajesh Kumar - BK-3756 - 11-06-2020 
 **/
trigger trgManualPermission on Manuals_Permission__c (before insert, after insert, after update) {

    ManualPermission_handler.trgManualPermission(trigger.new,trigger.oldMap,trigger.isinsert,trigger.isUpdate, trigger.isAfter, trigger.isBefore);

        
}