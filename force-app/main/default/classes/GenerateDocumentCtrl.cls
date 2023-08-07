/**
* File:        GenerateDocumentCtrl.cls
* Project:     GAP
* Date:        Nov 30, 2016
* Created By:  Rajesh Kr.
* *************************************************************************
* Description: Controller for GenerateDocumentCtrl page to check validation before genarate documnet.
* *************************************************************************
* History:
*/

public class GenerateDocumentCtrl {
    
    public String sCreditCheckFailedMsg {
        get;
        set;
    }
    public SBQQ__Quote__c oQuote {
        get;
        set;
    }
    public Boolean isLightingEnv {
        get;
        set;
    }
    public Boolean hasPartner {
        get;
        set;
    }
    public Boolean hasNoBillingContact {
        get;
        set;
    }
    public String QdID {
        get;
        set;
    }
    public boolean show{get;set;}
    pageReference redirectToDocuSign;    
    public GenerateDocumentCtrl(ApexPages.StandardController controller) {
        redirectToDocuSign = null;
        String sCurrentUrl = ApexPages.currentPage().getURL();
        QdID = apexpages.currentpage().getparameters().get('id');
        show = false;
    }
    Public PageReference autorun() {
        show = false;
        SBQQ__Quote__c oQuote = [select SBQQ__Opportunity2__c,SBQQ__PrimaryContact__c from SBQQ__Quote__c where Id =: apexpages.currentpage().getparameters().get('id') LIMIT 1];
        PageReference pg;
        
        if(oQuote.SBQQ__PrimaryContact__c == null ){
            show = true;            
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Primary Contact not found.'));
            return null;            
        }        
        if (oQuote != null && oQuote.SBQQ__Opportunity2__c != null) {
            Opportunity oOpportunity = [select AccountId, Credit_Status_Eval__c, Billing_Contact__c,Auto_Send_Contract__c , Partner_Account__c, Agreement_Contact__c, Opportunity_Contact__c from Opportunity where Id =: oQuote.SBQQ__Opportunity2__c LIMIT 1];
            pg = new pageReference('/apex/SBQQ__GenerateDocument?scontrolCaching=1&id=' + QdID);
            redirectToDocuSign = pg;
            if (oOpportunity != null && oOpportunity.AccountId != null) {
                if (oOpportunity.Opportunity_Contact__c != null && oOpportunity.Agreement_Contact__c == null) {
                    update new Opportunity(Id = oOpportunity.Id, Agreement_Contact__c = oOpportunity.Opportunity_Contact__c);
                }
                if (oOpportunity.Credit_Status_Eval__c != null && (oOpportunity.Credit_Status_Eval__c == 'Warning' || oOpportunity.Credit_Status_Eval__c == 'Hold')) { sCreditCheckFailedMsg = 'The Quote cannot be generated as the Credit Status is ' + oOpportunity.Credit_Status_Eval__c + '.'; return null;
                                                                                                                                                                     }
                else if (oOpportunity.Billing_Contact__c == null && (oOpportunity.Auto_Send_Contract__c == true || oOpportunity.Auto_Send_Contract__c == false)) {
                    sCreditCheckFailedMsg = 'Billing contact on Opportunity is empty. Please provide a Billing Contact';
                    hasNoBillingContact = true;
                    return null;
                }
                else {
                    List < Partner > lstPartner = [select AccountToId from Partner where AccountFromId =: oOpportunity.AccountId];
                    if (lstPartner != null && lstPartner.size() > 0) {
                        sCreditCheckFailedMsg = 'The opportunity account has a Partner account. Please verify that the correct Billing Contact has been selected?';
                        hasPartner = true;
                        return null;
                    }
                }
            }
        }
        return pg;
    }
    
    public PageReference returnToPT() {
        pageReference pg = new pageReference('/' + apexpages.currentpage().getparameters().get('id'));
        return pg;
    }
    
    public PageReference redirectToDS() {
        return redirectToDocuSign;
    }
}