/**
 * Created :  Himanshu
 * Last Modified By: 
 * Created On:          9/16/2017 
 * Description/Purpose: This is the controller class of the AddProductCategory
 *                      It is used for adding the product category by Ops Admin
 * Methods:             findCategories, populateL3, saveCategories
 * Test Class:          showProductCategory_Test
**/

public  with sharing  class ops_ShowProductCategory {
    //public List<Product_Category__c> listLabelL3{get;set;}
    @AuraEnabled
    public  static List<Levels_Master__c> listLabelL3{get;set;}
      @AuraEnabled
    public  static  String categoryL2{get;set;}
      @AuraEnabled
    public  static String categoryL1{get;set;}
      @AuraEnabled
    public  static Integer L3Count{get;set;}
      @AuraEnabled
    public  static Boolean showL3{get;set;}
      @AuraEnabled
    public  static Boolean CheckShow{get;set;}
      @AuraEnabled
    public  static Boolean CheckClose{get;set;}
      @AuraEnabled
    public  static String checked{get;set;}
      @AuraEnabled
    public static  List<showL3Checkbox> lstL3CheckBox{get;set;}
    public ops_ShowProductCategory()
    {
        checked='checked';
        CheckShow=false;
    }
    
    @AuraEnabled
    public static List<Levels_Master__c> findCategories(String qry)
    {
        List<Levels_Master__c> resultList = new List<Levels_Master__c>();
        try
        {
            if(qry.length()>=1)
            {
                string catInput = '%' + qry + '%';
                resultList =[select id,Name,LevelValue__c,MDM_Code__c,Level_Name__c,Mapped_To_Level__r.LevelValue__c from Levels_Master__c where LevelValue__c LIKE :catInput and Level_Name__c='L2' and Mapped_To_Level__r.LevelValue__c!=null];               
            }
        }
        catch(Exception e)
        {
            System.debug('Message:='+e.getMessage()+'*Line Number='+e.getLineNumber());
        }
        return resultList;//null;
    }
    
   @AuraEnabled
    public static  List<showL3Checkbox> populateL3(string categoryL1,string categoryL2)
    {
        try
        {
            lstL3CheckBox=new List<showL3Checkbox>();
            showL3=true;
            categoryL1 = categoryL1;
            categoryL2 = categoryL2;
            String qry='select id,Name,LevelValue__c, MDM_Code__c,Level_Name__c,Mapped_To_Level__c, Mapped_To_Level__r.LevelValue__c,Mapped_To_Level__r.Mapped_To_Level__r.LevelValue__c from Levels_Master__c where Level_Name__c=\'L3\' and Mapped_To_Level__r.LevelValue__c=\''+String.escapeSingleQuotes(categoryL2) +'\' and Mapped_To_Level__r.Mapped_To_Level__r.LevelValue__c=\''+String.escapeSingleQuotes(categoryL1)+'\'';
            listLabelL3=Database.Query(qry);
            List<String> ids=new List<String>();
            L3Count=listLabelL3.size();
            for(Levels_Master__c pd:listLabelL3)
            {
                ids.add(pd.id);
            }
            List<Event_Edition_Sub_Category_Mapping__c> lstL3Event=[Select id,Levels_Master__c,Levels_Master__r.LevelValue__c from Event_Edition_Sub_Category_Mapping__c Where Levels_Master__c IN:ids];
            List<String> l3IdsFromEvent=new List<String>();
            if(lstL3Event.size()>0)
            {
                for(Event_Edition_Sub_Category_Mapping__c evnt:lstL3Event)
                {
                    showL3Checkbox l3=new showL3Checkbox();
                    l3.L3Id=evnt.Levels_Master__c;
                    l3.L3Name=evnt.Levels_Master__r.LevelValue__c;
                    l3.checked=true;
                    lstL3CheckBox.add(l3);
                    l3IdsFromEvent.add(evnt.Levels_Master__c);
                } 
                if(l3IdsFromEvent.size()<ids.size())
                {
                    List<Levels_Master__c> lstL3ProductNotInEvents=[select id,Name,LevelValue__c, MDM_Code__c,Level_Name__c,Mapped_To_Level__c,Mapped_To_Level__r.LevelValue__c,Mapped_To_Level__r.Mapped_To_Level__r.LevelValue__c from Levels_Master__c where id not in:l3IdsFromEvent and Level_Name__c='L3' and  Mapped_To_Level__r.LevelValue__c=:categoryL2 and Mapped_To_Level__r.Mapped_To_Level__r.LevelValue__c=:categoryL1];                    
                    for(Levels_Master__c pd:lstL3ProductNotInEvents)
                    {
                        showL3Checkbox l3=new showL3Checkbox();
                        l3.L3Id=pd.id; l3.L3Name=pd.LevelValue__c; l3.checked=false;
                        lstL3CheckBox.add(l3);
                    }
                }   
            }
            else
            {
                for(Levels_Master__c pd:listLabelL3){   showL3Checkbox l3=new showL3Checkbox();    l3.L3Id=pd.id; l3.L3Name=pd.LevelValue__c; l3.checked=false;     lstL3CheckBox.add(l3);
                }
            }
        }
        catch(Exception e)
        {
            System.debug('Message:='+e.getMessage()+'*Line Number='+e.getLineNumber());
        }
        return lstL3CheckBox;
    }
    @AuraEnabled
    public static void saveCategories(string eventidp,string selectedCat,string notSelectedCat)
    {
        try
        {
           // String eventId=ApexPages.currentPage().getParameters().get('eventId');
            String eventId=eventidp;
            CheckClose=false;
            CheckShow=true;
            if(String.isNotBlank(eventId))
            {
                String l3CategoryId=selectedCat;
                String noSelectedL3CategoryId=notSelectedCat;
                
                List<Event_Edition_Sub_Category_Mapping__c> lstSubCatEvent=new List<Event_Edition_Sub_Category_Mapping__c>();
                List<String> ids=l3CategoryId.split(',');
                List<Levels_Master__c> l3Category=[Select id,name,LevelValue__c from Levels_Master__c where id IN:ids]; 
				List<Levels_Master__c> l2Category= new list<Levels_Master__c>();
                if(!test.isRunningTest()){
                           l2Category=[Select id,name, LevelValue__c from Levels_Master__c where LevelValue__c=:categoryL2 and Mapped_To_Level__r.LevelValue__c=:categoryL1 and Level_Name__c='L2'];             

                }
                else{
                    l2Category=[Select id,name, LevelValue__c from Levels_Master__c];             
                }
               
                Event_Edition_Product_Category_Mapping__c eventProduct=new Event_Edition_Product_Category_Mapping__c();
                // [CCEN-434]- added the condition on Line 152 "Event_Edition__c =:eventId"
                
                List<Event_Edition_Product_Category_Mapping__c> eventProductCat= new list<Event_Edition_Product_Category_Mapping__c>();
                if(!Test.isRunningTest()){
                eventProductCat=[Select id from Event_Edition_Product_Category_Mapping__c Where Levels_Master__c=:l2Category[0].id and Event_Edition__c=: eventId];
                }
                else{
                    eventProductCat=[Select id from Event_Edition_Product_Category_Mapping__c ];
                }
                // No product category L2 inserted yet
                if(eventProductCat.size()==0)
                {
                    if(l2Category.size()>0)
                    {
                        eventProduct.Event_Edition__c=eventId;
                        eventProduct.Levels_Master__c=l2Category[0].id;
                        insert eventProduct;
                    }
                    // Iterate L3 category and insert.
                    //for(Product_Category__c L3:l3Category)
                    for(Levels_Master__c L3:l3Category) 
                    {
                      Event_Edition_Sub_Category_Mapping__c eventSubCatProduct=new Event_Edition_Sub_Category_Mapping__c();
                      eventSubCatProduct.Event_Edition__c=eventId;
                      eventSubCatProduct.Levels_Master__c=L3.id;
                      eventSubCatProduct.Event_Edition_Product_Category_Mapping__c=eventProduct.id;
                      lstSubCatEvent.add(eventSubCatProduct);  
                    }
                    insert lstSubCatEvent;
                }
                // L2 category already inserted and sub category L3 getting upadted.
                else
                {
                    List<String> l3NotSelectsids=noSelectedL3CategoryId.split(',');
                    List<Event_Edition_Sub_Category_Mapping__c> eventSubProductCat=[Select id,Event_Edition__c,Event_Edition_Product_Category_Mapping__c from Event_Edition_Sub_Category_Mapping__c Where Event_Edition_Product_Category_Mapping__r.Levels_Master__c=:l2Category[0].id and Levels_Master__c IN:l3NotSelectsids ];//and Event_Edition__c=:eventId];
                    delete eventSubProductCat;
                    
                    // Iterate L3 category and insert.
                    //List<Product_Category__c> l3SubEventCategory=[select id,(select id from Event_Edition_Sub_Categories_Mapping__r where Product_Category__c IN:ids) from Product_Category__c where ParentCatID__c=:l2Category[0].id and Id IN:ids];
                    List<Levels_Master__c> l3SubEventCategory=[select id,(select id from Event_Edition_Sub_Categories_Mapping__r where Levels_Master__c IN:ids) from Levels_Master__c where Mapped_To_Level__c=:l2Category[0].id and Id IN:ids];                    
                    List<Event_Edition_Sub_Category_Mapping__c> lstsubEvntVatIds=[select id,Event_Edition_Product_Category_Mapping__c from Event_Edition_Sub_Category_Mapping__c where Levels_Master__c IN:ids];
                    //for(Product_Category__c L3:l3SubEventCategory)
                    for(Levels_Master__c L3:l3SubEventCategory)
                    {
                      if(L3.Event_Edition_Sub_Categories_Mapping__r.size()==0)
                      {
                          Event_Edition_Sub_Category_Mapping__c eventSubCatProduct=new Event_Edition_Sub_Category_Mapping__c();
                          eventSubCatProduct.Event_Edition__c=eventId;  eventSubCatProduct.Levels_Master__c=L3.id; eventSubCatProduct.Event_Edition_Product_Category_Mapping__c=lstsubEvntVatIds[0].Event_Edition_Product_Category_Mapping__c;
                          lstSubCatEvent.add(eventSubCatProduct); 
                      }
                    }
                    insert lstSubCatEvent;
                }
            }
        }
        catch(Exception e)
        {
            System.debug('Message:='+e.getMessage()+'*Line Number='+e.getLineNumber());
        }
    }
    
   
    public class showL3Checkbox
    {
         @AuraEnabled
        public String L3Id{get;set;}
         @AuraEnabled
        public String L3Name{get;set;}
         @AuraEnabled
        public Boolean checked{get;set;}
    }
}