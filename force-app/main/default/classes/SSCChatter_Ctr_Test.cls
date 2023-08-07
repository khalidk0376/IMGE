/**
* File:        redirectUrl.cls
* Project:     GAP
* Date :      3/2/2017 3:35 AM
* Created By:  Rajesh Girikon
* *************************************************************************
* Description: Discription - For Redirect Currenlty created opportuniy from review process .
*
* *************************************************************************
* History:
*/

@isTest
public class SSCChatter_Ctr_Test {
    static testMethod void TestSSCChatter()
    {
        Account oacc = new Account (Name = 'Test');
        insert oacc ;
        
        User Usr = [SELECT Id FROM User WHERE Id = : UserInfo.getUserId()];
        
        Opportunity opp = new opportunity (name = 'test' ,IsCreatedByReviewProcess__c=true, closeDate = Date.Today(),Event_Edition__c ='Arab Health 2016', EventSeries__c= 'Arab Health', StageName= 'Qalification' , AccountId = oacc.id);
        insert opp;
        // Added by Palla Kishore for the ticket BK-19602
        System.assertEquals('test', opp.name, 'Here value is not same');
        ApexPages.StandardController sc = new ApexPages.StandardController(opp );
        SSCChatter_Ctr rd  = new SSCChatter_Ctr();
    }
}