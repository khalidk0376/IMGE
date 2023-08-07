/**
 * Created By   :   Camille Ward
 * Created On   :   22/11/2016
 * @description  :  An apex class that creates a portal user.
 * Test Class   :   SiteRegisterControllerTest(88%)
 * Modofied by : Himanshu Jasuja [BK -3719] on 25/03/2020 
 **/
public with sharing class SiteRegisterController {
    // PORTAL_ACCOUNT_ID is the account on which the contact will be created on and then enabled as a portal user.
    // you need to add the account owner into the role hierarchy before this will work - please see Customer Portal Setup help for more information.       
    private static Id PORTAL_ACCOUNT_ID = System.Label.AccPortal;//BK -3719
    /*
    public SiteRegisterController () {
     //BK-3753 - EmptyStatementBlock Violation Reported so I am commented this block as of now.
      
}
*/

    
    public String username {get; set;}
    public String email {get; set;}
    public String password {get; set {password = value == null ? value : value.trim(); } }
    public String confirmPassword {get; set { confirmPassword = value == null ? value : value.trim(); } }
    public String communityNickname {get; set { communityNickname = value == null ? value : value.trim(); } }
  
    public boolean isValidPassword() {
        return password == confirmPassword;
    }
    
    public PageReference registerUser() {
        if (!isValidPassword() ) {
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.site.passwords_dont_match);ApexPages.addMessage(msg);
            return null; 
        }    
        User u = new User();
        u.Username = username;
        u.Email = email;
        u.CommunityNickname = communityNickname; 
        
        String accountId = PORTAL_ACCOUNT_ID;
        
        String userId = Site.createPortalUser(u, accountId, password);        
        if (userId != null || test.isRunningTest()) { 
            if ((password != null && password.length() > 1 ) ) {
                return Site.login(username, password, null);
            }
            else {
                PageReference page = System.Page.SiteRegisterConfirm;
                page.setRedirect(true);
                return page;
            }
        }
        return null;
    }
}