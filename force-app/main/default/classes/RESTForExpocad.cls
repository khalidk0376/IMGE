/**
 * File:        ValidateTeam.cls
 * Project:     GAP
 * Created Date: 29-Nov-2017
 * Created By:  Rajesh Kumar
 * Modified By:  Rajesh Kumar
 * Class Name : RESTForExpocad
 * Test Class: RESTForExpocad_Test
 * Coverage: 94%
 * *************************************************************************
 * Description: This class used to show all expocad booth record on expocad desk.
 * *************************************************************************
 * History: 
  Modified By: Rajesh Kumar On 13 Dec 2018 [GGCW-2846]
 */
@RestResource ( urlMapping = '/RESTForExpocad/*')
global with sharing class RESTForExpocad
{
  @HttpGet
  //Returns a List of Maps of all Expocad record
  global static List < Map < String , String >> GetExpocadJsonForEventStats () {
    String EventCode =RestContext.request.params.get('EventCode');
    List<ExpocadClasses.Stats> lstExpoBooth = new List<ExpocadClasses.Stats>();
    List < Map < String , String >> result = new List < Map < String , String >>();
    try{
      if (EventCode != null && EventCode != ''){
        Event_Edition__c oevent = [SELECT Id , Expocad_API_Url__c , Event_Code__c FROM Event_Edition__c WHERE Event_Code__c =: EventCode];
        String sExpocadURL = oevent.Expocad_API_Url__c+'/events/stats?databaseName=' +oevent.Event_Code__c;
        sExpocadURL = sExpocadURL.replace(' ', '%20');
          System.debug(sExpocadURL);
        Http h = new Http();
        // Send the request, and return a response
        HttpResponse res = new ExpocadResponses().request(sExpocadURL, 'GET', '');
        if(res.getBody()!= null){
          String sReturn = '[';
          sReturn += res.getBody();
          sReturn+=']';
          lstExpoBooth = (List<ExpocadClasses.Stats>)JSON.deserialize(sReturn, List<ExpocadClasses.Stats>.class);
          System.debug('lstExpoBooth ::' + lstExpoBooth);
            System.debug('json stats' + sReturn);
        }
        
        for ( ExpocadClasses.Stats oExpocad : lstExpoBooth ) {
          Map < String , String > row = new Map < String , String >();
          row.put ('TotalBooths', oExpocad.TotalBooths);
          row.put ('RentedBooths' , oExpocad.RentedBooths);
          row.put ('AvailableBooths', oExpocad.AvailableBooths);
          row.put ('NonInventoryBooths', oExpocad.NonInventoryBooths);
          row.put ('TotalExhibitors', oExpocad.TotalExhibitors);
          row.put('TotalBoothArea',oExpocad.TotalBoothArea); 
          row.put('RentedBoothArea', oExpocad.RentedBoothArea); 
          row.put('AvailableBoothArea', oExpocad.AvailableBoothArea);  
          row.put('NonInventoryBoothArea',oExpocad.NonInventoryBoothArea);   
          row.put('RentedBoothPercentage', oExpocad.RentedBoothPercentage);
          row.put('AvailableBoothPercentage',oExpocad.AvailableBoothPercentage);
          row.put('NetValueSold', oExpocad.NetValueSold);
          result.add (row);
        } 
        
      }
    }
    catch(Exception ex)
    {
      Utility.logError(ex.getMessage(), ex.getCause(), ex.getLineNumber(), ex.getStackTraceString(), 'Expocad Report class (RESTForExpocad)');
    }
    return result;
  }
}