/**
 * Created/Modified By: Girikon(Prashant)
 * Created On:          12/03/2018
 * Description/Purpose: Class which will at after update of Contact Object //CCEN-458
 * Test Class:  UpdateContactEmailOnUser_Handler_Test
 * Last Modified By :  Shiv Raghav Ticket No - BK-19067 
      
**/
public without sharing class UpdateContactEmailOnUser implements TriggerInterface_Con.Runnable 
{
   public void run(TriggerInterface_Con.Trig trig) 
   {    
       if(trig.isAfter && trig.isUpdate) 
       {
          //To contains updated contact IDs
        Set<Id> newSet=New Set<Id>();
        
        //Iteration on updated Contact records
        for(Contact con: trig.newList)
        {
            //Get only those contact records which email address is updated and not null/blank/whitespaces
            if(String.IsNotBlank(con.Email)) 
            {
                newSet.Add(con.Id);
            } 
            // Start of BK - 3038
            if(String.IsNotBlank(con.FirstName)) 
            {
                newSet.Add(con.Id);
            }
            if(String.IsNotBlank(con.Account.Name)) 
            {
                newSet.Add(con.Id);
            }
            if(String.IsNotBlank(con.LastName)) 
            {
                newSet.Add(con.Id);
            }
            if(String.IsNotBlank(con.MailingCountry)) 
            {
                newSet.Add(con.Id);
            }
            if(String.IsNotBlank(con.MailingStreet)) 
            {
                newSet.Add(con.Id);
            }
            if(String.IsNotBlank(con.MailingCity)) 
            {
                newSet.Add(con.Id);
            }
            if(String.IsNotBlank(con.MailingState)) 
            {
                newSet.Add(con.Id);
            }
            if(String.IsNotBlank(con.MailingPostalCode)) 
            {
                newSet.Add(con.Id);
            }
            // End of BK - 3038
        }
        if(!newSet.IsEmpty())
        {
            //Call handler class to update email address on user record to same as of contact's
            UpdateContactEmailOnUser_Handler handler = new UpdateContactEmailOnUser_Handler();
            handler.updateContactEmailOnUser(newSet);
        }
      }
      
     /* Ticket No - BK-19067 
        Developer - Shiv Raghav Sharma
        Description -  Email_Address_Updated__c checkbox should be checked automatically whenever the user updates the Email field in a contact.*/
      if(trig.isBefore && trig.isUpdate) 
       {
        //Iteration on updated Contact records
        for(Contact con: trig.newList)
        {
           if(con.Email != trig.oldMap.get(con.Id).Email)
           {
              con.Email_Address_Updated__c = true;
           }         
        }        
       }
        
   }
}