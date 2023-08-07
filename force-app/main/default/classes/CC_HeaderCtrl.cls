/*
Created By		: Girikon(Sunil[STL-17])
Created On		: July 31 2019
@description 	: This class is used to fetch the user related all data on Home Page at Customer Centre.
Test Class		: CC_HeaderCtrl_Test(89%)

Modification log --
Modified By		:  History: BK-3758 Modified By Rajesh Kumar - on 28-05-2020
*/
public without sharing class CC_HeaderCtrl 
{

    /**
     * @description         [Fetch user related all data]
     * @param  eventCode    [Event Code]
     * @return              [List of wrapper class]
     */
    @AuraEnabled(Cacheable = true)
    public static WrapperUserDetail fetchUserDetails(String eventCode) 
    {
        WrapperUserDetail userDetails = new WrapperUserDetail();
        string userType = ''; 
        string userTypeId = '';
        List <User> lstUser = new List <User> ([SELECT id, ContactId, AccountId, Account.Name 
                                                FROM User 
                                                WHERE id =: UserInfo.getUserId()]);
        if (!lstUser.IsEmpty()) {
            userDetails.accountName = lstUser[0].Account.Name;
            userDetails.accountId = lstUser[0].AccountId;
            string strQuery = 'select Id,User_Type__r.Name,SFEventEditionID__r.Event_Code__c,SFEventEditionID__r.Name,SFEventEditionID__r.Event_Edition_Image_URL__c from ContactEventEditionMapping__c where SFContactID__c =\'' + string.escapeSingleQuotes(lstUser[0].ContactId) + '\'';
            strQuery += ' AND SFEventEditionID__r.End_Date__c >=TODAY and IsEmailSent__c=true  and SFEventEditionID__c in (select Event_Edition__c from Event_Settings__c  where Is_Event_Edition_Live__c=true)';
            userDetails.totalEvents = 0;
            List <ContactEventEditionMapping__c> cntctMapLst = Database.query(strQuery);
            if (string.isNotBlank(eventCode)) 
            {
                if (!cntctMapLst.IsEmpty()) 
                {
                    userDetails.totalEvents = cntctMapLst.size();
                    List < WrapperEvent > lstEvents = new List < WrapperEvent > ();
                    for (ContactEventEditionMapping__c oConEvtEditionMap: cntctMapLst) 
                    {
                        WrapperEvent wprEvent = new WrapperEvent();
                        wprEvent.eventCode = oConEvtEditionMap.SFEventEditionID__r.Event_Code__c;
                        wprEvent.eventName = oConEvtEditionMap.SFEventEditionID__r.Name;
                        if (eventCode == oConEvtEditionMap.SFEventEditionID__r.Event_Code__c) 
                        {
                            wprEvent.selectedEvent = true;
                        }
                        lstEvents.add(wprEvent);
                    }
                    if (!lstEvents.IsEmpty()) 
                    {
                        userDetails.lstEvents = lstEvents;
                    }
                }

                //Fetch current login event data
                List <ContactEventEditionMapping__c> conEventMap = new List <ContactEventEditionMapping__c> ([Select Id, User_Type__r.Name, SFEventEditionID__r.Event_Code__c, SFEventEditionID__r.Name, SFEventEditionID__r.Event_Edition_Image_URL__c 
                                                                                                              from ContactEventEditionMapping__c 
                                                                                                              where SFContactID__c =: lstUser[0].ContactId 
                                                                                                              and SFEventEditionID__r.Event_Code__c =: eventCode]);
                if (!conEventMap.IsEmpty()) 
                {
                    userDetails.eventName = conEventMap[0].SFEventEditionID__r.Name;
                    userDetails.userType = conEventMap[0].User_Type__r.Name;
                    userDetails.eventLogo = '/servlet/servlet.FileDownload?file=' + conEventMap[0].SFEventEditionID__r.Event_Edition_Image_URL__c;
                    userType = conEventMap[0].User_Type__r.Name;
                    userTypeId = conEventMap[0].User_Type__c;

                    List <ComponentUserTypeMapping__c > cmpUserTypeMapping = new List <ComponentUserTypeMapping__c> ([SELECT Id, Accounts_and_Billing_Show__c, Badges_Show__c, E_Commerce_Show__c, Event_Edition__c, Exhibitor_Directory_Show__c, FormQuickView__c, Form_Show__c, Freeman_Show__c, Insurance_Show__c, Know_deadlines_Show__c, ManualQuickView__c, Manual_Show__c, Marketing_Show__c, Profile_Show__c, Standard_Contractor_Show__c, Third_Party_Integrations_Show__c, User_Type__c, My_Exhibitor_Show__c, SubContractor_Show__c, Agent_Own_Exhibitor_Show__c, Custom_1_Show__c, Gorrilla_Show__c, Custom_2_Show__c, Custom_3_Show__c, Pop_Up_Greeting_Show__c
                                                                                                                      FROM ComponentUserTypeMapping__c 
                                                                                                                      where Event_Edition__r.Event_Code__c =: eventCode 
                                                                                                                      and user_type__c =: userTypeId]);

                    list <Announcement__c> lstAnnouncements = new list <Announcement__c> ([Select id, URL__c, Name, Title__c, Description__c 
                                                                                           From Announcement__c
                                                                                           WHERE Is_Active__c = true 
                                                                                           AND Event_Edition__r.Event_Code__c =: eventCode 
                                                                                           AND Actors__c includes(: userType) 
                                                                                           and Expiration_Date__c > TODAY 
                                                                                           ORDER BY Priority__c asc]);

                    list <User_Manual_Action__c> lstManuals = new list <User_Manual_Action__c> ([SELECT Id, Is_Agree__c, Is_Viewed__c 
                                                                                                 FROM User_Manual_Action__c 
                                                                                                 Where Manual_Permission__r.Active__c = True 
                                                                                                 AND Manual_Permission__r.Manuals__r.Required__c = True 
                                                                                                 AND Manual_Permission__r.Manuals__r.Event_Edition__r.Event_Code__c =: eventCode 
                                                                                                 AND Account__c =: lstUser[0].Accountid 
                                                                                                 AND User_Type__c =: userTypeId 
                                                                                                 And Manual_Permission__r.Manuals__r.Manual_Type__c = 'Downloadable PDF']);

                    // Added By Mahesh Kumar(12 Dec,2019[BK-2897])
                     list<User_Form_Action__c> lstForms = new list<User_Form_Action__c>([SELECT Id,Is_Filled_Up__c,Is_Approved__c, Is_Viewed__c FROM User_Form_Action__c Where Account__c=:lstUser[0].Accountid  AND Form_Permission__r.Active__c = True AND Form_Permission__r.Event_Edition_Form__r.Event_Edition__r.Event_Code__c =: eventCode AND Form_Permission__r.Event_Edition_Form__r.Mandatory__c = True AND StatusDisplay__c NOT IN ('Rejected','N/A') AND User_Type__c =:userTypeId]);		

                    if (!cmpUserTypeMapping.IsEmpty()) {
                        userDetails.userTypeMapping = cmpUserTypeMapping[0];
                    }
                    if (!lstAnnouncements.IsEmpty()) {
                        userDetails.lstAnnouncements = lstAnnouncements;
                    }
                    if (!lstManuals.IsEmpty()) {
                        userDetails.lstManuals = lstManuals;
                    }
	
                    if(!lstForms.IsEmpty()){ 
                    	userDetails.lstForms = lstForms;
                    }			  
                }
                List<Event_Settings__c> objEventSettings = new List <Event_Settings__c> ([SELECT id, Is_Event_Edition_Live__c, Event_Edition__r.Name, Event_Edition__r.Event_Edition_Image_URL__c, Is_Pop_Up_Greeting__c,                Pop_Up_Greeting_Header__c, Pop_Up_Greeting__c, Homepage_Right_Panel_Content_Header__c, Homepage_Right_Panel_Custom_Content__c, Welcome_Message_Customer_Portal_Homepage__c, Event_Edition__r.Start_Date__c, Event_Edition__r.Venue__c, Event_Edition__r.End_Date__c, Is_Account_and_Billing_Visible__c, Is_Account_and_Billing_Active__c, Accounts_and_Billing_Title__c, Is_Form_Active__c, Is_Form_Visible__c, Forms_Title__c, Forms_Sub_Title__c, Forms_Redirect_URL__c, Is_Manual_Active__c, Is_Manual_Visible__c, Manuals_Title__c, Manuals_Sub_Title__c, Manuals_Redirect_URL__c, Exhibitor_Directory_Title__c, Is_Customer_Profile_Active__c, Is_Customer_Profile_Visible__c, Upload_Center_Title__c, Is_Upload_Center_Active__c, Is_Upload_Center_Visible__c, E_Commerce_Title__c, Is_E_Commerce_Active__c, Is_E_Commerce_Visible__c, Badges_Title__c, Badges_Redirect_URL__c, Is_Customer_Badges_Active__c, Is_Customer_Badges_Visible__c, Freeman_Title__c, Is_Freeman_Active__c, Is_Freeman_Visible__c, Freeman_Redirect_Url__c, Stand_Contractor_Title__c, Stand_Contractor_Redirect_URL__c, Is_Stand_Contractor_Active__c, Is_Stand_Contractor_Visible__c, My_Exhibitor_Title__c, Is_My_Exhibitor_Active__c, My_Exhibitor_Redirect_URL__c, Is_My_Exhibitor_Visible__c, Subcontractor_Title__c, Subcontractor_Redirect_Url__c, Is_SubContractors_Active__c, Is_SubContractors_Visible__c, Agent_Own_Exhibitor_Title__c, Is_Agent_Own_Exhibitor_Active__c, Is_Agent_Own_Exhibitor_Visible__c, Gorrilla_Title__c, Is_Gorrilla_Active__c, Is_Gorrilla_Visible__c, Custom_1_Title__c, Is_Custom_1_Visible__c, Is_Custom_1_Active__c, Custom_2_Title__c, Is_Custom_2_Active__c, Is_Custom_2_Visible__c, Custom_3_Title__c, Is_Custom_3_Active__c, Is_Custom_3_Visible__c, Event_Summary_Visibility__c, Gorrilla_Sub_Title__c, Custom_1_Sub_Title__c, Custom_2_Sub_Title__c, Custom_3_Sub_Title__c, Agent_Own_Exhibitor_Sub_Title__c, Subcontractor_Sub_Title__c, My_Exhibitor_Sub_Title__c, Freeman_Sub_Title__c, Stand_Contractor_Sub_Title__c, Exhibitor_Directory_Sub_Title__c, Badges_Sub_Title__c, Branding_Color__c, Utility_Navigation_text_Color__c, Main_Nav_Background_Color__c, Main_Nav_Text_Color__c, Footer_background_color__c, Footer_text_color__c, Button_colors__c, Button_Text_Color__c, Custom_1_Redirect_URL__c, Custom_2_Redirect_URL__c, Custom_3_Redirect_URL__c, Agent_Own_Exhibitor_Redirect_URL__c, Exhibitor_Directory_Redirect_URL__c, Gorrilla_Redirect_Url__c, Is_EventCode_Required__c, Event_Edition__r.Freeman_Show_ID__c
                                                                                          FROM Event_Settings__c
                                                                                          WHERE Event_Edition__r.Event_Code__c =: eventCode]);

                if (!objEventSettings.IsEmpty()) {
                    userDetails.eventSettings = objEventSettings[0];
                }
            }
        }
        return userDetails;
    }

    // wrapper or Inner class with @AuraEnabled {get;set;} properties*    
    public class WrapperUserDetail
    {
        @AuraEnabled public Event_Settings__c eventSettings{get;set;}
        @AuraEnabled public String accountName {get;set;}
        @AuraEnabled public String accountId {get;set;}
        @AuraEnabled public String eventLogo {get;set;}
        @AuraEnabled public String eventName{get;set;}
        @AuraEnabled public String userType{get;set;}
        @AuraEnabled public Integer totalEvents{get;set;}
        @AuraEnabled public List<WrapperEvent> lstEvents{get;set;}
        @AuraEnabled public ComponentUserTypeMapping__c userTypeMapping {get;set;}
        @AuraEnabled public List<Announcement__c> lstAnnouncements{get;set;}
        @AuraEnabled public List<User_Manual_Action__c> lstManuals{get;set;}
        @AuraEnabled public List<User_Form_Action__c> lstForms{get;set;}
    }
    public Class WrapperEvent
    {
        @AuraEnabled public String eventCode {get;set;}
        @AuraEnabled public String eventName{get;set;}
        @AuraEnabled public Boolean selectedEvent{get;set;}
    }

}