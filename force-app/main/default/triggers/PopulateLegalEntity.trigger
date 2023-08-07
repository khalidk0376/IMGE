/**
* Class Name: PopulateLegalEntity trg
* Created By : Rajesh Kumar 
* Created Date : 13/02/2019
* Test Class: InvoiceHandlerFromQuote_Test 
* Test Class: --
* **************************************************************************************************************************
* @description: This trigger is used to do the functionality of Process builder "SFB Populate Legal Entity on Order Product v2" 
* **************************************************************************************************************************
* Modified By - Rajesh Kumar - on 30-07-2020 to BK-6532 / Modified By Rajesh KUmar : Bk-6918 - Date : 03-09-2020
*/


trigger PopulateLegalEntity on OrderItem (After Insert, After Update , Before Update) {


    if (Trigger.isAfter && Trigger.isInsert){
        PopulateLegalEntity_class.updateLegalEntity(Trigger.new);
    } 
    //Modified By Rajesh KUmar : Bk-6918 - Date : 03-09-2020
    if (Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)){
       PopulateLegalEntity_class.maxrollupsummery(Trigger.new, Trigger.oldMap, Trigger.isInsert, Trigger.isUpdate);
    }


    //MOdified By Rajesh Kumar : BK-11310 (We have blank value all custom tax call fields)
    if (Trigger.isBefore && Trigger.isUpdate){
       PopulateLegalEntity_class.resetSAPTAXCallFields(Trigger.new);
    }


}