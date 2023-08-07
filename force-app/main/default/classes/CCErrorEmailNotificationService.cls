/***************************************************************************
* Created By    :  Girikon(Ashish) [CCEN-785]
* Created On    :  April 06 2019
* @description  :  This is Service Class to notify Admin in case of any error in Customer Center
* Test Class    :  PageTitleCtrl_Test (96%)
***************************************************************************/

global class CCErrorEmailNotificationService
{ 
    webservice static void sendErrorNotificationMail(String errorMsg) 
    {
        string adminEmail ;
        CC_community_Setting__c ccStng = CC_community_Setting__c.getValues('Customer Center');
        if( string.isNotBlank(ccStng.Admin_Email__c))
        {
            adminEmail =  ccStng.Admin_Email__c;
        }
        else
        {
            adminEmail = Label.Admin_Email_Address_CC;
        }
        Messaging.reserveSingleEmailCapacity(2);           
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();            
        String[] toAddresses = new String[] {adminEmail};            
        mail.setToAddresses(toAddresses);
        mail.setSenderDisplayName('Customer Center');
        mail.setSubject('Exception on Customer Center ');
        mail.setBccSender(false);
        mail.setUseSignature(false);
        mail.setHtmlBody(' There is Error on Customer Center </br> ERROR :<b> '+errorMsg +'</b>');            
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail },false);                        
    }
}