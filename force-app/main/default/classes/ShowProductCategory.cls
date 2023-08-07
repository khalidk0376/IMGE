/**
 * Created :  Archit
 * Last Modified By: Amish (Girikon)/Himanshu Jasuja[BK - 3748]
 * Created On:          8/25/2017 
 * Modified By :    Amish (Girikon)
 * Last Modified Date:  Girikon(amish) [CCEN-434]- line 152,  [Aishwarya BK-3759 27 Aug 2020]
 * Description/Purpose: This is the controller class of the VF page- AddProductCategory
 *                      It is used for adding the product category by Ops Admin
 * Methods:             findCategories, populateL3, saveCategories
 * Test Class:          showProductCategory_Test
 * History: BK-3758 Modified By Rajesh Kumar - on 28-05-2020, [Aishwarya BK-16640 21 June 2021]
 * 
**/

Global class ShowProductCategory
{
    public List<Levels_Master__c> listLabelL3{get;set;}
    public String categoryL2{get;set;}
    public String categoryL1{get;set;}
    public Integer L3Count{get;set;}
    public Boolean showL3{get;set;}
    public Boolean CheckShow{get;set;}
    public Boolean CheckClose{get;set;}
    public String checked{get;set;}
    public List<showL3Checkbox> lstL3CheckBox{get;set;}
    public showProductCategory()
    {
        checked='checked';
        CheckShow=false;
    }
    
    // this method is used to fetch categories related to products 
    @RemoteAction
    //public static String[] findCategories(String qry)
    global static String[] findCategories(String qry)
    {
        List<String> resultList = new List<string>();
        try
        {
            //List<String> resultList = new List<string>();
            if(qry.length()>=1)
            {
                string catInput = '%' + qry + '%';
                List<Levels_Master__c    > lstPrdCat =[Select id,Name,LevelValue__c,MDM_Code__c,Level_Name__c,Mapped_To_Level__r.LevelValue__c 
                                                       From Levels_Master__c 
                                                       Where LevelValue__c 
                                                       LIKE :catInput
                                                       And Level_Name__c='L2' 
                                                       And Mapped_To_Level__r.LevelValue__c!=null];
               
                for(Levels_Master__c pd:lstPrdCat)
                {
                    if(pd.LevelValue__c!=null && pd.Mapped_To_Level__r.LevelValue__c!=null)
                    {
                        resultList.add(pd.LevelValue__c+'~'+'in '+pd.Mapped_To_Level__r.LevelValue__c+'(L1)'); 
                    }
                }
            }
            
            return resultList;
        }
        catch(Exception e)
        {
            System.debug('Message:='+e.getMessage()+'*Line Number='+e.getLineNumber());
        }
        return resultList ;//null;
    }
    
    // this method  use to fetch level 3 products 
    public void populateL3()
    {
        try
        {
           //Added escapeHtml4() - BK - 3748
            lstL3CheckBox=new List<showL3Checkbox>();
            showL3=true;
            categoryL1=ApexPages.currentPage().getParameters().get('label').escapeHtml4();
            categoryL2=ApexPages.currentPage().getParameters().get('category').escapeHtml4();
            String qry='select id,Name,LevelValue__c, MDM_Code__c,Level_Name__c,Mapped_To_Level__c, Mapped_To_Level__r.LevelValue__c,Mapped_To_Level__r.Mapped_To_Level__r.LevelValue__c from Levels_Master__c where Level_Name__c=\'L3\' and Mapped_To_Level__r.LevelValue__c=\''+String.escapeSingleQuotes(categoryL2) +'\' and Mapped_To_Level__r.Mapped_To_Level__r.LevelValue__c=\''+String.escapeSingleQuotes(categoryL1)+'\'';
            listLabelL3=Database.Query(qry);
            List<String> ids=new List<String>();
            L3Count=listLabelL3.size();
            for(Levels_Master__c pd:listLabelL3)
            {
                ids.add(pd.id);
            }
            List<Event_Edition_Sub_Category_Mapping__c> lstL3Event=[Select id,Levels_Master__c,Levels_Master__r.LevelValue__c 
                                                                    From Event_Edition_Sub_Category_Mapping__c 
                                                                    Where Levels_Master__c IN:ids];
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
                    List<Levels_Master__c> lstL3ProductNotInEvents=[select id,Name,LevelValue__c, MDM_Code__c,Level_Name__c,Mapped_To_Level__c,Mapped_To_Level__r.LevelValue__c,Mapped_To_Level__r.Mapped_To_Level__r.LevelValue__c
                                                                    From Levels_Master__c Where id not in:l3IdsFromEvent And Level_Name__c='L3' And  Mapped_To_Level__r.LevelValue__c=:categoryL2 And Mapped_To_Level__r.Mapped_To_Level__r.LevelValue__c=:categoryL1];                    
                    for(Levels_Master__c pd:lstL3ProductNotInEvents)
                    {
                        showL3Checkbox l3=new showL3Checkbox();l3.L3Id=pd.id; l3.L3Name=pd.LevelValue__c; l3.checked=false;lstL3CheckBox.add(l3);
                    }
                }   
            }
            else
            {
                for(Levels_Master__c pd:listLabelL3){showL3Checkbox l3=new showL3Checkbox();l3.L3Id=pd.id; l3.L3Name=pd.LevelValue__c; l3.checked=false;lstL3CheckBox.add(l3);}
            }
        }
        catch(Exception e)
        {
            System.debug('Message:='+e.getMessage()+'*Line Number='+e.getLineNumber());
        }
    }
    
    // this method save categories to database
    public void saveCategories()
    {
        try
        {
            String eventId=ApexPages.currentPage().getParameters().get('eventId').escapeHtml4();
            CheckClose=false;
            CheckShow=true;
            if(String.isNotBlank(eventId))
            {
                String l3CategoryId=ApexPages.currentPage().getParameters().get('selectedCat');
                String noSelectedL3CategoryId=ApexPages.currentPage().getParameters().get('notSelectedCat');
                List<Event_Edition_Sub_Category_Mapping__c> lstSubCatEvent=new List<Event_Edition_Sub_Category_Mapping__c>();
                List<String> ids=l3CategoryId.split(',');
                // selected L3 category list
                List<Levels_Master__c> l3Category=[Select id,name,LevelValue__c 
                                                   From Levels_Master__c 
                                                   Where id IN:ids]; 
                
                
                // get selected category label 2
                List<Levels_Master__c> l2Category=[Select id,name, LevelValue__c 
                                                   From Levels_Master__c where LevelValue__c=:categoryL2 
                                                   And Mapped_To_Level__r.LevelValue__c=:categoryL1 
                                                   And Level_Name__c='L2'];             
                Event_Edition_Product_Category_Mapping__c eventProduct=new Event_Edition_Product_Category_Mapping__c();
                // [CCEN-434]- added the condition on Line 152 "Event_Edition__c =:eventId"
                List<Event_Edition_Product_Category_Mapping__c> eventProductCat=[Select id From Event_Edition_Product_Category_Mapping__c
                                                                                 Where Levels_Master__c=:l2Category[0].id And Event_Edition__c=: eventId];
                
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
                    List<Event_Edition_Sub_Category_Mapping__c> eventSubProductCat=[Select id,Event_Edition__c,Event_Edition_Product_Category_Mapping__c
                                                                                    From Event_Edition_Sub_Category_Mapping__c 
                                                                                    Where Event_Edition_Product_Category_Mapping__r.Levels_Master__c=:l2Category[0].id 
                                                                                    And Levels_Master__c IN:l3NotSelectsids ];//and Event_Edition__c=:eventId];
                    delete eventSubProductCat;
                    
                    // Iterate L3 category and insert.
                    List<Levels_Master__c> l3SubEventCategory=[Select id,(select id from Event_Edition_Sub_Categories_Mapping__r where Levels_Master__c IN:ids)
                                                               From Levels_Master__c
                                                               Where Mapped_To_Level__c=:l2Category[0].id and Id IN:ids];                    
                    List<Event_Edition_Sub_Category_Mapping__c> lstsubEvntVatIds=[Select id,Event_Edition_Product_Category_Mapping__c From Event_Edition_Sub_Category_Mapping__c Where Levels_Master__c IN:ids];
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
        public String L3Id{get;set;}
        public String L3Name{get;set;}
        public Boolean checked{get;set;}
    }
}