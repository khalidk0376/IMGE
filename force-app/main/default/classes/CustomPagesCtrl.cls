/**
* Created by     : Girikon(Prashant [CCEN-547])
* Created On     : Feb 19 2019
* @description   : This class provides following functionalities:
*                  Display custom pages details on Customer Center side.
* Methods        : getCustomSettings,getEventDetails
* Test Class     : CustomPagesCtrl_Test  (100%)
*
* Modification Log----- 
* Modified by    : [Aishwarya 17 sep 2020 BK-9045]
**/
public without sharing class CustomPagesCtrl 
{
    // @description : this method is used for fetching Custom_Setting_CC__c records on the basis of eventcode and name.
    @AuraEnabled
    public static Custom_Setting_CC__c getCustomSettings(String sEventcode, String customName)
    {
        Custom_Setting_CC__c customSetting = new Custom_Setting_CC__c ();
        if(string.isNotBlank(sEventcode) && string.isNotBlank(customName) && Schema.sObjectType.Custom_Setting_CC__c.isAccessible())
        {
            customSetting = [SELECT Name, Left_Panel__c, Right_Panel__c FROM Custom_Setting_CC__c WHERE Event_Edition__r.Event_Code__c =:sEventcode and Name = :customName order by LastModifiedDate LIMIT 1];
        }
        return customSetting; 
    }
    
    // @description : this method is used for fetching Event_Settings__c records on the basis of eventcode.
    @AuraEnabled
    public static Event_Settings__c getEventDetails(String sEventcode)
    {
        Event_Settings__c eventSetting = new Event_Settings__c ();
        if(string.isNotBlank(sEventcode) && Schema.sObjectType.Event_Settings__c.isAccessible())
        {
            eventSetting = [SELECT Id,Name,Custom_1_Title__c,Custom_2_Title__c,Custom_3_Title__c,Event_Edition__c FROM Event_Settings__c WHERE Event_Edition__r.Event_Code__c =:sEventcode];
        }
        return eventSetting;
    }
}