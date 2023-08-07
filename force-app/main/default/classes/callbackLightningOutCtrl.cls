/*
 * File         :   callbackLightningOutCtrl
 * Project      :   Opportunity integration
 * Created Date :   29th Apr 2022
 * Created By   :   Girikon(Shiv Raghav, Abhishek)
 * Test Class   :   callbackLightningOutCtrl_Test(100%)
 * ***************************************************************************
 * @description : to Show Opportunity Data from GE to UBM Org
 */

public class callbackLightningOutCtrl {
    @AuraEnabled
    public static List<Opportunity> getOpportunities(String AccountId) {
        List<Opportunity> opptys =
                [SELECT Id, Name, Amount,Total_Area_Rented__c,Event_Edition_Name__c,StageName,Data_Source__c,Amount_Custom_Code__c FROM Opportunity WHERE Account.x_Legacy_Id__c =:AccountId];
        return opptys;
    }
}