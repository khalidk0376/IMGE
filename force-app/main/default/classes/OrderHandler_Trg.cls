/***
*
* Class Name: OrderHandler_Trg
* Date:  31/1/2019 
* Created By : Rajesh Kumar 
* Created Date : 13/02/2019
* Test Class: OnlyOneMainOrder_Test
* Ticket: GGCW-3124
* ***********************************************************************************************************************************************
* @description This class is used to do the functionality of Process builder "Contract # to order" And "Populate Bill To Contact - Opp to Order" 
* ***********************************************************************************************************************************************\
Modified By  : Rajesh Kumar - BK-3756 on 10-06-2020
*
**/

public with sharing class OrderHandler_Trg implements TriggerInterface_Order.Runnable {
    public void run(TriggerInterface_Order.Trig trig){
        if (trig.isBefore) {
            if (trig.isUpdate) {
                OrderHandler handler = new OrderHandler();
                handler.unallocatePaymentsOnOrder(trig.newList, trig.oldMap);
            }
        }
    }
}