/**
 * An apex page controller that exposes the site login functionality
 Last Modified By: [Aishwarya BK-3759 27 Aug 2020]
 */
global with sharing class CommunitiesLoginController {
    /*
    public CommunitiesLoginController () {}
      //BK-3753 - EmptyStatementBlock Violation Reported so I am commented this block as of now.
      */
    
    // Code we will invoke on page load.
    global PageReference forwardToAuthPage() {
        String startUrl = System.currentPageReference().getParameters().get('startURL');
        String displayType = System.currentPageReference().getParameters().get('display');
        return Network.forwardToAuthPage(startUrl, displayType);
    }
}