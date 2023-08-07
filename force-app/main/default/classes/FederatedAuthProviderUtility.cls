/**
 * Created By   :   Girikon(Mahesh)[Regarding:-(TES-55)]
 * Created On   :   May 16 2019
 * @description :   [This is a Utility Class for Federated Auth]
 * Test Class   :   LogoutControllerTest
 * Modification Log----- 
 * Modified by  :   
 **/
public class FederatedAuthProviderUtility {
    
    public static String getDefaultCommunityURL(){
    String defaultCommunityURL;

    // Get the default community auth config
    AuthConfig defaultCommunityAuthConfig = FederatedAuthProviderUtility.getDefaultCommunityAuthConfig();

    // Get the community URL from the default community auth config
    if(defaultCommunityAuthConfig != null){
      defaultCommunityURL = defaultCommunityAuthConfig.Url;
    }
    return defaultCommunityURL;
  }

  public static AuthConfig getDefaultCommunityAuthConfig(){
    // Query org to detect if in a sandbox environment
    Organization org = [SELECT Id,InstanceName,IsReadOnly,IsSandbox FROM Organization LIMIT 1];
    // Check if currently in a sandbox environment and select different label
    String defaultCommunity = (org.IsSandbox) ? Label.Communities_Sandbox_Default_Community_AuthConfig : Label.Communities_Production_Default_Community_AuthConfig;
    // Query AuthConfig for default community
    List<AuthConfig> communityAuthConfigs = [SELECT DeveloperName, Url, Type FROM AuthConfig WHERE IsActive = true AND Type = 'Community' AND DeveloperName = :defaultCommunity LIMIT 1];
    
    AuthConfig defaultCommunityAuthConfig;
    if(!communityAuthConfigs.isEmpty()){
      defaultCommunityAuthConfig = communityAuthConfigs[0];
    }
    return defaultCommunityAuthConfig;
  }
}