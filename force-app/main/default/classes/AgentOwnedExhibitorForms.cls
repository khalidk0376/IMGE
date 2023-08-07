/**
 * Created By   :   Girikon(Prashant)
 * Created On   :   Aug 5 2018
 * @description :   Class to show forms tab of Agent Owned Exhibitor to Agent in Customer Center[C2E-13].
 * Test Class   :   AgentOwnedExhibitorForms_Test (93%)
 * Modification Log----- 
 * Modified by  :   
**/

public with sharing class AgentOwnedExhibitorForms {

    @AuraEnabled
    public static WrapperForm customerFormList(String accId , String eventCode)
    {
        WrapperForm returnwrapperClass = new WrapperForm(); 
        List<Forms_Permission__c> formPermit = new list<Forms_Permission__c>();
        List<Forms_Permission__c> addedFormList = new list<Forms_Permission__c>();
        List<Event_Settings__c> deadline = new List<Event_Settings__c>();
        set<string> formassignd = new set<string>();
        set<string> addedformassignd = new set<string>();
        List<User_Form_Action__c> usrFormAction = new list<User_Form_Action__c>();
        if(Schema.sObjectType.Event_Settings__c.isAccessible())
        {
           deadline=[ select id , name ,Deadline_Reached_Message_for_Forms__c from Event_Settings__c where Event_Edition__r.Event_Code__c=:eventCode];
           returnwrapperClass.deadlineMessage = String.valueOf(deadline[0].Deadline_Reached_Message_for_Forms__c);
        }
        
        if(Schema.sObjectType.Forms_Permission__c.isAccessible())
        {
        	formPermit=[select id ,Active__c ,Event_Edition_Form__c ,Event_Edition_Form__r.Name ,Event_Edition_Form__r.Deadline__c From Forms_Permission__c where Active__c=:true and ( User_Type__r.Name='Agent Owned Exhibitor' OR User_Type__r.Name='Exhibitor' OR  User_Type__r.Name='Co-Exhibitor') and Event_Edition_Form__r.Mandatory__c=:true and Event_Edition_Form__r.Event_Edition__r.Event_Code__c=:eventCode ];
               
			system.debug('formPermit'+formPermit.size());             
            system.debug('formPermit'+formPermit);
            addedFormList=[select id ,Active__c ,Event_Edition_Form__c,Event_Edition_Form__r.Name ,Event_Edition_Form__r.Deadline__c From Forms_Permission__c  where Active__c=:true and ( User_Type__r.Name='Agent Owned Exhibitor' OR User_Type__r.Name='Exhibitor' OR  User_Type__r.Name='Co-Exhibitor') and Event_Edition_Form__r.Mandatory__c=:false and Event_Edition_Form__r.Event_Edition__r.Event_Code__c=:eventCode ];
                            system.debug('formPermit'+formPermit);
            
        }
        if(!(addedFormList.IsEmpty()))
        {
            for(Forms_Permission__c addFormPermitd:addedFormList)
            {
                addedformassignd.add(addFormPermitd.id);

            }
        }
        if(!(formPermit.IsEmpty()))
        {
            for(Forms_Permission__c formPermitd:formPermit)
            {
                formassignd.add(formPermitd.id);

            }
        }
         if(Schema.sObjectType.User_Form_Action__c.isAccessible())
        {
        	returnwrapperClass.requiredForms=[SELECT id,Status__c, StatusDisplay__c,Is_Viewed__c ,Is_Filled_Up__c,Last_Updated_Date__c, Last_Updated_By__r.Name, 
            Form_Permission__r.Event_Edition_Form__r.Allow_Submit_After_Deadline__c,
            Form_Permission__r.Event_Edition_Form__r.Forms__r.Url__c, Form_Permission__r.Event_Edition_Form__r.Provider__c, User_Form_Contact__r.Name,Form_Submitted__c,
            Form_Permission__r.Event_Edition_Form__r.Forms__r.Name,Form_Permission__r.Event_Edition_Form__r.Forms__r.id ,Form_Permission__r.Event_Edition_Form__r.FormType__c,LastModifiedBy.Name, LastModifiedBy.Profile.Name, LastModifiedDate,
            Form_Permission__r.Event_Edition_Form__r.Deadline__c,Form_Permission__r.Event_Edition_Form__r.Template_Form__c,
            Form_Permission__r.Event_Edition_Form__r.Forms__r.Uploaded_Attachment_Id__c FROM User_Form_Action__c  where 
                            Account__c=:accId and Form_Permission__c IN:formassignd and 
                                ( User_Type__r.Name='Agent Owned Exhibitor' OR User_Type__r.Name='Exhibitor' OR  User_Type__r.Name='Co-Exhibitor') ];

                                
            returnwrapperClass.additionalForms=[SELECT id,Status__c, StatusDisplay__c,Is_Viewed__c ,Is_Filled_Up__c, Last_Updated_Date__c, Last_Updated_By__r.Name, Form_Permission__r.Event_Edition_Form__r.Allow_Submit_After_Deadline__c,
            Form_Permission__r.Event_Edition_Form__r.Forms__r.Url__c, 
            Form_Permission__r.Event_Edition_Form__r.Provider__c, Form_Permission__r.Event_Edition_Form__r.Forms__r.Name,Form_Permission__r.Event_Edition_Form__r.Forms__r.id ,User_Form_Contact__r.Name,Form_Submitted__c,
            Form_Permission__r.Event_Edition_Form__r.FormType__c,Form_Permission__r.Event_Edition_Form__r.Deadline__c,Form_Permission__r.Event_Edition_Form__r.Template_Form__c,LastModifiedBy.Name, LastModifiedBy.Profile.Name, LastModifiedDate, Form_Permission__r.Event_Edition_Form__r.Forms__r.Uploaded_Attachment_Id__c FROM User_Form_Action__c  where 
                            Account__c=:accId and Form_Permission__c IN:addedformassignd and 
                                ( User_Type__r.Name='Agent Owned Exhibitor' OR User_Type__r.Name='Exhibitor' OR  User_Type__r.Name='Co-Exhibitor') ];
                                                
        }
        //system.debug('returnwrapperClass'+returnwrapperClass);
        return returnwrapperClass;
    }
    @AuraEnabled
    public Static List<User_Form_Action__c> viewedRecord(string id , boolean isViewed , boolean isFilled) 
    {
        list<User_Form_Action__c> uFA = new List<User_Form_Action__c>();
        uFA = [select id, name, Is_Viewed__c, Is_Filled_Up__c,Last_Updated_By__c, Last_Updated_Date__c from User_Form_Action__c where id=:id];
        User currentUser = [Select Id FROM User where Id =: UserInfo.getUserId() LIMIT 1];
        if(!uFA.IsEmpty())
        {
            uFA[0].Is_Viewed__c=isViewed;
            uFA[0].Last_Updated_By__c = currentUser.Id;
            uFA[0].Last_Updated_Date__c = System.now();
            if(isFilled)
            {
                uFA[0].Is_Filled_Up__c=isFilled; 
            }
        }
        System.debug('ufa ' +ufa);
        if(Schema.sObjectType.User_Form_Action__c.isUpdateable())
        {
            update uFA;
        }
        return uFA;
    }
    
     public class WrapperForm{
        @AuraEnabled public List<User_Form_Action__c> additionalForms{get;set;}
        @AuraEnabled public List<User_Form_Action__c> requiredForms{get;set;}
        @AuraEnabled public String deadlineMessage{get;set;}

        public WrapperForm()
        {
            additionalForms = new List<User_Form_Action__c>();
            requiredForms = new List<User_Form_Action__c>();
            deadlineMessage ='';
        }
        
    }
    @AuraEnabled 
     public static ContentVersion getContentVersionId(String docId) {
         //To fetch the content version Id of respective content document
         ContentVersion conVer = new ContentVersion();
         if(string.isNotBlank(docId)) {
         conVer = [SELECT Id,Title FROM ContentVersion WHERE ContentDocumentId =: docId];
         }
         return conVer;
    }
}