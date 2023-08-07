/**
* Created/Modified By: Girikon(shashank)
* Created On:          9/17/2018
* @description :  This class is the controller for "AddCustomerProductCategoryLtng" Lightning Component.
*                      This class is used for providing L1 ,L2 ,L3 values to cmp. Accordingly provides saves functionality.
* Methods:             getEventDetails, fetchClassValue,saving,packageInformation
* Test Class:          AddCustomerProductCategoryLtngCtrl_Test

* Modification Log---
* Modified By:         Girikon(amish[CCEN-435],Sunil[CCEN-744 Apr 19 2019], Prashant[C2E-16 26 Aug 2019],[C2E-102 25th Sept 2019])
* Modified On:         10/26/2018,10/05/2018  
**/
public without sharing class AddCustomerProductCategoryLtngCtrl
{
    //Fetch event details   
    @AuraEnabled      
    public static Event_Settings__c getEventDetails(String sEventcode)
    {
        return UtilityMethods.getEventDetails(sEventcode);
    }
    // its for fetching L1   // Customer_Product_Category__c  Customer_Product_Sub_Category__c
    @AuraEnabled 
    public static List<wrapperClass>  fetchClassValue(String eventId, String accountId,String uId,String contactId,String expoId)
    {        
        Set<Id> setLevelMasterIds = new Set<Id>();
        Set<Id> setEEPCMIds = new Set<Id>();
        Map<id,Event_Edition_Sub_Category_Mapping__c> mapEESCM = new Map<id,Event_Edition_Sub_Category_Mapping__c>();
        Map<id,Event_Edition_Product_Category_Mapping__c> mapEEPCM = new Map<id,Event_Edition_Product_Category_Mapping__c>();
        map<String,List<Event_Edition_Product_Category_Mapping__c>> mapL1StringListEEPCM = new map<String,List<Event_Edition_Product_Category_Mapping__c>>();
        map<id,List<Event_Edition_Sub_Category_Mapping__c>> mapPCMidListEESCM = new map<id,List<Event_Edition_Sub_Category_Mapping__c>>();
        map<id,List<WrapEESCMValuesANDCheckbox>> mapPCMidListWrapEESCMValuesANDCheckbox = new map<id,List<WrapEESCMValuesANDCheckbox>>();
        Map<String,List<WrapEEPCMAndchild>> mapL1NameListWrapEEPCMAndchild =new Map<String,List<WrapEEPCMAndchild>>();
        Map<id, id> mapEvntProdCatMapgIdCustProdCategoryObjId = new Map<id, id>();
        Map<id, id> mapEvntSubCatMapgIdCustProdSubCategoryObjId = new Map<id, id>();
        Map<Id, Customer_Product_Category__c> mapCustProdCatDb = new Map<Id,Customer_Product_Category__c>();
        
        for (Customer_Product_Category__c custProdCategoryObj : [SELECT Id,Event_Edition_Product_Category_Mapping__c,Account__c,Contact__c,Event_Edition__c,Opp_Booth_Mapping__c,User__c,LastModifiedBy.Name, LastModifiedDate
                                                                 FROM Customer_Product_Category__c 
                                                                 WHERE Account__c=:AccountId  
                                                                 AND Event_Edition__c=:eventId 
                                                                 AND Opp_Booth_Mapping__c=:expoId  ]) {
           mapEvntProdCatMapgIdCustProdCategoryObjId.put(custProdCategoryObj.Event_Edition_Product_Category_Mapping__c,custProdCategoryObj.Id );          
        }
        for (Customer_Product_Sub_Category__c custProdSubCategoryObj : [SELECT Id,Event_Edition_Sub_Category_Mapping__c,Customer_Product_Category__c,Account__c,User__c,Contact__c,Event_Edition__c,Opp_Booth_Mapping__c 
                                                                        FROM Customer_Product_Sub_Category__c
                                                                        WHERE Account__c=:AccountId  
                                                                        AND Event_Edition__c=:eventId 
                                                                        AND Opp_Booth_Mapping__c=:expoId  ]) {
           mapEvntSubCatMapgIdCustProdSubCategoryObjId.put(custProdSubCategoryObj.Event_Edition_Sub_Category_Mapping__c,custProdSubCategoryObj.Id );           
        }
        Map<Id, Customer_Product_Sub_Category__c> mapCustProdSubCat = new Map<Id,Customer_Product_Sub_Category__c>();
        if (String.isNotBlank(eventId)) 
        {    
            for(Event_Edition_Product_Category_Mapping__c pcm : [Select id, Name, Levels_Master__r.LevelValue__c, Levels_Master__r.Mapped_To_Level__c,Levels_Master__r.Mapped_To_Level__r.LevelValue__c, Event_Edition__r.Name, Levels_Master__c 
                                                                 From Event_Edition_Product_Category_Mapping__c 
                                                                 Where Event_Edition__c =:eventId ])
            {    
                if(!mapL1StringListEEPCM.containsKey((pcm.Levels_Master__r.Mapped_To_Level__r.LevelValue__c )) )
                {  //  new List<Id> { newUser.Id } 
                    mapL1StringListEEPCM.put(pcm.Levels_Master__r.Mapped_To_Level__r.LevelValue__c,new List<Event_Edition_Product_Category_Mapping__c> {pcm} );     
                }
                mapL1StringListEEPCM.get(pcm.Levels_Master__r.Mapped_To_Level__r.LevelValue__c).add(pcm);
                setEEPCMIds.add(pcm.id);
                setLevelMasterIds.add(pcm.Levels_Master__r.Mapped_To_Level__c);
                mapEEPCM.put(pcm.id,pcm);
            }
            for(Event_Edition_Sub_Category_Mapping__c sEESCMObj :[SELECT   Event_Edition_Product_Category_Mapping__c,Event_Edition__c,Id,Levels_Master__c,Name,Levels_Master__r.LevelValue__c,Levels_Master__r.Level_Name__c ,Levels_Master__r.Mapped_To_Level__r.Level_Name__c,Levels_Master__r.Mapped_To_Level__r.LevelValue__c,Levels_Master__r.Mapped_To_Level__r.Mapped_To_Level__r.LevelValue__c,Levels_Master__r.Mapped_To_Level__r.Mapped_To_Level__r.Level_Name__c 
                                                                  FROM Event_Edition_Sub_Category_Mapping__c  
                                                                  Where  Event_Edition_Product_Category_Mapping__c  IN:  setEEPCMIds  
                                                                  And Event_Edition__c=:eventId])
            {   
                if( !mapPCMidListEESCM.containsKey(sEESCMObj.Event_Edition_Product_Category_Mapping__c))
                {  
                    mapPCMidListEESCM.put(sEESCMObj.Event_Edition_Product_Category_Mapping__c, new List<Event_Edition_Sub_Category_Mapping__c> {sEESCMObj});
                }        
                mapPCMidListEESCM.get(sEESCMObj.Event_Edition_Product_Category_Mapping__c).add(sEESCMObj);
                mapEESCM.put(sEESCMObj.id, sEESCMObj);
            }
            
            // initailize wrapper scm with pcm id -- mapPCMidListWrapEESCMValuesANDCheckbox
            for( Event_Edition_Product_Category_Mapping__c pcmObj : mapEEPCM.values())
            {
                List<WrapEESCMValuesANDCheckbox> listWrapEESCMValuesANDCheckbox = new List<WrapEESCMValuesANDCheckbox>(); 
                for(Event_Edition_Sub_Category_Mapping__c scmObj : mapEESCM.values())
                {
                    if( scmObj.Event_Edition_Product_Category_Mapping__c == pcmObj.id )
                    {
                        //  for checking checkbox use a map to see id pcm or pscm  exist then its checked                                                      
                        WrapEESCMValuesANDCheckbox wrapEESCMValuesANDCheckboxObj = new WrapEESCMValuesANDCheckbox(scmObj,(mapEvntSubCatMapgIdCustProdSubCategoryObjId.containsKey(scmObj.Id)?true:false),pcmObj.id,false,false,'','',mapEvntProdCatMapgIdCustProdCategoryObjId.get(pcmObj.Id),mapEvntSubCatMapgIdCustProdSubCategoryObjId.get(scmObj.Id));
                        listWrapEESCMValuesANDCheckbox.add(wrapEESCMValuesANDCheckboxObj);
                    }                    
                }
                // inserting FAKE values 
                if (listWrapEESCMValuesANDCheckbox.size()==0)
                {
                   WrapEESCMValuesANDCheckbox wrapEESCMValuesANDCheckboxObj = new WrapEESCMValuesANDCheckbox(null,false,pcmObj.id,true,(mapEvntProdCatMapgIdCustProdCategoryObjId.containsKey(pcmObj.Id)?true:false),pcmObj.Levels_Master__r.LevelValue__c,pcmObj.Levels_Master__r.Mapped_To_Level__r.LevelValue__c,mapEvntProdCatMapgIdCustProdCategoryObjId.get(pcmObj.Id),'');
                   listWrapEESCMValuesANDCheckbox.add(wrapEESCMValuesANDCheckboxObj);
                }
                mapPCMidListWrapEESCMValuesANDCheckbox.put(pcmObj.id,listWrapEESCMValuesANDCheckbox);
                WrapEEPCMAndchild wrapEEPCMAndchildObj = new WrapEEPCMAndchild(pcmObj,listWrapEESCMValuesANDCheckbox);
                if( String.isNotBlank(pcmObj.Levels_Master__r.Mapped_To_Level__r.LevelValue__c ))
                {                                    
                    if(!mapL1NameListWrapEEPCMAndchild.containskey(pcmObj.Levels_Master__r.Mapped_To_Level__r.LevelValue__c))
                    {                    
                        List<WrapEEPCMAndchild> listWrapEEPCMAndchild = new List<WrapEEPCMAndchild>();
                        listWrapEEPCMAndchild.add(wrapEEPCMAndchildObj);
                        mapL1NameListWrapEEPCMAndchild.put(pcmObj.Levels_Master__r.Mapped_To_Level__r.LevelValue__c,listWrapEEPCMAndchild);
                    }else
                    {
                        mapL1NameListWrapEEPCMAndchild.get(pcmObj.Levels_Master__r.Mapped_To_Level__r.LevelValue__c).add(wrapEEPCMAndchildObj);      
                    }
                    
                }
            }
            List<wrapperClass> listwrapperClass = new List<wrapperClass>(); 
            for(String l1Name : mapL1NameListWrapEEPCMAndchild.keyset() )
            {
                wrapperClass wrapperClassObj = new wrapperClass(l1Name,mapL1NameListWrapEEPCMAndchild.get(l1Name));
                listwrapperClass.add(wrapperClassObj);
            }

            return listwrapperClass;
        }
        return null;
    }

    public class wrapperClass{
        @AuraEnabled public List<WrapEEPCMAndchild> listWrapEEPCMAndchild{get;set;}  // L2 Wrap
        @AuraEnabled public String L1Heading {get;set;} // L1 *
        public  wrapperClass( String L1Heading ,List<WrapEEPCMAndchild> listWrapEEPCMAndchild  ){
            this.listWrapEEPCMAndchild = listWrapEEPCMAndchild;
            this.L1Heading =  L1Heading;
        }
    }
    public class WrapEEPCMAndchild{
        @AuraEnabled public List<WrapEESCMValuesANDCheckbox> listWrapEESCMValuesANDCheckbox {get;set;} // l2  isFakeL3  isFakeL3Checked
        @AuraEnabled public Event_Edition_Product_Category_Mapping__c EEPCMObj {get;set;}
       
        public WrapEEPCMAndchild(Event_Edition_Product_Category_Mapping__c EEPCMObj ,List<WrapEESCMValuesANDCheckbox> listWrapEESCMValuesANDCheckbox) {
            this.listWrapEESCMValuesANDCheckbox =listWrapEESCMValuesANDCheckbox;
            this.EEPCMObj = EEPCMObj;
           
        }
    }
    public class WrapEESCMValuesANDCheckbox{
        @AuraEnabled public id EEPCMid {get;set;}
        @AuraEnabled public Event_Edition_Sub_Category_Mapping__c ObjEESCM {get;set;} // l2
        @AuraEnabled public Boolean isChecked {get;set;}
        //for fake values 
        @AuraEnabled public Boolean isFakeL3 {get;set;}
        @AuraEnabled public Boolean isFakeL3Checked {get;set;}
        @AuraEnabled public String  fakeL3Value {get;set;}
        @AuraEnabled public String  fakeL3L1Value {get;set;}
        @AuraEnabled public String  selectedCatId {get;set;}
        @AuraEnabled public String  selectedsubCatId {get;set;}

        public WrapEESCMValuesANDCheckbox(Event_Edition_Sub_Category_Mapping__c ObjEESCM ,Boolean isChecked, id EEPCMid,Boolean isFakeL3,Boolean isFakeL3Checked,String  fakeL3Value,String fakeL3L1Value,String  selectedCatId,String selectedsubCatId) {
            this.ObjEESCM =ObjEESCM;
            this.isChecked =isChecked;
            this.EEPCMid =EEPCMid;
            this.isFakeL3 =isFakeL3;
            this.isFakeL3Checked =isFakeL3Checked;
            this.fakeL3Value =fakeL3Value;
            this.fakeL3L1Value =fakeL3L1Value;
            this.selectedCatId =selectedCatId;
            this.selectedsubCatId =selectedsubCatId;
        }
    } 
    // Made Opp_Booth_Mapping__c lookup field on Customer_Product_Category__c for fetching data from Opportunity_ExpoCAD_Booth_Mapping__c object[CCEN-744]
    @AuraEnabled
    public static void saving(String listSelected,String accountId ,String uId,String contactId,String eventId, String expoId)
    { 
        list<WrapEESCMValuesANDCheckbox> listSelectedConvtd = (list<WrapEESCMValuesANDCheckbox>) JSON.deserialize(listSelected,list<WrapEESCMValuesANDCheckbox>.class);
        
        set<Customer_Product_Category__c> listCustProdCategory = new set<Customer_Product_Category__c>();
        list<Customer_Product_Sub_Category__c> listCustProdSubCategory = new list<Customer_Product_Sub_Category__c>();

        list<Customer_Product_Category__c> listDELCustProdCategory = new list<Customer_Product_Category__c>();
        list<Customer_Product_Sub_Category__c> listDELCustProdSubCategory = new list<Customer_Product_Sub_Category__c>();

        Map<id, Customer_Product_Category__c> mapEvtProdMapgIdCustProdCat = new Map<id,Customer_Product_Category__c >();
        Map<id, Id> mapEvtProdMapgIdCustProdSubCat = new Map<id,Id >();

        map<id,Customer_Product_Category__c> mapCustProCat= new map<id,Customer_Product_Category__c>();
        
        delete [select id from Customer_Product_Category__c
                where Account__c =: AccountId  
                and Event_Edition__c =: eventId 
                and Opp_Booth_Mapping__c =: expoId ];
        delete [select id from Customer_Product_Sub_Category__c 
                where Account__c =: AccountId  
                and Event_Edition__c =: eventId 
                and Opp_Booth_Mapping__c =: expoId  ]; 

        for(Customer_Product_Category__c custProCat :[select id,Event_Edition_Product_Category_Mapping__c from Customer_Product_Category__c  where Account__c =: AccountId and Event_Edition__c =: eventId and Opp_Booth_Mapping__c =: expoId ])
        {
            mapCustProCat.put(custProCat.Event_Edition_Product_Category_Mapping__c,custProCat);
            listDELCustProdCategory.add(custProCat);
        }

        map<id,Customer_Product_Sub_Category__c> mapCustProSubCat= new map<id,Customer_Product_Sub_Category__c>();
        for(Customer_Product_Sub_Category__c custProSubCat :[select id,Event_Edition_Sub_Category_Mapping__c 
                                                             from Customer_Product_Sub_Category__c  
                                                             where Account__c =: AccountId 
                                                             and Event_Edition__c =: eventId 
                                                             and Opp_Booth_Mapping__c =: expoId ])
        {
            mapCustProSubCat.put(custProSubCat.Event_Edition_Sub_Category_Mapping__c,custProSubCat);
            listDELCustProdSubCategory.add(custProSubCat); 
        }

        for ( WrapEESCMValuesANDCheckbox wrapEESCMValuesANDCheckboxObj  : listSelectedConvtd) 
        {
            Customer_Product_Category__c custProdCategoryObj = new Customer_Product_Category__c();
            custProdCategoryObj.Account__c = AccountId;
            custProdCategoryObj.Contact__c =ContactId ;
            custProdCategoryObj.Event_Edition__c = eventId;
            custProdCategoryObj.Event_Edition_Product_Category_Mapping__c = wrapEESCMValuesANDCheckboxObj.EEPCMid ;
            custProdCategoryObj.Opp_Booth_Mapping__c = expoId;
            custProdCategoryObj.User__c = uId;
 
            listCustProdCategory.add(custProdCategoryObj);
           
            if(!wrapEESCMValuesANDCheckboxObj.isFakeL3)
            {            
                Customer_Product_Sub_Category__c custProdSubCategoryObj = new Customer_Product_Sub_Category__c();
                custProdSubCategoryObj.Account__c = AccountId;
                custProdSubCategoryObj.User__c = uId;
                custProdSubCategoryObj.Contact__c =ContactId ;
                custProdSubCategoryObj.Event_Edition__c =eventId ;
                custProdSubCategoryObj.Opp_Booth_Mapping__c =expoId ;
                custProdSubCategoryObj.Event_Edition_Sub_Category_Mapping__c = wrapEESCMValuesANDCheckboxObj.ObjEESCM.Id ;
                mapEvtProdMapgIdCustProdSubCat.put(wrapEESCMValuesANDCheckboxObj.ObjEESCM.Id, wrapEESCMValuesANDCheckboxObj.EEPCMid);
                 
                listCustProdSubCategory.Add(custProdSubCategoryObj);
            } 
        }
        Map<id, id> mapProductCatWithId = new Map<id,id >();
        //insert listCustProdCategory;
        list<Customer_Product_Category__c> listCustProdCategoryobj= new list<Customer_Product_Category__c>(listCustProdCategory); 
        if(Schema.sObjectType.Customer_Product_Category__c.IsCreateable())
        {
            insert listCustProdCategoryobj;
        }
        for(Customer_Product_Category__c objCustProd:listCustProdCategoryobj)
        {
            mapProductCatWithId.put(objCustProd.Event_Edition_Product_Category_Mapping__c,objCustProd.Id);
        }
        try
        {
            for(Customer_Product_Sub_Category__c custProdSubCategoryObj : listCustProdSubCategory)
            {
                string evntEditProCatMap='';
                if(mapEvtProdMapgIdCustProdSubCat.containsKey(custProdSubCategoryObj.Event_Edition_Sub_Category_Mapping__c))
                {
                        evntEditProCatMap=mapEvtProdMapgIdCustProdSubCat.get(custProdSubCategoryObj.Event_Edition_Sub_Category_Mapping__c);
                }

                if(mapProductCatWithId.containskey(evntEditProCatMap))
                {
                    custProdSubCategoryObj.Customer_Product_Category__c=mapProductCatWithId.get(evntEditProCatMap);
                }
                if(mapCustProCat.containskey(evntEditProCatMap))
                {
                    custProdSubCategoryObj.Customer_Product_Category__c=mapCustProCat.get(evntEditProCatMap).Id;
                }
                
            }
            if(Schema.sObjectType.Customer_Product_Sub_Category__c.IsCreateable())
            {
                insert listCustProdSubCategory;
            }
             
        }
        catch(Exception ex)
        {
            System.Debug('ex: '+ex.GetMessage());
        }
    }
    // Fetching data of Customer_Product_Sub_Category__c on the basis of Opportunity_ExpoCAD_Booth_Mapping__c Id[CCEN-744]
    @AuraEnabled
    public static Integer packageInformation(String eventId, String accountId,String uId,String contactId,String expoId)
    {  
        Integer totalProdCatCount = 0;
            Profile_Package_Setting__c profilePackage = new Profile_Package_Setting__c();
            List<User_Package__c> userPackageList = new List<User_Package__c>();
            if(Schema.sObjectType.User_Package__c.isAccessible())
            {
                userPackageList =  [Select Id, Profile_Package_Setting__c From User_Package__c where Event_Edition__c =: eventId AND Account__c =: AccountId  ORDER BY LastModifiedDate DESC limit 1];
            }
            List<Customer_Product_Sub_Category__c> custProdSubCatList = [Select id , Account__c,Opp_Booth_Mapping__c from Customer_Product_Sub_Category__c  where Event_Edition__c =: eventId AND Account__c =: AccountId AND Opp_Booth_Mapping__c =: expoId];
            if(userPackageList.size()>0 && Schema.sObjectType.Profile_Package_Setting__c.isAccessible())
            {
                profilePackage = [Select ID, Product_Categories__c from Profile_Package_Setting__c where Id =:userPackageList[0].Profile_Package_Setting__c ];
                totalProdCatCount = (profilePackage.Product_Categories__c).intValue();
                return totalProdCatCount;
            }
            else
            {
                // [CCEN-435]- added the condition on Line 293 "Event_Edition__c =:eventId"
                profilePackage = [Select ID, Product_Categories__c from Profile_Package_Setting__c where Is_Default__c = true and  Event_Edition__c =:eventId];
                totalProdCatCount = profilePackage.Product_Categories__c.intValue();
                return totalProdCatCount;
            }
     
        
    }
    //delete selcted category and sub category for user
    @AuraEnabled
    public static string deleteCategories(String catId, String subCatId)
    {
        if(String.isNotBlank(catId))
        {
            delete [select id from Customer_Product_Category__c where id=:catId] ;
        }
        if(String.isNotBlank(subCatId))
        {
            delete [select id from Customer_Product_Sub_Category__c where id=:subCatId] ;
        }
        return 'Successfully Deleted';
    }
    // Fetching data from Customer_Product_Sub_Category__c and Customer_Product_Category__c on the basis of Opportunity_ExpoCAD_Booth_Mapping__c Id[CCEN-744]
     @AuraEnabled
    public static string getProductSize(String accID, String conID, String bothID, String eventID)
    {
        string size = '0';
            list<Customer_Product_Sub_Category__c> proSubCat = new list<Customer_Product_Sub_Category__c>();
            proSubCat = [select id from Customer_Product_Sub_Category__c where Account__c = :accID 
                         And Event_Edition__c =: eventID And Opp_Booth_Mapping__c  =: bothID];

            list<Customer_Product_Category__c> proCat = new list<Customer_Product_Category__c>();
            proCat = [select id from Customer_Product_Category__c where Account__c = :accID 
                        And Event_Edition__c =: eventID And Opp_Booth_Mapping__c  =: bothID
                        And id not in (select Customer_Product_Category__c from Customer_Product_Sub_Category__c where Account__c = :accID 
                        And Event_Edition__c =: eventID And Opp_Booth_Mapping__c  =: bothID)];  

             size = String.valueOf(proSubCat.size()+proCat.size()) ;                  

        return String.valueOf(proSubCat.size());
        //return size;


    }
     // Fetching data of Customer_Product_Sub_Category__c and Customer_Product_Category__c on the basis of Opportunity_ExpoCAD_Booth_Mapping__c Id[CCEN-744]
    @AuraEnabled
    public static void savingOps(String listSelected ,String accountId ,String uId , String eventId  , String expoId)
    { 
        list<WrapEESCMValuesANDCheckbox> listSelectedConvtd = (list<WrapEESCMValuesANDCheckbox>) JSON.deserialize(listSelected,list<WrapEESCMValuesANDCheckbox>.class);

        set<Customer_Product_Category__c> listCustProdCategory = new set<Customer_Product_Category__c>();
        list<Customer_Product_Sub_Category__c> listCustProdSubCategory = new list<Customer_Product_Sub_Category__c>();
        Map<id, Customer_Product_Category__c> mapEvtProdMapgIdCustProdCat = new Map<id,Customer_Product_Category__c >();
        Map<id, Id> mapEvtProdMapgIdCustProdSubCat = new Map<id,Id >();

        delete [Select id from Customer_Product_Category__c 
                Where Account__c =: AccountId  
                And Event_Edition__c =: eventId 
                And Opp_Booth_Mapping__c =: expoId ];
        delete [Select id from Customer_Product_Sub_Category__c 
                Where Account__c =: AccountId  
                And Event_Edition__c =: eventId 
                And Opp_Booth_Mapping__c =: expoId  ];

        map<id,Customer_Product_Category__c> mapCustProCat= new map<id,Customer_Product_Category__c>();
        for(Customer_Product_Category__c custProCat :[select id,Event_Edition_Product_Category_Mapping__c from Customer_Product_Category__c  where Account__c =: AccountId and Event_Edition__c =: eventId and Opp_Booth_Mapping__c =: expoId ])
        {
            mapCustProCat.put(custProCat.Event_Edition_Product_Category_Mapping__c,custProCat);
        }

        map<id,Customer_Product_Sub_Category__c> mapCustProSubCat= new map<id,Customer_Product_Sub_Category__c>();
        for(Customer_Product_Sub_Category__c custProSubCat :[select id,Event_Edition_Sub_Category_Mapping__c from Customer_Product_Sub_Category__c  where Account__c =: AccountId and Event_Edition__c =: eventId and Opp_Booth_Mapping__c =: expoId ])
        {
            mapCustProSubCat.put(custProSubCat.Event_Edition_Sub_Category_Mapping__c,custProSubCat);
        }

        for ( WrapEESCMValuesANDCheckbox wrapEESCMValuesANDCheckboxObj  : listSelectedConvtd) 
        {
            Customer_Product_Category__c custProdCategoryObj = new Customer_Product_Category__c();
            custProdCategoryObj.Account__c = AccountId;
            custProdCategoryObj.Event_Edition__c = eventId;
            custProdCategoryObj.Event_Edition_Product_Category_Mapping__c = wrapEESCMValuesANDCheckboxObj.EEPCMid ;
            custProdCategoryObj.Opp_Booth_Mapping__c = expoId;
            
            if(!mapCustProCat.containskey(wrapEESCMValuesANDCheckboxObj.EEPCMid))
            {
                listCustProdCategory.add(custProdCategoryObj);
            }
            
            if(!wrapEESCMValuesANDCheckboxObj.isFakeL3)
            {            
                Customer_Product_Sub_Category__c custProdSubCategoryObj = new Customer_Product_Sub_Category__c();
                custProdSubCategoryObj.Account__c = AccountId;
                custProdSubCategoryObj.Event_Edition__c =eventId ;
                custProdSubCategoryObj.Opp_Booth_Mapping__c =expoId ;
                custProdSubCategoryObj.Event_Edition_Sub_Category_Mapping__c = wrapEESCMValuesANDCheckboxObj.ObjEESCM.Id ;
                mapEvtProdMapgIdCustProdSubCat.put(wrapEESCMValuesANDCheckboxObj.ObjEESCM.Id, wrapEESCMValuesANDCheckboxObj.EEPCMid);
                if(!mapCustProSubCat.containskey(wrapEESCMValuesANDCheckboxObj.ObjEESCM.Id))
                {
                    listCustProdSubCategory.Add(custProdSubCategoryObj);
                }
            } 
        }
        Map<id, id> mapProductCatWithId = new Map<id,id >();
        list<Customer_Product_Category__c> listCustProdCategoryobj= new list<Customer_Product_Category__c>(listCustProdCategory); 
        insert listCustProdCategoryobj;
        for(Customer_Product_Category__c objCustProd:listCustProdCategoryobj)
        {
            mapProductCatWithId.put(objCustProd.Event_Edition_Product_Category_Mapping__c,objCustProd.Id);
        }
       
        try
        {
            for(Customer_Product_Sub_Category__c custProdSubCategoryObj : listCustProdSubCategory)
            {
                string evntEditProCatMap=''; 
                if(mapEvtProdMapgIdCustProdSubCat.containsKey(custProdSubCategoryObj.Event_Edition_Sub_Category_Mapping__c))
                {
                        evntEditProCatMap=mapEvtProdMapgIdCustProdSubCat.get(custProdSubCategoryObj.Event_Edition_Sub_Category_Mapping__c);
                } 

                if(mapProductCatWithId.containskey(evntEditProCatMap))
                {
                    custProdSubCategoryObj.Customer_Product_Category__c=mapProductCatWithId.get(evntEditProCatMap);
                }
                if(mapCustProCat.containskey(evntEditProCatMap))
                {
                    custProdSubCategoryObj.Customer_Product_Category__c=mapCustProCat.get(evntEditProCatMap).Id;
                } 
            }
            insert listCustProdSubCategory; 
        }
        catch(Exception ex)
        {
            System.Debug('ex: '+ex.GetMessage());
        }
    }
    // Added this method to get Last Modified User Details[C2E-16]
    // Added two new fields LastModifiedBy.Profile.Name, LastModifiedBy.ContactId for [C2E-102]
    @AuraEnabled
    public static List<Customer_Product_Sub_Category__c> fetchLastModifiedofUser(String accountId, String eventId, String expoId)
    {
        List<Customer_Product_Sub_Category__c> getProductSubCatDetails = new List<Customer_Product_Sub_Category__c>();
        if(Schema.sObjectType.Customer_Product_Sub_Category__c.isAccessible())
        {
            getProductSubCatDetails = [SELECT Id,Event_Edition_Sub_Category_Mapping__c,Customer_Product_Category__c,Account__c,User__c,Contact__c,Event_Edition__c,Opp_Booth_Mapping__c, LastModifiedBy.Name, LastModifiedBy.Id, LastModifiedBy.Profile.Name, LastModifiedBy.ContactId, LastModifiedDate FROM Customer_Product_Sub_Category__c WHERE Account__c=:accountId  AND Event_Edition__c=:eventId AND Opp_Booth_Mapping__c=:expoId order by CreatedDate DESC limit 1 ];
        }

        return getProductSubCatDetails;
        
    }
}