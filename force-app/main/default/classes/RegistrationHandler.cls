/**
 * Created By   :   Girikon(Mahesh)[Regarding:-(TES-15)]
 * Created On   :   May 13 2019
 * @description :   [This is generating the community Nickname and getting the IP address]
 * Test Class   :   RegistrationHandlerTest
 * Modification Log----- 
 * Modified by  :   
 **/
//Ticket No. BK-14521 Updating API Version
public with sharing class RegistrationHandler {
 
  /*private static List<Service_IP_Range__c> matchingServiceIpAddresses {get; set;}
    private static List<Service_Email_Domain__c> matchingServiceEmailDomains {get; set;} */
     
    public static String generateCommunityNickname(User theUser){
 
        // Automatically genereate a community nickname for the user
        String firstName = (String.isNotBlank(theUser.FirstName)) ? theUser.FirstName.deleteWhitespace() : '';
        String lastName = (String.isNotBlank(theUser.LastName)) ? theUser.LastName.deleteWhitespace() : '';
        String name = (String.isBlank(theUser.ContactId)) ? firstName + lastName : theUser.ContactId;
        String timeStr = DateTime.now().format('yyyyMMddHHmmssS');
        String communityNickname = name + timeStr;
 
        if(communityNickname.length() > 40){
            // Check the length of the nickname and trim the name to reduce the length
            communityNickname = (communityNickname.length() > 40) ? firstName.left(1) + lastName + timeStr : communityNickname;
            communityNickname = (communityNickname.length() > 40) ? firstName.left(1) + lastName.substring(0,(39 - timeStr.length())) + timeStr : communityNickname;
        }
 
        return communityNickname;
    }
 
   /*public static Id getMatchingAccountId(String ipAddress, String username) {
 
        Id accountId;
 
        if(String.isNotBlank(ipAddress)){
 
            // Get matching service ip range records
            queryMatchingServiceIpAddresses(ipAddress);
 
            if(matchingServiceIpAddresses != null && !matchingServiceIpAddresses.isEmpty()){
                accountId = matchingServiceIpAddresses[0].Service_ID__r.csord__Order__r.csord__Account__c;
            }
        }
 
        if(String.isNotBlank(username)){x
 
            // Get matching service email domain records
            queryMatchingServiceEmailDomains(username);
                     
            if(matchingServiceEmailDomains != null && !matchingServiceEmailDomains.isEmpty()){
                accountId = matchingServiceEmailDomains[0].Email_Domain__r.Account__c;
            }
        }
 
        return accountId;
    } */
 
  /*private static void queryMatchingServiceIpAddresses(String ipAddress){
        if(String.isNotBlank(ipAddress)){
 
            Long selfRegIpAddressNumber = Utility.getIpAddressNumber(ipAddress);
 
            Id productServiceRecTypeId = Utility.getRecordTypeByName('Product Service', 'csord__Service__c');
 
            // Get all matching on IP addresses and store in variable for entitlement later
            matchingServiceIpAddresses =  [  
                                            SELECT
                                                Id, Service_ID__c, Service_ID__r.csord__Service__c, Service_ID__r.csord__Order__r.csord__Account__c, Service_ID__r.Status__c,
                                                Service_ID__r.Available_Licences__c, Service_ID__r.Registration_Method__c
                                            FROM
                                                Service_IP_Range__c
                                            WHERE
                                                Active__c = true
                                            AND
                                                Service_ID__r.RecordTypeId = :productServiceRecTypeId
                                            AND
                                                IP_Range_ID__r.IP_Range_From_Number__c <= :selfRegIpAddressNumber
                                            AND
                                                IP_Range_ID__r.IP_Range_To_Number__c >= :selfRegIpAddressNumber
                                            AND
                                                (Service_ID__r.Registration_Method__c = 'Site Licence' OR Service_ID__r.Registration_Method__c = 'Any')
                                            AND
                                                Type__c = 'Site Licence'
                                        ];
        }
    }  */
 
   /*private static void queryMatchingServiceEmailDomains(String username){
        if(String.isNotBlank(username)){
 
            // IEP-1549 - Now match on email domain, which takes priority over IP address on account allocation
            // Get all matching on email domains and store in variable for entitlement later
            matchingServiceEmailDomains = [
                                            SELECT
                                                Id, Service__c, Email_Domain__c, Active__c, Email_Domain__r.Account__c, Service__r.Registration_Method__c
                                            FROM
                                                Service_Email_Domain__c
                                            WHERE  
                                                Email_Domain__r.Name = :username.substringAfter('@')
                                            AND
                                                Active__c = true
                                            AND
                                                (Service__r.Registration_Method__c = 'Email Domain' OR Service__r.Registration_Method__c = 'Any')
                                        ];
        }
    } */
 
 
   /*public static void runPostRegistrationLogic(String userId){
        entitleUser(userId);
    }
 
    private static void entitleUser(String userId) {
 
        RecordType rt = [SELECT Name, Id FROM RecordType WHERE Name = 'Standard' AND sObjectType = 'Entitled_User__c' LIMIT 1];
        List<User> users = [SELECT Id, Name, ContactId, Username FROM User WHERE id = :userId];
 
        if(users != null && !users.isEmpty()){
 
            User u = users[0];
 
            // Set to hold service Id's to prevent duplicate entitled user records from being generated per service
            Set<Id> entitledServices = new Set<Id>(); // IEP-1124     
             
            //collect services ip ranges
            List<Entitled_User__c> lstEntiledUser = new List<Entitled_User__c>();
            if(matchingServiceIpAddresses == null || (matchingServiceIpAddresses != null && matchingServiceIpAddresses.isEmpty())){
                queryMatchingServiceIpAddresses(u.Self_Registration_IP_Address__c);
            }
 
            if(matchingServiceIpAddresses != null && !matchingServiceIpAddresses.isEmpty()){
                for (Service_IP_Range__c srvIpRange: matchingServiceIpAddresses) {          
 
                    // IEP-1124 Added additional if conditions of set check and service reg method check
                    if (Utility.isServiceEligibleToAddLicences(srvIpRange.Service_ID__r, 1) && !entitledServices.contains(srvIpRange.Service_ID__c)) {
                        lstEntiledUser.add(new Entitled_User__c(RecordTypeId = rt.Id
                            , User_ID__c    = u.Id
                            , Contact__c    = u.ContactId
                            , Service_ID__c = srvIpRange.Service_ID__c
                            , Account_ID__c = srvIpRange.Service_ID__r.csord__Order__r.csord__Account__c
                            , Active__c     = true
                        ));
 
                        // Add service Id to set to prevent duplicate records from being added
                        entitledServices.add(srvIpRange.Service_ID__c);
                    }
                }
            }
 
            //collect services email domains (pavle - iep 271)
            if(matchingServiceEmailDomains == null || (matchingServiceEmailDomains != null && matchingServiceEmailDomains.isEmpty())){
                queryMatchingServiceEmailDomains(u.Username);
            }
 
            if(matchingServiceEmailDomains != null && !matchingServiceEmailDomains.isEmpty()){
                for(Service_Email_Domain__c srvEmailDomain : matchingServiceEmailDomains){
 
                    if(Utility.isServiceEligibleToAddLicences(srvEmailDomain.Service__c, 1) && !entitledServices.contains(srvEmailDomain.Service__c)){
                        lstEntiledUser.add(new Entitled_User__c(
                            RecordTypeId    = rt.Id
                            , User_ID__c    = u.Id
                            , Contact__c    = u.ContactId
                            , Service_ID__c = srvEmailDomain.Service__c
                            , Account_ID__c = srvEmailDomain.Email_Domain__r.Account__c
                            , Active__c     = true
                        ));
 
                        // Add service Id to set to prevent duplicate records from being added
                        entitledServices.add(srvEmailDomain.Service__c);
                    }
                }
            }
 
            if (lstEntiledUser.size() > 0) {
                //system.debug(lstEntiledUser);
                insert lstEntiledUser;
            }
        }
    }
 
    public static final String internalUserSuffix = '.ide';
    public static Boolean validateInternalUserRegistration(String email){
        // Check if user registering with email with a matching email domain in custom metadata. 
        // Internal users should register with an email doamin ending in .ide
 
        Boolean isValid = true;
 
        if(String.isNotBlank(email) && email.contains('@')){
 
            String registeringEmailDomain = email.substringAfter('@');
 
            Boolean containsEmailDomain = false;
 
            for(Internal_End_User_Registration_Domain__mdt domain : [SELECT Email_Domain__c FROM Internal_End_User_Registration_Domain__mdt WHERE Active__c = true]){
                 
                if(registeringEmailDomain.equalsIgnoreCase(domain.Email_Domain__c)){
                    isValid = false;
                    break;
                }else if(registeringEmailDomain.startsWithIgnoreCase(domain.Email_Domain__c) && !registeringEmailDomain.endsWithIgnoreCase(internalUserSuffix)){
                    isValid = false;
                    break;
                }
            }
        }
        return isValid;
    }*/
    public static String getUserIpAddress(){
        System.debug('*** -- True-Client-IP: ' + ApexPages.currentPage().getHeaders().get('True-Client-IP'));
        System.debug('*** -- X-Salesforce-SIP: ' + ApexPages.currentPage().getHeaders().get('X-Salesforce-SIP'));
        System.debug('*** -- X-Forwarded-For: ' + ApexPages.currentPage().getHeaders().get('X-Forwarded-For'));

        // True-Client-IP has the value when no caching integration or via secure URL.
        String ipAddress = ApexPages.currentPage().getHeaders().get('True-Client-IP');

        // get IP address when no caching (sandbox, dev, secure urls)
        if (String.isBlank(ipAddress)) {
            ipAddress = ApexPages.currentPage().getHeaders().get('X-Salesforce-SIP');
        } 
        
        // get IP address from standard header if proxy in use
        if (String.isBlank(ipAddress)) {
            ipAddress = ApexPages.currentPage().getHeaders().get('X-Forwarded-For');
        }

        return ipAddress;
    }
}