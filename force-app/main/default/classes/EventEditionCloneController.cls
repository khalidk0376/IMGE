/**
 * File:        EventEditionCloneController.cls
 * Project:     GAP
 * Date:        12/7/2016 6:50 AM
 * Created By: Rajesh Kumar
 * *************************************************************************
 * Description: Clone Event Edition as per new finacial year and get all record related to previous event edition.
          
 * *************************************************************************
 * History:
 */
public with sharing class EventEditionCloneController
{
  public string nameOfEvent { get; set;}
  public String eventeditionid {get; set;}
  public list < Event_Edition__c > oEventEdition {get;set;}
  public Event_Edition__c eventedition {get;set;}
  public string sMessage {get;set;}
  public boolean isshowblock {get; set; }
  public String sCurrent_EE_Name {get;set;}
  public EventEditionCloneController()
  {
    isshowblock = true;
    // Get Event Editon Id
    eventeditionid = ApexPages.currentPage().getParameters().get('eventeditonid').escapeHtml4();
    //Query from Event Edition 
    oEventEdition = new list < Event_Edition__c > ();
    getEventEdition();
    sCurrent_EE_Name = eventedition.Name;
    nameOfEvent = getNext_EE_Name(sCurrent_EE_Name);

  }

  public PageReference save()
  {
    try
    {
      Event_Edition__c cloningEventEdition = new Event_Edition__c();
      if (eventedition.Name != nameOfEvent)
      {
        cloningEventEdition = new Event_Edition__c();
        cloningEventEdition = eventedition.clone();
        cloningEventEdition.name = nameOfEvent; 
        oEventEdition.add(cloningEventEdition);
      }
      else
      {
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING, 'Please Enter the unique Event Edition Name'));
        return null;
      }
        System.debug('eventeditionid ' + eventeditionid);
      if (oEventEdition != null && oEventEdition.size() > 0)
      {
          insert oEventEdition;
          System.debug('oEventEdition id' + oEventEdition.get(0).id);
          isshowblock = false;
        sMessage = 'Please Update Global Picklist Value for the Event Edition';
      }
      return null;
    }
    catch (DMLException e)
    {
      ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, string.valueOf(e));
      ApexPages.addMessage(myMsg);
      return null;
    }
  }
  public String getNext_EE_Name(String sCurrent_EE_Name)
  {
    String sPrevious_EE_Name;
    if (!String.isBlank(sCurrent_EE_Name))
    {
      String sCurrent_EE_Year = sCurrent_EE_Name.substring((sCurrent_EE_Name.length() - 4), sCurrent_EE_Name.length());
      if (sCurrent_EE_Year.isNumeric())
      {
        Integer iPrevious_EE_Year = integer.valueof(sCurrent_EE_Year) + 1;
        sPrevious_EE_Name = sCurrent_EE_Name.substring(0, (sCurrent_EE_Name.length() - 4)) + string.valueof(iPrevious_EE_Year);
      }
    }
    return sPrevious_EE_Name;
  }
  public PageReference redirectToEventEdtn()
  {
    return new pageReference('/' + oEventEdition.get(0).id);
  }
  
  public void getEventEdition()
  {
    eventedition = new Event_Edition__c();
    if (!IsEmptyOrNull(eventeditionid))
    {
      eventedition = [SELECT Part_of_Series__c, Event_Director__c, Cutoff_Date_1__c, Cutoff_Date_2__c, Cutoff_Date_3__c, Event_Price_Book__c, Approval_Service_Now_ID__c, Event_Website__c, CurrencyIsoCode, Venue__c, Event_Currency__c, Measurement__c, Status__c, Alternate_Currency__c, Payment_Schedule__c,Tab1__c , Tab7__c, Name FROM Event_Edition__c where id =: eventeditionid];
    }
  }
  //Utility method to check string is empty are not
  private Boolean IsEmptyOrNull(String strValue)
    {
      return (strValue == null || strValue.trim().equals('')) ? true : false;
    }
  //Utility method to get pegerefernance parameters
  @TestVisible private String getURParameter(String pname)
  {
    PageReference pageRef = ApexPages.currentPage();
    Map < string, string > pageParameters = pageRef.getParameters();
    string p = pageParameters.get(pname);
    return p;
  }

}