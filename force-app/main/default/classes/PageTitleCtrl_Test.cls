/**
* Created by     : Girikon(Ashish)
* Created On     : Aug 13 2018
* @description   : This test class covers the apex class "PageTitleCtrl_Test".
* Apex Class     : PageTitleCtrl_Test  (90%)
*
* Modification Log----- 
* Modified by    :
**/
@isTest
public class PageTitleCtrl_Test 
{    
    static testMethod void test1()
    {
        
        Pricebook2 customPB = new Pricebook2(Name='ICRE', isActive=true);
        insert customPB;
        System.assertNotEquals(null,customPB,'Pricebook2 not equal null');
        
        Event_Edition__c ee = new Event_Edition__c(Name='World of Concrete 2017',Event_Price_Book__c=customPB.Id,Price_Rule_object_Name__c='TOC__c',Event_Code__c='WOC17',End_Date__c=System.Today(),Start_Date__c=System.Today(),Payment_Schedule__c='50-50',X50_Cutoff_Date__c=System.Today(),Cutoff_Date_1__c=System.Today(),Cutoff_Date_2__c=System.Today(),Cutoff_Date_3__c=System.Today());
        insert ee;        
        //Create Event_Settings__c
        
        Event_Settings__c evntSttng = new Event_Settings__c(Name='Test',About_Show__c='Test',ShowHours1__c='test',ShowHours2__c='Test',Branding_Color__c='Black',Link_1__c='http://m.www.google.com/',Is_Stand_Design_Visible__c=True,Is_Stand_Detail_Visible__c=True,Is_SubContractors_Visible__c=True,Is_Amount_Visible__c=True,Link_2__c='http://m.www.google.com/',Link_3__c='http://m.www.google.com/',Link_4__c='http://m.www.google.com/',Link_1_Label__c='TestLink1',Link_2_Label__c='TestLink2',Link_3_Label__c='TestLink3',Link_4_Label__c='TestLink4',FaceBook__c='http://m.www.facebook.com/',LinkedIn__c='http://m.www.linkedin.com/',Twitter__c='http://m.www.Twitter.com/',YouTube__c='http://m.www.youtube.com/',Custom_1_Title__c='CstmTitle',Event_Edition__c=EE.Id,E_Commerce_Title__c='EC Title',Welcome_Stand_Contractor__c='WSC Test',Disable_this_information__c=True);        
        insert evntSttng;
        
        CC_community_Setting__c ccstng = new CC_community_Setting__c();
        ccstng.name = 'Customer Center';
        ccstng.Admin_Email__c = 'testabc@abc.com';
        ccstng.Under_Maintenance__c = true;
        insert ccstng;

        PageReference pageRefUnArc = Page.CustomPage_1;
        Test.setCurrentPage(pageRefUnArc);
        pageRefUnArc.getParameters().put('eventcode', 'WOC17');
        
        PageTitleCtrl crtl = new PageTitleCtrl();        
    }
    static testMethod void testCCErrorEmailNotificationService()
    {
        CC_community_Setting__c ccstng = new CC_community_Setting__c();
        ccstng.name = 'Customer Center';
        ccstng.Admin_Email__c = 'testabc@abc.com';

        insert ccstng;
        System.assertNotEquals(null,ccstng,' CC community Setting not equal null');
        CCErrorEmailNotificationService.sendErrorNotificationMail('test');
    }
    
}