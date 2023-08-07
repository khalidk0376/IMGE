/**
 * An apex page controller that exposes the site forgot password functionality
 * Ticket No : BK-14521 Updating API Version
 */
public with sharing class ForgotPasswordController {
    public String username {get; set;}   
     /*  
    public ForgotPasswordController() {}
      //BK-3753 - EmptyStatementBlock Violation Reported so I am commented this block as of now.
    */
    
    public PageReference forgotPassword() {
        boolean success = Site.forgotPassword(username);
        PageReference pr = Page.ForgotPasswordConfirm;
        pr.setRedirect(true);
        
        if (success) {              
            return pr;
        }
        return null;
    }
}