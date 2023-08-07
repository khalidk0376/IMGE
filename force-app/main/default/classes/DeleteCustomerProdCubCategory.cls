/**
 * Created/Modified By: Girikon(Amish)
 * Created On:          12/19/2017
 * Description/Purpose: This class is called through the SKUID page: ProductCategories
 *                      This Class is used for deleting custProCategory,custProSubCategory,EventEProCategory and EventEProSubCategory from Operation Portal
 * Methods:             deleteCustomerProdSubCategory, deleteCustomerProdCatCategory
 * Test Class:          DeleteCustomerProdCubCategory_Test
 **/

global class DeleteCustomerProdCubCategory{
    //Webservice to delete custProSubCategory and EventEProSubCategory 
    webservice static string deleteCustomerProdSubCategory(String EPSCMId) 
    {     
        List <Event_Edition_Sub_Category_Mapping__c> eEPSCMList=[Select id from Event_Edition_Sub_Category_Mapping__c  where id =:EPSCMId];
        List <Customer_Product_Sub_Category__c> cPSCList=[Select id,Event_Edition_Sub_Category_Mapping__c,Customer_Product_Category__c from Customer_Product_Sub_Category__c where Event_Edition_Sub_Category_Mapping__c IN:eEPSCMList];              
        //List of new records
        List <Customer_Product_Sub_Category__c> cPSCNewList = new list<Customer_Product_Sub_Category__c>();
        List <Event_Edition_Sub_Category_Mapping__c> eEPSCMNewList = new list<Event_Edition_Sub_Category_Mapping__c>();
        Set<id> setCPCIds= new Set<Id>();
        for(Customer_Product_Sub_Category__c  cps: cPSCList)
        {
            Customer_Product_Sub_Category__c cpsc= new Customer_Product_Sub_Category__c();
            cpsc.Id= cps.Id;
            cPSCNewList.add(cpsc);
            setCPCIds.add(cps.Customer_Product_Category__c);
        }
        if(cPSCNewList!=null){
            delete cPSCNewList;
        }
        for(Event_Edition_Sub_Category_Mapping__c  esc: eEPSCMList)
        {
            Event_Edition_Sub_Category_Mapping__c escm= new Event_Edition_Sub_Category_Mapping__c();
            escm.Id= esc.Id;
            eEPSCMNewList.add(escm);
        }
        if(eEPSCMNewList!=null){
            delete eEPSCMNewList;
        }
        integer flag=0;
        if(setCPCIds!=null)
        {
            List <Customer_Product_Category__c> cPCList=[Select id from Customer_Product_Category__c where id IN:setCPCIds];
            List <Customer_Product_Sub_Category__c> cPSCatList=[Select id,Customer_Product_Category__c from Customer_Product_Sub_Category__c where Customer_Product_Category__c  IN:cPCList];  
            List <Customer_Product_Category__c> cPCNewList= new list<Customer_Product_Category__c>();     
            for (Customer_Product_Category__c cpcc: cPCList)
            { 
                flag=0;
                Customer_Product_Category__c  cpccc= new Customer_Product_Category__c ();
                cpccc.Id= cpcc.Id;      
                for (Customer_Product_Sub_Category__c cpscc :cPSCatList)
                {
                    if (cpcc.id==cpscc.Customer_Product_Category__c )
                    {
                        flag=1;
                    }
                }
                if (flag==0)
                {
                    cPCNewList.add(cpccc);
                }
                
            }
            if(cPCNewList!=null)
            {
                delete cPCNewList;
            }
        }
        
        
        return null;
       
    }
    
    //Webservice to delete custProCategory,custProSubCategory,EventEProCategory and EventEProSubCategory from Operation Portal
    webservice static string deleteCustomerProdCatCategory(String EPCMId) 
    {
        List <Event_Edition_Product_Category_Mapping__c> eEPCMList=[Select id from Event_Edition_Product_Category_Mapping__c where id =:EPCMId];
        List <Event_Edition_Sub_Category_Mapping__c> eEPSCMList=[Select id, Event_Edition_Product_Category_Mapping__c from Event_Edition_Sub_Category_Mapping__c  where Event_Edition_Product_Category_Mapping__c IN:eEPCMList];
        List <Customer_Product_Sub_Category__c> cPSCList=[Select id,Event_Edition_Sub_Category_Mapping__c from Customer_Product_Sub_Category__c where Event_Edition_Sub_Category_Mapping__c IN:eEPSCMList];      
        //List of new records
        List <Customer_Product_Sub_Category__c> cPSCNewList = new list<Customer_Product_Sub_Category__c>();
        List <Event_Edition_Sub_Category_Mapping__c> eEPSCMNewList = new list<Event_Edition_Sub_Category_Mapping__c>();
        List <Event_Edition_Product_Category_Mapping__c> eEPCMNewList = new list<Event_Edition_Product_Category_Mapping__c>();
        for(Customer_Product_Sub_Category__c  cps: cPSCList)
        {
            Customer_Product_Sub_Category__c cpsc= new Customer_Product_Sub_Category__c();
            cpsc.Id= cps.Id;
            cPSCNewList.add(cpsc);
        }
        if(cPSCNewList!=null){
            delete cPSCNewList;
        }
        for(Event_Edition_Sub_Category_Mapping__c  esc: eEPSCMList)
        {
            Event_Edition_Sub_Category_Mapping__c escm= new Event_Edition_Sub_Category_Mapping__c();
            escm.Id= esc.Id;
            eEPSCMNewList.add(escm);
        }
        if(eEPSCMNewList!=null){
            delete eEPSCMNewList;
        }
        for(Event_Edition_Product_Category_Mapping__c ec: eEPCMList)
        {
            Event_Edition_Product_Category_Mapping__c ecm= new Event_Edition_Product_Category_Mapping__c();
            ecm.Id= ec.Id;
            eEPCMNewList .add(ecm);
        }
        if(eEPCMNewList !=null){
            delete eEPCMNewList ;
        }
        return null;
    }
}