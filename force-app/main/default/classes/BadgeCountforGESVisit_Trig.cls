/**
* Created By    :  Girikon(Aishwarya)[BK-9194/9188]
* Created On    :  15/10/2020
* @description  :  This class is used for updating the total badges field on opportunity expocad booth mapping record on basis of assign booth size badge limit setting.
* Test Class    :  BadgeCountforGESVisit_Trig_Test
* Modified By   :  [Aishwarya BK-13687 23 March 2021]
**/
public with sharing class BadgeCountforGESVisit_Trig implements TriggerInterface_BoothSizeBadgeLimit.Runnable{
    public void run(TriggerInterface_BoothSizeBadgeLimit.Trig trig)
    {
        if(trig.isAfter && (trig.isUpdate || trig.isInsert))
        {
            Set<string> setEventEditionIds = new Set<string>();
            for(Booth_Size_Badge_Limit__c boothLimit :trig.Newlist){
                if(boothLimit.Event_Edition__c != null){
                    setEventEditionIds.add(boothLimit.Event_Edition__c);
                }
            }
            //system.debug('=========================='+setEventEditionIds);
            if(setEventEditionIds.size() > 0){
                database.executeBatch(new updateBadgeCountforGESVisit(setEventEditionIds)); // Calling batch class.
            }
        }
    }
}