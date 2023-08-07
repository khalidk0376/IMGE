/**
* Project:     Informa Markets
* Date:        Dec, 6 2019
* Created By:  Avinash Shukla
* Test Class:  Opp_Handler_Quote_Test(95%)
* *************************************************************************
* @description This is Handler for Opportunity Trigger. It is used mainly for updating related quote object on opportunity.
* HISTORY 3/4/2020: //Modified by Avinash Shukla Changes added from BarterOpportunityHandler_Trig merging into consolidated to Avoid issue related to BK-3826/ BK-3825 START.
* *************************************************************************
*/
public without sharing class Opp_Handler_Quote {
    /**
     * @description Perform all Operations on Quote Object from this method.
     * @param oppNewList New Opportunity List
     * @param oppOldList Old Opportunity List
     * @param oppNewMap  New Opportunity Map
     * @param oppOldMap  Old Opportunity Map
     * @param isAfter    Trigger Event
     * @param isBefore   Trigger Event
     * @param isInsert   Trigger Event
     * @param isUpdate   Trigger Event
     */
    public static void quoteAutomation(List<opportunity> oppNewList, List<opportunity> oppOldList, Map<Id, Opportunity> oppNewMap, Map<Id, Opportunity> oppOldMap, Boolean isAfter, Boolean isBefore, Boolean isInsert, Boolean isUpdate) {
        //@Description Variable Declaration
        //BK-3713 : Changes added from BarterOpportunityHandler_Trig merging into consolidated to Avoid issue related to BK-3826/ BK-3825 START.
        Set<String> StageSet = new Set<String>();
        StageSet.add('Closed Won');
        StageSet.add('Closed Lost');
        StageSet.add('Closed Booked');
        set<Id> oppid = new Set<id>();
        //BK-3713 : Changes added from BarterOpportunityHandler_Trig merging into consolidated to Avoid issue related to BK-3826/ BK-3825 END.

        List<SBQQ__Quote__c> quoteList = new List<SBQQ__Quote__c>();
        Set<Id> quoteLinesToDeleteForBarter = new Set<Id>();
        list<dsfs__DocuSign_Status__c> lstDocusignstsupdate = new  list<dsfs__DocuSign_Status__c>();
        Set<Id> oppToUpdateQuoteStatus = new Set<Id>();
        Map<Id, Opportunity> mapBilingConChangeOppty = new Map<Id, Opportunity>();
		Map<Id, Opportunity> mapBilingConChangeOrderInvc = new Map<Id, Opportunity>();

        //@Description Void type method that is used to update SBQQ__Quote__c status.

        if (!Utility.isAmendmentProcess && !Utility.isRebookInProcess) {
            for (Opportunity opp : oppNewList) {
                if ((opp.StageName == 'Closed Lost' && oppOldMap.get(opp.Id).StageName != 'Closed Lost' ) || (opp.StageName == 'Closed Won'  && opp.Status__c == 'Awaiting Payment' && oppOldMap.get(opp.Id).Status__c != 'Awaiting Payment') || (opp.StageName == 'Closed Won' && oppOldMap.get(opp.Id).StageName != 'Closed Won' && opp.Status__c == 'Pending Accounting Approval' && opp.Manual_Contract__c )) {
                    oppToUpdateQuoteStatus.add(opp.id);
                }
                /** Billing Contact Update Functionality */
                if (isUpdate && (opp.Billing_Contact__c != null && oppOldMap.get(opp.Id).Billing_Contact__c != opp.Billing_Contact__c) || (opp.OwnerId != null && oppOldMap.get(opp.Id).OwnerId != opp.OwnerId) || (opp.Opportunity_Contact__c != null && oppOldMap.get(opp.Id).Opportunity_Contact__c != opp.Opportunity_Contact__c)) {
                    /**Billing contact change*/
                    mapBilingConChangeOppty.put(opp.Id, opp);
                    /** Add the Opp id to update the billing contact in case is updated on the Opportunity.*/
                    oppToUpdateQuoteStatus.add(opp.id);
                }
				system.debug('@@mapBilingConChangeOppty:::::'+mapBilingConChangeOppty);
				/** Billing Contact Update Functionality on order and invoices BK-20038*/
                if (isUpdate && opp.StageName == 'Closed Won' && opp.Billing_Contact__c != null && oppOldMap.get(opp.Id).Billing_Contact__c != opp.Billing_Contact__c) 
                {
                    mapBilingConChangeOrderInvc.put(opp.Id, opp);
                }
				
                //** Barter Functionality : Delete QLIs when Is Barter is checked. */
                //Modified by Avinash Shukla Changes added from BarterOpportunityHandler_Trig merging into consolidated to Avoid issue related to BK-3826/ BK-3825 START.
                if(oppOldMap.get(opp.id).Is_Barter_Opportunity__c  != opp.Is_Barter_Opportunity__c && opp.Is_Barter_Opportunity__c &&  !String.isBlank(opp.SBQQ__PrimaryQuote__c) ){
                    quoteLinesToDeleteForBarter.add(opp.SBQQ__PrimaryQuote__c); 
                }
                /* Shiv Raghav (BK-3713)  
                Assign Quote Page Layout based on opportunity Stage and barter condition
                */               
                if(StageSet.contains(oppOldMap.get(opp.id).StageName) && !StageSet.contains(opp.StageName)) { oppid.add(opp.id);
                }
                else if(StageSet.contains(opp.StageName) && !StageSet.contains(oppOldMap.get(opp.id).StageName)){ oppid.add(opp.id);
                } 
                else if(oppOldMap.get(opp.id).Is_Barter_Opportunity__c  != opp.Is_Barter_Opportunity__c){ oppid.add(opp.id);
                } 
                //Modified by Avinash Shukla : Changes added from BarterOpportunityHandler_Trig merging into consolidated to Avoid issue related to BK-3826/ BK-3825 END.
            }
        }
				
		if(!mapBilingConChangeOrderInvc.isEmpty())		
		{
		    Map<Id, Order> mapBilingConChangeOrder = new Map<Id, Order>();
            for(Order ord : [Select id,BillToContactId,OpportunityId from Order where OpportunityId IN : mapBilingConChangeOppty.keySet() FOR UPDATE])            
            {
               ord.BillToContactId = mapBilingConChangeOrderInvc.get(ord.OpportunityId).Billing_Contact__c; 
               mapBilingConChangeOrder.put(ord.id,ord);
            }
            
            if(!mapBilingConChangeOrder.isEmpty()){
                update mapBilingConChangeOrder.values();
                List<blng__Invoice__c> lstInvoiceToProcess = new List<blng__Invoice__c>();
                for(blng__Invoice__c inv : [Select id,blng__BillToContact__c,blng__Order__c from blng__Invoice__c where blng__Order__c IN : mapBilingConChangeOrder.keySet() FOR UPDATE])            
                {
                    inv.blng__BillToContact__c = mapBilingConChangeOrder.get(inv.blng__Order__c).BillToContactId; 
                    lstInvoiceToProcess.add(inv);
                }
                
                if(!lstInvoiceToProcess.isEmpty()){
                    update lstInvoiceToProcess;
                }
            }   
		}
        if (!oppToUpdateQuoteStatus.isEmpty() || !oppid.isEmpty() || !mapBilingConChangeOppty.isEmpty()) {
            
            List<SBQQ__Quote__c> lstQuoteToProcess = new List<SBQQ__Quote__c>();
            lstQuoteToProcess = [select id, SBQQ__Status__c, SBQQ__Primary__c , SBQQ__Opportunity2__r.StageName ,SBQQ__Opportunity2__r.Name, SBQQ__Opportunity2__r.IsCreatedByReviewProcess__c, SBQQ__Opportunity2__r.Status__c, Manual__c, RecordTypeId, SBQQ__Opportunity2__r.Is_Barter_Opportunity__c, (Select Id , Name , dsfs__Envelope_Status__c from DocuSign_Status__r) from SBQQ__Quote__c where SBQQ__Opportunity2__c IN : oppToUpdateQuoteStatus OR SBQQ__Opportunity2__c IN : mapBilingConChangeOppty.keySet() OR SBQQ__Opportunity2__c IN : oppid FOR UPDATE];
            for (SBQQ__Quote__c tempQuote : lstQuoteToProcess) {
                Boolean isFieldUpdated = false;
                if (oppToUpdateQuoteStatus.contains(tempQuote.SBQQ__Opportunity2__c)) {
                    if (tempQuote.SBQQ__Opportunity2__r.StageName == 'Closed Lost' && tempQuote.SBQQ__Status__c != 'Contract Lost') {
                        tempQuote.SBQQ__Status__c = 'Contract Lost';
                        isFieldUpdated = true;
                        if (!tempQuote.DocuSign_Status__r.isEmpty()) {
                            for (dsfs__DocuSign_Status__c odocusingStatus : tempQuote.DocuSign_Status__r ) {
                                odocusingStatus.dsfs__Envelope_Status__c = 'Voided';
                                lstDocusignstsupdate.add(odocusingStatus);
                            }
                        }
                    }
                    //Update Code to GGCW-3283
                    else if (tempQuote.SBQQ__Opportunity2__r.StageName == 'Closed Won' && tempQuote.SBQQ__Opportunity2__r.Status__c == 'Awaiting Payment' && tempQuote.SBQQ__Primary__c && !tempQuote.SBQQ__Opportunity2__r.IsCreatedByReviewProcess__c && tempQuote.SBQQ__Status__c != 'Accounting Approved') {
                        tempQuote.SBQQ__Status__c = 'Accounting Approved';
                        isFieldUpdated = true;
                    }
                    //GGCW-3159 Start Manual Contract
                    else if (tempQuote.SBQQ__Opportunity2__r.StageName == 'Closed Won' && tempQuote.SBQQ__Opportunity2__r.Status__c == 'Pending Accounting Approval' && tempQuote.SBQQ__Primary__c && !tempQuote.SBQQ__Opportunity2__r.IsCreatedByReviewProcess__c && tempQuote.SBQQ__Status__c != 'Contract Approved' && tempQuote.Manual__c )  {
                        tempQuote.SBQQ__Status__c = 'Contract Approved';
                        isFieldUpdated = true;
                    }
                    //GGCW-3159 END  Manual Contract
                }
                if (mapBilingConChangeOppty.keySet().contains(tempQuote.SBQQ__Opportunity2__c)) {
                    tempQuote.Billing_Contact__c = mapBilingConChangeOppty.get( tempQuote.SBQQ__Opportunity2__c ).Billing_Contact__c ;
                    tempQuote.SBQQ__PrimaryContact__c  = mapBilingConChangeOppty.get( tempQuote.SBQQ__Opportunity2__c ).Opportunity_Contact__c;
                    tempQuote.SBQQ__SalesRep__c  = mapBilingConChangeOppty.get( tempQuote.SBQQ__Opportunity2__c ).OwnerId ;
                    isFieldUpdated = true;
                }
                //BK-3713 Added by Shiv
            
                if(StageSet.contains(tempQuote.SBQQ__Opportunity2__r.StageName)) {
                    if(tempQuote.RecordTypeId != Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByDeveloperName().get('Read_Only_Sales_Ops_Brazil').getRecordTypeId()){
                        tempQuote.RecordTypeId  =  Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByDeveloperName().get('Read_Only_Sales_Ops_Brazil').getRecordTypeId();
                        isFieldUpdated = true;
                    }
                }
                else {
                    if(tempQuote.SBQQ__Opportunity2__r.Is_Barter_Opportunity__c && tempQuote.RecordTypeId != Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByDeveloperName().get('Barter').getRecordTypeId())  {
                        tempQuote.RecordTypeId  =  Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByDeveloperName().get('Barter').getRecordTypeId();
                        isFieldUpdated = true;
                    }
                    else if(!tempQuote.SBQQ__Opportunity2__r.Is_Barter_Opportunity__c && tempQuote.RecordTypeId  !=  Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByDeveloperName().get('Is_Not_Barter').getRecordTypeId()) {
                        tempQuote.RecordTypeId  =  Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByDeveloperName().get('Is_Not_Barter').getRecordTypeId();
                        isFieldUpdated = true;
                    }                                          
                }
                //BK-3713 Added by Shiv
                //Modified by Avinash Shukla Changes added from BarterOpportunityHandler_Trig merging into consolidated to Avoid issue related to BK-3826/ BK-3825 END.
                if (isFieldUpdated) { quoteList.add( tempQuote ); }
            }
            if (!quoteList.isEmpty()) {
                Utility.byPassClosedWon = true;
                update quoteList;
            }
            /**
             * Update docusign records to voided.
             */
            if (!lstDocusignstsupdate.isEmpty()) {
                update lstDocusignstsupdate;
            }
        }
        //** Delete Quote Lines for  */
        if(!quoteLinesToDeleteForBarter.IsEmpty()) { Delete [SELECT ID , SBQQ__Quote__c FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c IN :quoteLinesToDeleteForBarter ]; }
    }	
}