/**
 * Created : Girikon(Divaker)
 * Created On:          4 May 2018
 * Methods:             WelcomeEmailPreviewCtr
 * Test Class:          WelcomeEmailPreviewCtr_Test(Code Cover : 96%)
**/
public class WelcomeEmailPreviewCtr {
    public string sEventCode;
    public string sTab;
    public string sBody1{get;set;}
    public string sBody2{get;set;}
    public Event_Settings__c lstEventSetting;
    public string sImageURL{get;set;} 
    
    //This is use for fetch data from event Setting for showing data on ops admin welcome email preview functionality. CCEN-48
    public WelcomeEmailPreviewCtr(){
        sEventCode = ApexPages.currentPage().getParameters().get('eventCode');
        sTab = ApexPages.currentPage().getParameters().get('Tab');
        if(sEventCode != null){
            lstEventSetting = [SELECT Id, Co_Exhibitor_Email_Content1__c, Co_Exhibitor_Email_Content2__c, Exhibitor_Email_Content1__c, Exhibitor_Email_Content2__c, Agent_Email_Content1__c, Agent_Email_Content2__c, Stand_Contractor_Content1__c, Stand_Contractor_Content2__c, Contractor_Email_Content1__c, Contractor_Email_Content2__c, Welcome_Email_Banner__c FROM Event_Settings__c WHERE Event_Edition__c = :sEventCode];
        }
        if(lstEventSetting != null){
            if(sTab == 'Exhibitor'){
                sBody1 = lstEventSetting.Exhibitor_Email_Content1__c;
                sBody2 = lstEventSetting.Exhibitor_Email_Content2__c;
            }
            else if(sTab == 'StandContractor'){
                sBody1 = lstEventSetting.Stand_Contractor_Content1__c;
                sBody2 = lstEventSetting.Stand_Contractor_Content2__c;
            }
            else if(sTab == 'Agent'){
                sBody1 = lstEventSetting.Agent_Email_Content1__c;
                sBody2 = lstEventSetting.Agent_Email_Content2__c;
            }
            else if(sTab == 'Co_Exhibitor'){
                sBody1 = lstEventSetting.Co_Exhibitor_Email_Content1__c;
                sBody2 = lstEventSetting.Co_Exhibitor_Email_Content2__c;
            }
            else if(sTab == 'Contractor'){
                sBody1 = lstEventSetting.Contractor_Email_Content1__c;
                sBody2 = lstEventSetting.Contractor_Email_Content2__c;
            }
            if(lstEventSetting.Welcome_Email_Banner__c != null){
                sImageURL = '/servlet/servlet.ImageServer?id='+lstEventSetting.Welcome_Email_Banner__c+'&oid='+UserInfo.getOrganizationId();
            }
        }
        system.debug(sImageURL);
    }
}