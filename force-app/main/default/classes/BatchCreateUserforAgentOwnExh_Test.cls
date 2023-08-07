/*
* Created By:  Mahesh Kumar (Girikon)
* Created on :  08/06/2018
* Modified by : 
* Modified On : 
* Description : This test class covers the apex class BatchCreateUserforAgent  
* Apex Class: BatchCreateUserforAgentOwnExh(85%) 
*/
@IsTest
public class BatchCreateUserforAgentOwnExh_Test{
    
     public static testMethod void BatchCreateUserforAgentTest() 
     {  
        //Create exhibitor user type
        User_Type__c uType = new User_Type__c(Name ='Agent Owned Exhibitor');
        insert uType;
        System.AssertEquals(uType.Name, 'Agent Owned Exhibitor','Not a Valid Usertype');
                
        //Create Account
        account acc = new account(Name='TestLName');
        insert acc;
        System.AssertNotEquals(acc, null,'account should not be null');
        
        //Create contact
        Contact con = new Contact(LastName='User',FirstName ='Test',email='test1@test.com', Type__c=uType.Id,AccountId = acc.id);
        insert con;
        System.AssertNotEquals(con, null,'Contact should not be null');
        set<Id> conIds = new set<Id>();
        conIds.add(con.id);
        
        APXTConga4__Conga_Template__c conTemp = new APXTConga4__Conga_Template__c();
        conTemp.APXTConga4__Name__c = 'CongaTest';
        insert conTemp;
        
        APXTConga4__Conga_Template__c quoteTemp = new APXTConga4__Conga_Template__c();
        conTemp.APXTConga4__Name__c = 'QuoteTest';
        insert quoteTemp;
        
        //Create EventEdition 
        //Event_Edition__c eventEdition1 = new Event_Edition__c(Name='TOC 2018',Event_Code__c='TOC18',Event_Currency__c='USD',End_Date__c=System.Today(),Start_Date__c=System.Today());
        //insert eventEdition1;
        //System.assertEquals(eventEdition1.Event_Code__c,'TOC18', 'Event Code');
        
        Event_Series__c oEventseries = new Event_Series__c(Name = 'World Of Concrete', CurrencyISOCode = 'USD', Package_Identifier__c = 'WOC', Event_Edition_Pool__c = 'WOC', Status__c = 'Active');
        insert oEventseries;
        
        //Create EventEdition 
        Event_Edition__c oEve = new Event_Edition__c(Name = 'World of Concrete 2017', Contract_Template__c = conTemp.id, Event_Edition_Status__c ='Confirmed', 
                                        Max_Hold_Days__c =10, Max_Hold_Booth__c = 10, Invoice_From_Email_ID__c='johncorner@gmail.com', Event_Website__c= 'google.com', 
                                        Measurement__c = 'Feet',Next_Edition__c ='2018',Payment_Schedule__c ='100', Quote_Template__c = quoteTemp.Id, Venue__c ='Corner',
                                        Year__c ='2018', Event_Code__c = 'WOC17', End_Date__c = System.Today(), Start_Date__c = System.Today(), Event_Currency__c = 'USD' ,Part_of_Series__c = oEventseries.Id);
        insert oEve;
        
        Event_Settings__c es = new Event_Settings__c();
        es.Event_Edition__c = oEve.Id;
        es.Is_Event_Edition_Live__c = True;
        insert es;
        
         
        //Create AgentExhibitorsContact
        AgentExhibitorsContact__c   agentExCon = New AgentExhibitorsContact__c(AgentContactId__c=con.id, ExhibitorContactId__c=con.id,IsUserCreated__c=false,EventEdition__c=oEve.id);
         try{
             insert agentExCon;}
         catch(Exception e){
             //Added by Palla Kishore for the ticket BK-19603
             System.debug('The following exception has occurred: ' + e);
             }
        
         test.startTest();
         BatchCreateUserforAgentOwnExh  batchCreateUser = New BatchCreateUserforAgentOwnExh();        
         Database.executeBatch(batchCreateUser ,2);
         test.stopTest();
           
     }


}