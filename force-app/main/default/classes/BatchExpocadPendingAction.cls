/**
* File:        BatchExpocadPendingAction.cls
* Project:     GAP
* Date:        May 10, 2017
* Created By:  Kumar Gaurav
* *************************************************************************
* Description: Batch Class which will be scheduled to Rent/Unhold Unsuccessful
               attempt during any Exception/Expocad Server Down Time
* *************************************************************************
* History:
*/

public class BatchExpocadPendingAction implements Database.Batchable<sObject>, Schedulable, Database.Stateful, Database.AllowsCallouts
{
    public static Integer batchSize = 1;
    private String query = null;
    List<Expocad_Pending_Action__c> lstEPA ;
    List<String> parts ;
    public BatchExpocadPendingAction()     
    {
        lstEPA = new List<Expocad_Pending_Action__c>();
        parts = new List<String>();
        query =  'SELECT Id , Booth_Number__c, Opportunity__c, Opportunity__r.AccountId, Quote__c, Event_Code__c, Opportunity__r.stageName, Request_Method_Type__c, Expocad_API_Url__c, Display_Name__c FROM Expocad_Pending_Action__c ';
        query += ' WHERE Status__c = \'Fail\' AND Status_Code__c Like \'5%\'  ORDER BY Request_Method_Type__c ASC';
        System.debug('SOQL : ' + query );
    }    

    public Database.QueryLocator start(Database.BatchableContext batchableContext){
        return Database.getQueryLocator(query);        
    }
    
    //@Description  All pending expocad actions executed again.
    public void execute(Database.BatchableContext batchableContext, List<Expocad_Pending_Action__c> scope) {
        for (Expocad_Pending_Action__c oEPA : (List<Expocad_Pending_Action__c>)scope) {
            try{
                String sExecutionMsg ;
                DateTime currentTime = System.now();
                if(oEPA.Request_Method_Type__c == 'Rent' && oEPA.Opportunity__r.stageName != 'Closed Lost'){
                    sExecutionMsg = ExpocadResponses.SyncRENT(oEPA.Booth_Number__c, oEPA.Opportunity__c, oEPA.Quote__c, oEPA.Event_Code__c, '', false); 
                }
                else if(oEPA.Request_Method_Type__c == 'Unhold'){
                    sExecutionMsg = ExpocadResponses.SyncUNHOLD(oEPA.Booth_Number__c, oEPA.Opportunity__c, oEPA.Quote__c, oEPA.Event_Code__c, oEPA.Expocad_API_Url__c , '');
                }
                else if (oEPA.Request_Method_Type__c == 'UnRent'){
                    sExecutionMsg = ExpocadResponses.SyncUnRent(oEPA.Booth_Number__c, oEPA.Opportunity__c, oEPA.Quote__c, oEPA.Event_Code__c, oEPA.Expocad_API_Url__c , '');
                }
                
                /*else if(oEPA.Request_Method_Type__c == 'DisplayNameOverride' && !String.isBlank(oEPA.Display_Name__c)){
                    sExecutionMsg = ExpocadResponses.SyncUpdateDisplay(oEPA.Booth_Number__c, oEPA.Opportunity__c, oEPA.Quote__c, oEPA.Event_Code__c, oEPA.Expocad_API_Url__c, oEPA.Display_Name__c);
                }*/
                
                else if(oEPA.Request_Method_Type__c == 'RentToHold' && !oEPA.Opportunity__r.stageName.containsIgnoreCase('Closed')){
                    sExecutionMsg = ExpocadResponses.SyncRentToHold(oEPA.Booth_Number__c, oEPA.Opportunity__c, oEPA.Quote__c, oEPA.Event_Code__c, oEPA.Expocad_API_Url__c);
                }
                else if(oEPA.Request_Method_Type__c == 'Hold'){
                    sExecutionMsg = ExpocadResponses.SyncHOLD(oEPA.Booth_Number__c, oEPA.Opportunity__c,  oEPA.Quote__c, oEPA.Event_Code__c, oEPA.Expocad_API_Url__c, oEPA.Display_Name__c);
                }
                else if(oEPA.Request_Method_Type__c == 'Add Co-Exhibitor'){
                    sExecutionMsg = BoothSelectionHlpr.createCoExibitor(oEPA.Booth_Number__c, oEPA.Event_Code__c, oEPA.Opportunity__c,  oEPA.Quote__c, oEPA.Opportunity__r.AccountId ,oEPA.Expocad_API_Url__c, oEPA.Display_Name__c);
                }
                else if(oEPA.Request_Method_Type__c == 'Remove Co-Exhibitor'){
                    //BoothSelectionHlpr oBoothSelectionHlpr = new BoothSelectionHlpr();
                    sExecutionMsg = BoothSelectionHlpr.RemoveCoExibitor(oEPA.Booth_Number__c, oEPA.Event_Code__c, oEPA.Opportunity__c,  oEPA.Quote__c, oEPA.Opportunity__r.AccountId ,oEPA.Expocad_API_Url__c);
                }
                
                //Start GGCW-3256 - Rajesh Kumar
               /* else if(oEPA.Request_Method_Type__c == 'unRentToRent'){
                    BoothSelectionHlpr.unRentToRent(oEPA.Booth_Number__c, oEPA.Event_Code__c, oEPA.Opportunity__c , oEPA.Quote__c, oEPA.Opportunity__r.AccountId , oEPA.Expocad_API_Url__c , oEPA.Display_Name__c) ;
                    
                }*/
                
                else if(oEPA.Request_Method_Type__c == 'Exhibitor Display Name'){
                    Boolean isflagoff = false;
                    sExecutionMsg = RemovedCoExhibitorClosedLost_class.updateDisplayDrawingNameToExibitors(oEPA.Booth_Number__c, oEPA.Event_Code__c, oEPA.Opportunity__c,oEPA.Display_Name__c , isflagoff , '' );
                }
                
                //End GGCW-3256- Rajesh Kumar
                if (!String.isBlank(sExecutionMsg)){
                    parts = sExecutionMsg.split(' - ');
                    System.debug('test Rajesh Kr :'+ parts[0]  +  parts[1] +  parts[2] + parts[3]);
                }
                if(parts.size() > 0 ){ 
                    if (parts[0] == 'Failure'){
                        oEPA.Status__c = 'Fail';
                    }
                    else {
                      oEPA.Status__c = parts[0] ; 
                    }
                   
                    oEPA.Status_Code__c = parts[1];
                    oEPA.API_Message__c = parts[2];
                    oEPA.Callout_Status__c = parts[3];
                    oEPA.Last_API_Call_Time__c = currentTime;
                    lstEPA.add(oEPA);
                    System.debug('Tst Rajesh Kr : ' + lstEPA);
                }      
            }
            catch (Exception Ex) {
                Utility.logError(Ex.getMessage(), Ex.getCause(), Ex.getLineNumber(), Ex.getStackTraceString(), 'execute(@BatchExpocadPendingAction.Class)');
            } 
        }
    }
    
    //@Description  Updates record which has been completed successfully 
    public void finish(Database.BatchableContext batchableContext) {
        if(lstEPA != Null && lstEPA.size() > 0) {
            try{
                Update lstEPA;
            }
            catch (Exception Ex) {
                Utility.logError(Ex.getMessage(), Ex.getCause(), Ex.getLineNumber(), Ex.getStackTraceString(), 'finish(@BatchExpocadPendingAction.Class)');
            } 
        }
    }
    
    //@Description  Scheduled Method which will initiate this Batch Job
    public void execute(SchedulableContext ctx)
    {
        Database.executeBatch(new BatchExpocadPendingAction(), 1);
    }
    
}