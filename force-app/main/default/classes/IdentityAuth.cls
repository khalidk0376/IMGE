/**
 * Created By   :   Girikon(Mahesh)[Regarding:-(TES-20)]
 * Created On   :   May 16 2019
 * @description :   [This is for change password Autontication]
 * Test Class   :   IdentityAuthTest
 * Modification Log----- 
 * Modified by  :   
 **/
public without sharing class IdentityAuth {
 
    @TestVisible private static Boolean treatAsSuccessfulTest {get; set;}
 
    @TestVisible private static Boolean treatAsPasswordExipredTest {get; set;}
 
    public static PageReference changePassword(Id userId, String newPassword, String verifyNewPassword, String oldPassword) {
         
        PageReference returnPage;
 
        // Get users tokens before changing password as performing query after change password
        // prevents new password from being set but will return a successful response
        List<OauthToken> tokens = OAuthTokenHandler.getUserTokens(userId);
 
        // Now set the new password
        returnPage = Site.changePassword(newPassword, verifyNewPassword, oldpassword);
 
        // Null returned if there is an error e.g. invalid password
        // If successful revoke users IDE OAuth tokens
        if (returnPage != null || (Test.isRunningTest() && treatAsSuccessfulTest != null && treatAsSuccessfulTest)) {
            OAuthTokenHandler.revokeTokens(tokens);
           /*if (Site.isPasswordExpired() || (Test.isRunningTest() && treatAsPasswordExipredTest != null && treatAsPasswordExipredTest)) {
                EmailVerificationService.tryVerifyUserEmail(userId);
            }*/
        }
         
        return returnPage;
    }
}