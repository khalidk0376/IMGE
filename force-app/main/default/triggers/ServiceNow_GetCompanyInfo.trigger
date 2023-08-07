/**************************************************************************
** Last Modified by Shay Spoonmore (shay.spoonmore@informausa.com)2015-08-28
** NOTE: Trigger will not work with SN callouts because we hit DML limits. Trigger will only work with batches of 200 and the SN callout will do the matching in it’s process.
***************************************************************************/
/**Test Class : zTest_ServiceNowUser
/** Modified By Rajesh Kumar - BK-3756 on 10-06-2020 */
trigger ServiceNow_GetCompanyInfo on Active_Directory_Details__c (Before insert, Before update){

    ServiceNow_GetCompanyInfoHandler.getCompanyInfo(trigger.new , trigger.oldMap , trigger.isInsert, trigger.isUpdate,trigger.isBefore);

}