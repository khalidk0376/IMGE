/**
* File:        Batch_Opportunity_Rebook
* Project:     GAP
* Date:        Jan 24, 2019
* Created By:  Shiv Raghav Sharma
* *************************************************************************
* Description: Batch Class for processing rebooking opportunity records
* ************************************************************************* 
*/

public class Batch_Opportunity_Rebook implements Database.Batchable<sObject>,Database.stateful {
    
    String previousEE_ID;   
    String currentEE_ID;
    Event_Edition__c currentEE;
    List<Opportunity> previousEEOppsList; 
    List<Opportunity> newEEOppsList;    
    Integer totalNoOfOppToBeClone = 0; 
    Integer totalNoOfOppSuccessToInsert = 0; 
    Integer totalNoOfOppFailedToInsert = 0; 
    Integer totalNoOfOppSuccessToUpdate = 0; 
    Integer totalNoOfOppFailedToUpdate = 0;     
    
    /*
@description : Batch Constructor for get Current and Previous event edition record which is calling 
from Rebook_Event_Edition_Ctrl Controller
*/
    public Batch_Opportunity_Rebook(String previousEEId, String CurrentEEId, Event_Edition__c CurrntEE) {              
        previousEE_ID = previousEEId;        
        currentEE_ID = CurrentEEId;
        currentEE = CurrntEE;          
    }
    
    /*
@description : Getting all Opportunity records of previous event edition
*/
    public Database.QueryLocator start(Database.BatchableContext BC) {         
        Set<String> stageNameSet = new Set<String>();            
        stageNameSet.add('Closed Booked');
        stageNameSet.add('Closed Won');
        String query = 'select Name,Type,OwnerId,CloseDate,Agreement_Contact__c,Billing_Contact__c,Billing_Contact__r.Inactive__c,Legal_Representative_1__c,Legal_Representative_2__c,Local_Representative__c,Marketing_Contact__c,MarkitMkr_Contact__c,Nota_Fiscal__c,Operation_Contact_2__c,Operation_Contact_3__c,Operation_Contact_4__c,Operation_Contact_5__c,Operations_Contact__c,Opportunity_Contact__c,Safety_Contact__c,Stand_Contractor__c,AccountId,PartnerAccountId,Partner_Account__c,Exhibitor_Paid_By__c,User_Type__c,CurrencyIsoCode,Event_Edition_Currency__c,Event_Series__c,EventEdition__c,Tax_Id__c,Payment_Schedule__c,Payment_Schedules__c,ReBooking_From_Opportunity__c,StageName,Status__c,Probability,Revenue_Estimate__c,Do_not_activate_Billing__c from opportunity where EventEdition__r.id =: previousEE_ID AND Rebooked__c = false And SBQQ__Contracted__c = True And Parent_Opportunity__c = Null And SBQQ__AmendedContract__c = Null And Agent_s_Opportunity__c = Null And StageName IN :stageNameSet';        
        return Database.getQueryLocator(query);
    }
    
    /*
    @description : Insert new opportuntiy into current event edition and 
    update old opportunity of privious event editon and
    insert failure records id with error msg into rebooking error object
    */    
    public void execute(Database.BatchableContext BC, List<Opportunity> previousEEGetAllOpps) {        
        totalNoOfOppToBeClone += previousEEGetAllOpps.Size();         
        previousEEOppsList = new List<Opportunity>();
        newEEOppsList = new List<Opportunity>();         
        for(Opportunity oppItemList : previousEEGetAllOpps)
        {        
            opportunity oppClone = oppItemList.clone(false, false, false, false);                
            String oPPName = CurrentEE.Prefix_for_Rebooking__c +' '+ oppItemList.Name;                
            Integer maxSize = 120;
            if(oPPName.Length() > maxSize)
            {
                oPPName = oPPName.substring(0, maxSize);
            }
            oppClone.Name =  oPPName;                                                                                       
            oppClone.StageName = System.label.Opportunity_Stage_Name_Discover;            
            oppClone.Status__c = System.label.Opportunity_Stage_Name_Discover;                               
            oppClone.Probability = 10;
            oppClone.EventEdition__c = currentEE_ID;                
            oppClone.ReBooking_From_Opportunity__c = oppItemList.Id;           
            oppClone.Opp_External_Id__c = oppItemList.Id + currentEE_ID;
            oppClone.CloseDate = currentEE.Start_Date__c;
            
            if(oppItemList.Billing_Contact__r.Inactive__c == True)
            {
                oppClone.Billing_Contact__c = Null;  
            } 
            newEEOppsList.add(oppClone);             
        }
        
        if(newEEOppsList.size() > 0 ){             
            try{
                Utility.isRebookInProcess = true ;
                Rebooking_Error__c rebookingError = new Rebooking_Error__c();
                List<Rebooking_Error__c> rebookingErrorList = new List<Rebooking_Error__c>();
                Set<id> oldEEOppIds = new Set<id>(); 
                Database.SaveResult[] srList = Database.insert(newEEOppsList,false);                
                for(Integer i=0;i<srList.size();i++)
                {
                    if (srList[i].isSuccess()) {                                                                   
                        oldEEOppIds.add(newEEOppsList[i].ReBooking_From_Opportunity__c);
                        totalNoOfOppSuccessToInsert += 1;  
                        
                    }
                    else
                    {                        
                        rebookingError = new Rebooking_Error__c();
                        rebookingError.OpportunityId__c = newEEOppsList[i].ReBooking_From_Opportunity__c;
                        rebookingError.Rebooking_Object__c = 'Opportunity' ;                     
                        rebookingError.Error_Message__c = String.valueOf(srList[i].getErrors()[0]); 
                        rebookingError.JobId__c = BC.getJobId();   
                        rebookingError.Operation__c = 'Insert'; 
                        rebookingError.Event_Edition__c = currentEE_ID;
                        rebookingErrorList.add(rebookingError);                        
                        totalNoOfOppFailedToInsert += 1;                          
                    }                    
                }
                
                if(oldEEOppIds.Size()> 0)
                {                       
                    For(String oldOppId : oldEEOppIds) 
                    {
                        Opportunity oppToUpdate = new Opportunity(id = oldOppId, Rebooked__c = true);                        
                        previousEEOppsList.add(oppToUpdate);
                    }
                    Database.SaveResult[] UpdateList = Database.update(previousEEOppsList,false);  
                    for(Integer i=0;i<UpdateList.size();i++)
                    {
                        if (UpdateList[i].isSuccess()) {                                                                                               
                            totalNoOfOppSuccessToUpdate += 1;                   
                        }
                        else
                        {
                            rebookingError = new Rebooking_Error__c();
                            rebookingError.OpportunityId__c = previousEEOppsList.get(i).id;
                            rebookingError.Rebooking_Object__c = 'Opportunity' ;                     
                            rebookingError.Error_Message__c = String.valueOf(UpdateList[i].getErrors()[0]);   
                            rebookingError.JobId__c = BC.getJobId();
                            rebookingError.Operation__c = 'Update'; 
                            rebookingError.Event_Edition__c = currentEE_ID;
                            rebookingErrorList.add(rebookingError);
                            totalNoOfOppFailedToUpdate += 1;  
                        }                       
                    } 
                } 
                if(rebookingErrorList.Size() > 0)
                {                    
                    insert rebookingErrorList;
                    System.debug('rebookingErrorList Success');
                }         
            }
            catch(Exception e){
                Rebooking_Error__c log =  new Rebooking_Error__c();
                log.Rebooking_Object__c = 'Opportunity' ;  
                log.JobId__c = BC.getJobId();
                log.Error_Message__c = 'Type: ' + e.getTypeName() + '\n' + 'Cause: ' + e.getCause() + '\n' + 'Message: ' 
                    + e.getMessage() + '\n' + 'Line #: ' + e.getLineNumber() + '\n' + e.getStackTraceString();                                   
                insert log;                
                system.debug('exception from rebooking>>>'+e.getLineNumber() + '-----' + e.getStackTraceString() + e.getMessage());                      
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
        mail.setSubject(currentEE.Name + ' Rebooking Status');
        if(totalNoOfOppToBeClone > 0)
        {
            mail.setPlainTextBody(currentEE.Name +' Rebooking Results: ' +'\n\n' +
                                  'Total opportunities attempted:  ' + totalNoOfOppToBeClone + '\n' +
                                  'Total successfully rebooked:  ' +totalNoOfOppSuccessToInsert + '\n' +
                                  'Total rebook failure:  ' +totalNoOfOppFailedToInsert + '\n' +
                                  'Total successful opportunities update on previous event edition:  ' +totalNoOfOppSuccessToUpdate + '\n' +
                                  'Total failed opportunities update on previous event edition:  ' +totalNoOfOppFailedToUpdate + '\n' + '\n' + '\n' +
                                  'Note :- Please find failed records in rebooking errors object with JobId ---' + BC.getJobId());
            
        }
        else
        {           
            mail.setPlainTextBody(currentEE.Name +' Rebooking Results: ' +'\n\n' +'No Opportunity found for rebook.');  
        }
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        Utility.isRebookInProcess = false ;        
        System.debug('Total records To Clone -----------' +totalNoOfOppToBeClone);
        System.debug('Successfully inserted Records -----------' +totalNoOfOppSuccessToInsert); 
        System.debug('Failed Records To Insert ------------' +totalNoOfOppFailedToInsert);
        System.debug('SuccessFully Updated Records ------------' +totalNoOfOppSuccessToUpdate);
        System.debug('Falied Records To Updated ------------' +totalNoOfOppFailedToUpdate);                 
    }
}