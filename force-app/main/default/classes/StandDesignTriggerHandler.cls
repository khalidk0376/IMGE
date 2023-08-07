/**
    * @Created By    :  Girikon(Shashank)
    * @Created On    :  20/08/2018
    * @Modified by   :  Girikon(Shashank[Aug 20 2018],Sunil[CCEN-617 Jan 23 2019])
    * @description   : This handler class provides following functionalities:          
    *                  -Copy the fields of stand design to boothcontarctorMapping status field.          
    * @Test Class    : StandDesignTrigger_Test(100%)
    **/
    public class StandDesignTriggerHandler {
    //  method to copy the  Booth_Design_Status__c fields of stand design to boothcontarctorMapping status field
    public static void updateBoothContractorMapping(list<Stand_Design__c>  listStandDesignNew){
            System.debug('listStandDesignNew-'+listStandDesignNew);
            Set<id> setbothCntorMappgIds = new Set<id>();
            for(Stand_Design__c standDesignObj :listStandDesignNew ){
                setbothCntorMappgIds.add(standDesignObj.BoothContractorMapping__c);
            }
            
            // fetching  BoothContractorMapping records
            Map<id,BoothContractorMapping__c> mapBothCntorMapDB  = new Map<id,BoothContractorMapping__c>([SELECT id,Booth_Design_Status__c FROM BoothContractorMapping__c WHERE id IN: setbothCntorMappgIds]);
            List<BoothContractorMapping__c> listUpdateBothCntrtorMappg = new  List<BoothContractorMapping__c>();
            if(mapBothCntorMapDB.size()>0){
                for(Stand_Design__c standDesignObj : listStandDesignNew){
                    if(mapBothCntorMapDB.containsKey(standDesignObj.BoothContractorMapping__c)){
                        if(mapBothCntorMapDB.get(standDesignObj.BoothContractorMapping__c) != null)
                        {
                            mapBothCntorMapDB.get(standDesignObj.BoothContractorMapping__c).Booth_Design_Status__c = standDesignObj.Booth_Design_Status__c;
                            mapBothCntorMapDB.get(standDesignObj.BoothContractorMapping__c).IsAgree__c = standDesignObj.Contractor_Agreement_CA__c;//[CCEN-617]
                            listUpdateBothCntrtorMappg.add(mapBothCntorMapDB.get(standDesignObj.BoothContractorMapping__c));
                        }   
                    }
                }
                
                //create a map that will hold the values of the list 
                   Map<id,BoothContractorMapping__c> MappgBothCntorMapDB  = new Map<id,BoothContractorMapping__c>();

                 //put all the values from the list to map. 
                    MappgBothCntorMapDB.putall(listUpdateBothCntrtorMappg);
              
                if(MappgBothCntorMapDB.size()>0 && Schema.sObjectType.BoothContractorMapping__c.isUpdateable()){
                    update MappgBothCntorMapDB.values();
                    System.debug('MappgBothCntorMapDB-'+MappgBothCntorMapDB);
                }
            }
        } 
    }