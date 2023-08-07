/**
 * Created By   :   Girikon(Mahesh)[Regarding:-(TES-15)]
 * Created On   :   May 15 2019
 * @description :   [This class using for Community Utility]
 * Test Class   :   CommunityUtilityTest
 * Modification Log----- 
 * Modified by  :   
 **/
//Ticket No. BK-14521 Updating API Version
public class CommunityUtility {
    
    public static String getLabelMessage(SiteBrandingIdentifier siteBranding, String labelText){

    String msg;

    // Get the communities login notification text is its not set to null - value of null will hide the notification to easily turn this off
        if(siteBranding != null && siteBranding.branding != null && String.isNotBlank(labelText) && !labelText.equalsIgnoreCase('null')){
            msg = labelText;

            // Replace text of {Client_Services_Contact_Email__c} with email address from branding sobject
            if(msg.contains('{') && msg.contains('}') && String.isNotBlank(siteBranding.defaultClientServicesEmail)){
                msg = msg.replace('{Client_Services_Contact_Email__c}', siteBranding.defaultClientServicesEmail);
            }
            // Replace text of {Client_Services_Contact_Email__c} with URL from branding sobject
            if(msg.contains('{') && msg.contains('}') && String.isNotBlank(siteBranding.defaultCustomerSupportPage)){
                msg = msg.replace('{Customer_Support_Page__c}', siteBranding.defaultCustomerSupportPage);
            }
        }
        return msg;
  }

}