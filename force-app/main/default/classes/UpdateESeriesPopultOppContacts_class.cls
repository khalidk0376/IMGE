/**
* Class Name: UpdateESeriesPopultOppContacts_class
* Created By : Rajesh Kumar 
* Created Date : 13/02/2019
* Test Class: UpdtESeriesPopultOppContcs_class_test(90%)
* **************************************************************************************************************************
* @description: This class is used to do the functionality of Process builder "Convert Lead to opportunity" 
* Modified By: Rajesh Kumar On 13 FeB 2019 T - GGCW-3124
* Modified By: Avinash Shukla On 1 July 2019 T - BK-1240
* Modified By: Adarsh Sharma On 23 Sept 2019 T - BK-2458
* Modified By: Shiv Raghav On 14 Nov 2019 T - BK-2874
* Modified By: Shiv Raghav(Bk-5887) on 20 July 2020.
* Modified By: Shiv Raghav(Bk-7068) on 29 July 2020.
* Modified By : Shiv Raghav(Bk-6861) on 16/2/2020.
* **************************************************************************************************************************
**/

public without sharing class UpdateESeriesPopultOppContacts_class implements TriggerInterface_Lead.Runnable {
    Set<Id> setContact = new Set<Id>();
    Set<Id> setOpp = new Set<Id>();
    Set<Id> setLeadId = new Set<Id>();
    Map<id,id> convertedAccountMap = new Map<id,id>();
    Map<id,id> convertedContactMap = new Map<id,id>();
    Map<id,id> convertedOpportunityMap = new Map<id,id>();
    Set<Id> convertedLeadIdset = new Set<Id>();
    Integer maxSize = 254;
    
    public void run(TriggerInterface_Lead.Trig trig) {
        if(trig.isAfter)
        {
            if (trig.isupdate &&  trig.isAfter){
                if(!trig.newList.isEmpty()){
                    Boolean invoiceContact = false;                    
                    for(Lead olead : trig.newList){
                        if ( olead.isConverted ){ 
                            convertedLeadIdset.add(olead.id);
                            if(olead.ConvertedOpportunityId != null)
                            {
                                setOpp.add(olead.ConvertedOpportunityId ); 
                                convertedOpportunityMap.put(olead.id, olead.ConvertedOpportunityId);
                            }
                            if(olead.ConvertedContactId != null)
                            {
                                setContact.add(olead.ConvertedContactId ); 
                                convertedContactMap.put(olead.id, olead.ConvertedContactId);
                                
                            }
                            if(olead.ConvertedAccountId != null)
                            {
                                convertedAccountMap.put(olead.id, olead.ConvertedAccountId);  
                            }
                            //Changes regarding BK-2458 [START]
                            If(olead.Lead_Type__c != NULL && olead.Lead_Type__c.contains('Invoice Contact')){
                                invoiceContact = true;                           
                            }
                            //Changes regarding BK-2458 [END]
                        }
                        if (trig.oldmap.get(olead.Id).Event_Edition__c != olead.Event_Edition__c && olead.Event_Edition__c != null){
                            setLeadId.add(olead.Id);
                        }
                        
                    }
                    if(setOpp.size() > 0) {
                        
                        List<Opportunity> lstOpportunity = [select Id , SBQQ__QuotePricebookId__c, EventEdition__r.Event_Currency__c , PriceBook2Id, EventEdition__r.Event_Price_Book__r.Id, CurrencyIsoCode, Opportunity_Contact__c, Operations_Contact__c  from Opportunity where Id IN : setOpp];
                        if (lstOpportunity.size() > 0){
                            
                            for(Opportunity opp : lstOpportunity){                        
                                //BK-2874 modified by shiv raghav (upon Lead Conversion The Opportunity Currency Should Default to Event Edition - Event Currency)                        
                                if(opp.EventEdition__r.Event_Currency__c != Null)
                                {
                                    opp.CurrencyIsoCode = opp.EventEdition__r.Event_Currency__c;
                                    opp.PriceBook2Id = opp.EventEdition__r.Event_Price_Book__r.Id;
                                    opp.SBQQ__QuotePricebookId__c = opp.EventEdition__r.Event_Price_Book__r.Id;
                                }
                                // End of bk-2874                                                  
                                for (String sContactId : setContact){
                                    opp.Opportunity_Contact__c = sContactId;
                                    opp.Operations_Contact__c = sContactId;
                                    //Modified by Avinash  : BK-1240
                                    opp.CloseDate = Date.Today() + 30;
                                    opp.By_Pass_Validation_Rule__c = true;
                                    //Changes regarding BK-2458 [START]
                                    if (invoiceContact){
                                        opp.Billing_contact__c = sContactId;
                                    }
                                    //Changes regarding BK-2458 [END]
                                } 
                            }
                            update lstOpportunity ;
                        }
                    }
                    
                    /*Bk-6861 
Developer : Shiv Raghav Sharma
Date : 16/2/2021
*/
                    if(!convertedLeadIdset.isEmpty())
                    {
                        List<LeadInterestLevelMapping__c> listofInterestMaapingrecords = new List<LeadInterestLevelMapping__c>();
                        List<Lead_Nature_Of_Business_Mapping__c> listofNatureBsnsMaapingrecords = new List<Lead_Nature_Of_Business_Mapping__c>();
                        for(LeadInterestLevelMapping__c interestMap : [Select id,SFDCLeadID__c,SFDCContactID__c,SFDCAccountID__c,SFDCOpportunityID__c from LeadInterestLevelMapping__c where SFDCLeadID__c In : convertedLeadIdset ])
                        {
                            if(convertedOpportunityMap.containsKey(interestMap.SFDCLeadID__c))
                            {
                                interestMap.SFDCOpportunityID__c = convertedOpportunityMap.get(interestMap.SFDCLeadID__c);  
                            }
                            if(convertedContactMap.containsKey(interestMap.SFDCLeadID__c))
                            {
                                interestMap.SFDCContactID__c = convertedContactMap.get(interestMap.SFDCLeadID__c);  
                            }
                            if(convertedAccountMap.containsKey(interestMap.SFDCLeadID__c))
                            {
                                interestMap.SFDCAccountID__c = convertedAccountMap.get(interestMap.SFDCLeadID__c);  
                            }
                            listofInterestMaapingrecords.add(interestMap);  
                        }
                        if(!listofInterestMaapingrecords.isEmpty())
                        {
                            update listofInterestMaapingrecords;
                        }
                        for(Lead_Nature_Of_Business_Mapping__c NatureMap : [Select id,Lead__c,Contact__c,Account__c,Opportunity__c from Lead_Nature_Of_Business_Mapping__c where Lead__c In : convertedLeadIdset ])
                        {
                            if(convertedOpportunityMap.containsKey(NatureMap.Lead__c))
                            {
                                NatureMap.Opportunity__c  = convertedOpportunityMap.get(NatureMap.Lead__c);  
                            }
                            if(convertedContactMap.containsKey(NatureMap.Lead__c))
                            {
                                NatureMap.Contact__c = convertedContactMap.get(NatureMap.Lead__c);  
                            }
                            if(convertedAccountMap.containsKey(NatureMap.Lead__c))
                            {
                                NatureMap.Account__c = convertedAccountMap.get(NatureMap.Lead__c);  
                            }
                            listofNatureBsnsMaapingrecords.add(NatureMap);  
                        }
                        
                        if(!listofNatureBsnsMaapingrecords.isEmpty())
                        {
                            update listofNatureBsnsMaapingrecords;
                        }                        
                    } 
                    //End of Bk-6861  
                }
            }   
            
            if (trig.isAfter && trig.isInsert){
                for (Lead ole : trig.newList){
                    if (ole.Event_Edition__c != null){
                        setLeadId.add(ole.Id);
                    }
                }
            }
            
            if (!setLeadId.isEmpty()){
                Map<Id, Lead> mapLead = new  Map<Id, Lead> ([Select Id , Name , Event_Edition__c , Event_Edition__r.Part_of_Series__c ,Event_Series__c From Lead where Id IN : setLeadId ]);
                for (Lead olead :mapLead.values()){
                    if(olead.Event_Edition__c != null){
                        olead.Event_Series__c =  olead.Event_Edition__r.Part_of_Series__c;
                    }
                }
                if (mapLead.values().size() > 0){
                    update mapLead.values();
                }
            }
        }
        /*
Developed By - Shiv Raghav(Bk-5887) and Bk-7068
Description - We need to get populate Nature of business field based on description field. 
*/   
        if(trig.isbefore && trig.isInsert)
        {            
            
            for(Lead olead : trig.newList){                       
                if(String.isNotBlank(olead.Description) && (olead.Description.contains('NOBs') || olead.Description.contains('Interests')))  
                {                                               
                    List<String> lines = olead.Description.split('\n');
                    if(!lines.isEmpty())
                    {
                        for(String str : lines)
                        {
                            if(str.contains('NOBs'))
                            {                                
                                String natureofBusiness = str.remove('NOBs:');
                                if(natureofBusiness.length() > maxSize ){
                                  olead.Nature_of_Business__c =natureofBusiness.substring(0, maxSize);  
                                }
                                else
                                {
                                  olead.Nature_of_Business__c = natureofBusiness;
                                } 
                            }
                            //Bk-7068
                            if(Str.contains('Interests'))
                            {
                                String interestLevel = str.remove('Interests:');
                                if(interestLevel .length() > maxSize ){
                                  olead.Interest_L1__c = interestLevel.substring(0, maxSize);
                                }
                                else
                                {
                                olead.Interest_L1__c = interestLevel ;  
                                }
                            }
                        }
                    } 
                }   
            }                               
        } 
        
        if(trig.isbefore && trig.isUpdate)
        {
            for(Lead olead : trig.newList){ 
                if(String.isNotBlank(olead.Description) && trig.oldmap.get(olead.Id).Description != olead.Description && (olead.Description.contains('NOBs') || olead.Description.contains('Interests')))  
                {                                            
                    List<String> lines = olead.Description.split('\n');
                    if(!lines.isEmpty())
                    {
                        for(String str : lines)
                        {
                            if(str.contains('NOBs'))
                            {
                                String natureofBusiness = str.remove('NOBs:');
                                if(natureofBusiness.length() > maxSize ){
                                  olead.Nature_of_Business__c =natureofBusiness.substring(0, maxSize);  
                                }
                                else
                                {
                                  olead.Nature_of_Business__c = natureofBusiness;
                                }    
                            }
                            //Bk-7068
                            if(Str.contains('Interests'))
                            {
                                String interestLevel = str.remove('Interests:');
                                if(interestLevel .length() > maxSize ){
                                  olead.Interest_L1__c = interestLevel.substring(0, maxSize);
                                }
                                else
                                {
                                olead.Interest_L1__c = interestLevel ;  
                                }
                            }
                        }
                    }                    
                }   
            }           
        }  
        /*******************************************End of Bk-5887*******************************/ 
    }
}