/**
 * Created By:  Girikon(Sunil)
 * Created On:  03/29/2018
 * Modified On: 03/01/2019
 * *************************************************************************
 * Description: This trigger delete sevice map records for the booth mapping.
 * *************************************************************************
 * Test Class   : trgDeleteServicesMap_Test(100%)
 * Last Modified By : Aishwarya / CCEN-570
 * Modified By Rajesh Kumar - Bk-3756 on 11-06-2020
 **/
trigger trgDeleteServicesMap on BoothContractorMapping__c (before delete, after update) {
    DeleteServicesMap_handler oDeleteServicesMap = new DeleteServicesMap_handler(trigger.new, trigger.oldMap, trigger.isDelete, trigger.isUpdate , trigger.isAfter,trigger.isBefore);
    oDeleteServicesMap.trgDeleteServicesMap();
}