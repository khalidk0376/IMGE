/**
* File:             cls_amendContract.cls
* Project:          GAP
* Date:             Jan 21, 2017
* Test Class:       cls_amendContract_Test
* Code Coverage:    97%
* Created By:       Kumar Gaurav
* Modified By:      Rajesh Kumar
* Modified Date:    13/12/2018 - GGCW-2825
* *************************************************************************
* @Description   Controller to amend Closed Opportunity.
* *************************************************************************
* History: Modified By Rajesh Kumar [GGCW-2824]
* Modified By Rajesh Kumar [GGCW-3494]
* Modified By Avinash Shukla for JIRA ticket GGCW-3481 on 30/05/2019
* Modified By Avinash Shukla for JIRA ticket GGCW-3497 on 12/06/2019
*/
public class cls_amendContract {

    // Variables
    public string OppId {get; set;}
    public String sShowMsg {get; set;}

    public string sProductType {get; set;}
    public string sTypeOfChg {get; set;}

    /**
     * Custructor.
     * @param  controller [ApexPages.StandardController]
     */
    public cls_amendContract(ApexPages.StandardController controller) {
        OppId = ApexPages.currentPage().getParameters().get('oppId').escapeHtml4();

        if (String.IsNotBlank(ApexPages.currentPage().getParameters().get('prdType')) && String.IsNotBlank(ApexPages.currentPage().getParameters().get('tyChg'))) {
            sProductType = ApexPages.currentPage().getParameters().get('prdType').escapeHtml4();
            sTypeOfChg = ApexPages.currentPage().getParameters().get('tyChg').escapeHtml4();
        }
    }

    /**
     * Method to call SB API to request an amend for Opportunity.
     * @return [pageReference]
     */
    public pageReference amendContract() {
        if (!String.isBlank(OppId)) {
            QuoteModel  qmodels ;
            Opportunity ParentOpportunity = [SELECT Id, Name, OwnerId, Main_Contract__c, Opportunity_Contact__c, Billing_Contact__c, Event_Series__c, EventEdition__c, Partner_Account__c, SBQQ__AmendedContract__c, StageName, Is_Amend_Opportunity__c FROM Opportunity WHERE Id = :oppId];
            if (ParentOpportunity != NULL && ParentOpportunity.StageName == 'Closed Won' && ParentOpportunity.SBQQ__AmendedContract__c == NULL && !String.isBlank(ParentOpportunity.Main_Contract__c)) {
                String qmodelJson = SBQQ.ServiceRouter.load('SBQQ.ContractManipulationAPI.ContractAmender', ParentOpportunity.Main_Contract__c, null);
                qmodels = (QuoteModel )System.JSON.deserialize(qmodelJson, QuoteModel.class);
                Utility.isReviewProcess = true;
                // Calling Future method to update few things on amend oppty and quote asynchronously.
                if (Utility.isReviewProcess) {
                    if (String.IsNotBlank(sProductType)) {
                        cls_amendContract.updateAmendOpptyAndQuote(oppId, qmodels.record.Id, sProductType, sTypeOfChg);
                    } else {
                        cls_amendContract.updateAmendOpptyAndQuote(oppId, qmodels.record.Id, '', '');
                    }
                }


                if (qmodels != null && !String.isblank(qmodels.record.Id)) {

                    // Modified By Avinash Shukla : GGCW-3497
                    /*List<SBQQ__Quote__c> lstAmendQuote = [select id, SBQQ__Opportunity2__c from SBQQ__Quote__c where id = :qmodels.record.Id];
                    Map<Id, Id> masterOppToNewOpp = new Map<Id, Id>();
                    Map<Id, Id> masterOppToNewQuote = new Map<Id, Id>();
                    masterOppToNewOpp.put(oppId, lstAmendQuote[0].SBQQ__Opportunity2__c);
                    masterOppToNewQuote.put(oppId, qmodels.record.Id);
                    amendContractHelper ach = new amendContractHelper(masterOppToNewOpp, masterOppToNewQuote);
                    ach.updateAmendmentOppQli();
                    ach.updateAllRelatedEb();
                    ach.updateAllRelatedEbm();
                    ach.updateParentOppForRelatedOpps();*/
                    // Modified By Avinash Shukla : GGCW-3497
                    
                    PageReference pageRef = new PageReference('/apex/SBQQ__sb?id=' + qmodels.record.Id + '#quote/le?qId=' + qmodels.record.Id);
                    return pageRef;
                }
            }
            if (ParentOpportunity.SBQQ__AmendedContract__c != NULL) {
                sShowMsg = 'This is not master opportunity, you can not process for amendment.';
                return null;
            }
            if (ParentOpportunity.StageName != 'Closed Won') {
                sShowMsg = 'You can not process for amendment, Opportunity is not Colsed Won.';
                return null;
            }
            if (String.isBlank(ParentOpportunity.Main_Contract__c)) {
                sShowMsg = 'Contract is not found for this opportunity, hence amendment cannot be processed.';
                return null;
            }
        }
        return null;
    }

    /**
    * Future method to update Amend Opportunity and Quote Billng/Primary Contact
    * @param oppId    [Parent Opportunity Id]
    * @param qModelId [Amend Quote Id]
    */
    @future(callout = true)
    public static void updateAmendOpptyAndQuote(Id oppId, Id qModelId, String sProductType, String sTypeofchange) {
        List<blng__Invoice__c> lstInvoiceUpdate = new List<blng__Invoice__c>();
        Application_Bypass__c appbypass = Application_Bypass__c.getInstance();
        if (oppId != NULL && qModelId != NULL) {
            Opportunity ParentOpportunity = [SELECT Id, Name, OwnerId , Main_Contract__c, Opportunity_Contact__c, Billing_Contact__c, Event_Series__c, EventEdition__c, Partner_Account__c, SBQQ__AmendedContract__c, IsAmendContractOpp__c , StageName , Exhibitor_Paid_By__c, CurrencyIsoCode, AccountId FROM Opportunity WHERE Id = :oppId];

            List<SBQQ__Quote__c> lstAmendQuote = [select id, SBQQ__Opportunity2__c from SBQQ__Quote__c where id = :qModelId];
            if (lstAmendQuote != null && !String.isBlank(lstAmendQuote[0].SBQQ__Opportunity2__c)) {
                Opportunity oAmendOpportunityToUpdate = new Opportunity();
                oAmendOpportunityToUpdate.Id = lstAmendQuote[0].SBQQ__Opportunity2__c ;
                if (ParentOpportunity.Partner_Account__c != null) {
                    oAmendOpportunityToUpdate.Partner_Account__c = ParentOpportunity.Partner_Account__c;
                }
                if (ParentOpportunity.Opportunity_Contact__c != null) {
                    oAmendOpportunityToUpdate.Opportunity_Contact__c = ParentOpportunity.Opportunity_Contact__c;
                }
                if (ParentOpportunity.Billing_Contact__c != null) {
                    oAmendOpportunityToUpdate.Billing_Contact__c = ParentOpportunity.Billing_Contact__c;
                }
                if (ParentOpportunity.Event_Series__c != null) {
                    oAmendOpportunityToUpdate.Event_Series__c = ParentOpportunity.Event_Series__c;
                }
                if (ParentOpportunity.EventEdition__c != null) {
                    oAmendOpportunityToUpdate.EventEdition__c = ParentOpportunity.EventEdition__c;
                }
                if (ParentOpportunity.Exhibitor_Paid_By__c != null ) {
                    oAmendOpportunityToUpdate.Exhibitor_Paid_By__c = ParentOpportunity.Exhibitor_Paid_By__c;
                }
                oAmendOpportunityToUpdate.Master_Opportunity__c = oppId;
                oAmendOpportunityToUpdate.Main_Contract__c = ParentOpportunity.Main_Contract__c;
                oAmendOpportunityToUpdate.IsAmendContractOpp__c = true;
                oAmendOpportunityToUpdate.CurrencyIsoCode = ParentOpportunity.CurrencyIsoCode;

                /* Modified by Rajesh Kumar Ticket No: [GGCW-1329]    Start*/

                if (appbypass.Bypass_Validation_Rules__c) {
                    oAmendOpportunityToUpdate.OwnerId = ParentOpportunity.OwnerId;
                }
                /* Modified by Rajesh Kumar Ticket No: [GGCW-1329]    End */
                SBQQ__Quote__c oQuoteToUpdate = new SBQQ__Quote__c() ;
                oQuoteToUpdate.Id = qModelId;
                if (ParentOpportunity.Billing_Contact__c != null) {
                    oQuoteToUpdate.Billing_Contact__c = ParentOpportunity.Billing_Contact__c;
                }

                if (ParentOpportunity.Opportunity_Contact__c != null) {
                    oQuoteToUpdate.SBQQ__PrimaryContact__c = ParentOpportunity.Opportunity_Contact__c;
                }
                oQuoteToUpdate.CurrencyIsoCode = ParentOpportunity.CurrencyIsoCode;

                if (oQuoteToUpdate.Id != NULL) {
                    Utility.isRebookInProcess = true;
                    update oQuoteToUpdate;
                }
                if (oAmendOpportunityToUpdate.Id != NULL) {
                    Utility.isRebookInProcess = true;
                    update oAmendOpportunityToUpdate;
                }
                ParentOpportunity.Is_Amend_Opportunity__c = True;
                //Modified BY Avinash : GGCW-3481
                ParentOpportunity.Status__c = 'Amended';
                if (ParentOpportunity.Id != null) {
                    Utility.isRebookInProcess = true;
                    update ParentOpportunity;

                    /**
                    * Modified By: Yash Gupta
                    * @Description Update the invoice status of master opportunity to "Rebilled" as per ticket no. "GGCKB-153".
                    */
                    /*system.debug('ParentOpportunity Id: '+ParentOpportunity.Id);
                    List<blng__Invoice__c> lstInvoice = [select id, blng__InvoiceStatus__c, blng__Order__r.OpportunityId from blng__Invoice__c where blng__Order__r.OpportunityId = :ParentOpportunity.Id and blng__InvoiceStatus__c !='Cancelled' and blng__InvoiceStatus__c != 'Rebilled'];
                    system.debug('lstInvoice: '+lstInvoice.size());
                    if (lstInvoice.size() > 0) {
                        for (blng__Invoice__c inv : lstInvoice) {
                                inv.blng__InvoiceStatus__c = 'Rebilled';
                                lstInvoiceUpdate.add(inv);
                        }
                        if (lstInvoiceUpdate.size() > 0) {
                            update lstInvoiceUpdate;
                        }
                    }*/
                }

                /**
                    Modified By: Yash Gupta
                    @Description Insert change request functionality as per ticket no GGCW-3466
                */
               /* if (String.IsNotBlank(sProductType)) {
                    Change_Request__c cReq = new Change_Request__c();
                    cReq.Account__c = ParentOpportunity.AccountId;
                    cReq.Event_Edition__c = ParentOpportunity.EventEdition__c;
                    cReq.Opportunity__c = ParentOpportunity.Id;
                    cReq.Product_Type__c = sProductType;
                    cReq.Type_of_Change__c = sTypeofchange;
                    cReq.Change_Request_Status__c = 'New';
                    cReq.Amended_Opportunity__c = oAmendOpportunityToUpdate.Id;
                    insert cReq;
                }*/
            }
        }
    }

    /**
     * Redirect to Parent Opportunity.
     * @return [pageReference]
     */
    public pageReference redirectOppty() {
        PageReference pageRef = new PageReference('/' + OppId);
        return pageRef;
    }

    /**
     * Inner Wrapper Class QuoteModel
     */
    public class QuoteModel {
        public Record record {get; set;}
    }

    /**
     * Inner Wrapper Class Record
     */
    public class Record {
        public String Id {get; set;}
    }

}