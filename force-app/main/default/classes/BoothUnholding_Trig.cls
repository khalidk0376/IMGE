/**
* Project:     GAP
* Date:        Sep 01, 2016
* Test Class:  BoothUnholding_Test
* Created By:  Kumar Gaurav
* Modified and created : Rajesh Kumar on 28/03/2019
* *************************************************************************
* @description This class used from quoteline item trigger QuotelineMerge to release booths if all QLI is deleted for Booths
               from Opportunity.
* *************************************************************************
* We are replicated funcationality from both triggers, which is runing on Quote line trigger.
*/

public with sharing class BoothUnholding_Trig implements TriggerInterface_QuoteLine.Runnable {
    set <id> objQLProdIds = new set <id> ();
    List <String> lstBoothToRelease = new List <String> ();
    List <String> lstBoothToUpdate = new List <String> ();
    Set<String> setBoothNos = new Set<String>();
    Map<Id , SBQQ__QuoteLine__c> mapMasterOppQLI = new Map<Id , SBQQ__QuoteLine__c>();
    Set<Id> setquoteID = new Set<Id>();
    List<SBQQ__QuoteLine__c> lstQuoteLines = new List<SBQQ__QuoteLine__c>();
    public void run(TriggerInterface_QuoteLine.Trig trig) {
        if (trig.isBefore) {
            try {
                for (SBQQ__QuoteLine__c objQL : trig.newList) {
                    if (objQL.SBQQ__Product__c != null) {
                        objQLProdIds.add(objQL.SBQQ__Product__c);
                    }
                }

                Map<Id, product2> mapproduct = new Map<Id, product2>([select id, Deliverables__c from product2 where Id IN: objQLProdIds]);
                system.debug('mapproduct: ' + mapproduct);
                for (SBQQ__QuoteLine__c objQL :  trig.newList) {
                    if (String.isNotBlank(mapproduct.get(objQL.SBQQ__Product__c).Deliverables__c) && String.isBlank(objQL.Deliverables__c)) {    objQL.Deliverables__c = mapproduct.get(objQL.SBQQ__Product__c).Deliverables__c;     }
                }
            } catch (exception ex) {   Utility.logError(ex.getMessage(), ex.getCause(), ex.getLineNumber(), ex.getStackTraceString(), 'SBQQ__QuoteLine__c.obj(@BoothUnholding_class before insert)');    }
            if (trig.IsInsert && !Utility.isRebookInProcess) {

                for (SBQQ__QuoteLine__c oQuoteLine : trig.newList) {
                    setquoteID.add(oQuoteLine.SBQQ__Quote__c);
                }

                if (setquoteID != null && setquoteID.size() > 0 ) {
                    List<SBQQ__Quote__c> lstQuote = [SELECT SBQQ__MasterContract__r.SBQQ__Quote__c, Parent_Opp_Primary_Quote_Total__c , SBQQ__Type__c FROM SBQQ__Quote__c WHERE Id = :setquoteID];
                    if (!lstQuote.isEmpty() && lstQuote[0].SBQQ__Type__c == 'Amendment') {
                        if (lstQuote[0].SBQQ__MasterContract__r.SBQQ__Quote__c != null) {
                            lstQuoteLines = [SELECT SBQQ__Number__c, Booth_Number__c, Line_Description__c FROM SBQQ__QuoteLine__c Where SBQQ__Quote__c = : lstQuote[0].SBQQ__MasterContract__r.SBQQ__Quote__c AND Booth__c = true LIMIT 5000];
                            if (!lstQuoteLines.isEmpty()) {      for (SBQQ__QuoteLine__c oQLI : lstQuoteLines) {   mapMasterOppQLI.put(oQLI.Id , oQLI);   }  }
                        }
                    }
                    System.debug('');
                    if (!mapMasterOppQLI.isEmpty()) {
                        for (SBQQ__QuoteLine__c oQuoteLine : trig.newList) {
                            for (SBQQ__QuoteLine__c oQuoteLineMasterOpp : mapMasterOppQLI.values()) {
                                //if (mapMasterOppQLI.containsKey(oQuoteLineMasterOpp.Id)) {
                                    oQuoteLine.Booth__c = true;                                    
                                    oQuoteLine.Booth_Number__c = mapMasterOppQLI.get(oQuoteLineMasterOpp.Id).Booth_Number__c;
                                    //oQuoteLine.SBQQ__Number__c = mapMasterOppQLI.get(oQuoteLineMasterOpp.Id).SBQQ__Number__c;                                    
                                    oQuoteLine.Line_Description__c = mapMasterOppQLI.get(oQuoteLineMasterOpp.Id).Line_Description__c;
                                    Utility.isAmendmentProcess = true;
                                //}
                            }
                        }
                    }
                    if (!lstQuote.isEmpty() && lstQuote[0].Parent_Opp_Primary_Quote_Total__c != null ) {
                        for ( SBQQ__QuoteLine__c oQuoteLine : trig.newList) {
                            oQuoteLine.Parent_Opp_Primary_Quote_Total__c = lstQuote[0].Parent_Opp_Primary_Quote_Total__c; Utility.isAmendmentProcess = true;
                        }
                    }
                }
            }

            if (trig.isUpdate && !Utility.isRebookInProcess) {
                try {
                    for (SBQQ__QuoteLine__c oQuoteLine : trig.newList) {
                        if (oQuoteLine.SBQQ__Quantity__c != trig.oldMap.get(oQuoteLine.Id).SBQQ__Quantity__c && oQuoteLine.SBQQ__Quantity__c == 0 && oQuoteLine.Booth_Number__c != null && oQuoteLine.Booth__c == true) {
                            oQuoteLine.Line_Description__c = null;                            setBoothNos.add(oQuoteLine.Booth_Number__c);
                            //setBoothNos.add(oQuoteLine.Expocad_Opportunity__c);
                        }
                    }
                    if (!setBoothNos.isEmpty()) {
                        List<ExpocadBooth__c> lstToUpdateBoothStatus = [SELECT Last_Action_Date__c, Status__c FROM ExpocadBooth__c WHERE Booth_Number__c IN :setBoothNos AND Status__c != 'Released' LIMIT 1000];
                        if (lstToUpdateBoothStatus != NULL && !lstToUpdateBoothStatus.isEmpty()) {
                            for (ExpocadBooth__c oExpocadBooth : lstToUpdateBoothStatus) {                                oExpocadBooth.Status__c = 'Released';  oExpocadBooth.Last_Action_Date__c = Date.today();                             }
                            update lstToUpdateBoothStatus;
                        }
                    }
                } catch (exception ex) {  Utility.logError(ex.getMessage(), ex.getCause(), ex.getLineNumber(), ex.getStackTraceString(), 'SBQQ__QuoteLine__c.obj(@BoothUnholding_class before Update)');}
            }
        }
        if (trig.isDelete && trig.isAfter) {
            set<String> setBoothNumber = new set<String>();
            set<String> setOppId = new set<String>();
            set<String> setBoothNumbers = new set<String>();
            set<String> setOppIdParent = new set<String>();
            if (trig.isDelete ) {
                for (SBQQ__QuoteLine__c oQuoteLine : trig.oldMap.values()) {
                    if (oQuoteLine.Booth__c && oQuoteLine.Booth_Number__c != null && oQuoteLine.ParentOpportunity_ID__c == null) {
                        setBoothNumber.add(oQuoteLine.Booth_Number__c);
                        setOppId.add(oQuoteLine.Opportunity_ID__c);
                    } else if (oQuoteLine.Booth__c && oQuoteLine.Booth_Number__c != null && oQuoteLine.ParentOpportunity_ID__c != null) {
                        setBoothNumbers.add(oQuoteLine.Booth_Number__c);
                        setOppIdParent.add(oQuoteLine.Opportunity_ID__c);
                    }
                }

                if (setBoothNumber.size() > 0 && setOppId.size() > 0 ) {
                    List <SBQQ__QuoteLine__c> lstQLI = [SELECT ID FROM SBQQ__QuoteLine__c WHERE Booth_Number__c = : setBoothNumber and Opportunity_ID__c != null and Opportunity_ID__c = : setOppId and ParentOpportunity_ID__c = null LIMIT 1000];
                    if (lstQLI == null || lstQLI.size() == 0) {
                        for (SBQQ__QuoteLine__c oQuoteLine : trig.oldMap.values()) {
                            lstBoothToRelease.add(oQuoteLine.Booth_Number__c);
                            lstBoothToRelease.add(oQuoteLine.Opportunity_ID__c);
                        }
                    }
                }

                if (setBoothNumbers.size() > 0 && setOppIdParent.size() > 0 ) {
                    List <SBQQ__QuoteLine__c> lstQLIParentOpp = [SELECT Id FROM SBQQ__QuoteLine__c WHERE Booth_Number__c = : setBoothNumbers and Opportunity_ID__c != null and Opportunity_ID__c = : setOppIdParent and ParentOpportunity_ID__c != null LIMIT 1000];
                    if (lstQLIParentOpp == null || lstQLIParentOpp.size() == 0) {
                        for (SBQQ__QuoteLine__c oQuoteLine : trig.oldMap.values()) {
                            lstBoothToUpdate.add(oQuoteLine.Booth_Number__c);
                            lstBoothToUpdate.add(oQuoteLine.Opportunity_ID__c);
                        }
                    }
                }

                if (lstBoothToRelease.size() > 0) {
                    List <ExpocadBooth__c> lstToUpdateBoothStatus = [SELECT Last_Action_Date__c, Status__c FROM ExpocadBooth__c WHERE Booth_Number__c IN: lstBoothToRelease AND Opportunity__c IN: lstBoothToRelease LIMIT 1000];
                    if (lstToUpdateBoothStatus != null && lstToUpdateBoothStatus.size() > 0) {
                        for (ExpocadBooth__c oExpocadBooth : lstToUpdateBoothStatus) {
                            oExpocadBooth.Status__c = 'Released';
                            oExpocadBooth.Last_Action_Date__c = Date.today();
                        }
                        update lstToUpdateBoothStatus;
                    }
                } else if (lstBoothToUpdate.size() > 0) {
                    List <ExpocadBooth__c> lstToUpdateBoothStatus = [SELECT AddedToQLI__c, Last_Action_Date__c, Status__c FROM ExpocadBooth__c WHERE Booth_Number__c IN: lstBoothToUpdate AND AddedToQLI__c = true AND Opportunity__r.Parent_Opportunity__c != null AND Opportunity__c IN: lstBoothToUpdate LIMIT 1000];
                    if (lstToUpdateBoothStatus != null && lstToUpdateBoothStatus.size() > 0) {
                        for (ExpocadBooth__c oExpocadBooth : lstToUpdateBoothStatus) {
                            oExpocadBooth.AddedToQLI__c = false;
                        }
                        update lstToUpdateBoothStatus;
                    }
                }
            }
        }
    }
}