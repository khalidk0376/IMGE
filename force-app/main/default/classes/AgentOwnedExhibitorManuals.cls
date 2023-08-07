public without sharing class AgentOwnedExhibitorManuals {
    
    @AuraEnabled
    public static List<User_Manual_Action__c> getAllManuals(Id accountId, String eventCode){
        if(Schema.SObjectType.User_Manual_Action__c.isAccessible() && 
            Schema.SObjectType.Manuals_Permission__c.isAccessible() && 
            Schema.SObjectType.Manual__c.isAccessible() &&
            Schema.SObjectType.User_Type__c.isAccessible() &&
            Schema.SObjectType.Event_Edition__c.isAccessible()){
            List<User_Manual_Action__c> manuals = [
                SELECT  Id, 
                        Manual_Permission__r.Manuals__r.Required__c, 
                        Manual_Permission__r.Manuals__r.Name, 
                        Manual_Permission__r.Manuals__r.Provider__c, 
                        Manual_Permission__r.Manuals__r.Deadline__c, 
                        Manual_Permission__r.Manuals__r.Uploaded_Attachment_Id__c,
                        Manual_Permission__r.Manuals__r.Allow_Submit_After_Deadline__c,
                        Manual_Permission__r.Manuals__r.Manual_Type__c,
                        Manual_Permission__r.Manuals__r.Url__c,
                        Is_Viewed__c, 
                        Is_Agree__c,
                        LastModifiedBy.Name,
                        LastModifiedDate
                FROM    User_Manual_Action__c 
                WHERE   Account__c = :accountId AND 
                        Manual_Permission__r.Manuals__r.Event_Edition__r.Event_Code__c =: eventCode AND 
                        (
                            User_Type__r.Name='Agent Owned Exhibitor' OR 
                            User_Type__r.Name='Exhibitor' OR 
                            User_Type__r.Name='Co-Exhibitor'
                        )
            ];
            return manuals;
        }
        return Null;
    }

    @AuraEnabled
    public static String updateViewedAndAgreed(Id manualActionId, Boolean viewed, Boolean agreed){
        if(Schema.SObjectType.User_Manual_Action__c.isAccessible()){
            User_Manual_Action__c manualAction = new User_Manual_Action__c();
            manualAction.Id = manualActionId;
            //Update only if it is being viewed first time
            if(viewed){
                manualAction.Is_Viewed__c = viewed;
            }
            if(agreed){
                manualAction.Is_Agree__c = agreed;
            }
            if(viewed || agreed){
                if(Schema.SObjectType.User_Manual_Action__c.isUpdateable()){
                    update manualAction;
                    return 'Success';
                }
            }
        }
        return 'Error';
    }

}