/************************************************************************** 
** Last Modified by Shay Spoonmore (shay.spoonmore@informausa.com)2016-10-31
** Note: Create 4 schedule Apex - Jobs Name: GetServiceNowSchedule1
** Modified by Hailey Niemand - 31/10/2019 - Amendments of P1 SCA violations
***************************************************************************/
public class ServiceNowUser 
{
    
    public static Boolean runningTrigger = false;
    public list<Service_Now_Objects__c> infoObjects = [SELECT Fields__c,Enabled__c,Id,Name,Process_Order__c,Record_Limit__c,SFDC_Call_Out_Limit__c,SystemModstamp FROM Service_Now_Objects__c WHERE Enabled__c = true ORDER BY Process_Order__c ASC NULLS LAST];
    public ServiceNowUtils snu = new ServiceNowUtils();
    
    
    public void GetObjectData()
    {    
        for(Service_Now_Objects__c infoObject: infoObjects)
        {
            string snObject= infoObject.name;
      		ServiceNowUtils.AppProcessHistory aph = snu.StartServiceNowObjectHistory(snObject);
            if(aph.appProcessRunning !=null && !aph.appProcessRunning)
            {
    			CallOutObjects(aph.appId, aph.appLastRecord,aph.appStartDate,aph.appEndDate,snObject,integer.valueOf(infoObject.Record_Limit__c), integer.valueOf(infoObject.SFDC_Call_Out_Limit__c), infoObject.Fields__c);
            }
        }
    } 
    
    static boolean isEmptyOrNUll(String value)
    {	
        if(value == null || string.isEmpty(value)) return true;
    	return false;
    }
    
    @future (callout=true)
    public static void CallOutObjects(string appId, string appLastRecord, datetime startDate, datetime endDate,string snObject,integer snRecordLimit,integer snCAllOutLimit, string snFields ) 
    { 
        ServiceNowUtils snUtils = new ServiceNowUtils();
        ServiceNowUtils.EndpointHeaderResponse epResponse = New ServiceNowUtils.EndpointHeaderResponse();//reponse details
        dateTime processCalled = system.now();
        integer recordlimit = snRecordLimit;//Magic number is 800 for size and timeouts
        integer callOutLimit = snCAllOutLimit <= Limits.getLimitCallouts()? snCAllOutLimit: Limits.getLimitCallouts();
        integer snOffset=0;
        boolean appFailed=false;
        string appShortMessage ='';
        string sys_id = '';
        
        integer loopCounter = 0;
        integer recordCounter = 0;
        
        System.debug('###	Test.isRunningTest()='+ Test.isRunningTest());
        System.debug('###	callOutLimit:'+ callOutLimit + '; recordlimit:'+ recordlimit);
        
        
        String requestUrl='/api/now/table/'+ snObject;
        string urlQuery = '&sysparm_query=sys_updated_on%3E%3D'+EncodingUtil.urlEncode(startDate.addMinutes(-1).format('yyyy-MM-dd HH:mm:ss'),'UTF-8')+'^sys_updated_on%3C%3D'+EncodingUtil.urlEncode(endDate.format('yyyy-MM-dd HH:mm:ss'),'UTF-8');
        string urlSysId = '';
        string urlDivision = '';
        string urlFields = '';
        if (!isEmptyOrNUll(snFields))urlFields = '&sysparm_fields=' + EncodingUtil.urlEncode(snFields,'UTF-8');
        if (appLastRecord != null && string.isNotEmpty(appLastRecord))urlSysId = '^sys_id%3E%3D' + appLastRecord;
        if (snObject == 'sys_user' && snUtils.apiSetup.SN_User_Division_Filter__c != null)
        {
            for(String divFilter : snUtils.apiSetup.SN_User_Division_Filter__c.split(';'))//Filter By Divisions
            {
            urlDivision += '^ORu_division%3D' + divFilter.trim();
            }
            urlDivision = '^' + urlDivision.removeStart('^OR');
        }
        
        try
        {
            
            List<ServiceNow_Division__c> snDivisions = new List<ServiceNow_Division__c>();// SN Data From u_org_division
            List<ServiceNow_Company__c> snBusinessGroups = new List<ServiceNow_Company__c>();// SN Data From u_org_business_group
            List<ServiceNow_Department__c> snBusinessUnits = new List<ServiceNow_Department__c>();// SN Data From u_org_business_unit
            List<Active_Directory_Details__c> snUsers = new List<Active_Directory_Details__c>();// SN Data From u_org_business_unit
            do {
                Set<string> snSysId = new Set<string>();	
                string reqURL =requestUrl + '?sysparm_orderby=sys_id&sysparm_display_value=all&sysparm_limit=' + recordlimit + '&sysparm_offset='+ snOffset + urlFields + urlQuery + urlSysId + urlDivision + '^ORDERBYsys_id' ;
                sys_id = '';//Set blank for every loop
                String responseJSON = null;
                
                system.debug('###	getLimitHeapSize():' + limits.getLimitHeapSize());
                system.debug('###	getLimitSize():' + limits.getHeapSize());
                System.debug('###	reqURL: ' + reqURL);
                System.debug('###	Test.isRunningTest(): '+ Test.isRunningTest());
                
                if(Test.isRunningTest())
                { 
                   responseJSON = TestObjectJson();
                   epResponse.totalCount = 10; 
                }
                else
                {
                    //System.debug(response.getBody());
                    HttpResponse response = snUtils.ServiceNowRequest(reqURL, 'GET',null,null);
                    responseJSON = response.getBody();  
                    epResponse = snUtils.EndpointResponseHeaderDetails(response, reqURL);
                    System.debug('###	Endpoint Header:'+ epResponse.FullDetails);
                }
                
                system.debug('###	ResponseJSON:' + responseJSON);
                JSONParser parser = JSON.createParser(responseJSON);
                map<string,id> mapParent = new map<String,id>();
                set<string> setParent = new set<string>();
               
                
                //Get SN parent ids to use for mapping
                if(snObject == 'u_org_business_group' || snObject == 'u_org_business_unit' || snObject == 'sys_user')
                {
                    JSONParser parserCompanyInfo = JSON.createParser(responseJSON);     
                    while (parserCompanyInfo.nextToken() != null) 
                    {
                        
                        if (parserCompanyInfo.getCurrentToken() == JSONToken.START_ARRAY) 
                        {
                            while (parserCompanyInfo.nextToken() != null) 
                            {
                                if (parserCompanyInfo.getCurrentToken() == JSONToken.START_OBJECT) 
                                { 
                                    ServiceNowFields sn = (ServiceNowFields)parserCompanyInfo.readValueAs(ServiceNowFields.class);
                                    if(sn.parent!=null && !isEmptyOrNUll(sn.parent.value)) setParent.add(sn.parent.value);
                                    if(sn.u_division!=null && !isEmptyOrNUll(sn.u_division.value)) setParent.add(sn.u_division.value);
                                    if(sn.u_business_group!=null && !isEmptyOrNUll(sn.u_business_group.value)) setParent.add(sn.u_business_group.value);
                                    if(sn.u_business_unit!=null && !isEmptyOrNUll(sn.u_business_unit.value)) setParent.add(sn.u_business_unit.value);   
                                    parserCompanyInfo.skipChildren();
                                }
                            }
                        }  
                    }
                    
                    //Map Salesforce Object Ids
                    if(setParent.size()>0)
                    {
                        if(snObject == 'u_org_business_group' || snObject == 'sys_user')
                        {
                            for (ServiceNow_Division__c snDivision : [SELECT Id,SN_Sys_Id__c FROM ServiceNow_Division__c Where SN_Sys_Id__c=:setParent])
                            {
                                mapParent.put(snDivision.SN_Sys_Id__c, snDivision.Id);
                            }
                        }
                        
                        if(snObject == 'u_org_business_unit' || snObject == 'sys_user')
                        {
                            for (ServiceNow_Company__c snCompany : [SELECT Id,SN_Sys_Id__c FROM ServiceNow_Company__c Where SN_Sys_Id__c=:setParent])
                            {
                                mapParent.put(snCompany.SN_Sys_Id__c, snCompany.Id);
                            }
                        }
                        
                        if(snObject == 'sys_user')
                        {
                            for (ServiceNow_Division__c snDivision : [SELECT Id,SN_Sys_Id__c FROM ServiceNow_Division__c Where SN_Sys_Id__c=:setParent])
                            {
                                mapParent.put(snDivision.SN_Sys_Id__c, snDivision.Id);
                            }
                        }
                    }
                }    
                    
                //Build Upsert  
                while (parser.nextToken() != null) 
                {
                    if (parser.getCurrentToken() == JSONToken.START_ARRAY) 
                    {
                        while (parser.nextToken() != null) 
                        {
                            if (parser.getCurrentToken() == JSONToken.START_OBJECT) 
                            {
                                ServiceNowFields sn = (ServiceNowFields)parser.readValueAs(ServiceNowFields.class);
                                system.debug('#### sn.sys_id: ' + sn.sys_id.value);
                                system.debug('#### Serialized SN: ' + JSON.serialize(sn));
                                sys_id = sn.sys_id.value;
                                datetime snCreatedOn = Datetime.valueOf(sn.sys_created_on.value);
                                datetime snUpdatedOn = Datetime.valueOf(sn.sys_updated_on.value);
                                boolean isActive = sn.u_active != null ? boolean.valueOf(sn.u_active.value):false;
                                string parentSfId = sn.parent != null ? mapParent.get(sn.parent.value):null;
                               
                                if (snObject == 'u_org_division')
                                {	
                                    ServiceNow_Division__c snDivision = new ServiceNow_Division__c(SN_Sys_Id__c=sn.sys_id.value,SN_Name__c=sn.name.value,Name=sn.name.value,SN_Created_On__c=snCreatedOn,SN_Updated_On__c=snUpdatedOn,SN_Description__c=sn.description.value,SN_Active__c=isActive);
                                    snDivisions.add(snDivision);
                                    snDivision = null;
                                }
                                else if(snObject == 'u_org_business_group')
                                {
                                    ServiceNow_Company__c snBusinessGroup = new ServiceNow_Company__c(SN_Sys_Id__c=sn.sys_id.value, SN_Name__c=sn.name.value, Name=sn.name.value, SN_Created_On__c=snCreatedOn, SN_Updated_On__c=snUpdatedOn, SN_Description__c=sn.description.value,SN_Division_Id__c=sn.parent.value, ServiceNow_Division__c=parentSfId , SN_Parent_Id__c= null ,ServiceNow_Company__c=null,SN_Active__c=isActive );
                                    snBusinessGroups.add(snBusinessGroup);
                                    snBusinessGroup = null;
                                }
                                else if (snObject == 'u_org_business_unit')
                                {
                                    ServiceNow_Department__c snBusinessUnit = new ServiceNow_Department__c(SN_Sys_Id__c=sn.sys_id.value,SN_Name__c=sn.name.value,Name=sn.name.value,SN_Created_On__c=snCreatedOn,SN_Updated_On__c=snUpdatedOn,SN_Description__c=sn.description.value, SN_Company_Id__c=sn.parent.value, ServiceNow_Company__c=parentSfId,SN_Active__c=isActive);
                                    snBusinessUnits.add(snBusinessUnit);
                                    snBusinessUnit=null;
                                }
                                else if (snObject == 'sys_user')
                                {
															                                    
                                    Active_Directory_Details__c snUser = new Active_Directory_Details__c();
                                    snUser.Sys_Id__c=sn.sys_id.value;
                                    snUser.Name=sn.name.value;
                                    snUser.Created_On__c=snCreatedOn;
                                    snUser.Updated_On__c=snUpdatedOn;
                                    snUser.Active__c = boolean.valueOf(sn.active.value);
                                    snUser.AD_UPN__c = sn.u_upn.value;
                                    snUser.Contract_Status__c = sn.u_contract_status.value;
                                    snUser.Country__c = sn.country.display_value;
                                    snUser.Department__c = sn.department.display_value;
                                    snUser.Email__c = sn.email.value;
                                    snUser.Employee_Number__c = sn.employee_number.value;
                                    snUser.First_Name__c = sn.first_name.value;
                                    snUser.Job_Function__c = sn.u_job_function.value;
                                    snUser.Job_Type__c = sn.u_job_type.value;
                                    snUser.Last_Name__c = sn.last_name.value;
                                    snUser.ServiceNow_Company__c = mapParent.get(sn.u_business_group.value);
                                    snUser.ServiceNow_Department__c = mapParent.get(sn.u_business_unit.value);
                                    snUser.ServiceNow_Division__c = mapParent.get(sn.u_division.value);
                                    snUser.SN_Company_Id__c = sn.u_business_group.value;
                                    snUser.SN_Department_Id__c = sn.u_business_unit.value;
                                    snUser.SN_Division_Id__c = sn.u_division.value;
                                    snUser.Source__c = sn.source.value;
                                    snUser.Title__c = sn.title.value;
                                    snUser.User_Name__c = sn.user_name.value;
                                    snUsers.add(snUser);
                                    snUser = null;
                                }
                                
                                System.debug('####	' + snObject +':sys_id='+sys_id+ '::name = ' + sn.Name + sn.u_name);
                                snSysId.add(sys_id);
                                
                                parser.skipChildren();
                                ++recordCounter;
                            }
                        }
                    }  
                }
				mapParent.clear();
                snOffset += recordlimit;
                ++loopCounter; 
                System.debug('### loopCounter= ' + loopCounter + '; recordCounter= ' + recordCounter+'; snOffset= ' + snOffset+ '; totalCount= ' + epResponse.totalCount + ';sys_id= ' + sys_id); 
                
            } 
            while (sys_id != '' && recordCounter <= epResponse.totalCount && loopCounter < callOutLimit ) ;
            
            System.debug('### snDivisions.Size()= ' + snDivisions.Size() + '; snBusinessGroups.Size()= ' + snBusinessGroups.Size() + '; snBusinessUnits.Size()= ' + snBusinessUnits.Size() + '; ' );
            
            
            if (snDivisions.Size() > 0)
            {
                upsert snDivisions SN_Sys_Id__c;
                snDivisions.clear();
            } 
           	if (snBusinessGroups.Size() > 0)
            {
                upsert snBusinessGroups SN_Sys_Id__c;
                snBusinessGroups.clear();
            } 
            if (snBusinessUnits.Size() > 0)
            {
                upsert snBusinessUnits SN_Sys_Id__c;
                snBusinessUnits.clear();
            } 
            if (snUsers.Size() > 0)
            {
                upsert snUsers Sys_Id__c;
                snUsers.clear();
            }
        }
        catch (Exception e) 
        {
            appFailed=true;
            appShortMessage += '!!!ERROR!!!'+ '\r\n';
            appShortMessage += 'LineNumber: ' + e.getLineNumber() + ': ' + e.getMessage() + '\r\n' + e.getStackTraceString();
            appShortMessage += 'Message: ' + e.getMessage() + '\r\n';
            appShortMessage += 'StackTrace: ' + e.getMessage() + '\r\n';
            System.debug('###	' + appShortMessage);   
        }
        finally
        {
            string sfLimits = '';
            sfLimits += 'CpuTime: ' +limits.getCpuTime() + '/' + limits.getLimitCpuTime()+ '\r\n';
            sfLimits += 'Callouts: ' + limits.getCallouts() + '/' + limits.getLimitCallouts()+ '\r\n';
            sfLimits += 'HeapSize: ' + limits.getHeapSize() + '/' + limits.getLimitHeapSize()+ '\r\n';
            sfLimits += 'DmlRows: ' + limits.getDmlRows() + '/' + limits.getLimitDmlRows()+ '\r\n';
            sfLimits += 'Settings CallOutLimit: ' + callOutLimit +  '\r\n';
            
            snUtils.FinishServiceNowObjectHistory(appId, appFailed, sys_id, appShortMessage, appShortMessage + sfLimits+ '\r\n' + epResponse.FullDetails,processCalled,recordCounter,epResponse.totalCount);
        }
    }

    public static string TestObjectJson()
    {
        string x = '{"result": [';
        string fields = '';
        datetime yourDate = datetime.now();
        String dateOutput = yourDate.format('yyyy-MM-dd HH:mm:ss');
        
        for (integer i = 0; i < 10; i++) 
        { 
            fields += '{';
            fields += '"sys_created_on": {"display_value": "'+dateOutput+'","value": "'+dateOutput+'"},';
            fields += '"sys_updated_on": {"display_value": "'+dateOutput+'","value": "'+dateOutput+'"},';
            fields += '"sys_id": {"display_value": "'+i+'","value": "'+i+'"},';
            fields += '"name": {"display_value": "'+i+'","value": "'+i+'"},';
            fields += '"description": {"display_value": "'+i+'","value": "'+i+'"},';
            fields += '"parent": {"display_value": "'+i+'","value": "'+i+'"},';
            fields += '"u_division": {"display_value": "'+i+'","value": "'+i+'"},';
            fields += '"u_contract_status": {"display_value": "'+i+'","value": "'+i+'"},';
            fields += '"country": {"display_value": "United States","value": "US"},';
            fields += '"u_job_type": {"display_value": "'+i+'","value": "'+i+'"},';
            fields += '"employee_number": {"display_value": "'+i+'","value": "'+i+'"},';
            fields += '"u_job_function": {"display_value": "'+i+'","value": "'+i+'"},';
            fields += '"active": {"display_value": "true","value": "true"},'; 
            fields += '"user_name": {"display_value": "'+ i + '//'+ i +'","value": "'+ i + '//'+ i +'"},';
            fields += '"title": {"display_value": "'+i+'","value": "'+i+'"},';
            fields += '"u_business_group": {"display_value": "'+i+'","value": "'+i+'"},';
            fields += '"email": {"display_value": "'+ i + '@'+ i +'.com","value": "'+ i + '@'+ i +'.com"},';
            fields += '"u_upn": {"display_value": "'+ i + '@'+ i +'.com","value": "'+ i + '@'+ i +'.com"},';
            fields += '"u_business_unit": {"display_value": "'+i+'","value": "'+i+'"},';
            fields += '"source": {"display_value": "'+i+'","value": "'+i+'"},';
            fields += '"last_name": {"display_value": "'+i+'","value": "'+i+'"},';
            fields += '"first_name": {"display_value": "'+i+'","value": "'+i+'"},';
            fields += '"department": {"display_value": "'+i+'","value": "'+i+'"}';
            fields += '},';
        }
        x += fields.removeEnd(',');
        x = x + ']}';
        System.debug(x);
        return x;
    }
 
    public static void TestCreateSettings()
    {
        if(Test.isRunningTest())
        {
            List<Setting__c> settings = new List<Setting__c>();
            settings.add(new Setting__c(name='ServiceNow - Setup'));
            settings.add(new Setting__c(name='ServiceNow - Licensing'));
            insert(settings);
            
            List<Setting_Item__c> settingItems = new List<Setting_Item__c>();
            settingItems.add(new Setting_Item__c(Setting__c=settings[0].id, Text_1__c='x', Text_2__c='ApiBase64Encoding', Text_3__c='snOrgIndentifier',Text_4__c='Main',Text_5__c='Test.Informa@Test.com',Text_6__c='ThisFieldTakesAnIdCValue'));
            
            settingItems.add(new Setting_Item__c(Setting__c=settings[1].id, Text_1__c='76a8a6ca5542948096348ccfdc7a89c0', Text_2__c='Salesforce'));
            settingItems.add(new Setting_Item__c(Setting__c=settings[1].id, Text_1__c='7afff7dd25f528c49634b1d7d09b5455', Text_2__c='Force.com - One App'));
            settingItems.add(new Setting_Item__c(Setting__c=settings[1].id, Text_1__c='4e95625b089f30c0875f7f13fc542e69', Text_2__c='Salesforce Platform'));
            settingItems.add(new Setting_Item__c(Setting__c=settings[1].id, Text_1__c='e5010fc925f1a4c49634b1d7d09b54df', Text_2__c='Chatter Free'));
            
            insert(settingItems);    
        }
    }
    
    Public static void TestCreateCustomSettings()
    {
        if(Test.isRunningTest())
        {
            list<Service_Now_Objects__c> snObjects = new list<Service_Now_Objects__c>();
            
            snObjects.add(new Service_Now_Objects__c(name='sys_user',Enabled__c=true,Fields__c='',	Process_Order__c=4,Record_Limit__c=10,SFDC_Call_Out_Limit__c=10));
            snObjects.add(new Service_Now_Objects__c(name='u_org_business_group',Enabled__c=true,Fields__c='',	Process_Order__c=2,Record_Limit__c=10,SFDC_Call_Out_Limit__c=10));
            snObjects.add(new Service_Now_Objects__c(name='u_org_business_unit',Enabled__c=true,Fields__c='',	Process_Order__c=3,Record_Limit__c=10,SFDC_Call_Out_Limit__c=10));
            snObjects.add(new Service_Now_Objects__c(name='u_org_division',Enabled__c=true,Fields__c='',	Process_Order__c=1,Record_Limit__c=10,SFDC_Call_Out_Limit__c=10));
            upsert snObjects Name;
        }
    }
    
    public class ServiceNowFields 
    {
        public ServiceNowFieldValue sys_created_on ;
        public ServiceNowFieldValue sys_updated_on ;
        public ServiceNowFieldValue sys_id;
        public ServiceNowFieldValue name;
        public ServiceNowFieldValue u_name;
        public ServiceNowFieldValue description;
        public ServiceNowFieldValue u_description;
        public ServiceNowFieldValue company;
        public ServiceNowFieldValue u_active;
        public ServiceNowFieldValue parent;
        public ServiceNowFieldValue u_division;
        public ServiceNowFieldValue u_contract_status;
        public ServiceNowFieldValue country;
        public ServiceNowFieldValue u_job_type; 
        public ServiceNowFieldValue employee_number;
        public ServiceNowFieldValue u_job_function;
        public ServiceNowFieldValue active;
        public ServiceNowFieldValue user_name;
        public ServiceNowFieldValue title;
        public ServiceNowFieldValue u_business_group;
        public ServiceNowFieldValue email;
        public ServiceNowFieldValue u_upn;
        public ServiceNowFieldValue u_business_unit;
        public ServiceNowFieldValue source;
        public ServiceNowFieldValue last_name;
        public ServiceNowFieldValue first_name;
        public ServiceNowFieldValue department;
    }      
    public class ServiceNowFieldValue 
    {
        //public string link;
        public string value;
        public string display_value;
    }
}

   
    /**
    public static String TestDepartmentJson()
    {
        String x = '{"records":[';
        Datetime yourDate = Datetime.now();
        String dateOutput = yourDate.format('yyyy-MM-dd HH:mm:ss');
        
        for (Integer i = 0; i < 5; i++) { 
            x=x + '{"__status":"success","u_verified":"true","sys_updated_on":"' + dateOutput + '","sys_id":"department' + i + '","parent":"department' + (i+1) + '","sys_created_on":"2015-05-01 15:14:30","code":"","sys_created_by":"ukcorplan\\\\HammondJ","id":"","cost_center":"","dept_head":"","sys_updated_by":"ukcorplan\\\\HammondJ","description":"","company":"company'+i +'","name":"test department' + i + '","primary_contact":"","sys_mod_count":"1"},';
            
        }
        x = x.removeEnd(',');
        x = x + ']}';
        System.debug(x);
        return x;
    }
    **/
    /**
    public static String TestDivisionJson()
    {
        String x = '{"records":[';
        Datetime yourDate = Datetime.now();
        String dateOutput = yourDate.format('yyyy-MM-dd HH:mm:ss');
        
        for (Integer i = 0; i < 5; i++) { 
            x=x + '{"__status":"success","u_description":"test division'+i+'","u_verified":"true","sys_updated_by":"ukcorplan\\\\HammondJ","sys_updated_on":"' + dateOutput + '","sys_id":"division'+ i +'","sys_mod_count":"3","sys_created_on":"2015-04-09 09:45:45","u_name":"test division'+i+'","sys_created_by":"ukcorplan\\\\HardyP"},';
            
            
        }
        x = x.removeEnd(',');
        x = x + ']}';
        System.debug(x);
        return x;
    }
    **/
    /**
    public static String TestCompanyJson()
    {
        String x = '{"records":[';
        Datetime yourDate = Datetime.now();
        String dateOutput = yourDate.format('yyyy-MM-dd HH:mm:ss');
        
        for (Integer i = 0; i < 5; i++) { 
            x=x + '{"phone":"","u_last_review":"","longitude_old":"","u_abc_compliant":"false","street":"","apple_icon":"","banner_image":"","u_division":"division'+i+'","u_informa":"true","vendor_manager":"","customer":"false","city":"","u_pci_checked":"false","u_last_year_spend":"0.00","primary":"false","u_account_manager":"","longitude":"","banner_text":"","sys_mod_count":"3","stock_price":"","u_mobile":"","u_job_title":"","sys_updated_on":"' + dateOutput + '","parent":"company'+(i+1)+'","u_msa_attached":"false","num_employees":"","country":"","discount":"","u_website":"","u_account_manager_email":"","manufacturer":"false","u_location":"","latitude":"","latitude_old":"","u_current_year_spend":"0.00","u_nda_attached":"false","u_service_review_cycle":"Quarterly","state":"","u_internal_account_owner":"","sys_created_on":"2015-05-01 15:13:02","contact":"","fax_phone":"","sys_updated_by":"ukcorplan\\\\HardyP","name":"test company'+i+'","vendor_type":"","__status":"success","zip":"","rank_tier":"","u_next_review":"","u_type":"","website":"","vendor":"false","u_verified":"true","sys_id":"company'+i+'","u_review_status":"","stock_symbol":"","u_active":"true","profits":"0.00","sys_created_by":"ukcorplan\\\\HammondJ","fiscal_year":"","revenue_per_year":"0.00","market_cap":"0.00","lat_long_error":"","u_annual_spend":"0.00","notes":"*** DO NOT CHANGE*** Verified by Group","publicly_traded":"false","u_code":""},';
            
        }
        x = x.removeEnd(',');
        x = x + ']}';
        System.debug(x);
        return x;
    }
    **/
    /**
    public static String TestUserXML(Integer loopCounter)
    {
        String x = '<?xml version="1.0" encoding="UTF-8"?><xml>';
        
        for (Integer i = 0; i < 5; i++) { 
            x=x + '<sys_user><active>true</active><building/><calendar_integration>1</calendar_integration><city/><company>company' + i + '</company><cost_center/><country/><date_format>yyyy-MM-dd</date_format><department>department'+i+'</department><edu_status>faculty</edu_status><email>' + (i*(loopCounter+1)) + 'f.f@informausa.com</email><employee_number/><failed_attempts/><first_name>Shay</first_name><gender/><home_phone>+1(941) 111 1111</home_phone><introduction>test test test</introduction><last_login/><last_login_device>199.27.244.90</last_login_device><last_login_time>2013-01-10 22:42:27</last_login_time><last_name>x</last_name><last_password/><location>e4abec8725b0a0c09634b1d7d09b54f7</location><manager>4c0bbb120a0aa01100dda8a218b257a5</manager><middle_name/><mobile_phone>+1(941) 726 2735</mobile_phone><name>user' + (i*(loopCounter+1)) +'</name><notification>2</notification><phone>+1 (941) 554 3476</phone><photo/><preferred_language/><schedule/><source>ldap:CN=Spoonmore\\, Shay,OU=UsersWithWin7,OU=Users,OU=US-FL-Sarasota (SAR),OU=Domain Objects,DC=NA,DC=CorpLAN,DC=net</source><state/><street/><sys_class_name>sys_user</sys_class_name><sys_created_by>LibbyP</sys_created_by><sys_created_on>2010-06-18 17:12:01</sys_created_on><sys_domain>global</sys_domain><sys_id>user' + (i*(loopCounter+1)) +'</sys_id><sys_mod_count>1539</sys_mod_count><sys_updated_by>ukcorplan\\ServiceNowScheduler</sys_updated_by><sys_updated_on>2013-01-23 10:02:54</sys_updated_on><time_format/><time_zone>US/Eastern</time_zone><title>Systems Integrator</title><u_assistant/><u_billable_to>US00518 - SFDC</u_billable_to><u_business_unit/><u_contract_status>Employee</u_contract_status><u_created/><u_distinguished_name>CN=Spoonmore\\, Shay,OU=UsersWithWin7,OU=Users,OU=US-FL-Sarasota (SAR),OU=Domain Objects,DC=NA,DC=CorpLAN,DC=net</u_distinguished_name><u_division>division' + i + '</u_division><u_domain_name/><u_external_account>false</u_external_account><u_external_company/><u_first_login>false</u_first_login><u_guid>xbHTnsKXX0Gpofl0Re4orA==</u_guid><u_job_function>IT General</u_job_function><u_job_type>IT</u_job_type><u_last_ad_login_time>2013-01-23 09:06:56</u_last_ad_login_time><u_last_ldap_refresh>2013-01-23 10:02:54</u_last_ldap_refresh><u_leave_date/><u_licensed_from>2011-05-12</u_licensed_from><u_local_account>false</u_local_account><u_local_support_team/><u_object_sid>AQUAAAAAAAUVAAAAdu7Acnht2GJVEX0dZU8AAA==</u_object_sid><u_office_365>Shay.Spoonmore@informa.com</u_office_365><u_personal_title>Mr</u_personal_title><u_primary_group>37f7cf9e0a0aa011000e4857eac7cca1</u_primary_group><u_score>80</u_score><u_start_date/><u_work_request/><user_name>nacorplan\\spoonmores</user_name><vip>false</vip><zip/></sys_user>';
            
            
        }
        x = x + '</xml>';
        System.debug(x);
        return x;
    }
	**/
  /**
    public static void GetServiceNowUserHistory() 
    {
        String appName = 'GetServiceNowUser';
        String appId = ''; 
        String appLastRecord= ''; 
        
        List<ApplicationProcessRunning__c> apr = [Select a.Id, a.Name, a.ProcessCalled__c, a.ProcessLastRecord__c, a.ProcessRunning__c, a.SystemModstamp, a.CreatedDate, a.Error_Message__c from ApplicationProcessRunning__c a where a.Name=:appName order by a.SystemModstamp desc limit 1];
        
        if (apr.Size() == 0)
        {
            ApplicationProcessRunning__c insertAPR = new ApplicationProcessRunning__c(name=appName,ProcessRunning__c= true ,ProcessCalled__c = System.now());
            insert(insertAPR);
            appId = insertAPR.Id;
            
        }
        else
        {
            if (apr[0].ProcessRunning__c == true)
            {
                Datetime createdDate = apr[0].CreatedDate;
                
                //if greater than 45min reset to run and update with error message
                if (createdDate.addMinutes(45) < System.Now())
                {
                    
                    FinishServiceNowUserHistory(appName, System.Now(), apr[0].Id, apr[0].ProcessLastRecord__c, 'Running to long, Apex Dead Message Queue!!'); 
                    apr[0].ProcessRunning__c = false;
                }
                
            }
            
            if (apr[0].ProcessRunning__c == false)
            {
                
                ApplicationProcessRunning__c insertAPR = new ApplicationProcessRunning__c(name=appName,ProcessRunning__c= true ,ProcessCalled__c = System.now());
                insert(insertAPR);
                
                appId = insertAPR.Id;
                appLastRecord= apr[0].ProcessLastRecord__c; 
                
            }
            
            
        }
        
        
        if (appId != '')
        {
            System.debug('*****appLastRecord='+ appLastRecord);
            GetServiceNowUsers(appName,appId,appLastRecord);
        }
        
    }
    **/
    /**
    public static void FinishServiceNowUserHistory(String appName, DateTime processStart, String appId, String appLastRecord, String appMessage) 
    {
        System.debug('*****FinishProcessRunning*****');
        
        
        if(appMessage.length() > 255)appMessage = appMessage.left(255);
        DateTime processFinish = System.now();
        
        ApplicationProcessRunning__c fp = new ApplicationProcessRunning__c(Id= appId, ProcessRunning__c = false,ProcessStart__c = processStart,ProcessFinished__c = processFinish, ProcessLastRecord__c = appLastRecord, Error_Message__c=appMessage);
        
        //fp.ProcessRunning__c = false;
        //fp.ProcessStart__c = processStart;
        //fp.ProcessFinished__c = processFinish;
        //fp.Id = appId;
        //fp.ProcessLastRecord__c = appLastRecord;
        //fp.Error_Message__c
        System.debug('*****FinishProcessRunning: fp.Id=' + fp.Id);
        System.debug('*****FinishProcessRunning: fp.ProcessRunning__c =' + fp.ProcessRunning__c);
        System.debug('*****FinishProcessRunning: fp.ProcessStart__c =' + fp.ProcessStart__c);
        System.debug('*****FinishProcessRunning: fp.ProcessFinished__c =' + fp.ProcessFinished__c);
        
        UPDATE(fp);
    }
	**/
    
    /**
    Private static String ServiceNowUserQuery(String appLastRecord)
    {
        
        String snQueryDivisionFilter = '';
        String snQuery = '';
        String snQuerySysId = '';
        
        
        if (appLastRecord != '' && appLastRecord != null)
        {
            snQuerySysId = 'sys_id%3E' + appLastRecord;
            
            snQuery = '&sysparm_query=' + snQuerySysId;
            
        }
        
        if(snUserDivisionFilter != '' && snUserDivisionFilter != null)
        {
            for(String divFilter : snUserDivisionFilter.split(';'))//Filter By Divisions
            {
            
            snQueryDivisionFilter += '^ORu_division%3D' + divFilter.trim();
            }
            snQueryDivisionFilter = snQueryDivisionFilter.removeStart('^OR');
            
            if(snQuery == '')
            {
            snQuery = '&sysparm_query=' + snQueryDivisionFilter;
            }
            else
            {
               snQuery = snQuery + '^' + snQueryDivisionFilter; 
            }
 
        }
        
        return snQuery;
        
    }
	**/
    
    /**
    @future (callout=true)
    public static void GetServiceNowUsers(String appName,String appId, String appLastRecord) 
    { 
        
       ServiceNowUtils snUtils = new ServiceNowUtils();
        
        
        
        String snQuery = ServiceNowUserQuery(appLastRecord);
        System.debug('#####snQuery= ' + snQuery);
        
        String appMessage ='';
        String sys_id = '';
        
        Integer loopCounter = 0;
        Integer recordlimit = 800;//Magic number is 800 for size and timeouts 
        DateTime processStart = system.now();
        try
        {
            List<Active_Directory_Details__c> adUsers = new List<Active_Directory_Details__c>();
            
            //HttpResponse response = ServiceNowRequest('https://informadev.service-now.com/sys_user.do?XML&sysparm_order=sys_id&sysparm_record_count='+ recordlimit, 'GET');                        
            System.debug('##1Test.isRunningTest()='+ Test.isRunningTest());
            do 
            {
                system.debug('#####getLimitHeapSize():' + limits.getLimitHeapSize());
                system.debug('#####getLimitSize():' + limits.getHeapSize());	
                String reqURL ='sys_user.do?XML&sysparm_orderby=sys_id&sysparm_record_count=' + recordlimit + snQuery;
                System.debug('******reqURL= ' + reqURL);
                
                
                
                Dom.Document doc = new Dom.Document();
                
                System.debug('##2Test.isRunningTest()='+ Test.isRunningTest());
                if(Test.isRunningTest())
                { 
                    doc.load(TestUserXML(loopCounter));
                    
                }
                else
                {
                    //System.debug(response.getBody());
                    HttpResponse response = snUtils.ServiceNowRequest(reqURL, 'GET',null,null);
                    doc = response.getBodyDocument(); 
                }
                
                
                
                sys_id = '';
                snQuery = '';
                
                Dom.XMLNode xml = doc.getRootElement();
                LIST<Dom.Xmlnode> snUser = xml.getChildElements();    
                
                set<String> setCompany = new set<String>();
                set<String> setDivision = new set<String>();
                set<String> setDepartment = new set<String>();
                
                for(Dom.XMLNode child : snUser)//get company information 
                {
                    if(child.getChildElement('department', null).getText() != null  ) setDepartment.add(child.getChildElement('department', null).getText());
                    if(child.getChildElement('company', null).getText() != null) setCompany.add(child.getChildElement('company', null).getText());
                    if(child.getChildElement('u_division', null).getText() != null) setDivision.add(child.getChildElement('u_division', null).getText());
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
                
                
                System.debug('########snUser.size():' + snUser.size());
                for(Dom.XMLNode child : snUser) 
                {
                    //System.debug('########' + EncodingUtil.urlEncode(child.getText(),'UTF-8'));
                    sys_id= child.getChildElement('sys_id', null).getText(); 
                    //urlSysId = '&sysparm_query=sys_id%3E%3D' + sys_id;// + '%26';
                    //urlSysId = '&sysparm_query=sys_id%3E' + sys_id;// + '%26';
                    snQuery = ServiceNowUserQuery(sys_id);
                    
                    String source = child.getChildElement('source', null).getText();
                    
                    System.debug('*******sys_id='+sys_id+ '::name = ' + child.getChildElement('name', null).getText());
                    //System.debug('******name = ' + child.getChildElement('name', null).getText());
                    String companyId = mapCompany.get(child.getChildElement('company', null).getText());
                    String departmentId = mapDepartment.get(child.getChildElement('department', null).getText());
                    String divisionId = mapDivision.get(child.getChildElement('u_division', null).getText());
                    
                    Active_Directory_Details__c adUser = new Active_Directory_Details__c(); 
                    adUser.Active__c = Boolean.valueOf( child.getChildElement('active', null).getText());
                    adUser.name = child.getChildElement('name', null).getText();
                    adUser.email__c = child.getChildElement('email', null).getText();
                    adUser.source__c = child.getChildElement('source', null).getText();
                    adUser.sys_id__c = child.getChildElement('sys_id', null).getText();
                    adUser.User_Name__c = child.getChildElement('user_name', null).getText();
                    adUser.First_Name__c = child.getChildElement('first_name', null).getText();
                    adUser.Last_Name__c = child.getChildElement('last_name', null).getText();
                    adUser.u_guid__c = child.getChildElement('u_guid', null).getText();
                    //adUser.Updated_On__c = child.getChildElement('sys_updated_on', null).getText();
                    //adUser.Created_On__c = child.getChildElement('sys_created_on', null).getText();
                    adUser.u_office_365__c = child.getChildElement('u_office_365', null).getText();
                    adUser.SN_Company_Id__c = child.getChildElement('company', null).getText();
                    adUser.SN_Department_Id__c = child.getChildElement('department', null).getText();
                    adUser.SN_Division_Id__c = child.getChildElement('u_division', null).getText(); 
                    
                    if(companyId != null )adUser.ServiceNow_Company__c=companyId;
                    if(departmentId != null)adUser.ServiceNow_Department__c=departmentId;
                    if(divisionId != null )adUser.ServiceNow_Division__c=divisionId;
                    
                    adUsers.add(adUser);
                    
                    
                    
                }
                
                
                
                ++loopCounter; 
                System.debug('******loopCounter:= ' + loopCounter + '******sys_id= ' + sys_id); 
                
                
                
            } 
            while (sys_id != '' && loopCounter < 12 ) ;
            
            if (adUsers.Size() > 0)
            {
                upsert adUsers sys_id__c;
                adUsers.clear();
            }        
            
            
            
        }
        catch (Exception e) 
        {
            
            appMessage = e.getLineNumber() + ': ' + e.getMessage() + '\r\n' + e.getStackTraceString();
            
        }
        finally
        {
            FinishServiceNowUserHistory(appName, processStart, appId, sys_id, appMessage);
        }
        
        
        //BUG WITH TESTMETHODS: This call stops the test method 
        //if(Test.isRunningTest())
        //{ 
        // HttpResponse response1 = ServiceNowRequest('sys_user.do?XML&sysparm_record_count=1', 'GET', null,null);
        //}
        
    }
    **/
  



  /***

@future (callout=true)
public static void SampleUpdatingServiceNow() {

String username = 'wsdl.soap';            
String password = 'WSd1S0ap';            
Blob headerValue = Blob.valueOf(username + ':' + password);            
String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);

HttpRequest req = new HttpRequest();
req.setHeader('Authorization', authorizationHeader);
req.setHeader('Content-Type', 'application/json');
req.setTimeout(60000);

HttpResponse res = new HttpResponse();
Http http = new Http();

req.setEndpoint('https://informadev.service-now.com/sys_user.do?JSON&sysparm_query=last_name=Spoonmore&sysparm_action=update');
req.setMethod('POST');
//req.setBody('name='+EncodingUtil.urlEncode(name, 'UTF-8')+'&city='+EncodingUtil.urlEncode(city, 'UTF-8'));
//req.setBody(EncodingUtil.urlEncode('{"introduction": "test test test"}', 'UTF-8'));
//req.setBody('{"introduction": "test test test"}');
req.setBody('{"home_phone": "+1(941) 111 1111", "introduction": "test test test"}');

System.debug('********BODY=' + req.getBody());

//req.setCompressed(true); // otherwise we hit a limit of 32000

try {
res = http.send(req);
System.debug('********BODY=' + res.getBody());
} catch(System.CalloutException e) {
System.debug('############# Callout error: '+ e);
System.debug(res.toString());
}

}
**/
    /**  
@future (callout=true)
public static void SampleDeletingServiceNow() {
String snUsedrId = '4c0bb1a60a0aa01101898f65df0427e7';
//String salesforceCRM = '76a8a6ca5542948096348ccfdc7a89c0';
//String salesforceOneApp = '7afff7dd25f528c49634b1d7d09b5455';
String salesforceChatterFree = 'e5010fc925f1a4c49634b1d7d09b54df';

String username = 'wsdl.soap';            
String password = 'WSd1S0ap';            
Blob headerValue = Blob.valueOf(username + ':' + password);            
String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);

HttpRequest req = new HttpRequest();
req.setHeader('Authorization', authorizationHeader);
req.setHeader('Content-Type', 'application/json');
req.setTimeout(60000);

HttpResponse res = new HttpResponse();
Http http = new Http();

req.setEndpoint('https://informadev.service-now.com/slm_license_usage_sys_user_m2m.do?JSON&sysparm_action=deleteMultiple');
req.setMethod('POST');
//req.setBody('name='+EncodingUtil.urlEncode(name, 'UTF-8')+'&city='+EncodingUtil.urlEncode(city, 'UTF-8'));
//req.setBody(EncodingUtil.urlEncode('{"introduction": "test test test"}', 'UTF-8'));
//req.setBody('{"introduction": "test test test"}');
req.setBody('{"sysparm_query": "user='+ snUsedrId +'^license='+ salesforceCRM +'^ORlicense='+ salesforceOneApp +'^ORlicense=' + salesforceChatterFree + '"}');

System.debug('********BODY=' + req.getBody());

//req.setCompressed(true); // otherwise we hit a limit of 32000

try {
res = http.send(req);
System.debug('********BODY=' + res.getBody());
} catch(System.CalloutException e) {
System.debug('############# Callout error: '+ e);
System.debug(res.toString());
}

}**/
    /**
@future (callout=true)
public static void SampleInsertingServiceNow() {
String snUsedrId = '4c0bb1a60a0aa01101898f65df0427e7';
String snUsedrId2 = '9a1c521e0a0aa01100b7e6d4ff971b81';
//String salesforceCRM = '76a8a6ca5542948096348ccfdc7a89c0';
//String salesforceOneApp = '7afff7dd25f528c49634b1d7d09b5455';
String salesforceChatterFree = 'e5010fc925f1a4c49634b1d7d09b54df';

String username = 'wsdl.soap';            
String password = 'WSd1S0ap';            
Blob headerValue = Blob.valueOf(username + ':' + password);            
String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);

HttpRequest req = new HttpRequest();
req.setHeader('Authorization', authorizationHeader);
req.setHeader('Content-Type', 'application/json');
req.setTimeout(60000);

HttpResponse res = new HttpResponse();
Http http = new Http();

req.setEndpoint('https://informadev.service-now.com/slm_license_usage_sys_user_m2m.do?JSON&sysparm_action=insertMultiple');
req.setMethod('POST');
//req.setBody('name='+EncodingUtil.urlEncode(name, 'UTF-8')+'&city='+EncodingUtil.urlEncode(city, 'UTF-8'));
//req.setBody(EncodingUtil.urlEncode('{"introduction": "test test test"}', 'UTF-8'));
//req.setBody('{"introduction": "test test test"}');
String record1 = '{"compliant":"true", "license":"'+ salesforceCRM +'","reason":"test insert from Salesforce - salesforceCRM","user":"' + snUsedrId + '"}';
String record2 = '{"compliant":"true", "license":"'+ salesforceOneApp +'","reason":"test insert from Salesforce - salesforceOneApp","user":"' + snUsedrId + '"}';
String record3 = '{"compliant":"true", "license":"'+ salesforceChatterFree +'","reason":"test insert from Salesforce - salesforceChatterFree","user":"' + snUsedrId + '"}';
String record4 = '{"compliant":"true", "license":"'+ salesforceCRM +'","reason":"test insert from Salesforce - salesforceCRM","user":"' + snUsedrId2 + '"}';
String record5 = '{"compliant":"true", "license":"'+ salesforceOneApp +'","reason":"test insert from Salesforce - salesforceOneApp","user":"' + snUsedrId2 + '"}';
String record6 = '{"compliant":"true", "license":"'+ salesforceChatterFree +'","reason":"test insert from Salesforce - salesforceChatterFree","user":"' + snUsedrId2 + '"}';

req.setBody('{"records":[' + record1 +', '+ record2 +', '+ record3 +', ' + record4 +', '+ record5 +', '+ record6 +']}');

System.debug('********BODY=' + req.getBody());

//req.setCompressed(true); // otherwise we hit a limit of 32000

try {
res = http.send(req);
System.debug('********BODY=' + res.getBody());
} catch(System.CalloutException e) {
System.debug('############# Callout error: '+ e);
System.debug(res.toString());
}

}**/
    /**
@future (callout=true)
public static void SampleUpdatingServiceNowLicense() {
String snUsedrId = '4c0bb1a60a0aa01101898f65df0427e7';
//String salesforceCRM = '76a8a6ca5542948096348ccfdc7a89c0';
//String salesforceOneApp = '7afff7dd25f528c49634b1d7d09b5455';
String salesforceChatterFree = 'e5010fc925f1a4c49634b1d7d09b54df';

String userSfCRM = '';
String userSfOneApp = '';
String userSfChatterFree = '';



//get license by user
String reqURL ='https://informadev.service-now.com/slm_license_usage_sys_user_m2m.do?JSON&sysparm_query=user='+ snUsedrId +'^license='+ salesforceCRM +'^ORlicense='+ salesforceOneApp +'^ORlicense=' + salesforceChatterFree;
System.debug('******reqURL= ' + reqURL);

HttpResponse response = ServiceNowRequest(reqURL, 'GET');                        
JSONParser parser = JSON.createParser(response.getBody()); 



while (parser.nextToken() != null) 
{   
if ((parser.getCurrentToken() == JSONToken.FIELD_NAME))
{
String fieldName = parser.getText();
System.debug('******fieldName: ' + fieldName);
parser.nextToken();
if(fieldName == 'user') {
System.debug('******user= ' +parser.getText());
} else if(fieldName == 'license'){
System.debug('******license= ' +parser.getText());

String licId = parser.getText();

if (licId == salesforceCRM)
{
userSfCRM  = licId;
}
else if (licId == salesforceOneApp)
{
userSfOneApp  = licId;
}
else if (licId == salesforceChatterFree )
{
userSfChatterFree  = licId;
}
}
else if(fieldName == 'sys_id'){
System.debug('******sys_id= ' +parser.getText());

}
}           

}




}   



@future (callout=true)
public static void TestServiceUserQueryGetMore() 
{

String sys_id = '';
Integer loopCounter = 0;
Integer recordlimit = 20000;

do {
String reqURL ='https://informadev.service-now.com/sys_user.do?JSON&'+sys_id+'sysparm_order=sys_id&sysparm_record_count=' + recordlimit;
System.debug('******reqURL= ' + reqURL);

HttpResponse response = ServiceNowRequest(reqURL, 'GET');                        
JSONParser parser = JSON.createParser(response.getBody()); 

sys_id = '';

while (parser.nextToken() != null) 
{   
if ((parser.getCurrentToken() == JSONToken.FIELD_NAME))
{
String fieldName = parser.getText();
//System.debug('******fieldName: ' + fieldName);
parser.nextToken();
if(fieldName == 'name') {
System.debug('******name= ' +parser.getText());
} else if(fieldName == 'user_name'){
System.debug('******user_name= ' +parser.getText());
}
else if(fieldName == 'sys_id'){
System.debug('******sys_id= ' +parser.getText());
sys_id = 'sysparm_query=sys_id%3E%3D' + parser.getText() + '&';
}
}           

}

++loopCounter; 
System.debug('******loopCounter:= ' + loopCounter + '******sys_id= ' + sys_id); 
} while (sys_id != '' && loopCounter < 11) ;



}

**/
    /**

//@future (callout=true)
public static void TestServiceUserQuery() 
{
String sys_id = '';
Integer loopCounter = 0;
Integer recordlimit = 1200;


HttpResponse response = ServiceNowRequest('https://informadev.service-now.com/sys_user.do?XML&sysparm_order=sys_id&sysparm_record_count='+ recordlimit, 'GET');                        

System.debug(response.getBody());
Dom.Document doc = response.getBodyDocument();
Dom.XMLNode xml = doc.getRootElement();
LIST<Dom.Xmlnode> snUser = xml.getChildElements();

for(Dom.XMLNode child : snUser) 
{
//System.debug('########' + EncodingUtil.urlEncode(child.getText(),'UTF-8'));
sys_id= child.getChildElement('sys_id', null).getText();
String source = child.getChildElement('source', null).getText();
System.debug('*******sys_id='+sys_id);
}

/**
JSONParser parser = JSON.createParser(response.getBody()); 

while (parser.nextToken() != null) 
{   
if ((parser.getCurrentToken() == JSONToken.FIELD_NAME))
{
String fieldName = parser.getText();
//System.debug('******fieldName: ' + fieldName);
parser.nextToken();
if(fieldName == 'name') {
System.debug('******name= ' +parser.getText());
} else if(fieldName == 'user_name'){
System.debug('******user_name= ' +parser.getText());
}
else if(fieldName == 'sys_id'){
System.debug('******sys_id= ' +parser.getText());
sys_id = 'sysparm_query=sys_id%3E%3D' + parser.getText() + '&';
}
}

++loopCounter;        
} 


System.debug('******loopCounter:= ' + loopCounter + '******sys_id= ' + sys_id); 
**/
    /** }


public static void TestServiceNowCall() 
{

/** String username = 'wsdl.soap';            
String password = 'WSd1S0ap';            
Blob headerValue = Blob.valueOf(username + ':' + password);            
String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);                
//Get Change Request            
snChangeRequest chg = new snChangeRequest();            
String theUrl = 'https://informadev.service-now.com/change_request.do?JSON&sysparm_action=getRecords&sysparm_query=number=' + 'CHG0043484';                        
Httprequest request = new Httprequest(); 
request.setTimeout(60000);           
request.setEndpoint(theUrl);            
request.setMethod('GET');                        
request.setHeader('Authorization', authorizationHeader);                
Http http = new Http();                        
HttpResponse response = http.send(request);                        
JSONParser parser = JSON.createParser(response.getBody());                        
**/
    /**
HttpResponse response = ServiceNowRequest('https://informadev.service-now.com/change_request.do?JSON&sysparm_action=getRecords&sysparm_query=number=CHG0043484', 'GET');                        
JSONParser parser = JSON.createParser(response.getBody()); 



System.debug('******Test2: ' );
while (parser.nextToken() != null) 
{   
if ((parser.getCurrentToken() == JSONToken.FIELD_NAME))
{
String fieldName = parser.getText();
System.debug('******fieldName: ' + fieldName);
parser.nextToken();
if(fieldName == 'sys_updated_by') {
System.debug('******sys_updated_by= ' +parser.getText());
} else if(fieldName == 'short_description'){
System.debug('******short_description= ' +parser.getText());
}

}           

}


}
**/
 
    /**
    @future (callout=true)
    public static void GetServiceNowObjects(String appName,String appId, String appLastRecord,String snObject, Datetime startDate, Datetime endDate ) 
    { 	
		ServiceNowUtils snUtils = new ServiceNowUtils();
		        
        String urlQuery = '&sysparm_query=u_verified=true^u_informa=true^sys_updated_on%3E%3D'+EncodingUtil.urlEncode(startDate.addMinutes(-1).format('yyyy-MM-dd HH:mm:ss'),'UTF-8')+'^sys_updated_on%3C%3D'+EncodingUtil.urlEncode(endDate.format('yyyy-MM-dd HH:mm:ss'),'UTF-8');
        String urlSysId = '';
        
        if(snObject == 'core_company')
        {}
        else if (snObject == 'u_division')
        {}
        else if (snObject == 'cmn_department')
        {}
        
        
        
        if (appLastRecord != '' && appLastRecord != null)urlSysId = '^sys_id%3E' + appLastRecord; 
        
        
        String appMessage ='';
        String sys_id = '';
        
        Integer loopCounter = 0;
        Integer recordlimit = 800;//Magic number is 800 for size and timeouts 
        DateTime processCalled = system.now();
        try
        {
            
            List<ServiceNow_Department__c> snDepartments = new List<ServiceNow_Department__c>();
            List<ServiceNow_Company__c> snCompanies = new List<ServiceNow_Company__c>();
            List<ServiceNow_Division__c> snDivisions = new List<ServiceNow_Division__c>();
            
            //HttpResponse response = ServiceNowRequest('https://informadev.service-now.com/sys_user.do?XML&sysparm_order=sys_id&sysparm_record_count='+ recordlimit, 'GET');                        
            System.debug('##1Test.isRunningTest()='+ Test.isRunningTest());
            do {
                Set<string> snSysId = new Set<string>();
                system.debug('#####getLimitHeapSize():' + limits.getLimitHeapSize());
                system.debug('#####getLimitSize():' + limits.getHeapSize());	
                String reqURL =snObject + '.do?JSONv2&sysparm_action=getRecords&sysparm_orderby=sys_id&sysparm_record_count=' + recordlimit + urlQuery + urlSysId + '^ORDERBYsys_id' ;
                System.debug('******reqURL= ' + reqURL);
                
                
                
                //Dom.Document doc = new Dom.Document();
                String responseJSON = null;
                
                System.debug('##2Test.isRunningTest()='+ Test.isRunningTest());
                if(Test.isRunningTest())
                { 
                    
                    if(snObject == 'core_company')
                    {
                        responseJSON = TestCompanyJson();        
                    }
                    else if (snObject == 'u_division')
                    {	
                        responseJSON = TestDivisionJson();
                    }
                    else if (snObject == 'cmn_department')
                    {
                        responseJSON = TestDepartmentJson();
                    }             
                    
                }
                else
                {
                    //System.debug(response.getBody());
                    HttpResponse response = snUtils.ServiceNowRequest(reqURL, 'GET',null,null);
                    responseJSON = response.getBody();  
                    //doc = response.getBodyDocument(); 
                }
                system.debug('##### responseJSON:' + responseJSON);
                JSONParser parser = JSON.createParser(responseJSON);
                
                
                sys_id = '';
                urlSysId = '';
                map<String,String> mapCompany = new map<String,String>();
                map<String,String> mapDivision = new map<String,String>();    
                set<String> setCompany = new set<String>();
                set<String> setDivision = new set<String>();
                //set<String> setDepartment = new set<String>();
                if(snObject == 'core_company' || snObject == 'cmn_department')
                {
                    JSONParser parserCompanyInfo = JSON.createParser(responseJSON);     
                    while (parserCompanyInfo.nextToken() != null) 
                    {
                        
                        if (parserCompanyInfo.getCurrentToken() == JSONToken.START_ARRAY) 
                        {
                            
                            
                            while (parserCompanyInfo.nextToken() != null) 
                            {
                                
                                if (parserCompanyInfo.getCurrentToken() == JSONToken.START_OBJECT) 
                                { 
                                    ServiceNowFields sn = (ServiceNowFields)parserCompanyInfo.readValueAs(ServiceNowFields.class);
                                    //if(sn.department != null  ) setDepartment.add(sn.department);
                                    String s = JSON.serialize(sn);
                                    system.debug('#### Serialized SN: ' + s);
                                    if(sn.company != null) setCompany.add(sn.company);
                                    if(snObject == 'core_company')if(sn.parent != null) setCompany.add(sn.parent);
                                    if(sn.u_division != null) setDivision.add(sn.u_division);
                                    
                                    parserCompanyInfo.skipChildren();
                                }
                            }
                        }  
                    }
                    //Create Mappings
                    
                    //map<String,String> mapDepartment = new map<String,String>();
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
                    
                    //if(setDepartment.Size()>0)
                    //{
                    //    for (ServiceNow_Department__c snDepartment : [SELECT Id,SN_Sys_Id__c FROM ServiceNow_Department__c Where SN_Sys_Id__c=:setDepartment])
                    //    {
                    //        mapDepartment.put(snDepartment.SN_Sys_Id__c, snDepartment.Id);
                    //    }
                    //}   
                }    
                //Build Update   
                while (parser.nextToken() != null) 
                {
                    
                    if (parser.getCurrentToken() == JSONToken.START_ARRAY) 
                    {
                        
                        
                        while (parser.nextToken() != null) 
                        {
                            
                            if (parser.getCurrentToken() == JSONToken.START_OBJECT) 
                            {
                                ServiceNowFields sn = (ServiceNowFields)parser.readValueAs(ServiceNowFields.class);
                                urlSysId = '^sys_id%3E' + sn.sys_id;
                                system.debug('#### sn.sys_id: ' + sn.sys_id);
                                //system.debug('#### Size of list items: ' + inv.lineItems.size());
                                
                                String s = JSON.serialize(sn);
                                system.debug('#### Serialized SN: ' + s);
                                Datetime snCreatedOn = Datetime.valueOf(sn.sys_created_on);
                                Datetime snUpdatedOn = Datetime.valueOf(sn.sys_updated_on);
                                String companyId = mapCompany.get(sn.company);
                                //String departmentId =mapDepartment.get(sn.department);
                                String divisionId = mapDivision.get(sn.u_division) ;
                                
                                //if(!snSysId.contains(sys_id))
                                //{
                                if(snObject == 'core_company')
                                {
                                    
                                    ServiceNow_Company__c snCompany = new ServiceNow_Company__c(SN_Sys_Id__c=sn.sys_id, SN_Name__c=sn.name, Name=sn.name, SN_Created_On__c=snCreatedOn, SN_Updated_On__c=snUpdatedOn, SN_Description__c=sn.description,SN_Division_Id__c=sn.u_division, SN_Parent_Id__c=sn.parent,ServiceNow_Division__c = divisionId,ServiceNow_Company__c=mapCompany.get(sn.parent) );
                                    snCompanies.add(snCompany);
                                    
                                }
                                else if (snObject == 'u_division')
                                {	
                                    ServiceNow_Division__c snDivision = new ServiceNow_Division__c(SN_Sys_Id__c=sn.sys_id,SN_Name__c=sn.u_name,Name=sn.u_name,SN_Created_On__c=snCreatedOn,SN_Updated_On__c=snUpdatedOn,SN_Description__c=sn.u_description);
                                    snDivisions.add(snDivision);
                                }
                                else if (snObject == 'cmn_department')
                                {
                                    
                                    ServiceNow_Department__c snDepartment = new ServiceNow_Department__c(SN_Sys_Id__c=sn.sys_id,SN_Name__c=sn.name,Name=sn.name,SN_Created_On__c=snCreatedOn,SN_Updated_On__c=snUpdatedOn,SN_Description__c=sn.description, SN_Company_Id__c=sn.company, ServiceNow_Company__c=companyId);
                                    snDepartments.add(snDepartment);
                                }
                                //}
                                
                                System.debug('####' + snObject +':sys_id='+sys_id+ '::name = ' + sn.Name + sn.u_name);
                                snSysId.add(sys_id);
                                
                                
                                parser.skipChildren();
                            }
                        }
                    }  
                }

                
                
                ++loopCounter; 
                System.debug('******loopCounter:= ' + loopCounter + '******sys_id= ' + sys_id); 
                
            } 
            while (sys_id != '' && loopCounter < 12 ) ;
            
            System.debug('******snCompanies.Size()= ' + snCompanies.Size());
            System.debug('******snDivisions.Size()= ' + snDivisions.Size());
            System.debug('******snDepartments.Size()= ' + snDepartments.Size());
            
            if (snCompanies.Size() > 0)
            {
                upsert snCompanies SN_Sys_Id__c;
                snCompanies.clear();
            } 
            if (snDivisions.Size() > 0)
            {
                upsert snDivisions SN_Sys_Id__c;
                snDivisions.clear();
            }
            if (snDepartments.Size() > 0)
            {
                upsert snDepartments SN_Sys_Id__c;
                snDepartments.clear();
            }
            
        }
        catch (Exception e) 
        {
            
            appMessage = e.getLineNumber() + ': ' + e.getMessage() + '\r\n' + e.getStackTraceString();
            System.debug('******ERROR:= ' + appMessage);    
            
        }
        finally
        {
            snUtils.FinishServiceNowObjectHistory(appName,  appId, sys_id, appMessage,processCalled);
        }
        
        
        
        
    }
    **/