/**
 * File:        DocuSignAutomateProcessCtrl.apxt
 * Project:     GAP
 * Date:        24/12/2018
 * Created By: Rajesh Kumar
 * Test Class : UpdateQuoteOpportunityByDocusign_Test
 * *************************************************************************
 * @description When Quote document Sign status is completed then related Quote field primary is update.
 * *************************************************************************
 * History:Modified By Rajesh Kumar Yadav -  GGCW-2760  - 26/12/2018
 * Modified By : RaJesh Kumar 21/01/2019 on GGCW-2927, Rajesh Kumar [GGCW-2760]
 * Modified by Rajesh Kumar On 19/02/2019 to GGCW-2432
 * Modified By Rajesh Kumar on 27/03/2019 to GGCW-3159
 * Modified by Rajesh Kumar On 01-04-2020 to BK-3636
 */
//Handler Class called from UpdatePrimaryOnQuote
public  without sharing class DocuSignAutomateProcessCtrl {
    List<SBQQ__QuoteDocument__c> newListDocument             { get; set; }
    Map<Id, SBQQ__QuoteDocument__c> oldListDocument          { get; set; }
    Boolean isInsert                                         { get; set; }
    Boolean isupdate                                         { get; set; }
    Boolean isAfter                                          { get; set; }
    Map<Id, Opportunity> mapOpportunity;
    /**
     * [DocuSignAutomateProcessCtrl constuctor]
     * @param  sBQQQuoteDocuList   [List of Quote Document record list]
     * @param  mapOldQuoteDocument [List of Quote Document record list]
     * @param  isInsert            [Insert]
     * @param  isupdate            [Update]
     * @param  isAfter             [after ]
     * @return                     [Null]
     */
    public DocuSignAutomateProcessCtrl( List<SBQQ__QuoteDocument__c> sBQQQuoteDocuList , map<Id, SBQQ__QuoteDocument__c> mapOldQuoteDocument,Boolean isInsert, Boolean isupdate, Boolean isAfter ) {
        this.newListDocument    = sBQQQuoteDocuList; 
        this.oldListDocument    = mapOldQuoteDocument;
        this.isInsert     = isInsert;
        this.isupdate     = isupdate;
        this.isAfter      = isAfter;  
    }
    /**
     * [onAfterInsertUpdate onAfterInsertUpdate]
     */
    public void onAfterInsertUpdate() {
        set<Id> sId = new set<Id>();
        if(newListDocument != null && newListDocument.size() > 0){
            for(SBQQ__QuoteDocument__c ooSBQQQuoteDocument:newListDocument){
                if (ooSBQQQuoteDocument.Online_Opportunity__c != null && ooSBQQQuoteDocument.Online_Opportunity_Stage_Name__c != 'Closed Won'){
                    sId.add(ooSBQQQuoteDocument.Online_Opportunity__c);
                    sId.add(ooSBQQQuoteDocument.Online_Opportunity_Quote__c);
                }
                sId.add(ooSBQQQuoteDocument.SBQQ__Quote__c);
                sId.add(ooSBQQQuoteDocument.SBQQ__Opportunity__c);
            }
            if (sId.size() > 0){
                
                Map<Id, SBQQ__Quote__c> mapQuote = new Map<Id, SBQQ__Quote__c>([SELECT Id , Name , SBQQ__Status__c , SBQQ__Primary__c , Manual__c, SBQQ__Opportunity2__c FROM SBQQ__Quote__c where  Id IN : sId]);
                //Below Code For the Ticket GGCW-2017
                mapOpportunity = new Map<Id, Opportunity>([SELECT Id , Name , StageName , isThroughDcousign__c , Contract_Sign_Status__c , Manual_Contract__c , Status__c FROM Opportunity where Id IN : sId]);
                for(SBQQ__QuoteDocument__c oSBQQQuoteDocument : newListDocument){
                    //I have merge apex class : quoteDocUtilityCls in this class.
                    //Start Manual contract Functinality - GGCW-3159
                    if( isAfter && isInsert) {
                        if(oSBQQQuoteDocument.SBQQ__ElectronicSignature__c == false && oSBQQQuoteDocument.Conga__c == false && oSBQQQuoteDocument.IsNotGeneralDocument__c == true){
                            if (mapQuote.size() > 0){ 
                                for (SBQQ__Quote__c oQuote :  mapQuote.values()){
                                    if (oQuote.SBQQ__Status__c != 'Contract Approved'){
                                        if (oSBQQQuoteDocument.SBQQ__Template__c == 'Contract'){ 
                                            oQuote.SBQQ__Status__c = 'Contract Sent'; oQuote.Manual__c = true; 
                                        } 
                                        else { oQuote.SBQQ__Status__c = 'Quote Sent'; oQuote.Manual__c = true; 
                                        } 
                                    } 
                                }
                            }
                            if (mapOpportunity.size() > 0 ){
                                for (Opportunity oOpp : mapOpportunity.values()){ 
                                    if ((oOpp.StageName != 'Closed Won' || oOpp.StageName != 'Closed Booked')){
                                        if (oSBQQQuoteDocument.SBQQ__Template__c == 'Contract'){ 
                                            oOpp.Manual_Contract__c = true;  oOpp.StageName = 'Contract Sent';  oOpp.Status__c = '';   
                                        } else {
                                            oOpp.Manual_Contract__c = true;  oOpp.StageName = 'Proposal Sent';  oOpp.Status__c = 'Proposal Sent'; 
                                        }

                                    }
                                }
                            }                      
                        }
                    }
                    //END Manual contract funcationality

                    if( isAfter && isInsert) {
                        //Quote Status Sent
                        if(oSBQQQuoteDocument.SBQQ__SignatureStatus__c =='Sent' && oSBQQQuoteDocument.SBQQ__Template__c == 'Quote'){
                            if (mapQuote.size() > 0){  for (SBQQ__Quote__c oQuote :  mapQuote.values()) { if(oQuote.SBQQ__Status__c == 'Draft'){ oQuote.SBQQ__Status__c = 'Quote Sent';}  }  }
                            if (mapOpportunity.size() > 0){ for (Opportunity oOpp : mapOpportunity.values()){ if(oOpp.StageName == 'Customize'){    oOpp.StageName = 'Proposal Sent'; oOpp.Status__c = 'Proposal Sent';} } }
                        }

                        //Adding Condition : update primary check box on quote , If user send contract thurogh docusign which is primary check box is uncheck.
                        if (oSBQQQuoteDocument.SBQQ__SignatureStatus__c == 'Sent' && oSBQQQuoteDocument.SBQQ__Template__c == 'Contract' && oSBQQQuoteDocument.Primary_Quote__c == false){
                            if (mapQuote.size() > 0){ for (SBQQ__Quote__c oQuote :  mapQuote.values()) { if(!oQuote.SBQQ__Primary__c){ oQuote.SBQQ__Primary__c = true; }  } }
                        }

                        //Contract send through docusign
                        if(oSBQQQuoteDocument.SBQQ__SignatureStatus__c =='Sent' && oSBQQQuoteDocument.SBQQ__Template__c == 'Contract' && oSBQQQuoteDocument.Primary_Quote__c == true){
                            if (mapQuote.size() > 0){ for (SBQQ__Quote__c oQuote :  mapQuote.values()) { if(oQuote.SBQQ__Status__c != 'Contract Approved') { oQuote.SBQQ__Status__c = 'Contract Sent'; } } }
                            if (mapOpportunity.size() > 0){for (Opportunity oOpp : mapOpportunity.values()){ if(oOpp.StageName != 'Closed Won'){ oOpp.Contract_Sign_Status__c = 'Sent'; oOpp.StageName = 'Contract Sent';  } }  }
                        }
                    }
                    
                    //This method is working on after update.
                    if( isAfter && isupdate ) {    
                        //Quote In Review
                        if(oldListDocument.get(oSBQQQuoteDocument.Id).SBQQ__SignatureStatus__c != null &&  (oldListDocument.get(oSBQQQuoteDocument.Id).SBQQ__SignatureStatus__c != oSBQQQuoteDocument.SBQQ__SignatureStatus__c) && oSBQQQuoteDocument.SBQQ__SignatureStatus__c == 'Delivered' && oSBQQQuoteDocument.SBQQ__Template__c == 'Quote'){
                            if (mapQuote.size() > 0){
                                for (SBQQ__Quote__c oQuote :  mapQuote.values()) { if(oQuote.SBQQ__Status__c == 'Quote Sent'){  oQuote.SBQQ__Status__c = 'Quote In Review'; } } 
                            }                      
                        }

                        ////Contract In Review
                        if(oldListDocument.get(oSBQQQuoteDocument.Id).SBQQ__SignatureStatus__c != null &&  (oldListDocument.get(oSBQQQuoteDocument.Id).SBQQ__SignatureStatus__c != oSBQQQuoteDocument.SBQQ__SignatureStatus__c) && oSBQQQuoteDocument.SBQQ__SignatureStatus__c == 'Delivered' && oSBQQQuoteDocument.SBQQ__Template__c == 'Contract' && oSBQQQuoteDocument.Primary_Quote__c == true){
                            if (mapQuote.size() > 0){ for (SBQQ__Quote__c oQuote :  mapQuote.values()) { if(oQuote.SBQQ__Status__c == 'Contract Sent'){ oQuote.SBQQ__Status__c = 'Contract In Review'; } } }                      
                        }
                        //Quote Completed
                        if(oldListDocument.get(oSBQQQuoteDocument.Id).SBQQ__SignatureStatus__c != null &&  (oldListDocument.get(oSBQQQuoteDocument.Id).SBQQ__SignatureStatus__c != oSBQQQuoteDocument.SBQQ__SignatureStatus__c ) && oSBQQQuoteDocument.SBQQ__SignatureStatus__c == 'Completed' && oSBQQQuoteDocument.SBQQ__Template__c == 'Quote'){
                            if (mapQuote.size() > 0){ for (SBQQ__Quote__c oQuote :  mapQuote.values()) { oQuote.SBQQ__Primary__c  = true;  oQuote.SBQQ__Status__c = 'Quote Approved'; } }
                            if (mapOpportunity.size() > 0){ for (Opportunity oOpp : mapOpportunity.values()){ if(oOpp.StageName == 'Proposal Sent'){ oOpp.StageName = 'Proposal Approved'; } } }
                        }
                        
                        //Quote Declined.
                        if(oldListDocument.get(oSBQQQuoteDocument.Id).SBQQ__SignatureStatus__c != null &&  (oldListDocument.get(oSBQQQuoteDocument.Id).SBQQ__SignatureStatus__c != oSBQQQuoteDocument.SBQQ__SignatureStatus__c ) && oSBQQQuoteDocument.SBQQ__SignatureStatus__c == 'Declined' && oSBQQQuoteDocument.SBQQ__Template__c == 'Quote'){
                            if (mapQuote.size() > 0){ for (SBQQ__Quote__c oQuote :  mapQuote.values()) { oQuote.SBQQ__Status__c = 'Quote Rejected'; } }
                        }
                        
                        //Contract Completed
                       
                        if(oldListDocument.get(oSBQQQuoteDocument.Id).SBQQ__SignatureStatus__c != null &&  (oldListDocument.get(oSBQQQuoteDocument.Id).SBQQ__SignatureStatus__c != oSBQQQuoteDocument.SBQQ__SignatureStatus__c ) && oSBQQQuoteDocument.SBQQ__SignatureStatus__c == 'Completed' && oSBQQQuoteDocument.SBQQ__Template__c == 'Contract' && oSBQQQuoteDocument.Primary_Quote__c == true){
                            if (mapQuote.size() > 0){ for (SBQQ__Quote__c oQuote :  mapQuote.values()) { oQuote.SBQQ__Status__c = 'Contract Approved'; } }
                            if (mapOpportunity.size() > 0) { for (Opportunity oOpp : mapOpportunity.values()){ 
                            if( oOpp.StageName != 'Closed Lost' ) { if( oOpp.StageName != 'Closed Won' ) { oOpp.StageName = 'Closed Won';   oOpp.Contract_Sign_Status__c = 'Signed'; oOpp.isThroughDcousign__c = true;  oOpp.Update_Contracted__c  = true; 
                            oOpp.Contract_Attached__c = true;  oOpp.Status__c = 'Awaiting Payment';
                            } 
                            } 
                            } 
                            }
                            //Fixing After/Before Update values for Opportunity Trigger. BK-2992 Avinash Shukla ,oOpp.SBQQ__Contracted__c = true;
                        }
                        //contract declined.
                        if(oldListDocument.get(oSBQQQuoteDocument.Id).SBQQ__SignatureStatus__c != null &&  (oldListDocument.get(oSBQQQuoteDocument.Id).SBQQ__SignatureStatus__c != oSBQQQuoteDocument.SBQQ__SignatureStatus__c ) && oSBQQQuoteDocument.SBQQ__SignatureStatus__c == 'Declined' && oSBQQQuoteDocument.SBQQ__Template__c == 'Contract' && oSBQQQuoteDocument.Primary_Quote__c == true){                            if (mapQuote.size() > 0){ for (SBQQ__Quote__c oQuote :  mapQuote.values()) { oQuote.SBQQ__Status__c = 'Contract Rejected'; } }
                        }
                    }
                }
                /**
                    Removed isRebookInProcess = true.
                    BK-2992 
                    Avinash Shukla
                 */
                if(mapOpportunity.Values().size() > 0){ update mapOpportunity.values(); }
                if(mapQuote.values().size() > 0){ Update mapQuote.values(); }           
            }
        }
    }
}