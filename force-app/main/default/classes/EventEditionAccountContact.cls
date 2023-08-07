/**
 * Created/Modified By: Girikon(Amish)
 * Created On:          11/21/2017
 * LastModified By :    Amish (SU112R-302) (CCEN-739)
 * LastModifiedDate:    04/15/2019 
 * @description      : This class is called through the SKUID page: AccountContactList
 *                      This Class is for fetching the accountContactas from Opportunity per the eventIDs and pasing it to the skuid page
 * Methods:             EventEditionAccountContact, EventEditionAccountEventBooth
 * Test Class:          EventEditionAccountContact_Test
**/
 

Global without sharing class EventEditionAccountContact
{
   /* web service class to capture contact id,ContactName and Type */
    //@RemoteAction
    //public static string EventEditionAccountContact (String eId,String accId)
    webservice static string EventEditionAccountContact(String eId,String accId)
    {
        //list<Account> accList= [select id from Account where id =:accId];
        //system.debug(accList);
        List< Opportunity> oppList =[select Id,AccountId ,StageName,Stand_Contractor__c,Billing_Contact__c,Billing_Contact__r.name,Marketing_Contact__c,Opportunity_Contact__c,Opportunity_Contact__r.name,Operations_Contact__c,Operations_Contact__r.name,
                                    Operation_Contact_2__c, Operation_Contact_2__r.Name, Operation_Contact_3__c, Operation_Contact_3__r.Name, Operation_Contact_4__c, Operation_Contact_4__r.name, 
                                    Operation_Contact_5__c, Operation_Contact_5__r.name, Safety_Contact__c,Safety_Contact__r.name,Agreement_Contact__c from Opportunity where AccountId =: accId AND EventEdition__c =:eId AND (StageName='Closed Won' OR StageName= 'Closed Booked')ORDER BY createddate 
                                  ASC limit 1];
        //Initializing the wrapper class
        List<ContactDetailWrapper> conWrapper=new List<ContactDetailWrapper>();
        system.debug(oppList );
        Set<id> setConIds= new Set<Id>();
        // Adding opportunity contact to the wrapper class
        if(oppList != null && oppList.size()>0)      
        {
            for(Opportunity opp : oppList )
            {
                if(opp.Billing_Contact__c!=null)
                {
                   ContactDetailWrapper cDetail=new ContactDetailWrapper();
                        cDetail.ContactId=opp.Billing_Contact__c;
                        cDetail.name=opp.Billing_Contact__r.name;   
                        cDetail.type ='Inv';                                                            
                    conWrapper.add(cDetail);
                }
                
               
                if(opp.Opportunity_Contact__c!=null)
                {
                    ContactDetailWrapper cDetail=new ContactDetailWrapper();
                        cDetail.ContactId=opp.Opportunity_Contact__c;
                        cDetail.name=opp.Opportunity_Contact__r.name;   
                        cDetail.type ='Pri';                                                           
                    conWrapper.add(cDetail);
                }
                
                if(opp.Operations_Contact__c!=null)
                {
                    ContactDetailWrapper cDetail=new ContactDetailWrapper();
                        cDetail.ContactId=opp.Operations_Contact__c;
                        cDetail.name=opp.Operations_Contact__r.name;  
                        cDetail.type ='Op1';                                                           
                    conWrapper.add(cDetail);
                }
                
                if(opp.Operation_Contact_2__c!=null)
                {
                    ContactDetailWrapper cDetail=new ContactDetailWrapper();
                        cDetail.ContactId=opp.Operation_Contact_2__c;
                        cDetail.name=opp.Operation_Contact_2__r.name;  
                        cDetail.type ='Op2';                                                           
                    conWrapper.add(cDetail);
                }
                
                if(opp.Operation_Contact_3__c!=null)
                {
                    ContactDetailWrapper cDetail=new ContactDetailWrapper();
                        cDetail.ContactId=opp.Operation_Contact_3__c;
                        cDetail.name=opp.Operation_Contact_3__r.name;  
                        cDetail.type ='Op3';                                                           
                    conWrapper.add(cDetail);
                }
                if(opp.Operation_Contact_4__c!=null)
                {
                    ContactDetailWrapper cDetail=new ContactDetailWrapper();
                        cDetail.ContactId=opp.Operation_Contact_4__c;
                        cDetail.name=opp.Operation_Contact_4__r.name;  
                        cDetail.type ='Op4';                                                           
                    conWrapper.add(cDetail);
                }
                
                if(opp.Operation_Contact_5__c!=null)
                {
                    ContactDetailWrapper cDetail=new ContactDetailWrapper();
                        cDetail.ContactId=opp.Operation_Contact_5__c;
                        cDetail.name=opp.Operation_Contact_5__r.name;  
                        cDetail.type ='Op5';                                                           
                    conWrapper.add(cDetail);
                }
                
                if(opp.Safety_Contact__c!=null)
                {
                    ContactDetailWrapper cDetail=new ContactDetailWrapper();
                        cDetail.ContactId=opp.Safety_Contact__c;
                        cDetail.name=opp.Safety_Contact__r.name;                       
                        cDetail.type ='Hlt';                                                           
                    conWrapper.add(cDetail);
                }                                                     
            }
        }
        system.debug(setConIds);
        system.debug(conWrapper);
        String jSONString = JSON.serialize(conWrapper);
        system.debug(jSONString );
        return jSONString;// returing in Json format
    }
    
    
    /* web service class to capture booth id */
    webservice static string EventEditionAccountEventBooth(String eId,String accId)
    {
        //list<Account> accList= [select id from Account where id =:accId];
        //system.debug(accList);
        set<string> quoteIds = new set<string>();
        // Initializaing the booth wrapper class
        List<boothDetailsWrapper> expoBoothWrpr =new List<boothDetailsWrapper>();               
        if(string.isNotBlank(accId) && string.isNotBlank(eId))
        {
            List<opportunity> opp = [select id,Name,SBQQ__PrimaryQuote__c from opportunity where AccountId=:accId AND 
                                      EventEdition__c=:eId AND (StageName='Closed Won' OR StageName='Closed Booked') order by createdDate];
            System.debug('opp11='+opp);
            if(opp!=null && opp.size()>0)
            { 
                for(opportunity oppty: opp)
                {
                    if(oppty.SBQQ__PrimaryQuote__c!=null) //(SU112R-302)
                    {
                        quoteIds.add(oppty.SBQQ__PrimaryQuote__c);
                    }
                }
            }
            System.debug('quoteIds:='+quoteIds);
            if(opp!=null && opp.size()>0)
            {
                if(!quoteIds.IsEmpty())
                {
                    //(SU112R-302)
                    //List<ExpocadBooth__c> expoBooths = [Select Id, Booth_Number__c,BoothContact__c,BoothContact__r.Name, status__c,Opportunity__r.Account.Name FROM ExpocadBooth__c where status__c='Rented' and  quote__c IN:quoteIds order by Opportunity__r.createdDate  ];
                    // (CCEN-739)
                    List<Opportunity_ExpoCAD_Booth_Mapping__c> expoBoothsMapping = [Select id,Expocad_Booth__c,Expocad_Booth__r.Status__c, Expocad_Booth__r.Booth_Number__c,Primary_Contact__c,Primary_Contact__r.name, Quote__c, Opportunity__c, Status__c from Opportunity_ExpoCAD_Booth_Mapping__c where Status__c= 'Active' AND Expocad_Booth__r.Status__c='Rented' AND quote__c  IN:quoteIds order by Opportunity__r.createdDate];
                    if(expoBoothsMapping !=null && expoBoothsMapping .size()>0)              
                    {
                      for(Opportunity_ExpoCAD_Booth_Mapping__c ecb: expoBoothsMapping )
                      {
                          boothDetailsWrapper bdw=new boothDetailsWrapper();
                          bdw.boothName=ecb.Expocad_Booth__r.Booth_Number__c;
                          bdw.boothId=ecb.Expocad_Booth__c;
                          bdw.boothContactId=ecb.Primary_Contact__c;
                          bdw.boothContactName=ecb.Primary_Contact__r.Name;
                          expoBoothWrpr.add(bdw);
                       }
                    }                    
                }
            }
        }
        system.debug(expoBoothWrpr);
        String jSONStringBooth = JSON.serialize(expoBoothWrpr); // Serializing the wrapper into JSON format
        system.debug(jSONStringBooth  );
        return jSONStringBooth ;   // returing in Json format           
    }
    // wrapper class to populate value with product fields that will be passed to skuid in JSON format
    global class ContactDetailWrapper
    {
        public String ContactId{get;set;}
        public String name{get;set;}
        public String LastName{get;set;} 
        public String ContactType{get;set;} 
        public String type {get;set;}         
    }  
    global class boothDetailsWrapper
    {
        public String boothId{get;set;}
        public String boothName{get;set;}
        public String boothContactId{get;set;}
        public String boothContactName{get;set;}             
    }         
}