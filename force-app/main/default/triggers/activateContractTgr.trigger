/**
 * File:        activateContractTgr
 * Project:     GAP
 * Date:        June 28, 2017
 * Created By:  Kumar Gaurav
 * *************************************************************************
 * Description: activateContractTgr is mainly to activate Contract and update 
                Opportunity's Main Contract and Contract Number
 * *************************************************************************
 * History: Modified By Rajesh Kumar - BK-3756 on 11-062020 
 Test Class : InvoiceHandlerFromQuote_Test
 */

trigger activateContractTgr on Contract (after insert) {
   ActivateContract_Handler.activecontract(Trigger.new, Trigger.oldMap, Trigger.isInsert, Trigger.isAfter );
}