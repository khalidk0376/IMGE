/**
* Created By    :  Girikon(Rajeev)[BK-2188]
* Created On    :  22/8/2019
* @description  :  Update the MatchMaking details. 
* Test Class    :  MatchMakingCtrl_Test(100%%)
* Modification log --
* Modified By   : Girikon(Rajeev [BK-2188 Sep 2 2019]
**/
public with sharing class MatchMakingCtrl {
   @AuraEnabled
    public static List<GoMed2Med__c> MatchMaking( String supplyDist , string supplyngEndUser, string Distributor, String AccountID ,String eventId ,Datetime lastModifiedDate) {
        List<GoMed2Med__c> goMed2MedMapng = new List<GoMed2Med__c>();
        list<Event_Edition__c> evntCode = new List<Event_Edition__c>();
        List<User> users = new List<User>();
         String userName = UserInfo.getUserId();
         if(Schema.sObjectType.User.isAccessible())
        {
            evntCode=[select id , name , Event_Code__c from Event_Edition__c where id=:eventId ];
        }
        if(Schema.sObjectType.User.isAccessible())
        {
            users=[Select Id, ContactId from User where id =: userName ];
            //system.debug('users'+users[0].ContactId);
        }
        if(Schema.sObjectType.User.isAccessible())
        {
        goMed2MedMapng = [select id , Are_you_a_distributor__c , Are_you_a_manufacturer_supplying_to_End__c , Are_you_a_manufacturer_supplying_to_Dist__c,LastModifiedByCC__c from GoMed2Med__c where   Event_Edition__c=:eventId and Account__c=:AccountID and Event_Code__c=:evntCode[0].Event_Code__c];
           if(goMed2MedMapng.isEmpty())
           {
               GoMed2Med__c goMed = new GoMed2Med__c();
               goMed.Event_Edition__c=eventId;
               goMed.Account__c=AccountID;
               goMed.Event_Code__c=evntCode[0].Event_Code__c;
               goMed.Are_you_a_distributor__c=Distributor;
               goMed.Are_you_a_manufacturer_supplying_to_End__c=supplyngEndUser;
               goMed.Are_you_a_manufacturer_supplying_to_Dist__c=supplyDist;
               goMed.LastModifiedByCC__c=lastModifiedDate; 
               goMed.Contact__c=users[0].ContactId;
               //system.debug('goMed2MedMapng'+goMed2MedMapng); 
                insert goMed ;
               goMed2MedMapng.add(goMed);
           }
           else
            {
                goMed2MedMapng[0].Are_you_a_distributor__c=Distributor;
                goMed2MedMapng[0].Are_you_a_manufacturer_supplying_to_End__c=supplyngEndUser;
                goMed2MedMapng[0].Are_you_a_manufacturer_supplying_to_Dist__c=supplyDist;
                goMed2MedMapng[0].LastModifiedByCC__c=lastModifiedDate;  
                goMed2MedMapng[0].Contact__c=users[0].ContactId;
                update goMed2MedMapng;
            }
         
        }
        //system.debug('goMed2MedMapng'+goMed2MedMapng);
        return goMed2MedMapng; 
    }
    @AuraEnabled
    public static List<GoMed2Med__c> med2MedDetails(String eventId , String accountId)
    {
        List<GoMed2Med__c> goMed2MedMapng = new List<GoMed2Med__c>();
        goMed2MedMapng = [select id , Are_you_a_distributor__c , Are_you_a_manufacturer_supplying_to_End__c , Are_you_a_manufacturer_supplying_to_Dist__c from GoMed2Med__c where   Event_Edition__c=:eventId and Account__c=:accountId];
		//system.debug('goMed2MedMapng'+goMed2MedMapng);
        return goMed2MedMapng;	
    }
}