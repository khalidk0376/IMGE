/*
Created By: {Girikon(Rajesh Kumar)}
Created On: 1/23/2018
Description/Purpose: Automatically assigned permision set when user is created. Story Id : -GGCW-1583 
Methods: getOppBoothDetails
Test Class: Automatically_Assigned_Handler_Test(91%) 
Modified By: {Girikon(Amish/Pramod)} ( JIRA # CCEN 380 ), [Aishwarya BK-1968 July 19 2019]
Modified On: 10/11/2018
Modified By: Akshi Arora for BK-3261 on 27/01/2020
Modified By: Shiv Raghav Sharma (BK-3234)
Modified On: 31/1/2020
*/


public class Automatically_Assigned_Handler implements Queueable 
{    
    Private Set<Id> setUserId; 
    Private Set<Id> setUserIdFordeleteSSO; 
    public boolean afterInsert;
    public boolean afterUpdate;
    
    public Automatically_Assigned_Handler(Set<Id> setUserId , Set<Id> setUserIdFordeleteSSO , boolean afterInsert , boolean afterUpdate)
    {
        this.setUserId = setUserId;
        this.setUserIdFordeleteSSO = setUserIdFordeleteSSO;
        this.afterInsert = afterInsert;
        this.afterUpdate = afterUpdate;
    }
    
    public void execute(QueueableContext context) 
    {
        List<User> lstuser = new List<User>();
        List<Permission_Set_Mapping__c> lstPermission_Set_Mapping = new List<Permission_Set_Mapping__c>();
        Set<String> setPermissionSetName = new Set<String>();
        List <PermissionSetAssignment> lstPemissionSetAssign = new List<PermissionSetAssignment>();
        List<String> tmpString = new List<String>();
        try
        {            
            PermissionSet SSOPermission = [Select id from PermissionSet where Name = 'SSO_Delegated_SSO_Enabled'];            
            if(afterInsert)
            {    
                if (setUserId != null )
                {   
                    lstuser = [SELECT  id , ProfileId , Profile.UserLicense.Name, FederationIdentifier , Profile.Name , IsActive from user where Id In : setUserId AND IsActive = true];
                    if (lstuser != null && !lstuser.IsEmpty())
                    {
                        lstPermission_Set_Mapping = [SELECT Id ,Permission_Set__c, Profile__c From Permission_Set_Mapping__c Where Profile__c = : lstuser[0].Profile.Name Limit 1];
                        System.Debug('lstPermission_Set_Mapping: '+lstPermission_Set_Mapping);
                        PermissionSetAssignment oPemissionSetAssign = new PermissionSetAssignment();
                        /*BK-3234
Discription - Apply after update trigger for user - SSO Permission set to be Added/Removed once 
Federation ID is Populated on User Record
*/
                        for(User usr : lstuser)
                        {
                            if(usr.FederationIdentifier != Null && usr.Profile.UserLicense.Name == 'Salesforce' && SSOPermission != Null)
                            {                           
                                oPemissionSetAssign = new PermissionSetAssignment();
                                oPemissionSetAssign.AssigneeId = usr.Id;
                                oPemissionSetAssign.PermissionSetId = SSOPermission.Id;
                                lstPemissionSetAssign.add(oPemissionSetAssign);                          
                            }
                        }
                        /******************End of BK-3234**************************/ 
                        if (lstPermission_Set_Mapping != null && !lstPermission_Set_Mapping.IsEmpty())
                        {
                            tmpString.addAll(lstPermission_Set_Mapping[0].Permission_Set__c.split(';'));                       
                            if (tmpString != null && !tmpString.IsEmpty())
                            {
                                List<PermissionSet> LstPermissionSet = [Select Id , Label from PermissionSet where Label IN: tmpString];
                                if(LstPermissionSet != null && !LstPermissionSet.IsEmpty())
                                {
                                    for(PermissionSet oPermisssionSet : LstPermissionSet)
                                    {                                    
                                        if(oPermisssionSet.Label != 'SSO Delegated SSO Enabled')
                                        {
                                            oPemissionSetAssign = new PermissionSetAssignment();
                                            oPemissionSetAssign.AssigneeId = lstuser[0].Id;
                                            oPemissionSetAssign.PermissionSetId = oPermisssionSet.Id;
                                            lstPemissionSetAssign.add(oPemissionSetAssign);  
                                        }
                                    }
                                }
                            }
                        }
                        
                        System.Debug('lstPemissionSetAssign: '+lstPemissionSetAssign);
                        if(lstPemissionSetAssign != null && !lstPemissionSetAssign.IsEmpty())
                        {
                            insert lstPemissionSetAssign;
                        }
                        
                        /******* Start BK-1968 *
List<UserPackageLicense> listUserPackageLicense = new List<UserPackageLicense>();
PackageLicense pl = [select Id, NameSpacePrefix FROM PackageLicense where NameSpacePrefix = 'Skuid' LIMIT 1]; // Query to fetch the skuid Package License
for(String userId: setUserId)
{
UserPackageLicense upl = new UserPackageLicense();
upl.PackageLicenseId = pl.Id;
upl.UserId = userId;
listUserPackageLicense.add(upl);
}
system.debug('===================SKUID '+listUserPackageLicense);
if(!listUserPackageLicense.isEmpty() && listUserPackageLicense.size()>0)
insert listUserPackageLicense;
/******* End BK-1968 *******/
                    }
                    
                    /**** BK-3038 Start *****/
                    List<User> listUserForUpdate = new List<User>();
                    listUserForUpdate = [SELECT Contact.Account.Name, Contact.MailingCountry, Contact.MailingStreet, Contact.MailingCity, Contact.MailingState, Contact.MailingPostalCode 
                                         FROM USER where Id IN:setUserId AND Profile.Name ='Customer Community Login User Custom'];
                    //system.debug('======listUser'+listUserForUpdate);
                    if(listUserForUpdate.size()>0)
                    {
                        for(User user:listUserForUpdate)
                        {
                            user.Account_Company_Name__c = user.Contact.Account.Name;
                            user.Country = user.Contact.MailingCountry;
                            user.State = user.Contact.MailingState;
                            user.City = user.Contact.MailingCity;
                            user.Street = user.Contact.MailingStreet;
                            user.PostalCode = user.Contact.MailingPostalCode;
                        }
                        update listUserForUpdate;
                    }
                    /**** BK-3038 End *****/   
                }  
                
                
            } 
            /*BK-3234
Discription - Apply after update trigger for user - SSO Permission set to be Added/Removed once 
Federation ID is Populated on User Record
*/
            if(afterUpdate)
            {
                if(setUserIdFordeleteSSO != null && !setUserIdFordeleteSSO.IsEmpty())
                {
                    List<PermissionSetAssignment> deletePermissionSetassing = [SELECT Id from PermissionSetAssignment WHERE PermissionSetId = : SSOPermission.Id AND AssigneeId IN : setUserIdFordeleteSSO];
                    if(deletePermissionSetassing != null && !deletePermissionSetassing.IsEmpty())
                    {
                        delete deletePermissionSetassing;
                    }
                }
                
                if (setUserId != null )                
                {
                    for(ID usrid : setUserId)
                    {                        
                        PermissionSetAssignment oPemissionSetAssign = new PermissionSetAssignment();
                        oPemissionSetAssign.AssigneeId = usrid;
                        oPemissionSetAssign.PermissionSetId = SSOPermission.Id;
                        lstPemissionSetAssign.add(oPemissionSetAssign);                                                  
                    }
                    
                    if(lstPemissionSetAssign != null && !lstPemissionSetAssign.IsEmpty())
                    {
                        insert lstPemissionSetAssign;
                    }
                }
                
            } 
            /************************End Of Bk-3234***********************/ 
        }
        catch(Exception ex)
        {
            ex.getMessage();     
            System.Debug('Error: '+ex.getMessage());          
        }
    }
}