/**
 * File:          ExpocadReport_cls
 * Project:       GAP
 * Date:          12/5/2017
 * Test Class :   ExpocadReportcls_Test 86%
 * Created By:    Rajesh Kumar
 * @Description: This class is used to handle the functionality of expocad deck on the home page inside "Expocad Report Decks".
 * History: Modified By Yash Gupta [10/23/2019]
 */
 
public class ExpocadReport_cls{   
    
    public String selEventSeries{get;set;}
    public String selEventEditon{get;set;}
    public Boolean hasEventEdition {get;set;}    
    public boolean buttonDisplay { get; set; }
    public List<SelectOption> eventedition = new List<SelectOption>();
    public List<Opportunity> lstOpp = new List<Opportunity>();
    List<selectOption> eventseries = new List<selectOption>();
 
    /**
    * Description: Constructor call at the time of page load
    */
    public ExpocadReport_cls(){
        hasEventEdition = false;
        buttonDisplay = false;
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
        }
        return eventedition; 
    }
    
    /**
    * Description: This can fetch all event event series name based on current user id from the opportunity.
    */
    public List<selectOption> geteventseriesname() {
        eventseries.add(new selectOption('--None--','--None--'));
        for(AggregateResult aggregateResult : [SELECT  Event_Series__r.Name e , Event_Series__r.Id eId  
                                               FROM Opportunity
                                               Where Owner.id = : UserInfo.getUserId()  
                                               AND  Event_Series__c != null 
                                               GROUP BY Event_Series__r.Name , Event_Series__r.Id ]){
            If(aggregateResult  != null){
                eventseries.add(new selectOption((String)aggregateResult.get('eId'),(String)aggregateResult.get('e')));
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
        } else { hasEventEdition = false; buttonDisplay = false; }
    }
    
    
    /**
    * Description: This will call the feature of changing event edition values.
    */
    public void changeEditionValue(){
        if( selEventEditon != '--None--' ){
            buttonDisplay = true;
        } else { buttonDisplay = false; }
    }
}