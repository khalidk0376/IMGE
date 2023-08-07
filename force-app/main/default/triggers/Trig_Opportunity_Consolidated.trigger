/**
* Project:     Informa Markets
* Last Modified Date:        Nov, 29 2019, [Aishwarya 25 Aug 2020 BK-6906]
* Created By:  Avinash Shukla
* Test Class:  Any of the following test classes can cover the trigger to 100% coverage.
* Coverage:    100%(Opp_Handler_Opportunity_Test,Opp_Handler_Expocad_Test,Opp_Handler_Account_Test,Opp_Handler_Quote_Test)
* *************************************************************************
* @description This is consolidated trigger on Opportunity object and is being created as to optimise the existing trigger and remove any salesforce governor limit
*              violation. This trigger executes on all five events as "before insert, before update, after insert, after update, after delete". This trigger is to
*              be referenced in future for executing any automation on opportunity object. Any other triggers functionality on opportunity must be merged/ added on this trigger.
***************************************************************************
* Handlers and there functionality.
***************************************************************************
Handler Name ::::::::       Method Name ::::::                      Description                                                                                                                                                             Test Class and Coverage::::::
Opp_Handler_WorkOrder       workOrderAutomation                     All the creation/updation of WOs and WOLIs are done from this method. INVOKED from Opp_Handler_Opportunity's relatedOpportunityAutomation Method                        Opp_Handler_WorkOrder_Test  97%
workOrderAutomationAfterCL                                          Cancelling of WOs and WOLIs are done from this method. INVOKED from Opp_Handler_Opportunity's relatedOpportunityAutomation Method                                       Opp_Handler_WorkOrder_Test  97%
Opp_Handler_ContactRoles    contactRolesAutomation                  All the process of creation/ updation of opportunity contact roles are done from this method. This also includes creation/ updation of Contact Event Edition Mapping.   Opp_Handler_ContactRoles_Test   88%
Opp_Handler_Opportunity2    opportunityAutomationPaymentSchedule    All processes related to Opportunity prepopulation of payment schedule etc. Based on custom payment checkbox.                                                           Opp_Handler_Opportunity2_Test   85%
Opp_Handler_Opportunity     opportunityAutomation                   All processes related to Opportunity prepopulation values like event edition, pricebook, event series etc.                                                              Opp_Handler_Opportunity_Test    88%
Opp_Handler_Expocad         expocadAutomation                       All processes related to expocad renting, unrenting, holding of booths are performed from this handler/method.                                                          Opp_Handler_Expocad_Test    100%
Opp_Handler_Account         accountAutomation                       All processes related to account for updation of buisness unit/ brand etc are performed from this handler/method                                                        Opp_Handler_Account_Test    100%
Opp_Handler_Quote           quoteAutomation                         All processes related to quote for updation of statuses, billing contacts etc are performed from this handler/method                                                    Opp_Handler_Quote_Test  95%
*/

trigger Trig_Opportunity_Consolidated on Opportunity (before insert, before update, after insert, after update, after delete) {
    System.debug('Entering Trig_Opportunity_Consolidated Trigger');
    if ( !Utility.isRebookInProcess) {
        if (Trigger.isBefore) {
            /**
             * Execute all Before Insert automation.
             */
            If(Trigger.isInsert && !Utility.triggerBIExecuted) {
                System.debug('Entering Before Insert Event Trigger');
                Utility.triggerBIExecuted = true;
                Opp_Handler_Opportunity.opportunityAutomation(trigger.new, trigger.old, trigger.newMap, trigger.oldMap, trigger.isAfter, trigger.isBefore, trigger.isInsert, trigger.isUpdate);
            }
            /**
             * Execute all Before Update automation.
             */
            If(Trigger.isUpdate && !Utility.triggerBUExecuted || Trigger.isUpdate && Test.isRunningTest()) {
                System.debug('Entering Before Update Event Trigger');
                Utility.triggerBUExecuted = true;
                
                Opp_Handler_Opportunity.opportunityAutomation(trigger.new, trigger.old, trigger.newMap, trigger.oldMap, trigger.isAfter, trigger.isBefore, trigger.isInsert, trigger.isUpdate);
                /** Account Team Member Creation while opportunity creation and also create account team member after opportunity owner changed */
                AddAccountTeamMember_Trg.addTeamMember(trigger.new, trigger.oldMap, trigger.isAfter, trigger.isBefore, trigger.isInsert, trigger.isUpdate);
                //Added by Ansh for GECI-654
                OppCustomPaymentHandler.customopportunityPaymentSchedule(trigger.new, trigger.oldMap);
                /**
                 * Calling another method to prepopulate/input values on opportunity for payment schedule etc. We have seperated this from Opp_Handler_Opportunity as SCA violation might come due too long apex class. This is to execute only on Update Event.
                 */
                Opp_Handler_Opportunity2.opportunityAutomationPaymentSchedule(trigger.new, trigger.oldMap);
                // Added by Palla Kishore for the ticket BK-20202.
                Opp_Handler_Opportunity.updateCloseDate(trigger.new, trigger.old, trigger.newMap, trigger.oldMap, trigger.isAfter, trigger.isBefore, trigger.isInsert, trigger.isUpdate);
            }
        }
        if (Trigger.isAfter) {
            /**
             * Execute all After Insert automation.
            */
            If(Trigger.isInsert) {
                System.debug('Entering After Insert Event Trigger');
                if (!Utility.triggerAIExecuted) {
                    /**
                    * triggerExecuted ::: Variable set to true, to avoid execution of the trigger in the same transaction.
                    */
                    Utility.triggerAIExecuted = true;
                    /**
                    * Execute related Account object updation.
                    */
                    Opp_Handler_Account.accountAutomation(trigger.new, trigger.old, trigger.newMap, trigger.oldMap, trigger.isAfter, trigger.isBefore, trigger.isInsert, trigger.isUpdate);
                    
                    /** Account Team Member Creation while opportunity creation and also create account team member after opportunity owner changed */
                    AddAccountTeamMember_Trg.addTeamMember(trigger.new, trigger.oldMap, trigger.isAfter, trigger.isBefore, trigger.isInsert, trigger.isUpdate);
                    
                    /**
                    * Execute related Contact Role, Contact Event Edition Mapping, Account Partner object updation.
                    */
                    Opp_Handler_ContactRoles.contactRolesAutomation(trigger.new, trigger.old, trigger.newMap, trigger.oldMap, trigger.isAfter, trigger.isBefore, trigger.isInsert, trigger.isUpdate);
                }
            }
            /**
             * Execute all After Update automation.
             */
            If(Trigger.isUpdate) {
                System.debug('Entering After Update Event Trigger');
                if (!Utility.triggerAUExecuted) {
                    /**
                    * triggerExecuted ::: Variable set to true, to avoid execution of the trigger in the same transaction.
                    */
                    Utility.triggerAUExecuted = true;

                    ProfilePackageSettingTriggerHandler.createOrUpdateUserPkg(trigger.newMap,trigger.oldMap,null,null);
                    /**
                    * Execute expocad object updation. 
                    */
                    Opp_Handler_Expocad.expocadAutomation(trigger.new, trigger.old, trigger.newMap, trigger.oldMap, trigger.isAfter, trigger.isBefore, trigger.isInsert, trigger.isUpdate);
                    /**
                    * Execute related opportunity object updation.
                    */
                    Opp_Handler_Opportunity.relatedOpportunityAutomation(trigger.new, trigger.old, trigger.newMap, trigger.oldMap, trigger.isAfter, trigger.isBefore, trigger.isInsert, trigger.isUpdate);
                    /**
                    * Execute related opportunity object updation.
                    */
                    Opp_Handler_Quote.quoteAutomation(trigger.new, trigger.old, trigger.newMap, trigger.oldMap, trigger.isAfter, trigger.isBefore, trigger.isInsert, trigger.isUpdate);
                    /**
                    * Execute related Account object updation.
                    */
                    Opp_Handler_Account.accountAutomation(trigger.new, trigger.old, trigger.newMap, trigger.oldMap, trigger.isAfter, trigger.isBefore, trigger.isInsert, trigger.isUpdate);
                    /**
                    * Execute related Contact Role, Contact Event Edition Mapping, Account Partner object updation.
                    */
                    Opp_Handler_ContactRoles.contactRolesAutomation(trigger.new, trigger.old, trigger.newMap, trigger.oldMap, trigger.isAfter, trigger.isBefore, trigger.isInsert, trigger.isUpdate);
                }
            }
        }
    }
    if(trigger.isUpdate && trigger.isBefore){
        /**
           * Execute for status__c field changing.
             */
        Opp_Handler_Opportunity.ChangedStatusfield(trigger.new, trigger.old,trigger.newMap, trigger.oldMap);  
   }
}