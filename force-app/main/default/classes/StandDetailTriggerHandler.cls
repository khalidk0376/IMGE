/**
 * Created By:  Girikon(Shashank)
 * Created On:  20/08/2018
* @description :This trigger class on Stand_Detail__c object provides following functionalities:          
*             -copy the  stand details fields to boothcontarctorMapping fields.
* Test Class    : StandDetailTrigger_Test(100%)
 * Modified by :  Girikon(Shashank,Ashish,Sunil)
 * Modified On: 20/08/2018,16/10/2018,  Girikon(Ashish)[CCEN-699 (march 5 2019)]
 * Ticket No   : BK-14521 Updating API Version
**/
public class StandDetailTriggerHandler {
     // copy the  stand details fields to boothcontarctorMapping fields. 
     public static void updateBoothContractorMapping(List<Stand_Detail__c> listNewStandDetail   ){
        System.debug('listNewStandDetail-'+listNewStandDetail);
        Set<id> setbothCntorMappgIds = new Set<id>();
        for(Stand_Detail__c standDetailObj :listNewStandDetail )
        {
            setbothCntorMappgIds.add(standDetailObj.BoothContractorMapping__c);
        }        
        // fetchingh  BoothContractorMapping records
       Map<id,BoothContractorMapping__c> mapBothCntorMapDB  = new Map<id,BoothContractorMapping__c>([SELECT id,IsRigging__c,Riggering_Options__c,Performance_Bond_Submitted__c,IsAgree__c,IsDoubleDecker__c FROM BoothContractorMapping__c WHERE id IN: setbothCntorMappgIds]);
       List<BoothContractorMapping__c> listUpdateBothCntrtorMappg = new  List<BoothContractorMapping__c>();
        if(mapBothCntorMapDB.size()>0)
        {
           for(Stand_Detail__c standDetailObj : listNewStandDetail)
           {
               if(mapBothCntorMapDB.containsKey(standDetailObj.BoothContractorMapping__c) && mapBothCntorMapDB.get(standDetailObj.BoothContractorMapping__c) != null)
               {
                   if(standDetailObj.Riggering_Options__c != null) //CCEN-699
                   {
                       mapBothCntorMapDB.get(standDetailObj.BoothContractorMapping__c).Riggering_Options__c = standDetailObj.Riggering_Options__c;
                   }else
                   {    
                       mapBothCntorMapDB.get(standDetailObj.BoothContractorMapping__c).Riggering_Options__c = '';
                   }
                    mapBothCntorMapDB.get(standDetailObj.BoothContractorMapping__c).IsRigging__c = standDetailObj.IsRigging__c;                                      
                    mapBothCntorMapDB.get(standDetailObj.BoothContractorMapping__c).Performance_Bond_Submitted__c = standDetailObj.IsReceived__c;                   
                    mapBothCntorMapDB.get(standDetailObj.BoothContractorMapping__c).IsAgree__c = standDetailObj.Contractor_Agreement_CA__c;
                    mapBothCntorMapDB.get(standDetailObj.BoothContractorMapping__c).IsDoubleDecker__c = standDetailObj.IsDoubleDecker__c;                    
                   //CCEN-432  update details submitted status 
                   mapBothCntorMapDB.get(standDetailObj.BoothContractorMapping__c).Booth_Detail_Status__c = 'Submitted';            
                   listUpdateBothCntrtorMappg.add(mapBothCntorMapDB.get(standDetailObj.BoothContractorMapping__c));
               }
           }
            //updating the list of BoothContractorMapping__c
            if(listUpdateBothCntrtorMappg.size()>0 && Schema.sObjectType.BoothContractorMapping__c.isUpdateable()){
                update listUpdateBothCntrtorMappg;
                System.debug('listUpdateBothCntrtorMappg-'+listUpdateBothCntrtorMappg);

            }
        
        } 
    }

}