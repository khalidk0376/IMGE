/**
* Project:     GAP
* Date:        20/05/2019
* Created By:  Rajesh Kumar
* Test Class:  OpportunityNotesAttachmentActivity_Test
* *************************************************************************
* @Description Class for Lightning component "Payment_Schedule" on Opportunity .
* *************************************************************************
* Ticket No: GGCW-3294 
* Ticket No: BK-3078 (Adarsh)[Changes done in the new component for the Payment Schedule (Payment_Schedule.cmp)] 
*/

public with sharing class PaymentSchedule_class {
    
    
    @AuraEnabled
    public static Opportunity getallDataRecord(String recordIdget){
        List<Opportunity> listOpportunity = [select id ,Payment_Schedules__c,Payment_Schedule_2__c,Event_Edition_Start_Date__c,Custom_Payment__c,Event_Payment_ScheduleFor__c, Quoted_Payment_Schedule__c,Total_No_of_payment__c,
                                             Start_Date__c,Event_Cutoff_DateF__c,Event_Cutoff_Date_1_F__c,Event_Cutoff_Date_3_F__c,Event_Cutoff_Date2F__c,Milestone_1_Delivery_Date__c,Milestone_2_Delivery_Date__c, 
                                             Milestone_3_Delivery_Date__c,Milestone_4_Delivery_Date__c ,Milestone_5_Delivery_Date__c ,Milestone_6_Delivery_Date__c, Milestone_7_Delivery_Date__c , 
                                             Milestone_8_Delivery_Date__c, Milestone_9_Delivery_Date__c,Milestone_10_Delivery_Date__c ,Milestone_11_Delivery_Date__c ,Milestone_12_Delivery_Date__c,
                                             Milestone_1_Amount__c,Milestone_2_Amount__c,Milestone_3_Amount__c,Milestone_4_Amount__c, Milestone_5_Amount__c,Milestone_6_Amount__c,
                                             Milestone_7_Amount__c,Milestone_8_Amount__c,Milestone_9_Amount__c,Milestone_10_Amount__c,Milestone_11_Amount__c,Milestone_12_Amount__c,
                                             Amount,CurrencyIsoCode 
                                             from Opportunity where Id =:recordIdget LIMIT 1];
        
        if(listOpportunity.size() > 0){
            return listOpportunity[0];
        }else{
            return null;
        }
    }
    
    @AuraEnabled
    public static String validateLoggedInUsr(String recordIdget){
        String profileForAccess = '';
        Opportunity oppDetails = [Select id, OwnerId from Opportunity where Id =:recordIdget LIMIT 1] ;
        User validateProfile = [Select id, Name, Profile.name from User where id =: UserInfo.getUserId()] ;
        if(oppDetails != null){
            if(((validateProfile.Profile.name == 'Sales' || validateProfile.Profile.name == 'Sales-Brasil' || validateProfile.Profile.name == 'Sales-Brazil') && oppDetails.OwnerId == validateProfile.id)){ 
                profileForAccess = validateProfile.Profile.name;
            }
            else if((validateProfile.Profile.name == 'System Administrator' || validateProfile.Profile.name == 'GE BA Administrator' || validateProfile.Profile.name == 'GE System Administrator' || validateProfile.Profile.name == 'SSC Finance-Accounting' || validateProfile.Profile.name == 'Operations' )){
                profileForAccess = validateProfile.Profile.name;
            }
        }
        return(profileForAccess);
    }
    
    @AuraEnabled
    public static void saveData (Opportunity fields){
        
        if(fields != null){
            update fields;
        }
    }    
}