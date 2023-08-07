/**
 * Created/Modified By: Girikon(Aishwarya)
 * Created On:          01/07/2018
 * Description/Purpose: To perform activities on Form permissions
 * Test Class         : FormManualsHandler_Test
 * Last Modified By   : Aishwarya/CCEN-447, [Aishwarya CCEN-815 June 13 2019]
 * Modified By Rajesh Kumar - BK-3756 - on 11-06-2020
 **/
trigger trgFormPermission on Forms_Permission__c(before insert, after insert, after update){    

    FormPermission_handler.trgFormPermission(trigger.new, trigger.oldmap, trigger.isinsert, trigger.isUpdate,trigger.isAfter,trigger.isBefore);

}