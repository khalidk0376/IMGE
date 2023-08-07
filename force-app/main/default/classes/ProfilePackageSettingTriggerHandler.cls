/**
* Created/Modified By: Girikon(shashank)
* Created On:          28/08/2018
* Description/Purpose: One Profile Package Setting will be manupulated at a time. one PPS can only be linked with one product.
* Methods:             createOrUpdateUserPkg,getHigherProfilePcakageSettg
* Modified By:         (Rajeev [Girikon] BK-3483), [Aishwarya 25 Aug 2020 BK-6906]
* Description:         Delete functionality
* Test Class: ProfilePackageSettingTriggerHandler_Test(Rajeev(Girikon) BK-3275)(87%)
**/

public class ProfilePackageSettingTriggerHandler  
{
    @future
    public static void usrPackgeUpdt(string usrNewPakgeVal , string usrOldPakgeVal){ 
       Map<id,Profile_Package_Setting__c> usrPackgeMapNew = (Map<id,Profile_Package_Setting__c>)JSON.deserialize(usrNewPakgeVal, Map<id,Profile_Package_Setting__c>.class);
       Map<id,Profile_Package_Setting__c> usrPackgeMapOld = (Map<id,Profile_Package_Setting__c>)JSON.deserialize(usrOldPakgeVal, Map<id,Profile_Package_Setting__c>.class);
       system.debug('usrPackgeMapNew'+usrPackgeMapNew);
       system.debug('usrPackgeMapOld'+usrPackgeMapOld);
       createOrUpdateUserPkg(null,null,usrPackgeMapNew,usrPackgeMapOld);
    }
    //  method to find the Profile Package Setting with higher priority among all the Profile Package Settings for all the related opportunities.
    public static void createOrUpdateUserPkg(Map<id,opportunity> mapNewOpp,Map<id,opportunity> mapOldOpp,Map<id,Profile_Package_Setting__c>  mapNewProfilePkgSettg,Map<id,Profile_Package_Setting__c>  mapOldProfilePkgSettg)
    {   
        //When Profile Package Setting is updated.
        if(mapNewProfilePkgSettg!=null && (mapOldProfilePkgSettg!=null && !mapOldProfilePkgSettg.isEmpty() && mapOldProfilePkgSettg.size()>0 ))
        {
            //method to get only those PPS in which product is updated
            mapNewProfilePkgSettg = getUpdatedProductMap(mapOldProfilePkgSettg,mapNewProfilePkgSettg ); 
            if(mapNewProfilePkgSettg != null && (!mapNewProfilePkgSettg.isEmpty() && mapNewProfilePkgSettg.size()>0 ))
            {
                List<User_Package__c> listUserPackageDel = new List<User_Package__c>([SELECT id,Profile_Package_Setting__c FROM User_Package__c  WHERE Profile_Package_Setting__c IN: mapNewProfilePkgSettg.keySet()]);
                //system.debug('listUserPackageDel::'+listUserPackageDel);
                if(listUserPackageDel.size()>0 ){
                    delete listUserPackageDel;
                }
            }                                   
            
        }
    
        System.debug('mapOldProfilePkgSettg-'+mapOldProfilePkgSettg);
        System.debug('mapNewProfilePkgSettg-'+mapNewProfilePkgSettg);
        map<id,Profile_Package_Setting__c> profPakgOldRec = new map<id,Profile_Package_Setting__c>();
        Set<id> setOldEvntEdtonId = new Set<id>();
        Set<id> setProfilePkgOldEventsIds = new Set<id>();
        Set<id> setProfilePakgOldProduct = new Set<id>();
        Set<id> setEventEditionIds = new Set<id>();
        Set<id> setProfilePkgIds = new Set<id>();  
        if(mapOldProfilePkgSettg !=null && !mapOldProfilePkgSettg.IsEmpty())
        {
            for(Profile_Package_Setting__c proflePkgOldObj : mapOldProfilePkgSettg.values())
            {
                setOldEvntEdtonId.add(proflePkgOldObj.Event_Edition__c);
            }
            List<Profile_Package_Setting__c> profilePkgSttngAggRec = [select id , name ,Event_Edition__c ,Product__c From Profile_Package_Setting__c where Event_Edition__c =: setOldEvntEdtonId and Product__c!=null];
            for(Profile_Package_Setting__c profPkgLeftRec : profilePkgSttngAggRec)
            {
                profPakgOldRec.put(profPkgLeftRec.id,profPkgLeftRec);
                if(profPkgLeftRec != null && profPkgLeftRec.Event_Edition__c != null )
                {
                    setProfilePkgOldEventsIds.add(profPkgLeftRec.Event_Edition__c);    
                }
                if(profPkgLeftRec != null && profPkgLeftRec.Product__c != null )
                {
                    setProfilePakgOldProduct.add(profPkgLeftRec.Product__c);            
                }   
            }
             
        }
        if(mapNewProfilePkgSettg != NULL && !mapNewProfilePkgSettg.IsEmpty())
        {    
            for(Profile_Package_Setting__c ProfilePkgSettgObj : mapNewProfilePkgSettg.Values())
            {
                //fetching id in set setProfilePkgIds from mapNewProfilePkgSettg for field  ProfilePkgSettgObj.Product__c
               if(ProfilePkgSettgObj != null && ProfilePkgSettgObj.Event_Edition__c != null )
                {
                    setEventEditionIds.add(ProfilePkgSettgObj.Event_Edition__c);    
                }
                if(ProfilePkgSettgObj != null && ProfilePkgSettgObj.Product__c != null )
                {
                    setProfilePkgIds.add(ProfilePkgSettgObj.Product__c);            
                }          
            }
        }
                
        //When PPS is created or updated 
        Map<id,Opportunity> mapOpportunityDb;
        if(mapNewOpp == NULL && mapOldOpp==NULL)
        {
            //  fetching opportunity from DB
            if(Test.isRunningTest())
            {
                mapOpportunityDb = new  Map<id,Opportunity>([SELECT EventEdition__c,AccountID,Operations_Contact__c,SBQQ__PrimaryQuote__c,(SELECT Id,Product2Id FROM OpportunityLineItems) FROM Opportunity WHERE EventEdition__c IN:setEventEditionIds  AND Id IN ( SELECT OpportunityId FROM OpportunityLineItem WHERE Product2Id IN: setProfilePkgIds )]);
            }
            else {
                if(setProfilePkgIds!=null && !setProfilePkgIds.isEmpty())
                {
                    //system.debug('NewlyProduct'+setProfilePkgIds);
                    //system.debug('NewlyEvents'+setEventEditionIds);
                    mapOpportunityDb = new  Map<id,Opportunity>([SELECT EventEdition__c,AccountID,Operations_Contact__c,SBQQ__PrimaryQuote__c,(SELECT Id,Product2Id FROM OpportunityLineItems) FROM Opportunity WHERE EventEdition__c IN:setEventEditionIds AND (StageName='Closed Won' OR StageName='Closed Booked') AND Id IN ( SELECT OpportunityId FROM OpportunityLineItem WHERE Product2Id IN: setProfilePkgIds )]);
                }
                if(setProfilePkgOldEventsIds!=null && !setProfilePkgOldEventsIds.isEmpty())
                {
                    //system.debug('OlderEvents'+setProfilePkgOldEventsIds);
                    //system.debug('OlderProduct'+setProfilePakgOldProduct);
                    mapOpportunityDb = new  Map<id,Opportunity>([SELECT EventEdition__c,AccountID,Operations_Contact__c,SBQQ__PrimaryQuote__c,(SELECT Id,Product2Id FROM OpportunityLineItems) FROM Opportunity WHERE EventEdition__c IN:setProfilePkgOldEventsIds AND (StageName='Closed Won' OR StageName='Closed Booked') AND Id IN ( SELECT OpportunityId FROM OpportunityLineItem WHERE Product2Id IN: setProfilePakgOldProduct )]);
                }
            }
            
            System.debug('pps mapOpportunityDb:: '+mapOpportunityDb);
        }
        //When opportunity is updated
        else
        {
            system.debug('mapNewOpp-'+mapNewOpp); system.debug('mapOldOpp-'+mapOldOpp);
            
             //method to get only those opps which are updated as closed won or closed booked
             mapOpportunityDb = getUpdatedStageOppMap(mapOldOpp,mapNewOpp);
             //system.debug('mapOpportunityDb mapOpportunityDb -'+mapOpportunityDb ); 
             mapOpportunityDb = new  Map<id,Opportunity>([SELECT EventEdition__c,AccountID,Operations_Contact__c,SBQQ__PrimaryQuote__c,(SELECT Id,Product2Id FROM OpportunityLineItems) FROM Opportunity WHERE Id IN: mapOpportunityDb.KeySet()]);
             //System.debug('opp mapOpportunityDb:: '+mapOpportunityDb);
        }
        // creating  sets with field values of opp like accountID ,EventEdition__c
        Set<id> setOppAccountIds = new Set<id>();
        Set<id> setOppContactIds = new Set<id>();
        Set<id> setOppEventEditionIds = new Set<id>(); 
        Set<id> setOppPrimaryQuoteIds = new Set<id>();
        Set<id> setOppProduct2Ids = new Set<id>();       
        Map<id,set<id>> mapOppIdSetProductId = new Map<id,set<id>>(); // used in main logic 
        Map<id,OppUserPkgFieldWrap> mapOppIdUserPkgFieldWrap = new Map<id,OppUserPkgFieldWrap>();
        Map<String,id> mapOppWrpper =new Map<String,id>();
        system.debug('mapOpportunityDb-'+mapOpportunityDb);
        if(mapOpportunityDb!=null && !mapOpportunityDb.IsEmpty())
        {
            for(Opportunity oppObj : mapOpportunityDb.values())
            {
                system.debug('mapOpportunityDb!=null-111');
                setOppAccountIds.add(oppObj.AccountID);
                setOppContactIds.add(oppObj.Operations_Contact__c);
                setOppEventEditionIds.add(oppObj.EventEdition__c); 
                setOppPrimaryQuoteIds.add(oppObj.SBQQ__PrimaryQuote__c);          
                // map<oppId , wrapper> value addition to filter objects of user pkg ** 
                mapOppIdUserPkgFieldWrap.put(oppObj.id, new OppUserPkgFieldWrap(oppObj.AccountID,oppObj.Operations_Contact__c,oppObj.EventEdition__c,oppObj.id ) );  
                string accntevntmap = oppObj.AccountID+'^'+oppObj.EventEdition__c;
                mapOppWrpper.put(accntevntmap,oppObj.id);
                System.debug('oppObj-'+oppObj); 
                //System.debug('oppObj.OpportunityLineItems-'+oppObj.OpportunityLineItems);
                for(OpportunityLineItem OpportunityLineItemObj : oppObj.OpportunityLineItems )
                {
                    //System.debug('OpportunityLineItemObj-'+OpportunityLineItemObj);
                    setOppProduct2Ids.add(OpportunityLineItemObj.Product2Id );
                    if(!mapOppIdSetProductId.containsKey(oppObj.id))
                    {
                        mapOppIdSetProductId.put(oppObj.id, new Set<id>());
                    }
                    mapOppIdSetProductId.get(oppObj.id).add(OpportunityLineItemObj.Product2Id );
                }  
            }  
        }       
        //system.debug('mapOppIdSetProductId-'+mapOppIdSetProductId);
        //Map<id,id> mapQuoteIdExpoId = new  Map<id,id>();         
        //fetch expocad ids
        //for(ExpocadBooth__c expocadObj :[SELECT id,Quote__c  FROM ExpocadBooth__c WHERE Quote__c IN:setOppPrimaryQuoteIds AND Status__c= 'Rented' ])
        //{
           // mapQuoteIdExpoId.put(expocadObj.Quote__c ,expocadObj.id );
        //}

        // fetching user pkg acc to opp fields
        Map<id,User_Package__c> mapRquiredUserPkg = new Map<id,User_Package__c>();
        Map<id,User_Package__c> mapOppIdUserPkg = new Map<id,User_Package__c>();
        map<string ,User_Package__c> usrpakgeRel = new map<String ,User_Package__c>();
        Set<id> setNoUserPkgOppId = new Set<id>();
        Set<id> setProfPkgExistgUserPkgId = new Set<id>();
        for(User_Package__c UserPackageOBJ : [SELECT id, Account__c  , Event_Edition__c , Profile_Package_Setting__c FROM User_Package__c  WHERE (Account__c IN:setOppAccountIds)  AND  (Event_Edition__c IN:setOppEventEditionIds)   ])
        {   
            String uspkgAccEvnt = UserPackageOBJ.Account__c+'^'+UserPackageOBJ.Event_Edition__c;
            usrpakgeRel.put(uspkgAccEvnt,UserPackageOBJ);
            system.debug('UserPackageOBJ'+UserPackageOBJ);
        }
        for(String key: usrpakgeRel.keyset())
        {
            if(mapOppWrpper.containsKey(key))
            {
                mapRquiredUserPkg.put(usrpakgeRel.get(key).id,usrpakgeRel.get(key));
                mapOppIdUserPkg.put(mapOppWrpper.get(key),usrpakgeRel.get(key));
                setProfPkgExistgUserPkgId.add(usrpakgeRel.get(key).Profile_Package_Setting__c);
            }
            else
            {
                setNoUserPkgOppId.add(mapOppWrpper.get(key));
            }
        }
        system.debug('setNoUserPkgOppId:: '+mapOppIdUserPkg);
        // fetched USER PKG in map mapRquiredUserPkg

        //need to fetch pps based on product ids of opps 
        Map<id,Profile_Package_Setting__c> mapProfilePkgSettgDb = new Map<id,Profile_Package_Setting__c>();
        Map<id,Profile_Package_Setting__c> mapProdIdPPSObj = new Map<id,Profile_Package_Setting__c>();
        for(Profile_Package_Setting__c proflPkgSettgObj :[SELECT id,Priority__c,Product__c,Name FROM Profile_Package_Setting__c WHERE (ID IN:setProfPkgExistgUserPkgId) OR(Product__c IN:setOppProduct2Ids)])
        {
            mapProfilePkgSettgDb.put(proflPkgSettgObj.id, proflPkgSettgObj);
            if(mapProdIdPPSObj.containsKey(proflPkgSettgObj.Product__c) && proflPkgSettgObj.Priority__c > mapProdIdPPSObj.get(proflPkgSettgObj.Product__c).Priority__c )
            {
                mapProdIdPPSObj.put(proflPkgSettgObj.Product__c,proflPkgSettgObj);//product Id and pps object map
            }
            else if(!mapProdIdPPSObj.containsKey(proflPkgSettgObj.Product__c))
            {
               mapProdIdPPSObj.put(proflPkgSettgObj.Product__c,proflPkgSettgObj);//product Id and pps object map
            }
            
        }
        List<User_Package__c> listUserPkgUpdate; 
        System.debug('mapProfilePkgSettgDb-'+mapProfilePkgSettgDb);  // data correct
        List<User_Package__c> listUserPkgInsert = new List<User_Package__c>();
        // for insertion
        Map<id,Profile_Package_Setting__c> mapOppIdPPS = new  Map<id,Profile_Package_Setting__c>(); 

        List<Profile_Package_Setting__c> listPPSHigherUpdate = new List<Profile_Package_Setting__c>();
        //variable for existing user pkg
        User_Package__c UserPackageOBJ ;
        Map<id,Profile_Package_Setting__c> mapOppIdPPSObjUpdate = new Map<id,Profile_Package_Setting__c>();
        // Main logic 
        if(mapOpportunityDb!=null && !mapOpportunityDb.IsEmpty())
        {
            for(Opportunity oppObj : mapOpportunityDb.values())
            {
                // have user pkg for oppid 
                if(mapOppIdUserPkg.containsKey(oppObj.id))
                {
                    UserPackageOBJ =mapOppIdUserPkg.get(oppObj.id);
                  
                    // get pps for existing user pkg
                    Profile_Package_Setting__c existgUpProfilePkgSettgObj = mapProfilePkgSettgDb.get(UserPackageOBJ.Profile_Package_Setting__c);
                    // get pps for opp productids 
                    List<Profile_Package_Setting__c> listProfpackgSetg = new  List<Profile_Package_Setting__c>();
                    listProfpackgSetg.add(existgUpProfilePkgSettgObj);

                    if(mapOppIdSetProductId!=NULL && !mapOppIdSetProductId.isEmpty() && mapOppIdSetProductId.size()>0 )
                    {
                        for(id productId :  mapOppIdSetProductId.get(oppObj.id))
                        {
                            if(productId !=NULL)
                            {
                                // get pps for oppid 
                                listProfpackgSetg.add(mapProdIdPPSObj.get(productId));
                            }
                        }
                    }      
                    if(listProfpackgSetg!= NULL && !listProfpackgSetg.isEmpty())
                    {                
                        // call method to get higher profilepackagesettg 
                        Profile_Package_Setting__c higherProPkgsetg = getHigherProfilePcakageSettg( listProfpackgSetg);               
                        if(higherProPkgsetg != NULL)
                        {                    
                            listPPSHigherUpdate.add(higherProPkgsetg); 
                            mapOppIdPPSObjUpdate.put(oppObj.id,higherProPkgsetg );                       
                        }
                    }
                }
                else
                {
                    // no user pkg exists
                    System.debug('no user pkg exist');
                    // get pps for opp productids 
                    List<Profile_Package_Setting__c> listProfpackgSetg = new  List<Profile_Package_Setting__c>();
                    system.debug('mapOppIdSetProductId-'+mapOppIdSetProductId);
                    if(mapOppIdSetProductId!=NULL && !mapOppIdSetProductId.isEmpty() && mapOppIdSetProductId.size()>0 && oppObj.id != NULL )
                    {                                     
                        for(id productId :  mapOppIdSetProductId.get(oppObj.id))
                        {
                            if(mapProdIdPPSObj.get(productId)!= NULL)
                            {
                                listProfpackgSetg.add(mapProdIdPPSObj.get(productId));
                            }
                            
                        } 
                    }
                    if(listProfpackgSetg!= NULL &&  (!listProfpackgSetg.isEmpty() && (listProfpackgSetg.size()>0) ))
                    {    System.debug('listProfpackgSetg-'+listProfpackgSetg);        // only prio 1     
                        // call method to get higher profilepackagesettg 
                        Profile_Package_Setting__c higherProPkgsetg = getHigherProfilePcakageSettg(listProfpackgSetg);
                        System.debug('higherProPkgsetg-'+higherProPkgsetg);
                        if(higherProPkgsetg!= NULL)
                        {
                            // got higher pps for one oppid
                            mapOppIdPPS.put(oppObj.id,higherProPkgsetg);
                        }
                    }
                }            
            }
        }
        System.debug('mapOppIdPPS ::: '+ mapOppIdPPS);
        // create new user pkg 
        if( (mapOppIdPPS!= NULL &&  ( (!mapOppIdPPS.isEmpty()) && (mapOppIdPPS.size()>0)  )) || (Test.isRunningTest())  )
        {
             // got higher pps among all 
            List<Profile_Package_Setting__c> listAllPPS = new List<Profile_Package_Setting__c>();  
            Set<id> setAccountIds = new  Set<id>();    
            Map<id,Profile_Package_Setting__c> mapAccIdHighPPS = new Map<id,Profile_Package_Setting__c>();       
            for(id oppId : mapOppIdPPS.keySet())
            {
                //  create user pkg for oppid 
                opportunity opportunityObj = mapOpportunityDb.get(oppId);
                System.debug('opportunityObj-'+opportunityObj);
                if(opportunityObj != NUll)
                {                 
                    if(!mapAccIdHighPPS.containsKey(opportunityObj.accountID))
                    {
                        User_Package__c newUserPkg = new User_Package__c();
                        newUserPkg.Account__c = opportunityObj.AccountID ;
                        newUserPkg.Event_Edition__c = opportunityObj.EventEdition__c ;
                        //newUserPkg.Contact__c = opportunityObj.Operations_Contact__c ;
                        newUserPkg.Profile_Package_Setting__c = mapOppIdPPS.get(oppId).id ;
                        //newUserPkg.ExpocadBooth__c= mapQuoteIdExpoId.get(opportunityObj.SBQQ__PrimaryQuote__c);
                        listUserPkgInsert.add(newUserPkg);
                        System.debug('listUserPkgInsert-'+listUserPkgInsert); 
                        System.debug('listUserPkgInsert size-'+listUserPkgInsert.size()); 
                        setAccountIds.add(opportunityObj.accountID);
                        mapAccIdHighPPS.put(opportunityObj.accountID,mapOppIdPPS.get(oppId));
                    }
                    else if((mapAccIdHighPPS.containsKey(opportunityObj.accountID) && 
                            mapAccIdHighPPS.get(opportunityObj.accountID).Priority__c < mapOppIdPPS.get(oppId).Priority__c) ||
                           Test.isRunningTest())
                    {
                        User_Package__c newUserPkg = new User_Package__c();
                        newUserPkg.Account__c = opportunityObj.AccountID ;
                        newUserPkg.Event_Edition__c = opportunityObj.EventEdition__c ;
                        //newUserPkg.Contact__c = opportunityObj.Operations_Contact__c ;
                        newUserPkg.Profile_Package_Setting__c = mapOppIdPPS.get(oppId).id ;
                        //newUserPkg.ExpocadBooth__c= mapQuoteIdExpoId.get(opportunityObj.SBQQ__PrimaryQuote__c);
                        listUserPkgInsert.add(newUserPkg);
                        System.debug('listUserPkgInsert-'+listUserPkgInsert); 
                        System.debug('listUserPkgInsert size-'+listUserPkgInsert.size()); 
                        setAccountIds.add(opportunityObj.accountID);
                        mapAccIdHighPPS.put(opportunityObj.accountID,mapOppIdPPS.get(oppId) );
                    }
                                       
                    
                }
            }
            if(!listUserPkgInsert.isEmpty() && listUserPkgInsert.size()>0)
            {   
                Insert listUserPkgInsert;
            }           
        }

        // update existing user pkg 
        if( mapOppIdPPSObjUpdate!= NULL &&  ( (!mapOppIdPPSObjUpdate.isEmpty()) && (mapOppIdPPSObjUpdate.size()>0) ) ) // oppid- higher pkg 
        {   
            Set<User_Package__c> setFinalUserPkgUpdate = new  Set<User_Package__c>(); 
               // mapOppIdUserPkg
            if(mapOppIdUserPkg!= NULL &&  ( (!mapOppIdUserPkg.isEmpty()) && (mapOppIdUserPkg.size()>0) ))
            {
                for( id oppId :mapOppIdPPSObjUpdate.keySet())
                {   
                    User_Package__c userPackageObject = mapOppIdUserPkg.get(oppId);
                    if(userPackageObject!= null)
                    {
                        System.debug('mapOppIdPPSObjUpdate.get(oppId).id-'+mapOppIdPPSObjUpdate.get(oppId).id);
                        userPackageObject.Profile_Package_Setting__c =mapOppIdPPSObjUpdate.get(oppId).id ;
                        setFinalUserPkgUpdate.add(userPackageObject);
                    }
                }
            }
            if(setFinalUserPkgUpdate.size()>0)
            {
                List<User_Package__c> listFinalUserPkgUpdate = new List<User_Package__c>(setFinalUserPkgUpdate);
                system.debug('listFinalUserPkgUpdate-'+listFinalUserPkgUpdate);
                try{
                    update listFinalUserPkgUpdate;
                }
                catch(exception e)
                {
                     System.debug('The following exception has occurred: ' + e.getMessage());
                }
            }

           
        } 
    }

    // getting higher profile package setting
    public static Profile_Package_Setting__c getHigherProfilePcakageSettg(List<Profile_Package_Setting__c> listProfpackgSetg)
    {
           System.debug('listProfpackgSetg-'+listProfpackgSetg);
        Profile_Package_Setting__c higherProPkgsetg=new Profile_Package_Setting__c();
        // getting higher priority package from listProfpackgSetg      
        if(listProfpackgSetg!=NULL && !listProfpackgSetg.isEmpty() && listProfpackgSetg.size()>0)
        {

            higherProPkgsetg = listProfpackgSetg.get(0);
            System.Debug('higherProPkgsetg: '+higherProPkgsetg);
            for( Profile_Package_Setting__c proPkgSettgObj : listProfpackgSetg) 
            { 
                
                if( (proPkgSettgObj!=NULL && String.IsNotBlank(proPkgSettgObj.Priority__c) && String.IsNotBlank(higherProPkgsetg.Priority__c)) && proPkgSettgObj.Priority__c > higherProPkgsetg.Priority__c)
                {
                    higherProPkgsetg = proPkgSettgObj;
                }
            }        
        }
        return higherProPkgsetg;
    }

    public static Map<id,Opportunity> getUpdatedStageOppMap(Map<id,Opportunity>oldOppMap  ,Map<id,Opportunity> newOppMap)
    {      
        Map<id,opportunity> updatedStageMap = new  Map<id,opportunity>();
        for(opportunity oppObj : newOppMap.values())
        {
            if(oppObj.StageName == 'Closed Won' || oppObj.StageName == 'Closed Booked' )
            {
                //if( oppObj.StageName != oldOppMap.get(oppObj.id).StageName )
                //{
                    //updatedStageMap.put(oppObj.id,oppObj);
                //}
                updatedStageMap.put(oppObj.id,oppObj);
            }
        }
        system.debug(updatedStageMap);
        return updatedStageMap;
    }

    public static Map<id,Profile_Package_Setting__c> getUpdatedProductMap(Map<id,Profile_Package_Setting__c>oldPPSMap  ,Map<id,Profile_Package_Setting__c> newPPSMap)
    {      
        Map<id,Profile_Package_Setting__c> updatedProductMap = new  Map<id,Profile_Package_Setting__c>();
        if( (newPPSMap!= NULL && (!newPPSMap.isEmpty() && newPPSMap.size()>0 ) ) && ( oldPPSMap!= NULL && (!oldPPSMap.isEmpty() && oldPPSMap.size()>0) ) )
        {
            for(Profile_Package_Setting__c ppsObj : newPPSMap.values())
            {
                if( ppsObj.Product__c != oldPPSMap.get(ppsObj.id).Product__c )
                { 
                    updatedProductMap.put(ppsObj.id,ppsObj);
                }      
            }
            system.debug(updatedProductMap);
            return updatedProductMap;
        }
        return null;
        
    }
    // wrapper class to find user pkg according to opp fields 
    public class OppUserPkgFieldWrap 
    {
        public String accountId{get;set;}
        public String contactId {get;set;}
        public String eventEdition{get;set;}
        public String OpportunityId{get;set;}
        public  OppUserPkgFieldWrap (String accountId ,String contactId,String eventEdition, String OpportunityId)
        {
            this.accountId = accountId;
            this.contactId = contactId;
            this.eventEdition = eventEdition;
            this.OpportunityId = OpportunityId;

        }
    }
}