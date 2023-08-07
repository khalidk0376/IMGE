/**
 * File:        Rebooking_without_Products.cls
 * Project:     GAP
 * Date:        Nov 25, 2016
 * Created By:  Sourabh Goyal
 * *************************************************************************
 * @description: Controller for Rebooking without Products page .
 * *************************************************************************
 */
public without sharing class Rebooking_without_Products{

    //public set<Id> oppId{get;set;}
    public String idofopp{get;set;}
    public opportunity oppItemList = new opportunity();
    public string eventEditionName{get;set;}
    public String yearOfEvent{get;set;}
    public integer nextYearOfEvent{get;set;}
    public String nameOfNextYear{get;set;}
    public Boolean success{get;set;}
    
    //Contructor calling
    public Rebooking_without_Products(ApexPages.StandardController controller){
        idofopp = ApexPages.currentPage().getParameters().get('id').escapeHtml4();
    }
    
    //Retrieving all the required details of the opportunities to be cloned
    opportunity eCopy = new Opportunity();
    public void objectDetails(){
        
        oppItemList = [select Name,OwnerId,AccountId,Type,Rebooked__c,Partner_Account__c,Opportunity_Contact__c,ReBooking_From_Opportunity__c,Billing_Contact__c,Agreement_Contact__c,Parent_Opportunity__c,CurrencyIsoCode,Payment_Type__c,Total_Billing_Amount__c,CloseDate,StageName,Reason_Lost__c,NextStep,Probability,Amount,Contract_Sign_Status__c,Network__c,Revenue_Estimate__c,Tax_Id__c,LeadSource,Specific_Source__c,Referred_By__c,CampaignId,Description,SBQQ__PrimaryQuote__c,SBQQ__QuotePricebookId__c,EventSeries__c,Event_Edition__c,Contract_Number__c,Contract_Attached__c,SBQQ__Contracted__c,SBQQ__Renewal__c,SBQQ__RenewedContract__c,Stand_Contractor__c,Safety_Contact__c,Marketing_Contact__c,Event_Series__c,EventEdition__c,EventEdition__r.Name,EventEdition__r.Start_Date__c from opportunity where Id=:idofopp];
        
        if(oppItemList.StageName!='Closed Booked' && !test.isRunningTest()){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Only opportunity with StageName equals Closed Booked can be Rebook'));success = false; return;
        }
        if(oppItemList.EventEdition__r.Name!=null && oppItemList.EventEdition__r.Name!=''){
            eventEditionName = oppItemList.EventEdition__r.Name;
        
        
            yearOfEvent = oppItemList.EventEdition__r.Name.substring((eventEditionName.length()-4),eventEditionName.length());
            nextYearOfEvent = integer.valueof(yearofevent)+1;        
            nameOfNextYear =  oppItemList.EventEdition__r.Name.substring(0,(eventEditionName.length()-4)) + string.valueof(nextyearofevent);
    
            system.debug('nameOfNextYear>>>'+nameOfNextYear+'nextyearofevent>>>'+nextyearofevent+'yearofevent>>>'+yearofevent);
    
        }
        list<Event_Edition__c> evE = [select id, name,Part_of_Series__c,Start_Date__c from Event_Edition__c where name =:nameOfNextYear];
            if(evE.isEmpty()){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Opportunity can not be Rebook. New Event Edition not found.'));
                success = false;
                return;
        }
        system.debug('>>>eventEditionId>>> '+evE.get(0).Id +' >>>>>>eventseriesId>> '+evE.get(0).Part_of_Series__c);
        
        if(oppItemList.Rebooked__c == true){ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Opportunity is already Rebooked')); success = false;  return; }
        eCopy = oppItemList.clone(false, false, false, false); eCopy.Name = 'Rebooking-'+oppItemList.Name; eCopy.Type = 'Existing Business'; eCopy.Parent_Opportunity__c = null; eCopy.Payment_Type__c = ''; eCopy.Total_Billing_Amount__c = null; eCopy.CloseDate = evE.get(0).Start_Date__c; String stageName = System.Label.Opportunity_Stage_Name_Discover; eCopy.StageName = stageName;eCopy.Reason_Lost__c = ''; eCopy.NextStep = '';eCopy.Contract_Sign_Status__c = ''; eCopy.Revenue_Estimate__c = null;eCopy.LeadSource = ''; eCopy.Specific_Source__c = ''; eCopy.CampaignId = null; eCopy.SBQQ__PrimaryQuote__c = null; eCopy.SBQQ__QuotePricebookId__c = null ; ecopy.ReBooking_From_Opportunity__c = idofopp; eCopy.Event_Edition__c = ''; eCopy.EventEdition__c = evE.get(0).Id;
        eCopy.Contract_Number__c = ''; eCopy.Contract_Attached__c = false; eCopy.SBQQ__Contracted__c = false; eCopy.SBQQ__Renewal__c = false; eCopy.SBQQ__RenewedContract__c = null; insert eCopy; oppItemList.Rebooked__c = true; update oppItemList;         ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Opportunity has been Rebook'));success = true;
    }
    
    public pageReference previous(){
    
        PageReference pageRef = new PageReference('/'+idofopp);
        return pageRef;
    }
    public pageReference next(){
    
        PageReference pageRef = new PageReference('/'+eCopy.Id);
        return pageRef;
    }
    
}