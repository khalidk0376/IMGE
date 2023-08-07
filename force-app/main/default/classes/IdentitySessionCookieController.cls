/**
 * Created By   :   Girikon(Mahesh)[Regarding:-(TES-15)]
 * Created On   :   May 23 2019
 * @description :   [This is for the Identity Session Cookie Controller]
 * Test Class   :   IdentitySessionCookieControllerTest
 * Modification Log----- 
 * Modified by  :   
 **/
public with sharing class IdentitySessionCookieController {
  
  public static String COOKIE_NAME {get {return 'ide_session';} private set;}
  public IdentitySessionCookie cookie {get; set;}
  public Boolean deleteCookie {get; set;}

  // Constructor
  public IdentitySessionCookieController(){
    //System.debug('*** -- deleteCookie ' + deleteCookie);
    cookie = setCookie();
  }

  private IdentitySessionCookie setCookie(){

    Integer sessionNumSeconds = 0;

    if(!UserInfo.getUserType().equalsIgnoreCase('guest')){

      // Get the logged in users session
      Map<String, String> sessionAttributes = (!Test.isRunningTest()) ? Auth.SessionManagement.getCurrentSession() : new Map<String, String>{'NumSecondsValid' => '1000'};

      if(sessionAttributes != null && sessionAttributes.containsKey('NumSecondsValid')){
        // Get the number of seconds the session is valif for
        sessionNumSeconds = Integer.valueOf(sessionAttributes.get('NumSecondsValid'));
      }
    }else{
      deleteCookie = true;  // guest user so delete cookie
    }
    //System.debug('*** -- sessionNumSeconds: ' + sessionNumSeconds);
    //System.debug('*** -- UserInfo.getUserType(): ' + UserInfo.getUserType());
    //System.debug('*** -- deleteCookie: ' + deleteCookie);

    // Set the maxAge to delete or session
    Integer maxAge = (deleteCookie != null && deleteCookie) ? 0 : -1; // 0 = delete, -1 = session
    //System.debug('*** -- maxAge: ' + maxAge);
    
    // Add the session number of seconds to the current time to work out the expiry value    
    String ideExpiry = Datetime.now().addSeconds(sessionNumSeconds).formatGMT('yyyy-MM-dd HH:mm:ss.S') + 'Z';
    //System.debug('*** -- ideExpiry: ' + ideExpiry);

    // URL encode the cookie value
    ideExpiry = EncodingUtil.urlEncode(ideExpiry.replace(' ', 'T'), 'UTF-8');

    // Query the org to detect if its a sandbox or not as this impacts the cookie location
    Boolean isSandbox = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;

    IdentitySessionCookie isc = new IdentitySessionCookie();
    isc.name = COOKIE_NAME;
    isc.value = ideExpiry;
    isc.expires = String.valueOf(maxAge);
    isc.domain = isSandbox ? '.force.com' : '.informamarkets.com'; // Will only set the cookie under .informa.com domain in production
    isc.path = '/';
    return isc;
  }

  public class IdentitySessionCookie{
    public String name {get; set;}
    public String value {get; set;}
    public String expires {get; set;}
    public String domain {get; set;}
    public String path {get; set;}
  }
}