/**
 * Created/Modified By: Girikon(Aishwarya, Archit)
 * Created On:          5/25/2017
 * Description/Purpose: This class is used for Creating the records of User_Form_Action__c and set the field "Is_Viewed__c" to true, after clicking on exhibitor page- CustomerFormList by passing
                        Form Permission ID, Contact Id and UserId.
 * Methods:             updateUserFormAction
 * Test Class:          UpdateUserFormAction_Test
**/

global class UpdateUserFormAction{
  webservice static boolean updateUserFormAction(String FormPermissionId,String ContactId,String UserID) {
        
       List <User_Form_Action__c> userFormActionList = new list<User_Form_Action__c>();
       List <User_Form_Action__c> userFormActioncheckList = new list<User_Form_Action__c>();

       userFormActioncheckList = [SELECT id,Name,Form_Permission__c, User_Form_Contact__c,Is_Viewed__c,User__c FROM User_Form_Action__c 
                                                   where Form_Permission__r.ID =: FormPermissionId and User_Form_Contact__r.ID =:ContactId];
       
       Forms_Permission__c formPermission=[SELECT id, Name from Forms_Permission__c where id=:FormPermissionId limit 1];
       
        if(userFormActioncheckList.IsEmpty()){
            User_Form_Action__c ufa = new User_Form_Action__c();
            ufa.User__c= UserID;
            ufa.Form_Permission__c = FormPermissionId;
            ufa.User_Form_Contact__c = ContactId;
            ufa.Name=formPermission.Name;
            ufa.Is_Viewed__c=true;
            userFormActionList.add(ufa);
        } 
        else
        {
            for(User_Form_Action__c ufa: userFormActioncheckList )
            {
                ufa.Is_Viewed__c=true;
                ufa.User__c= UserID;
                userFormActionList.add(ufa);
            }
        }
        
        if(userFormActionList!=null){
            upsert userFormActionList;
        }
        
       return true;
  }
    public class userException extends Exception{}
}