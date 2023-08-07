/**  History: BK-3758 Modified By Rajesh Kumar - on 28-05-2020 */
public with sharing class SettingsExtension {
    private ApexPages.StandardController controller {get; set;}
    public Setting__c setting {get; set;}
    public List<Setting_Item__c> settingItems {get; set;}
    private List<String> listSettingItemFieldNames;
    private String settingItemFieldNames;
    public Integer pageSize {get; set;}
    public Integer pageNumber {get; set;}
    public Integer numRecords {get; set;}
    public Integer numStart {get; set;}
    public Integer numEnd {get; set;}
    public Integer numPages;
    
    private String urlPage;
    
    public PageReference next() {
        urlPage = null;
        pageNumber++;
        queryItems();
        return null;
    }

    public PageReference previous() {
        urlPage = null;
        pageNumber--;
        queryItems();
        return null;
    }

    public SettingsExtension(ApexPages.StandardController controller) {
        this.controller = controller;
        
        urlPage = ApexPages.currentPage().getParameters().get('page');
        
        settingItemFieldNames = SettingsExtension.allFieldsFromObject('Setting_Item__c').replaceAll(' ', '');
        listSettingItemFieldNames = settingItemFieldNames.Split(',');

        setting = Database.query('SELECT ' + SettingsExtension.allFieldsFromObject('Setting__c') + ' FROM Setting__c WHERE Id = \'' + ApexPages.currentPage().getParameters().get('id') + '\'');

        numRecords = [SELECT COUNT() FROM Setting_Item__c WHERE Setting__c = :setting.Id];
        
        if (pageSize == null || pageSize == 0)
            pageSize = 100;

        if (pageNumber == null || pageNumber == 0)
            pageNumber = 1;

        numPages = Integer.valueOf((Decimal.valueOf(numRecords) / Decimal.valueOf(pageSize)).round(System.RoundingMode.CEILING));
        
        if (numPages == null || numPages == 0)
            numPages = 1;
                    
        queryItems();        
    }
    
    private void queryItems() {
        if (urlPage != null)
            pageNumber = Integer.valueOf(urlPage);
            
        if (pageNumber < 1)
            pageNumber = 1;
        else if (pageNumber > numPages)
            pageNumber = numPages;
        
        Integer offset = (pageNumber - 1) * pageSize;
        settingItems = Database.query('SELECT ' + String.escapeSingleQuotes(settingItemFieldNames) + ' FROM Setting_Item__c WHERE Setting__c = \'' + String.escapeSingleQuotes(setting.Id) + '\' ORDER BY Name LIMIT ' + String.valueOf(pageSize) + ' OFFSET ' + String.valueOf(offset));

        numStart = offset + 1;
        numEnd = offset + pageSize;
        if (numEnd > numRecords)
            numEnd = numRecords;
        if (numRecords == 0) {
            numStart = 0;
            numEnd = 0;
        }
    }

    public Component.Apex.PageBlockTable getSettingItemTable() {
        //Setup Table
        Component.Apex.PageBlockTable dynPBT = new Component.Apex.PageBlockTable();
        dynPBT.expressions.value = '{!settingItems}';
        dynPBT.var = 'item';
        
        //Instantiate column objects
        Component.Apex.Column dynColumn;
                
        //Action column
        dynColumn = new Component.Apex.Column();
        dynColumn.headerValue = 'Action';
        dynColumn.width = '50';
            //Edit Link     
            Component.Apex.OutputLink dynEditLink = new Component.Apex.OutputLink();
            dynEditLink.expressions.value = '/apex/setting_item?m=e&id={!item.Id}&retURL=/{!setting.id}&cancelURL=/{!setting.id}';
                Component.Apex.OutputText dynEditText = new Component.Apex.OutputText();
                dynEditText.value = 'Edit';
                dynEditLink.childComponents.add(dynEditText);
            dynColumn.childComponents.add(dynEditLink);
        dynPBT.childComponents.add(dynColumn);
        
        //Item Number column
        dynColumn = new Component.Apex.Column();
        dynColumn.headerValue = 'Item Number';
        dynColumn.width = '100';
        
            Component.Apex.OutputLink dynCommandLink2 = new Component.Apex.OutputLink();
            dynCommandLink2.expressions.value = '/{!item.Id}?retURL=/apex/settings?id={!setting.id}';
        
                Component.Apex.OutputField out = new Component.Apex.OutputField();
                out.expressions.value = '{!item.Name}';
                dynCommandLink2.childComponents.add(out);

            dynColumn.childComponents.add(dynCommandLink2);
        dynPBT.childComponents.add(dynColumn);

        //The rest of the columns        
        List<SettingField> flds = settingFields();
        for (SettingField fld : flds) {
            dynColumn = new Component.Apex.Column();
            dynColumn.expressions.value = fld.fieldValue;
            dynColumn.expressions.headerValue = fld.fieldLabel;
            dynPBT.childComponents.add(dynColumn);
        }

        return dynPBT;
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
                        fld.fieldValue = '{!item.' + fldName + '}';
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
    
    public Pagereference addItem() {
        PageReference page = new PageReference('/apex/setting_item?m=a&sid=' + setting.id + '&retURL=/' + setting.id + '&cancelURL=/' + setting.id);  
        page.setRedirect(true);  
        return page;    }
    
    public static String allFieldsFromObject(String objName) {
        Map<String, Schema.SObjectField> fldObjMap;
        if (objName == 'Setting__c')
        fldObjMap = Schema.SObjectType.Setting__c.fields.getMap();
        else if (objName == 'Setting_Item__c')
        fldObjMap = Schema.SObjectType.Setting_Item__c.fields.getMap();
            
       //List<Schema.SObjectField> fldObjMapValues = fldObjMap.values();

        String soql = '';
        for(Schema.SObjectField s : fldObjMap.values()) 
        {
            String fldName = s.getDescribe().getName();
            soql += fldName + ',';
        }
        soql = soql.subString(0, soql.length() - 1); //Trim last comma
        return soql;
    }
    
    
    
    
    
    
    
}