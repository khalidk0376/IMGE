/**
 * Created/Modified By  :  Mahesh (Girikon)
 * Created On:          :  June 12 2019
 * @description         : [This test class covers the apex class : DomainFilterUtility]
 * Modification log --
 * Modified By          :
**/
@isTest
private class DomainFilterUtilityTest {
 
  @TestSetup static void setupTestData(){
    List<esso_Domain_Filter__c> domainFilters = new List<esso_Domain_Filter__c>();
    domainFilters.add(new esso_Domain_Filter__c(Name = 'apex.unit.test.com', Type__c = 'Blacklist', Active__c = true));
    domainFilters.add(new esso_Domain_Filter__c(Name = 'apex.unit.test.com', Type__c = 'Greylist', Active__c = true));
    domainFilters.add(new esso_Domain_Filter__c(Name = 'apexunit.test.com', Type__c = 'Blacklist', Active__c = true));
    domainFilters.add(new esso_Domain_Filter__c(Name = 'apexunit.test.com', Type__c = 'Greylist', Active__c = true));
    domainFilters.add(new esso_Domain_Filter__c(Name = 'apex.unittest.com', Type__c = 'Blacklist', Active__c = true));
    domainFilters.add(new esso_Domain_Filter__c(Name = 'apex.unittest.com', Type__c = 'Greylist', Active__c = true));
    domainFilters.add(new esso_Domain_Filter__c(Name = 'inactive.com', Type__c = 'Greylist', Active__c = false));
    domainFilters.add(new esso_Domain_Filter__c(Name = 'inactive.com', Type__c = 'Greylist', Active__c = false));
    insert domainFilters;
  }
   
  @isTest static void getMatchingDomainFilters_Test() {  
 
    Test.startTest();
 
      System.assertEquals(2, DomainFilterUtility.getMatchingDomainFilters('tester@apex.unit.test.com').size(),'The value should be match');
      System.assertEquals(2, DomainFilterUtility.getMatchingDomainFilters('tester@apexunit.test.com').size(),'The value should be match');
      System.assertEquals(2, DomainFilterUtility.getMatchingDomainFilters('tester@apex.unittest.com').size(),'The value should be match');
      System.assertEquals(0, DomainFilterUtility.getMatchingDomainFilters('tester@inactive.com').size(),'The value should be match');
 
      System.assertEquals(2, DomainFilterUtility.getMatchingDomainFilters('apex.unit.test.com').size(),'The value should be match');
      System.assertEquals(2, DomainFilterUtility.getMatchingDomainFilters('apexunit.test.com').size(),'The value should be match');
      System.assertEquals(2, DomainFilterUtility.getMatchingDomainFilters('apex.unittest.com').size(),'The value should be match');
      System.assertEquals(0, DomainFilterUtility.getMatchingDomainFilters('inactive.com').size(),'The value should be match');
 
    Test.stopTest();
  }
 
  @isTest static void getFilterTypes_Test() {
 
    Set<String> filterTypes = new Set<String>{'BLACKLIST', 'GREYLIST'};
 
    Test.startTest();
 
      System.assertEquals(2, DomainFilterUtility.getFilterTypes('tester@apex.unit.test.com').size(),'The value should be match');
      System.assert(DomainFilterUtility.getFilterTypes('tester@apex.unit.test.com').containsAll(filterTypes) == true,'condition should match');
      System.assertEquals(2, DomainFilterUtility.getFilterTypes('tester@apexunit.test.com').size(),'The value should be match');
      System.assert(DomainFilterUtility.getFilterTypes('tester@apexunit.test.com').containsAll(filterTypes) == true,'condition should match');
      System.assertEquals(2, DomainFilterUtility.getFilterTypes('tester@apex.unittest.com').size(),'The value should be match');
      System.assert(DomainFilterUtility.getFilterTypes('tester@apex.unittest.com').containsAll(filterTypes) == true,'condition should match');
      System.assertEquals(0, DomainFilterUtility.getMatchingDomainFilters('tester@inactive.com').size(),'The value should be match');
      System.assert(DomainFilterUtility.getFilterTypes('tester@inactive.com').containsAll(filterTypes) == false,'condition should match');
 
      System.assertEquals(2, DomainFilterUtility.getFilterTypes('apex.unit.test.com').size(),'The value should be match');
      System.assert(DomainFilterUtility.getFilterTypes('apex.unit.test.com').containsAll(filterTypes) == true,'condition should match');  
      System.assertEquals(2, DomainFilterUtility.getFilterTypes('apexunit.test.com').size(),'The value should be match');
      System.assert(DomainFilterUtility.getFilterTypes('apexunit.test.com').containsAll(filterTypes) == true,'condition should match');
      System.assertEquals(2, DomainFilterUtility.getFilterTypes('apex.unittest.com').size(),'The value should be match');
      System.assert(DomainFilterUtility.getFilterTypes('apex.unittest.com').containsAll(filterTypes) == true,'condition should match');
      System.assertEquals(0, DomainFilterUtility.getMatchingDomainFilters('inactive.com').size(),'The value should be match');
      System.assert(DomainFilterUtility.getFilterTypes('inactive.com').containsAll(filterTypes) == false,'condition should match');
 
    Test.stopTest();
  }
   
  @isTest static void isBlacklisted_Test() {
 
    Test.startTest();
 
      System.assertEquals(true, DomainFilterUtility.isBlacklisted('tester@apex.unit.test.com'),'The value should be return true');
      System.assertEquals(true, DomainFilterUtility.isBlacklisted('tester@apexunit.test.com'),'The value should be return true');
      System.assertEquals(true, DomainFilterUtility.isBlacklisted('tester@apex.unittest.com'),'The value should be return false');
      System.assertEquals(false, DomainFilterUtility.isBlacklisted('tester@otherone.com'),'The value should be return false');
      System.assertEquals(false, DomainFilterUtility.isBlacklisted('tester@othertwo.com'),'The value should be return false');
      System.assertEquals(false, DomainFilterUtility.isBlacklisted('tester@otherthree.com'),'The value should be return false');
      System.assertEquals(false, DomainFilterUtility.isBlacklisted('tester@inactive.com'),'The value should be return false');
 
      System.assertEquals(true, DomainFilterUtility.isBlacklisted('apex.unit.test.com'),'The value should be return true');
      System.assertEquals(true, DomainFilterUtility.isBlacklisted('apexunit.test.com'),'The value should be return true');
      System.assertEquals(true, DomainFilterUtility.isBlacklisted('apex.unittest.com'),'The value should be return true');
      System.assertEquals(false, DomainFilterUtility.isBlacklisted('otherone.com'),'The value should be return false');
      System.assertEquals(false, DomainFilterUtility.isBlacklisted('othertwo.com'),'The value should be return false');
      System.assertEquals(false, DomainFilterUtility.isBlacklisted('otherthree.com'),'The value should be return false');
      System.assertEquals(false, DomainFilterUtility.isBlacklisted('inactive.com'),'The value should be return false');
 
    Test.stopTest();
  }
 
  @isTest static void isGreylisted_Test() {
 
    Test.startTest();
 
      System.assertEquals(true, DomainFilterUtility.isGreylisted('tester@apex.unit.test.com'),'The value should be return true');
      System.assertEquals(true, DomainFilterUtility.isGreylisted('tester@apexunit.test.com'),'The value should be return true');
      System.assertEquals(true, DomainFilterUtility.isGreylisted('tester@apex.unittest.com'),'The value should be return true');
      System.assertEquals(false, DomainFilterUtility.isGreylisted('tester@otherone.com'),'The value should be return false');
      System.assertEquals(false, DomainFilterUtility.isGreylisted('tester@othertwo.com'),'The value should be return false');
      System.assertEquals(false, DomainFilterUtility.isGreylisted('tester@otherthree.com'),'The value should be return false');
      System.assertEquals(false, DomainFilterUtility.isGreylisted('tester@inactive.com'),'The value should be return false'); 
 
      System.assertEquals(true, DomainFilterUtility.isGreylisted('apex.unit.test.com'),'The value should be return true');
      System.assertEquals(true, DomainFilterUtility.isGreylisted('apexunit.test.com'),'The value should be return true');
      System.assertEquals(true, DomainFilterUtility.isGreylisted('apex.unittest.com'),'The value should be return true');
      System.assertEquals(false, DomainFilterUtility.isGreylisted('otherone.com'),'The value should be return false');
      System.assertEquals(false, DomainFilterUtility.isGreylisted('othertwo.com'),'The value should be return false');
      System.assertEquals(false, DomainFilterUtility.isGreylisted('otherthree.com'),'The value should be return false');
      System.assertEquals(false, DomainFilterUtility.isGreylisted('inactive.com'),'The value should be return false');
 
    Test.stopTest();
  }
 
  @isTest static void isFiltered() {
 
    Test.startTest();
 
      System.assertEquals(true, DomainFilterUtility.isFiltered('tester@apex.unit.test.com', 'BLACKLIST'),'The value should be return true');
      System.assertEquals(true, DomainFilterUtility.isFiltered('tester@apex.unit.test.com', 'blacklist'),'The value should be return true');
      System.assertEquals(true, DomainFilterUtility.isFiltered('tester@apex.unit.test.com', 'BlAcKlIsT'),'The value should be return true');
      System.assertEquals(true, DomainFilterUtility.isFiltered('tester@apex.unit.test.com', 'GREYLIST'),'The value should be return true');
      System.assertEquals(true, DomainFilterUtility.isFiltered('tester@apex.unit.test.com', 'greylist'),'The value should be return true');
      System.assertEquals(true, DomainFilterUtility.isFiltered('tester@apex.unit.test.com', 'GrEylIsT'),'The value should be return true');
      System.assertEquals(false, DomainFilterUtility.isFiltered('tester@apex.unit.test.com', 'OTHER'),'The value should be return false');
      System.assertEquals(false, DomainFilterUtility.isFiltered('tester@apex.unit.test.com', 'other'),'The value should be return false');
      System.assertEquals(false, DomainFilterUtility.isFiltered('tester@apex.unit.test.com', 'oThEr'),'The value should be return false');
 
      System.assertEquals(true, DomainFilterUtility.isFiltered('apex.unit.test.com', 'BLACKLIST'),'The value should be return true');
      System.assertEquals(true, DomainFilterUtility.isFiltered('apex.unit.test.com', 'blacklist'),'The value should be return true');
      System.assertEquals(true, DomainFilterUtility.isFiltered('apex.unit.test.com', 'BlAcKlIsT'),'The value should be return true');
      System.assertEquals(true, DomainFilterUtility.isFiltered('apex.unit.test.com', 'GREYLIST'),'The value should be return true');
      System.assertEquals(true, DomainFilterUtility.isFiltered('apex.unit.test.com', 'greylist'),'The value should be return true');
      System.assertEquals(true, DomainFilterUtility.isFiltered('apex.unit.test.com', 'GrEylIsT'),'The value should be return true');
      System.assertEquals(false, DomainFilterUtility.isFiltered('apex.unit.test.com', 'OTHER'),'The value should be return false');
      System.assertEquals(false, DomainFilterUtility.isFiltered('apex.unit.test.com', 'other'),'The value should be return false');
      System.assertEquals(false, DomainFilterUtility.isFiltered('apex.unit.test.com', 'oThEr'),'The value should be return false');
 
    Test.stopTest();
  }
}