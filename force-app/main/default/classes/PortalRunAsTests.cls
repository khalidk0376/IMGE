/**
 * Created/Modified By  :  Mahesh (Girikon)
 * Created On:          :  June 11 2019
 * @description         : [ This test class covers the apex class : PortalRunAs]
 * Modification log --
 * Modified By          :
**/
@IsTest
public class PortalRunAsTests {
 
    public enum PortalType { CSPLiteUser, CspLitePortal, PowerPartner, PowerCustomerSuccess, CustomerSuccess, Guest }
     
  @IsTest static void usertest() {
        User pu = getPortalUser(PortalType.CspLitePortal, null, true);
        System.assert([select isPortalEnabled from user where id = :pu.id].isPortalEnabled, 'User was not flagged as portal enabled.');      
         
        System.RunAs(pu) {
            System.assert([select isPortalEnabled from user where id = :UserInfo.getUserId()].isPortalEnabled, 'User wasnt portal enabled within the runas block. ');
        }
    }
     
  public static User getPortalUser(PortalType portalType, User userWithRole, Boolean doInsert) {
     
        /* Make sure the running user has a role otherwise an exception will be thrown. */
        if(userWithRole == null) {  
             
            if(UserInfo.getUserRoleId() == null) {
 
                UserRole r = new UserRole(name = 'TEST ROLE');
                Database.insert(r);
                 
                userWithRole = new User(alias = 'hasrole', email='userwithrole@roletest2.com', userroleid = r.id,
                                    emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                                    localesidkey='en_US', profileid = UserInfo.getProfileId(),
                                    timezonesidkey='America/Los_Angeles', username='userwithrole2@testorg.com');
            } else {
                userWithRole = new User(Id = UserInfo.getUserId(), UserRoleId = UserInfo.getUserRoleId());
            }
             
            System.assert(userWithRole.userRoleId != null, 'This test requires the target org to have at least one UserRole created. Please create a user role in this organization and try again.');
        }
 
        Account a;
        Contact c;
        System.runAs(userWithRole) {
 
            a = new Account(name = 'TEST ACCOUNT');
            Database.insert(a);
 
            a.OwnerId = userWithRole.Id; // Re-set the owner as workflow rules sets account owner to generic user
            update a;
             
            c = new Contact(AccountId = a.id, lastname = 'lastname');
            Database.insert(c);
        }
         
        /* Get any profile for the given type.*///Usertype = :portalType.name() and 
        Profile p = [SELECT Id FROM Profile WHERE name='Informa Markets Identity' LIMIT 1];  
         
        String testemail = 'puser000@apex.unit.test.com';
        User pu = new User(profileId = p.id, username = testemail, email = testemail,
                           emailencodingkey = 'UTF-8', localesidkey = 'en_US',
                           languagelocalekey = 'en_US', timezonesidkey = 'America/Los_Angeles',
                           alias='cspu', lastname='lastname', contactId = c.id);
         
        if(doInsert) {
            Database.insert(pu);
        }
        return pu;
    }
}