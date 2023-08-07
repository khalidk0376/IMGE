/**
 * Created By     :  Girikon(Shashank)
 * Created On     :  20/08/2018
 * Modified by    :  Girikon(Prashant)[CCEN-617 (Jan 23 2018)] 
 * @description   : test class for StandDesignTrigger(100%) , StandDesignTriggerHandler(100%)            
 **/
    @isTest
    public class StandDesignTrigger_Test {
     
        @isTest
        public static void standDesignFieldMappingMethod(){
        
        //create Account record
             Account acc = new Account(Name='TestAcc' );
             insert acc;
             System.assertNotEquals(null,acc,'Account not equal null');
            
            //create contact record
            Contact con = new Contact(AccountId =acc.Id, FirstName = 'TestConFirst', LastName = 'TestConLast', Email='abc@test.com');
            insert con;

            //create BoothContractorMapping__c record
            BoothContractorMapping__c boothConMap = new BoothContractorMapping__c(Approved__c=True, Contact__c=con.Id,status__c='Rejected');
            insert boothConMap;                                                              

            //create Stand_Design__c record
            Stand_Design__c standDesign = new Stand_Design__c(Account__c=acc.Id,Booth_Design_Status__c='Tentative Approval',BoothContractorMapping__c=boothConMap.id,Contractor_Agreement_CA__c=true,
                                                                Booth_Design_Submitted_On__c=system.today(),Submitted_to_Venue_On__c=system.today(),Is_Rejected__c=false);
            
            insert standDesign;
            
            List<Stand_Design__c> lststandDesign = new List<Stand_Design__c>();
            lststandDesign.add(standDesign);
          
            StandDesignTriggerHandler.updateBoothContractorMapping(lststandDesign);

        }
    }