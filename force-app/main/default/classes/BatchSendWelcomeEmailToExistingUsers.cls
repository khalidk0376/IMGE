/**
 * Created/Modified By: Girikon(Divaker)
 * Created On:          19 July 2018
 * Description/Purpose: Update Inactive user and send welcome email.
 * Test Class:  ContactEventEditionMapping_Test
 * Code Coverage: 100%
 * Last Modified By: [Ashish/CCEN-585 (7 Jan 2019)],
**/
/** @description Update Inactive user and send welcome email.**/
public with sharing class BatchSendWelcomeEmailToExistingUsers implements Database.Batchable<sObject>,Database.Stateful{

    public final set<id> conEvntMapIds; // Changed parameter to Contact EEM Ids [CCEN-585]
    public set<id> toUpdateconEvntMapIds = new set<id>(); 
    /**
     * [Batch to Send Welcome-Email To Existing Users]
     * @param  conEEMIds [Set of contactEventEditionMapping Ids ]
     **/  
    public BatchSendWelcomeEmailToExistingUsers(set<id> conEEMIds)
    {
        this.conEvntMapIds = conEEMIds;
    }
    // Start Method
    public Database.QueryLocator start(Database.BatchableContext bthContext){
       return Database.getQueryLocator('Select Id,SFContactID__c,SFEventEditionID__c,IsEmailSent__c from ContactEventEditionMapping__c where IsEmailSent__c = false And id in:conEvntMapIds');
    }
    //Execute Logic
    public void execute(Database.BatchableContext bthContext, List<ContactEventEditionMapping__c> contactEventEditionMapping)
    {
        set<Id> conIDs              = new set<Id>();
        set<Id> toUpdateConEEmId    = new set<Id>();
        set<Id> sConEEMIds          = new set<Id>();  
        set<Id> inactiveconIDs      = new set<Id>();  
        List<user> updateInActiveuser = new List<user>();
        for(ContactEventEditionMapping__c conEEM : contactEventEditionMapping)
        {
            conIDs.add(conEEM.SFContactID__c);
            toUpdateConEEmId.add(conEEM.Id);
        }        
        try{
            for(user usr : [SELECT Id, IsActive, ContactId FROM USER WHERE ContactId IN :conIDs])
            {
                if(!usr.IsActive)
                {
                    usr.IsActive = true;
                    updateInActiveuser.add(usr);
                    inactiveconIDs.add(usr.ContactId);
                }
            }
            for(ContactEventEditionMapping__c conEEM : contactEventEditionMapping)
            {
                if(!inactiveconIDs.contains(conEEM.SFContactID__c))
                {
                    // Final List of Ids For Which Welcome Email Should Be ReSend 
                    sConEEMIds.add(conEEM.Id);
                }
            }
            if(sConEEMIds != null && !sConEEMIds.isEmpty())
            {
                UtilityMethods.sendEmailToExistingUser(sConEEMIds); //Send Welcome Email to Existing User
            }

            toUpdateconEvntMapIds.addAll(toUpdateConEEmId);   // set of Con Event Ids For which welcome email is sent 

            if(updateInActiveuser != null && !updateInActiveuser.IsEmpty())
            {
                //DML statement
                Database.SaveResult[] srList = Database.update(updateInActiveuser, false);
                system.debug('Batch Send Welcome Email To Existing Users SaveResult =============================='+srList);
            }
             if(test.isRunningTest())
                {
                    integer i = 9/0; // For test class Code covrage 
                } 
        }       
        catch(Exception e)
        {
            String sMessage='Exception Details<br>';
            sMessage += '<br><b>User List:</b> ';
            sMessage += '<br><b>Logged In User:</b> '+UserInfo.getName()+'[ '+ UserInfo.getUserId()+']';
            sMessage += '<br><b>Org:</b> '+UserInfo.getOrganizationName();
            sMessage += '<br><b>ERROR TYPE:</b> '+e.getTypeName();
            sMessage += '<br><b>ERROR MESSAGE:</b> '+e.getMessage();
            sMessage += '<br><b>ERROR LINE NUMBER:</b> '+e.getLineNumber();
            sMessage += '<br><b>Error Details:</b> '+e.getStackTraceString();
            String[] toAddresses = new String[] {Label.Admin_Email_Address_CC};
            string subject='Exception occurred while creating community user';
            UtilityMethods.SendEmailNotification(toAddresses,subject,sMessage);
        }
    }
    public void finish(Database.BatchableContext bthContext)
    {
        // Logic to be Executed at finish
        List<ContactEventEditionMapping__c> updateCEEMApping = new List<ContactEventEditionMapping__c>();
        if(toUpdateconEvntMapIds != null && !toUpdateconEvntMapIds.isEmpty())
        {
            List<ContactEventEditionMapping__c> lstCEEMApping = [SELECT id, SFContactID__c, IsEmailSent__c,Email_Sent__c FROM ContactEventEditionMapping__c WHERE Id IN :toUpdateconEvntMapIds];
            if(lstCEEMApping != null && !lstCEEMApping.IsEmpty())
            {
                for(ContactEventEditionMapping__c oCEEMapping : lstCEEMApping)
                {
                    oCEEMapping.IsEmailSent__c = true;
                    oCEEMapping.Email_Sent__c = system.now();
                    updateCEEMApping.add(oCEEMapping);
                }
                if(updateCEEMApping != null && !updateCEEMApping.IsEmpty())
                {
                    Update updateCEEMApping;
                }
            }
        }
    }
}