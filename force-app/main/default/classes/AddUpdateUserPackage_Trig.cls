/*Created By: {Girikon(Pramod)}
Created On: 08/30/2018
Description/Purpose: This class executes to create/update "User Package" record at creation/updation of "Profile Package Setting" record
Methods: run
Test Class: AddUpdateUserPackage_Trig_Test

Modification log --
Modified By: {####(####)} [Jira #]
Modified On: MM/DD/YYYY*/
public with sharing class AddUpdateUserPackage_Trig implements TriggerInterface_ProfPckgStngs.Runnable 
{
    public void run(TriggerInterface_ProfPckgStngs.Trig trig) 
    {
        System.DEbug('pramod');
        System.DEbug('trig.newMap-'+trig.newMap);
        System.DEbug('trig.oldMap-'+trig.oldMap);
        string usrNewPakge = JSON.serialize(trig.newMap);
		string usrOldPakge = JSON.serialize(trig.oldMap);
        System.DEbug('usrNewPakge-'+usrNewPakge);
        System.DEbug('usrOldPakge-'+usrOldPakge);
       	ProfilePackageSettingTriggerHandler.usrPackgeUpdt(usrNewPakge,usrOldPakge);
    }
}