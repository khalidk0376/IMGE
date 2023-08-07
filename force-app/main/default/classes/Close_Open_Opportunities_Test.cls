/**
*Created By Rajesh Girikon
*Date : 1/11/2017
*
*Discription - Closed all opporotunity has stageName NOT IN ('Closed Won', 'Pending Accounting Approval' , 'Awaiting Payment - Booth/Stand' , 'Closed Booked' , 'Closed Lost').
*
*/

@isTest(seeAlldata = false)
public class Close_Open_Opportunities_Test
{
    static testMethod void Close_Open_Opportunities_Test_Method() 
    {
        Event_Edition__c eved = new Event_Edition__c();
        eved.Name='Test';
        eved.Tab1__c='ttttt';
        eved.Tab7__c='yyyyyy';
        insert eved;
        Account oacc = new account (name = 'test');
        insert oacc;
        
        Contact oCon1 = new Contact();
        oCon1.FirstName = 'test';
        oCon1.Contact_Type__c = 'Invoice Contact';
        oCon1.LastName = 'ContTest11';
        oCon1.Email = 'abcd1@gmail.com';
        oCon1.AccountId = oacc.Id;
        oCon1.MailingStreet = 'Test1';
        oCon1.MailingCity = 'Test1';
        oCon1.MailingState='';
        oCon1.MailingCountry='India';
        oCon1.Phone = '+12345564788'; 
        oCon1.Inactive__c = false;
        oCon1.AssistantPhone = '+12445567788'; 
        oCon1.HomePhone = '+12345567388'; 
        oCon1.MobilePhone = '+12335567788'; 
        oCon1.OtherPhone = '+12346567788';
        insert oCon1;
        
        opportunity opp = new opportunity ( name = 'testclassopp',Billing_Contact__c = oCon1.id ,StageName ='need assesment' , accountid = oacc.id ,EventEdition__c= eved.id,CloseDate = Date.today());   
        insert opp;
        
        System.assertEquals( opp.StageName =  'Closed Lost',  opp.StageName , 'Opportunity stage not updated');
        ApexPages.currentPage().getParameters().put('id',eved.id);
        ApexPages.StandardController sc = new ApexPages.StandardController(eved);
        Close_Open_Opportunities Close_Open_Opp = new Close_Open_Opportunities(sc);       
        Close_Open_Opp.getOpp();
        String surl = 'test';
        Close_Open_Opp.getURParameter(surl);       
    }
}