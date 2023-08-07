/*Created By: {Girikon(Pramod)}
Created On: 09/14/2018
Description/Purpose: This class is used that maps the original URLs to user-friendly URLs and implements interface Site.UrlRewriter.
Methods: mapRequestUrl, generateUrlFor
Test Class: ccRewriter_Test(88%)

Modification log --
Modified By: Pramod on Dec 13 2018 [CCEN-505], Pramod on Feb 27 2019[CCEN-695]
*/

public with sharing class ccRewriter implements Site.UrlRewriter 
{ 
    //Variables to represent the user-friendly URLs 
    String UI_PAGE = '/_ui/'; 
    //String NOT_FOUND_PAGE = '/filenotfound';
    String NOT_FOUND_PAGE = '/PageNotFound'; //CCEN-505
        
    //method to map incoming URL requests to the right Salesforce record.
    public PageReference mapRequestUrl(PageReference myFriendlyUrl)
    { 
        String url = myFriendlyUrl.getUrl(); 
        System.Debug('url: '+url);
         
        //[CCEN-695] Start: To access attachment by anonymous user after decrypting the record id
        if(url.toLowerCase().contains('/file/view'))
        {
            //Get encrypted ID url
            Integer intIndex = url.indexOf('/file/view/');
            //Extract encrypted ID only
            string attID=url.Substring(intIndex+11);
            //Decrypt record ID in genuine SF ID
            attID=UtilityMethods.Decrypt_aes256(attID);
            return new PageReference('/ViewAtt?file='+attID);
        }   
        //End
        
        //Start : [25 Nov, 2019]
        Boolean IsNotAlllowedURL=false;
        List<Not_Allowed_UI_URLs__c> naulCS = Not_Allowed_UI_URLs__c.getall().values();
        system.debug('naulCS'+naulCS);
        for(Not_Allowed_UI_URLs__c naul : naulCS)
        { if(url.toLowerCase().startsWith(naul.Name)){IsNotAlllowedURL=true;}
        }
        System.Debug('IsNotAlllowedURL: '+IsNotAlllowedURL);
        //End :
        
        Boolean IsAlllowedURL=false;
        List<Allowed_UI_URLs__c> aulCS = Allowed_UI_URLs__c.getall().values();
        system.debug('aulCS'+aulCS);
        for(Allowed_UI_URLs__c aul : aulCS)
        {
            if(url.toLowerCase().startsWith(aul.Name))
                IsAlllowedURL=true;
        }

        if(!IsAlllowedURL)
        {
            if(url.startsWith(UI_PAGE) || IsNotAlllowedURL)
            { 
                return new PageReference(NOT_FOUND_PAGE); 
            }
        }
        return null; 
    }
    public PageReference[] generateUrlFor(PageReference[] yourSalesforceUrls)
    {
        return null; 
    }
}