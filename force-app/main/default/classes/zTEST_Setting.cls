/*****************************************************
* Tests:
*	SettingsExtension.cls				100%
*	SettingsFieldSetupExtension.cls		100%
*	SettingItemExtension.cls			90%
* Modified By : Rajesh kumar Yadav Bk-3751
*****************************************************/

@isTest
private class zTEST_Setting {
	
	static testMethod void testSettings() {
		Setting__c s = new Setting__c();
		s.Text_1_Label__c = 'test';
		s.Text_1_Order__c = 1;
		insert s;
		
		Setting_Item__c si = new Setting_Item__c();
		si.Setting__c = s.Id;
		si.Text_1__c = 'test';
		insert si;
		system.assertEquals(si.Text_1__c, 'test', 'Both values should be the same.');
		//****** SettingsExtension ******
		
		//Setup a reference to the page the controller is expecting with the parameters
        PageReference pRef = Page.Settings;
        pRef.getParameters().put('id',s.id);
        Test.setCurrentPage(pRef);

        //Construct the controller class 
        SettingsExtension ext = new SettingsExtension(new ApexPages.StandardController(s));
		
		Component.Apex.PageBlockTable dynPBT = ext.getSettingItemTable();
		ext.addItem();

		//****** SettingsFieldSetupExtension ******
		
		//Setup a reference to the page the controller is expecting with the parameters
        PageReference pRef2 = Page.Settings_FieldSetup;
        pRef2.getParameters().put('id',s.id);
        Test.setCurrentPage(pRef2);

        //Construct the controller class 
        SettingsFieldSetupExtension ext2 = new SettingsFieldSetupExtension();
		
		Component.Apex.PageBlockSection dynPBS = ext2.getSettingFieldSetupPageLayout();
		ext2.save();
		ext2.cancel();
		
		//****** SettingItemExtension ******
		
		//Setup a reference to the page the controller is expecting with the parameters
        PageReference pRef3 = Page.Settings_FieldSetup;
        pRef3.getParameters().put('id',si.id);
        Test.setCurrentPage(pRef3);

        //Construct the controller class 
        SettingItemExtension ext3 = new SettingItemExtension(new ApexPages.StandardController(si));
		
		dynPBS = ext3.getSettingItemPageLayout();
		ext3.edit();
		ext3.save();
		ext3.deleteItem();
		
		ext3.mode = 'a';
		dynPBS = ext3.getSettingItemPageLayout();
	}
	
}