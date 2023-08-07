/**
 * Created By   :   Girikon(Mahesh)[Regarding:-(TES-15)]
 * Created On   :   May 03 2019
 * @description :   [For Get the domain from the email param.]
 * Test Class   :   DomainFilterUtilityTest
 * Modification Log----- 
 * Modified by  :   
 **/
public with sharing class DomainFilterUtility {
 
  private static String currentEmail;
  private static List<esso_Domain_Filter__c> domainFilters;
 
  public static List<esso_Domain_Filter__c> getMatchingDomainFilters(String email){
 
    // Check if new email provided and only run query if email param is new otherwise return cached variable
    if(String.isNotBlank(email) && !email.equalsIgnoreCase(currentEmail)){
 
      //Get the domain from the email param
      String domain = (email.contains('@')) ? email.substringAfter('@') : email;
      // Query active matching domain filters
      domainFilters = [SELECT Id, Name, Type__c, Active__c FROM esso_Domain_Filter__c WHERE Active__c = true AND Name = :domain ORDER BY Type__c ASC];
    }
 
    // Set the current email to prevent additional queries
    setCurrentEmail(email);
 
    return domainFilters;
  }
 
  public static Set<String> getFilterTypes(String email){
    // Get matching domain filters
    domainFilters = getMatchingDomainFilters(email);
 
    Set<String> filterTypes = new Set<String>();
 
    if(!domainFilters.isEmpty()){
      // Loop through domain fileters and add types to SET in uppercase to normalise SET values
      for(esso_Domain_Filter__c filter : domainFilters){
        if(String.isNotBlank(filter.Type__c)){
          filterTypes.add(filter.Type__c.toUpperCase());     
        }
      }
    }
    return filterTypes;
  }
 
  public static Boolean isBlacklisted(String email){
    return isFiltered(email, 'BLACKLIST');
  }
 
  public static Boolean isGreylisted(String email){
    return isFiltered(email, 'GREYLIST');
  }
 
  public static Boolean isFiltered(String email, String filterType){
     
    Boolean isFiltered = false;
 
    if(String.isNotBlank(email) && string.isNotBlank(filterType)){
      // Check if email is filterd basked on the type value normalised to uppsercase to compare with SET
      isFiltered = getFilterTypes(email).contains(filterType.toUpperCase());
    }
    return isFiltered;
  }
 
  private static void setCurrentEmail(String email){
    // Set the currrent email variable to the param
    currentEmail = email;
  }
}