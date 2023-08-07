/**
 * File:        Schedule_Email_Notification_AR.cls
 * Project:     GAP
 * Date:        Dec 22, 2016
 * Created By:  Kumar Gaurav
 * Test Calss : ReleaseNotification_Test
 * *************************************************************************
 * Description: Controller for Email Notification and Release Booths Scheduling.
 * *************************************************************************
 * History:
 */

global class Schedule_Email_Notification_AR implements Schedulable {

  /***** Scheduling Rebook Opportunities for all event edition which is scheduled for today *****/
  global void execute(SchedulableContext SC) {
    System.debug('##Debug## Inside Schedule_Email_Notification_AR method !');
    try {
      EmailTemplate[] templateId = [Select id from EmailTemplate where name = 'Informa Template For Reminder after Release'];
      List < Messaging.SingleEmailMessage > lstMailMsg = new List < Messaging.SingleEmailMessage > ();
      Messaging.SingleEmailMessage mail;
      List < String > toAddresses;

      List < ExpocadBooth__c > lstEB = [SELECT Booth_Number__c, Opportunity__r.Id, Opportunity__r.Owner.Email, Opportunity__r.Owner.Id, Quote__c from ExpocadBooth__c where Opportunity__c != NULL AND Quote__c != NULL AND Opportunity__r.StageName NOT IN('Closed Booked', 'Closed Lost', 'Closed Won') AND Quote__r.SBQQ__Status__c NOT IN('Quote Approved', 'Contract Sent', 'Contract In Review', 'Contract Approved','Accounting Approved') AND Max_Date_To_Release__c =: date.today() AND Status__c != 'Released' AND IsAssociatedBooth__c = false ORDER BY createdDate ASC LIMIT 10000];
      System.debug('##Debug## List Expocad booths ' + lstEB);

      if (!lstEB.isEmpty()) {
        Set < Id > opptyIds = new Set < Id > ();
        OrgWideEmailAddress[]  oWideEmailAdrs = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress WHERE DisplayName = 'GE Exhibitions' LIMIT 1];
        System.debug('OrgWideEmailAddress '+oWideEmailAdrs);
        for (ExpocadBooth__c oEB: lstEB) {
          if (!opptyIds.contains(oEB.Opportunity__r.Id)) {
            mail = new Messaging.SingleEmailMessage();
            toAddresses = new list < string > ();
            toAddresses.add(oEB.Opportunity__r.Owner.Email);
            if (!toAddresses.isEmpty() && !oWideEmailAdrs.isEmpty() && !templateId.isEmpty()) {
              mail.setToAddresses(toAddresses);
              mail.setTemplateID(templateId.get(0).Id);
              mail.setTargetObjectId(oEB.Opportunity__r.Owner.Id);
              mail.setWhatId(oEB.Opportunity__r.Id);
              mail.setOrgWideEmailAddressId(oWideEmailAdrs.get(0).Id);
              mail.setSaveAsActivity(false);
              lstMailMsg.add(mail);
              opptyIds.add(oEB.Opportunity__r.Id);
            }
          }
          oEB.Status__c = 'Released';
        }
      }
      System.debug('##Debug## lstMailMsg Size ' + lstMailMsg.size() + ' ' + lstMailMsg);
      if (!lstMailMsg.isEmpty()) {
        Messaging.sendEmail(lstMailMsg, false);
        update lstEB;
      }
    } catch (Exception Ex) {
      System.debug('##Error## Scheduling can not be completed ' + Ex.getMessage());
      Utility.logError(Ex.getMessage(), Ex.getCause(), Ex.getLineNumber(), Ex.getStackTraceString(), 'execute(@Schedule_Email_Notification_AR.Class)');
    }
  }
}