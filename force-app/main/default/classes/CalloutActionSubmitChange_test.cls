@isTest
public class CalloutActionSubmitChange_test{
   static testmethod void validate(){
        Account acc = new Account();
        acc.name = 'test acc';
        acc.Website__c ='www.google.com';
        acc.Mailing_Address__c ='test city';
        insert acc;
        Event_Edition__c oEventEdition = new Event_Edition__c(name = 'World of Concrete',Event_Code__c='woc17', 
        Payment_Schedule__c= '50-50',Cutoff_Date_1__c=date.today(), Approval_Service_Now_ID__c = 'test',
        Tab1__c='esttt',Tab2__c='test',Tab3__c='test',Tab4__c='test',Tab5__c='test',Tab6__c='test',Tab7__c='testtt',Tab8__c='testtt');
        insert oEventEdition;
        
        Opportunity oOpportunity = new Opportunity(Name = 'Expocad Opportunity', CloseDate = Date.today(), StageName = 'Proposal', EventEdition__c = oEventEdition.Id, AccountId = acc.Id);
        insert oOpportunity;
        oOpportunity.Status__c = 'Pending Change';
        update oOpportunity;
        System.AssertEquals('Pending Change' , oOpportunity.Status__c , 'Opportunity is submitted for Change'); 
        Change_Request__c c = new Change_Request__c();
        c.Account__c =  acc.Id;          
        c.Opportunity__c = oOpportunity.Id;
        c.Event_Edition__c = oEventEdition.Id;
        c.Product_Type__c ='Booth';
        insert c;
        
        Set<Id> soppIds = new Set<Id>();
        SoppIds.add(c.Id);
        CalloutActionSubmitChange sc = new CalloutActionSubmitChange(soppIds);
        
    }
 }