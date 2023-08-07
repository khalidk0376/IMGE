/**
* File:        Rebook_Event_Edition_Ctrl.cls
* Project:     GAP
* Date:        Nov 25, 2016
* Created By:  Kumar Gaurav
* *************************************************************************
* @Description: Controller for RebookEventEdition page .
* *************************************************************************
* History:
Updated By : Shiv Raghav Sharma
Updated Date : Jan 17, 2019
Update DesCription : Update Functionality of Rebooking 
1. Modified to include dynamic way to clone all the fields on opportunity to new rebook opportunity.
Also put few checks to see if previous event edition has been added or not. 
Also removed all the products from opportunity line item. 
2. Make Dynamic SOQL Query for getting all fields of opportunity
3. Change Filter Criteria for opportunity retrive 
4. Update opprtunities of previous event edition for marked Rebooked checkbook to true.
5. Fix SCA Report Issues 
*/

public with sharing class Rebook_Event_Edition_Ctrl {
    
    String currentEE_ID;
    public Boolean bWarnMsg {get;set;}    
    Event_Edition__c currentEE;    
    
    public Rebook_Event_Edition_Ctrl(ApexPages.StandardController controller) {
        currentEE_ID = apexpages.currentpage().getparameters().get('id');
        currentEE = new Event_Edition__c();       
        if(currentEE_ID != null)
        {
            currentEE = [SELECT Id, Name,Start_Date__c, Prefix_for_Rebooking__c ,Previous_Event_Edition__c,Previous_Event_Edition__r.Event_Edition_Status__c FROM Event_Edition__c where id =: currentEE_ID Limit 1];            
            if(currentEE.Previous_Event_Edition__c == null ){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Previous event edition should not be blank. '));
                bWarnMsg = true;               
            }
            if(currentEE.Prefix_for_Rebooking__c == Null)
            {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Prefix for rebooking should not be blank. '));
                bWarnMsg = true;
            }               
            if(currentEE.Previous_Event_Edition__c != null && (currentEE.Previous_Event_Edition__r.Event_Edition_Status__c != 'Confirmed' && currentEE.Previous_Event_Edition__r.Event_Edition_Status__c != 'Active'))
            {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Previous event edition should be Active or Confirmed. '));
                bWarnMsg = true;
            }
        }        
        else
        {            
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'You are at wrong page , Rebook functionality can only be used from event edition'));            
            bWarnMsg = true;
        } 
    }
    
/* 
@Description: Rebook Opportunity for Event Edition by calling Batch_Opportunity_Rebook batch process
*/
    Public void rebookEE(){
        if(currentEE != Null)
        {
            Utility.isRebookInProcess = true ;
            ID recordId = currentEE.Previous_Event_Edition__c;
            Batch_Opportunity_Rebook btch = new Batch_Opportunity_Rebook(recordId,currentEE_ID,currentEE); 
            database.executeBatch(btch,30);  
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'Rebooking of ' +currentEE.Name+ ' is in progress - User will get email once completed'));
            bWarnMsg = true; 
        }    
    }
    
    public PageReference returnToPP() {
        if(currentEE_ID != Null)
        {    
            pageReference pg = new pageReference('/'+currentEE_ID);
            return pg;
        } 
        return null;
    } 
}