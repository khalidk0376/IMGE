/**
 * Trigger: AmendmentTeamMemberValidation,OnlineBoothTeamMemberValidation,OperationsTeamMemberValidation,SSCTeamMemberValidation,SSCTeamMemberValidation_Trig,Trigger_SscTeamMember,TriggerInterface_SscTeamMember       
 * Project:     GAP
 * Date:        
 * Test Class : OperationsTeamMemberValidation_Test
 * Created By:  Rajesh Kumar Yadav
 * @description 
 */
@isTest
public class OperationsTeamMemberValidation_Test{
    /**
    * @param 
    * @description 
    */
    public static testmethod void operTeamMembTest(){
        
        // Setup test data
		// This code runs as the system user
		
		// Create Trigger test record 
        Trigger__c trig = new Trigger__c(Name = 'SSCTeamMemberValidation_Trig' , Trigger_Name_Unique__c='SSCTeamMemberValidation_Trig',Enabled__c=true,Object__c='SSC_Team_Member__c',Run_for_Recordypes__c='All',  Description__c='my test',Execution_Order__c=1,
                                         Before_Insert__c=true , Before_Update__c = true, Before_delete__c = true);
        Insert trig;
        Trigger_Recordtype__c rt = new Trigger_Recordtype__c(Enabled__c=true,Recordtype_Id__c=trig.Id,Trigger__c=trig.Id,Parameters__c='param=1;param=2');
        Insert rt;
        //Call event edition trigger interface
        TriggerInterface_SscTeamMember obj = new TriggerInterface_SscTeamMember();
        
        TriggerInterfaceHelper.runTrigger('SSCTeamMemberValidation_Trig','SSC_Team_Member__c',1, 'bi', null,null,'All');
		Profile prof = [SELECT Id FROM Profile WHERE Name='Standard User']; 
		User user = new User();
		user.firstName = 'ramraj';
		user.lastName = 'kum';
		user.profileId = prof.id;
		user.username = 'ramraj@test.com';
		user.email = 'ramraj@test.com';
		user.alias='ramraj';
		user.TimeZoneSidKey='America/New_York';
		user.LocaleSidKey='en_US';
		user.EmailEncodingKey='ISO-8859-1';
		user.LanguageLocaleKey='en_US';
		user.IsActive = true;
		insert user;

        //start This part for the Operations Team Member
        system.runAs(user){
        insert new Application_Bypass__c(Bypass_Validation_Rules__c = true);

		Operations_Team__c newOperationsTeam = new Operations_Team__c();
        newOperationsTeam.Operations_Team_Description__c = 'XYZ';
        System.assertEquals(newOperationsTeam.Operations_Team_Description__c , 'XYZ', 'decription must match the data');
        insert newOperationsTeam;
		
         
        Operations_Team_Member__c newOperationsTeamMember = New Operations_Team_Member__c();
        newOperationsTeamMember.Operations_Team__c = newOperationsTeam.Id;
        insert newOperationsTeamMember;
        delete newOperationsTeamMember;
        //start This part for the SSC Team Member
        SSC_Team__c newSSCTeam = new SSC_Team__c();
        newSSCTeam.SSC_Team_Description__c = 'XYZ';
        insert newSSCTeam;
        
         
        SSC_Team_Member__c newSSCTeamMember = New SSC_Team_Member__c();
        newSSCTeamMember.SSC_Team__c = newSSCTeam.Id;
        insert newSSCTeamMember;
        delete newSSCTeamMember;
		//start This part for the Amendment Team Member
		
		Amendment_Team__c newAmendmentTeam = new Amendment_Team__c();
        newAmendmentTeam.Amendment_Team_Description__c = 'XYZ';
        insert newAmendmentTeam;
        
         
        Amendment_Team_Member__c newAmendmentTeamMember = New Amendment_Team_Member__c();
        newAmendmentTeamMember.Amendment_Team__c = newAmendmentTeam.Id;
        insert newAmendmentTeamMember;
        delete newAmendmentTeamMember;
        }
        //End
		
    }
}