/**
* Created By       :   Girikon(Yash Gupta [STL-227])
* Created On       :   04 Oct, 2019
* @description     :   This controller used to get expocad data by calling rest api. First Query on Event Edition Custom Object to get Expocad API URL by passing event code. Called Rest API using GET method, here we are using existing class "ExpocadResponses" to request 
* Test Class       :   ExpocadRentedBooth_LWC_Test(88%)
* Modified by      :   Yash Gupta [23 Oct, 2019]
**/

public class ExpocadRentedBooth_LWC{

    /*
    * @description [This method is used to fetch the all rented booth based on event code from booth API]
    * @param eventCode [get eventCode from the selected event edition]
    * @return [Map <String , Object>]
    */
    @AuraEnabled(cacheable=true)
    public static Map <String , Object> getExpocadForEventStats(String eventCode) {        
        //Variable declarations
        List<ExpocadClasses.Booth> lstExpoBooth = new List<ExpocadClasses.Booth>();
        Map<String,Object> result = new Map<String , Object>();
        Set<String> setExhibitorId = new Set<String>();
        Map<Id,Account> lstAcc = new Map<Id,Account> ();
        try{
            if (eventCode != null && eventCode != ''){
                Event_Edition__c oevent = [SELECT Id , Name, Expocad_API_Url__c , Event_Code__c FROM Event_Edition__c WHERE Event_Code__c =: eventCode];
                String sExpocadURL = oevent.Expocad_API_Url__c+'/booths/all/rented?databaseName='+oevent.Event_Code__c;
                sExpocadURL = sExpocadURL.replace(' ', '%20'); 
                HttpResponse res = new ExpocadResponses().request(sExpocadURL, 'GET', '');
                if(res.getBody()!= null){
                    String sReturn =  res.getBody();
                    lstExpoBooth = (List<ExpocadClasses.Booth>)JSON.deserialize(sReturn, List<ExpocadClasses.Booth>.class);
                    result.put('lstExpoBooth',lstExpoBooth);
                }
                if (lstExpoBooth != null && lstExpoBooth.size() > 0){  for ( ExpocadClasses.Booth oExpocad : lstExpoBooth ) {                      if (String.IsNotBlank(oExpocad.ExhibitorId)){ setExhibitorId.add(oExpocad.ExhibitorId); }
                    }
                }                
                lstAcc = new Map<Id,Account>([select Id, Name from Account where Id IN : setExhibitorId]);
                result.put('lstAcc',[select Id, Name from Account where Id IN : setExhibitorId]);
            } 
        } 
        catch(Exception ex) {
            Utility.logError(ex.getMessage(), ex.getCause(), ex.getLineNumber(), ex.getStackTraceString(), 'Expocad Report class (ExpocadRentedBooth_LWC)');
        }
        return result;
    }

    /*
    * @description [This method is used to fetch the all booth based on event code from booth API]
    * @param eventCode [get eventCode from the selected event edition]
    * @return [Map <String , Object>]
    */
    @AuraEnabled(cacheable=true)
    public static Map <String , Object> GetExpocadJsonForEventStats(String eventCode) {
        //Variable declarations
        List<ExpocadClasses.Stats> lstExpoBooth1 = new List<ExpocadClasses.Stats>();
        Map<String,Object> result1 = new Map<String , Object>();
        try{
            if (eventCode != null && eventCode != ''){
                Event_Edition__c oevent = [SELECT Id , Name, Expocad_API_Url__c , Event_Code__c 
                                           FROM Event_Edition__c 
                                           WHERE Event_Code__c =: eventCode];
                String sExpocadURL = oevent.Expocad_API_Url__c+'/events/stats?databaseName='+oevent.Event_Code__c;
                sExpocadURL = sExpocadURL.replace(' ', '%20'); 
                HttpResponse res = new ExpocadResponses().request(sExpocadURL, 'GET', '');
                if(res.getBody()!= null){
                    String sReturn = '[';
                    sReturn += res.getBody();
                    sReturn+=']';
                    lstExpoBooth1 = (List<ExpocadClasses.Stats>)JSON.deserialize(sReturn, List<ExpocadClasses.Stats>.class);
                    result1.put('lstExpoBooth1',lstExpoBooth1);
                }
            } 
        } catch(Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
        return result1;
    }

    /*
    * @description [This method is used to fetch the all booth based on event code from booth API]
    * @param eventCode [get eventCode from the selected event edition]
    * @return [Map <String , Object>]
    */
    @AuraEnabled(cacheable=true)
    public static Map <String , Object> getRESTForExpocadAllBooth(String eventCode) {
        //Variable declarations
        List<ExpocadClasses.Booth> lstBooth = new List<ExpocadClasses.Booth>();
        Map<String,Object> fetchresult = new Map<String , Object>();
        Set<String> setAccountId = new Set<String>();
        Map<Id,Account> lstAccount = new Map<Id,Account> ();
        
        try{
            if (eventCode != null && eventCode != ''){
                Event_Edition__c oevent = [SELECT Id , Name, Expocad_API_Url__c , Event_Code__c FROM Event_Edition__c WHERE Event_Code__c =: eventCode];
                String sExpocadURL = oevent.Expocad_API_Url__c+'/booths/all?databaseName='+oevent.Event_Code__c;
                sExpocadURL = sExpocadURL.replace(' ', '%20'); 
                HttpResponse res = new ExpocadResponses().request(sExpocadURL, 'GET', '');
                if(res.getBody()!= null){
                    String sReturn =  res.getBody();
                    lstBooth = (List<ExpocadClasses.Booth>)JSON.deserialize(sReturn, List<ExpocadClasses.Booth>.class);
                    fetchresult.put('lstBooth',lstBooth);
                }
                if (lstBooth != null && lstBooth.size() > 0){
                    for ( ExpocadClasses.Booth oExpocad : lstBooth ) { if (String.IsNotBlank(oExpocad.ExhibitorId)){ setAccountId.add(oExpocad.ExhibitorId);  }
                    }
                }                
                lstAccount = new Map<Id,Account>([select Id, Name from Account where Id IN : setAccountId]);
                fetchresult.put('lstAccount',[select Id, Name from Account where Id IN : setAccountId]);
            } 
        } catch(Exception ex) { Utility.logError(ex.getMessage(), ex.getCause(), ex.getLineNumber(), ex.getStackTraceString(), 'Expocad Report class (ExpocadRentedBooth_LWC)'); if(!test.isrunningtest()){ throw new AuraHandledException(ex.getMessage()); }
        }
        return fetchresult;
    }
}