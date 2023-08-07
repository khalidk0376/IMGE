/**
* File:        BatchGetEventsStats.cls
* Project:     Informa Market (BAU GE)
* Date:		   24-12-2020
* Created By : Shiv Raghav Sharma
* Test Class : BatchGetEventsStats_Test.cls
* *************************************************************************
* Description: A call will be made to Expocad API (GET\Event\Stats) for event edition on which checkbox Run_Historical_Batch__c is 
true on weekly basis and a Historical Reporting record will created. 
* *************************************************************************
* History: BK-9620
*/
public class BatchGetEventsStats implements Database.Batchable<sObject>, Database.AllowsCallouts , Schedulable 
{
    public String batchRunFor;
    public List<Historical_Reporting__c> lstofReporting = new List<Historical_Reporting__c>();
    
    public BatchGetEventsStats(String runcondition)
    {
        batchRunFor = runcondition;
    }
    
    public Database.QueryLocator start(Database.BatchableContext batchableContext)
    {
        String query;
        if(batchRunFor == 'All')
        {
            query = 'select id from Event_Edition__c where Run_Historical_Batch__c = True'; 
        }
        else
        {
            query = 'select id from Event_Edition__c where id =:batchRunFor'; 
        }
        
        return Database.getQueryLocator(query);        
    }
    
    public void execute(Database.BatchableContext batchableContext, List<Event_Edition__c> scope) 
    {
        try{ 
            List<Event_Edition__c> recordswithchild = new List<Event_Edition__c>();
            recordswithchild = [SELECT id,Event_Code__c, Expocad_API_Url__c, (SELECT Starting_Booth_Area__c FROM Historical_Reportings__r where Report_Type__c = 'Report Type 1' Limit 1) FROM Event_Edition__c WHERE Id =: scope];
            
            Historical_Reporting_Setting__c ohistorycustomsetting = Historical_Reporting_Setting__c.getValues('Report Type 1');
            for (Event_Edition__c oEventEdition : recordswithchild) {
                if (oEventEdition != null && !String.isBlank(oEventEdition.Event_Code__c)) {
                    String sAPIUrl = oEventEdition.Expocad_API_Url__c + '/events/stats/?databaseName=' + oEventEdition.Event_Code__c;                
                    HttpResponse res = new ExpocadResponses().request(sAPIUrl, 'GET', '');
                    String sResBody = res.getBody();
                    System.debug('Body' +sResBody);
                    System.debug('res Status' +res.getStatusCode());
                    if (res.getStatus() == null) 
                    { 
                        System.debug('API Down'+res.getStatus());
                    } 
                    else if (!String.isBlank(sResBody)) {
                        ExpocadClasses.Stats eventStats = (ExpocadClasses.Stats)JSON.deserialize(sResBody, ExpocadClasses.Stats.class);
                        Historical_Reporting__c reporting = new Historical_Reporting__c();
                        reporting.Available_Booth_Area__c = Decimal.ValueOf(eventStats.AvailableBoothArea); 
                        reporting.Available_Booth_Percentage__c = Decimal.ValueOf(eventStats.AvailableBoothPercentage);
                        reporting.Available_Booths__c = Decimal.ValueOf(eventStats.AvailableBooths);
                        reporting.Current_Booth_Area__c = Decimal.ValueOf(eventStats.TotalBoothArea);
                        if(ohistorycustomsetting != Null)
                        {
                            reporting.Description__c = ohistorycustomsetting.Report_Type_Description__c;
                        }
                        reporting.Event_Edition__c = oEventEdition.id;
                        
                        if(eventStats.HoldBoothArea!=null)
                        {
                            reporting.Hold_Booth_Area__c = Decimal.ValueOf(eventStats.HoldBoothArea);
                            reporting.Hold_Booth_Percentage__c = Decimal.ValueOf(eventStats.HoldBoothPercentage);  
                            reporting.Hold_Booths__c = Decimal.ValueOf(eventStats.HoldBooths);    
                        }                   
                        reporting.Non_Inventory_Booth_Area__c  = Decimal.ValueOf(eventStats.NonInventoryBoothArea);
                        reporting.Non_Inventory_Booths__c = Decimal.ValueOf(eventStats.NonInventoryBooths);
                        reporting.Rented_Booth_Area__c = Decimal.ValueOf(eventStats.RentedBoothArea);
                        reporting.Rented_Booth_Percentage__c = Decimal.ValueOf(eventStats.RentedBoothPercentage);
                        reporting.Rented_Booths__c = Decimal.ValueOf(eventStats.RentedBooths);
                        reporting.Report_Type__c = 'Report Type 1';      
                        if(oEventEdition.Historical_Reportings__r.Size() > 0)
                        {
                            reporting.Starting_Booth_Area__c = oEventEdition.Historical_Reportings__r[0].Starting_Booth_Area__c;
                        }
                        else
                        {
                            reporting.Starting_Booth_Area__c = Decimal.ValueOf(eventStats.TotalBoothArea);                  
                        }            
                        reporting.Total_Booths__c = Decimal.ValueOf(eventStats.TotalBooths );
                        reporting.Total_Exhibitors__c = Decimal.ValueOf(eventStats.TotalExhibitors);
                        lstofReporting.add(reporting);  
                    }
                } 
            }
            if(!lstofReporting.isEmpty())
            {
                insert lstofReporting;
            }
        }
        catch (Exception Ex) {
            Utility.logError(Ex.getMessage(), Ex.getCause(), Ex.getLineNumber(), Ex.getStackTraceString(), 'execute(@BatchGetEventsStats.Class)');
        }   
        
    }
    
    public void finish(Database.BatchableContext BC) 
    {
        System.debug('Batch Run Successfully ....');
       // Get the ID of the AsyncApexJob representing this batch job  
        // from Database.BatchableContext.    
        // Query the AsyncApexJob object to retrieve the current job's information.  
        AsyncApexJob a = [Select Id, Status,ExtendedStatus,NumberOfErrors, JobItemsProcessed,
        TotalJobItems, CreatedBy.Email
        from AsyncApexJob where Id =:BC.getJobId()];
        // Send an email to the Apex job's submitter notifying of job completion.  
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String[] toAddresses = new String[] {a.CreatedBy.Email};
            mail.setToAddresses(toAddresses);
            mail.setSubject('BatchGetEventsStats' + a.Status);
            mail.setPlainTextBody('The batch Apex job processed ' + a.TotalJobItems +
           ' batches with '+ a.NumberOfErrors + ' failures.');
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });    
    }
    
    //@Description  Scheduled Method which will initiate this Batch Job
    public void execute(SchedulableContext ctx){
        Database.executeBatch(new BatchGetEventsStats('All'),50);
    }
}