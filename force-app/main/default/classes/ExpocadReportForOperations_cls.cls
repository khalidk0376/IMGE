/**
 * File:        ExpocadReportForOperations_cls
 * Project:     GAP
 * Date:        5/12/2017
 * Created By:  Rajesh Kumar
 * Test Class:  ExpocadReportForOperationscls_Test 89%
 * *************************************************************************
 * Description: Showing Expocad Report for operational community user.
 * *************************************************************************
 * History: Modified By Yash Gupta [10/23/2019]
 */
 
public class ExpocadReportForOperations_cls{
    
    public String selEventSeries{get;set;}
    public String selEventEditon{get;set;}
    public Boolean hasEventEdition {get;set;}
    public string ErrorMessage{get;set;}
    public boolean buttonDisplay { get; set; }
    public List<SelectOption> eventedition = new List<SelectOption>();
    public List<Opportunity> lstOpp = new List<Opportunity>();
    Set<String> setListofTeam = new Set<String>();
    List<Operations_Team_Member__c> lstOTM = new List<Operations_Team_Member__c>(); 
    public boolean IsListOfTeamMemberCheck{get;set;}
    List<selectOption> eventseries = new List<selectOption>();

    /**
    * Description: Constructor call at the time of page load
    */
    public ExpocadReportForOperations_cls(){
      hasEventEdition = false;
      buttonDisplay = false;
      IsListOfTeamMemberCheck = false;
      lstOTM = [SELECT  Operations_Team__c  
                FROM Operations_Team_Member__c 
                Where User_Name__c =: UserInfo.getUserId()];
      if(lstOTM.size()==0){ ErrorMessage = 'You are not a part of the Operation team of any of the shows.'; IsListOfTeamMemberCheck = true; }
    }
    
    /**
    * Description: This can fetch all event edition name based on selected event series.
    */
    public List<selectOption> geteventeditonname(){ 
        eventedition.clear();
        eventedition.add(new selectOption ('--None--','--None--'));
        for(AggregateResult aggregateResult : [select id , Name 
                                               from Event_Edition__c 
                                               Where Part_of_Series__r.Id = : selEventSeries 
                                               AND Event_Edition_Status__c = 'Confirmed'  
                                               GROUP BY Name , Id]){
            eventedition.add(new selectOption((String)aggregateResult.get('id'),(String)aggregateResult.get('Name')));
            hasEventEdition = true;
        }
        return eventedition; 
    }

    /**
    * Description: This can fetch all event event series name based on current user id from the opportunity.
    */
    public List<selectOption> geteventseriesname() {
      if (lstOTM.size() > 0 && lstOTM != null){
      IsListOfTeamMemberCheck = false;
        for(Operations_Team_Member__c oTeamM : lstOTM ){
          setListofTeam.add(oTeamM.Operations_Team__c);
        }
        if (setListofTeam.size() > 0 && setListofTeam != null){
          eventseries.add(new selectOption('--None--','--None--'));
          for(AggregateResult aggregateResult : [SELECT  Event_Series__r.Name  e ,Event_Series__r.Id eid  
                                                 FROM Operations_Team__c 
                                                 Where Id IN : setListofTeam 
                                                 AND Event_Series__c != null 
                                                 GROUP BY Event_Series__r.Name , Event_Series__r.Id ]){
              eventseries.add(new selectOption((String)aggregateResult.get('eid'),(String)aggregateResult.get('e')));
          }
        }
      }
          return eventseries;
    }
    
    /**
    * Description: This will call once user click on go to reports.
    */
    public pagereference getToLink(){
      String sEventEditionName = '';
      if(!test.isrunningtest()){ sEventEditionName = [select Name 
                                                      from Event_Edition__c 
                                                      where Id=:selEventEditon].Name; }
      PageReference opageRedirect = new PageReference('/c/expocadApp.app?eventId='+selEventEditon+'&eventName='+sEventEditionName);
      opageRedirect.setRedirect(true);
      return opageRedirect;
    }

    /**
    * Description: This will call the feature of changing Event Series values.
    */
    public void changeEventSeries(){
        if( selEventSeries != '--None--' ){
            hasEventEdition = true;
        } else {
            hasEventEdition = false;
            buttonDisplay = false;
        }    
        
    }
    
    /**
    * Description: This will call the feature of changing event edition values.
    */
    public void changeEditionValue(){
        if( selEventEditon != '--None--' ){
            buttonDisplay = true;
        } else {
            buttonDisplay = false;
        }
    }
    
}