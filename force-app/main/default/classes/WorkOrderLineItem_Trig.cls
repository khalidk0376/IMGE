/**
 * File:        WorkOrderLineItem_Trig.cls
 * Project:     GAP
 * Date:        06/11/2019
 * Test Class : Test_WorkOrderLineItem_Trig(89%)
 * Created By:  Avinash Shukla (Utilised Existing Trigger SendEMail ::: Conversion to Trigger Management App.)
 * *************************************************************************
 * Description: Send Email to WO/ WOLIs owners when OLIs are closed and or The assigned user is updated from to some other value.
 * *************************************************************************
 * History: Update by Abdul Kadir : Work Order Changes(GGCW-1663).
 * Modified by Avinash : BK-12 6/11/2019 : Removing Email exception of too many email invocation.
 * Added Reindent for the code for Better allignment for code in the trigger.
 */

Public without sharing class WorkOrderLineItem_Trig implements TriggerInterface_WorkOrderLineItem.Runnable {
    public void run(TriggerInterface_WorkOrderLineItem.Trig trig) {
        if (trig.isAfter && (trig.isUpdate || trig.isInsert)) {
            sendEmail(trig);
        }
        if (trig.isBefore && trig.isDelete) {
            deleteLine(trig);
        }
    }
    /** Allow deletion of Work OLIs is logged in User is the Owner **/
    Public void deleteLine(TriggerInterface_WorkOrderLineItem.Trig trig) {
        for (WorkOrderLineItem woli : trig.oldList) {
            if (woli.isOwnerSame__c == 'False'){ woli.adderror('You can only delete the record which is Owned by you.'); }
        }
    }
    /** Email to Owner Email or Assigned User **/
    Public void sendEmail(TriggerInterface_WorkOrderLineItem.Trig trig) {
        System.debug('Trig :::::: ' + trig);
        set<Id> woSet = new set<Id>();
        string baseUrl = URL.getSalesforceBaseUrl().toExternalForm();
        OrgWideEmailAddress[]  oWideEmailAdrs = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress WHERE DisplayName = 'GE Exhibitions' LIMIT 1];
        /** List of Email Messages to Be Sent for Work OlIs.**/
        List<Messaging.SingleEmailMessage> lstSingleEmailMessage = new List<Messaging.SingleEmailMessage>();
        /** List of Email Messages to Be Sent for Work Orders. **/
        List<Messaging.SingleEmailMessage> lstSingleEmailMessageForWorkOrder = new List<Messaging.SingleEmailMessage>();
        EmailTemplate emailTemplate = [SELECT Id, Subject, HtmlValue, Body FROM EmailTemplate WHERE Name = 'Informa Template2 For WorkOrderLineItemClosed'];
        EmailTemplate emailTemplateAssigned = [SELECT Id, Subject, HtmlValue, Body FROM EmailTemplate WHERE Name = 'Informa Template2 For WorkOrderLineItemAssigned'];
        for (WorkOrderLineItem woli : trig.newList) {
            if (trig.isUpdate && woli.Assign__c != null && trig.oldMap.get(woli.id).Assign__c != woli.Assign__c) {
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                List<String> toAddresses = new list<string>();
                toAddresses.add(woli.assigneeEmail__c);
                String subject = 'Work Order Line Item assigned';
                email.setSubject(subject);
                email.setToAddresses( toAddresses );

                String htmlBody = emailTemplateAssigned.HtmlValue;
                htmlBody = htmlBody.replace(' {!WorkOrderLineItem.Assign_To__c}', woli.asigneeName__c);
                htmlBody = htmlBody.replace('{!WorkOrderLineItem.LineItemNumber}', woli.LineItemNumber);
                htmlBody = htmlBody.replace('{!WorkOrderLineItem.Task_Name__c}', woli.Task_Name__c);
                htmlBody = htmlBody.replace('{!link}', baseUrl + '/' + woli.Id);

                String plainBody = emailTemplateAssigned.Body;
                plainBody = plainBody.replace('{!WorkOrderLineItem.Assign_To__c}', woli.assigneeEmail__c);
                plainBody = plainBody.replace('{!WorkOrderLineItem.LineItemNumber}', woli.LineItemNumber);
                plainBody = plainBody.replace('{!WorkOrderLineItem.Task_Name__c}', woli.Task_Name__c);
                plainBody = plainBody.replace('{!link}', baseUrl + '/' + woli.Id);

                email.setHtmlBody(htmlBody);
                email.setSaveAsActivity(false);
                email.setPlainTextBody(plainBody);
                email.setOrgWideEmailAddressId(oWideEmailAdrs[0].id);
                lstSingleEmailMessage.add(email);
            }
            if (woli.status == 'Closed' && trig.oldmap.get(woli.id).status != woli.status) {
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                list<string> linktoTheRecord = new list<String>();
                List<String> toAddresses = new list<string>();
                toAddresses.add(woli.Owner_Email__c);
                String subject = 'Work Order Line Item Closed';
                email.setSubject(subject);
                email.setToAddresses( toAddresses );

                String htmlBody = emailTemplate.HtmlValue;
                htmlBody = htmlBody.replace('{!WorkOrderLineItem.Owner_Name__c}', woli.owner_name__c);
                htmlBody = htmlBody.replace('{!WorkOrderLineItem.LineItemNumber}', woli.LineItemNumber);

                if (woli.Task_Name__c != null || woli.Task_Name__c != '') {
                    htmlBody = htmlBody.replace('{!WorkOrderLineItem.Task_Name__c}', woli.Task_Name__c);
                } else {
                    htmlBody = htmlBody.replace('{!WorkOrderLineItem.Task_Name__c}', 'N.A');
                }
                if (woli.Task_Name__c != null) {
                    htmlBody = htmlBody.replace('{!WorkOrderLineItem.Task_Name__c}', woli.Task_Name__c);
                } else {
                    htmlBody = htmlBody.replace('{!WorkOrderLineItem.Task_Name__c}', 'N.A');
                }
                if (woli.Assign__c != null || woli.Assign__c != '') {
                    htmlBody = htmlBody.replace('{!asignto}', woli.asigneeName__c);
                } else {
                    htmlBody = htmlBody.replace('{!asignto}', 'N.A');
                }
                if (woli.Account_Name__c != null) {
                    htmlBody = htmlBody.replace('{!WorkOrderLineItem.Account_Name__c}', woli.Account_Name__c);
                } else {
                    htmlBody = htmlBody.replace('{!WorkOrderLineItem.Account_Name__c}', 'N.A');
                }
                if (woli.Opportuity_Name__c != null) {
                    htmlBody = htmlBody.replace('{!WorkOrderLineItem.Opportuity_Name__c}', woli.Opportuity_Name__c);
                } else {
                    htmlBody = htmlBody.replace('{!WorkOrderLineItem.Opportuity_Name__c}', 'N.A');
                }
                if (woli.WorkOrderId != null) {
                    htmlBody = htmlBody.replace('{!link}', baseUrl + '/' + woli.WorkOrderId);
                } else {
                    htmlBody = htmlBody.replace('{!link}', '');
                }
                String plainBody = emailTemplate.Body;
                plainBody = plainBody.replace('{!WorkOrderLineItem.Owner_Name__c}', woli.owner_name__c);
                plainBody = plainBody.replace('{!WorkOrderLineItem.LineItemNumber}', woli.LineItemNumber);
                if (woli.Task_Name__c != null) {
                    plainBody = plainBody .replace('{!WorkOrderLineItem.Task_Name__c}', woli.Task_Name__c);
                }
                if (woli.Account_Name__c != null) {
                    plainBody = plainBody .replace('{!WorkOrderLineItem.Account_Name__c}', woli.Account_Name__c);
                } else {
                    plainBody = plainBody.replace('{!WorkOrderLineItem.Account_Name__c}', 'N.A');
                }
                if (woli.Task_Name__c != null) {
                    plainBody = plainBody .replace('{!WorkOrderLineItem.Task_Name__c}', woli.Task_Name__c);
                } else {
                    plainBody = plainBody.replace('{!WorkOrderLineItem.Task_Name__c}', 'N.A');
                }
                if (woli.Opportuity_Name__c != null) {
                    plainBody = plainBody .replace('{!WorkOrderLineItem.Opportuity_Name__c}', woli.Opportuity_Name__c);
                } else {
                    plainBody = plainBody.replace('{!WorkOrderLineItem.Opportuity_Name__c}', 'N.A');
                }
                if (woli.WorkOrderId != null) {
                    plainBody = plainBody .replace('{!link}', baseUrl + '/' + woli.WorkOrderId);
                } else {
                    plainBody = plainBody.replace('{!link}', 'N.A');
                }
                if (woli.Assign__c != null || woli.Assign__c != '') {
                    plainBody = plainBody.replace('{!asignto}', woli.asigneeName__c);
                } else {
                    plainBody = plainBody.replace('{!asignto}', 'N.A');
                }
                email.setHtmlBody(htmlBody);
                email.setSaveAsActivity(false);
                email.setPlainTextBody(plainBody);
                email.setOrgWideEmailAddressId(oWideEmailAdrs[0].id);
                lstSingleEmailMessage.add(email);
            }
        }
        try {
            //BK-12 Modified By Avinash : Removing too many email invocation exception.
            if (!lstSingleEmailMessage.isEmpty()) {
                Messaging.SendEmailResult[] r = Messaging.sendEmail(lstSingleEmailMessage);
            }
        } catch (Exception ex) {
            Utility.logError(ex.getMessage(), ex.getCause(), ex.getLineNumber(), ex.getStackTraceString(), 'Trigger ::: WorkOrderLineItem_Trig ::: sendEmail');
        }

        //Added by Abdul Kadir -When All WorkOrderlineitem under workorder are closed then workorder status should be Completed.
        if (trig.isUpdate) {
            String userId = (String)UserInfo.getUserId();
            set<Id> woSetUpdated = new set<Id>();
            List<workOrder> woListUpdated = new List<workOrder>();
            for (WorkOrderLineItem woli : trig.newList) {
                if (woli.status == 'Completed' ) {
                    woSet.add(woli.WorkOrderId);
                }
            }

            for (workOrder wo : [select id, (select id, status from WorkOrderLineItems ), status, Account.name, Event_Edition__r.name, Event_Edition__r.PDF_Logo_URL__c, Product_Name__r.name, Owner.email, OwnerId from workOrder where id in : woSet]) {
                boolean checkCompleted = false;
                boolean checkUnCompleted = false;
                for (WorkOrderLineItem woli : wo.WorkOrderLineItems) {
                    if (woli.status == 'Completed') {
                        checkCompleted = true;
                    } else {
                        checkUnCompleted = true;
                    }
                }
                if (checkCompleted = true) {
                    wo.status = 'Completed';
                    woListUpdated.add(wo);
                }
                if (checkUnCompleted == true) {
                    woListUpdated.remove(0);
                }
            }
            if (!woListUpdated.isEmpty()) {
                update woListUpdated;
            }
            //End AK
            if (!woListUpdated.isEmpty()) {
                Document footerlogo = [select id, name from document where name = 'EmailTemplateFooter_Logo' limit 1];
                Document headerlogo = [select id, name from document where name = 'EmailTemplateHeader_Logo' limit 1];
                EmailTemplate emailTemplateWoli = [SELECT Id, Subject, HtmlValue, Body FROM EmailTemplate WHERE Name = 'Informa Template3 For WorkOrderLineItem'];
                String orgId = [SELECT Id FROM Organization limit 1].Id;
                for (workOrder wo : woListUpdated) {
                    Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                    List<String> toAddresses = new list<string>();
                    toAddresses.add(wo.Owner.email);
                    String subject = 'All tasks have been completed on the Work Order for ' + wo.Account.name + ' / ' + wo.Event_Edition__r.name + ' / ' + wo.Product_Name__r.name;
                    email.setSubject(subject);
                    email.setToAddresses( toAddresses );
                    String htmlBody = emailTemplateWoli.HtmlValue;
                    htmlBody = htmlBody.replace('{!WorkOrder. Account}', wo.Account.name);
                    htmlBody = htmlBody.replace('{!WorkOrder.Event_Edition__c}', wo.Event_Edition__r.name);
                    htmlBody = htmlBody.replace('{!WorkOrder.Product_Name__c}', wo.Product_Name__r.name);
                    htmlBody = htmlBody.replace('{!link}', baseUrl + '/' + wo.Id);
                    htmlBody = htmlBody.replace('{!logo}', wo.Event_Edition__r.PDF_Logo_URL__c);
                    htmlBody = htmlBody.replace('{!footerlogo}', baseUrl + '/servlet/servlet.ImageServer?oid=' + OrgId + '&id=' + footerlogo.Id);
                    htmlBody = htmlBody.replace('{!headerlogo}', baseUrl + '/servlet/servlet.ImageServer?oid=' + OrgId + '&id=' + headerlogo.Id);

                    String plainBody = emailTemplateWoli.Body;
                    plainBody = plainBody.replace('{!WorkOrder. Account}', wo.Account.name);
                    plainBody = plainBody.replace('{!WorkOrder.Event_Edition__c}', wo.Event_Edition__r.name);
                    plainBody = plainBody.replace('{!WorkOrder.Product_Name__c}', wo.Product_Name__r.name);
                    plainBody = plainBody.replace('{!link}', baseUrl + '/' + wo.Id);
                    htmlBody = htmlBody.replace('{!Event_Edition__c.Email_Body__c}', '');
                    htmlBody = htmlBody.replace('{!logo}', wo.Event_Edition__r.PDF_Logo_URL__c);
                    htmlBody = htmlBody.replace('{!footerlogo}', baseUrl + '/servlet/servlet.ImageServer?oid=' + OrgId + '&id=' + footerlogo.Id);
                    htmlBody = htmlBody.replace('{!headerlogo}', baseUrl + '/servlet/servlet.ImageServer?oid=' + OrgId + '&id=' + headerlogo.Id);

                    email.setHtmlBody(htmlBody);
                    email.setSaveAsActivity(false);
                    email.setPlainTextBody(plainBody);
                    email.setOrgWideEmailAddressId(oWideEmailAdrs[0].id);

                    lstSingleEmailMessageForWorkOrder.add(email);
                    //BK-12 Modified By Avinash : Removing too many email invocation exception.
                    if (!lstSingleEmailMessageForWorkOrder.isEmpty()) {
                        Messaging.SendEmailResult[] r = Messaging.sendEmail(lstSingleEmailMessageForWorkOrder);
                    }
                }
            }
        }
    }
}