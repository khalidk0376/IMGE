/**
 * File:        ProductClonePageController.cls
 * Project:     GAP
 * Date:        11/17/2016 3:03 AM 
 * Created By: Rajesh Kumar
 * *************************************************************************
 * Description: clone Quote Line to with required related fields. 
 * *************************************************************************
 * History: Set time to start date in Quote Line item.
 */

public with sharing class ProductClonePageController {
  public SelectOption[] selectedContacts {
    get;
    set;
  }
  public SelectOption[] allContacts {
    get;
    set;
  }
  public SelectOption[] years {
    get;
    set;
  }
  public String QuoteLineId {
    get;
    set;
  }
  public string salesPrice {
    get;
    set;
  }
  public list < SBQQ__QuoteLine__c > QuoteLineItems {
    get;
    set;
  }
  public SBQQ__QuoteLine__c LineItems {
    get;
    set;
  }
  public string SelectedYear {
    get;
    set;
  }
  public String message {
    get;
    set;
  }
  public integer runMonth;
  public integer runYear;

  public ProductClonePageController() {
    // Get Quote Line Id
    QuoteLineId = getURParameter('QuoteLineId');
    //Query from Quote Line 
    getLineItem();
    //Get Years 
    GetYears();
    selectedContacts = new List < SelectOption > ();
    //Get Month
    GetMonths();
  }

  public PageReference save() {
    try {
      if (selectedContacts.size() > 0) {
        message = 'Selected Months: ';
        Boolean first = true;
        list < SBQQ__QuoteLine__c > QuoteLineItems = new list < SBQQ__QuoteLine__c > ();
        SBQQ__QuoteLine__c cloningQuoteline = new SBQQ__QuoteLine__c();
        cloningQuoteline = new SBQQ__QuoteLine__c();
        for (SelectOption so: selectedContacts) {
          cloningQuoteline = LineItems.clone();
          cloningQuoteline.Run_Date__c = date.newinstance(Integer.valueOf(SelectedYear), Integer.valueOf(so.getValue()), 1);
          if (!first) {
            message += ', ';
          }
          message += so.getLabel() + ' (' + so.getValue() + ')';
          first = false;
          if (cloningQuoteline.SBQQ__Product__r.Family == 'Event') {
            cloningQuoteline.ServiceEndDate__c = date.today();
            QuoteLineItems.add(cloningQuoteline);
          } else if (cloningQuoteline.SBQQ__Product__r.Family == 'Publishing') {
            cloningQuoteline.ServiceEndDate__c = cloningQuoteline.Run_Date__c;
            QuoteLineItems.add(cloningQuoteline);
          } else if (cloningQuoteline.SBQQ__Product__r.Family == 'Digital' && Date.today().daysBetween(cloningQuoteline.Run_Date__c) < 30 && date.today().month() == cloningQuoteline.Run_Date__c.month()) {
            cloningQuoteline.ServiceEndDate__c = date.today();
            QuoteLineItems.add(cloningQuoteline);
          } else if (cloningQuoteline.SBQQ__Product__r.Family == 'Digital' && Date.today().daysBetween(cloningQuoteline.Run_Date__c) < 30 && date.today().month() != cloningQuoteline.Run_Date__c.month()) {
            cloningQuoteline.ServiceEndDate__c = cloningQuoteline.Run_Date__c.adddays(4);
            QuoteLineItems.add(cloningQuoteline);
          } else if (Date.today().daysBetween(cloningQuoteline.Run_Date__c) > 30 && cloningQuoteline.SBQQ__Product__r.Family == 'Digital') {
            cloningQuoteline.ServiceEndDate__c = cloningQuoteline.Run_Date__c.adddays(-30);
            QuoteLineItems.add(cloningQuoteline);
          } else {
            QuoteLineItems.add(cloningQuoteline);
          }
        }
        if (QuoteLineItems != null && QuoteLineItems.size() > 0) {
          insert QuoteLineItems; //insert new quote line with product 
        }
        string pageUrl = null;
        PageReference AgreementLocation;
        pageUrl = 'https://' + ApexPages.currentPage().getHeaders().get('Host') + '/' + LineItems.SBQQ__Quote__r.Id;
        //system.debug('cloningQuoteline ---->'+QuoteLineItems[0].Name);
        AgreementLocation = new PageReference(pageUrl);
        return AgreementLocation.setRedirect(true);
      } else {
        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Please select run date month');
        ApexPages.addMessage(myMsg);
        return null;
      }
    } catch (DMLException e) {
      ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, string.valueOf(e));
      ApexPages.addMessage(myMsg);
      return null;
    }
  }
  public void getLineItem() {
    LineItems = new SBQQ__QuoteLine__c();
    if (!IsEmptyOrNull(QuoteLineId)) {
      LineItems = [SELECT ServiceEndDate__c, Brand__c, Line_Description__c, SBQQ__Product__r.Family, SBQQ__Quote__r.id, SBQQ__ProductFamily__c, SBQQ__Product__r.Name, SBQQ__Quantity__c, Run_Date__c, Name, Unit_Price__c, SBQQ__ListPrice__c FROM SBQQ__QuoteLine__c where id =: QuoteLineId];
    }
  }
  public void GetMonths() {
    allContacts = new List < SelectOption > ();
    allContacts.add(new SelectOption('1', 'January(1)'));
    allContacts.add(new SelectOption('2', 'February(2)'));
    allContacts.add(new SelectOption('3', 'March(3)'));
    allContacts.add(new SelectOption('4', 'April(4)'));
    allContacts.add(new SelectOption('5', 'May(5)'));
    allContacts.add(new SelectOption('6', 'June(6)'));
    allContacts.add(new SelectOption('7', 'July(7)'));
    allContacts.add(new SelectOption('8', 'August(8)'));
    allContacts.add(new SelectOption('9', 'September(9)'));
    allContacts.add(new SelectOption('10', 'October(10)'));
    allContacts.add(new SelectOption('11', 'November(11)'));
    allContacts.add(new SelectOption('12', 'December(12)'));
  }

  public void GetYears() {
      integer i = system.today().year();
      integer lastyear = i + 5;
      years = new List < SelectOption > ();
      while (i <= lastyear) {
        years.add(new SelectOption(string.ValueOf(i), string.ValueOf(i)));
        i = i + 1;
      }
    }
    //Utility method to check string is empty are not
  @TestVisible private Boolean IsEmptyOrNull(String strValue) {
      return (strValue == null || strValue.trim().equals('')) ? true : false;
    }
    //Utility method to get pegerefernance parameters
  @TestVisible private String getURParameter(String pname) {
    PageReference pageRef = ApexPages.currentPage();
    Map < string, string > pageParameters = pageRef.getParameters();
    string p = pageParameters.get(pname);
    return p;
  }

}