/**
* Created by     : Girikon(Prashant)
* Created On     : Feb 19 2019
* @description   : This test class covers the apex class "CustomPagesCtrl".
* Apex Class     : CustomPagesCtrl  
*
* Modification Log----- 
* Modified by    : [Aishwarya 17 sep 2020 BK-9045]
**/
@isTest
public class CustomPagesCtrl_Test { 
    
    public static testMethod void test1(){
        
        // Create Event_Edition__c
        Event_Edition__c ee = new Event_Edition__c(Name='World of Concrete 2017',Event_Code__c='WOC17',End_Date__c=System.Today(),Start_Date__c=System.Today());
        insert ee;
        System.assertEquals('WOC17', ee.Event_Code__c, 'Here value is not same');
        // Create Custom_Setting_CC__c
        Custom_Setting_CC__c customSet = new Custom_Setting_CC__c(Name = 'Test', Left_Panel__c='Test1', Right_Panel__c='Test2', Event_Edition__c = ee.id);
        insert customSet;
        
        //Create Event_Settings__c
        Event_Settings__c evntSttng = new Event_Settings__c(Name='Test',About_Show__c='Test',ShowHours1__c='test',ShowHours2__c='Test',Branding_Color__c='Black',Link_1__c='http://m.www.google.com/',Is_Stand_Design_Visible__c=True,Is_Stand_Detail_Visible__c=True,Is_SubContractors_Visible__c=True,Is_Amount_Visible__c=True,
                                                            Link_2__c='http://m.www.google.com/',Link_3__c='http://m.www.google.com/',Link_4__c='http://m.www.google.com/',Link_1_Label__c='TestLink1',Link_2_Label__c='TestLink2',Link_3_Label__c='TestLink3',Link_4_Label__c='TestLink4',
                                                            FaceBook__c='http://m.www.facebook.com/',LinkedIn__c='http://m.www.linkedin.com/',Twitter__c='http://m.www.Twitter.com/',YouTube__c='http://m.www.youtube.com/',
                                                            Custom_1_Title__c='CstmTitle',Event_Edition__c=EE.Id,E_Commerce_Title__c='EC Title',
                                                            Welcome_Stand_Contractor__c='WSC Test',Disable_this_information__c=True);
        
        insert evntSttng;
        
        Test.StartTest();
        CustomPagesCtrl.getCustomSettings(ee.Event_Code__c,'Test');
        CustomPagesCtrl.getEventDetails(ee.Event_Code__c);
        Test.StopTest();
    }
}