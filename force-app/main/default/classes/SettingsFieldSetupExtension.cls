public with sharing class SettingsFieldSetupExtension {
    public Setting__c setting {get; set;}
    private List<String> listSettingItemFieldNames;
    
    public SettingsFieldSetupExtension() {
        String settingItemFieldNames = SettingsExtension.allFieldsFromObject('Setting_Item__c').replaceAll(' ', '');
        listSettingItemFieldNames = settingItemFieldNames.Split(',');
        			
        setting = Database.query('SELECT ' + SettingsExtension.allFieldsFromObject('Setting__c') + ' FROM Setting__c WHERE Id = \'' + ApexPages.currentPage().getParameters().get('id') + '\'');
    }
    
    public Pagereference cancel() {
    	return null;
    }

    public Pagereference save() {
    	update setting;
    	return null;
    }
    
    public Component.Apex.PageBlockSection getSettingFieldSetupPageLayout() {
        Component.Apex.PageBlockSection dynPBS = new Component.Apex.PageBlockSection(columns=2);
        Component.Apex.InputField dynInputField;
        listSettingItemFieldNames.sort();
 		for (String fldName : listSettingItemFieldNames) {
			if (fldName.containsAny('123456789')) {
				String fldName_Label = fldName.replace('__c', '_Label__c');
				String fldName_Order = fldName.replace('__c', '_Order__c');
				
				dynInputField = new Component.Apex.InputField();
				dynInputField.expressions.value = '{!setting.' + fldName_Label + '}';
				dynPBS.childComponents.add(dynInputField);

				dynInputField = new Component.Apex.InputField();
				dynInputField.expressions.value = '{!setting.' + fldName_Order + '}';
				dynPBS.childComponents.add(dynInputField);
			}
		}			
        return dynPBS;
    }

}