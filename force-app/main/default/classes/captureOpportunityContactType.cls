/**
 * Created/Modified By: Girikon(Amish)
 * Created On:          06/20/2017
 * Description/Purpose: This class is called through the SKUID page: InformaMainPage
 *                      This Class is used  for fetching the primary Contactas (Opportunity Contact) from Opportunity as  per the eventIDs
 * Methods:             captureOpportunityContactType
 * Test Class:          captureOpportunityContactType_Test
**/
 

global without sharing class captureOpportunityContactType {
   /* web service class to capture contact id, contact name and contact type  */
    webservice static string captureOpportunityContactTypes(String eId,String accId, String contId)
    {
        list<Account> accList= [select id from Account where id =:accId];
        system.debug(accList);
        List< Opportunity> oppList =[select Id,AccountId ,StageName,Stand_Contractor__c,Billing_Contact__c,Billing_Contact__r.name,Marketing_Contact__c,Opportunity_Contact__c,Opportunity_Contact__r.name,Operations_Contact__c,Operations_Contact__r.name,
                                    Safety_Contact__c,Safety_Contact__r.name,Agreement_Contact__c from Opportunity where AccountId =: accId AND EventEdition__c =:eId AND (StageName='Closed Won' OR StageName= 'Closed Booked')ORDER BY createddate 
                                  ASC limit 1];
        list<Contact> conList= [select id from Contact where id =:contId];
        List<ContactDetailWrapper> conWrapper=new List<ContactDetailWrapper>();
        system.debug(oppList );
        Set<id> setConIds= new Set<Id>();
        // Condition to capture Opportunity-contact only from Opportunity 
        if(oppList != null && oppList.size()>0)      
        {
            for(Opportunity opp : oppList )
            {
                                      
                if(opp.Opportunity_Contact__c!=null)
                {
                    
                    ContactDetailWrapper cDetail=new ContactDetailWrapper();
                        cDetail.ContactId=opp.Opportunity_Contact__c;
                        cDetail.name=opp.Opportunity_Contact__r.name;   
                        cDetail.type ='Pri';                                                           
                    conWrapper.add(cDetail);

                }                                                                                 
            }
        }       
        system.debug(conWrapper);
        String JSONString = JSON.serialize(conWrapper);
        system.debug(JSONString );
        return JSONString;// returing in Json format
    }
    
    // wrapper class to populate value with Opportunity fields that will be passed to skuid in JSON format
    global class ContactDetailWrapper
    {
        public String ContactId{get;set;}
        public String name{get;set;}
        public String type {get;set;}         
    }  
          
}