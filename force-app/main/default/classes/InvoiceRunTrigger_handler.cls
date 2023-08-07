/**
 * File:        InvoiceRunTrigger_handler.cls
 * Project:     GAP
 * Created Date: 10-06-2020
 * Created By:  Rajesh Kumar
 * Modified By:  Rajesh Kumar
 * Test Class: InvoiceRunTriggerTest
 * Coverage: 
 *
 * *************************************************************************
 * @description This class is using in blng__InvoiceRun__c Object Trigger InvoiceRunTrigger.
 * *************************************************************************
 * 
 * 
 * History:Ticket :BK-3756
 *
*/

public with sharing class InvoiceRunTrigger_handler {
	public static void callPaymentHandler(List<blng__InvoiceRun__c> newInvoiceRunLst ,Map<Id, blng__InvoiceRun__c> oldmapInvoiceRun , Boolean isAfter, Boolean isUpdate){
		List<Id> invoiceRuns = new List<Id>();
		if(isUpdate && isAfter) {
			for(blng__InvoiceRun__c invoiceRun: newInvoiceRunLst) {
				if(invoiceRun.blng__Status__c == 'Completed' && oldmapInvoiceRun.get(invoiceRun.Id).blng__Status__c != 'Completed') {					invoiceRuns.add(invoiceRun.Id);
				}
			}
			if(invoiceRuns.size() > 0) {
				PaymentHandler pmtHandler = new PaymentHandler();				pmtHandler.updatePaymentInvoiceValue(invoiceRuns);
			}
		}
	}
}