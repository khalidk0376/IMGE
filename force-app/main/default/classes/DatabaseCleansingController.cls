public with sharing class DatabaseCleansingController {
    
    public List<Setting_Item__c> settingItems {get; set;}
    public Setting__c setting {get; set;}
    public id setItemId {get; set;}
   
    
    public DatabaseCleansingController()
    {
        
        
        
        setting = [SELECT Checkbox_1_Label__c,Checkbox_2_Label__c,Checkbox_3_Label__c,Checkbox_4_Label__c,Id,Long_Text_1_Label__c,Name,Text_1_Label__c,Text_2_Label__c,Text_3_Label__c,Text_4_Label__c,Text_5_Label__c,Text_6_Label__c,Text_7_Label__c,Text_8_Label__c FROM Setting__c WHERE Name = 'Database Cleansing'];
        settingItems = [SELECT Checkbox_1__c,Checkbox_2__c,Checkbox_3__c,Checkbox_4__c,Id,Long_Text_1__c,Name,Setting__c,Text_1__c,Text_2__c,Text_3__c,Text_4__c,Text_5__c,Text_6__c,Text_7__c,Text_8__c FROM Setting_Item__c WHERE Setting__c =: setting.Id];
        
  
        
    }
    
        
    public Pagereference addItem() {
        PageReference page = new PageReference('/apex/setting_item?m=a&sid=' + setting.id + '&retURL=/apex/DatabaseCleansing&cancelURL=/apex/DatabaseCleansing');  
        page.setRedirect(true);  
        return page;    }
    
    public pagereference runAll(){
        DatabaseCleansing.GetSettings(null);
        return null;
    }
    public pagereference run(){
        System.debug('####setItemId: '+setItemId);
        DatabaseCleansing.GetSettings(setItemId);
        return null;
    }
    
    
    
}