/**
* Class Name : ServiceNow_GetCompanyInfoHandler.
* Created By : Rajesh Kumar 
* Created Date : 11-06-2020
* Test Class: zTest_ServiceNowUser
* Ticket: GGCW-3756
* ***********************************************************************************************************************************************
* @description : ServiceNow_GetCompanyInfo object "Active_Directory_Details__c"
* ***********************************************************************************************************************************************
* Modified By  : Rajesh Kumar - BK-3756 on 11-06-2020
*
**/

public with sharing class ServiceNow_GetCompanyInfoHandler {

    public static void getCompanyInfo(List<Active_Directory_Details__c> newActiveDirectryDetalLst, Map<id, Active_Directory_Details__c> oldActiveDirectryDetal, Boolean isInsert, Boolean isupdate ,Boolean isBefore){

        if(newActiveDirectryDetalLst.size()<=200)
        {
            set<String> setCompany = new set<String>();
            set<String> setDivision = new set<String>();
            set<String> setDepartment = new set<String>();
            for (Integer i=0;i< newActiveDirectryDetalLst.size();i++){ 
                if(newActiveDirectryDetalLst[i].SN_Department_Id__c != null  ){
                    setDepartment.add(newActiveDirectryDetalLst[i].SN_Department_Id__c);
                }
                if(newActiveDirectryDetalLst[i].SN_Company_Id__c != null) {
                    setCompany.add(newActiveDirectryDetalLst[i].SN_Company_Id__c);
                }
                if(newActiveDirectryDetalLst[i].SN_Division_Id__c != null) {
                    setDivision.add(newActiveDirectryDetalLst[i].SN_Division_Id__c);
                }
            }
            
            //Create Mappings
            map<String,String> mapCompany = new map<String,String>();
            map<String,String> mapDivision = new map<String,String>();
            map<String,String> mapDepartment = new map<String,String>();
            if(setCompany.size()>0)
            {
                for (ServiceNow_Company__c snCompany : [SELECT Id,SN_Sys_Id__c FROM ServiceNow_Company__c Where SN_Sys_Id__c=:setCompany])
                {
                    mapCompany.put(snCompany.SN_Sys_Id__c, snCompany.Id);
                }
            }
            if(setDivision.Size()>0)
            {
                for (ServiceNow_Division__c snDivision : [SELECT Id,SN_Sys_Id__c FROM ServiceNow_Division__c Where SN_Sys_Id__c=:setDivision])
                {
                    mapDivision.put(snDivision.SN_Sys_Id__c, snDivision.Id);
                }
            }
            if(setDepartment.Size()>0)
            {
                for (ServiceNow_Department__c snDepartment : [SELECT Id,SN_Sys_Id__c FROM ServiceNow_Department__c Where SN_Sys_Id__c=:setDepartment])
                {
                    mapDepartment.put(snDepartment.SN_Sys_Id__c, snDepartment.Id);
                }
            }
            
            //Add Company Info
            if(mapDepartment.size()>0 || mapDivision.size()>0 || mapCompany.size()>0)
            {
                List<Active_Directory_Details__c> updateAD = new List<Active_Directory_Details__c>();
                for (Integer i=0; i< newActiveDirectryDetalLst.size(); i++) 
                {
                    String companyId = mapCompany.get(newActiveDirectryDetalLst[i].SN_Company_Id__c);
                    String departmentId = mapDepartment.get(newActiveDirectryDetalLst[i].SN_Department_Id__c);
                    String divisionId = mapDivision.get(newActiveDirectryDetalLst[i].SN_Division_Id__c);
                    
                    if((companyId + departmentId + divisionId) != null)
                    {
                        if(companyId != null && newActiveDirectryDetalLst[i].ServiceNow_Company__c!=companyId){
                            newActiveDirectryDetalLst[i].ServiceNow_Company__c=companyId;
                        }
                        if(departmentId != null && newActiveDirectryDetalLst[i].ServiceNow_Department__c!=departmentId){
                            newActiveDirectryDetalLst[i].ServiceNow_Department__c=departmentId;
                        }
                        if(divisionId != null && newActiveDirectryDetalLst[i].ServiceNow_Division__c!=divisionId){
                            newActiveDirectryDetalLst[i].ServiceNow_Division__c=divisionId;
                        }
                    }                    
                }
            } 
        }
    }
}