/**
* Created by : Girikon(Prashant)
* Created On :  08/28/2018
* @description : This class provides following functionalities:
*              Bind the values of Company Contact Information from BoothContactInfo or Contact
* Test Class : CustomerProfileContactInfo_Test(95%)
* Modification Log---
* Modified by : Girikon (amish) ,Girikon (Ashish), Girikon(Prashant) [CCEN-743 (April 9 2019), C2E-16 (August 23 2019),C2E-102 (Sept 30 2019)]
* Modified On: 10/11/2018 -JIRA [CCEN 369],10/09/2018 -JIRA [CCEN 371]
**/
public without sharing class CustomerProfileContactInfo{
    public class ContactInfoDetailsWrap{
        @AuraEnabled public string firstname{get;set;}
        @AuraEnabled public string lastname{get;set;}
        @AuraEnabled public string address{get;set;}
        @AuraEnabled public string po_box{get;set;}
        @AuraEnabled public string city{get;set;}
        @AuraEnabled public string state{get;set;}
        @AuraEnabled public string zipcode{get;set;}
        @AuraEnabled public string country{get;set;}
        @AuraEnabled public string telephone{get;set;}
        @AuraEnabled public string fax{get;set;}
        @AuraEnabled public string email{get;set;}
        @AuraEnabled public string ccEmail{get;set;}
        @AuraEnabled public string website{get;set;}
        @AuraEnabled public string boothConId{get;set;}
        @AuraEnabled public string boothConInfoId{get;set;}
        @AuraEnabled public boolean isSubmitted{get;set;}
        @AuraEnabled public boolean isAgent{get;set;}
        @AuraEnabled public string lastUpdatedByName{get;set;}
        @AuraEnabled public Datetime lastUpdatedByDate{get;set;}
    }
    //Contact details are now fetched using the boothId from Opportunity_ExpoCAD_Booth_Mapping__c object id[CCEN-743]
    @AuraEnabled
    public static ContactInfoDetailsWrap getContactDetails(string boothId,String eventId, String accountId, Boolean showLastModFromAgent)
    {
        ContactInfoDetailsWrap coninfo = new ContactInfoDetailsWrap();

        List<Opportunity_ExpoCAD_Booth_Mapping__c> lstBoothCon = new List<Opportunity_ExpoCAD_Booth_Mapping__c>();

        List<User> u =[Select id,AccountId from user where id =:UserInfo.getUserId()];
        System.debug('user  ' +u);

        if(Schema.sObjectType.Opportunity_ExpoCAD_Booth_Mapping__c.isAccessible())
        {
            lstBoothCon = [select Id, Primary_Contact__c, Contact__c from Opportunity_ExpoCAD_Booth_Mapping__c where id =:boothId];
        }
        if(lstBoothCon.size()>0) 
        {
            List<Contact> contactinfo = new List<Contact>();
            if(Schema.sObjectType.Contact.isAccessible())
            {
                contactinfo = [select id,FirstName,LastName,MailingStreet,MailingCity,MailingStateCode,MailingPostalCode,MailingCountryCode,Phone,Fax__c,Email,Website__c,Contact_Type__c from Contact where id = :lstBoothcon[0].Primary_Contact__c ];
            }   
            
            List<BoothContactInfo__c> boothconinfo = new List<BoothContactInfo__c>();
			
			// Added two new fields LastModifiedBy.Profile.Name, LastModifiedBy.AccountId for [C2E-102]
            if(Schema.sObjectType.BoothContactInfo__c.isAccessible())
            {
                boothconinfo =[select Id,Contact__c,First_Name__c,Last_Name__c,Address__c,P_O_Box__c,Telephone__c,Zip_Code__c,City__c,State__c,Fax__c,Email__c,CC_Email__c,Website__c,Country__c, LastModifiedBy.Name, LastModifiedBy.Profile.Name, LastModifiedBy.AccountId, LastModifiedDate, IsSubmitted__c  from BoothContactInfo__c  where  Contact__c = :lstBoothcon[0].Primary_Contact__c and Event_Edition__c=:eventId and Opportunity_Booth_Mapping__c=:boothId ORDER BY createddate ASC limit 1];
            }
            if(!boothconinfo.isEmpty() && !u.isEmpty())
            {
                if(boothconinfo[0].LastModifiedBy.Profile.Name != 'Operations' && boothconinfo[0].LastModifiedBy.AccountId != u[0].AccountId && showLastModFromAgent == false)
                {
                    coninfo.isAgent = true;
                }
            }
            
            if(boothconinfo.size() > 0)
            {
                coninfo.boothConInfoId= boothconinfo[0].Id;
                coninfo.boothConId = boothconinfo[0].Contact__c ;
                coninfo.firstname = boothconinfo[0].First_Name__c;
                coninfo.lastname = boothconinfo[0].Last_Name__c;
                coninfo.address = boothconinfo[0].Address__c;
                coninfo.po_box = boothconinfo[0].P_O_Box__c;
                coninfo.city = boothconinfo[0].City__c;
                coninfo.state = boothconinfo[0].State__c;
                coninfo.zipcode = boothconinfo[0].Zip_Code__c;
                coninfo.telephone = boothconinfo[0].Telephone__c;
                coninfo.fax = boothconinfo[0].Fax__c;
                coninfo.email = boothconinfo[0].Email__c;
                coninfo.ccEmail= boothconinfo[0].CC_Email__c;
                coninfo.website = boothconinfo[0].Website__c;
                coninfo.country = boothconinfo[0].Country__c; 
                coninfo.isSubmitted = boothconinfo[0].IsSubmitted__c;
                coninfo.lastUpdatedByName = boothconinfo[0].LastModifiedBy.Name; // Added this to fetch data of last modified name[C2E-16]
                coninfo.lastUpdatedByDate = boothconinfo[0].LastModifiedDate; // Added this to fetch data of last modified date[C2E-16]
                
            }
            else if(contactinfo.size() >0)
            {
                // Creted BoothContactInfo__c in contact is not avialable [CCEN-371]
                BoothContactInfo__c newBoothContactInfo = new BoothContactInfo__c();  

                newBoothContactInfo.Contact__c= lstBoothcon[0].Primary_Contact__c ;
                newBoothContactInfo.First_Name__c=contactinfo[0].FirstName;
                newBoothContactInfo.Last_Name__c=contactinfo[0].LastName;
                newBoothContactInfo.Address__c=contactinfo[0].MailingStreet;
                //newBoothContactInfo.P_O_Box__c=contactinfo[0].MailingPostalCode;
                newBoothContactInfo.Telephone__c=contactinfo[0].Phone;
                newBoothContactInfo.Zip_Code__c=contactinfo[0].MailingPostalCode;
                newBoothContactInfo.City__c=contactinfo[0].MailingCity;
                newBoothContactInfo.State__c=contactinfo[0].MailingStateCode;
                newBoothContactInfo.Fax__c=contactinfo[0].Fax__c;
                newBoothContactInfo.Email__c=contactinfo[0].Email;
                newBoothContactInfo.Website__c=contactinfo[0].Website__c;
                newBoothContactInfo.Country__c=contactinfo[0].MailingCountryCode;
                newBoothContactInfo.Event_Edition__c=eventId;
                newBoothContactInfo.Opportunity_Booth_Mapping__c=boothId;
                
                if(Schema.sObjectType.BoothContactInfo__c.IsCreateable())
                {
                    insert newBoothContactInfo;
                }
                

                coninfo.boothConInfoId= newBoothContactInfo.Id;
                coninfo.boothConId = lstBoothcon[0].Primary_Contact__c ;
                coninfo.firstname = contactinfo[0].FirstName;
                coninfo.lastname = contactinfo[0].LastName;
                coninfo.address = contactinfo[0].MailingStreet;
                coninfo.city = contactinfo[0].MailingCity;
                coninfo.state = contactinfo[0].MailingStateCode;
                coninfo.zipcode = contactinfo[0].MailingPostalCode;
                coninfo.telephone = contactinfo[0].Phone;
                coninfo.fax = contactinfo[0].Fax__c;
                coninfo.email = contactinfo[0].Email;
                coninfo.website = contactinfo[0].Website__c;
                coninfo.country = contactinfo[0].MailingCountryCode;
                
            }
        }
       
        return coninfo;
    }
    @AuraEnabled
    public static Profile_Package_Setting__c getProfilePackageSetting(String eventId, string boothId, string accountId) 
    {
        User usr = new User();
        if(String.isBlank(accountId))
        {
            usr = [SELECT Id, Contactid,Accountid  FROM User WHERE Id = : UserInfo.getUserId()]; 
        }
        string packageId;
        string query;
        list<User_Package__c>  lstUserPackage = new list<User_Package__c>();
        if(Schema.sObjectType.User_Package__c.isAccessible() && String.isBlank(accountId))
        {
            lstUserPackage = [select Profile_Package_Setting__c from User_Package__c where Event_Edition__c=:eventId and Account__c=:usr.Accountid  limit 1];
        }
        else{
            lstUserPackage = [select Profile_Package_Setting__c from User_Package__c where Event_Edition__c=:eventId and Account__c=:accountid  limit 1];
        }
        if(lstUserPackage.size()>0)
        {
            packageId=lstUserPackage[0].Profile_Package_Setting__c;
        }
        list<Profile_Package_Setting__c> lstProfilePackage = new  list<Profile_Package_Setting__c> (); 
        query='select Id,Booth_Contact_Info__c, Booth_Description__c, Booth_Schedule__c, Logo__c, Press_Release__c, Print_Description__c,Social_Media_Links__c, Web_Description__c,Print_Description_Limit__c,Web_Description_Limit__c from Profile_Package_Setting__c ';
        if(String.isNotBlank(packageId)) 
        {
            query+='  where Id = :packageId ';
        }
        else {
            query+='  where Event_Edition__c = :eventId and Is_Default__c = true ';
        }
        lstProfilePackage =  Database.query(query);
        return lstProfilePackage[0];
    }

    @AuraEnabled //Fetch event details 
    public static Event_Settings__c getEventDetails(String sEventcode)
    {
        return UtilityMethods.getEventDetails(sEventcode); 
    }
    @AuraEnabled
    public static List<String> getPickListValues(string objectName,string fieldName) 
    {
        List<String> options =  UtilityMethods.getPicklistValues(objectName,fieldName);
        return options;
    }
    // fetching expocad details from Opportunity_ExpoCAD_Booth_Mapping__c instead of Expocad Booth[CCEN-743]
    @AuraEnabled
    public static Opportunity_ExpoCAD_Booth_Mapping__c getExpocadBoothDetails(String boothId, String accountId)
    {   
        Opportunity_ExpoCAD_Booth_Mapping__c exBth = new Opportunity_ExpoCAD_Booth_Mapping__c();
        List<Opportunity_ExpoCAD_Booth_Mapping__c> lstExpoDtails= [select id,Booth_Number__c,Display_Name__c,Event_Code__c,Web_Description__c,Print_Description__c,FaceBook__c,Instagram__c,LinkedIn__c,YouTube__c,Twitter__c from Opportunity_ExpoCAD_Booth_Mapping__c where id =:boothId limit 1];
        if(!lstExpoDtails.isEmpty() && lstExpoDtails.size()>0)
        {
            exBth = lstExpoDtails[0];
            if(exBth.Display_Name__c == null || String.isBlank(exBth.Display_Name__c))
            {
                if(String.isNotBlank(accountId))
                {
                    Account acc = new Account();
                    acc = [Select name from Account where Id=:accountId];
                    if(acc.name != null)
                    {
                        exBth.Display_Name__c = acc.name;
                    }
                }
                else
                {
                    user usr = new user();
                    usr = [select contact.account.name from user where id =: UserInfo.getUserId()];
                    if(usr.contact.account.name != null)
                    {
                        exBth.Display_Name__c = usr.contact.account.name;
                    }
                }
                
            }

        }
        return exBth;  
     }
    @AuraEnabled
    public static string createRecord (BoothContactInfo__c boothcontactinfo)
    {
        string msg='Saved Successfully';
        
        try{
            if(String.isNotBlank(boothcontactinfo.Id))
            {
                boothcontactinfo.IsSubmitted__c = true; // CCEN -368 
                update boothcontactinfo;
            }
            else
            {
                boothcontactinfo.IsSubmitted__c = true; //CCEN -368
                insert boothcontactinfo;
            }
            
        } catch (Exception ex){
            msg=ex.getMessage();
        }
        return msg;
    }    
    @AuraEnabled
    public static string updateExpocadBooth(Opportunity_ExpoCAD_Booth_Mapping__c expoBooth)
    {
        string msg='success';
        try{
             update expoBooth;
            
        } catch (Exception ex){
            msg=ex.getMessage();
        }
        return msg;
       
    }
    @AuraEnabled
    public static Profile_Option_Visibility__c getProfileOptionVisibility(String eventId){
        List<Profile_Option_Visibility__c> lstProfileOptions = new List<Profile_Option_Visibility__c>();
        if(Schema.sObjectType.Profile_Option_Visibility__c.isAccessible())
        {
            lstProfileOptions = [select Booth_Contact_Info__c,Event_Edition__c,Logo__c,Print_Description__c,Social_Media_Links__c,Web_Description__c from Profile_Option_Visibility__c where Event_Edition__c =:eventId limit 1];
        }
        return lstProfileOptions[0];  
    }
    
}