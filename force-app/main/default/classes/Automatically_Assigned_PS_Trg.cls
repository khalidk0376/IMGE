/**
 * File:        Automatically_Assigned_PS_Trg.cls
 * Project:     GE Informa
 * Created Date: 17/03/2020
 * Created By:  Rajesh Kumar
 * Modified By:  Rajesh Kumar
 * Test Class: Automatically_Assigned_Handler_Test
 * Coverage: 
 *
 * *************************************************************************
 * @description We have converted exisiting Automatically_Assigned_PS trig with trig Management app.
 * *************************************************************************
 * 
 * 
 * History:Ticket :BK-3665
 *
*/
public with sharing class Automatically_Assigned_PS_Trg implements TriggerInterface_user.Runnable {
    public void run(TriggerInterface_user.Trig trig){
        Set<Id> setUserId = new Set<Id>(); 
        Set<Id> setUserIdFordeleteSSO = new Set<Id>(); 
        Set<Id> setUserIdForInsertSSO = new Set<Id>();
        try{       
            if(trig.Isinsert){   
                for(User ouser : trig.newList){
                    
                    if (ouser.IsActive == true){
                        setUserId.add(ouser.Id);
                    }
                }
                
            }
            
            if (setUserId != null && !setUserId.IsEmpty() && trig.Isinsert){
                System.enqueueJob(new Automatically_Assigned_Handler(setUserId , Null , true , false ));
            }
           /*BK-3234
            Discription - Apply after update trig for user - SSO Permission set to be Added/Removed once 
            Federation ID is Populated on User Record
           */ 
            if(trig.IsUpdate){
                for(User usr : [Select id , IsActive , Profile.UserLicense.Name, FederationIdentifier from user where id In : trig.newMap.keySet()]){
                    if (usr.IsActive == true && usr.Profile.UserLicense.Name == 'Salesforce'){                     
                        if(trig.oldMap.get(usr.ID).FederationIdentifier == Null && usr.FederationIdentifier != Null){
                            setUserIdForInsertSSO.add(usr.Id); 
                        }
                        else if (trig.oldMap.get(usr.ID).FederationIdentifier != Null && usr.FederationIdentifier == Null){
                            setUserIdFordeleteSSO.add(usr.Id); 
                        }
                    }
                }
            }
            
            if(trig.Isupdate){
                System.enqueueJob(new Automatically_Assigned_Handler(setUserIdForInsertSSO , setUserIdFordeleteSSO , false , true ));
            }
            /********************End Of BK-3234*********************/
        }
        catch(Exception ex){
            System.debug('Exception is Comming : ' + ex.getMessage());
        }
    }
 }