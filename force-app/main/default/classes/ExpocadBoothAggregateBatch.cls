/**
* File:        ExpocadBoothAggregateBatch.cls
* Project:     Informa Market (BAU GE)
* Date:		   23-12-2020
* Created By : Rajesh Kumar 
* Test Class : ExpocadBoothAggregateBatch_Test.cls
* *************************************************************************
* Description: It will run on Rented/ Hold Expocad booth records with active event edition and where Expocad event code is not null.

They will create records for each matched product name and then against it will have the following fields calculated:

Matched Product Count

Matched Product Area

Matched Product Booth Status.

Event Edition should be populated for the Event Edition the batch job ran for.

Description - This should be populated from the value in custom settings/ custom label.
* *************************************************************************
* History: BK-9619
*/

public class ExpocadBoothAggregateBatch implements Database.Batchable<AggregateResult> , Schedulable {
    
    public String batchRunFor;
    
    public ExpocadBoothAggregateBatch(String runcondition)
    {
        batchRunFor = runcondition;
    }
    
    // The batch job starts
    public Iterable<AggregateResult> start(Database.BatchableContext bc){
        String query;
        if(batchRunFor == 'All')
        {
            query = 'Select COUNT(Id) cnt, Matched_Product_Name__c matchedprodname , Status__c stat, SUM (Area_Number__c) sumarea , Opportunity__r.EventEdition__c eventIds from ExpocadBooth__c where Status__c != \'Released\' AND Opportunity__r.EventEdition__r.Run_Historical_Batch__c = True GROUP BY Status__c,  Matched_Product_Name__c , Opportunity__r.EventEdition__c';
        }
        else
        {
            query = 'Select COUNT(Id) cnt, Matched_Product_Name__c matchedprodname , Status__c stat, SUM (Area_Number__c) sumarea , Opportunity__r.EventEdition__c eventIds from ExpocadBooth__c where Status__c != \'Released\'And Opportunity__r.EventEdition__c =:batchRunFor GROUP BY Status__c,  Matched_Product_Name__c , Opportunity__r.EventEdition__c';
        }
        return new AggregateResultIterable(query,batchRunFor);
    } 
    
    // The batch job executes and operates on one batch of records
    public void execute(Database.BatchableContext bc, List<sObject> scope){ 
        List<Historical_Reporting__c> lsthistoryReport = new List<Historical_Reporting__c>();
        try{
            Historical_Reporting_Setting__c ohistorycustomsetting = Historical_Reporting_Setting__c.getValues('Report Type 2');
            for(sObject sObj : scope) {
                AggregateResult ar = (AggregateResult)sObj;
                Historical_Reporting__c ohistoryReport = new Historical_Reporting__c();
                ohistoryReport.Matched_Product_Name__c = String.valueof(ar.get('matchedprodname'));
                ohistoryReport.Matched_Product_Count__c = Integer.valueOf(ar.get('cnt'));
                ohistoryReport.Matched_Product_Area__c = String.valueof(ar.get('sumarea'));
                ohistoryReport.Matched_Product_Booth_Status__c = String.valueof(ar.get('stat'));
                ohistoryReport.Event_Edition__c = String.valueof(ar.get('eventIds'));
                ohistoryReport.Description__c =  ohistorycustomsetting.Report_Type_Description__c;
                ohistoryReport.Report_Type__c = 'Report Type 2';                    
                lsthistoryReport.add(ohistoryReport);
            }
            if(!lsthistoryReport.isEmpty())
            {
                insert lsthistoryReport;
            }
        }
        catch (Exception Ex) {
            Utility.logError(Ex.getMessage(), Ex.getCause(), Ex.getLineNumber(), Ex.getStackTraceString(), 'execute(@ExpocadBoothAggregateBatch.Class)');
        } 
    }
    
    // The batch job finishes
    public void finish(Database.BatchableContext bc){ 
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
            mail.setSubject('ExpocadBoothAggregateBatch' + a.Status);
            mail.setPlainTextBody('The batch Apex job processed ' + a.TotalJobItems +
           ' batches with '+ a.NumberOfErrors + ' failures.');
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
    
    //@Description  Scheduled Method which will initiate this Batch Job
    public void execute(SchedulableContext ctx){
        Database.executeBatch(new ExpocadBoothAggregateBatch('All'),50);
    }
}