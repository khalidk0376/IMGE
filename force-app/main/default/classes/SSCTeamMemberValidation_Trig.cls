/*
* Created By   : Girikon[Adarsh BK-3756]
* Created On   : 29/05/2020
* @description : Only the System Admin and GE System Admin, Team owner is able to add and remove Team Members.
* Coverage     : 84%
* Test Class   : OperationsTeamMemberValidation_Test
*/
public class SSCTeamMemberValidation_Trig implements TriggerInterface_SscTeamMember.Runnable{
    public Id userId = userinfo.getUserId();
    public User userDetails =[SELECT Id, Name, Email, Profile.Name,ProfileId, UserRole.Name FROM User where Id=:userId Limit 1];
    public string profileName = userDetails.Profile.Name;
    public set<Id> sscTeamMemberId = New set<Id> ();
    public List<SSC_Team__c> lstSSCTeam = new List<SSC_Team__c>();
    Application_Bypass__c appbypass = Application_Bypass__c.getInstance();
    
    public void run(TriggerInterface_SscTeamMember.Trig trig){
        if(trig.isInsert || trig.isUpdate){
            for(SSC_Team_Member__c oSSCTeamMemb : trig.newList){
                sscTeamMemberId.add(oSSCTeamMemb.SSC_Team__c);
            }
            if(sscTeamMemberId != null){
                lstSSCTeam = [SELECT Id, Name,Owner.ProfileId,Owner.Profile.Name, OwnerId, Owner.Name FROM SSC_Team__c where Id=: sscTeamMemberId];
                if(lstSSCTeam.size() > 0){
                    if(( profileName !=  System.Label.System_Administrator_Profile_Name || profileName != System.Label.GE_System_Administrator_Profile_Name ) && profileName == System.Label.SSC_Finance_Accounting_Profile_Name && lstSSCTeam[0].OwnerId != userId)
                    { 
                        for(SSC_Team_Member__c ooSSCTeamMemb : trig.newList){ ooSSCTeamMemb.adderror(System.Label.OperationsTeamMemberUpsert); }                
                    }
                }
            }
        }
        if (trig.IsDelete){
            for(SSC_Team_Member__c oSSCTeamMemb : trig.oldList){
                sscTeamMemberId.add(oSSCTeamMemb.SSC_Team__c);
            }
            if(sscTeamMemberId != null){
                lstSSCTeam = [SELECT Id, Name,Owner.ProfileId,Owner.Profile.Name, OwnerId, Owner.Name FROM SSC_Team__c where Id =: sscTeamMemberId];
                if(lstSSCTeam.size() > 0){
                    
                    if(( profileName !=  System.Label.System_Administrator_Profile_Name || profileName != System.Label.GE_System_Administrator_Profile_Name ) && profileName == System.Label.SSC_Finance_Accounting_Profile_Name && lstSSCTeam[0].OwnerId != userId)
                    { 
                        for(SSC_Team_Member__c ooSSCTeamMemb : trig.oldList){   ooSSCTeamMemb.adderror(System.Label.OperationsTeamMemberDelete);        }               
                    }
                }
            }
        }
    }
}