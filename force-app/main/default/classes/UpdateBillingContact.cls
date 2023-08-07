/**
 * File:        UpdateBillingContact
 * Project:     GAP
 * Date:        Sep 28, 2016
 * Created By:  Rajesh Kumar
 * *************************************************************************
 * Description: Controller for UpdateOpportunityField page , when user selected primary contact.
 * *************************************************************************
 * History:
 */

public with sharing class UpdateBillingContact{

  private ApexPages.StandardController controller {get; set;}
  private final Opportunity opp;
  public Boolean refreshPage {get; set;}

  public UpdateBillingContact(ApexPages.StandardController controller) {
    this.controller = controller;
    this.opp = (Opportunity)controller.getRecord();
  }
  
  public PageReference updatePrimaryContacteName() {
  
   List<OpportunityContactRole> ocr =[Select Contact.Name from OpportunityContactRole where OpportunityId=:opp.Id and isPrimary=true limit 1];
    if( (ocr !=null && ocr.size() > 0) && opp.Billing_Contact__c !=ocr[0].Contact.Id){
    
      update new Opportunity(Id=opp.Id,Billing_Contact__c=ocr[0].Contact.Id);
      refreshPage=true;
    }
    else{
      refreshPage=false;
    }
    return null;
  }
}