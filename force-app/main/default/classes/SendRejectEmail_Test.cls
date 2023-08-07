/**
 * Created/Modified By: Girikon(Pramod)
 * Created On:          6/28/2017 
 * Description/Purpose: This test class covers the apex class : SendRejectEmail
 * Methods:             SendRejectEmail_DataInsert
 * Apex Class:          SendRejectEmail
**/

@isTest
public class SendRejectEmail_Test
{
    public static testMethod void SendRejectEmail_DataInsert()
    {
         // Setup test data
        // This code runs as the system user
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User u = new User(Alias = 'standt', Email='testnicholas@test.com', 
            EmailEncodingKey='UTF-8', LastName='Kumar', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='standarduserdavid1@testorg.com');
            Event_Edition__c OEve;
        List <User_Form_Action__c> ufaList = new List<User_Form_Action__c >();
        System.runAs(u) 
        {
            // The following code runs as user 'u' 
            System.debug('Current User: ' + UserInfo.getUserName());
            System.debug('Current Profile: ' + UserInfo.getProfileId());
           
            User_Type__c UType = new User_Type__c(Name ='Exhibitor');
            insert UType;
            User_Type__c UTypeAgent= new User_Type__c(Name ='Agent');
            insert UTypeAgent;
          
            Contact con = new Contact(LastName='User',FirstName ='Test', Type__c=UType.Id,Email='test@test.com' );
            insert con;
            
            OEve = new Event_Edition__c(Name='World of Concrete 2017',Event_Code__c='WOC17',End_Date__c=System.Today(),Start_Date__c=System.Today());
            insert OEve;
            System.assertEquals(OEve.Event_Code__c,'WOC17', 'Event Code');
              
 
            Form__c oForm = new Form__c(Doc_Type__c='Online',Form__c=1,Deadline__c=System.Today());
            insert oForm;
            System.assertEquals(oForm.Doc_Type__c,'Online', 'Page Templates');
            Event_Edition_Form__c oEEForm = new Event_Edition_Form__c(Event_Edition__c = OEve.id,Forms__c =oForm.id);
            insert oEEForm;
            System.assertEquals(oEEForm.Event_Edition__c,OEve.id, 'Event Edition');
            Forms_Permission__c fPermission = new Forms_Permission__c(Event_Edition_Form__c = oEEForm.id, User_Type__c= UType.Id);
            insert fPermission;
            System.assert(fPermission != null, 'Forms_Permission successfully insert');
            Test.startTest();
            
                List <ContactEventEditionMapping__c> conList = new List<ContactEventEditionMapping__c >(); 
               
                ContactEventEditionMapping__c cEEM = new ContactEventEditionMapping__c(SFEventEditionID__c=OEve.Id, SFContactID__c=con.Id);
                conList.Add(cEEM);
                ContactEventEditionMapping__c cEEM2 = new ContactEventEditionMapping__c(SFEventEditionID__c=OEve.Id, SFContactID__c=con.Id);
                conList.Add(cEEM2);
                insert conList;
                system.debug('conList===='+conList);
                System.assert(conList != null, 'conList');
                
                
                for(Integer i=0;i<conList.size();i++){
                    system.debug('conList===='+conList);
                
                    User_Form_Action__c UFAction = new User_Form_Action__c(name='Test',Form_Permission__c =fPermission.id, User_Form_Contact__c =conList[i].SFContactID__c);
                    ufaList.Add(UFAction);
                }
                
                system.debug('ufaList===='+ufaList);
                insert ufaList;
                System.assert(ufaList!= null, 'conList');
            Test.stopTest();
            
        }
        System.assert(ufaList[0].Id != null, 'Successfully Insert User Form Action.');
        SendRejectEmail.sendRejectEmailNotification(ufaList[0].Id,'Exhibitor');
        
    }
}