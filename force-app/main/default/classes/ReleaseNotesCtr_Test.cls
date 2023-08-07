/*Created By: Avinash Singh
Created On: 08/02/2018
Description/Purpose: SN Ticket - CHG0046785
Apex Classes Covered: ReleaseNotesCtr (100%)
 */
@isTest
public class ReleaseNotesCtr_Test
{
    public static testMethod void ValidateReleaseNotesCtr() 
    {
        
        List <Release_Note__c> rnData=new List <Release_Note__c>();
        rnData.add(new Release_Note__c(CurrencyIsoCode='USD',Project__c='TestPrj1',IsPublished__c=True));
        rnData.add(new Release_Note__c(CurrencyIsoCode='USD',Project__c='TestPrj2',IsPublished__c=True));
        rnData.add(new Release_Note__c(CurrencyIsoCode='USD',Project__c='TestPrj1',IsPublished__c=True));
        Insert rnData ;   
        
        Test.startTest();

        Map <String,List<Release_Note__c>> getReleaseMap = new Map <String,List<Release_Note__c>>();
        ReleaseNotesCtr rnCtr=new ReleaseNotesCtr ();                                  
        getReleaseMap=rnCtr.releaseMap;
        
        System.AssertEquals(true, getreleaseMap.containsKey(rnData[0].Project__c), 'Map must contain at least one project record');
        
        rnCtr.validateUserSession();
        

        Test.stopTest();
        
    }
}