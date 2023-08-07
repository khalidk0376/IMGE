/*
Created By		: Girikon(Garima[STL-20])
Created On		: July 31 2019
@description 	: This class is used to get the Event Settings and usertype of current login user to fetch corresponding Manuals at Customer Centre.
Test Class		: CC_ManualsCtrl_Test(Coverage 86%)

Modification log --
Modified By		: 
*/


public without sharing class CC_ManualsCtrl {
    /*
   * @description [Update User Manual Action]
   * @return          [List of sObject]
   */
    @AuraEnabled
    public static void updateUserAction(String sId,Boolean isViewed,Boolean isAgreed){
	
    
    if(isViewed){
   
        
        User_Manual_Action__c manualaction = new User_Manual_Action__c();
        manualaction.id = sId;
        manualaction.Is_Viewed__c = true; 
            update manualaction;
            
    }
    if(isAgreed){
      
        
        User_Manual_Action__c manualaction = new User_Manual_Action__c();
        manualaction.id = sId;
        manualaction.Is_Agree__c = true; 
            update manualaction;
    }
  

}
  /*
   * @description [fetch usertype and contact's account from contacteventedition mapping]
   * @param eventvode [to match with event edition]
   * @return          [List of sObject]
   */
    @AuraEnabled
    public static ContactEventEditionMapping__c getConUserType(String sEventcode)
    {
		List<User> lstUser = new List<User>([SELECT id,ContactId,Contact.AccountId,Contact.Type__c 
                                             FROM User 
                                             WHERE id=:UserInfo.getUserId()]);
        
		ContactEventEditionMapping__c conMap = new ContactEventEditionMapping__c();
				if(string.isNotBlank(sEventcode)){
                List<ContactEventEditionMapping__c> conMapping = new List<ContactEventEditionMapping__c>();
				conMapping = [Select id,SFEventEditionID__r.Event_Code__c, SFContactID__c,SFContactID__r.AccountId,User_Type__c,User_Type__r.Name
                              from ContactEventEditionMapping__c 
                              where SFContactID__c =: lstUser[0].ContactId 
                              and SFEventEditionID__r.Event_Code__c=:sEventcode];
				if(conMapping != null && conMapping.size()>0){
                     conMap = conMapping[0];
				}
	}
	return conMap;
	}

    
    
}