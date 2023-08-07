/**************************************************************************
** Last Modified by Shay Spoonmore (shay.spoonmore@informausa.com)2018-09-25, [Aishwarya BK-3759 27 Aug 2020]
***************************************************************************/
global class ConnectedAppCustomerCenter extends Auth.ConnectedAppPlugin
{
    global override Map<String,String> customAttributes(Id userId, Id connectedAppId, Map<String,String> formulaDefinedAttributes, Auth.InvocationContext context)
    { 
        User u = [SELECT AccountId, Account.Name, ContactId FROM User WHERE Id = :userId];
        
        if (u != null && u.AccountId != null)
        {
            string strJson = '{';
            strJson += '"contactId": "'+ u.ContactId +'","accountId": "'+ u.AccountId +'","accountName": "'+ u.Account.Name +'","eventEditions": ['; 
            
            Date expireEventEditionFromList = Date.today().addMonths(-6); // exclude Editions 6 months after end date
            
            list<Opportunity> opps = [SELECT EventEdition__r.Event_Edition_Status__c,EventEdition__c,EventEdition__r.Event_Edition_Code__c,EventEdition__r.Event_Code__c,EventEdition__r.Name,EventEdition__r.Start_Date__c,EventEdition__r.End_Date__c ,Id,IsClosed,IsWon FROM Opportunity WHERE 
                                      AccountId =: u.AccountId AND 
                                      (EventEdition__r.End_Date__c >=: expireEventEditionFromList
                                        AND StageName IN ('Closed Won','Closed Booked')) 
                                      Order By EventEdition__r.Start_Date__c DESC];
            for(Opportunity opp: opps)
            {
                strJson += '{"opportunityId": "'+ opp.Id +'","eventName": "'+ opp.EventEdition__r.Name +'","eventCode": "'+ opp.EventEdition__r.Event_Code__c +'","eventEditionCode": "'+ opp.EventEdition__r.Event_Edition_Code__c +'","startDate": "'+ opp.EventEdition__r.Start_Date__c +'","endDate": "'+ opp.EventEdition__r.End_Date__c +'"},';
            }
            if (strJson.endsWith(',')){strJson.left(strJson.length()-1);}
            
            strJson += ']}';
            formulaDefinedAttributes.put('exhibitor',  strJson);
        }
            
        
        return formulaDefinedAttributes;   
    }
}