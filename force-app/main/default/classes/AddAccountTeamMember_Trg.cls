/**
 * File:        AddAccountTeamMember_Trg  .cls
 * Project:     GAP
 * Created Date: 03/09/2019
 * Created By:  Rajesh Kumar
 * Modified By:  Rajesh Kumar
 * Test Class: ValidateTeamTrigger_Test
 * Coverage: 
 * *************************************************************************
 * @description This class is using in "Opportunity Trigger Management app" Trigger.
 * *************************************************************************
 * History:Ticket :BK-23, [Aishwarya 25 Aug 2020 BK-6906] [BK-9301 Rajesh Kumar 14-01-2021]
 *
*/

public with sharing class AddAccountTeamMember_Trg {
    public static void addTeamMember (List<Opportunity> newOppLst, Map<id, Opportunity> oldOppMap, Boolean isAfter, Boolean isBefore, Boolean isinsert, Boolean isUpdate){
        List<AccountTeamMember> atmList = new List <AccountTeamMember>( );
        List<AccountTeamMember> lstAcctmembers = new List <AccountTeamMember>( );
        Set<Id> accIds = new Set<Id> ();
        Map <Id, Set<Id>> mapuserid         = new Map <Id, Set<Id>>( );
        for(Opportunity opp : newOppLst){
            if(isAfter && isInsert){
                accIds.add(Opp.OwnerId); 
            }
            else if (isBefore && isUpdate && oldOppMap.get(opp.id).OwnerId != opp.OwnerId){                accIds.add(Opp.OwnerId);        
            }  
        }
        if (accIds != null){
            if (!Schema.sObjectType.AccountTeamMember.fields.accountId.isAccessible() || !Schema.sObjectType.AccountTeamMember.fields.userId.isAccessible()) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error: Insufficient Access'));
            } else {
                atmList = [ Select Id, accountId, userId, User.Profile.Name from AccountTeamMember where userId in: accIds];
            }
            if ( atmList.size( ) > 0 ) {
                for ( AccountTeamMember oatm : atmList ) {
                    if (mapuserid.containsKey(oatm.accountId )){                        mapuserid.get( oatm.accountId ).add( oatm.userId ); 
                    }
                    else {
                        Set<Id> sid = new Set<Id>( );
                        sid.add( oatm.userId );
                        mapuserid.put( oatm.accountId, sid );
                    }
                }
            }
            AccountTeamMember teammemberad;
            List<User> lstuser = new List<User>();
            if (!Schema.sObjectType.User.fields.ProfileId.isAccessible()) {                
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error: Insufficient Access'));
            } 
            else {
                lstuser = [ Select Id , Profile.Name  , UserRole.Name FROM User Where id =: accIds ];
            }
            if (lstuser.size() > 0 && String.isNotBlank(lstuser[0].UserRole.Name)){
                if (!lstuser[0].UserRole.Name.contains('Operations') && !lstuser[0].UserRole.Name.contains('SSC')){
                    if (lstuser[0].Profile.Name == 'Sales' || lstuser[0].Profile.Name == 'Sales-Brasil'){   
                        for (Opportunity opp : newOppLst) {     
                            if ( !mapuserid.containsKey(opp.AccountId) || (mapuserid.containsKey(opp.AccountId) && !mapuserid.get(opp.AccountId).contains(lstuser[0].Id))) {
                                teammemberad                = new AccountTeamMember( );                            
                                teammemberad.AccountId      = opp.AccountId;                            
                                teammemberad.UserId         = lstuser[0].Id;
                                teammemberad.TeamMemberRole = 'Account Executive';                            
                                lstAcctmembers.add(teammemberad);
                                if ( mapuserid.containsKey(opp.accountId)) {                                mapuserid.get(opp.accountId).add(lstuser[0].Id);                            
                                } else {
                                    Set<Id> sid = new Set<Id>();
                                    sid.add(lstuser[0].Id);
                                    mapuserid.put(opp.accountId, sid);
                                }
                            } 
                        }
                    }
                }
            }
            
            if (lstAcctmembers.size() > 0 ) {                
                if (!Schema.sObjectType.AccountTeamMember.fields.AccountId.isCreateable()) {                   
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error: Insufficient Access'));                
                } else {
                    insert lstAcctmembers;
                }
            }
        } 
    }
}