/**************************************************************************
** Last Modified by Shay Spoonmore (shay.spoonmore@informausa.com)2020-10-22
***************************************************************************/
@isTest
public class zTest_ConnectedAppCustomerCenter {
    static string name = 'TestHandler';
    static User u = new User();
    static Account a = new Account();
    static Contact c = new Contact();
    
    
    static testMethod void UnitTest() 
    {
        Profile p = [SELECT Id FROM Profile Where UserType='CspLitePortal' LIMIT 1];
        
        a = new Account(Name=name);
        insert a;
        
        c= new Contact(AccountId=a.Id,LastName=name,FirstName=name);
        insert c;
        
        u = new User(ContactId = c.Id,FirstName=name,LastName=name,Username= name +'@TestHandler.com',email=name +'@TestHandler.com',ProfileId=p.Id,Alias=name.left(8),LocaleSidKey='en_US',LanguageLocaleKey='en_US',TimeZoneSidKey='America/Los_Angeles',EmailEncodingKey='UTF-8');
   		insert u;
        
        Event_Edition__c e = new Event_Edition__c(Name='Event',End_Date__c =Date.today(), Start_Date__c=Date.today().addMonths(-3));
        insert e;
        System.debug('####!DEBUG! Event_Edition__c: '+ e);
        Opportunity o = new Opportunity(AccountId = a.Id,Name='name',StageName='Closed Won', EventEdition__c=e.Id, closedate=Date.today(),Status__c='Closed Won');
   		insert o;
        update o;
        System.debug('####!DEBUG! Opportunity: '+ ([SELECT Id, AccountId,StageName FROM Opportunity WHERE AccountId =: a.Id]));
        
        
        
        //System.runAs(u) {
        ConnectedAppCustomerCenter cacc = new ConnectedAppCustomerCenter();
        Map<String,String> formulaDefinedAttributes = new Map<String,String>();
        System.debug('####!DEBUG! u.Id: '+ u.Id);
        Map<String,String> j = cacc.customAttributes(u.Id,null,formulaDefinedAttributes,null);
        System.debug('####!DEBUG! j: '+ j.get('exhibitor'));
        System.assertEquals(o.Id, ([SELECT Id, AccountId,StageName FROM Opportunity WHERE AccountId =: a.Id]).Id, 'Opp ids match');
        System.assertEquals(true, String.isNotBlank(j.get('exhibitor')), 'Is Json');
    }

}