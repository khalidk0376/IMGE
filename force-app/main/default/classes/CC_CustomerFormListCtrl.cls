/*
Created By      : Girikon(Himanshu[STL-19])
Created On      : Jul 02 2019
@description    : This class is used to fetch the Customer Form  data on form Tab at Customer Centre.
Test Class      : CC_CustomerFormListCtrl_Test(Coverage - 91% )
Modification log --
Modified By     : Girikon(Prashant[STL-282], Oct 16 2019)
*/

public with sharing class CC_CustomerFormListCtrl {

     /**
     * @description         [Fetch User From Action Record Required Conditions ]
     * @param  eventCode    [User Id,Event Code]
     * @return              [List of wrapper class]
     */
    @AuraEnabled(cacheable = true)
    public static customerFormListWrp customerFormListWrpData(id userId, string eventCode) {
        customerFormListWrp Wrpobj = new customerFormListWrp();

        list < Event_Settings__c > lstEventSetting = new list < Event_Settings__c > ();
        // get user details
        list < User > lstUserDetails = new list < User > ();
        User usr = new User();
        lstUserDetails = [select id, ContactId, Accountid, Contact.AccountId, Contact.Type__c 
                          from user 
                          where id =: userId];
        if (lstUserDetails != null && lstUserDetails.size() > 0) 
        {
            usr = lstUserDetails[0];
            Wrpobj.usr = usr;
        }

        // fetch event edition data  
        system.debug('=====eCode11'+eventCode);
        list < Event_Edition__c > lstEventEdition = new list < Event_Edition__c > ();
        lstEventEdition = [select id, Event_Code__c 
                           from Event_Edition__c 
                           where Event_Code__c =: eventCode];
                           system.debug('@@@@@@@@@@@@@@@@@@@@@@@'+lstEventEdition);

        // fetch contact event edition mapping data 
        system.debug('===================User'+usr.ContactId);
        system.debug('===================ecode'+lstEventEdition[0].Event_Code__c);
        list < ContactEventEditionMapping__c > lstcontactEventEditionMapping = new list < ContactEventEditionMapping__c > ();
        if (lstEventEdition != null && lstEventEdition.size() > 0) 
        {
            lstcontactEventEditionMapping = [select id, User_Type__c, SFContactID__c, SFEventEditionID__r.Event_Code__c, IsEmailSent__c 
                                             from ContactEventEditionMapping__c 
                                             where SFContactID__c =: usr.ContactId 
                                             AND SFEventEditionID__r.Event_Code__c =: lstEventEdition[0].Event_Code__c];
        }
        if (lstcontactEventEditionMapping != null && lstcontactEventEditionMapping.size() > 0) 
        {
            Wrpobj.contactEventEditionMApping = lstcontactEventEditionMapping[0].User_Type__c;
        }

        // fetch Eventsetting data
        system.debug('=====eCode'+eventCode);
        lstEventSetting = [select id, name, On_Off_Form_Status__c, Deadline_Reached_Message_for_Forms__c, Forms_Title__c, Welcome_Text_Forms__c 
                           from Event_Settings__c 
                           where Event_Edition__r.Event_Code__c =:eventCode];
                           system.debug('===================eelist '+lstEventSetting);
                           //system.debug('===================Deadline '+lstEventSetting[0].Deadline_Reached_Message_for_Forms__c);
        //if(lstEventSetting.size()>0){
            Wrpobj.lstEventSetting = lstEventSetting[0];
            //Wrpobj.deadlineMessage = String.valueOf(lstEventSetting[0].Deadline_Reached_Message_for_Forms__c);
       // }
        // fetch user form permission data 
        if (lstcontactEventEditionMapping != null && lstcontactEventEditionMapping.size() > 0) 
        {

            list < Forms_Permission__c > lstformPermission = new list < Forms_Permission__c > ();
            list < Forms_Permission__c > lstformPermissionAdditional = new list < Forms_Permission__c > ();
            
            lstformPermission = [Select Id, User_Type__c 
                                 from Forms_Permission__c where Active__c = true
                                 AND User_Type__c =: lstcontactEventEditionMapping[0].User_Type__c
                                 AND Event_Edition_Form__r.Mandatory__c = true
                                 AND Event_Edition_Form__r.Event_Edition__r.Event_Code__c =: lstEventEdition[0].Event_Code__c
                                ];

            lstformPermissionAdditional = [Select Id, User_Type__c
                                           from Forms_Permission__c where Active__c = true
                                           AND User_Type__c =: lstcontactEventEditionMapping[0].User_Type__c
                                           AND Event_Edition_Form__r.Mandatory__c != true
                                           AND Event_Edition_Form__r.Event_Edition__r.Event_Code__c =: lstEventEdition[0].Event_Code__c
                                            ];

            list < string > lstformPermissions = new list < string > ();
            list < string > lstformPermissionsAdditional = new list < string > ();
            if (lstformPermission != null && lstformPermission.size() > 0) {
                for (Forms_Permission__c fm: lstformPermission) 
                {
                    lstformPermissions.add(fm.id);
                }
            }
            if (lstformPermissionAdditional != null && lstformPermissionAdditional.size() > 0)
            {
                for (Forms_Permission__c fm: lstformPermissionAdditional) 
                {
                    lstformPermissionsAdditional.add(fm.id);
                }
            }
            Wrpobj.lstformPermissions = lstformPermissions;
            Wrpobj.lstformPermissionsAdditional = lstformPermissionsAdditional;
        }
        return Wrpobj;
    }

 /**
     * @description         [Update User From Action Is Viewed Field]
     * @param  eventCode    [formId,isViewed]
     * @return              [ Status Of Update]
     */
    @AuraEnabled
    public static string updateUserFormAction(id formId, string isViewed, boolean isFilled)
     {
        string message = '';
        User currentUser = [Select Id 
                            FROM User 
                            where Id =: UserInfo.getUserId()
                            LIMIT 1];
        try 
        {
            User_Form_Action__c formaction = new User_Form_Action__c();
            formaction.id = formId;
            formaction.Is_Viewed__c = true;
            // Added Last_Updated_By__c, Last_Updated_Date__c fields to update for [STL-282]
            formaction.Last_Updated_By__c = currentUser.Id;
            formaction.Last_Updated_Date__c = System.now();
            if(isFilled)
            {
                formaction.Is_Filled_Up__c = true;
            }
            if(Schema.sObjectType.User_Form_Action__c.isUpdateable())
            {
                update formAction;
            }
            message = 'success';
        } 
        catch (DmlException e) 
        {
            message = e.getMessage();
        }
        return message;
    }
    // wrapper class 
    public class customerFormListWrp {
        @AuraEnabled
        public user usr 
        {
            get;
            set;
        }
        @AuraEnabled
        public list < string > lstformPermissions
         {
            get;
            set;
        }
        @AuraEnabled
        public Id contactEventEditionMApping 
        {
            get;
            set;
        }
        @AuraEnabled 
        public list < string > lstformPermissionsAdditional 
        {
            get;
            set;
        }
        @AuraEnabled
        public string deadlineMessage 
        {
            get;
            set;
        }
        @AuraEnabled
        public Event_Settings__c lstEventSetting 
        {
            get;
            set;
        }
    }
}