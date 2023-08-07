/*
Created By		: Girikon(Himanshu[STL-160])
Created On		: Sep 25 2019
@description 	: This class is used as controller for ops_eventEditionEmailTemplates LWC at Customer Centre.
Test Class		: ops_emailTemplatesCtrl_Test(100%)

Modification log --
Modified By		: 
*/

public class ops_emailTemplatesCtrl {
    
      /*
    * @description [Fetch FromEmailAddressESMapping__c]
    * @param  sEventId [Event_Edition__c Id to fetch records]
    * @return          [List of FromEmailAddressESMapping__c ]
    */
    
    @AuraEnabled
    public static List<FromEmailAddressESMapping__c> getEmails(string evtid){
        List<FromEmailAddressESMapping__c> options = new List<FromEmailAddressESMapping__c>();
        List<FromEmailAddressESMapping__c> fromEmailList = new List<FromEmailAddressESMapping__c>();
        list<Event_Edition__c> evtEdition = new list<Event_Edition__c>();
        
        evtEdition = [SELECT Id, Part_of_Series__c 
                      FROM Event_Edition__c 
                      where id=:evtid];
       fromEmailList =  [SELECT Id,Event_Series_Name__c,Org_Wide_From_Email_Addresses__c 
                         FROM FromEmailAddressESMapping__c 
                         where Event_Series_Name__c =:evtEdition[0].Part_of_Series__c];
        for (FromEmailAddressESMapping__c p: fromEmailList) {
            options.add(p);
        }
        return options;
    }
}