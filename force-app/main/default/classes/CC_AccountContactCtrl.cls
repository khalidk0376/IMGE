/*
Created By		: Girikon(Sunil[STL-21])
Created On		: July 31 2019
@description 	: This class is used to fetch the data cc_accountContacts LWC at Customer Centre.
Test Class		: CC_AccountContactCtrl_Test(91%)

Modification log --
Modified By		: 
*/


public without sharing class CC_AccountContactCtrl {
    /*
* @description [Fetch Current User details]
* @return          [User]
*/
    @AuraEnabled
    Public Static User getCurrentUser(){
        User currentUser = new User();
        currentUser = [Select Id,UserName, SmallPhotoUrl, Name, FirstName, LastName, ContactId, Contact.Name, Contact.Type__c, Contact.Type__r.Name, Contact.AccountId,Contact.Account.Name, AccountId, Account.Name, Contact.Id, LanguageLocaleKey, LocaleSidKey, DefaultCurrencyIsoCode, TimeZoneSidKey,                       EmailEncodingKey, Contact.Contact_Type__c, Account.SSO_ID__c 
                       From User 
                       Where Id = :UserInfo.getUserId()];
        return currentUser;
    }
    /*
* @description [Fetch Event_Edition__c and Event_Settings__c record]
* @param  sEventCode [Event_Code__c to fetch the object record]
* @return          [EventEditionSettingWraper record]
*/
    @AuraEnabled
    Public Static EventEditionSettingWraper getEventDetail(string sEventCode){
        EventEditionSettingWraper eesw = new EventEditionSettingWraper();
        Event_Edition__c eventEdition = new Event_Edition__c();
        if(sEventCode!=null){
            eventEdition = [Select Name, Booth_Type__c, Booth_Size__c, Start_Date__c, Online_Payment_Details__c, Event_Code__c, Event_Edition_Image_URL__c,Event_Price_Book__c, Event_Price_Book__r.Name, Payment_Schedule__c, Cutoff_Date_1__c, Cutoff_Date_2__c, Cutoff_Date_3__c, X50_Cutoff_Date__c,EventCurrency__c, EventCurrency__r.Name, Freeman_Show_ID__c, Part_of_Series__c, Part_of_Series__r.Name, Price_Rule_object_Name__c,Venue__c, End_Date__c,
                            (Select SFContactID__c, Name, SFEventEditionID__c, Id from ContactEventEditionMappings__r) 
                            from Event_Edition__c
                            where Event_Code__c=:sEventCode];
        }
        Event_Settings__c eventSettings = new Event_Settings__c();
        if(sEventCode!=null){
            eventSettings=[Select Event_Edition__c, Event_Edition__r.Name, Event_Edition__r.Event_Code__c, AccountBoothContactDescription__c, AccountHealthSafetyContactDescription__c, AccountInvoiceContactDescription__c,AccountPrimaryContactDescription__c, Welcome_Text_Account_Contacts__c, Is_Booth_Contact_Visible__c, Is_Health_And_Safety_Contact_Visible__c, Is_Invoice_Contact_Visible__c,Is_Primary_Contact_Visibile__c, AccountOperationsContactDescription__c, Is_Operations_Contact_Visible__c
                           from Event_Settings__c 
                           where Event_Edition__r.Event_Code__c =:sEventCode];
        }
        eesw.eventEdition = eventEdition;
        eesw.eventSettings = eventSettings;
        return eesw;
    }
    /*
* @description [Fetch Contact record and User Info]
* @param  sConId [Id to fetch the object record]
* @return          [ContactWrap record]
*/
    
    @AuraEnabled
    public static ContactWrap getContact(String sConId){
        ContactWrap conWrap =new ContactWrap();
        conWrap.con = new Contact();
        if(sConId!=null){
            conWrap.con=[Select Id,  FirstName, LastName, MailingStreet, Title, MailingCity, MailingState, MailingStateCode, MailingCountry, Email, AccountId, Account.Name,Name, Type__c, Type__r.Name, Contact_Type__c, MailingPostalCode 
                         from contact where Id=:sConId];
            List<User> listConUsers = new  List<User>();
            listConUsers= [Select Id, ContactId, UserName 
                           from User 
                           where ContactId=:sConId];
            conWrap.listConUser=listConUsers;
        }
        return conWrap;
    }
    
    /*
* @description [Fetch Contact and Booth records]
* @param  eId [EventEdition__c to fetch the object record]
@param  accId [AccountId to fetch the object record]
* @return          [ContactBoothWrapper record]
*/
    
    @AuraEnabled
    public static ContactBoothWrapper getEventEditionAccountContact(String eId,String accId){
        ContactBoothWrapper  cbw = new ContactBoothWrapper();
        List<Opportunity> oppList =[select Id,AccountId ,StageName,Stand_Contractor__c,Billing_Contact__c,Billing_Contact__r.name,Marketing_Contact__c,Opportunity_Contact__c,Opportunity_Contact__r.name,Operations_Contact__c,Operations_Contact__r.name,Operation_Contact_2__c, Operation_Contact_2__r.Name, Operation_Contact_3__c, Operation_Contact_3__r.Name, Operation_Contact_4__c, Operation_Contact_4__r.name,Operation_Contact_5__c, Operation_Contact_5__r.name, Safety_Contact__c,Safety_Contact__r.name,Agreement_Contact__c 
                                    from Opportunity where AccountId =: Id.valueOf(accId) 
                                    AND EventEdition__c =:Id.valueOf(eId) 
                                    AND (StageName='Closed Won' OR StageName= 'Closed Booked')
                                    ORDER BY createddate 
                                    ASC limit 1];
        //Initializing the wrapper class
        List<ContactDetailWrapper> conWrapper=new List<ContactDetailWrapper>();
        Set<id> setConIds= new Set<Id>();
        // Adding opportunity contact to the wrapper class
        if(oppList != null && oppList.size()>0){
            for(Opportunity opp : oppList ){
                if(opp.Billing_Contact__c!=null){
                    ContactDetailWrapper cDetail=new ContactDetailWrapper();
                    cDetail.ContactId=opp.Billing_Contact__c;
                    cDetail.name=opp.Billing_Contact__r.name;   
                    cDetail.type ='Inv';                                                            
                    conWrapper.add(cDetail);
                }
                if(opp.Opportunity_Contact__c!=null){
                    ContactDetailWrapper cDetail=new ContactDetailWrapper();
                    cDetail.ContactId=opp.Opportunity_Contact__c;
                    cDetail.name=opp.Opportunity_Contact__r.name;   
                    cDetail.type ='Pri';
                    conWrapper.add(cDetail);
                }
                if(opp.Operations_Contact__c!=null) {
                    ContactDetailWrapper cDetail=new ContactDetailWrapper();
                    cDetail.ContactId=opp.Operations_Contact__c;
                    cDetail.name=opp.Operations_Contact__r.name;  
                    cDetail.type ='Op1';                                                           
                    conWrapper.add(cDetail);
                }
                if(opp.Operation_Contact_2__c!=null){
                    ContactDetailWrapper cDetail=new ContactDetailWrapper();
                    cDetail.ContactId=opp.Operation_Contact_2__c;
                    cDetail.name=opp.Operation_Contact_2__r.name;  
                    cDetail.type ='Op2';                                                           
                    conWrapper.add(cDetail);
                }
                if(opp.Operation_Contact_3__c!=null){
                    ContactDetailWrapper cDetail=new ContactDetailWrapper();
                    cDetail.ContactId=opp.Operation_Contact_3__c;
                    cDetail.name=opp.Operation_Contact_3__r.name;  
                    cDetail.type ='Op3';                                                           
                    conWrapper.add(cDetail);
                }
                if(opp.Operation_Contact_4__c!=null){
                    ContactDetailWrapper cDetail=new ContactDetailWrapper();
                    cDetail.ContactId=opp.Operation_Contact_4__c;
                    cDetail.name=opp.Operation_Contact_4__r.name;  
                    cDetail.type ='Op4';                                                           
                    conWrapper.add(cDetail);
                }
                if(opp.Operation_Contact_5__c!=null){
                    ContactDetailWrapper cDetail=new ContactDetailWrapper();
                    cDetail.ContactId=opp.Operation_Contact_5__c;
                    cDetail.name=opp.Operation_Contact_5__r.name;  
                    cDetail.type ='Op5';                                                           
                    conWrapper.add(cDetail);
                }
                if(opp.Safety_Contact__c!=null) {
                    ContactDetailWrapper cDetail=new ContactDetailWrapper();
                    cDetail.ContactId=opp.Safety_Contact__c;
                    cDetail.name=opp.Safety_Contact__r.name;                       
                    cDetail.type ='Hlt';                                                           
                    conWrapper.add(cDetail);
                }                                                     
            }
        }
        set<string> setQuoteIds = new set<string>();
        // Initializaing the booth wrapper class
        List<boothDetailsWrapper> expoBoothWrpr =new List<boothDetailsWrapper>();               
        if(string.isNotBlank(accId) && string.isNotBlank(eId)){
            List<opportunity> opp = [select id,Name,SBQQ__PrimaryQuote__c 
                                     from opportunity 
                                     where AccountId=:accId 
                                     AND 
                                     EventEdition__c=:eId 
                                     AND (StageName='Closed Won' OR StageName='Closed Booked') 
                                     order by createdDate];
            if(opp!=null && opp.size()>0){ 
                for(opportunity oppty: opp){
                    if(oppty.SBQQ__PrimaryQuote__c!=null){
                        setQuoteIds.add(oppty.SBQQ__PrimaryQuote__c);
                    }
                }
            }
            if(opp!=null && opp.size()>0){
                if(!setQuoteIds.IsEmpty()){
                    List<Opportunity_ExpoCAD_Booth_Mapping__c> expoBoothsMapping = [Select id,Expocad_Booth__c,Expocad_Booth__r.Status__c, Expocad_Booth__r.Booth_Number__c,Primary_Contact__c,Primary_Contact__r.name, Quote__c, Opportunity__c, Status__c 
                                                                                    from Opportunity_ExpoCAD_Booth_Mapping__c 
                                                                                    where Status__c= 'Active' 
                                                                                    AND Expocad_Booth__r.Status__c='Rented' 
                                                                                    AND quote__c  IN:setQuoteIds 
                                                                                    order by Opportunity__r.createdDate];
                    if(expoBoothsMapping !=null && expoBoothsMapping .size()>0){
                        for(Opportunity_ExpoCAD_Booth_Mapping__c ecb: expoBoothsMapping) {
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
        cbw.contactDetailJson = JSON.serialize(conWrapper);
        cbw.boothDetailJson =JSON.serialize(expoBoothWrpr);
        return cbw;// returing in Json format
    }
    
    
    
    /*
* @description [Update Contact]
* @param  con [Edited contact data]
* @return          []
*/
    
    @AuraEnabled 
    public static void saveContact(Contact con){
        Contact conToUpdate = new Contact();
        conToUpdate =[Select Id,  FirstName, LastName, MailingStreet, Title, MailingCity, MailingState, MailingStateCode, MailingCountry, Email, AccountId, Account.Name,MailingPostalCode
                      from contact 
                      where Id=:con.Id];
        conToUpdate.FirstName=con.FirstName;
        conToUpdate.LastName=con.LastName;
        conToUpdate.MailingStreet=con.MailingStreet;
        conToUpdate.Email=con.Email;
        conToUpdate.MailingCity=con.MailingCity;
        conToUpdate.MailingState=con.MailingState;
        conToUpdate.MailingPostalCode=con.MailingPostalCode;
        conToUpdate.MailingCountry=con.MailingCountry;
        conToUpdate.Title=con.Title;
        if(conToUpdate!=null){
            update conToUpdate;
        }
    }
    
    public class ContactDetailWrapper {
        @AuraEnabled
        public String ContactId;
        @AuraEnabled
        public String Name;
        @AuraEnabled
        public String LastName;
        @AuraEnabled
        public String ContactType; 
        @AuraEnabled
        public String Type;        
    } 
    public class BoothDetailsWrapper{
        @AuraEnabled
        public String boothId;
        @AuraEnabled
        public String boothName;
        @AuraEnabled
        public String boothContactId;
        @AuraEnabled
        public String boothContactName;             
    }
    public class ContactBoothWrapper{
        @AuraEnabled
        public string contactDetailJson;
        @AuraEnabled
        public string boothDetailJson;
    }
    
     public class ContactWrap{
        @AuraEnabled
         public Contact con;
         @AuraEnabled
         public List<User> listConUser;
     }
    
    public class EventEditionSettingWraper{
        @AuraEnabled
        public Event_Edition__c eventEdition;
        @AuraEnabled
        public Event_Settings__c eventSettings;
    }  
}