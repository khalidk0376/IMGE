/**
* Project:     Informa Markets
* Date:        Dec, 4 2019
* Created By:  Avinash Shukla
* Test Class:  Opp_Handler_Opportunity_Test(88%)
* Modidied By     :   Palla Kishore for Jira ticket opportunityAutomation: BK-14867   
* *************************************************************************
* @description This is Handler for Opportunity Trigger. It is used mainly for Pre-population of Opportunity object fields.
* *************************************************************************
*/
public without sharing class Opp_Handler_Opportunity {
    /**
* @description Perform all Operations on Opportunity Object from this method.
* @param oppNewList New Opportunity List
* @param oppOldList Old Opportunity List
* @param oppNewMap  New Opportunity Map
* @param oppOldMap  Old Opportunity Map
* @param isAfter    Trigger Event
* @param isBefore   Trigger Event
* @param isInsert   Trigger Event
* @param isUpdate   Trigger Event
*/
    public static void opportunityAutomation(List<opportunity> oppNewList, List<opportunity> oppOldList, Map<Id, Opportunity> oppNewMap, Map<Id, Opportunity> oppOldMap, Boolean isAfter, Boolean isBefore, Boolean isInsert, Boolean isUpdate) {
        // Variable Declaration
        try {
            Set<String> amendmentContractNumbers = new Set<String>();
            Set<Id> oppIds = new Set<Id>();
            Set<Id> eventEditionIds = new Set<Id>();
            Map<Id, Event_Edition__c> eventEditionMap = new Map<Id, Event_Edition__c>();
            Map<String, Contract> contractNumberToContractMap;
            Map <String, Id> userType = new Map <String, Id> ( );
            Set<Id> oppIdsToCheckRelated = new Set<Id>();
            Map<Id, Boolean> cantBeClosedLost = new Map<Id, Boolean>();
            Map<Id, Integer> countrentedBooth = new Map<Id, Integer>();
            Map<Id, Opportunity> mapOpportunity;
            Map<Id, Id> mapOpptyBillingContact  = new Map<Id, Id>();
            Map<Id, Contact> mapBillingContact = new Map<Id, Contact>();
            String sStageName = System.Label.Opportunity_Stage_Name_Discover;
            Set<Id> oppContactId = new Set<Id>();
            Map<id,id> oppContactwithaccountMap = new Map<id,id>(); 
            Set<String> ISOCodes = new Set<String>();
            // Created by Palla Kishore for the ticket BK-25375
            Map<Id, String> oppOldStatusMap = new Map<Id, String>();
            Set<Id> oppStatusChangedIds = new Set<Id>();
            // Created by Palla Kishore for the ticket BK-27444
            Map<Id, String> oppByForecastOldMap = new map<Id, String>();
            set<Id> opportunityIdsSet = new Set<Id>();     
            // Variable Declaration
            //Loop runs to get all related Ids to Query and get the required data from different objects and prepopulate opportunity fields.
            for (Opportunity opp : oppNewList) {
                //Get Event Edition Ids, to prepopulate event series.
                //Condition ::: For Both isUpdate and Or isInsert but is Not from Amendment Process.
                if ((isInsert && opp.EventEdition__c != NULL && !Utility.isAmendmentProcess) || (isUpdate && opp.EventEdition__c != oppOldMap.get(opp.Id).EventEdition__c && opp.EventEdition__c != Null && !Utility.isAmendmentProcess)) {
                    eventEditionIds.add(opp.EventEdition__c);
                }
                //Amendment Opportunity
                //To run on all type of opportunity
                if (isInsert) {
                    if (opp.Name.contains('Amendment for contract #' )) {
                        String amendNumber = opp.Name.substringAfter('#');
                        if ( !String.isBlank( amendNumber ) ) {
                            amendmentContractNumbers.add( amendNumber );
                        }
                    }
                    if ( opp.Billing_Contact__c != null ) {
                        mapOpptyBillingContact.put( opp.Id, opp.Billing_Contact__c );
                    }
                    if (!Utility.isAmendmentProcess && opp.EventEdition__c != Null && (opp.SBQQ__QuotePricebookId__c == Null || opp.PriceBook2Id  == Null)) {
                        eventEditionIds.add(opp.EventEdition__c);
                    }
                    //Bk-3771 - Shiv Raghav (8/4/2020)     
                    if(opp.Opportunity_Contact__c != null && opp.Operations_Contact__c == null)
                    {
                        oppContactId.add(opp.Opportunity_Contact__c);
                    }
                    
                }
                /**
* @description Method checks for the opportunity being cancelled. if the cancelled opp has any related records then there is an error for the same.
* Related to ticket BK-1217
* To run on all type of Opportunity Update.
*/
                if (isUpdate) {
                    //Modified by Avinash Shukla : BK-1217 : 08/07/2019
                    if (oppOldMap.containsKey(opp.Id)) {
                        if (opp.stageName == 'Closed Lost' && oppOldMap.get(opp.id).StageName != opp.stageName)    {
                            oppIdsToCheckRelated.add(opp.id);
                        }
                    }
                    if (isFieldUpdated(opp, 'Billing_Contact__c', oppOldMap)) {
                        mapOpptyBillingContact.put(opp.Id, opp.Billing_Contact__c);
                    }
                    if (oppOldMap.get( opp.id ).Event_Edition_Currency__c != opp.Event_Edition_Currency__c ) { eventEditionIds.add(opp.EventEdition__c);
                                                                                                             }
                    if (oppOldMap.get( opp.id ).Payment_Schedules__c != opp.Payment_Schedules__c )  {
                        eventEditionIds.add(opp.EventEdition__c);
                    }
                    if (oppOldMap.get( opp.id ).Payment_Schedule_2__c != opp.Payment_Schedule_2__c ) {
                        eventEditionIds.add(opp.EventEdition__c);
                    }
                    if (oppOldMap.get( opp.id ).Custom_Payment__c != opp.Custom_Payment__c) {
                        eventEditionIds.add(opp.EventEdition__c);
                    }
                    if (opp.EventEdition__c != Null && (opp.SBQQ__QuotePricebookId__c == Null || opp.PriceBook2Id  == Null)) {
                        eventEditionIds.add(opp.EventEdition__c);
                    }
                    //LM-12
                    if(opp.StageName == 'Closed Won' && oppOldMap.get( opp.id ).StageName != opp.StageName && opp.Amount != null)
                    {
                        if(opp.ISO_Code__c != 'USD')
                        {
                            ISOCodes.add(opp.ISO_Code__c);
                        }                        
                    }
                    if (!opp.Do_not_activate_Billing__c && oppOldMap.get(opp.Id).Do_not_activate_Billing__c != opp.Do_not_activate_Billing__c) {
                        oppStatusChangedIds.add(opp.Id);
                    }
                    // Added by Palla Kishore for the ticket BK-27444
                    opportunityIdsSet.add(opp.Id);
                    
                }
                //Modified by Avinash Shukla : BK-1217 : 08/07/2019
                if (!oppStatusChangedIds.isEmpty()) {
                    oppOldStatusMap = fetchOppHistoryForStatus(oppStatusChangedIds);
                }
               // Added by Palla Kishore for the ticket BK-27444
                if (!opportunityIdsSet.isEmpty()) {
                    oppByForecastOldMap = fetchOppHistoryForForecast(opportunityIdsSet);
                }  
          }
            /**
*
Modified By    Shiv Raghav
Ticket No      BK - 1823
@description   When a user attempts to cancel an opportunity where the number of booths rented against the opportunity are over 50,
a pop-up will appear saying, "Opportunity cannot be cancelled at this time. To cancel, please decrease the number of rented booths to 50 or less."
and the Opportunity will not be able to be cancelled until the number of rented booths is 50 or under
*/
            //Bk-14867 - Palla Kishore (8/24/2021) 
            //for (AggregateResult aggRes : [ SELECT COUNT(ID) boothcount , Opportunity__c oppId FROM ExpocadBooth__c where status__c = 'Rented' and opportunity__c IN : oppIdsToCheckRelated GROUP BY opportunity__c]) {
            list<AggregateResult> aResultList = new list<AggregateResult>();
            aResultList = [ SELECT COUNT(ID) boothcount , Opportunity__c oppId FROM ExpocadBooth__c where status__c = 'Rented' and opportunity__c IN : oppIdsToCheckRelated GROUP BY opportunity__c];    
            for (AggregateResult aggRes : aResultList) {     
                Id oppId = (Id) aggRes.get('oppId');
                Integer countbooth = (Integer) aggRes.get('boothcount');
                if (countbooth > 50) { countrentedBooth.put(oppId , countbooth);
                                     }
            }
            
            if (!oppIdsToCheckRelated.isEmpty()) {
                List<Opportunity> oppListToCheckRelated = new List<Opportunity>();
                oppListToCheckRelated = [Select Id, Name , (Select id, Name , stageName from Opportunities__r WHERE StageName != 'Closed Lost') FROM Opportunity WHERE ID IN : oppIdsToCheckRelated];
                For(Opportunity oppToProcess : oppListToCheckRelated) {
                    if (!oppToProcess.Opportunities__r.isEmpty()) {
                        cantBeClosedLost.put(oppToProcess.Id, true);
                    }
                }
            }
            //Get Opportunity User Type data
            //Bk-14867 - Palla Kishore (8/24/2021)
            //for ( User_Type__c uType : [ SELECT Id, Name FROM User_Type__c ]) {
            list<User_Type__c> uTypeList = new list<User_Type__c>();
            uTypeList = [ SELECT Id, Name FROM User_Type__c ];
            for ( User_Type__c uType : uTypeList){
                userType.put( uType.Name, uType.Id );
            }
            // Get Map of Event Edition to Event Series
            if (!eventEditionIds.isEmpty()) {
                eventEditionMap = new Map<Id, Event_Edition__c>([Select Id, Event_Price_Book__c, EventCurrency__r.Name, EventCurrency__c, Part_of_Series__c from Event_Edition__c WHERE Id IN : eventEditionIds]);
            }
            // Get Map of Contract Numbers to Contract.
            if (!amendmentContractNumbers.isEmpty()) {
                contractNumberToContractMap = new Map<String, Contract>();
                Map<Id, Contract> contractMap = new Map<Id, Contract>([SELECT ContractNumber, SBQQ__Opportunity__r.Event_Series__c, SBQQ__Opportunity__r.EventEdition__c FROM Contract WHERE ContractNumber IN :amendmentContractNumbers AND SBQQ__Opportunity__c != Null AND SBQQ__Opportunity__r.EventEdition__c != Null LIMIT 10000]);
                for (Contract cont : contractMap.values()) { contractNumberToContractMap.put(cont.ContractNumber, cont);
                                                           }
            }
            
            if (!mapOpptyBillingContact.isEmpty()) {
                mapBillingContact = new Map<Id, Contact>([SELECT ID, AccountID FROM Contact WHERE Id IN: mapOpptyBillingContact.values() AND AccountID != NULL ]);
            }
            
            
            if(!oppContactId.isEmpty())
            {     
                //Bk-14867 - Palla Kishore (8/24/2021)
                //for(Contact con : [Select id, accountid from contact where id in : oppContactId])
                list<Contact> lsCon = new list<Contact>();
                lsCon = [Select id, accountid from contact where id in : oppContactId];     
                for(Contact con : lsCon) 
                {
                    oppContactwithaccountMap.put(con.id , con.AccountId); 
                }
            }
            //LM-12
            Map<String,decimal> currTypeMap = new Map<string,decimal>( );
            if(ISOCodes.Size()>0)
            {
                //Bk-14867 - Palla Kishore (8/24/2021)
                //for( Currency_Master__c curr : [ Select ExchangeRate__c,ForeignCurrency__c,LocalCurrency__c From Currency_Master__c Where LocalCurrency__c in : ISOCodes AND  ForeignCurrency__c = 'USD' Order By ExchangeRateDate__c]) {
                list<Currency_Master__c> cmasterlist = new list<Currency_Master__c>();
                cmasterlist = [ Select ExchangeRate__c,ForeignCurrency__c,LocalCurrency__c From Currency_Master__c Where LocalCurrency__c in : ISOCodes AND  ForeignCurrency__c = 'USD' Order By ExchangeRateDate__c];
                for(Currency_Master__c curr : cmasterlist){ 
                    currTypeMap.put(curr.LocalCurrency__c,curr.ExchangeRate__c );
                }
            }
            
            //Pre-population of Opportunity Fields.
            for (Opportunity opp : oppNewList) {
                if (isInsert || isUpdate) {
                    if (opp.Billing_Contact__c != null) {
                        if ( mapOpptyBillingContact.containsKey( opp.id ) && opp.AccountId != mapBillingContact.get( opp.Billing_Contact__c ).AccountID ) {
                            opp.Partner_Account__c = mapBillingContact.get( opp.Billing_Contact__c ).AccountID;
                        }
                    }
                    //Get Event Edition Ids, to pre-populate event series.
                    if ((isInsert && opp.EventEdition__c != NULL && !Utility.isAmendmentProcess) ||
                        (isUpdate && opp.EventEdition__c != oppOldMap.get(opp.Id).EventEdition__c &&
                         opp.EventEdition__c != Null && !Utility.isAmendmentProcess)) {
                             if (!eventEditionMap.isEmpty() && eventEditionMap.containsKey(opp.EventEdition__c)) {
                                 opp.Event_Series__c = eventEditionMap.get(opp.EventEdition__c).Part_of_Series__c;
                             }
                         }
                    //Amendment Event Series and Event Edition population.
                    if ( opp.Name.contains('Amendment for contract #') && isInsert ) {
                        String contractNumber = opp.Name.substringAfter('#');
                        if ( !String.isBlank(contractNumber) && contractNumberToContractMap.containsKey(contractNumber) ) {
                            opp.Event_Series__c = contractNumberToContractMap.get(contractNumber).SBQQ__Opportunity__r.Event_Series__c != NULL ? contractNumberToContractMap.get(contractNumber).SBQQ__Opportunity__r.Event_Series__c : '';
                            opp.EventEdition__c = contractNumberToContractMap.get(contractNumber).SBQQ__Opportunity__r.EventEdition__c != NULL ? contractNumberToContractMap.get(contractNumber).SBQQ__Opportunity__r.EventEdition__c : '';
                        }
                    }
                    // User Type Pre-population.
                    ExhibitorForUserType__c exhibitorUserType;
                    if ( opp.Exhibitor_Paid_By__c == NULL ) {
                        exhibitorUserType = ExhibitorForUserType__c.getValues( 'NULL' );
                    } else if ( opp.Exhibitor_Paid_By__c != NULL ) {
                        exhibitorUserType = ExhibitorForUserType__c.getValues( opp.Exhibitor_Paid_By__c );
                    }
                    if ( exhibitorUserType != NULL ) {
                        if ( opp.Parent_Opportunity__c == NULL ) {
                            opp.User_Type__c = userType.get( exhibitorUserType.UserType_for_Parent_Opptunity__c );
                        } else if ( opp.Parent_Opportunity__c != NULL ) {
                            opp.User_Type__c = userType.get( exhibitorUserType.UserType_for_Related_Opptunity__c );
                        }
                    }
                    //Modified by Avinash Shukla : BK-1217 : 08/07/2019 START
                    if (isUpdate) {
                        if (oppOldMap.containsKey(opp.Id)) {
                            if (opp.stageName == 'Closed Lost' && oppOldMap.get(opp.id).StageName != opp.stageName)    {
                                if (cantBeClosedLost.containsKey(opp.Id)) {
                                    if (!test.isRunningTest()) { opp.addError('Cannot cancel opportunity. Please close lost all related opportunities and try again.');
                                                               }
                                }
                                /*
Modified By : Shiv Raghav
Ticket No : BK - 1823
*/
                                else if (countrentedBooth.containskey(opp.id)) { opp.addError('Opportunity cannot be cancelled at this time. To cancel, please decrease the number of rented booths to 50 or less');
                                                                               }
                            }
                        }
                        //Modified by shiv LM-12
                        if(opp.Amount != Null && opp.StageName == 'Closed Won')
                        {
                            if(opp.ISO_Code__c == 'USD')
                            {
                                opp.Revenue__c = opp.Amount; 
                            }
                            else if(currTypeMap.Size() > 0)
                            {
                                Decimal cRate = currTypeMap.get(opp.ISO_Code__c);
                                if( cRate != null ) 
                                {                          
                                    opp.Revenue__c = opp.Amount*cRate; 
                                }
                            }
                            
                        }
                        
                        /**
* Working on stagename field condition.
*/
                        if(opp.Do_not_activate_Billing__c) 
						{
                            // Modified by Palla Kishore for the ticket BK-26535
                            opp.Status__c = 'Do Not Bill Status';
                        }
                        else if ( opp.StageName == 'Discover') 
                        { 
                            opp.Status__c = 'Discover';
                        }
                        else if ( opp.StageName == 'Proposal Sent' && (oppOldMap.get( opp.id ).status__c != opp.Status__c ||  oppOldMap.get(opp.id).Do_not_activate_Billing__c != opp.Do_not_activate_Billing__c) && oppOldMap.get(opp.id).status__c != 'Proposal Sent' ) 
                        { 
                            opp.Status__c = 'Proposal Sent';
                        }
                        else if (opp.StageName == 'Customize' &&  oppOldStatusMap.containsKey(Opp.Id) && (oppOldStatusMap.get(opp.Id) == 'Accounting Rejected' || oppOldStatusMap.get(opp.Id) == 'Recalled' || oppOldStatusMap.get(opp.Id) == 'Rejected by Sales Ops Team'))  
                        {
                            opp.Status__c = oppOldStatusMap.get(opp.Id);
                        }
                        else if (opp.StageName == 'Customize' &&  opp.Status__c != 'Accounting Rejected' && opp.Status__c != 'Recalled' && opp.Status__c != 'Rejected by Sales Ops Team')  
                        {
                            opp.Status__c = 'Customize';
                        }
                        // Added by Palla Kishore for the ticket BK-27444
                       else if (opp.StageName == 'Customize'  && oppOldMap.get( opp.id ).StageName != opp.StageName && (oppOldMap.get( opp.id ).Status__c != opp.Status__c &&  (opp.Status__c == 'Accounting Rejected' || opp.Status__c == 'Recalled' || opp.Status__c == 'Rejected by Sales Ops Team')))
                        {
                            opp.Forecast_Category__c = oppByForecastOldMap.get(opp.Id) != Null?oppByForecastOldMap.get(opp.Id):'N/A';
                        }
                        else if ( opp.StageName == 'Proposal Approved' ) { 
                            opp.Status__c = 'None';
                        } 
                        else if ( opp.StageName == 'Contract Sent' ) {
                            // Modified by Danish for the ticket BK-28200 
                            opp.Status__c = 'Contract Sent';
                        } 
                        else if ( opp.StageName == 'Closed Won') {
                            opp.Forecast_Category__c = 'Closed Won';
                            if(opp.Do_not_activate_Billing__c != oppOldMap.get(opp.id).Do_not_activate_Billing__c && !opp.Do_not_activate_Billing__c){
                                if(oppOldStatusMap.get(opp.Id) == 'Sales Ops Review - Pending' || oppOldStatusMap.get(opp.Id) == 'Pending Accounting Approval'){
                                    opp.Status__c =  oppOldStatusMap.get(opp.Id);
                                }else{
                                    if(opp.Review_by_Sales_Ops_Team__c){
                                        opp.Status__c = 'Sales Ops Review - Pending';
                                    }else{
                                        opp.status__c = 'Pending Accounting Approval'; 
                                    }
                                }
                            }
                            if (opp.Payment_Status__c != 'Partial Paid' && opp.Payment_Status__c != 'Paid' && !opp.IsCreatedByReviewProcess__c && !opp.isThroughDcousign__c && !opp.isThroughCompleteAmendProcess__c && !opp.Manual_Contract__c && opp.Amount != 0 )
                            {
                                if (oppOldMap.get(opp.id).status__c != 'Pending Accounting Approval' && oppOldMap.get(opp.id).status__c != 'Pending Change' && oppOldMap.get(opp.id).status__c != 'Legacy Won' && (oppOldMap.get(opp.id).status__c != opp.Status__c || oppOldMap.get(opp.id).Do_not_activate_Billing__c != opp.Do_not_activate_Billing__c) ) {
                                    if(opp.Review_by_Sales_Ops_Team__c)
                                    {
                                      opp.Status__c = 'Sales Ops Review - Pending';
                                    }
                                    else
                                    {
                                       opp.Status__c = 'Pending Accounting Approval';  
                                    }
                                                                                                                                                                                                                                            
                                }
                                /**
* Modified Date 13 Aug 2019 (BK - 2030)
* Modified By Shiv Raghav ::: A new field on the opportunity needs to be created that stamps the exact Date & Time of an opportunity
*                             when the stage goes from Contract Sent to Closed Won.
*/
                            }
                            if (oppOldMap.get(opp.Id).StageName == 'Contract Sent' && opp.Submission_Date__c == Null) { opp.Submission_Date__c = System.now();
                                                                                                                      }
                        } else if ( opp.StageName == 'Closed Booked' && opp.IsCreatedByReviewProcess__c == false ) 
						{ 
							opp.Status__c = 'None';
                        }
                        /**
* Working on reason lost field condition.
*/
                        if (oppOldMap.get( opp.id ).Reason_Lost__c != 'AR Cancel / Re-bill' && opp.Reason_Lost__c  == 'AR Cancel / Re-bill' ) {
                            opp.Status__c = 'AR Cancel / Re-bill';
                        } else if (oppOldMap.get( opp.id ).Reason_Lost__c != 'Booth/Sponsorship Cancellation' && opp.Reason_Lost__c  == 'Booth/Sponsorship Cancellation') { opp.Status__c = 'Opportunity Cancelled';
                                                                                                                                                                          } else if (oppOldMap.get( opp.id ).Reason_Lost__c != 'Digital / Print Cancellation' && opp.Reason_Lost__c == 'Digital / Print Cancellation' ) { opp.Status__c = 'Opportunity Cancelled';
                                                                                                                                                                                                                                                                                                                        }
                        if (oppOldMap.get( opp.id ).Revenue_Estimate__c != opp.Revenue_Estimate__c && opp.Revenue_Estimate__c != null)  { opp.Amount = opp.Revenue_Estimate__c;
                                                                                                                                        }
                        /*****Start Of GRQ0283883**********/
                        /*   Updated By :- Shiv Raghav
@Description :- I am putting below code in before update instead of after update. if we update CurrencyIsoCode and pricebook both during after update
then due to CurrencyIsoCode update it remove pricebook from opportunity(Steel Brick Feature) so both operation can't perform in after update.
*/
                        if (opp.Alternate_Currency__c != oppOldMap.get(opp.Id).Alternate_Currency__c && opp.Alternate_Currency__c != null && opp.SBQQ__PrimaryQuote__c == null) { opp.CurrencyIsoCode = opp.Alternate_Currency__c;
                                                                                                                                                                                }
                        /***** End Of GRQ0283883 **********/
                        /**
* Modified Date 2nd April 2019
* Modified By Yash Gupta [ Covert Workflow functionality i.e "Is Barter Opportunity" ]
*/
                        if (opp.Is_Barter_Opportunity__c != oppOldMap.get(opp.Id).Is_Barter_Opportunity__c && opp.Is_Barter_Opportunity__c && !oppOldMap.get(opp.Id).Name.contains('BARTER-')) {
                            opp.Name = 'BARTER-' + opp.Name;
                        }
                        /*************GRQ0283883************/
                        /*Updated By : Shiv Raghav
@Description : Update Pricebook On opportunity if Event Edition Currency get change or if eventedition get changed.*/
                        /***** End Of GRQ0283883 **********/
                        if (opp.EventEdition__c != Null && !eventEditionMap.isEmpty() && eventEditionMap.containsKey(opp.EventEdition__c) && eventEditionMap.get(opp.EventEdition__c).Event_Price_Book__c != Null ) {
                            if (opp.SBQQ__QuotePricebookId__c == Null || opp.SBQQ__QuotePricebookId__c != eventEditionMap.get(opp.EventEdition__c).Event_Price_Book__c) {
                                //GGCW-2394
                                /* Updated By : Shiv Raghav On 26th Aug 2019 [T - BK-2279] */
                                opp.SBQQ__QuotePricebookId__c = eventEditionMap.get(opp.EventEdition__c).Event_Price_Book__c;
                            }
                            if (opp.priceBook2Id == NULL || opp.priceBook2Id != eventEditionMap.get(opp.EventEdition__c).Event_Price_Book__c) { opp.priceBook2Id = eventEditionMap.get(opp.EventEdition__c).Event_Price_Book__c;
                                                                                                                                              }
                        }
                        if ((oppOldMap.get(opp.id ).Payment_Schedules__c != opp.Payment_Schedules__c) && opp.Payment_Schedules__c) {
                            opp.Payment_Schedule_2__c = false;
                            opp.Custom_Payment__c = false;
                        } else if ((oppOldMap.get( opp.id ).Payment_Schedule_2__c != opp.Payment_Schedule_2__c ) && opp.Payment_Schedule_2__c ) {
                            opp.Payment_Schedules__c = false;
                            opp.Custom_Payment__c = false;
                        } else if ((oppOldMap.get( opp.id ).Custom_Payment__c != opp.Custom_Payment__c) && opp.Custom_Payment__c) {
                            opp.Payment_Schedules__c = false;
                            opp.Payment_Schedule_2__c = false;
                        }
                        
                        
                    }
                    //Modified by Avinash Shukla : BK-1217 : 08/07/2019 END
                    //ValidateTeam teamValidate method merging into one place.
                    if (isInsert) {
                        if (!opp.IsCreatedByReviewProcess__c) {
                            opp.StageName = sStageName;
                            opp.Status__c = sStageName;
                            //Bk-3771 - Shiv Raghav (8/4/2020)  
                            //BK-16140 - Shiv SCA Violation remove.                         
                            if (opp.Operations_Contact__c == null && opp.Opportunity_Contact__c != null) {
                                
                                if(oppContactwithaccountMap.get(opp.Opportunity_Contact__c) == opp.AccountId)
                                {    
                                    opp.Operations_Contact__c = opp.Opportunity_Contact__c;
                                }
                            }
                            //End of Bk-3771 - Shiv Raghav (8/4/2020)
                            opp.Amount = opp.Revenue_Estimate__c ;
                            if (opp.Event_Edition_Currency__c != null) { opp.CurrencyIsoCode = opp.Alternate_Currency__c;
                                                                       }
                            /**
* Modified Date 2nd April 2019
* Modified By Yash Gupta [ Covert Workflow functionality i.e "Is Barter Opportunity" ]
*/
                            if (opp.Is_Barter_Opportunity__c && !opp.Name.contains('BARTER-')) { opp.Name = 'BARTER-' + opp.Name;
                                                                                               }
                        }
                        if (!eventEditionMap.isEmpty() && eventEditionMap.containsKey(opp.EventEdition__c) && eventEditionMap.get(opp.EventEdition__c).Event_Price_Book__c != Null) {
                            opp.Event_Series__c = eventEditionMap.get(opp.EventEdition__c).Part_of_Series__c;
                            if ((opp.SBQQ__QuotePricebookId__c == Null || opp.SBQQ__QuotePricebookId__c != eventEditionMap.get(opp.EventEdition__c).Event_Price_Book__c)) { opp.SBQQ__QuotePricebookId__c = eventEditionMap.get(opp.EventEdition__c).Event_Price_Book__c; }
                            if (opp.priceBook2Id == NULL || opp.priceBook2Id != eventEditionMap.get(opp.EventEdition__c).Event_Price_Book__c) {
                                opp.priceBook2Id = eventEditionMap.get(opp.EventEdition__c).Event_Price_Book__c;
                            }
                        }
                        if(opp.Do_not_activate_Billing__c) 
						{
                            // Modified by Palla Kishore for the ticket BK-26535
                            opp.Status__c = 'Do Not Bill Status';
                        }
                        // Added by Palla Kishore for the ticket BK-27444
                        if(opp.Forecast_Category__c == Null){
                            opp.Forecast_Category__c = 'N/A';
                        }
                    }
                }
            }
            
            
        } catch (Exception exe) { Utility.logError(exe.getMessage(), exe.getCause(), exe.getLineNumber(), exe.getStackTraceString(), 'Opp_Handler_Opportunity Class for before Update/Insert functionality on Opportunity'); }
    }
    /**
* @description Perform all Operations on Related Opportunity Object from this method.
* @param oppNewList New Opportunity List
* @param oppOldList Old Opportunity List
* @param oppNewMap  New Opportunity Map
* @param oppOldMap  Old Opportunity Map
* @param isAfter    Trigger Event
* @param isBefore   Trigger Event
* @param isInsert   Trigger Event
* @param isUpdate   Trigger Event
*/
    public static void relatedOpportunityAutomation(List<opportunity> oppNewList, List<opportunity> oppOldList, Map<Id, Opportunity> oppNewMap, Map<Id, Opportunity> oppOldMap, Boolean isAfter, Boolean isBefore, Boolean isInsert, Boolean isUpdate) {
        if (!Utility.isAmendmentProcess) {
            /**
* Variable deaclaration start
*/
            List<Opportunity> lstAmendOppty;
            Map<Id, Opportunity> mapOpportunity = new Map<Id, Opportunity>();
            Map<Id, Opportunity> mapMasterOppty = new Map<Id, Opportunity>();
            /**
* Variable deaclaration end
*/
            
            for ( opportunity opp : oppNewList ) {
                Opportunity oldOpp = oppOldMap.get( opp.Id );
                if ( opp.StageName != oldOpp.StageName && opp.StageName == 'Closed Won' && opp.Event_Edition_Booth_Rent_Stage__c == 'On Contract' ) { mapOpportunity.put(opp.id, opp);
                                                                                                                                                    } else if (opp.Event_Edition_Booth_Rent_Stage__c == 'On Payment' &&
                                                                                                                                                               (opp.StageName != oldOpp.StageName || opp.Payment_Status__c != oldOpp.Payment_Status__c) &&
                                                                                                                                                               (opp.StageName == 'Closed Won' || opp.StageName == 'Closed Booked') &&
                                                                                                                                                               (oldOpp.Payment_Status__c != 'Partial Paid' || oldOpp.Payment_Status__c != 'Paid') &&
                                                                                                                                                               (opp.Payment_Status__c == 'Partial Paid' || opp.Payment_Status__c == 'Paid')) { mapOpportunity.put(opp.id, opp);
                                                                                                                                                                                                                                             }
                if (opp.Master_Opportunity__c == null && oldOpp.Cancel_Reason__c != opp.Cancel_Reason__c) {
                    mapMasterOppty.put(opp.id, opp);
                }
            }
            
            if ( !mapMasterOppty.isEmpty( ) ) {
                lstAmendOppty = new List<Opportunity>();
                //Bk-14867 - Palla Kishore (8/24/2021)
                //for ( Opportunity otemp : [ SELECT Id, Master_Opportunity__r.id, Cancel_Reason__c, Reason_Lost__c FROM Opportunity WHERE Master_Opportunity__r.id IN:mapMasterOppty.keySet( ) ] ) {
                list<Opportunity> oppList = new list<Opportunity>();
                oppList = [ SELECT Id, Master_Opportunity__r.id, Cancel_Reason__c, Reason_Lost__c FROM Opportunity WHERE Master_Opportunity__r.id IN:mapMasterOppty.keySet( ) ];
                for (Opportunity otemp : oppList){  
                    otemp.Cancel_Reason__c = mapMasterOppty.get(otemp.Master_Opportunity__r.id).Cancel_Reason__c;
                    otemp.Reason_Lost__c = mapMasterOppty.get(otemp.Master_Opportunity__r.id).Reason_Lost__c;
                    lstAmendOppty.add(otemp);
                }
                if ( !lstAmendOppty.isEmpty() ) { update lstAmendOppty; }
                for ( Id opptyId : mapMasterOppty.keySet( ) ) {
                    //Send Cancel Opportunity Mail//
                    cls_cancelOpportunity cls = new cls_cancelOpportunity();
                    cls.redirectPopup(opptyId);
                }
            }
            
            /**
Now performing all operations on the work order, work Order line items and other email services to be invoked via another handler realted to workorder.
This also includes th
*/
            Opp_Handler_WorkOrder.workOrderAutomation(oppNewList, oppOldList, oppNewMap, oppOldMap, isAfter, isBefore, isInsert, isUpdate, mapOpportunity);
            Opp_Handler_WorkOrder.workOrderAutomationAfterCL(oppNewList, oppOldMap);
        }
    }
    /**
* @description Check if the field is updated
* @param  opp       Opportunity Instance
* @param  fieldApi  Field Api Name
* @param  oldOppMap Old Opportunity Map
* @return           None
*/
    private static Boolean isFieldUpdated(Opportunity opp, String fieldApi, Map<ID, Opportunity> oldOppMap) {
        Boolean retVal = false;
        if (opp.get(fieldApi) != oldOppMap.get(opp.Id).get(fieldApi)) {
            retVal = true;
        }
        return retVal;
    }
    // Added by Palla Kishore for the ticket BK-20202.
    public static void updateCloseDate(List<opportunity> oppNewList, List<opportunity> oppOldList, Map<Id, Opportunity> oppNewMap, Map<Id, Opportunity> oppOldMap, Boolean isAfter, Boolean isBefore, Boolean isInsert, Boolean isUpdate){
        for(opportunity opp :oppNewList){            
            if(opp.StageName != oppOldMap.get(opp.Id).StageName && ('Closed Won'.equals(opp.StageName) || 'Closed Lost'.equals(opp.StageName))){
                opp.CloseDate = system.today();
            }
        }
    } 
    /* Added by Danish for the ticket BK-22946 */
    public static void ChangedStatusfield(List<opportunity> oppNewList, List<opportunity> oppOldList,Map<Id, Opportunity> oppNewMap, Map<Id, Opportunity> oppOldMap){
        for(opportunity op:oppNewList) {
            if(op.Status__c !=oppOldMap.get(op.Id).Status__c && op.Status__c=='Pending Accounting Approval'){
              op.Pending_Accounting_Approval_Since_Date__c= system.today();
            }
            else if (op.Status__c !=oppOldMap.get(op.Id).Status__c && oppOldMap.get(op.Id).Status__c=='Pending Accounting Approval' && op.Status__c!='Pending Accounting Approval'){
              op.Pending_Accounting_Approval_Since_Date__c=null;  
            }
            
        }
    }

 // Created by Palla Kishore for the ticket BK-25375
    public static Map<Id, String> fetchOppHistoryForStatus(Set<Id> oppIds) {
        Map<Id, String> oppStatusOldMap = new Map<Id, String>();
        for(OpportunityFieldHistory  history : [SELECT Id, OpportunityId, Field, DataType, OldValue, NewValue,createddate FROM OpportunityFieldHistory where OpportunityId IN: oppIds and Field = 'Status__c' ORDER BY CreatedDate DESC]) {
            if (!oppStatusOldMap.containsKey(history.OpportunityId)) {
                oppStatusOldMap.put(history.OpportunityId, (String)history.oldValue);
            }
        }
        return oppStatusOldMap;
    }
    
    // Created by Palla Kishore for the ticket BK-27444
    public static Map<Id, String> fetchOppHistoryForForecast(Set<Id> oppIds) {
        Map<Id, String> oppForecastOldMap = new Map<Id, String>();
        for(OpportunityFieldHistory  history : [SELECT Id, OpportunityId, Field, DataType, OldValue, NewValue,createddate FROM OpportunityFieldHistory where OpportunityId IN: oppIds and Field = 'Forecast_Category__c' ORDER BY CreatedDate DESC]) {
            if (!oppForecastOldMap.containsKey(history.OpportunityId)) {
                oppForecastOldMap.put(history.OpportunityId, (String)history.oldValue);
            }
        }
        return oppForecastOldMap;
    } 
}