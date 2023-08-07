/**
 * File:        BoothSelectionCtrl.cls
 * Project:     GAP
 * Date:        Sep 06, 2016
 * Created By:  Kumar Gaurav
 * *************************************************************************
 * Description: Controller for BoothSelectionCtrl page to search Booth from 
                Expocad.
 * *************************************************************************
 * History:
 */

Public class SWD_Ctrl {


    public String sCES {get;set;}
    public String sCRL {get;set;}
    public String sCreditCheckFailedMsg {get;set;}
    public SBQQ__QuoteDocument__c oQuoteDocument {get;set;}
    public Boolean isLightingEnv {get;set;}
    public Boolean hasPartner {get;set;}
    public Boolean hasNoBillingContact {get;set;}
    Public String QdID {get;set;}
    pageReference redirectToDocuSign ;

    public SWD_Ctrl(ApexPages.StandardController controller) {
      redirectToDocuSign = null ;
      String sCurrentUrl = ApexPages.currentPage().getURL();
      QdID = apexpages.currentpage().getparameters().get('id');
      if(sCurrentUrl.tolowercase().contains('lightning')){
        isLightingEnv = true;
        hasPartner = false;
        hasNoBillingContact = false;
      }
    }
    
    Public PageReference autorun(){
      SBQQ__QuoteDocument__c oQuoteDocument = [select Primary_Contact_Last_Name__c, Primary_Contact_First_Name__c, Primary_Contact_Email__c, SBQQ__Quote__c, SBQQ__Template__c from SBQQ__QuoteDocument__c where Id=: apexpages.currentpage().getparameters().get('id') LIMIT 1];
      System.debug('oQuoteDocument '+oQuoteDocument);
      pageReference pg ;
      if(oQuoteDocument != null && oQuoteDocument.SBQQ__Quote__c != null){
        System.debug('oQuoteDocument.SBQQ__Quote__c '+oQuoteDocument.SBQQ__Quote__c);
        // sCES='Informa '+oQuoteDocument.SBQQ__Template__c+' for you to sign'; 
        sCES='Informasigny'; 
        //String scess = sCES.replaceAll(' ',' ');
        sCRL='Email~'+oQuoteDocument.Primary_Contact_Email__c+';FirstName~'+oQuoteDocument.Primary_Contact_First_Name__c+';LastName~'+oQuoteDocument.Primary_Contact_Last_Name__c+';Role~A;RecipientNote~'+oQuoteDocument.SBQQ__Template__c+';RoutingOrder~1';
        //pg = new pageReference('/apex/dsfs__DocuSign_CreateEnvelope');
        //pg = new pageReference('/apex/dsfs__DocuSign_CreateEnvelope?DSEID=0&SourceID='+QdID+'&RQD='+QdID+'&SSB=1&CCRM=A~Signer 1&CCTM=A~Signer&CRL='+sCRL+'&CES='+sCES+'&RC=');
        pg = new pageReference('/apex/dsfs__DocuSign_CreateEnvelope?DSEID=0&SourceID='+QdID+'&RQD='+QdID+'&SSB=1&CCRM=A~Signer1&CCTM=A~Signer&CRL='+sCRL+'&RC=');
        redirectToDocuSign = pg;
        SBQQ__Quote__c oQuote = [select SBQQ__Opportunity2__c from SBQQ__Quote__c where Id=: oQuoteDocument.SBQQ__Quote__c LIMIT 1];
        System.debug('oQuote '+oQuote);
        if(oQuote != null && oQuote.SBQQ__Opportunity2__c != null){
          System.debug('oQuote.SBQQ__Opportunity2__c '+oQuote.SBQQ__Opportunity2__c);
          Opportunity oOpportunity = [select AccountId, Credit_Status_Eval__c ,Billing_Contact__c , Partner_Account__c , Agreement_Contact__c , Opportunity_Contact__c from Opportunity where Id=: oQuote.SBQQ__Opportunity2__c LIMIT 1];
          System.debug('oOpportunity '+oOpportunity);
          if(oOpportunity != null && oOpportunity.AccountId != null){
            System.debug('oOpportunity.AccountId '+oOpportunity.AccountId);
            if (oOpportunity.Opportunity_Contact__c != null && oOpportunity.Agreement_Contact__c == null){
               // oOpportunity.Agreement_Contact__c = oOpportunity.Partner_Account__c;
                  update new Opportunity(Id=oOpportunity.Id,Agreement_Contact__c = oOpportunity.Opportunity_Contact__c);
            }
            if(oOpportunity.Credit_Status_Eval__c != null && (oOpportunity.Credit_Status_Eval__c == 'Warning' || oOpportunity.Credit_Status_Eval__c == 'Hold')){
                sCreditCheckFailedMsg = 'The Quote cannot be generated as the Credit Status is ' + oOpportunity.Credit_Status_Eval__c + '.';
                return null;
            }else if(oOpportunity.Billing_Contact__c == null){
                sCreditCheckFailedMsg = 'The opportunity has no Billing Contact. Please verify that the correct Billing Contact has been selected? ';
                hasNoBillingContact = true;
                return null;
            }
            else{
                List<Partner> lstPartner = [select AccountToId from Partner where AccountFromId =: oOpportunity.AccountId];
                if(lstPartner!= null && lstPartner.size() > 0){
                  sCreditCheckFailedMsg =  'The opportunity account has a Partner account. Please verify that the correct Billing Contact has been selected?';
                  System.debug('Has partner');
                  hasPartner = true;
                  return null;
                }
            }
          }
        }
        System.debug('No Execution');
      }
      System.debug('Page '+pg);
      return pg;
    }
    
    public PageReference returnToPT() {
      pageReference pg = new pageReference('/'+apexpages.currentpage().getparameters().get('id'));
      return pg;
    }
    
    public PageReference redirectToDS() {
      return redirectToDocuSign;
    }
}