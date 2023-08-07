/**
 * File:        Assigned_getAttachmentId_Trig.cls
 * Project:     GE Informa
 * Created Date: 24/03/2020
 * Created By:  Rajeev Mishra
 * Modified By:  
 * Test Class: Assigned_getAttachmentId_Trig_Test
 * Coverage: 
 *
 * *************************************************************************
 * @description We have converted exisiting tgr_getAttachmentId trig with trig Management app.
 * *************************************************************************
 * 
 * 
 *
*/
public with sharing class Assigned_getAttachmentId_Trig implements TriggerInterface_Attachment.Runnable {
    public void run(TriggerInterface_Attachment.Trig trig){
        map<id,id> mapEventAttach = new map<id,id>();
        List<Event_Edition__c> objEvntlst = new List<Event_Edition__c>();  
        try{
            if(trig.isInsert){
                for(Attachment att: trig.newList){                  
                    if(string.valueof(att.parentID).startswith('a1S')){
                        mapEventAttach.put(att.parentID,att.id);
                    }
                }
            }
            else if (trig.isDelete){
                for(Attachment att:trig.oldList){                  
                    if(string.valueof(att.parentID).startswith('a1S')){    //a1S instance for Event edition
                        mapEventAttach.put(att.parentID,att.id);
                    }
                }
            }
            if (mapEventAttach.size() > 0){
                
                List<Event_Edition__c> lstEventEdition = [SELECT ID, Name, Event_Edition_Image_URL__c FROM Event_Edition__c WHERE ID IN : mapEventAttach.keyset()];
                
                if (trig.isInsert && lstEventEdition.size() > 0){                
                    for(Event_Edition__c obj : lstEventEdition){                     
                        obj.Event_Edition_Image_URL__c = mapEventAttach.get(obj.id);                     
                        objEvntlst.add(obj);
                    }
                    //if(objEvntlst.size()>0){
                       // update objEvntlst;
                    //}
                }
                else if (trig.isDelete && lstEventEdition.size() > 0){
                    List<Attachment> lstAttachments = [SELECT CreatedDate,Id FROM Attachment WHERE ParentId = :mapEventAttach.keyset() AND IsDeleted = false  order by CreatedDate desc  limit 1];
                    for(Event_Edition__c obj : lstEventEdition){ 
                        if (lstAttachments.size() > 0){
                            obj.Event_Edition_Image_URL__c = lstAttachments[0].id;                     
                            objEvntlst.add(obj);
                        }
                        else {
                            obj.Event_Edition_Image_URL__c = '';                     
                            objEvntlst.add(obj);
                        }
                    }
                    
                }
                if(objEvntlst.size()> 0 ){
                    update objEvntlst;
                }
            }
        }
        catch(Exception ex){
            System.debug('Exception is Comming : ' + ex.getMessage());
        }
    }
 }