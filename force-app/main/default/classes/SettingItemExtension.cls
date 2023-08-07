/** History: BK-3758 Modified By Rajesh Kumar - on 28-05-2020 */

public with sharing class SettingItemExtension {
    private ApexPages.StandardController controller {get; set;}
    public Setting__c setting {get; set;}
    public Setting_Item__c settingItem {get; set;}
    public String mode {get; set;}
    private String retURL;
    private Boolean editViaView = false;
    private List<String> listSettingItemFieldNames;
    
    public SettingItemExtension(ApexPages.StandardController controller) {
        this.controller = controller;

		mode = ApexPages.currentPage().getParameters().get('m');
		String settingItemId = ApexPages.currentPage().getParameters().get('id');
		retURL = ApexPages.currentPage().getParameters().get('retURL');
		String settingItemFieldNames = SettingsExtension.allFieldsFromObject('Setting_Item__c').replaceAll(' ', '');
       	listSettingItemFieldNames = settingItemFieldNames.Split(',');

		if (settingItemId != null && settingItemId != '') {
			settingItem = Database.query('SELECT ' + String.escapeSingleQuotes(settingItemFieldNames) + ' FROM Setting_Item__c WHERE Id = \'' + String.escapeSingleQuotes(settingItemId) + '\'');
		} else {
			settingItem = new Setting_Item__c();
			settingItem.Setting__c = ApexPages.currentPage().getParameters().get('sid');
		}
		
		if (settingItem.Setting__c != null) { 	
	       	setting = Database.query('SELECT ' + String.escapeSingleQuotes(SettingsExtension.allFieldsFromObject('Setting__c')) + ' FROM Setting__c WHERE Id = \'' + String.escapeSingleQuotes(settingItem.Setting__c) + '\'');
			if (retURL == null || retURL == ''){
				retURL = '/' + String.escapeSingleQuotes(settingItem.Setting__c);
			}
		} else {
			setting = new Setting__c();
			if (retURL == null)
				retURL = '';
		}
    }
    
    public Component.Apex.PageBlockSection getSettingItemPageLayout() {
        Component.Apex.PageBlockSection dynPBS = new Component.Apex.PageBlockSection(columns=1);
        Component.Apex.InputField dynInputField;
        Component.Apex.OutputField dynOutputField;
        
        List<SettingField> flds = settingFields();
        for (SettingField fld : flds) {
			if (mode == 'e' || mode == 'a') {     
				dynInputField = new Component.Apex.InputField();
				dynInputField.expressions.value = fld.fieldValue;
				dynInputField.expressions.label = fld.fieldLabel;
				dynPBS.childComponents.add(dynInputField);
			} else {
				dynOutputField = new Component.Apex.OutputField();
				dynOutputField.expressions.value = fld.fieldValue;
				dynOutputField.expressions.label = fld.fieldLabel;
				dynPBS.childComponents.add(dynOutputField);
			}
        }
        return dynPBS;
    }
    
    private List<SettingField> settingFields() {
    	List<SettingField> outputList = new List<SettingField>();
		for (Integer n=1; n<=1000; n++) {
			Boolean isFound = false;
			SettingField fld = new SettingField();
			for (String fldName : listSettingItemFieldNames) {
				if (fldName.containsAny('123456789')) {
					String fldName_Order = fldName.replace('__c', '_Order__c');
					String fldName_Label = fldName.replace('__c', '_Label__c');
					if (setting.get(fldName_Order) == n) {
						fld.fieldValue = '{!settingItem.' + fldName + '}';
						fld.fieldLabel = '{!setting.' + fldName_Label + '}';
						isFound = true;
					}
				}
			}			
			if (isFound)
				outputList.add(fld);
			else
				break;
		}
		return outputList;
    }
    
    public class SettingField {
    	String fieldValue;
    	String fieldLabel;	
    }
    
    public Pagereference edit() {
    	mode = 'e';
    	editViaView = true;
    	return null;
    }

    public Pagereference deleteItem() {
		Setting_Item__c item = [SELECT Id FROM Setting_Item__c WHERE Id = :settingItem.Id];
		delete item;
    	return new Pagereference(retURL);
    }
        
    public Pagereference save() {
    	if (mode == 'a')
    		insert settingItem;
    	else
	    	update settingItem;
	    	
    	if (editViaView)
    		return new PageReference('/' + settingItem.id + '?retURL=' + retURL);
    	else
	    	return new Pagereference(retURL);
    }
    
}