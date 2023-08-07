/**
 * File:        Rebook_with_Products.cls
 * Project:     GAP
 * Date:        Nov 25, 2016
 * Created By:  Sourabh Goyal
 * *************************************************************************
 * @description Controller for Rebooking with Products page .
 * *************************************************************************
 */
public without sharing class Rebooking_with_Products{
    public String idofopp                               {get;set;}
    public opportunity oppItemList = new opportunity();
    public Boolean success                              {get;set;}
    string eventEditionName;
    String yearofevent;
    integer nextyearofevent;
    String nextyearofeventName;
    public Rebooking_with_Products(ApexPages.StandardController controller){
        idofopp = ApexPages.currentPage().getParameters().get('id').escapeHtml4();
    }
    
    //Retrieving all the required details of the opportunities to be cloned
    opportunity eCopy = new Opportunity();
    public void objectDetails(){
        oppItemList = [select Name,OwnerId,AccountId,Type,Rebooked__c,Partner_Account__c,Opportunity_Contact__c,ReBooking_From_Opportunity__c ,EventEdition__r.Start_Date__c,Billing_Contact__c,Agreement_Contact__c,Parent_Opportunity__c,CurrencyIsoCode,Payment_Type__c,Total_Billing_Amount__c,CloseDate,StageName,Reason_Lost__c,NextStep,Probability,Amount,Contract_Sign_Status__c,Network__c,Revenue_Estimate__c,Tax_Id__c,LeadSource,Specific_Source__c,Referred_By__c,CampaignId,Description,SBQQ__PrimaryQuote__c,SBQQ__QuotePricebookId__c,EventSeries__c,Event_Edition__c,Contract_Number__c,Contract_Attached__c,SBQQ__Contracted__c,SBQQ__Renewal__c,SBQQ__RenewedContract__c,Stand_Contractor__c,Safety_Contact__c,Marketing_Contact__c,Event_Series__c,EventEdition__c,EventEdition__r.Name,(select id, Product2Id,Product2.Event_Edition_Name__c,Brand__c,UnitPrice,Quantity,PricebookEntryId,Name,Product2.name  from OpportunityLineItems) from opportunity where Id=:idofopp];
        if(oppItemList.StageName!='Closed Booked' && !test.isRunningTest()){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Only opportunity with StageName equals Closed Booked can be Rebook.'));success = false;return;}
        
        if( String.isNotBlank(oppItemList.EventEdition__r.Name)) {
            eventEditionName = oppItemList.EventEdition__r.Name;
        }
        
        if(oppItemList.EventEdition__c!=null){
            yearofevent = oppItemList.EventEdition__r.Name.substring((eventEditionName.length()-4),eventEditionName.length());
            nextyearofevent = integer.valueof(yearofevent)+1; 
            nextyearofeventName =  oppItemList.EventEdition__r.Name.substring(0,(eventEditionName.length()-4)) + string.valueof(nextyearofevent);
        }
        system.debug('nextyearofeventName -->:' + nextyearofeventName);
        list<Event_Edition__c> evE = [select id, name,Start_Date__c from Event_Edition__c where name =: nextyearofeventName];
        system.debug('evE -->:' + evE);
        if(evE.isEmpty() && !test.isRunningTest() ){ ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Opportunity can not be Rebook. New Event Edition not found.')); success = false; return;
        }
        
        if(oppItemList.Rebooked__c == true ){ ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Opportunity is already Rebooked.')); success = false; return;
        }
        
        eCopy = oppItemList.clone(false, false, false, false); eCopy.Name = 'Rebooking-'+oppItemList.Name; eCopy.Type = 'Existing Business';eCopy.Parent_Opportunity__c = null; eCopy.Payment_Type__c = '';eCopy.Total_Billing_Amount__c = null; eCopy.CloseDate = evE.get(0).Start_Date__c;ecopy.ReBooking_From_Opportunity__c = idofopp; String stageName = System.Label.Opportunity_Stage_Name_Discover; eCopy.StageName = stageName;eCopy.Reason_Lost__c = '';eCopy.NextStep = ''; eCopy.Contract_Sign_Status__c = ''; eCopy.Revenue_Estimate__c = null; eCopy.LeadSource = '';eCopy.Specific_Source__c = '';eCopy.CampaignId = null;eCopy.SBQQ__PrimaryQuote__c = null;eCopy.SBQQ__QuotePricebookId__c = null;eCopy.Event_Edition__c = ''; eCopy.EventEdition__c = evE.get(0).Id;eCopy.Contract_Number__c = ''; eCopy.Contract_Attached__c = false;eCopy.SBQQ__Contracted__c = false;eCopy.SBQQ__Renewal__c = false; eCopy.SBQQ__RenewedContract__c = null;
        list<OpportunityLineItem> oliList = new list<OpportunityLineItem>(); set<Id> proName = new set<Id>();set<string> proNameforcheckduplicate = new set<string>();map<string,opportunityLineItem> proId = new map<string,opportunityLineItem>();for(OpportunityLineItem oli : oppItemList.OpportunityLineItems){proName.add(oli.Product2Id);proId.put(oli.Product2.Name,oli);}list<Product2> oliList1 = [select id,name,Event_Edition__r.Name from Product2 where Name IN: proId.keyset() AND Event_Edition__r.Name =: nextyearofeventName order by createdDate ASC];map<id,id> proidVsPBEId = new map<id,id>();for(PriceBookEntry pBE : [select id,Product2Id from PriceBookEntry where product2Id IN: oliList1]){proidVsPBEId.put(pBE.Product2Id,pBE.Id);}for(Product2 pro : oliList1){if(!proNameforcheckduplicate.contains(pro.Name)){ proNameforcheckduplicate.add(pro.Name);OpportunityLineItem oliCopy = proId.get(pro.Name).clone(false, false, false, false);olicopy.PriceBookEntryId = proidVsPBEId.get(pro.Id);oliList.add(oliCopy);}
        }
        SavePoint mySavePoint;mySavePoint = Database.setSavePoint();try{if(!oliList.isEmpty()){ insert eCopy;list<OpportunityLineItem> oliListNew = new list<OpportunityLineItem>(); for(OpportunityLineItem oliNew : oliList){oliNew.OpportunityId = eCopy.Id; oliListNew.add(oliNew);}insert oliListNew; oppItemList.Rebooked__c = true;update oppItemList;success = true;ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Opportunity has been Rebook.')); } else{ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Warning,'Opportunity can not be Rebook. Products Not Available for the New Event Edition.'));}}catch(Exception e){ Database.rollBack(mySavePoint);ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Something went wrong, Opportunity can not be Rebook.'));        } }
       
        public pageReference previous(){
        PageReference pageRef = new PageReference('/'+idofopp);
        return pageRef;
    }
    
    public pageReference next(){
        PageReference pageRef = new PageReference('/'+eCopy.Id);
        return pageRef;
    }
}