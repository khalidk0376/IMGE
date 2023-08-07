/**
* Project:     Informa Markets
* Date:        Dec, 6 2019
* Created By:  Avinash Shukla
* Test Class:  Opp_Handler_WorkOrder_Test(97%)
* *************************************************************************
* @description This is Handler for Opportunity Trigger. It is used mainly for Automation of work order creation and its line items insertion/ updation.
* *************************************************************************
*/
public without sharing class Opp_Handler_WorkOrder {
    /**
     * @description Perform all Operations on Work order/ work order line items/ email invocations related to work order object and its line items records.
     * @param oppNewList New Opportunity List
     * @param oppOldList Old Opportunity List
     * @param oppNewMap  New Opportunity Map
     * @param oppOldMap  Old Opportunity Map
     * @param isAfter    Trigger Event
     * @param isBefore   Trigger Event
     * @param isInsert   Trigger Event
     * @param isUpdate   Trigger Event
     * @param mapOpportunity Additional map parameter to perform action after opportunity is updated.
     */
    public static void workOrderAutomation(List<opportunity> oppNewList, List<opportunity> oppOldList, Map<Id, Opportunity> oppNewMap, Map<Id, Opportunity> oppOldMap, Boolean isAfter, Boolean isBefore, Boolean isInsert, Boolean isUpdate, Map<Id, Opportunity> mapOpportunity) {
        try {
            System.debug('Entering ::: Oppportunity After Update ::: Invoking ::: workOrderAutomation Method from CLASS ::: Opp_Handler_WorkOrder');
            Map<id, Map<Id, Id>> wotIdVsopplist = new Map<id, Map<Id, Id>>( );
            Map<Id, Id> mapPrdVsWot = new Map<Id, Id>( );
            Map<Id, OpportunityLineItem> mapOLI = new Map<Id, OpportunityLineItem>( );
            Map<Id, Work_Order_Template__c> mapWOT = new Map<Id, Work_Order_Template__c>( );
            Map<Id, Id> mapuserIds = new Map<Id, Id>( );
            String workOwner;
            Id workOwnerId;

            if ( !mapOpportunity.isEmpty( ) ) {
                mapOLI = new Map<Id, OpportunityLineItem>([SELECT Id, Product2Id, Product2.Work_Order_Template__c, Product2.Name, Product2.Work_Order_Template__r.Name, OpportunityId, Opportunity.AccountId, Booth_Number__c, Booth_Pavilion__c, Show_In_Show__c, Booth_Type__c from OpportunityLineItem where opportunityid = : mapOpportunity.keySet( ) AND Product2.Work_Order_Template__c != NULL]);
                for ( OpportunityLineItem oli : mapOLI.values() ) {
                    if ( wotIdVsopplist.containskey(oli.Product2.Work_Order_Template__c ) ) {
                        if ( !wotIdVsopplist.get( oli.Product2.Work_Order_Template__c ).containskey( oli.OpportunityId ) ) { wotIdVsopplist.get( oli.Product2.Work_Order_Template__c ).put( oli.OpportunityId, oli.Opportunity.AccountId );}
                    } else {
                        map<Id, Id> templist = new map<Id, Id>();
                        templist.put(oli.OpportunityId, oli.Opportunity.AccountId);
                        wotIdVsopplist.put(oli.Product2.Work_Order_Template__c, templist);
                    }
                    mapPrdVsWot.put(oli.Product2Id, oli.Product2.Work_Order_Template__c);
                }
            }
            /**
             * Variable declaration to get list of records to be inserted/ updated after the opportunity functionality is done.
             */
            map<integer, list<WorkOrder_Team__c>> locTeamVsteam = new map<integer, list<WorkOrder_Team__c>>();
            map<integer, list<WorkOrderLineItem>> locVswoli = new map<integer, list<WorkOrderLineItem>>();
            map<integer, WorkOrder> locVswo = new map<integer, WorkOrder>();
            map<Id, List<String>> oppIdVsEmail = new map<Id, List<String>>();
            integer loc = 1;
            //
            if (!mapPrdVsWot.isEmpty()) {
                mapWOT = new Map<Id, Work_Order_Template__c>( [select id , Name, (select Name, Work_Order_Owner__c, Notify_User__c, Work_Order__c, Team_Member__c, Work_Order_Template__c, Team_Roles__c, Team_Member__r.Email, Team_Member__r.Name from Workspace_Teams__r), (select id, Name, Work_Order_Template__c, Department__c, Document_Link__c, Description__c from Work_Order_Tasks__r) from Work_Order_Template__c  where Id = :mapPrdVsWot.values()] );
                Map<String, Id> mapWOVsQLI = new Map<String, Id>();
                for (WorkOrder wo : [SELECT Opportunity_Product_Id__c, Product_Name__c FROM WorkOrder WHERE Opportunity__c IN: mapOpportunity.keySet()]) {
                    mapWOVsQLI.put(wo.Opportunity_Product_Id__c, Wo.Product_Name__c);
                }

                if (!mapWOT.isEmpty()) {

                    for (Id idOLI : mapOLI.KeySet()) {
                        If(!mapWOVsQLI.containsKey(idOLI) && mapWOVsQLI.get(idOLI) != mapOLI.get(idOLI).Product2Id) {
                            WorkOrder wo = new WorkOrder();
                            wo.Work_Order_Name__c = mapOLI.get(idOLI).Product2.Work_Order_Template__r.Name;
                            wo.Opportunity__c = mapOLI.get(idOLI).OpportunityId;
                            wo.AccountId = mapOLI.get(idOLI).Opportunity.AccountId;
                            wo.Work_Order_Template__c = mapOLI.get(idOLI).Product2.Work_Order_Template__c;
                            wo.Event_SeriesL__c = mapOpportunity.get(mapOLI.get(idOLI).OpportunityId).Event_Series__c;
                            wo.Event_Edition__c = mapOpportunity.get(mapOLI.get(idOLI).OpportunityId).EventEdition__c;
                            wo.Product_Name__c = mapOLI.get(idOLI).Product2Id;
                            wo.Opportunity_Product_Id__c = idOLI;
                            wo.Booth_Number__c = mapOLI.get(idOLI).Booth_Number__c;
                            wo.Booth_Pavilion__c = mapOLI.get(idOLI).Booth_Pavilion__c;
                            wo.Booth_Show_In_Show__c = mapOLI.get(idOLI).Show_In_Show__c;
                            wo.Booth_Type__c = mapOLI.get(idOLI).Booth_Type__c;
                            locVswo.put(loc, wo);

                            for (Work_Order_Task__c wsTask : mapWOT.get( mapOLI.get( idOLI ).Product2.Work_Order_Template__c ).Work_Order_Tasks__r ) {
                                WorkOrderLineItem woliNew = new WorkOrderLineItem();
                                woliNew.Task_Name__c      = wsTask.Name;
                                woliNew.Department__c     = wsTask.Department__c;    //GGCW-1547
                                woliNew.Document_Link__c  = wsTask.Document_Link__c; //GGCW-2048
                                woliNew.Description       = wsTask.Description__c;   //GGCW-2048
                                if (locVswoli.containsKey(loc)) { locVswoli.get(loc).add(woliNew); }
                                else {
                                    list<WorkOrderLineItem> tempList = new list<WorkOrderLineItem>();
                                    tempList.add(woliNew);
                                    locVswoli.put(loc, tempList);
                                }
                            }

                            for (WorkOrder_Team__c userobj : mapWOT.get(mapOLI.get(idOLI).Product2.Work_Order_Template__c).Workspace_Teams__r) {
                                if (userobj.Work_Order_Owner__c == true) {
                                    workOwner  = userobj.Team_Member__r.Name;
                                    workOwnerId = userobj.Team_Member__r.Id;
                                    mapuserIds.put(userobj.Work_Order_Template__c, workOwnerId);
                                }

                                if (oppIdVsEmail.containsKey(mapOLI.get(idOLI).OpportunityId) && userobj.Notify_User__c == true) {oppIdVsEmail.get(mapOLI.get(idOLI).OpportunityId).add(userobj.Team_Member__r.Email);}
                                else {
                                    list<string> tempList = new list<string>();
                                    if (userobj.Notify_User__c == true) {
                                        tempList.add(userobj.Team_Member__r.Email);
                                        oppIdVsEmail.put(mapOLI.get(idOLI).OpportunityId, tempList);
                                    }
                                }

                                WorkOrder_Team__c woTeam = new WorkOrder_Team__c();
                                woTeam.Notify_User__c = userobj.Notify_User__c;
                                woTeam.Team_Member__c = userobj.Team_Member__c;
                                woTeam.Team_Roles__c = userobj.Team_Roles__c;
                                if (locTeamVsteam.containsKey(loc)) {locTeamVsteam.get(loc).add(woTeam);}
                                else {
                                    list<WorkOrder_Team__c> tempList = new list<WorkOrder_Team__c>();
                                    tempList.add(woTeam);
                                    locTeamVsteam.put(loc, tempList);
                                }
                            }
                            loc++;
                        }
                    }
                }
            }
            //Insertion of Work Order
            if (!locVswo.isEmpty()) {
                insert locVswo.values();
                List<WorkOrder> wolisttoUpdate = new list<WorkOrder>();
                if (!mapuserIds.isEmpty()) {
                    for (WorkOrder wotemp : locVswo.values()) {
                        for (Id wotemplate : mapuserIds.Keyset()) {
                            if (wotemp.Work_Order_Template__c == wotemplate) {
                                wotemp.OwnerID = mapuserIds.get(wotemplate);
                                wolisttoUpdate.add(wotemp);
                            }
                        }
                    }
                    update wolisttoUpdate;

                    List<Messaging.SingleEmailMessage> lstSingleEmailMessage = new List<Messaging.SingleEmailMessage>();
                    string baseUrl = URL.getSalesforceBaseUrl().toExternalForm();
                    EmailTemplate emailTemplate = [SELECT Id, Subject, HtmlValue, Body FROM EmailTemplate WHERE Name = 'Informa Template2 For sendEmailCloseOpportunity'];

                    OrgWideEmailAddress[]  oWideEmailAdrs = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress WHERE DisplayName = 'GE Exhibitions' LIMIT 1];
                    for (Id oppid : oppIdVsEmail.keyset()) {

                        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                        List<String> toAddresses = new list<string>();
                        toAddresses = oppIdVsEmail.get(oppId);
                        String subject = 'Created Work Order';
                        email.setSubject(subject);
                        email.setToAddresses( toAddresses );
                        String htmlBody = emailTemplate.HtmlValue;
                        htmlBody = htmlBody.replace(' {!user}', '');
                        htmlBody = htmlBody.replace('{oppName}', mapOpportunity.get(oppId).Name);

                        for (WorkOrder idofWo : locVswo.values()) {
                            htmlBody = htmlBody.replace('{!link}', baseUrl + '/' + idofWo.id);
                        }

                        String plainBody = emailTemplate.Body;
                        plainBody = plainBody.replace(' {!user}', '');
                        plainBody = plainBody.replace('{oppName}', mapOpportunity.get(oppId).Name);
                        for (WorkOrder idofWo : locVswo.values()) {
                            plainBody = plainBody.replace('{!link}', baseUrl + '/' + idofWo.id);
                        }
                        email.setHtmlBody(htmlBody);
                        email.setSaveAsActivity(false);
                        email.setPlainTextBody(plainBody);
                        email.setOrgWideEmailAddressId(oWideEmailAdrs[0].id);

                        lstSingleEmailMessage.add(email);
                    }
                }

                //Insertion of Work Order Line Item
                list<WorkOrderLineItem> workOrderLineItemToInsert = new list<WorkOrderLineItem>();
                list<WorkOrder_Team__c> workOrderTeamToInsert = new list<WorkOrder_Team__c>();
                for (integer i = 1 ; i <= locVswo.size(); i++) {
                    if (locVswoli.get(i) != null && !locVswoli.get(i).isEmpty()) {
                        for (WorkOrderLineItem woli : locVswoli.get(i)) {
                            woli.WorkOrderId = locVswo.get(i).id;
                            WorkOrderLineItemToInsert.add(woli);
                        }
                    }
                    if (locTeamVsteam.get(i) != null && !locTeamVsteam.get(i).isEmpty()) {
                        for (WorkOrder_Team__c woteam : locTeamVsteam.get(i)) {
                            woteam.Work_Order__c = locVswo.get(i).id;
                            WorkOrderTeamToInsert.add(woteam);
                        }
                    }
                }
                insert WorkOrderLineItemToInsert;
                insert WorkOrderTeamToInsert;
            }
        } catch (exception exe) {
            Utility.logError(exe.getMessage(), exe.getCause(), exe.getLineNumber(), exe.getStackTraceString(), 'Opp_Handler_WorkOrder Class for "workOrderAutomation" method after Update functionality on Opportunity');
        }
    }
    /**
     * @description This method is used to update the status of all the related WOs and WOLIs to cancelled once the opportunity is Closed Lost
     * @param newOpportunities New list of opportunity
     * @param oldOpportunities Map of old values of the opportunity
     */
    public static void workOrderAutomationAfterCL(List <Opportunity> newOpportunities, Map <id, Opportunity> oldOpportunities) {
        System.debug('Entering ::: Oppportunity After Update ::: Invoking ::: workOrderAutomationAfterCL Method from CLASS ::: Opp_Handler_WorkOrder');
        List <Id> updateOpportunitiesId          = new List <Id> ( );
        List <WorkOrder> updateWorkOrders        = new List <WorkOrder> ( );
        List <WorkOrderLineItem> updateLineItems = new List <WorkOrderLineItem> ( );

        for ( Opportunity opp : newOpportunities ) {
            if ( opp.StageName == 'Closed Lost' && oldOpportunities.get( opp.Id ).StageName != 'Closed Lost' ) {
                updateOpportunitiesId.add( opp.id );
            }
        }
        if ( updateOpportunitiesId.size( ) > 0 ) {
            for ( WorkOrder workorders : [ SELECT Id, Status, ( SELECT Id, Status FROM WorkOrderLineItems ) FROM WorkOrder WHERE Opportunity__c IN : updateOpportunitiesId ] ) {
                WorkOrder workorder = new WorkOrder( Id = workorders.Id, Status = 'Canceled' );
                updateWorkOrders.add( workorder );
                for ( WorkOrderLineItem lineItem : workorders.WorkOrderLineItems ) {
                    WorkOrderLineItem workOrderLineItem = new WorkOrderLineItem( Id = lineItem.Id, Status = 'Canceled' );
                    updateLineItems.add( workOrderLineItem );
                }
            }
        }
        if ( updateWorkOrders.size( ) > 0 )  { update updateWorkOrders; }
        if ( updateLineItems.size( ) > 0 )  { update updateLineItems; }
    }
}