/**
 * Created/Modified By: Girikon(Aishwarya)/Aishwarya
 * Created On:          24/08/2018
 * modified On:         29/08/2018
 * @description : Handler class which will be called by the triggers trgFormPermission/trgManualPermission/ CCEN-193
 * Methods:             deleteFormsToStandContractor, deleteManualsToStandContractor
 * Test Class:          AssignFormsManualsToStandContractor_Test(84%)
 * Last Modified By :   Girikon[Aishwarya CCEN-735/738 Apr 3 2019]
**/

public without sharing class DeleteFormsManualsToStandContractor
{
    public void deleteFormsToStandContractor(List<Event_Edition_Form__c> listEEF)
    {
        List<String> listExpProductIds = new List<String>();
        List<String> listExpBoothIds = new List<String>();
        List<String> listStrExpoBoothproductType = new List<String>();
        List<String> listStrExpoBoothType = new List<String>();
        Set<String>  setExpproductType = new Set<String>();
        Set<String>  setExpBoothType = new Set<String>();
        List<User_Form_Action__c> listUFAForDelete = new List<User_Form_Action__c>();
        Set<String> setUFAForDelete = new Set<String>();
        Set<String> setBoothContMapping = new Set<String>();
        List<User_Form_Action__c> listExistingUFA = new List<User_Form_Action__c>();
        List<Forms_Permission__c> listFP = new List<Forms_Permission__c>();
        
        if(Schema.sObjectType.Forms_Permission__c.isAccessible())
        {
            listFP = [Select Id, User_Type__c, User_Type__r.Name, Event_Edition_Form__r.Expocad_Product_Type__c, Event_Edition_Form__r.Expocad_Booth_Type__c FROM Forms_Permission__c where User_Type__c != null AND 
                                                              User_Type__r.Name = 'Stand Contractor' AND Event_Edition_Form__c IN: listEEF];
        }
        system.debug('&&&&&&&&&&&&&&&&'+listFP +'SIZEFP'+listFP.size());
        
        Set<String> setFPIds = new Set<String>();
        if(listFP.size()>0)
        {
            for(Forms_Permission__c fp : listFP)
            {
                if(fp.Event_Edition_Form__r.Expocad_Product_Type__c != null || fp.Event_Edition_Form__r.Expocad_Booth_Type__c != null)
                {
                    setFPIds.add(fp.id);
                }
            }
        }
        system.debug('=======================FP'+setFPIds);
        
        if(listFP.size()>0)
        {
            for(Forms_Permission__c fp: listFP)
            {
                String productType = fp.Event_Edition_Form__r.Expocad_Product_Type__c;            
                if(productType != null)
                {
                    listExpProductIds = productType.split(';');
                    for(string str:listExpProductIds)
                    {
                        setExpproductType.add(str);
                    }
                }
                system.debug('^^^^^^^^^^^^^^^^^^^^^^^^'+setExpproductType+'Size;;;'+setExpproductType.size());
              
                String boothType = fp.Event_Edition_Form__r.Expocad_Booth_Type__c;            
                if(boothType != null)
                {
                    listExpBoothIds = boothType.split(';');
                    for(string str: listExpBoothIds)
                    {
                        setExpBoothType.add(str);
                    }
                }
                system.debug('%%%%%%%%%%%%%%%%%%ExpoBootthType '+setExpBoothType+'SIZE'+setExpBoothType.size());
            }
        }
        
        for(string str :setExpproductType)
        {
            listStrExpoBoothproductType.add(str);
        }
        
        for(string str :setExpBoothType)
        {
            listStrExpoBoothType.add(str);
        }
        /* CCEN-735 changes corresponding to expocad new object start*/
        if(Schema.sObjectType.User_Form_Action__c.isAccessible())
        {
            listExistingUFA = [Select Id, Account__c, User_Type__c, Form_Permission__c, BoothContractorMapping__r.Opp_Booth_Mapping__r.Expocad_Booth__r.Booth_Type__c, 
                                             BoothContractorMapping__r.Opp_Booth_Mapping__r.Expocad_Booth__r.Matched_Product_Name__c FROM User_Form_Action__c where 
                                             Form_Permission__c IN: setFPIds AND User_Type__r.Name ='Stand Contractor']; 
        }
        system.debug('===================UFA '+listExistingUFA+'size:: '+listExistingUFA.size());
        
        if(listStrExpoBoothproductType.size()>0)
        {
            for(String str : listStrExpoBoothproductType)
            {
                for(User_Form_Action__c ufa :listExistingUFA)
                {
                    system.debug('==============================UFA'+ufa.BoothContractorMapping__r.Opp_Booth_Mapping__r.Expocad_Booth__r.Matched_Product_Name__c);
                    if(ufa.BoothContractorMapping__r.Opp_Booth_Mapping__r.Expocad_Booth__r.Matched_Product_Name__c != null && str == ufa.BoothContractorMapping__r.Opp_Booth_Mapping__r.Expocad_Booth__r.Matched_Product_Name__c )
                    {
                        setUFAForDelete.add(ufa.id);
                    }
                }
            }
        }
        
        if(listStrExpoBoothType.size()>0)
        {
            for(String str : listStrExpoBoothType)
            {
                system.debug('=======================================STR '+str);
                for(User_Form_Action__c ufa :listExistingUFA)
                {
                    system.debug('==============================UFA'+ufa.BoothContractorMapping__r.Opp_Booth_Mapping__r.Expocad_Booth__r.Booth_Type__c );
                    if(ufa.BoothContractorMapping__r.Opp_Booth_Mapping__r.Expocad_Booth__r.Booth_Type__c != null && str == ufa.BoothContractorMapping__r.Opp_Booth_Mapping__r.Expocad_Booth__r.Booth_Type__c)
                    {
                        setUFAForDelete.add(ufa.id);
                    }
                }
            }
        }
        /* CCEN-735 changes corresponding to expocad new object end*/
        system.debug('@@@@@@@@@@@@@@@@@@@@@@@@@@@@@SET '+setUFAForDelete+'DeleteUFASIZE '+setUFAForDelete.size());
        
        if(listStrExpoBoothproductType.size()>0 || listStrExpoBoothType.size()>0)
        {
            listUFAForDelete = [Select Id FROM User_Form_Action__c where Form_Permission__c IN: setFPIds AND Id NOT IN: setUFAForDelete AND User_Type__r.Name ='Stand Contractor'];
            system.debug('===================UFA DELETE'+listUFAForDelete+'SIZE:: '+listUFAForDelete.Size());
        }
        
        try
        {
            if(listUFAForDelete.size()>0 && User_Form_Action__c.sObjectType.getDescribe().isDeletable())
            {
                delete listUFAForDelete;
            }
        }catch(exception ex) {ex.getMessage();}
     }

     public void deleteManualsToStandContractor(List<Manual__c> listManual)
     {
        Set<String> setMPIds = new Set<String>();
        List<String> listExpProductIds = new List<String>();
        List<String> listExpBoothIds = new List<String>();
        List<String> listStrExpoBoothproductType = new List<String>();
        List<String> listStrExpoBoothType = new List<String>();
        Set<String>  setExpproductType = new Set<String>();
        Set<String>  setExpBoothType = new Set<String>();
        List<User_Manual_Action__c> listUMAForDelete = new List<User_Manual_Action__c>();
        Set<String> setUMAForDelete = new Set<String>();
        Set<String> setBoothContMapping = new Set<String>();
        List<User_Manual_Action__c> listExistingUMA = new List<User_Manual_Action__c>();
        List<Manuals_Permission__c> listMP = new List<Manuals_Permission__c>();
        
        if(Schema.sObjectType.Manuals_Permission__c.isAccessible())
        {
            listMP = [Select Id, Manuals__c, Manuals__r.Expocad_Product_Type__c, Manuals__r.Expocad_Booth_Type__c, User_Type__c, User_Type__r.Name FROM Manuals_Permission__c where User_Type__c != null AND 
                                          User_Type__r.Name = 'Stand Contractor' AND Manuals__c IN: listManual];
        }
        
        system.debug('&&&&&&&&&&&&&&&&'+listMP +'SIZEFP'+listMP.size());
        
        if(listMP.size()>0)
        {
            for(Manuals_Permission__c mp : listMP)
            {
                if(mp.Manuals__r.Expocad_Product_Type__c != null || mp.Manuals__r.Expocad_Booth_Type__c != null)
                {
                    setMPIds.add(mp.id);
                }
            }
        }
        system.debug('=======================MP'+setMPIds);
        
        if(listMP.size()>0)
        {
            for(Manuals_Permission__c mp: listMP)
            {
                String productType = mp.Manuals__r.Expocad_Product_Type__c;            
                if(productType != null)
                {
                    listExpProductIds = productType.split(';');
                    for(string str:listExpProductIds)
                    {
                        setExpproductType.add(str);
                    }
                }
                system.debug('^^^^^^^^^^^^^^^^^^^^^^^^'+setExpproductType+'Size;;;'+setExpproductType.size());
              
                String boothType = mp.Manuals__r.Expocad_Booth_Type__c;            
                if(boothType != null)
                {
                    listExpBoothIds = boothType.split(';');
                    for(string str: listExpBoothIds)
                    {
                        setExpBoothType.add(str);
                    }
                }
                system.debug('%%%%%%%%%%%%%%%%%%ExpoBootthType '+setExpBoothType);
            }
        }
        
        for(string str :setExpproductType)
        {
            listStrExpoBoothproductType.add(str);
        }
        
        for(string str :setExpBoothType)
        {
            listStrExpoBoothType.add(str);
        }
        
        /* CCEN-738 changes corresponding to expocad new object start*/
        if(Schema.sObjectType.User_Manual_Action__c.isAccessible())
        {   
            listExistingUMA = [Select Id, Account__c, User_Type__c, Manual_Permission__c, BoothContractorMapping__r.Opp_Booth_Mapping__r.Expocad_Booth__r.Booth_Type__c, 
                                             BoothContractorMapping__r.Opp_Booth_Mapping__r.Expocad_Booth__r.Matched_Product_Name__c FROM User_Manual_Action__c where 
                                             Manual_Permission__c IN: setMPIds AND User_Type__r.Name ='Stand Contractor']; 
        }
        
        
        system.debug('===================UMA '+listExistingUMA+'sizeUMA'+listExistingUMA.size());
        
        if(listStrExpoBoothproductType.size()>0 && listExistingUMA.size()>0)
        {
            for(String str : listStrExpoBoothproductType)
            {
                for(User_Manual_Action__c uma :listExistingUMA)
                {
                    if(uma.BoothContractorMapping__r.Opp_Booth_Mapping__r.Expocad_Booth__r.Matched_Product_Name__c != null && str == uma.BoothContractorMapping__r.Opp_Booth_Mapping__r.Expocad_Booth__r.Matched_Product_Name__c )
                    {
                        setUMAForDelete.add(uma.id);
                    }
                }
            }
        }
        
        if(listStrExpoBoothType.size()>0 && listExistingUMA.size()>0)
        {
            for(String str : listStrExpoBoothType)
            {
                for(User_Manual_Action__c uma :listExistingUMA)
                {
                    if(uma.BoothContractorMapping__r.Opp_Booth_Mapping__r.Expocad_Booth__r.Booth_Type__c != null && str == uma.BoothContractorMapping__r.Opp_Booth_Mapping__r.Expocad_Booth__r.Booth_Type__c)
                    {
                        setUMAForDelete.add(uma.id);
                    }
                }
            }
        }
        /* CCEN-738 changes corresponding to expocad new object end*/
        
        if(listStrExpoBoothproductType.size()>0 || listStrExpoBoothType.size()>0)
        {
            listUMAForDelete = [Select Id FROM User_Manual_Action__c where Manual_Permission__c IN: setMPIds AND Id NOT IN: setUMAForDelete AND User_Type__r.Name ='Stand Contractor'];
            system.debug('===================UMA DELETE'+listUMAForDelete);
        }
        
        try
        {
            if(listUMAForDelete.size()>0 && User_Manual_Action__c.sObjectType.getDescribe().isDeletable())
            {
                delete listUMAForDelete;
            }
        }catch (exception ex){ex.getMessage();}
    }
}