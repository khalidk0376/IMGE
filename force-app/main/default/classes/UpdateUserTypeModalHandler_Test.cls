/**
 * Created By   :   Girikon(Shiv Raghav)
 * Created On   :   Feb 07 2020
 * @description :   This class is use for updating Expocad ,Opportunity Mapping records for particular opportunity.
 * Test Class   :   UpdateUserTypeModalHandler_Test (93%)
 * Modified by  :  
**/
@IsTest
public class UpdateUserTypeModalHandler_Test {
   
     @IsTest
    private static void UpdateUserTypeModalTestMethod() {
       
        User usr = [Select id from User where Id =: userInfo.getUserId()];
        System.assertNotEquals(null, usr.Id , 'Hello');
        
        User_Type__c usrtype = new User_Type__c();
        usrtype.Name = 'Agent';
        insert usrtype;
        
        Account acc1 = new Account();
        acc1.Name='acc1';
        acc1.BillingCity ='Delhi' ;
        acc1.BillingCountry='india';
        acc1.BillingPostalCode='600075';
        acc1.BillingState='Delhi';
        acc1.BillingStreet='water well street';              
        insert acc1;
        System.assertNotEquals(null, acc1.Id  , 'Hello');
        
        Account acc2 = new Account();
        acc2.Name='acc2';
        acc2.BillingCity ='Delhi' ;
        acc2.BillingCountry='india';
        acc2.BillingPostalCode='600075';
        acc2.BillingState='Delhi';
        acc2.BillingStreet='water well street';              
        insert acc2;
        System.assertNotEquals(null, acc2.Id , 'Hello');
        
        Contact oCon1 = new Contact();
        oCon1.FirstName = 'test';
        oCon1.Contact_Type__c = 'Invoice Contact';
        oCon1.LastName = 'ContTest11';
        oCon1.Email = 'abcd1@gmail.com';
        oCon1.AccountId = acc1.Id;
        oCon1.MailingStreet = 'Test1';
        oCon1.MailingCity = 'Test1';
        oCon1.MailingState='';
        oCon1.MailingCountry='India';
        oCon1.Phone = '+12345564788'; 
        oCon1.Inactive__c = false;
        oCon1.AssistantPhone = '+12445567788'; 
        oCon1.HomePhone = '+12345567388'; 
        oCon1.MobilePhone = '+12335567788'; 
        oCon1.OtherPhone = '+12346567788';
        insert oCon1;
        
        Event_Series__c eentseries = new Event_Series__c(Name = 'World Of Concrete', CurrencyISOCode = 'USD', Package_Identifier__c = 'WOC');
        insert eentseries;
        
        Event_Edition__c ee = new Event_Edition__c( name='Test Edition' );
        ee.Part_of_Series__c = eentseries.id;
        ee.Event_Currency__c = 'USD';
        ee.Event_Code__c     = 'WOC17';
        insert ee;
        System.assertEquals(ee.Event_Code__c,'WOC17', 'Event Code');
        
        EventCurrecies__c eventCurrency = new EventCurrecies__c (Name='USD',Event_Edition__c=ee.id);
        insert eventCurrency;
        System.assertEquals(eventCurrency.Name,'USD', 'Event Currency');
        ee.EventCurrency__c = eventCurrency.id;
        update ee; 
        
        opportunity opp = new opportunity(Name='World of Concrete 2017', EventEdition__c=ee.id,AccountId = acc1.id,Paid_Amount__c=10.00,Amount=20.00,CloseDate=System.Today(),StageName='Discover',CurrencyIsoCode=ee.EventCurrency__r.Name, IsExistingContactAccount__c = false);
        Utility.isReviewProcess = true; 
        Utility.isRebookInProcess = true;
        insert opp;
        
        List<ExpocadBooth__c> lstExpoBooth = new List<ExpocadBooth__c>();
        for(Integer i=0;i<3;i++)
        {
            ExpocadBooth__c eB = new ExpocadBooth__c(Booth_Number__c='TestBoothNo.'+i, status__c = 'Rented');
            lstExpoBooth.add(eB);   
        }
        insert lstExpoBooth;
        
        List<Opportunity_ExpoCAD_Booth_Mapping__c> lstOppExpoBooth = new List<Opportunity_ExpoCAD_Booth_Mapping__c>();
        for(Integer i=0;i<3;i++)
        {
            Opportunity_ExpoCAD_Booth_Mapping__c oEBM = new Opportunity_ExpoCAD_Booth_Mapping__c(Opportunity__c = opp.id );
            lstOppExpoBooth.add(oEBM);   
        }
        insert lstOppExpoBooth;
        
        List<ContactEventEditionMapping__c> lstOppConEdition = new List<ContactEventEditionMapping__c>();
        for(Integer i=0;i<3;i++)
        {
            ContactEventEditionMapping__c cEEM = new ContactEventEditionMapping__c(SFContactID__c = oCon1.id,SFEventEditionID__c = ee.Id );
            lstOppConEdition.add(cEEM);   
        }
        insert lstOppConEdition;
               
        Test.startTest();
        UpdateUserTypeModalHandler.getAllOppMapping(opp);
        UpdateUserTypeModalHandler.updateOppMappingRecords(lstOppExpoBooth);
        UpdateUserTypeModalHandler.getAllExpocadRecords(opp);
        UpdateUserTypeModalHandler.updateExpocadRecords(lstExpoBooth);    
        UpdateUserTypeModalHandler.getAllCCMappingRecords(opp);
        UpdateUserTypeModalHandler.getselectOptions( opp , 'Exhibitor_Paid_By__c');
        UpdateUserTypeModalHandler.updateExpocadRelationOnOpp('Agent' , opp.id);
        UpdateUserTypeModalHandler.updateCCMappingRecords(lstOppConEdition);
        UpdateUserTypeModalHandler.AsyncupdateComment2onExbhitor(opp.id , 'Agent');
        UpdateUserTypeModalHandler.getCurrentUserDtls();
        UpdateUserTypeModalHandler.moveAndUpdateCCObjects(lstOppConEdition[0].id,lstOppConEdition[1].Id);
        customLookUpController.fetchLookUpValues('test','Opportunity');
        Test.stopTest();
        
    }
}