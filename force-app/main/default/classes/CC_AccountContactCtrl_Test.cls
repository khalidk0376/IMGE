/*
Created By		: Girikon(Sunil[STL-21])
Created On		: August 7 2019
@description 	: This class is test class for CC_AccountContactCtrl.
Test Class		: 

Modification log --
Modified By		: 
*/

@IsTest
public class CC_AccountContactCtrl_Test {
    @IsTest
    private static void getTest() {
        
        Account acc = new Account(Name = 'test acc');
        insert acc;
        Account oacc1 = new Account(Name = 'Test partner');
        insert oacc1;
        Account acc2 = new Account(Name = 'Test acc2');
        insert acc2;
        
        Contact conObj = new Contact(Lastname = 'test', AccountId = oacc1.Id, LeadSource = 'Cold call',Email='test@gmail.com'); 
        insert conObj;
        conObj.LastName='test updated';
        Contact newContactbs = new Contact(Lastname = 'testLastName25', AccountId = acc.Id, LeadSource = 'Cold call', 
                                           MailingStreet = 'Test', MailingCity = 'Test', MailingState='',MailingCountry='India');
        insert newContactbs ;
       
        Event_Edition__c eventEdition = new Event_Edition__c(Name = 'test eventEdition',Event_Code__c = 'test code');
        insert eventEdition;
        
        Event_Settings__c eventSetting = new Event_Settings__c(Name = 'test eventSetting', Event_Edition__c = eventEdition.id);
        insert eventSetting;
        
        
        Opportunity opp = new Opportunity(Name='test opp', AccountId = acc.id, EventEdition__c = eventEdition.id,StageName = 'Discover', 
                                          closeDate = Date.today(), Amount = 126473 ,Opportunity_Contact__c = conObj.id,
                                          Billing_Contact__c = conObj.Id, Operations_Contact__c = newContactbs.Id, 
                                          Operation_Contact_2__c = newContactbs.Id, Operation_Contact_3__c = newContactbs.Id,
                                          Operation_Contact_4__c = newContactbs.Id, Operation_Contact_5__c = newContactbs.Id,
                                          Safety_Contact__c = newContactbs.Id, Partner_Account__c = oacc1.Id );
        insert opp;
        opp.StageName='Closed Won';
        update opp;
        
        OpportunityContactRole oOpportunityContactRole = new OpportunityContactRole(OpportunityId = opp.Id, ContactId = conObj.id);
        insert oOpportunityContactRole;
        
        Partner oPartner = new Partner(Role = 'Agency', AccountToId = opp.Partner_Account__c, OpportunityId = opp.id, IsPrimary = true);
        insert oPartner;
        
        Opportunity_ExpoCAD_Booth_Mapping__c oppEBM = new Opportunity_ExpoCAD_Booth_Mapping__c(Opportunity__c = opp.id, Primary_Contact__c = conObj.id);
        insert oppEBM;
        
        Test.startTest();
        
        CC_AccountContactCtrl.ContactWrap testConWrap= CC_AccountContactCtrl.getContact(conObj.Id);
        
        User currentUser = CC_AccountContactCtrl.getCurrentUser(); 
        system.assertEquals(UserInfo.getUserId(), currentUser.Id, 'Test');
        
        Contact con=testConWrap.con;
        system.assertEquals('test', con.LastName , 'test');
        
        CC_AccountContactCtrl.saveContact(conObj);
        system.assertEquals('test updated', conObj.LastName, 'test');
        
        CC_AccountContactCtrl.EventEditionSettingWraper testEesw = CC_AccountContactCtrl.getEventDetail(eventEdition.Event_Code__c);
        
        CC_AccountContactCtrl.ContactBoothWrapper testConBoothWrapper = CC_AccountContactCtrl.getEventEditionAccountContact(eventEdition.id,acc.id );
       
        Test.stopTest();
    }
}