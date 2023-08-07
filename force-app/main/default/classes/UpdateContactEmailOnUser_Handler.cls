/**
 * Created/Modified By: Girikon(Aishwarya) // CCEN-458
 * Created On:          12/03/2018
 * Description/Purpose: Handler class which will be called by UpdateContactEmailOnUser
 * Test Class:          UpdateContactEmailOnUser_Handler_Test
 * Last Modified By :   Akshi Arora for BK-3261
**/

public class UpdateContactEmailOnUser_Handler
{
    public void UpdateContactEmailOnUser(Set<Id> conIdsSet)
    {
        //Query to get all users associated with the respective contact Id in set
        Map<Id, User> mapUsers = new Map<Id,User>([Select Id, Email, FirstName, LastName, Country, Street, City, State, PostalCode, Account_Company_Name__c, ContactId, Contact.Email, Contact.FirstName, Contact.LastName,Contact.Accountid,Contact.Account.Name, Contact.MailingCountry,Contact.MailingStreet,Contact.MailingCity,Contact.MailingState,Contact.MailingPostalCode FROM User where contactId IN: conIdsSet]); 
        //system.debug('####################UserList '+mapUsers);
        //Iteration on user records which contacts were updated
        if(!mapUsers.isEmpty() && mapUsers.size()>0)
        {
            for(User user :mapUsers.values()){
                //Check whether contact email address is different with user email address or not
                if(user.Contact.Email != user.Email){
                    user.Email = user.Contact.Email; // Associate the updated contact's email with respective user's email
                }else {
                    user.Email=User.Email;
                }
                // Start of BK - 3038
                System.debug(user.Contact.Account.Name+'test11'+user.Account_Company_Name__c);
                if(user.Contact.Account.Name  != user.Account_Company_Name__c){
                    user.Account_Company_Name__c = user.Contact.Account.Name; // Associate the updated contact's account with respective user's account
                }
                if(user.Contact.FirstName  != user.FirstName ){
                    user.FirstName = user.Contact.FirstName; // Associate the updated contact's FirstName   with respective user's FirstName  
                }
                if(user.Contact.LastName  != user.LastName ){
                    user.LastName = user.Contact.LastName; // Associate the updated contact's LastName  with respective user's LastName  
                }
                if(user.Contact.MailingCountry  != user.Country )
                {
                    user.Country = user.Contact.MailingCountry; // Associate the updated contact's MailingCountry  with respective user's MailingCountry  
                }
                if(user.Contact.MailingStreet  != user.Street )
                {
                    user.Street = user.Contact.MailingStreet; // Associate the updated contact's MailingStreet  with respective user's MailingStreet  
                }
                if(user.Contact.MailingCity  != user.City )
                {
                    user.City = user.Contact.MailingCity; // Associate the updated contact's MailingCity  with respective user's MailingCity  
                }
                if(user.Contact.MailingState  != user.State )
                {
                    user.State = user.Contact.MailingState; // Associate the updated contact's MailingState  with respective user's MailingState  
                }
                if(user.Contact.MailingPostalCode  != user.PostalCode )
                {
                    user.PostalCode = user.Contact.MailingPostalCode; // Associate the updated contact's MailingPostalCode  with respective user's MailingPostalCode  
                }
                //End of BK - 3038
            }
        }
        system.debug('#################MapUserUpdate '+mapUsers.values());
        if(mapUsers != null && mapUsers.size()>0)
            update mapUsers.values();
    }
}