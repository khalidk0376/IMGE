/*Created By: {Girikon(Pramod)}
Created On: 08/30/2018
Description/Purpose: This class provides coverage to apex class "AddUpdateUserPackage_Trig"
Methods: AddUpdateUserPackageTest
Apex Class: AddUpdateUserPackage_Trig (100%), Profile_Package_Setting_Trigger (96%), TriggerInterface_ProfPckgStngs (100%)

Modification log --
Modified By: {####(####)} [Jira #]
Modified On: MM/DD/YYYY*/

@isTest
Public class AddUpdateUserPackage_Trig_Test
{
    @isTest
    public static void addUpdateUserPackageTest() 
    { 
        TriggerInterface_ProfPckgStngs obj=new TriggerInterface_ProfPckgStngs();
        Profile_Package_Setting__c pps=new Profile_Package_Setting__c();
        pps.name='Test';
        insert pps;
        TriggerInterfaceHelper.runTrigger('AddUpdateUserPackage_Trig','Profile_Package_Setting__c',99, 'bu', null,null,'All');
        
        pps.name='TestLatest';
        update pps; 
        System.assertEquals('TestLatest' , pps.Name , 'test  class failed');      
    }
}