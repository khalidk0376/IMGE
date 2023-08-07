/**
 * Created/Modified By  :  
 * Created On:          :  
 * @description         : 
 * Modification log --
 * * Modified By : Rajesh kumar Yadav Bk-3751
**/
@isTest(seeAllData = false)
public class UpdateLeadCommunication_Test {
    static testMethod void testUpdateLeadCommunication()
    {
        Communication_Directory__c comid = new Communication_Directory__c ();
        comid.Value__c='test@girikon.com';
        comid.CurrencyIsoCode='USD';
        comid.Communication_Group__c = 'Email';
        comid.Lead_MDM_Id__c = 'testrajeshgirikonmdmid';
        insert comid;
        system.assertEquals(comid.Value__c, 'test@girikon.com', 'Both values should be the same.');
        //Update Phone Number
        ApexPages.currentPage().getParameters().put('id',comid.id);
        ApexPages.StandardController sc = new ApexPages.StandardController(comid);
        UpdateLeadCommunication lctrl = new UpdateLeadCommunication(sc);
        lctrl.CommucationId =comid.Id;
        
        Lead ld = new Lead();
        ld.LastName='test';
        ld.Status='Contacted';
        ld.Company='test';
        ld.Account_MDM_ID__c = 'testrajeshgirikon';
        ld.MDM_ID__c = comid.Lead_MDM_Id__c;//'testrajeshgirikonmdm';
        ld.CurrencyIsoCode='USD';
        insert ld;
        system.assertEquals(ld.Status, 'Contacted', 'Both values should be the same.');
        
        lctrl.UpdateAddress();
        comid.Communication_Group__c = 'Phone';
        comid.Value__c= '9711953494';
        update comid;
        //Update Lead Address
        ApexPages.currentPage().getParameters().put('id',comid.id);
        ApexPages.StandardController sc2 = new ApexPages.StandardController(comid);
        UpdateLeadCommunication lctrl2 = new UpdateLeadCommunication(sc2);
        lctrl2.CommucationId =comid.Id;
        lctrl2.UpdateAddress();
        
        comid.Communication_Group__c = 'Direct Post';
        comid.Mailing_Street__c = 'a/c 24';
        comid.Mailing_city__c = 'Hekki';
        comid.Mailing_State__c = 'Bihar';
        comid.Mailing_Country__c = 'India';
        comid.Mailing_Zip__c = '848127';
        
        update comid;
        
        ApexPages.currentPage().getParameters().put('id',comid.id);
        ApexPages.StandardController sc1 = new ApexPages.StandardController(comid);
        UpdateLeadCommunication lctrl1 = new UpdateLeadCommunication(sc1);
        lctrl1.CommucationId =comid.Id;
        lctrl1.UpdateAddress();
    }
    
}