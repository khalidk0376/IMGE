/**
 * Created By   :   Girikon(Mahesh)[Regarding:-(TES-15)]
 * Created On   :   May 05 2019
 * @description :   [Class to provide methods to enforce security reducing Xss vulnerabilities.]
 * Test Class   :   XssSecurityHelperTest
 * Modification Log----- 
 * Modified by  :   
 **/
public with sharing class XssSecurityHelper {
    
    /*
    private static esso_Application_Security_Settings__c securitySettings{
    get{
      if(securitySettings == null){
        securitySettings = esso_Application_Security_Settings__c.getInstance();  
 
        // Null or empty object e.g. setting not setup
        if(securitySettings == null || securitySettings == new esso_Application_Security_Settings__c(SetupOwnerId = UserInfo.getUserId())){
          // Instantiate a new object in memory with defaults
          securitySettings = new esso_Application_Security_Settings__c();
        }
      }
      return securitySettings;
    }
    set;
  }
  */
 
  //regular expression to match all HTML/XML tags
  private static final String HTML_SCRIPT_OPEN_TAG_MATCH_PATTERN = '(^<.+)'; // Match text that starts with <
  private static final String HTML_SCRIPT_CLOSE_TAG_MATCH_PATTERN = '(^>.+)'; // Match text that starts with >
  private static final String HTML_TAG_MATCH_PATTERN = '(^.*<.*?>.*$)'; // Match all HTML tags that existing within other text
  private static final String JAVASCRIPT_MATCH_PATTERN = '(?i:.*JAVASCRIPT.*)'; // Case insensitive Matches for 'Javascrip' within other text
  private static final String VBSCRIPT_MATCH_PATTERN = '(?i:.*vbscript.*)'; // Case insensitive Matches for 'vbscript' within other text
  private static final String SCRIPT_TAG_MATCH_PATTERN = '<(?i:.*script.*)>(.*?)<\\/(?i:.*script.*)>'; // Case insensitive Matches for 'script' tags
 
  //regualr expression to use in replacing tags found in match regex
  private static final String HTML_TAG_REPLACE_PATTERN = '(<.*?>)'; // Match all HTML tags to replace
  private static final String HTML_SCRIPT_OPEN_TAG_REPLACE_PATTERN = '(^<.+)'; // Match text that starts with <
  private static final String HTML_CLOSE_TAG_REPLACE_PATTERN = '(("?\\s?\\/\\s?>)|(^>))'; // Match all HTML closing tags to replace that may have " before and contain whitspace e.g. " /> or "/ >
  private static final String JAVASCRIPT_REPLACE_PATTERN = '((?i)(JAVASCRIPT([:>]*)))'; // Case insensitive Matches for 'Javascrip' and/or ending with :>
  private static final String VBSCRIPT_REPLACE_PATTERN = '((?i)(vbscript:?))'; // Case insensitive Matches for 'vbscript:' or 'vbscript'
  private static final String SCRIPT_TAG_REPLACE_PATTERN = '<(?i:.*script.*)>(.*?)<\\/(?i:.*script.*)>'; // Case insensitive Matches for 'script' tags
 
 
  private static String getXssMatcherRegex(){
    return   SCRIPT_TAG_MATCH_PATTERN + '|' +
        HTML_SCRIPT_OPEN_TAG_MATCH_PATTERN + '|' +
        HTML_SCRIPT_CLOSE_TAG_MATCH_PATTERN + '|' +
        HTML_TAG_MATCH_PATTERN + '|' +
        JAVASCRIPT_MATCH_PATTERN + '|' +
        VBSCRIPT_MATCH_PATTERN;
  }
 
  private static String getXssReplaceRegex(){
    return  SCRIPT_TAG_REPLACE_PATTERN + '|' +
         HTML_TAG_REPLACE_PATTERN + '|' +
        HTML_SCRIPT_OPEN_TAG_REPLACE_PATTERN + '|' +
        HTML_CLOSE_TAG_REPLACE_PATTERN + '|' +
        JAVASCRIPT_REPLACE_PATTERN + '|' +
        VBSCRIPT_REPLACE_PATTERN;
  }
 
  private static Pattern getXssPatternMatcher(){
    return Pattern.compile(getXssMatcherRegex());
  }
 
  public static Boolean isXssVulnerable(String input){
    Boolean hasXssCharacters = false;
    if(String.isNotBlank(input) && esso_Configuration.setting.Enable_Xss_Input_Detection__c){
      Matcher xssMatcher = getXssPatternMatcher().matcher(input);
      hasXssCharacters = xssMatcher.matches();
    }
    return hasXssCharacters;
  }
 
  public static String getXssCleanString(String input){
    String cleanString = input;
    if(String.isNotBlank(input) && esso_Configuration.setting.Enable_Xss_Input_Detection__c){
      Pattern xssPatern = getXssPatternMatcher();
      Matcher xssMatcher = xssPatern.matcher(input);
      if(xssMatcher.matches()){
        // Strip out Xss characters using replace regex
        do{
          System.debug('*** XSS attempt to clean: ' + cleanstring);
          cleanString = cleanString.replaceAll(getXssReplaceRegex(), '');
        }
        while(isXssVulnerable(cleanString));
      }
      cleanString = cleanstring.normalizeSpace();
    }
    return cleanString;
  }
 
  public class SObjectXssDataResult{
    public SObject theSObject {get; private set;}
    public Boolean hasXssVulnerability {get; private set;}
    public List<String> xssMatchingFieldAPINames {get; private set;}
 
    // Constructor
    public SObjectXssDataResult(SObject theSObject){
      this.theSObject = theSObject;
      xssVulnerableDataCheck();
    }
 
    private void xssVulnerableDataCheck(){
       
        System.debug('*** -- this.theSobject: ' + this.theSobject);
 
      if(this.theSobject != null){
 
        Map<String, Object> sObjectfieldsToValue = this.theSobject.getPopulatedFieldsAsMap();
           
          System.debug('*** -- this.sObjectfieldsToValue: ' + sObjectfieldsToValue);
             
            // Loop through all of the populated fields to check for Xss Data
            for(String fieldName : sObjectfieldsToValue.keySet()){
 
              String valueStr = String.valueOf(sObjectfieldsToValue.get(fieldName));
 
              System.debug('*** -- fieldName & valueStr to check: ' + fieldName + ' & ' + valueStr);
 
                if(XssSecurityHelper.isXssVulnerable(valueStr)){
                System.debug('*** -- fieldName is Xss vulnerable -- ***');
                    this.addXssMatchedField(fieldName);
                }
            }
      }
        System.debug('*** -- this.addXssMatchedField list: ' + this.xssMatchingFieldAPINames);
      this.hasXssVulnerability = (this.xssMatchingFieldAPINames != null && !this.xssMatchingFieldAPINames.isEmpty());
    }
 
    public void addXssMatchedField(String theField){
      if(this.xssMatchingFieldAPINames == null){
        this.xssMatchingFieldAPINames = new List<String>();
      }
      if(String.isNotBlank(theField)){
        this.xssMatchingFieldAPINames.add(theField);
      }
    }
 
    public List<String> getXssMatchingFieldLabels(){
 
      List<String> fieldLabels;
 
      if(this.theSObject != null && xssMatchingFieldAPINames != null && !xssMatchingFieldAPINames.isEmpty()){
 
        fieldLabels = new List<String>();
 
        // Get all the fields for the SObject
        SObjectType objToken = this.theSObject.getSObjectType();
            DescribeSObjectResult objDef = objToken.getDescribe();
            Map<String, SObjectField> fldObjMap = objDef.fields.getMap();
 
            for(String fieldKey : xssMatchingFieldAPINames){
              fieldLabels.add(fldObjMap.get(fieldKey).getDescribe().getLabel());
            }
      }
      return fieldLabels;
    }
 
    public String getXssMatchingFieldLabelsToString(){
      List<String> fieldLabels = this.getXssMatchingFieldLabels();
      return (fieldLabels != null && !fieldLabels.isEmpty() ? String.join(fieldLabels, ',') : null);
    }
  }
 
  
}