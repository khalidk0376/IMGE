/**
* File:        Batch_Close_Open_Opportunities
* Project:     GAP
* Date:        Nov 22, 2019,   [Aishwarya BK-3759 27 Aug 2020]
* Created By:  Shiv Raghav Sharma
* Test Class : Close_Open_Opportunities_Test
* *************************************************************************
* Description: Batch Class for Closed all opporotunity has StageName NOT IN ('Closed Won', 'Closed Booked' , 'Closed Lost')
* ************************************************************************* 
*/
public class Batch_Close_Open_Opportunities implements Database.Batchable<sObject>,Database.stateful {
    String eventEditionId;
    Integer totalNoOfOppToBeClosed = 0; 
    Integer totalNoOfOppSuccessToClosed = 0; 
    Integer totalNoOfOppFailedToClosed = 0; 
    public Batch_Close_Open_Opportunities(String evnteEdtnId) {              
        eventEditionId = evnteEdtnId;                
    }
   /*
@description : Getting all Opportunity records which need to be closed lost of event edition. 
*/    
    public Database.QueryLocator start(Database.BatchableContext BC) {  
        Set<String> stageNameSet = new Set<String>();            
        stageNameSet.add('Closed Booked');
        stageNameSet.add('Closed Won');
        stageNameSet.add('Closed Lost');
        String query = 'Select id,StageName,Status__c,Reason_Lost__c,Cancel_Reason__c from Opportunity where EventEdition__r.id =: eventEditionId AND StageName NOT IN :stageNameSet';        
        return Database.getQueryLocator(query);        
    }
  /*
@description : update opportuntiy with closed lost stage and 
insert failure records id with error msg into rebooking error object
*/      
    public void execute(Database.BatchableContext BC, List<Opportunity> oppToBeClosed) { 
        if(oppToBeClosed.Size() > 0){   
            try{ 
                System.debug('oppToBeClosed.Size()' +oppToBeClosed.Size());
                System.debug('totalNoOfOppToBeClosed ' +totalNoOfOppToBeClosed );
                totalNoOfOppToBeClosed += oppToBeClosed.Size();
                for(Opportunity Opp : oppToBeClosed){
                    opp.StageName =  'Closed Lost';
                    opp.Status__c = 'Event Edition Closed';
                    opp.Reason_Lost__c = 'Event Edition Closed'; 
                    opp.Cancel_Reason__c = 'Event Edition Closed';
                }
                Database.SaveResult[] srList = Database.update(oppToBeClosed,false);
                List<Rebooking_Error__c> rebookingErrorList = new List<Rebooking_Error__c>();
                
                for(Integer i=0;i<srList.size();i++){
                    if (srList[i].isSuccess()) {                                                                                       
                        totalNoOfOppSuccessToClosed += 1; System.debug('totalNoOfOppSuccessToClosed ' +totalNoOfOppSuccessToClosed );                                  
                    } 
                   else{   
                        Rebooking_Error__c rebookingError = new Rebooking_Error__c();
                        // System.debug('srList[i].getId()--' +srList[i].getId());
                        rebookingError.OpportunityId__c = oppToBeClosed[i].id;
                        rebookingError.Rebooking_Object__c = 'Opportunity' ;                     
                        rebookingError.Error_Message__c = String.valueOf(srList[i].getErrors()[0]); 
                        rebookingError.JobId__c = BC.getJobId();   
                        rebookingError.Operation__c = 'Update'; 
                        rebookingError.Event_Edition__c = eventEditionId;
                        rebookingErrorList.add(rebookingError);                        
                        totalNoOfOppFailedToClosed += 1;     
                        System.debug('totalNoOfOppFailedToClosed' +totalNoOfOppFailedToClosed);    
                     }
                 
                }
                if(rebookingErrorList.Size() > 0){ insert rebookingErrorList;
                }  
            }             
            catch(Exception e){             
                system.debug('exception from Opportunity Clossing>>>'+e.getLineNumber() + '-----' + e.getStackTraceString() + e.getMessage());                      
            } 
        }
    }
    /*
@description : Send Email to current user which contain total no of success, failed records
*/    
    public void finish(Database.BatchableContext BC) {
        // Get the AsyncApexJob that represents the Batch job using the Id from the BatchableContext
        AsyncApexJob a = [Select Id, Status, NumberOfErrors, JobItemsProcessed,
                          TotalJobItems, CreatedBy.Email, ExtendedStatus
                          from AsyncApexJob where Id = :BC.getJobId()];
        // Email the Batch Job's submitter that the Job is finished.
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {a.CreatedBy.Email};
            mail.setToAddresses(toAddresses);
        mail.setSubject('Opportunities Close Status');
        if(totalNoOfOppToBeClosed > 0){
            mail.setPlainTextBody('Opportunities Close Status : ' +'\n\n' +
                                  'Total opportunities to be closed :  ' + totalNoOfOppToBeClosed + '\n' +
                                  'Total successfully Closed Opportunity :  ' +totalNoOfOppSuccessToClosed + '\n' +
                                  'Total Unsuccessfully Closed Opportunity :  ' +totalNoOfOppFailedToClosed + '\n' + '\n' + '\n' +                                  
                                  'Note :- Please find failed records in rebooking errors object with JobId ---' + BC.getJobId());            
        }
        else{           
            mail.setPlainTextBody('Opportunities Close Status  : ' +'\n\n' +'No Opportunity found for Close.');  
        }
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });                   
    }
}