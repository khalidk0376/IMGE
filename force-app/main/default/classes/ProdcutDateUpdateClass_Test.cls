/**
 * Project:         GAP
 * Date:            10/1/2019
 * Test Class For:  ProdcutDateUpdateClass and UpdateProductStartDateEndDate_Batch
 * Code Coverage:   100%
 * Created By:      Yash Gupta
 * *************************************************************************
 * @Description     This test class covers "ProdcutDateUpdateClass" class and "UpdateProductStartDateEndDate_Batch".
 * *************************************************************************
 * History: 
 */
 
//@Description Test class for "ProdcutDateUpdateClass" class and "UpdateProductStartDateEndDate_Batch".
@isTest
public class ProdcutDateUpdateClass_Test {
     @isTest static void prodcutDateUpdateClassMethodOne() {    
        
        List<Event_Edition__c> lstEventEdition = new List<Event_Edition__c>(); 
        List<Product2> lstProduct = new List<Product2>(); 
        
        Event_Edition__c ed = new Event_Edition__c();
        ed.Start_Date__c = Date.Today();
        ed.End_Date__c = Date.Today().addDays(2);
        lstEventEdition.add(ed);
        if(lstEventEdition.size() > 0){
            insert lstEventEdition;
        }

        Product2 prod = new Product2();
        prod.Name='Corner Booth Fee';
        prod.Family='Event';
        prod.Event_Product_Type__c = 'Booth';
        prod.Event_Edition__c  = ed.Id;
        prod.Start_Date__c = ed.Start_Date__c;
        prod.End_Date__c = ed.End_Date__c;
        lstProduct.add(prod);
        if(lstProduct.size() > 0){
            insert lstProduct;
        }
        System.assertEquals('Booth', prod.Event_Product_Type__c, 'Product must has its Event Product Type as booth');
        Test.startTest();
        
        PageReference pageRef = Page.Date_Update_on_Product;
        pageRef.getParameters().put('id', ed.Id);
        Test.setCurrentPage(pageRef);
        
        ProdcutDateUpdateClass prdCls = new ProdcutDateUpdateClass(new ApexPages.StandardController(ed));
        ProdcutDateUpdateClass prdcls1 = new ProdcutDateUpdateClass();
        prdCls.autoRedirect();
        
        UpdateProductStartDateEndDate_Batch prdBatch = new UpdateProductStartDateEndDate_Batch(ed.Id, ed.Start_Date__c, ed.End_Date__c);
        Database.executeBatch(prdBatch); 
        Test.stopTest();
     }
}