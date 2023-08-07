/*
Created By:Garima Gupta
Created On: 01/11/2019
Description/Purpose: This is the handler class for Trigger_ContentDocumentLink.
Test Class:  ContentDocumentLink_Trig_test
*/

// To give permission of content document to community users(STL-19)   
public without sharing class ContentDocumentLink_Trig implements TriggerInterface_ContentDocumentLink.Runnable{
    public void run(TriggerInterface_ContentDocumentLink.Trig trig) {
        if(trig.isInsert && trig.isBefore){
            if(trig.newList.size() > 0){
                for (ContentDocumentLink so :trig.newList) {
                    if(so.ShareType =='V'){
                        so.Visibility = 'AllUsers';
                    }
                } 
            }
        }
    }
    // To give permission of content document to community users(STL-19)   
}