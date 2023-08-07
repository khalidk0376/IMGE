/**
 * Application  :   Informa Markets Identity (IM IdP)
 * Created By   :   Shay.Spoonmore@informa.com (20200710)
 * Created On   :   20200710
 * @description :   [Display Social Network option to login]
 * Test Class   :   esso_SocialNetworksControllerTest
 * Modification Log-----
 * Modified by  :   Shay.Spoonmore@informa.com (20200710)
 **/
public with sharing class esso_SocialNetworksController {
    
    public CommunityBaseController controller {get; set;}
    public list<esso_Configuration.SocialNetwork>  socialNetworks {get; set;}

    public esso_SocialNetworksController() {

        // socialNetworks = new list<SocialNetwork> ();
        
        
        // List<esso_Configuration_Social_Networks__c> confNetworks = [SELECT Auth_Provider_Name__c,Auth_Provider_URL_Suffix__c,Display_0rder__c,Enabled__c,Id,Image_Static_Resource_URL__c,Name 
        //                                                                 FROM esso_Configuration_Social_Networks__c WHERE Enabled__c = true AND Is_Employee_Login__c = false ORDER BY Display_0rder__c ASC, Name ASC];

        // for (esso_Configuration_Social_Networks__c si : confNetworks ) 
        // //for (esso_Configuration_Social_Networks__c si : esso_Configuration.socialNetworks) // custom settings is list doesnt work as a property
        // {
        //     System.debug('#### !DEBUG! esso_SocialNetworksController.get' + si);

        //     SocialNetwork sn = new SocialNetwork();
        //     sn.Name=si.Name;
        //     sn.Image_Static_Resource_URL=si.Image_Static_Resource_URL__c;
        //     sn.Auth_Provider_URL_Suffix=si.Auth_Provider_URL_Suffix__c;
        //     socialNetworks.add(sn);
        // }

        System.debug('#### !DEBUG! esso_Configuration.socialNetworks:' + esso_Configuration.socialNetworks);
        socialNetworks = esso_Configuration.socialNetworks;
        
    }


    // public class SocialNetwork
    // {
    //     public string Name {get; set;}
    //     public string Image_Static_Resource_URL {get; set;}
    //     public string Auth_Provider_URL_Suffix {get; set;}
    // }
}