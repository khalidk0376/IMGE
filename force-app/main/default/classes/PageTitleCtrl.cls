/***************************************************************************
* Created By    :  Girikon(Ashish)
* Created On    :  Aug 13 2018
* @description  :  This is Ctrl for All Community page to set the page header.
* Test Class    :  PageTitleCtrl_Test (90%)

***************************************************************************/

public without sharing class PageTitleCtrl 
{    
    //public Event_Settings__c event_Setting{ get; set;} // Remove this variable after Deployment 
    public Event_Settings__c eventSetting{ get; set;}
    public Boolean showMaintaince { get; set;}
    public PageTitleCtrl ()
    {
        try
        {
            string eventCode= apexpages.currentpage().getparameters().get('eventcode');
            if(string.isNotBlank(eventCode) && Schema.sObjectType.Event_Settings__c.isAccessible())
            {
                eventSetting = [SELECT Custom_1_Title__c,Custom_2_Title__c,Custom_3_Title__c,Forms_Title__c,Manuals_Title__c,Badges_Title__c,E_Commerce_Title__c,Accounts_and_Billing_Title__c,Exhibitor_Directory_Title__c,Upload_Center_Title__c,Freeman_Title__c,Stand_Contractor_Title__c,My_Exhibitor_Title__c,Subcontractor_Title__c,Agent_Own_Exhibitor_Title__c FROM Event_Settings__c WHERE Event_Edition__r.Event_Code__c =:EventCode limit 1];
            }

            CC_community_Setting__c ccSetting = CC_community_Setting__c.getValues('Customer Center');            
            showMaintaince = ccSetting.Under_Maintenance__c;            
        }
        catch(Exception ex)
        {
            System.debug('The following exception has occurred: ' + ex.getMessage());
        }
    }
    /*
   
    public PageReference redirectTologin()
    {
        PageReference pageRef;
        CC_community_Setting__c ccStng = CC_community_Setting__c.getValues('Customer Center');
        if(ccStng.Under_Maintenance__c == false)
        {  
            string url = System.URL.getSalesforceBaseUrl().toExternalForm()+'/CustomerCenter';             
            pageRef = new PageReference(url);
            pageRef.setRedirect(true);
            return pageRef;
        }else
        {
            return null; 
        } 
    } */
}