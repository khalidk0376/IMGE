/**
 * File:        chkBeforeDelete.cls
 * Project:     GAP
 * Created Date: 10-06-2020
 * Created By:  Rajesh Kumar
 * Modified By:  Rajesh Kumar
 * Test Class: Test_checkbeforeDelete
 * Coverage: 
 *
 * *************************************************************************
 * @description This class is using in CPQ_Product_Clone__c Object Trigger.
 * *************************************************************************
 * 
 * 
 * History:Ticket :BK-3756
 *
*/

trigger chkBeforeDelete on CPQ_Product_Clone__c(before delete) {
    ChkBeforeDelete_handler.chkBeforeDelete(Trigger.new, Trigger.oldMap, Trigger.isDelete , Trigger.isBefore);
}