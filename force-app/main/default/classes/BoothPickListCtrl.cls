/**
 * Created/Modified By: Girikon(Amish Ranjit,  Archit Agarwal, Aishwarya Kumar, Prashant)
 * Created On:          9/8/2017, 11/22/2018
 * @description : This class is used for the Customer Profile tab on Customer Community. The booth picklist is shown using this class.
 *                      This class is the controller for BoothPicklist VF page.
 * Methods:             getOppBoothDetails,getBoothItems
 * Test Class:          BoothPickListCtrl_Test(98%) 
 *
 * Modification Log---
 * Modified By:         Girikon(Prashant[CCEN-743] Apr 18 2019, [C2E-16] Aug 23 2019, [STL-117] Oct 24 2019)
 **/

public without sharing class BoothPickListCtrl
{
    public string BoothItemId{get;set;}

    /**
    * @description : get data on Method getOppBoothDetails from Opportunity_ExpoCAD_Booth_Mapping__c[CCEN-743]
    **/
    public List<boothDetailsWrapper> getOppBoothDetails()
    {
        String accountId = ApexPages.currentPage().getParameters().get('accountId');
        String eventId = ApexPages.currentPage().getParameters().get('eventId');
        Date currentDate =  date.today();
        set<string> quoteIds = new set<string>();
        List<boothDetailsWrapper> expoBoothWrpr =new List<boothDetailsWrapper>();
        List<Opportunity_ExpoCAD_Booth_Mapping__c> expoBoothMapping= new List<Opportunity_ExpoCAD_Booth_Mapping__c>();
        
        if(string.isNotBlank(accountId) && string.isNotBlank(eventId))
        {
            List<opportunity> opp = [Select id,Name,SBQQ__PrimaryQuote__c 
                                     From opportunity 
                                     Where AccountId=:accountId AND 
                                     EventEdition__c=:eventId AND (StageName='Closed Won' OR StageName='Closed Booked') 
                                     Order by createdDate];
            
            if(opp!=null && opp.size()>0)
            { 
                for(opportunity oppty: opp)
                {
                    if(oppty.SBQQ__PrimaryQuote__c!=null)
                    {
                        quoteIds.add(oppty.SBQQ__PrimaryQuote__c);
                    }
                }
            }
            if(opp!=null && opp.size()>0)
            {
                if(!quoteIds.IsEmpty())                  
                {
                    //Added condition of Related_Opportunity__c and Opportunity__r.User_Type__r.Name for [CCEN-416]
                    expoBoothMapping = [Select Id, Booth_Number__c,Opportunity__r.Account.Name, Expocad_Booth__c 
                                        FROM Opportunity_ExpoCAD_Booth_Mapping__c 
                                        Where Expocad_Booth__r.Status__c='Rented' 
                                        And Status__c = 'Active' 
                                        AND quote__c IN:quoteIds 
                                        And (Opportunity__r.User_Type__r.Name != 'Agent' OR Opportunity__r.Parent_Opportunity__c != null) 
                                        order by Opportunity__r.createdDate];
                   
                }
                if(expoBoothMapping !=null && expoBoothMapping.size()>0)              
                {
                    for(Opportunity_ExpoCAD_Booth_Mapping__c ecb: expoBoothMapping)
                    {
                        boothDetailsWrapper bdw=new boothDetailsWrapper();
                        bdw.boothName=ecb.Booth_Number__c;
                        bdw.boothId=ecb.Id;
                        bdw.accountName=ecb.Opportunity__r.Account.Name;
                        expoBoothWrpr.add(bdw);
                    }
                }
            }
        }
      return expoBoothWrpr;
  }  
        /**
        * @description : get data on Method getBoothItems from Opportunity_ExpoCAD_Booth_Mapping__c[CCEN-743]
        **/
    public List<SelectOption> getBoothItems(){
        List<SelectOption> options = new List<SelectOption>();
        
        List<boothDetailsWrapper> boothDetails= getOppBoothDetails();
        if(boothDetails != null && boothDetails.size()>0)
        {
            for(boothDetailsWrapper boothDetail :boothDetails)
            {
                options.add(new SelectOption(boothDetail.boothId,boothDetail.accountName+' - '+ boothDetail.boothName ));
            }
            BoothItemId=boothDetails[0].boothId;
        }      
        return options;
    }

       /**
        * @description : get Booth Details For ExhProfile
        * @param : account id [account Id ]
        * @param : eventId[ Evnet Id]
        * @return : return[List of booth details wrapper]
        **/
    @AuraEnabled
    public static List<boothDetailsWrapper> getOppBoothDetailsForExhProfile(String accountId, String eventId)
        {
            Date currentDate =  date.today();
            set<string> quoteIds = new set<string>();
            List<boothDetailsWrapper> expoBoothWrpr =new List<boothDetailsWrapper>();
            List<Opportunity_ExpoCAD_Booth_Mapping__c> expoBoothMapping= new List<Opportunity_ExpoCAD_Booth_Mapping__c>();
            
            if(string.isNotBlank(accountId) && string.isNotBlank(eventId))
            {
                List<opportunity> opp = [Select id,Name,SBQQ__PrimaryQuote__c 
                                         From opportunity 
                                         Where AccountId=:accountId 
                                         AND  EventEdition__c=:eventId 
                                         AND (StageName='Closed Won' OR StageName='Closed Booked')];
                if(opp!=null && opp.size()>0)
                { 
                    for(opportunity oppty: opp)
                    {
                        if(oppty.SBQQ__PrimaryQuote__c!=null)
                        {
                            quoteIds.add(oppty.SBQQ__PrimaryQuote__c);
                        }
                    }
                }
                if(opp!=null && opp.size()>0)
                {
                    if(!quoteIds.IsEmpty())                  
                    {
                        //Added condition of Related_Opportunity__c and Opportunity__r.User_Type__r.Name for [CCEN-416]
                        expoBoothMapping = [Select Id, Booth_Number__c,Opportunity__r.Account.Name, Expocad_Booth__c 
                                            FROM Opportunity_ExpoCAD_Booth_Mapping__c 
                                            Where Expocad_Booth__r.Status__c='Rented' 
                                            And Status__c = 'Active' 
                                            AND quote__c IN:quoteIds 
                                            And (Opportunity__r.User_Type__r.Name != 'Agent' OR Opportunity__r.Parent_Opportunity__c != null)
                                            order by Opportunity__r.createdDate];
                    
                    }
                    if(expoBoothMapping !=null && expoBoothMapping.size()>0)              
                    {
                        for(Opportunity_ExpoCAD_Booth_Mapping__c ecb: expoBoothMapping)
                        {
                            boothDetailsWrapper bdw=new boothDetailsWrapper();
                            bdw.boothName=ecb.Booth_Number__c;
                            bdw.boothId=ecb.Id;
                            bdw.accountName=ecb.Opportunity__r.Account.Name;
                            expoBoothWrpr.add(bdw);
                        }
                    }
                }
            }
        return expoBoothWrpr;
    } 

      /**
        * @description : get getProfilePackageSetting  For ExhProfile
        * @param : eventId [eventId ]
        * @param : boothId[ boothId]
        * @param : accountId[accountId]
        * @return : return[List of booth details wrapper]
        **/
    @AuraEnabled
    public static Profile_Package_Setting__c getProfilePackageSetting(String eventId, string boothId, string accountId) 
    {
        string packageId;
        string query;
        list<User_Package__c>  lstUserPackage = new list<User_Package__c>();

        lstUserPackage = [Select Profile_Package_Setting__c 
                          From User_Package__c 
                          Where Event_Edition__c=:eventId 
                          And Account__c=:accountid  
                          Limit 1];

        if(lstUserPackage.size()>0)
        {
            packageId=lstUserPackage[0].Profile_Package_Setting__c;
        }
        list<Profile_Package_Setting__c> lstProfilePackage = new  list<Profile_Package_Setting__c> (); 
        //Added Show_Hide_MatchMaking__c in the query[STL-117]
        query='select Id,Booth_Contact_Info__c, Booth_Schedule__c, Press_Release__c,Show_Hide_MatchMaking__c  from Profile_Package_Setting__c ';
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
	
      /**
        * @description : get Booth Details For ExhProfile
        * @param : account id [account Id ]
        * @param : eventId[ Evnet Id]
        * @return : return[List of booth details wrapper]
        **/
    @AuraEnabled
    public static Profile_Option_Visibility__c getProfileOptionVisibility(String eventId){
        List<Profile_Option_Visibility__c> lstProfileOptions = new List<Profile_Option_Visibility__c>();
        if(Schema.sObjectType.Profile_Option_Visibility__c.isAccessible())
        {
            //Added Show_Hide_MatchMaking__c in the query[STL-117]
            lstProfileOptions = [Select Booth_Contact_Info__c,Event_Edition__c, Show_Hide_MatchMaking__c,Product_Categories__c,Product_Listing__c,Show_Specials__c,Videos__c,Documents__c,Booth_Schedule__c,Press_Release__c 
                                 From Profile_Option_Visibility__c 
                                 Where Event_Edition__c =:eventId 
                                 Limit 1];
        }
        return lstProfileOptions[0];  
    }

    // get current user type from contactEventEditionMapping the selected user
    @AuraEnabled
    public static ContactEventEditionMapping__c getCurrentUserType(String eventId)
    {  
        String evntId = eventId.escapeHtml4(); 
        ContactEventEditionMapping__c objConEvnMap = new  ContactEventEditionMapping__c();
        objConEvnMap = CommunityExhibitorBadgeCtrl.getCurrentUserType(evntId);
        return objConEvnMap;
    }

    public class boothDetailsWrapper
    {
        @AuraEnabled public string boothId{get;set;}
        @AuraEnabled public string boothName{get;set;}
        @AuraEnabled public string accountName{get;set;}
    }
}