/**
 * File:        Opp_Handler_Opportunity2.cls
 * Project:     GAP
 * Date:        26-Dec-2019
 * Created By:  Avinash Shukla
 * Modified By: Shiv Raghav Sharma (Bk-3487)
 * Test Class:  Opp_Handler_Opportunity2_Test(87%)
 * *************************************************************************
 * Description: The class is clone of UpdateQuoteStatus, using naming conventions/SCA violation removal.
 * Modified by Avinash Shukla for BK-3502 , Added condition for allowing due date population when event edition start date is null.
 * *************************************************************************
 */
public without sharing class Opp_Handler_Opportunity2 {
    /**
     * @description Prepopulate opportunity fields
     * @param newOppLst New Opportunity List
     * @param oldOppMap Old Opportunity Map
     */
    public static void opportunityAutomationPaymentSchedule( List<Opportunity> newOppLst, Map<id, Opportunity> oldOppMap ) {
        System.debug('CAlling Payment Schedule');
        try {
            decimal dPrice = 0.0;
            decimal dAmount = 0.0;
            decimal dtotalAmt = 0.0;
            Map < Integer, Decimal > percentageList = new Map < Integer, Decimal > ();
            set<Id> edIds = new Set<Id>();        
            for(Opportunity opp : newOppLst){
                if(String.isNotBlank(opp.EventEdition__c))
                {
                    edIds.add(opp.EventEdition__c);
                }
            }
            Map<Id,Event_Edition__c> mapOfed = new Map<Id,Event_Edition__c>([SELECT Id,Enabled_for_IOM_Billing__c FROM Event_Edition__c WHERE Id in:edIds]);

            for ( Opportunity opp : newOppLst ) {
                if(mapOfed.containsKey(opp.EventEdition__c) 
                && mapOfed.get(opp.EventEdition__c).Enabled_for_IOM_Billing__c == false){
                    Boolean isEventEditionStartDateNull = false;
                    isEventEditionStartDateNull = opp.Event_Edition_Start_Date__c == NULL ? true : false;
                    Opportunity oldOpp = oldOppMap.get( opp.Id );
                    if ( opp.Custom_Payment__c == false) {
                        opp.Total_No_of_payment__c        = null; opp.Start_Date__c                 = null; opp.Milestone_1_Amount__c         = null;
                        opp.Milestone_1_Delivery_Date__c  = null; opp.Milestone_2_Amount__c         = null; opp.Milestone_2_Delivery_Date__c  = null;
                        opp.Milestone_3_Amount__c         = null; opp.Milestone_3_Delivery_Date__c  = null; opp.Milestone_4_Amount__c         = null;
                        opp.Milestone_4_Delivery_Date__c  = null; opp.Milestone_5_Amount__c         = null; opp.Milestone_5_Delivery_Date__c  = null;
                        opp.Milestone_6_Amount__c         = null; opp.Milestone_6_Delivery_Date__c  = null; opp.Milestone_7_Amount__c         = null;
                        opp.Milestone_7_Delivery_Date__c  = null; opp.Milestone_8_Amount__c         = null; opp.Milestone_8_Delivery_Date__c  = null;
                        opp.Milestone_9_Amount__c         = null; opp.Milestone_9_Delivery_Date__c  = null; opp.Milestone_10_Amount__c        = null;
                        opp.Milestone_10_Delivery_Date__c = null; opp.Milestone_11_Amount__c        = null; opp.Milestone_11_Delivery_Date__c = null;
                        opp.Milestone_12_Amount__c        = null; opp.Milestone_12_Delivery_Date__c = null; opp.Total_Milestone_Amount__c     = null;
                        opp.Total_Milestone_Dates__c      = null;
                        opp.Milestone_1_Percent__c = null;
                        opp.Milestone_2_Percent__c = null;
                        opp.Milestone_3_Percent__c = null;
                        opp.Milestone_4_Percent__c = null;
                        opp.Milestone_5_Percent__c = null;
                        opp.Milestone_6_Percent__c = null;
                        opp.Milestone_7_Percent__c = null;
                        opp.Milestone_8_Percent__c = null;
                        opp.Milestone_9_Percent__c = null;
                        opp.Milestone_10_Percent__c = null;
                        opp.Milestone_11_Percent__c = null;
                        opp.Milestone_12_Percent__c = null;
                    } else if (opp.Total_No_of_payment__c != null && opp.Total_No_of_payment__c == 0) { opp.addError(system.label.Zero_total_number_of_payment);
                    } else if ( opp.Custom_Payment__c &&  opp.Start_Date__c != null && opp.Total_No_of_payment__c != null && opp.Total_No_of_payment__c != 0 && opp.Amount != null && opp.Amount != 0) {
                        Date dstartdate = opp.Start_Date__c;
                        //Bk-3487
                        Integer invoiceTobeIssueBefore = 0;
                        if (opp.Invoice_to_be_issued_before_in_Days__c != Null) {
                            invoiceTobeIssueBefore = opp.Invoice_to_be_issued_before_in_Days__c.intValue();
                        }

                        Date dEventStartDate = opp.Event_Edition_Start_Date__c ;
                        dPrice = (opp.Amount) / (opp.Total_No_of_payment__c);
                        Exempted_Profiles_from_a_VR__c exemptedprofile = Exempted_Profiles_from_a_VR__c.getInstance();
                        if ( ( opp.Total_No_of_payment__c == 1 ) && ( oldOpp.Total_No_of_payment__c != 1 ) ) {
                            if (((dstartdate < dEventStartDate) && !exemptedprofile.Exempt_Profile__c) || (exemptedprofile.Exempt_Profile__c) || (isEventEditionStartDateNull)) {
                                opp.Milestone_1_Delivery_Date__c = dstartdate;
                                opp.Milestone_1_Amount__c = dPrice;
                                opp.Milestone_2_Amount__c        = 0;                                                          opp.Milestone_2_Delivery_Date__c = null;
                                opp.Milestone_3_Amount__c        = 0;                                                          opp.Milestone_3_Delivery_Date__c = null;
                                opp.Milestone_4_Amount__c        = 0;                                                          opp.Milestone_4_Delivery_Date__c = null;
                                opp.Milestone_5_Amount__c        = 0;                                                          opp.Milestone_5_Delivery_Date__c = null;
                                opp.Milestone_6_Amount__c        = 0;                                                          opp.Milestone_6_Delivery_Date__c = null;
                                opp.Milestone_7_Amount__c        = 0;                                                          opp.Milestone_7_Delivery_Date__c = null;
                                opp.Milestone_8_Amount__c        = 0;                                                          opp.Milestone_8_Delivery_Date__c = null;
                                opp.Milestone_9_Amount__c        = 0;                                                          opp.Milestone_9_Delivery_Date__c = null;
                                opp.Milestone_10_Amount__c        = 0;                                                         opp.Milestone_10_Delivery_Date__c = null;
                                opp.Milestone_11_Amount__c        = 0;                                                         opp.Milestone_11_Delivery_Date__c = null;
                                opp.Milestone_12_Amount__c        = 0;                                                         opp.Milestone_12_Delivery_Date__c = null;
                            } else { opp.addError('Billing 1 date should not go past the Event Start Date.');
                            }
                        } else if ( ( opp.Total_No_of_payment__c == 2 ) && ( oldOpp.Total_No_of_payment__c != 2 ) ) {
                            System.debug('Test Rajesh : ' + dstartdate + ' Event Date ' +  dEventStartDate + 'Bill Date 1' +  opp.Milestone_2_Delivery_Date__c  + 'Test Second' + opp.Milestone_1_Delivery_Date__c  + 'teststtstss :' + dstartdate.addmonths(1) );
                            if (((dstartdate < dEventStartDate) && !exemptedprofile.Exempt_Profile__c) || (exemptedprofile.Exempt_Profile__c) || (isEventEditionStartDateNull)) {
                                opp.Milestone_1_Amount__c        = dPrice.round( System.RoundingMode.DOWN );
                                opp.Milestone_1_Delivery_Date__c = dstartdate;
                                if (((dstartdate.addmonths(1) < dEventStartDate) && !exemptedprofile.Exempt_Profile__c) || (exemptedprofile.Exempt_Profile__c) || (isEventEditionStartDateNull)) {
                                    opp.Milestone_2_Delivery_Date__c = dstartdate.addDays(invoiceTobeIssueBefore);
                                    opp.Milestone_2_Amount__c        = ( opp.Amount - ( dPrice.round( System.RoundingMode.DOWN ) ) );
                                    opp.Milestone_3_Amount__c        = 0;                                                          opp.Milestone_3_Delivery_Date__c = null;
                                    opp.Milestone_4_Amount__c        = 0;                                                          opp.Milestone_4_Delivery_Date__c = null;
                                    opp.Milestone_5_Amount__c        = 0;                                                          opp.Milestone_5_Delivery_Date__c = null;
                                    opp.Milestone_6_Amount__c        = 0;                                                          opp.Milestone_6_Delivery_Date__c = null;
                                    opp.Milestone_7_Amount__c        = 0;                                                          opp.Milestone_7_Delivery_Date__c = null;
                                    opp.Milestone_8_Amount__c        = 0;                                                          opp.Milestone_8_Delivery_Date__c = null;
                                    opp.Milestone_9_Amount__c        = 0;                                                          opp.Milestone_9_Delivery_Date__c = null;
                                    opp.Milestone_10_Amount__c        = 0;                                                         opp.Milestone_10_Delivery_Date__c = null;
                                    opp.Milestone_11_Amount__c        = 0;                                                         opp.Milestone_11_Delivery_Date__c = null;
                                    opp.Milestone_12_Amount__c        = 0;                                                         opp.Milestone_12_Delivery_Date__c = null;
                                } else { opp.addError('Billing 2 date should not go past the Event Start Date.');
                                }
                            } else { opp.addError('Billing 2 date should not go past the Event Start Date.');
                            }

                        } else if ( ( opp.Total_No_of_payment__c == 3 ) && ( oldOpp.Total_No_of_payment__c != 3 ) ) {

                            if (((dstartdate < dEventStartDate) && !exemptedprofile.Exempt_Profile__c) || (exemptedprofile.Exempt_Profile__c) || (isEventEditionStartDateNull)) {
                                opp.Milestone_1_Amount__c        = dPrice.round(System.RoundingMode.DOWN);
                                opp.Milestone_2_Amount__c        = dPrice.round(System.RoundingMode.DOWN);
                                opp.Milestone_1_Delivery_Date__c = dstartdate;
                                opp.Milestone_2_Delivery_Date__c = dstartdate.addDays(invoiceTobeIssueBefore);
                                if (((dstartdate.addmonths(2) < dEventStartDate) && !exemptedprofile.Exempt_Profile__c) || (exemptedprofile.Exempt_Profile__c) || (isEventEditionStartDateNull)) {
                                    opp.Milestone_3_Delivery_Date__c = opp.Milestone_2_Delivery_Date__c.addDays(invoiceTobeIssueBefore);
                                    opp.Milestone_3_Amount__c        = (opp.Amount - (dPrice.round(System.RoundingMode.DOWN) * 2));
                                    opp.Milestone_4_Amount__c        = 0;                                                          opp.Milestone_4_Delivery_Date__c = null;
                                    opp.Milestone_5_Amount__c        = 0;                                                          opp.Milestone_5_Delivery_Date__c = null;
                                    opp.Milestone_6_Amount__c        = 0;                                                          opp.Milestone_6_Delivery_Date__c = null;
                                    opp.Milestone_7_Amount__c        = 0;                                                          opp.Milestone_7_Delivery_Date__c = null;
                                    opp.Milestone_8_Amount__c        = 0;                                                          opp.Milestone_8_Delivery_Date__c = null;
                                    opp.Milestone_9_Amount__c        = 0;                                                          opp.Milestone_9_Delivery_Date__c = null;
                                    opp.Milestone_10_Amount__c        = 0;                                                         opp.Milestone_10_Delivery_Date__c = null;
                                    opp.Milestone_11_Amount__c        = 0;                                                         opp.Milestone_11_Delivery_Date__c = null;
                                    opp.Milestone_12_Amount__c        = 0;                                                         opp.Milestone_12_Delivery_Date__c = null;
                                } else { opp.addError('Billing 3 date should not go past the Event Start Date.');
                                }
                            } else { opp.addError('Billing 3 date should not go past the Event Start Date.');
                            }

                        } else if ( ( opp.Total_No_of_payment__c == 4 ) && ( oldOpp.Total_No_of_payment__c != 4 ) ) {
                            if (((dstartdate < dEventStartDate) && !exemptedprofile.Exempt_Profile__c) || (exemptedprofile.Exempt_Profile__c) || (isEventEditionStartDateNull)) {
                                opp.Milestone_1_Amount__c        = dPrice.round(System.RoundingMode.DOWN);
                                opp.Milestone_2_Amount__c        = dPrice.round(System.RoundingMode.DOWN);
                                opp.Milestone_3_Amount__c        = dPrice.round(System.RoundingMode.DOWN);
                                opp.Milestone_1_Delivery_Date__c = dstartdate;
                                opp.Milestone_2_Delivery_Date__c = opp.Milestone_1_Delivery_Date__c.addDays(invoiceTobeIssueBefore);
                                opp.Milestone_3_Delivery_Date__c = opp.Milestone_2_Delivery_Date__c.addDays(invoiceTobeIssueBefore);

                                if (((dstartdate.addmonths(3) < dEventStartDate) && !exemptedprofile.Exempt_Profile__c) || (exemptedprofile.Exempt_Profile__c) || (isEventEditionStartDateNull)) {
                                    opp.Milestone_4_Delivery_Date__c = opp.Milestone_3_Delivery_Date__c.addDays(invoiceTobeIssueBefore);
                                    opp.Milestone_4_Amount__c        = (opp.Amount - (dPrice.round(System.RoundingMode.DOWN) * 3));
                                    opp.Milestone_5_Amount__c        = 0;                                                          opp.Milestone_5_Delivery_Date__c = null;
                                    opp.Milestone_6_Amount__c        = 0;                                                          opp.Milestone_6_Delivery_Date__c = null;
                                    opp.Milestone_7_Amount__c        = 0;                                                          opp.Milestone_7_Delivery_Date__c = null;
                                    opp.Milestone_8_Amount__c        = 0;                                                          opp.Milestone_8_Delivery_Date__c = null;
                                    opp.Milestone_9_Amount__c        = 0;                                                          opp.Milestone_9_Delivery_Date__c = null;
                                    opp.Milestone_10_Amount__c        = 0;                                                         opp.Milestone_10_Delivery_Date__c = null;
                                    opp.Milestone_11_Amount__c        = 0;                                                         opp.Milestone_11_Delivery_Date__c = null;
                                    opp.Milestone_12_Amount__c        = 0;                                                         opp.Milestone_12_Delivery_Date__c = null;
                                } else { opp.addError('Billing 4 date should not go past the Event Start Date.');
                                }

                            } else { opp.addError('Billing 4 date should not go past the Event Start Date.');
                            }

                        } else if ( ( opp.Total_No_of_payment__c == 5 ) && ( oldOpp.Total_No_of_payment__c != 5 ) ) {
                            if (((dstartdate < dEventStartDate) && !exemptedprofile.Exempt_Profile__c) || (exemptedprofile.Exempt_Profile__c) || (isEventEditionStartDateNull)) {
                                opp.Milestone_1_Amount__c        = dPrice.round(System.RoundingMode.DOWN);
                                opp.Milestone_2_Amount__c        = dPrice.round(System.RoundingMode.DOWN);
                                opp.Milestone_3_Amount__c        = dPrice.round(System.RoundingMode.DOWN);
                                opp.Milestone_4_Amount__c        = dPrice.round(System.RoundingMode.DOWN);
                                opp.Milestone_5_Amount__c        = (opp.Amount - (dPrice.round(System.RoundingMode.DOWN) * 4));
                                opp.Milestone_1_Delivery_Date__c = dstartdate;
                                opp.Milestone_2_Delivery_Date__c = opp.Milestone_1_Delivery_Date__c.addDays(invoiceTobeIssueBefore);
                                opp.Milestone_3_Delivery_Date__c = opp.Milestone_2_Delivery_Date__c.addDays(invoiceTobeIssueBefore);
                                opp.Milestone_4_Delivery_Date__c = opp.Milestone_3_Delivery_Date__c.addDays(invoiceTobeIssueBefore);

                                if (((dstartdate.addmonths(4) < dEventStartDate) && !exemptedprofile.Exempt_Profile__c) || (exemptedprofile.Exempt_Profile__c) || (isEventEditionStartDateNull)) {
                                    opp.Milestone_5_Delivery_Date__c = opp.Milestone_4_Delivery_Date__c.addDays(invoiceTobeIssueBefore);
                                    opp.Milestone_6_Amount__c        = 0;                                                          opp.Milestone_6_Delivery_Date__c = null;
                                    opp.Milestone_7_Amount__c        = 0;                                                          opp.Milestone_7_Delivery_Date__c = null;
                                    opp.Milestone_8_Amount__c        = 0;                                                          opp.Milestone_8_Delivery_Date__c = null;
                                    opp.Milestone_9_Amount__c        = 0;                                                          opp.Milestone_9_Delivery_Date__c = null;
                                    opp.Milestone_10_Amount__c        = 0;                                                         opp.Milestone_10_Delivery_Date__c = null;
                                    opp.Milestone_11_Amount__c        = 0;                                                         opp.Milestone_11_Delivery_Date__c = null;
                                    opp.Milestone_12_Amount__c        = 0;                                                         opp.Milestone_12_Delivery_Date__c = null;
                                } else { opp.addError('Billing 5 date should not go past the Event Start Date.');
                                }

                            } else { opp.addError('Billing 5 date should not go past the Event Start Date.');
                            }

                        } else if ( ( opp.Total_No_of_payment__c == 6 ) && ( oldOpp.Total_No_of_payment__c != 6 ) ) {
                            if (((dstartdate < dEventStartDate) && !exemptedprofile.Exempt_Profile__c) || (exemptedprofile.Exempt_Profile__c) || (isEventEditionStartDateNull)) {
                                opp.Milestone_1_Amount__c        = dPrice.round(System.RoundingMode.DOWN);
                                opp.Milestone_2_Amount__c        = dPrice.round(System.RoundingMode.DOWN);
                                opp.Milestone_3_Amount__c        = dPrice.round(System.RoundingMode.DOWN);
                                opp.Milestone_4_Amount__c        = dPrice.round(System.RoundingMode.DOWN);
                                opp.Milestone_5_Amount__c        = dPrice.round(System.RoundingMode.DOWN);
                                opp.Milestone_1_Delivery_Date__c = dstartdate;
                                opp.Milestone_2_Delivery_Date__c = opp.Milestone_1_Delivery_Date__c.addDays(invoiceTobeIssueBefore);
                                opp.Milestone_3_Delivery_Date__c = opp.Milestone_2_Delivery_Date__c.addDays(invoiceTobeIssueBefore);
                                opp.Milestone_4_Delivery_Date__c = opp.Milestone_3_Delivery_Date__c.addDays(invoiceTobeIssueBefore);
                                opp.Milestone_5_Delivery_Date__c = opp.Milestone_4_Delivery_Date__c.addDays(invoiceTobeIssueBefore);

                                if (((dstartdate.addmonths(5) < dEventStartDate) && !exemptedprofile.Exempt_Profile__c) || (exemptedprofile.Exempt_Profile__c) || (isEventEditionStartDateNull)) {
                                    opp.Milestone_6_Delivery_Date__c = opp.Milestone_5_Delivery_Date__c.addDays(invoiceTobeIssueBefore);
                                    opp.Milestone_6_Amount__c        = (opp.Amount - (dPrice.round(System.RoundingMode.DOWN) * 5));
                                    opp.Milestone_7_Amount__c        = 0;                                                          opp.Milestone_7_Delivery_Date__c = null;
                                    opp.Milestone_8_Amount__c        = 0;                                                          opp.Milestone_8_Delivery_Date__c = null;
                                    opp.Milestone_9_Amount__c        = 0;                                                          opp.Milestone_9_Delivery_Date__c = null;
                                    opp.Milestone_10_Amount__c        = 0;                                                         opp.Milestone_10_Delivery_Date__c = null;
                                    opp.Milestone_11_Amount__c        = 0;                                                         opp.Milestone_11_Delivery_Date__c = null;
                                    opp.Milestone_12_Amount__c        = 0;                                                         opp.Milestone_12_Delivery_Date__c = null;
                                } else { opp.addError('Billing 6 date should not go past the Event Start Date.');
                                }


                            } else { opp.addError('Billing 6 date should not go past the Event Start Date.');
                            }


                        } else if ( ( opp.Total_No_of_payment__c == 7 ) && ( oldOpp.Total_No_of_payment__c != 7 ) ) {
                            if (((dstartdate < dEventStartDate) && !exemptedprofile.Exempt_Profile__c) || (exemptedprofile.Exempt_Profile__c) || (isEventEditionStartDateNull)) {
                                opp.Milestone_1_Amount__c        = dPrice.round(System.RoundingMode.DOWN);
                                opp.Milestone_2_Amount__c        = dPrice.round(System.RoundingMode.DOWN);
                                opp.Milestone_3_Amount__c        = dPrice.round(System.RoundingMode.DOWN);
                                opp.Milestone_4_Amount__c        = dPrice.round(System.RoundingMode.DOWN);
                                opp.Milestone_5_Amount__c        = dPrice.round(System.RoundingMode.DOWN);
                                opp.Milestone_6_Amount__c        = dPrice.round(System.RoundingMode.DOWN);

                                opp.Milestone_1_Delivery_Date__c = dstartdate;
                                opp.Milestone_2_Delivery_Date__c = opp.Milestone_1_Delivery_Date__c.addDays(invoiceTobeIssueBefore);
                                opp.Milestone_3_Delivery_Date__c = opp.Milestone_2_Delivery_Date__c.addDays(invoiceTobeIssueBefore);
                                opp.Milestone_4_Delivery_Date__c = opp.Milestone_3_Delivery_Date__c.addDays(invoiceTobeIssueBefore);
                                opp.Milestone_5_Delivery_Date__c = opp.Milestone_4_Delivery_Date__c.addDays(invoiceTobeIssueBefore);
                                opp.Milestone_6_Delivery_Date__c = opp.Milestone_5_Delivery_Date__c.addDays(invoiceTobeIssueBefore);

                                if (((dstartdate.addmonths(6) < dEventStartDate) && !exemptedprofile.Exempt_Profile__c) || (exemptedprofile.Exempt_Profile__c) || (isEventEditionStartDateNull)) {
                                    opp.Milestone_7_Delivery_Date__c = opp.Milestone_6_Delivery_Date__c.addDays(invoiceTobeIssueBefore);
                                    opp.Milestone_7_Amount__c        = (opp.Amount - (dPrice.round(System.RoundingMode.DOWN) * 6));
                                    opp.Milestone_8_Amount__c        = 0;                                                          opp.Milestone_8_Delivery_Date__c = null;
                                    opp.Milestone_9_Amount__c        = 0;                                                          opp.Milestone_9_Delivery_Date__c = null;
                                    opp.Milestone_10_Amount__c       = 0;                                                         opp.Milestone_10_Delivery_Date__c = null;
                                    opp.Milestone_11_Amount__c       = 0;                                                         opp.Milestone_11_Delivery_Date__c = null;
                                    opp.Milestone_12_Amount__c       = 0;                                                         opp.Milestone_12_Delivery_Date__c = null;
                                } else { opp.addError('Billing 7 date should not go past the Event Start Date.');
                                }

                            } else { opp.addError('Billing 7 date should not go past the Event Start Date.');
                            }

                        } else if ( ( opp.Total_No_of_payment__c == 8 ) && ( oldOpp.Total_No_of_payment__c != 8 ) ) {
                            if (((dstartdate < dEventStartDate) && !exemptedprofile.Exempt_Profile__c) || (exemptedprofile.Exempt_Profile__c) || (isEventEditionStartDateNull)) {
                                opp.Milestone_1_Amount__c        = dPrice.round(System.RoundingMode.DOWN);
                                opp.Milestone_2_Amount__c        = dPrice.round(System.RoundingMode.DOWN);
                                opp.Milestone_3_Amount__c        = dPrice.round(System.RoundingMode.DOWN);
                                opp.Milestone_4_Amount__c        = dPrice.round(System.RoundingMode.DOWN);
                                opp.Milestone_5_Amount__c        = dPrice.round(System.RoundingMode.DOWN);
                                opp.Milestone_6_Amount__c        = dPrice.round(System.RoundingMode.DOWN);
                                opp.Milestone_7_Amount__c        = dPrice.round(System.RoundingMode.DOWN);
                                opp.Milestone_1_Delivery_Date__c = dstartdate;
                                opp.Milestone_2_Delivery_Date__c = opp.Milestone_1_Delivery_Date__c.addDays(invoiceTobeIssueBefore);
                                opp.Milestone_3_Delivery_Date__c = opp.Milestone_2_Delivery_Date__c.addDays(invoiceTobeIssueBefore);
                                opp.Milestone_4_Delivery_Date__c = opp.Milestone_3_Delivery_Date__c.addDays(invoiceTobeIssueBefore);
                                opp.Milestone_5_Delivery_Date__c = opp.Milestone_4_Delivery_Date__c.addDays(invoiceTobeIssueBefore);
                                opp.Milestone_6_Delivery_Date__c = opp.Milestone_5_Delivery_Date__c.addDays(invoiceTobeIssueBefore);
                                opp.Milestone_7_Delivery_Date__c = opp.Milestone_6_Delivery_Date__c.addDays(invoiceTobeIssueBefore);

                                if (((dstartdate.addmonths(7) < dEventStartDate) && !exemptedprofile.Exempt_Profile__c) || (exemptedprofile.Exempt_Profile__c) || (isEventEditionStartDateNull)) {
                                    opp.Milestone_8_Delivery_Date__c = opp.Milestone_7_Delivery_Date__c.addDays(invoiceTobeIssueBefore);
                                    opp.Milestone_8_Amount__c        = (opp.Amount - (dPrice.round(System.RoundingMode.DOWN) * 7));
                                    opp.Milestone_9_Amount__c        = 0;                                                          opp.Milestone_9_Delivery_Date__c = null;
                                    opp.Milestone_10_Amount__c        = 0;                                                         opp.Milestone_10_Delivery_Date__c = null;
                                    opp.Milestone_11_Amount__c        = 0;                                                         opp.Milestone_11_Delivery_Date__c = null;
                                    opp.Milestone_12_Amount__c        = 0;                                                         opp.Milestone_12_Delivery_Date__c = null;
                                } else { opp.addError('Billing 8 date should not go past the Event Start Date.');
                                }
                            } else { opp.addError('Billing 8 date should not go past the Event Start Date.');
                            }

                        } else if ( ( opp.Total_No_of_payment__c == 9 ) && ( oldOpp.Total_No_of_payment__c != 9 ) ) {
                            if (((dstartdate < dEventStartDate) && !exemptedprofile.Exempt_Profile__c) || (exemptedprofile.Exempt_Profile__c) || (isEventEditionStartDateNull)) {
                                opp.Milestone_1_Amount__c        = dPrice.round(System.RoundingMode.DOWN);                        opp.Milestone_2_Amount__c        = dPrice.round(System.RoundingMode.DOWN);
                                opp.Milestone_3_Amount__c        = dPrice.round(System.RoundingMode.DOWN);                        opp.Milestone_4_Amount__c        = dPrice.round(System.RoundingMode.DOWN);
                                opp.Milestone_5_Amount__c        = dPrice.round(System.RoundingMode.DOWN);                        opp.Milestone_6_Amount__c        = dPrice.round(System.RoundingMode.DOWN);
                                opp.Milestone_7_Amount__c        = dPrice.round(System.RoundingMode.DOWN);                        opp.Milestone_8_Amount__c        = dPrice.round(System.RoundingMode.DOWN);
                                opp.Milestone_1_Delivery_Date__c = dstartdate;
                                opp.Milestone_2_Delivery_Date__c = opp.Milestone_1_Delivery_Date__c.addDays(invoiceTobeIssueBefore);
                                opp.Milestone_3_Delivery_Date__c = opp.Milestone_2_Delivery_Date__c.addDays(invoiceTobeIssueBefore);
                                opp.Milestone_4_Delivery_Date__c = opp.Milestone_3_Delivery_Date__c.addDays(invoiceTobeIssueBefore);
                                opp.Milestone_5_Delivery_Date__c = opp.Milestone_4_Delivery_Date__c.addDays(invoiceTobeIssueBefore);
                                opp.Milestone_6_Delivery_Date__c = opp.Milestone_5_Delivery_Date__c.addDays(invoiceTobeIssueBefore);
                                opp.Milestone_7_Delivery_Date__c = opp.Milestone_6_Delivery_Date__c.addDays(invoiceTobeIssueBefore);

                                opp.Milestone_8_Delivery_Date__c = opp.Milestone_7_Delivery_Date__c.addDays(invoiceTobeIssueBefore);
                                if (((dstartdate.addmonths(8) < dEventStartDate) && !exemptedprofile.Exempt_Profile__c) || (exemptedprofile.Exempt_Profile__c) || (isEventEditionStartDateNull)) {
                                    opp.Milestone_9_Delivery_Date__c = opp.Milestone_8_Delivery_Date__c.addDays(invoiceTobeIssueBefore);
                                    opp.Milestone_9_Amount__c        = (opp.Amount - (dPrice.round(System.RoundingMode.DOWN) * 8));
                                    opp.Milestone_10_Amount__c        = 0;                                                         opp.Milestone_10_Delivery_Date__c = null;
                                    opp.Milestone_11_Amount__c        = 0;                                                         opp.Milestone_11_Delivery_Date__c = null;
                                    opp.Milestone_12_Amount__c        = 0;                                                         opp.Milestone_12_Delivery_Date__c = null;
                                } else { opp.addError('Billing 9 date should not go past the Event Start Date.');
                                }
                            } else { opp.addError('Billing 9 date should not go past the Event Start Date.');
                            }

                        } else if ( ( opp.Total_No_of_payment__c == 10 ) && ( oldOpp.Total_No_of_payment__c != 10 ) ) {
                            if (((dstartdate < dEventStartDate) && !exemptedprofile.Exempt_Profile__c) || (exemptedprofile.Exempt_Profile__c) || (isEventEditionStartDateNull)) {
                                opp.Milestone_1_Amount__c        = dPrice.round(System.RoundingMode.DOWN);                        opp.Milestone_2_Amount__c         = dPrice.round(System.RoundingMode.DOWN);
                                opp.Milestone_3_Amount__c        = dPrice.round(System.RoundingMode.DOWN);                        opp.Milestone_4_Amount__c         = dPrice.round(System.RoundingMode.DOWN);
                                opp.Milestone_5_Amount__c        = dPrice.round(System.RoundingMode.DOWN);                        opp.Milestone_6_Amount__c         = dPrice.round(System.RoundingMode.DOWN);
                                opp.Milestone_7_Amount__c        = dPrice.round(System.RoundingMode.DOWN);                        opp.Milestone_8_Amount__c         = dPrice.round(System.RoundingMode.DOWN);
                                opp.Milestone_9_Amount__c        = dPrice.round(System.RoundingMode.DOWN);
                                opp.Milestone_1_Delivery_Date__c = dstartdate;
                                opp.Milestone_2_Delivery_Date__c  = opp.Milestone_1_Delivery_Date__c.addDays(invoiceTobeIssueBefore);
                                opp.Milestone_3_Delivery_Date__c = opp.Milestone_2_Delivery_Date__c.addDays(invoiceTobeIssueBefore);
                                opp.Milestone_4_Delivery_Date__c  = opp.Milestone_3_Delivery_Date__c.addDays(invoiceTobeIssueBefore);
                                opp.Milestone_5_Delivery_Date__c = opp.Milestone_4_Delivery_Date__c.addDays(invoiceTobeIssueBefore);
                                opp.Milestone_6_Delivery_Date__c  = opp.Milestone_5_Delivery_Date__c.addDays(invoiceTobeIssueBefore);
                                opp.Milestone_7_Delivery_Date__c = opp.Milestone_6_Delivery_Date__c.addDays(invoiceTobeIssueBefore);
                                opp.Milestone_8_Delivery_Date__c = opp.Milestone_7_Delivery_Date__c.addDays(invoiceTobeIssueBefore);
                                opp.Milestone_9_Delivery_Date__c = opp.Milestone_8_Delivery_Date__c.addDays(invoiceTobeIssueBefore);
                                if (((dstartdate.addmonths(9) < dEventStartDate) && !exemptedprofile.Exempt_Profile__c) || (exemptedprofile.Exempt_Profile__c) || (isEventEditionStartDateNull)) {
                                    opp.Milestone_10_Delivery_Date__c = opp.Milestone_9_Delivery_Date__c.addDays(invoiceTobeIssueBefore);
                                    opp.Milestone_10_Amount__c        = (opp.Amount - (dPrice.round(System.RoundingMode.DOWN) * 9));
                                    opp.Milestone_11_Amount__c        = 0;                                                         opp.Milestone_11_Delivery_Date__c = null;
                                    opp.Milestone_12_Amount__c        = 0;                                                         opp.Milestone_12_Delivery_Date__c = null;
                                } else { opp.addError('Billing 10 date should not go past the Event Start Date.');
                                }
                            } else { opp.addError('Billing 10 date should not go past the Event Start Date.');
                            }

                        } else if ((opp.Total_No_of_payment__c == 11) && (oldOpp.Total_No_of_payment__c != 11)) {
                            if (((dstartdate < dEventStartDate) && !exemptedprofile.Exempt_Profile__c) || (exemptedprofile.Exempt_Profile__c) || (isEventEditionStartDateNull)) {
                                opp.Milestone_1_Amount__c         = dPrice.round(System.RoundingMode.DOWN);                       opp.Milestone_2_Amount__c         = dPrice.round(System.RoundingMode.DOWN);
                                opp.Milestone_3_Amount__c         = dPrice.round(System.RoundingMode.DOWN);                       opp.Milestone_4_Amount__c         = dPrice.round(System.RoundingMode.DOWN);
                                opp.Milestone_5_Amount__c         = dPrice.round(System.RoundingMode.DOWN);                       opp.Milestone_6_Amount__c         = dPrice.round(System.RoundingMode.DOWN);
                                opp.Milestone_7_Amount__c         = dPrice.round(System.RoundingMode.DOWN);                       opp.Milestone_8_Amount__c         = dPrice.round(System.RoundingMode.DOWN);
                                opp.Milestone_9_Amount__c         = dPrice.round(System.RoundingMode.DOWN);                       opp.Milestone_10_Amount__c        = dPrice.round(System.RoundingMode.DOWN);
                                opp.Milestone_1_Delivery_Date__c  = dstartdate;
                                opp.Milestone_2_Delivery_Date__c  = opp.Milestone_1_Delivery_Date__c.addDays(invoiceTobeIssueBefore);
                                opp.Milestone_3_Delivery_Date__c  = opp.Milestone_2_Delivery_Date__c.addDays(invoiceTobeIssueBefore);
                                opp.Milestone_4_Delivery_Date__c  = opp.Milestone_3_Delivery_Date__c.addDays(invoiceTobeIssueBefore);
                                opp.Milestone_5_Delivery_Date__c  = opp.Milestone_4_Delivery_Date__c.addDays(invoiceTobeIssueBefore);
                                opp.Milestone_6_Delivery_Date__c  = opp.Milestone_5_Delivery_Date__c.addDays(invoiceTobeIssueBefore);
                                opp.Milestone_7_Delivery_Date__c  = opp.Milestone_6_Delivery_Date__c.addDays(invoiceTobeIssueBefore);
                                opp.Milestone_8_Delivery_Date__c  = opp.Milestone_7_Delivery_Date__c.addDays(invoiceTobeIssueBefore);
                                opp.Milestone_9_Delivery_Date__c  = opp.Milestone_8_Delivery_Date__c.addDays(invoiceTobeIssueBefore);

                                opp.Milestone_10_Delivery_Date__c = opp.Milestone_9_Delivery_Date__c.addDays(invoiceTobeIssueBefore);
                                if (((dstartdate.addmonths(10) < dEventStartDate) && !exemptedprofile.Exempt_Profile__c) || (exemptedprofile.Exempt_Profile__c) || (isEventEditionStartDateNull)) {
                                    opp.Milestone_11_Delivery_Date__c = opp.Milestone_10_Delivery_Date__c.addDays(invoiceTobeIssueBefore);
                                    opp.Milestone_11_Amount__c        = (opp.Amount - (dPrice.round(System.RoundingMode.DOWN) * 10));
                                    opp.Milestone_12_Amount__c        = null;                                                         opp.Milestone_12_Delivery_Date__c = null;
                                } else { opp.addError('Billing 11 date should not go past the Event Start Date.');
                                }
                            } else { opp.addError('Billing 11 date should not go past the Event Start Date.');
                            }


                        } else if ( ( opp.Total_No_of_payment__c == 12 ) && ( oldOpp.Total_No_of_payment__c != 12 ) ) {
                            if (((dstartdate < dEventStartDate) && !exemptedprofile.Exempt_Profile__c) || (exemptedprofile.Exempt_Profile__c) || (isEventEditionStartDateNull)) {
                                opp.Milestone_1_Amount__c         = dPrice.round(System.RoundingMode.DOWN);                       opp.Milestone_2_Amount__c         = dPrice.round(System.RoundingMode.DOWN);
                                opp.Milestone_3_Amount__c         = dPrice.round(System.RoundingMode.DOWN);                       opp.Milestone_4_Amount__c         = dPrice.round(System.RoundingMode.DOWN);
                                opp.Milestone_5_Amount__c         = dPrice.round(System.RoundingMode.DOWN);                       opp.Milestone_6_Amount__c         = dPrice.round(System.RoundingMode.DOWN);
                                opp.Milestone_7_Amount__c         = dPrice.round(System.RoundingMode.DOWN);                       opp.Milestone_8_Amount__c         = dPrice.round(System.RoundingMode.DOWN);
                                opp.Milestone_9_Amount__c         = dPrice.round(System.RoundingMode.DOWN);                       opp.Milestone_10_Amount__c        = dPrice.round(System.RoundingMode.DOWN);
                                opp.Milestone_11_Amount__c        = dPrice.round(System.RoundingMode.DOWN);
                                opp.Milestone_1_Delivery_Date__c  = dstartdate;
                                opp.Milestone_2_Delivery_Date__c  = opp.Milestone_1_Delivery_Date__c.addDays(invoiceTobeIssueBefore);
                                opp.Milestone_3_Delivery_Date__c  = opp.Milestone_2_Delivery_Date__c.addDays(invoiceTobeIssueBefore);
                                opp.Milestone_4_Delivery_Date__c  = opp.Milestone_3_Delivery_Date__c.addDays(invoiceTobeIssueBefore);
                                opp.Milestone_5_Delivery_Date__c  = opp.Milestone_4_Delivery_Date__c.addDays(invoiceTobeIssueBefore);
                                opp.Milestone_6_Delivery_Date__c  = opp.Milestone_5_Delivery_Date__c.addDays(invoiceTobeIssueBefore);
                                opp.Milestone_7_Delivery_Date__c  = opp.Milestone_6_Delivery_Date__c.addDays(invoiceTobeIssueBefore);
                                opp.Milestone_8_Delivery_Date__c  = opp.Milestone_7_Delivery_Date__c.addDays(invoiceTobeIssueBefore);
                                opp.Milestone_9_Delivery_Date__c  = opp.Milestone_8_Delivery_Date__c.addDays(invoiceTobeIssueBefore);
                                opp.Milestone_10_Delivery_Date__c = opp.Milestone_9_Delivery_Date__c.addDays(invoiceTobeIssueBefore);

                                opp.Milestone_11_Delivery_Date__c = opp.Milestone_10_Delivery_Date__c.addDays(invoiceTobeIssueBefore);
                                if (((dstartdate.addmonths(11) < dEventStartDate) && !exemptedprofile.Exempt_Profile__c) || (exemptedprofile.Exempt_Profile__c) || (isEventEditionStartDateNull)) {
                                    opp.Milestone_12_Delivery_Date__c = opp.Milestone_11_Delivery_Date__c.addDays(invoiceTobeIssueBefore);
                                    opp.Milestone_12_Amount__c        = (opp.Amount - (dPrice.round(System.RoundingMode.DOWN) * 11));
                                } else { opp.addError('Billing 12 date should not go past the Event Start Date.');
                                }

                            } else { opp.addError('Billing 12 date should not go past the Event Start Date.');
                            }

                        } else if ( ( (oldOpp.Milestone_1_Amount__c != null && opp.Milestone_1_Amount__c != null ) && (opp.Milestone_1_Amount__c != oldOpp.Milestone_1_Amount__c.setScale(2)) ) ) {
                            dtotalAmt = opp.Milestone_1_Amount__c;
                            if (opp.Amount >= dtotalAmt) {
                                dAmount = (opp.Amount - dtotalAmt);
                                dPrice  = dAmount / (opp.Total_No_of_payment__c - 1);
                                if ( opp.Total_No_of_payment__c == 2 )  { opp.Milestone_2_Amount__c  = dAmount; } else { opp.Milestone_2_Amount__c = dPrice.round(System.RoundingMode.DOWN); }
                                if ( opp.Total_No_of_payment__c == 3 )  { opp.Milestone_3_Amount__c  = dAmount - (dPrice.round(System.RoundingMode.DOWN)); } else { opp.Milestone_3_Amount__c = dPrice.round(System.RoundingMode.DOWN) ; }
                                if ( opp.Total_No_of_payment__c == 4 )  { opp.Milestone_4_Amount__c  = (dAmount - (dPrice.round(System.RoundingMode.DOWN) * 2)); } else { opp.Milestone_4_Amount__c = dPrice.round(System.RoundingMode.DOWN); }
                                if ( opp.Total_No_of_payment__c == 5 )  { opp.Milestone_5_Amount__c  = (dAmount - (dPrice.round(System.RoundingMode.DOWN) * 3)); } else { opp.Milestone_5_Amount__c = dPrice.round(System.RoundingMode.DOWN); }
                                if ( opp.Total_No_of_payment__c == 6 )  { opp.Milestone_6_Amount__c  = (dAmount - (dPrice.round(System.RoundingMode.DOWN) * 4)); } else { opp.Milestone_6_Amount__c = dPrice.round(System.RoundingMode.DOWN); }
                                if ( opp.Total_No_of_payment__c == 7 )  { opp.Milestone_7_Amount__c  = (dAmount - (dPrice.round(System.RoundingMode.DOWN) * 5)); } else { opp.Milestone_7_Amount__c = dPrice.round(System.RoundingMode.DOWN); }
                                if ( opp.Total_No_of_payment__c == 8 )  { opp.Milestone_8_Amount__c  = (dAmount - (dPrice.round(System.RoundingMode.DOWN) * 6)); } else { opp.Milestone_8_Amount__c = dPrice.round(System.RoundingMode.DOWN); }
                                if ( opp.Total_No_of_payment__c == 9 )  { opp.Milestone_9_Amount__c  = (dAmount - (dPrice.round(System.RoundingMode.DOWN) * 7)); } else { opp.Milestone_9_Amount__c = dPrice.round(System.RoundingMode.DOWN); }
                                if ( opp.Total_No_of_payment__c == 10 ) { opp.Milestone_10_Amount__c = (dAmount - (dPrice.round(System.RoundingMode.DOWN) * 8)); } else { opp.Milestone_10_Amount__c = dPrice.round(System.RoundingMode.DOWN); }
                                if ( opp.Total_No_of_payment__c == 11 ) { opp.Milestone_11_Amount__c = (dAmount - (dPrice.round(System.RoundingMode.DOWN) * 9)); } else { opp.Milestone_11_Amount__c = dPrice.round(System.RoundingMode.DOWN); }
                                if ( opp.Total_No_of_payment__c == 12 ) { opp.Milestone_12_Amount__c = (dAmount - (dPrice.round(System.RoundingMode.DOWN) * 10)); } else { opp.Milestone_12_Amount__c = dPrice.round(System.RoundingMode.DOWN); }
                            } else { opp.addError(system.label.Custom_Payment_Validation_Message + ' ' + opp.Amount); }
                        } else if (opp.Milestone_1_Amount__c == null && opp.Milestone_1_Amount__c != 0 && oldOpp.Milestone_1_Delivery_Date__c == opp.Milestone_1_Delivery_Date__c) {
                            opp.addError('Amount field can not be blank.');
                        } else if ( (oldOpp.Milestone_2_Amount__c != null && opp.Milestone_2_Amount__c != null) && ( opp.Milestone_2_Amount__c != oldOpp.Milestone_2_Amount__c.setScale(2) ) ) {
                            dtotalAmt = ( opp.Milestone_1_Amount__c + opp.Milestone_2_Amount__c );
                            if (opp.Amount >= dtotalAmt) {
                                dAmount = (opp.Amount - dtotalAmt);
                                dPrice = dAmount / (opp.Total_No_of_payment__c - 2);
                                if ( opp.Total_No_of_payment__c == 3 ) { opp.Milestone_3_Amount__c = dAmount; } else { opp.Milestone_3_Amount__c = dPrice.round(System.RoundingMode.DOWN); }
                                if ( opp.Total_No_of_payment__c == 4 ) { opp.Milestone_4_Amount__c = (dAmount - (dPrice.round(System.RoundingMode.DOWN))); } else { opp.Milestone_4_Amount__c = dPrice.round(System.RoundingMode.DOWN); }
                                if ( opp.Total_No_of_payment__c == 5 ) { opp.Milestone_5_Amount__c = (dAmount - (dPrice.round(System.RoundingMode.DOWN) * 2)); } else { opp.Milestone_5_Amount__c = dPrice.round(System.RoundingMode.DOWN); }
                                if ( opp.Total_No_of_payment__c == 6 ) { opp.Milestone_6_Amount__c = (dAmount - (dPrice.round(System.RoundingMode.DOWN) * 3)); } else { opp.Milestone_6_Amount__c = dPrice.round(System.RoundingMode.DOWN); }
                                if ( opp.Total_No_of_payment__c == 7 ) { opp.Milestone_7_Amount__c = (dAmount - (dPrice.round(System.RoundingMode.DOWN) * 4)); } else { opp.Milestone_7_Amount__c = dPrice.round(System.RoundingMode.DOWN); }
                                if ( opp.Total_No_of_payment__c == 8 ) { opp.Milestone_8_Amount__c = (dAmount - (dPrice.round(System.RoundingMode.DOWN) * 5)); } else { opp.Milestone_8_Amount__c = dPrice.round(System.RoundingMode.DOWN); }
                                if ( opp.Total_No_of_payment__c == 9 ) { opp.Milestone_9_Amount__c = (dAmount - (dPrice.round(System.RoundingMode.DOWN) * 6)); } else { opp.Milestone_9_Amount__c = dPrice.round(System.RoundingMode.DOWN); }
                                if ( opp.Total_No_of_payment__c == 10 ) { opp.Milestone_10_Amount__c = (dAmount - (dPrice.round(System.RoundingMode.DOWN) * 7)); } else { opp.Milestone_10_Amount__c = dPrice.round(System.RoundingMode.DOWN); }
                                if ( opp.Total_No_of_payment__c == 11 ) { opp.Milestone_11_Amount__c = (dAmount - (dPrice.round(System.RoundingMode.DOWN) * 8)); } else { opp.Milestone_11_Amount__c = dPrice.round(System.RoundingMode.DOWN); }
                                if ( opp.Total_No_of_payment__c == 12 ) { opp.Milestone_12_Amount__c = (dAmount - (dPrice.round(System.RoundingMode.DOWN) * 9)); } else { opp.Milestone_12_Amount__c = dPrice.round(System.RoundingMode.DOWN); }
                            } else { Double forTwoRemAmount = opp.Amount - opp.Milestone_1_Amount__c;                            opp.addError(system.label.Custom_Payment_Validation_Message + ' ' + forTwoRemAmount);
                            }
                        } else if (opp.Milestone_2_Amount__c == null &&  opp.Milestone_2_Amount__c != 0 && oldOpp.Milestone_1_Delivery_Date__c == opp.Milestone_1_Delivery_Date__c && oldOpp.Milestone_2_Delivery_Date__c == opp.Milestone_2_Delivery_Date__c) { opp.addError('Amount field can not be blank.');
                        } else if ((oldOpp.Milestone_3_Amount__c != null  && opp.Milestone_3_Amount__c != null) && (opp.Milestone_3_Amount__c != oldOpp.Milestone_3_Amount__c.setScale(2)) ) {
                            dtotalAmt = (opp.Milestone_1_Amount__c + opp.Milestone_2_Amount__c + opp.Milestone_3_Amount__c);
                            if ( opp.Amount >= dtotalAmt ) {
                                dAmount = (opp.Amount - dtotalAmt);
                                dPrice = dAmount / (opp.Total_No_of_payment__c - 3);
                                if ( opp.Total_No_of_payment__c == 4 ) { opp.Milestone_4_Amount__c = dAmount; } else { opp.Milestone_4_Amount__c = dPrice.round(System.RoundingMode.DOWN); }
                                if ( opp.Total_No_of_payment__c == 5 ) { opp.Milestone_5_Amount__c = dAmount - dPrice.round(System.RoundingMode.DOWN); } else { opp.Milestone_5_Amount__c = dPrice.round(System.RoundingMode.DOWN); }
                                if ( opp.Total_No_of_payment__c == 6 ) { opp.Milestone_6_Amount__c = (dAmount - dPrice.round(System.RoundingMode.DOWN) * 2); } else { opp.Milestone_6_Amount__c = dPrice.round(System.RoundingMode.DOWN); }
                                if ( opp.Total_No_of_payment__c == 7 ) { opp.Milestone_7_Amount__c = (dAmount - dPrice.round(System.RoundingMode.DOWN) * 3); } else { opp.Milestone_7_Amount__c = dPrice.round(System.RoundingMode.DOWN); }
                                if ( opp.Total_No_of_payment__c == 8 ) { opp.Milestone_8_Amount__c = (dAmount - dPrice.round(System.RoundingMode.DOWN) * 4); } else { opp.Milestone_8_Amount__c = dPrice.round(System.RoundingMode.DOWN); }
                                if ( opp.Total_No_of_payment__c == 9 ) { opp.Milestone_9_Amount__c = (dAmount - dPrice.round(System.RoundingMode.DOWN) * 5); } else { opp.Milestone_9_Amount__c = dPrice.round(System.RoundingMode.DOWN); }
                                if ( opp.Total_No_of_payment__c == 10 ) { opp.Milestone_10_Amount__c = (dAmount - dPrice.round(System.RoundingMode.DOWN) * 6); } else { opp.Milestone_10_Amount__c = dPrice.round(System.RoundingMode.DOWN); }
                                if ( opp.Total_No_of_payment__c == 11 ) { opp.Milestone_11_Amount__c = (dAmount - dPrice.round(System.RoundingMode.DOWN) * 7); } else { opp.Milestone_11_Amount__c = dPrice.round(System.RoundingMode.DOWN); }
                                if ( opp.Total_No_of_payment__c == 12 ) { opp.Milestone_12_Amount__c = (dAmount - dPrice.round(System.RoundingMode.DOWN) * 8); } else { opp.Milestone_12_Amount__c = dPrice.round(System.RoundingMode.DOWN); }
                            } else { Double forThreeRemAmount = opp.Amount - (opp.Milestone_1_Amount__c + opp.Milestone_2_Amount__c);                            opp.addError(system.label.Custom_Payment_Validation_Message + ' ' + forThreeRemAmount);
                            }
                        } else if (opp.Milestone_3_Amount__c == null && opp.Milestone_3_Amount__c != 0 && oldOpp.Milestone_1_Delivery_Date__c == opp.Milestone_1_Delivery_Date__c && oldOpp.Milestone_2_Delivery_Date__c == opp.Milestone_2_Delivery_Date__c && oldOpp.Milestone_3_Delivery_Date__c == opp.Milestone_3_Delivery_Date__c) { opp.addError('Amount field can not be blank.');
                        } else if ( (oldOpp.Milestone_4_Amount__c != null && opp.Milestone_4_Amount__c != null) && ( opp.Milestone_4_Amount__c != oldOpp.Milestone_4_Amount__c.setScale(2) )) {
                            dtotalAmt = (opp.Milestone_1_Amount__c + opp.Milestone_2_Amount__c + opp.Milestone_3_Amount__c + opp.Milestone_4_Amount__c);
                            if (opp.Amount >= dtotalAmt) {
                                dAmount = (opp.Amount - dtotalAmt);
                                dPrice = dAmount / (opp.Total_No_of_payment__c - 4);
                                if ( opp.Total_No_of_payment__c == 5 ) { opp.Milestone_5_Amount__c = dAmount; } else { opp.Milestone_5_Amount__c = dPrice.round(System.RoundingMode.DOWN); }
                                if ( opp.Total_No_of_payment__c == 6 ) { opp.Milestone_6_Amount__c = (dAmount - dPrice.round(System.RoundingMode.DOWN)); } else { opp.Milestone_6_Amount__c = dPrice.round(System.RoundingMode.DOWN); }
                                if ( opp.Total_No_of_payment__c == 7 ) { opp.Milestone_7_Amount__c = (dAmount - dPrice.round(System.RoundingMode.DOWN) * 2); } else { opp.Milestone_7_Amount__c = dPrice.round(System.RoundingMode.DOWN); }
                                if ( opp.Total_No_of_payment__c == 8 ) { opp.Milestone_8_Amount__c = (dAmount - dPrice.round(System.RoundingMode.DOWN) * 3); } else { opp.Milestone_8_Amount__c = dPrice.round(System.RoundingMode.DOWN); }
                                if ( opp.Total_No_of_payment__c == 9 ) { opp.Milestone_9_Amount__c = (dAmount - dPrice.round(System.RoundingMode.DOWN) * 4); } else { opp.Milestone_9_Amount__c = dPrice.round(System.RoundingMode.DOWN); }
                                if ( opp.Total_No_of_payment__c == 10 ) { opp.Milestone_10_Amount__c = (dAmount - dPrice.round(System.RoundingMode.DOWN) * 5); } else { opp.Milestone_10_Amount__c = dPrice.round(System.RoundingMode.DOWN); }
                                if ( opp.Total_No_of_payment__c == 11 ) { opp.Milestone_11_Amount__c = (dAmount - dPrice.round(System.RoundingMode.DOWN) * 6); } else { opp.Milestone_11_Amount__c = dPrice.round(System.RoundingMode.DOWN); }
                                if ( opp.Total_No_of_payment__c == 12 ) { opp.Milestone_12_Amount__c = (dAmount - dPrice.round(System.RoundingMode.DOWN) * 7); } else { opp.Milestone_12_Amount__c = dPrice.round(System.RoundingMode.DOWN); }
                            } else { Double forFourRemAmount = opp.Amount - (opp.Milestone_1_Amount__c + opp.Milestone_2_Amount__c + opp.Milestone_3_Amount__c);                            opp.addError(system.label.Custom_Payment_Validation_Message + ' ' + forFourRemAmount);
                            }
                        } else if (opp.Milestone_4_Amount__c == null && opp.Milestone_4_Amount__c != 0 && oldOpp.Milestone_1_Delivery_Date__c == opp.Milestone_1_Delivery_Date__c && oldOpp.Milestone_2_Delivery_Date__c == opp.Milestone_2_Delivery_Date__c && oldOpp.Milestone_3_Delivery_Date__c == opp.Milestone_3_Delivery_Date__c && oldOpp.Milestone_4_Delivery_Date__c == opp.Milestone_4_Delivery_Date__c) { opp.addError('Amount field can not be blank.');
                        } else if ((oldOpp.Milestone_5_Amount__c != null && opp.Milestone_5_Amount__c != null) && ( opp.Milestone_5_Amount__c != oldOpp.Milestone_5_Amount__c.setScale(2))) {
                            dtotalAmt = (opp.Milestone_1_Amount__c + opp.Milestone_2_Amount__c + opp.Milestone_3_Amount__c + opp.Milestone_4_Amount__c + opp.Milestone_5_Amount__c);
                            if (opp.Amount >= dtotalAmt) {
                                dAmount = (opp.Amount - dtotalAmt);
                                dPrice = dAmount / (opp.Total_No_of_payment__c - 5);
                                if ( opp.Total_No_of_payment__c == 6 ) { opp.Milestone_6_Amount__c = dAmount; } else { opp.Milestone_6_Amount__c = dPrice.round(System.RoundingMode.DOWN); }
                                if ( opp.Total_No_of_payment__c == 7 ) { opp.Milestone_7_Amount__c = (dAmount - dPrice.round(System.RoundingMode.DOWN)); } else { opp.Milestone_7_Amount__c = dPrice.round(System.RoundingMode.DOWN); }
                                if ( opp.Total_No_of_payment__c == 8 ) { opp.Milestone_8_Amount__c = (dAmount - dPrice.round(System.RoundingMode.DOWN) * 2); } else { opp.Milestone_8_Amount__c = dPrice.round(System.RoundingMode.DOWN); }
                                if ( opp.Total_No_of_payment__c == 9 ) { opp.Milestone_9_Amount__c = (dAmount - dPrice.round(System.RoundingMode.DOWN) * 3); } else { opp.Milestone_9_Amount__c = dPrice.round(System.RoundingMode.DOWN); }
                                if ( opp.Total_No_of_payment__c == 10 ) { opp.Milestone_10_Amount__c = (dAmount - dPrice.round(System.RoundingMode.DOWN) * 4); } else { opp.Milestone_10_Amount__c = dPrice.round(System.RoundingMode.DOWN); }
                                if ( opp.Total_No_of_payment__c == 11 ) { opp.Milestone_11_Amount__c = (dAmount - dPrice.round(System.RoundingMode.DOWN) * 5); } else { opp.Milestone_11_Amount__c = dPrice.round(System.RoundingMode.DOWN); }
                                if ( opp.Total_No_of_payment__c == 12 ) { opp.Milestone_12_Amount__c = (dAmount - dPrice.round(System.RoundingMode.DOWN) * 6); } else { opp.Milestone_12_Amount__c = dPrice.round(System.RoundingMode.DOWN); }
                            } else { Double forFourRemAmount = opp.Amount - (opp.Milestone_1_Amount__c + opp.Milestone_2_Amount__c + opp.Milestone_3_Amount__c + opp.Milestone_4_Amount__c);   opp.addError(system.label.Custom_Payment_Validation_Message + ' ' + forFourRemAmount);
                            }
                        } else if (opp.Milestone_5_Amount__c == null && opp.Milestone_5_Amount__c != 0 && oldOpp.Milestone_1_Delivery_Date__c == opp.Milestone_1_Delivery_Date__c && oldOpp.Milestone_2_Delivery_Date__c == opp.Milestone_2_Delivery_Date__c && oldOpp.Milestone_3_Delivery_Date__c == opp.Milestone_3_Delivery_Date__c && oldOpp.Milestone_4_Delivery_Date__c == opp.Milestone_4_Delivery_Date__c &&  oldOpp.Milestone_5_Delivery_Date__c == opp.Milestone_5_Delivery_Date__c) { opp.addError('Amount field can not be blank.');
                        } else if ( (oldOpp.Milestone_6_Amount__c != null  && opp.Milestone_6_Amount__c != null ) && ( opp.Milestone_6_Amount__c != oldOpp.Milestone_6_Amount__c.setScale(2))) {
                            dtotalAmt = (opp.Milestone_1_Amount__c + opp.Milestone_2_Amount__c + opp.Milestone_3_Amount__c + opp.Milestone_4_Amount__c + opp.Milestone_5_Amount__c + opp.Milestone_6_Amount__c);
                            if ( opp.Amount >= dtotalAmt ) {
                                dAmount = ( opp.Amount - dtotalAmt );
                                dPrice = dAmount / (opp.Total_No_of_payment__c - 6);
                                if ( opp.Total_No_of_payment__c == 7 ) { opp.Milestone_7_Amount__c = dAmount; } else { opp.Milestone_7_Amount__c = dPrice.round(System.RoundingMode.DOWN); }
                                if ( opp.Total_No_of_payment__c == 8 ) { opp.Milestone_8_Amount__c = (dAmount - dPrice.round(System.RoundingMode.DOWN)); } else { opp.Milestone_8_Amount__c = dPrice.round(System.RoundingMode.DOWN); }
                                if ( opp.Total_No_of_payment__c == 9 ) { opp.Milestone_9_Amount__c = (dAmount - dPrice.round(System.RoundingMode.DOWN) * 2); } else { opp.Milestone_9_Amount__c = dPrice.round(System.RoundingMode.DOWN); }
                                if ( opp.Total_No_of_payment__c == 10 ) { opp.Milestone_10_Amount__c = (dAmount - dPrice.round(System.RoundingMode.DOWN) * 3);} else {opp.Milestone_10_Amount__c = dPrice.round(System.RoundingMode.DOWN); }
                                if ( opp.Total_No_of_payment__c == 11 ) { opp.Milestone_11_Amount__c = (dAmount - dPrice.round(System.RoundingMode.DOWN) * 4);} else {opp.Milestone_11_Amount__c = dPrice.round(System.RoundingMode.DOWN);}
                                if ( opp.Total_No_of_payment__c == 12 ) { opp.Milestone_12_Amount__c = (dAmount - dPrice.round(System.RoundingMode.DOWN) * 5);} else {opp.Milestone_12_Amount__c = dPrice.round(System.RoundingMode.DOWN);}
                            } else { Double forSiRemAmount = opp.Amount - (opp.Milestone_1_Amount__c + opp.Milestone_2_Amount__c + opp.Milestone_3_Amount__c + opp.Milestone_4_Amount__c + opp.Milestone_5_Amount__c);   opp.addError(system.label.Custom_Payment_Validation_Message + ' ' + forSiRemAmount);
                            }
                        } else if (opp.Milestone_6_Amount__c == null && opp.Milestone_6_Amount__c != 0 && oldOpp.Milestone_1_Delivery_Date__c == opp.Milestone_1_Delivery_Date__c && oldOpp.Milestone_2_Delivery_Date__c == opp.Milestone_2_Delivery_Date__c && oldOpp.Milestone_3_Delivery_Date__c == opp.Milestone_3_Delivery_Date__c && oldOpp.Milestone_4_Delivery_Date__c == opp.Milestone_4_Delivery_Date__c &&  oldOpp.Milestone_5_Delivery_Date__c == opp.Milestone_5_Delivery_Date__c && oldOpp.Milestone_6_Delivery_Date__c == opp.Milestone_6_Delivery_Date__c ) { opp.addError('Amount field can not be blank.');
                        } else if ( (oldOpp.Milestone_7_Amount__c != null && opp.Milestone_7_Amount__c != null ) && ( opp.Milestone_7_Amount__c != oldOpp.Milestone_7_Amount__c.setScale(2) ) ) {
                            dtotalAmt = (opp.Milestone_1_Amount__c + opp.Milestone_2_Amount__c + opp.Milestone_3_Amount__c + opp.Milestone_4_Amount__c + opp.Milestone_5_Amount__c + opp.Milestone_6_Amount__c + opp.Milestone_7_Amount__c);
                            if (opp.Amount >= dtotalAmt) {
                                dAmount = (opp.Amount - dtotalAmt);
                                dPrice = dAmount / (opp.Total_No_of_payment__c - 7);
                                if (opp.Total_No_of_payment__c == 8) {
                                    opp.Milestone_8_Amount__c = dAmount;
                                } else { opp.Milestone_8_Amount__c = dPrice.round(System.RoundingMode.DOWN);
                                }
                                if (opp.Total_No_of_payment__c == 9) { opp.Milestone_9_Amount__c = (dAmount - dPrice.round(System.RoundingMode.DOWN));
                                } else {
                                    opp.Milestone_9_Amount__c = dPrice.round(System.RoundingMode.DOWN);
                                }
                                if (opp.Total_No_of_payment__c == 10) { opp.Milestone_10_Amount__c = (dAmount - dPrice.round(System.RoundingMode.DOWN) * 2);
                                } else {
                                    opp.Milestone_10_Amount__c = dPrice.round(System.RoundingMode.DOWN);
                                }
                                if (opp.Total_No_of_payment__c == 11) { opp.Milestone_11_Amount__c = (dAmount - dPrice.round(System.RoundingMode.DOWN) * 3);
                                } else {
                                    opp.Milestone_11_Amount__c = dPrice.round(System.RoundingMode.DOWN);
                                }
                                if (opp.Total_No_of_payment__c == 12) { opp.Milestone_12_Amount__c = (dAmount - dPrice.round(System.RoundingMode.DOWN) * 4);
                                } else {
                                    opp.Milestone_12_Amount__c = dPrice.round(System.RoundingMode.DOWN);
                                }
                            } else {
                                Double forSevenRemAmount = opp.Amount - (opp.Milestone_1_Amount__c + opp.Milestone_2_Amount__c + opp.Milestone_3_Amount__c + opp.Milestone_4_Amount__c + opp.Milestone_5_Amount__c + opp.Milestone_6_Amount__c);
                                opp.addError(system.label.Custom_Payment_Validation_Message + ' ' + forSevenRemAmount);
                            }
                        } else if (opp.Milestone_7_Amount__c == null && opp.Milestone_7_Amount__c != 0  && oldOpp.Milestone_1_Delivery_Date__c == opp.Milestone_1_Delivery_Date__c && oldOpp.Milestone_2_Delivery_Date__c == opp.Milestone_2_Delivery_Date__c && oldOpp.Milestone_3_Delivery_Date__c == opp.Milestone_3_Delivery_Date__c && oldOpp.Milestone_4_Delivery_Date__c == opp.Milestone_4_Delivery_Date__c &&  oldOpp.Milestone_5_Delivery_Date__c == opp.Milestone_5_Delivery_Date__c && oldOpp.Milestone_6_Delivery_Date__c == opp.Milestone_6_Delivery_Date__c && oldOpp.Milestone_7_Delivery_Date__c == opp.Milestone_7_Delivery_Date__c) { opp.addError('Amount field can not be blank.');
                        } else if ((oldOpp.Milestone_8_Amount__c != null && opp.Milestone_8_Amount__c != null) && (opp.Milestone_8_Amount__c != oldOpp.Milestone_8_Amount__c.setScale(2))) {
                            dtotalAmt = (opp.Milestone_1_Amount__c + opp.Milestone_2_Amount__c + opp.Milestone_3_Amount__c + opp.Milestone_4_Amount__c + opp.Milestone_5_Amount__c + opp.Milestone_6_Amount__c + opp.Milestone_7_Amount__c + opp.Milestone_8_Amount__c);
                            if (opp.Amount >= dtotalAmt) {
                                dAmount = (opp.Amount - dtotalAmt);
                                dPrice = dAmount / (opp.Total_No_of_payment__c - 8);
                                if (opp.Total_No_of_payment__c == 9) {
                                    opp.Milestone_9_Amount__c = dAmount;
                                } else { opp.Milestone_9_Amount__c = dPrice.round(System.RoundingMode.DOWN);
                                }
                                if (opp.Total_No_of_payment__c == 10) { opp.Milestone_10_Amount__c = (dAmount - dPrice.round(System.RoundingMode.DOWN));
                                } else {
                                    opp.Milestone_10_Amount__c = dPrice.round(System.RoundingMode.DOWN);
                                }
                                if (opp.Total_No_of_payment__c == 11) { opp.Milestone_11_Amount__c = (dAmount - dPrice.round(System.RoundingMode.DOWN) * 2);
                                } else {
                                    opp.Milestone_11_Amount__c = dPrice.round(System.RoundingMode.DOWN);
                                }
                                if (opp.Total_No_of_payment__c == 12) { opp.Milestone_12_Amount__c = (dAmount - dPrice.round(System.RoundingMode.DOWN) * 3);
                                } else {
                                    opp.Milestone_12_Amount__c = dPrice.round(System.RoundingMode.DOWN);
                                }
                            } else {
                                Double forEightRemAmount = opp.Amount - (opp.Milestone_1_Amount__c + opp.Milestone_2_Amount__c + opp.Milestone_3_Amount__c + opp.Milestone_4_Amount__c + opp.Milestone_5_Amount__c + opp.Milestone_6_Amount__c + opp.Milestone_7_Amount__c );
                                opp.addError(system.label.Custom_Payment_Validation_Message + ' ' + forEightRemAmount);
                            }
                        } else if (opp.Milestone_8_Amount__c == null && opp.Milestone_8_Amount__c != 0 && oldOpp.Milestone_1_Delivery_Date__c == opp.Milestone_1_Delivery_Date__c && oldOpp.Milestone_2_Delivery_Date__c == opp.Milestone_2_Delivery_Date__c && oldOpp.Milestone_3_Delivery_Date__c == opp.Milestone_3_Delivery_Date__c && oldOpp.Milestone_4_Delivery_Date__c == opp.Milestone_4_Delivery_Date__c &&  oldOpp.Milestone_5_Delivery_Date__c == opp.Milestone_5_Delivery_Date__c && oldOpp.Milestone_6_Delivery_Date__c == opp.Milestone_6_Delivery_Date__c && oldOpp.Milestone_7_Delivery_Date__c == opp.Milestone_7_Delivery_Date__c && oldOpp.Milestone_8_Delivery_Date__c == opp.Milestone_8_Delivery_Date__c ) { opp.addError('Amount field can not be blank.');
                        } else if ((oldOpp.Milestone_9_Amount__c != null && opp.Milestone_9_Amount__c != null ) && (opp.Milestone_9_Amount__c != oldOpp.Milestone_9_Amount__c.setScale(2)) ) {
                            dtotalAmt = (opp.Milestone_1_Amount__c + opp.Milestone_2_Amount__c + opp.Milestone_3_Amount__c + opp.Milestone_4_Amount__c + opp.Milestone_5_Amount__c + opp.Milestone_6_Amount__c + opp.Milestone_7_Amount__c + opp.Milestone_8_Amount__c + opp.Milestone_9_Amount__c);
                            if (opp.Amount >= dtotalAmt) {
                                dAmount = (opp.Amount - dtotalAmt);
                                dPrice = dAmount / (opp.Total_No_of_payment__c - 9);

                                if (opp.Total_No_of_payment__c == 10) { opp.Milestone_10_Amount__c = dAmount;
                                } else { opp.Milestone_10_Amount__c = dPrice.round(System.RoundingMode.DOWN);
                                }
                                if (opp.Total_No_of_payment__c == 11) { opp.Milestone_11_Amount__c = (dAmount - dPrice.round(System.RoundingMode.DOWN));
                                } else { opp.Milestone_11_Amount__c = dPrice.round(System.RoundingMode.DOWN);
                                }
                                if (opp.Total_No_of_payment__c == 12) { opp.Milestone_12_Amount__c = (dAmount - dPrice.round(System.RoundingMode.DOWN) * 2);
                                } else { opp.Milestone_12_Amount__c = dPrice.round(System.RoundingMode.DOWN);
                                }
                            } else {
                                Double fornineRemAmount = opp.Amount - (opp.Milestone_1_Amount__c + opp.Milestone_2_Amount__c + opp.Milestone_3_Amount__c + opp.Milestone_4_Amount__c + opp.Milestone_5_Amount__c + opp.Milestone_6_Amount__c + opp.Milestone_7_Amount__c + opp.Milestone_8_Amount__c);
                                opp.addError(system.label.Custom_Payment_Validation_Message + ' ' + fornineRemAmount);
                            }
                        } else if (opp.Milestone_9_Amount__c == null && opp.Milestone_9_Amount__c != 0 &&  oldOpp.Milestone_1_Delivery_Date__c == opp.Milestone_1_Delivery_Date__c && oldOpp.Milestone_2_Delivery_Date__c == opp.Milestone_2_Delivery_Date__c && oldOpp.Milestone_3_Delivery_Date__c == opp.Milestone_3_Delivery_Date__c && oldOpp.Milestone_4_Delivery_Date__c == opp.Milestone_4_Delivery_Date__c &&  oldOpp.Milestone_5_Delivery_Date__c == opp.Milestone_5_Delivery_Date__c && oldOpp.Milestone_6_Delivery_Date__c == opp.Milestone_6_Delivery_Date__c && oldOpp.Milestone_7_Delivery_Date__c == opp.Milestone_7_Delivery_Date__c && oldOpp.Milestone_8_Delivery_Date__c == opp.Milestone_8_Delivery_Date__c && oldOpp.Milestone_9_Delivery_Date__c == opp.Milestone_9_Delivery_Date__c ) {opp.addError('Amount field can not be blank.');}
                        else if ((oldOpp.Milestone_10_Amount__c != null && opp.Milestone_10_Amount__c != null) && (opp.Milestone_10_Amount__c != oldOpp.Milestone_10_Amount__c.setScale(2))) {
                            dtotalAmt = (opp.Milestone_1_Amount__c + opp.Milestone_2_Amount__c + opp.Milestone_3_Amount__c + opp.Milestone_4_Amount__c + opp.Milestone_5_Amount__c + opp.Milestone_6_Amount__c + opp.Milestone_7_Amount__c + opp.Milestone_8_Amount__c + opp.Milestone_9_Amount__c + opp.Milestone_10_Amount__c);
                            if (opp.Amount >= dtotalAmt) {
                                dAmount = (opp.Amount - dtotalAmt);
                                dPrice = dAmount / (opp.Total_No_of_payment__c - 10);
                                if (opp.Total_No_of_payment__c == 11) { opp.Milestone_11_Amount__c = dAmount;
                                } else { opp.Milestone_11_Amount__c = dPrice.round(System.RoundingMode.DOWN);
                                }
                                if (opp.Total_No_of_payment__c == 12) { opp.Milestone_12_Amount__c = (dAmount - dPrice.round(System.RoundingMode.DOWN));
                                } else { opp.Milestone_12_Amount__c = dPrice.round(System.RoundingMode.DOWN);
                                }
                            } else {
                                Double fortRemAmount = opp.Amount - (opp.Milestone_1_Amount__c + opp.Milestone_2_Amount__c + opp.Milestone_3_Amount__c + opp.Milestone_4_Amount__c + opp.Milestone_5_Amount__c + opp.Milestone_6_Amount__c + opp.Milestone_7_Amount__c + opp.Milestone_8_Amount__c + opp.Milestone_9_Amount__c );
                                opp.addError(system.label.Custom_Payment_Validation_Message + ' ' + fortRemAmount);
                            }
                        } else if (opp.Milestone_10_Amount__c == null && opp.Milestone_10_Amount__c != 0 && oldOpp.Milestone_1_Delivery_Date__c == opp.Milestone_1_Delivery_Date__c && oldOpp.Milestone_2_Delivery_Date__c == opp.Milestone_2_Delivery_Date__c && oldOpp.Milestone_3_Delivery_Date__c == opp.Milestone_3_Delivery_Date__c && oldOpp.Milestone_4_Delivery_Date__c == opp.Milestone_4_Delivery_Date__c &&  oldOpp.Milestone_5_Delivery_Date__c == opp.Milestone_5_Delivery_Date__c && oldOpp.Milestone_6_Delivery_Date__c == opp.Milestone_6_Delivery_Date__c && oldOpp.Milestone_7_Delivery_Date__c == opp.Milestone_7_Delivery_Date__c && oldOpp.Milestone_8_Delivery_Date__c == opp.Milestone_8_Delivery_Date__c && oldOpp.Milestone_9_Delivery_Date__c == opp.Milestone_9_Delivery_Date__c && oldOpp.Milestone_10_Delivery_Date__c == opp.Milestone_10_Delivery_Date__c ) {opp.addError('Amount field can not be blank.');}
                        else if ( (oldOpp.Milestone_11_Amount__c != null && opp.Milestone_11_Amount__c != null) && (opp.Milestone_11_Amount__c != oldOpp.Milestone_11_Amount__c.setScale(2)) ) {
                            dtotalAmt = (opp.Milestone_1_Amount__c + opp.Milestone_2_Amount__c + opp.Milestone_3_Amount__c + opp.Milestone_4_Amount__c + opp.Milestone_5_Amount__c + opp.Milestone_6_Amount__c + opp.Milestone_7_Amount__c + opp.Milestone_8_Amount__c + opp.Milestone_9_Amount__c + opp.Milestone_10_Amount__c + opp.Milestone_11_Amount__c);
                            if (opp.Amount >= dtotalAmt) {
                                dAmount = (opp.Amount - dtotalAmt);
                                dPrice = dAmount / (opp.Total_No_of_payment__c - 11);
                                /*opp.Milestone_12_Amount__c = dPrice.round(System.RoundingMode.DOWN);*/
                                if (opp.Total_No_of_payment__c == 12) { opp.Milestone_12_Amount__c = dAmount;
                                } else { opp.Milestone_12_Amount__c = dPrice.round(System.RoundingMode.DOWN);
                                }
                            } else {
                                Double forElevenRemAmount = opp.Amount - (opp.Milestone_1_Amount__c + opp.Milestone_2_Amount__c + opp.Milestone_3_Amount__c + opp.Milestone_4_Amount__c + opp.Milestone_5_Amount__c + opp.Milestone_6_Amount__c + opp.Milestone_7_Amount__c + opp.Milestone_8_Amount__c + opp.Milestone_9_Amount__c + opp.Milestone_10_Amount__c);
                                opp.addError(system.label.Custom_Payment_Validation_Message + ' ' + forElevenRemAmount);
                            }
                        } else if (opp.Milestone_11_Amount__c == null &&  opp.Milestone_11_Amount__c != 0  && oldOpp.Milestone_1_Delivery_Date__c == opp.Milestone_1_Delivery_Date__c && oldOpp.Milestone_2_Delivery_Date__c == opp.Milestone_2_Delivery_Date__c && oldOpp.Milestone_3_Delivery_Date__c == opp.Milestone_3_Delivery_Date__c && oldOpp.Milestone_4_Delivery_Date__c == opp.Milestone_4_Delivery_Date__c &&  oldOpp.Milestone_5_Delivery_Date__c == opp.Milestone_5_Delivery_Date__c && oldOpp.Milestone_6_Delivery_Date__c == opp.Milestone_6_Delivery_Date__c && oldOpp.Milestone_7_Delivery_Date__c == opp.Milestone_7_Delivery_Date__c && oldOpp.Milestone_8_Delivery_Date__c == opp.Milestone_8_Delivery_Date__c && oldOpp.Milestone_9_Delivery_Date__c == opp.Milestone_9_Delivery_Date__c && oldOpp.Milestone_10_Delivery_Date__c == opp.Milestone_10_Delivery_Date__c &&  oldOpp.Milestone_11_Delivery_Date__c == opp.Milestone_11_Delivery_Date__c ) {opp.addError('Amount field can not be blank.');}

                        //Added by AQ to populate payment percentage.

                        if (opp.Milestone_1_Amount__c > 0) {
                            percentageList.put(1, (opp.Milestone_1_Amount__c * 100) / opp.Amount  );
                        }

                        if (opp.Milestone_2_Amount__c  > 0) {
                            percentageList.put(2, (opp.Milestone_2_Amount__c * 100) / opp.Amount  );
                        }

                        if (opp.Milestone_3_Amount__c > 0) {
                            percentageList.put(3, (opp.Milestone_3_Amount__c * 100) / opp.Amount  );
                        }

                        if (opp.Milestone_4_Amount__c > 0) {
                            percentageList.put(4, (opp.Milestone_4_Amount__c * 100) / opp.Amount  );
                        }

                        if (opp.Milestone_5_Amount__c > 0) {
                            percentageList.put(5, (opp.Milestone_5_Amount__c * 100) / opp.Amount  );
                        }

                        if (opp.Milestone_6_Amount__c > 0) {
                            percentageList.put(6, (opp.Milestone_6_Amount__c * 100) / opp.Amount  );
                        }

                        if (opp.Milestone_7_Amount__c > 0) {
                            percentageList.put(7, (opp.Milestone_7_Amount__c * 100) / opp.Amount  );
                        }

                        if (opp.Milestone_8_Amount__c > 0) {
                            percentageList.put(8, (opp.Milestone_8_Amount__c * 100) / opp.Amount  );
                        }

                        if (opp.Milestone_9_Amount__c > 0) {
                            percentageList.put(9, (opp.Milestone_9_Amount__c * 100) / opp.Amount  );
                        }

                        if (opp.Milestone_10_Amount__c > 0) {
                            percentageList.put(10, (opp.Milestone_10_Amount__c * 100) / opp.Amount  );
                        }

                        if (opp.Milestone_11_Amount__c > 0) {
                            percentageList.put(11, (opp.Milestone_11_Amount__c * 100) / opp.Amount  );
                        }

                        if (opp.Milestone_12_Amount__c > 0) {
                            percentageList.put(12, (opp.Milestone_12_Amount__c * 100) / opp.Amount  );
                        }


                        /* Decimal dAdjusted = 0;
                        for(Integer i :percentageList.keySet()){
                            Decimal sTemp = percentageList.get(i)+ dAdjusted;
                            Decimal dActual = sTemp;
                            sTemp = sTemp.setscale(2);
                            dAdjusted = (dActual-sTemp);
                            percentageList.put(i,sTemp);
                        }*/

                        for (Integer i : percentageList.keySet()) {
                            if (percentageList.get(1) > 0) {
                                opp.Milestone_1_Percent__c = percentageList.get(1);
                            }

                            if (percentageList.get(2) > 0) {
                                opp.Milestone_2_Percent__c = percentageList.get(2);
                            }

                            if (percentageList.get(3) > 0) {
                                opp.Milestone_3_Percent__c = percentageList.get(3);
                            }

                            if (percentageList.get(4) > 0) {
                                opp.Milestone_4_Percent__c = percentageList.get(4);
                            }

                            if (percentageList.get(5) > 0) {
                                opp.Milestone_5_Percent__c = percentageList.get(5);
                            }

                            if (percentageList.get(6) > 0) {
                                opp.Milestone_6_Percent__c = percentageList.get(6);
                            }

                            if (percentageList.get(7) > 0) {
                                opp.Milestone_7_Percent__c = percentageList.get(7);
                            }

                            if (percentageList.get(8) > 0) {
                                opp.Milestone_8_Percent__c = percentageList.get(8);
                            }

                            if (percentageList.get(9) > 0) {
                                opp.Milestone_9_Percent__c = percentageList.get(9);
                            }

                            if (percentageList.get(10) > 0) {
                                opp.Milestone_10_Percent__c = percentageList.get(10);
                            }

                            if (percentageList.get(11) > 0) {
                                opp.Milestone_11_Percent__c = percentageList.get(11);
                            }

                            if (percentageList.get(12) > 0) {
                                opp.Milestone_12_Percent__c = percentageList.get(12);
                            }
                        }

                        //added code for set validate message before
                        //Added By Rajesh Kr : BK 3000
                        /*if (  opp.Milestone_1_Delivery_Date__c != oldOpp.Milestone_1_Delivery_Date__c && opp.Milestone_1_Delivery_Date__c < dEventStartDate && !exemptedprofile.Exempt_Profile__c){
                            opp.addError('Billing 1 date should not go past the Event Start Date.');
                            System.debug('test Rajesh ::::: +++ ' + opp.Milestone_1_Delivery_Date__c );
                        }
                        if ( opp.Milestone_2_Delivery_Date__c != oldOpp.Milestone_2_Delivery_Date__c && opp.Milestone_2_Delivery_Date__c < dEventStartDate && !exemptedprofile.Exempt_Profile__c){
                            opp.addError('Billing 2 date should not go past the Event Start Date.');
                            System.debug('test Rajesh ::::: +++ ' + opp.Milestone_3_Delivery_Date__c );
                        }
                        if (opp.Milestone_3_Delivery_Date__c != oldOpp.Milestone_3_Delivery_Date__c && opp.Milestone_3_Delivery_Date__c < dEventStartDate && !exemptedprofile.Exempt_Profile__c){
                            opp.addError('Billing 3 date should not go past the Event Start Date.');
                            System.debug('test Rajesh ::::: +++ ' + opp.Milestone_3_Delivery_Date__c );
                        }
                        if ( opp.Milestone_4_Delivery_Date__c != oldOpp.Milestone_4_Delivery_Date__c && opp.Milestone_4_Delivery_Date__c < dEventStartDate && !exemptedprofile.Exempt_Profile__c){
                            opp.addError('Billing 4 date should not go past the Event Start Date.');
                            System.debug('test Rajesh ::::: +++ ' + opp.Milestone_3_Delivery_Date__c );
                        }
                        if ( opp.Milestone_5_Delivery_Date__c != oldOpp.Milestone_5_Delivery_Date__c && opp.Milestone_5_Delivery_Date__c < dEventStartDate && !exemptedprofile.Exempt_Profile__c){
                            opp.addError('Billing 5 date should not go past the Event Start Date.');
                            System.debug('test Rajesh ::::: +++ ' + opp.Milestone_3_Delivery_Date__c );
                        }
                        if ( opp.Milestone_6_Delivery_Date__c != oldOpp.Milestone_6_Delivery_Date__c && opp.Milestone_6_Delivery_Date__c < dEventStartDate && !exemptedprofile.Exempt_Profile__c){
                            opp.addError('Billing 6 date should not go past the Event Start Date.');
                        }
                        if ( opp.Milestone_7_Delivery_Date__c != oldOpp.Milestone_7_Delivery_Date__c && opp.Milestone_7_Delivery_Date__c < dEventStartDate && !exemptedprofile.Exempt_Profile__c){
                            opp.addError('Billing 7 date should not go past the Event Start Date.');
                        }
                        if ( opp.Milestone_8_Delivery_Date__c != oldOpp.Milestone_8_Delivery_Date__c && opp.Milestone_8_Delivery_Date__c < dEventStartDate && !exemptedprofile.Exempt_Profile__c){
                            opp.addError('Billing 8 date should not go past the Event Start Date.');
                        }
                        if ( opp.Milestone_9_Delivery_Date__c != oldOpp.Milestone_9_Delivery_Date__c && opp.Milestone_9_Delivery_Date__c < dEventStartDate && !exemptedprofile.Exempt_Profile__c){
                            opp.addError('Billing 9 date should not go past the Event Start Date.');
                        }
                        if ( opp.Milestone_10_Delivery_Date__c != oldOpp.Milestone_10_Delivery_Date__c &&  opp.Milestone_10_Delivery_Date__c < dEventStartDate  && !exemptedprofile.Exempt_Profile__c){
                            opp.addError('Billing 10 date should not go past the Event Start Date.');
                        }
                        if ( opp.Milestone_11_Delivery_Date__c != oldOpp.Milestone_11_Delivery_Date__c &&  opp.Milestone_11_Delivery_Date__c < dEventStartDate && !exemptedprofile.Exempt_Profile__c){
                            opp.addError('Billing 11 date should not go past the Event Start Date.');
                        }
                        if ( opp.Milestone_12_Delivery_Date__c != oldOpp.Milestone_12_Delivery_Date__c && opp.Milestone_12_Delivery_Date__c < dEventStartDate  && !exemptedprofile.Exempt_Profile__c){
                            opp.addError('Billing 12 date should not go past the Event Start Date.');
                        }*/


                        if ( opp.Milestone_1_Delivery_Date__c != oldOpp.Milestone_1_Delivery_Date__c  && opp.Milestone_1_Delivery_Date__c < opp.Start_Date__c  && opp.Milestone_1_Delivery_Date__c < dEventStartDate  ) { opp.addError('Billing 1 date cannot less than due Date');
                        }

                        if ( opp.Milestone_2_Delivery_Date__c != oldOpp.Milestone_2_Delivery_Date__c && opp.Milestone_2_Delivery_Date__c  < opp.Milestone_1_Delivery_Date__c  && opp.Milestone_2_Delivery_Date__c < dEventStartDate) { opp.addError('Billing 2 date cannot less than Billing 1 date');
                        }
                        if ( opp.Milestone_3_Delivery_Date__c != oldOpp.Milestone_3_Delivery_Date__c &&  opp.Milestone_3_Delivery_Date__c  < opp.Milestone_2_Delivery_Date__c  && opp.Milestone_3_Delivery_Date__c < dEventStartDate) { opp.addError('Billing 3 date cannot less than Billing 2 date');
                        }
                        if ( opp.Milestone_4_Delivery_Date__c != oldOpp.Milestone_4_Delivery_Date__c && opp.Milestone_4_Delivery_Date__c  < opp.Milestone_3_Delivery_Date__c  && opp.Milestone_4_Delivery_Date__c < dEventStartDate) { opp.addError('Billing 4 date cannot less than Billing 3 date');
                        }
                        if ( opp.Milestone_5_Delivery_Date__c != oldOpp.Milestone_5_Delivery_Date__c &&  opp.Milestone_5_Delivery_Date__c  < opp.Milestone_4_Delivery_Date__c && opp.Milestone_5_Delivery_Date__c < dEventStartDate ) { opp.addError('Billing 5 date cannot less than Billing 4 date');
                        }
                        if ( opp.Milestone_6_Delivery_Date__c != oldOpp.Milestone_6_Delivery_Date__c && opp.Milestone_6_Delivery_Date__c  < opp.Milestone_5_Delivery_Date__c  && opp.Milestone_6_Delivery_Date__c < dEventStartDate ) { opp.addError('Billing 6 date cannot less than Billing 5 date');
                        }
                        if ( opp.Milestone_7_Delivery_Date__c != oldOpp.Milestone_7_Delivery_Date__c && opp.Milestone_7_Delivery_Date__c  < opp.Milestone_6_Delivery_Date__c && opp.Milestone_7_Delivery_Date__c < dEventStartDate ) { opp.addError('Billing 7 date cannot less than Billing 6 date');
                        }
                        if (opp.Milestone_8_Delivery_Date__c != oldOpp.Milestone_8_Delivery_Date__c &&  opp.Milestone_8_Delivery_Date__c  < opp.Milestone_7_Delivery_Date__c && opp.Milestone_8_Delivery_Date__c < dEventStartDate ) { opp.addError('Billing 8 date cannot less than Billing 7 date');
                        }
                        if (opp.Milestone_9_Delivery_Date__c != oldOpp.Milestone_9_Delivery_Date__c && opp.Milestone_9_Delivery_Date__c  < opp.Milestone_8_Delivery_Date__c && opp.Milestone_9_Delivery_Date__c < dEventStartDate) { opp.addError('Billing 9 date cannot less than Billing 8 date');
                        }
                        if ( opp.Milestone_10_Delivery_Date__c != oldOpp.Milestone_10_Delivery_Date__c &&  opp.Milestone_10_Delivery_Date__c < opp.Milestone_9_Delivery_Date__c && opp.Milestone_10_Delivery_Date__c < dEventStartDate ) { opp.addError('Billing 10 date cannot less than Billing 9 date');
                        }
                        if (opp.Milestone_11_Delivery_Date__c != oldOpp.Milestone_11_Delivery_Date__c && opp.Milestone_11_Delivery_Date__c < opp.Milestone_10_Delivery_Date__c && opp.Milestone_11_Delivery_Date__c < dEventStartDate ) { opp.addError('Billing 11 date cannot less than Billing 10 date');
                        }
                        if ( opp.Milestone_12_Delivery_Date__c != oldOpp.Milestone_12_Delivery_Date__c && opp.Milestone_12_Delivery_Date__c < opp.Milestone_11_Delivery_Date__c && opp.Milestone_12_Delivery_Date__c < dEventStartDate ) { opp.addError('Billing 12 date cannot less than Billing 11 date');
                        }

                        if (opp.Milestone_1_Amount__c < 0) { opp.addError('Amount must be in positive number: ' + opp.Milestone_1_Amount__c);
                        }

                        if (opp.Milestone_2_Amount__c  < 0) { opp.addError('Amount must be in positive number: ' + opp.Milestone_2_Amount__c);
                        }

                        if (opp.Milestone_3_Amount__c < 0) { opp.addError('Amount must be in positive number: ' + opp.Milestone_3_Amount__c);
                        }

                        if (opp.Milestone_4_Amount__c < 0) { opp.addError('Amount must be in positive number: ' + opp.Milestone_4_Amount__c);
                        }

                        if (opp.Milestone_5_Amount__c < 0) { opp.addError('Amount must be in positive number: ' + opp.Milestone_5_Amount__c);
                        }

                        if (opp.Milestone_6_Amount__c < 0) { opp.addError('Amount must be in positive number: ' + opp.Milestone_6_Amount__c);
                        }

                        if (opp.Milestone_7_Amount__c < 0) { opp.addError('Amount must be in positive number: ' + opp.Milestone_7_Amount__c);
                        }

                        if (opp.Milestone_8_Amount__c < 0) { opp.addError('Amount must be in positive number: ' + opp.Milestone_8_Amount__c);
                        }

                        if (opp.Milestone_9_Amount__c < 0) { opp.addError('Amount must be in positive number: ' + opp.Milestone_9_Amount__c);
                        }

                        if (opp.Milestone_10_Amount__c < 0) { opp.addError('Amount must be in positive number: ' + opp.Milestone_10_Amount__c);
                        }

                        if (opp.Milestone_11_Amount__c < 0) { opp.addError('Amount must be in positive number: ' + opp.Milestone_11_Amount__c);
                        }

                        if (opp.Milestone_12_Amount__c < 0) { opp.addError('Amount must be in positive number: ' + opp.Milestone_12_Amount__c);
                        }
                    } else if (opp.Custom_Payment__c && opp.Start_Date__c == null && opp.Total_No_of_payment__c != null && opp.Total_No_of_payment__c != 0 && opp.Amount != null && opp.Amount != 0) { opp.addError(system.label.Custom_Payment_Validation_Message1);
                    }

                    //All Closed Lost / Closed Won / CLosed Booked Validation Message.

                    String lblclosedwonmessage;
                    String lblClosedLostMessage;
                    String lblClosedBookedMessage;
                    lblclosedwonmessage = System.Label.closed_won_message;
                    lblClosedLostMessage = System.Label.Closed_Lost_Message;
                    lblClosedBookedMessage = System.Label.closed_booked_message;

                    if (opp.Payment_Status__c == 'Paid' && oldOpp.Payment_Status__c != 'Paid') {
                        opp.StageName = 'Closed Booked';
                    } else if ((opp.Payment_Status__c == 'Partial Paid' && oldOpp.Payment_Status__c != 'Partial Paid') || (opp.Payment_Status__c == 'Invoice' && oldOpp.Payment_Status__c != 'Invoice')) {
                        opp.StageName = 'Closed Won';
                        opp.Status__c = 'Awaiting Payment';                  
                    }

                    if (oldOpp.StageName.equals('Closed Won') || oldOpp.StageName.equals('Closed Lost') || oldOpp.StageName.equals('Closed Booked')) {
                        Application_Bypass__c appbypass = Application_Bypass__c.getInstance();
                        if (oldOpp.StageName.equals('Closed Booked') && !appbypass.Bypass_Validation_Rules__c && (!Utility.isAsync() && Utility.byPassClosedWon == false) && (oldOpp.Name == Opp.name && oldOpp.Owner.Id == Opp.Owner.Id && oldOpp.Marketing_Contact__c == Opp.Marketing_Contact__c && oldOpp.MarkitMkr_Contact__c == Opp.MarkitMkr_Contact__c && oldOpp.Local_Representative__c == Opp.Local_Representative__c && oldOpp.Legal_Representative_2__c == Opp.Legal_Representative_2__c && oldOpp.Legal_Representative_1__c == Opp.Legal_Representative_1__c && oldOpp.Nota_Fiscal__c == Opp.Nota_Fiscal__c && oldOpp.Operation_Contact_2__c == Opp.Operation_Contact_2__c && oldOpp.Operation_Contact_3__c == Opp.Operation_Contact_3__c && oldOpp.Operation_Contact_4__c == Opp.Operation_Contact_4__c && oldOpp.Operation_Contact_5__c == Opp.Operation_Contact_5__c && oldOpp.Operations_Contact__c == Opp.Operations_Contact__c && oldOpp.Safety_Contact__c == Opp.Safety_Contact__c && oldOpp.Stand_Contractor__c == Opp.Stand_Contractor__c && oldOpp.Agreement_Contact__c == Opp.Agreement_Contact__c ) && (oldOpp.Do_not_activate_Billing__c == Opp.Do_not_activate_Billing__c && oldOpp.Status__c.equals('Awaiting Payment')) && oldOpp.Tax_Rule_SAP__c != Opp.Tax_Rule_SAP__c && Opp.Tax_Rule_SAP__c != 'UAE VAT Refund') { opp.AddError(lblclosedwonmessage);
                        } else if (oldOpp.StageName.equals('Closed Lost') && !appbypass.Bypass_Validation_Rules__c && (!Utility.isAsync() && Utility.byPassClosedWon == false)) { opp.AddError(lblClosedLostMessage);
                        } else if (oldOpp.StageName.equals('Closed Booked') && !appbypass.Bypass_Validation_Rules__c && (!Utility.isAsync() && Utility.byPassClosedWon == false) && (oldOpp.Name == Opp.name && oldOpp.Marketing_Contact__c == Opp.Marketing_Contact__c && oldOpp.MarkitMkr_Contact__c == Opp.MarkitMkr_Contact__c && oldOpp.Local_Representative__c == Opp.Local_Representative__c && oldOpp.Legal_Representative_2__c == Opp.Legal_Representative_2__c && oldOpp.Legal_Representative_1__c == Opp.Legal_Representative_1__c && oldOpp.Nota_Fiscal__c == Opp.Nota_Fiscal__c && oldOpp.Operation_Contact_2__c == Opp.Operation_Contact_2__c && oldOpp.Operation_Contact_3__c == Opp.Operation_Contact_3__c && oldOpp.Operation_Contact_4__c == Opp.Operation_Contact_4__c && oldOpp.Operation_Contact_5__c == Opp.Operation_Contact_5__c && oldOpp.Operations_Contact__c == Opp.Operations_Contact__c && oldOpp.Safety_Contact__c == Opp.Safety_Contact__c && oldOpp.Stand_Contractor__c == Opp.Stand_Contractor__c && oldOpp.Agreement_Contact__c == Opp.Agreement_Contact__c ) && (oldOpp.Do_not_activate_Billing__c == Opp.Do_not_activate_Billing__c && oldOpp.Status__c.equals('Awaiting Payment')) ) { opp.AddError(lblClosedBookedMessage);
                        }
                    }
                }
            }
        } catch (exception ex) {
            Utility.logError(ex.getMessage(), ex.getCause(), ex.getLineNumber(), ex.getStackTraceString(), 'UpdateQuoteStatus(@quoteStatusUpdate)');
        }
    }
}