/**
 * An apex page controller that exposes the site login functionality
 Last Modified By :   [Aishwarya BK-3759 27 Aug 2020]
 */
public with sharing class SiteLoginController {
    public String username {get; set;}
    public String password {get; set;}

    public PageReference login() {
        String startUrl = System.currentPageReference().getParameters().get('startURL');
        return Site.login(username, password, startUrl);
    }
    /*
    public SiteLoginController () {}
    //BK-3753 - EmptyStatementBlock Violation Reported so I am commented this block as of now.
    */
}