/**
* Project:         GAP
* Date:            11/12/2018
* Test Class Name :EmailMessagingContact_Test   
* Code Coverage:   100%
* Created By:      Abdul Kadir
* *************************************************************************
* @Description:     This test class covers "EmailMessagingContact_Test " trigger.
* *************************************************************************
* History:Ticket :GGCW-2845
* Modified Date:   27/12/2018
* Modified By:     Rajesh Kumar Yadav
*/
trigger EmailMessagingContact on EmailMessage (After insert) {
   EmailMessagingContact_Class objEmailMessagingContact  = new EmailMessagingContact_Class(Trigger.new, Trigger.oldMap, Trigger.isInsert, Trigger.isAfter);
   objEmailMessagingContact.createContactAttachment(); 
}