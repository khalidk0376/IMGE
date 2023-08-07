/**
* File:            BoothApprovalProcess_Trig.cls
* Project:         GAP
* Created By:      Rajesh Kumar yadav
* Modified By:     Rajesh Kumar (related toGGCkB-161)
* Test Class:      BoothApprovalProcess_test
* Coverage:        84%
*
* *************************************************************************
* @description
* *************************************************************************
* History:Ticket :GGCkB-76 ,161
*
*/

public without sharing class BoothApprovalProcess_Trig implements TriggerInterface_BoothApprovalDashboard.Runnable {
    
    //Variables Declarations
    Set<Id> setOppId = new Set<Id>();
    Set<String> setStatus = new Set<String>();
    
    public void run(TriggerInterface_BoothApprovalDashboard.Trig trig) {
        if (trig.isAfter && trig.isUpdate) {
            if (trig.newList.size() > 0) {
                for (Booth_Approval_Dashboard__c oBoothApproval : trig.newList) {
                    setStatus.add(oBoothApproval.Status__c);
                    if (trig.oldMap.get(oBoothApproval.Id).Status__c != oBoothApproval.Status__c && oBoothApproval.Status__c == 'Approved') {
                        setOppId.add(oBoothApproval.Opportunity__c );
                    }
                    if (trig.oldMap.get(oBoothApproval.Id).Status__c != oBoothApproval.Status__c && oBoothApproval.Status__c == 'Declined') {
                        setOppId.add(oBoothApproval.Opportunity__c );
                    }
                }
                if (setOppId.size() > 0) {
                    List<Opportunity> lstOpportunity = new List<Opportunity> ();
                    if (Schema.sObjectType.Opportunity.fields.Booth_Approval_Status__c.isAccessible() && Schema.sObjectType.Opportunity.fields.MSA_Requested__c.isAccessible() && Schema.sObjectType.Opportunity.fields.Multiple_Stands_Approval__c.isAccessible()) {
                        lstOpportunity = [select id , Payment_Schedules__c, Custom_Payment__c, Booth_Approval_Status__c, MSA_Requested__c, Multiple_Stands_Approval__c,Total_No_of_payment__c from Opportunity where Id in:setOppId];
                    } else {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error: Insufficient Access'));
                    }
                    
                    if (lstOpportunity.size() > 0) {
                        for (Opportunity opp : lstOpportunity) {
                            if(opp.Payment_Schedules__c || (opp.Custom_Payment__c && opp.Total_No_of_payment__c > 0)){
                                if (setStatus.contains('Approved')) {
                                    opp.Booth_Approval_Status__c = 'Approved';
                                    opp.MSA_Requested__c = false;
                                    opp.Multiple_Stands_Approval__c = true;
                                } 
                                if (setStatus.contains('Declined')) {
                                    opp.Booth_Approval_Status__c = 'Declined';
                                    opp.MSA_Requested__c = false;
                                }
                            } 
                        }
                        update lstOpportunity ;
                    }
                }
            }
        }
    }
}