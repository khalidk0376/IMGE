/**************************************************************************
** Last Modified by Shay Spoonmore (shay.spoonmore@informausa.com)2016-10-20
** Modified by Hailey Niemand - 31/10/2019 - Amendments of P1 SCA violations
** NOTE: 
***************************************************************************/

public class ServiceNowUtils 
{
    public Organization org{get;set;}
    public Service_Now_API__c apiSetup{get;set;}
    
    public ServiceNowUtils()
    {
        if(org == null)
        {
            org = [select Id, IsSandbox, InstanceName from Organization limit 1];
            
            System.debug('####orgIsSandbox: '+ org.IsSandbox + '; orgInstanceName: ' + org.InstanceName + '; org Id: ' + org.Id + '; Org BaseUrl: ' + system.Url.getSalesforceBaseUrl());   
        }
        
        if(apiSetup == null)
        {
            TestCreateCustomSettings();
            apiSetup = Service_Now_API__c.getall().values()[0];
        }
        
    }
    
    public HttpResponse ServiceNowRequest(String requestURL, String requestMethod, String setBody, String setContentType)
    {	
        
        String urlType = apiSetup.Production_EndPoint__c;
        
        If (org.IsSandbox)urlType = apiSetup.Sandbox_EndPoint__c;//Sandboxes only connect to ServiceNow Dev Environment
        
        String url = 'https://'+ urlType + requestURL;
        
        String authorizationHeader = 'Basic ' + apiSetup.API_Base_64_Encode__c;                                               
        Httprequest request = new Httprequest();  
        request.setTimeout(120000);           
        request.setEndpoint(url);            
        request.setMethod(requestMethod);                        
        request.setHeader('Authorization', authorizationHeader);
        if (setContentType != null && setContentType !='')  request.setHeader('Content-Type', 'application/' + setContentType);
        if (setBody != null && setBody !='')  request.setBody(setBody) ;             
        Http http = new Http();
        HTTPresponse res = new HTTPresponse();
        
        if(!Test.isRunningTest()) res = http.send(request);
        return res;
    }
    
    public void SendEmail(string emailTo,string emailSubject, string emailMessage,string emailPriority,string emailDisplayName,string emailOrgWideId,boolean emailIsHtml, List<Messaging.Emailfileattachment> fileAttachments)
    {
        
        if (Limits.getEmailInvocations() < Limits.getLimitEmailInvocations())
        {
            //Send Email
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            if(apiSetup.Org_Wide_Email_Id__c !=null && !system.Test.isRunningTest())mail.setOrgWideEmailAddressId(apiSetup.Org_Wide_Email_Id__c);
            
            string orgDetails = '';
            orgDetails += 'Org: ' + org.Id + '(' +apiSetup.SN_SFDC_Org_Indentifier__c + ')\n\r';
            orgDetails += 'Org isSandbox: ' + org.IsSandbox + '\n\r';
            orgDetails += 'Org InstanceName: ' + org.InstanceName + '\n\r';
            orgDetails += 'Org BaseUrl: ' + URL.getSalesforceBaseUrl().getHost() + '\n\r';
            
            set<string> toDedupeAddresses = new set<String>();
            if (emailTo.endsWith(';') || emailTo.endsWith(',')) 
            {
                integer r = (emailTo.length() - 1);
                emailTo = emailTo.left(r);
            }
            if (emailTo.startsWith(';') || emailTo.startsWith(',')) 
            {
                Integer r = (emailTo.length() - 1);
                emailTo = emailTo.right(r);
            }
            
            toDedupeAddresses.addAll(emailTo.split(';' ,-1));
            
            list<string> toAddresses= new list<string>();
            toAddresses.addAll(toDedupeAddresses);
            
            System.debug('#### emailTo=' + emailTo + ';list:' + toAddresses);
            if(emailDisplayName != null)mail.setSenderDisplayName(emailDisplayName);
            
            mail.setToAddresses(toAddresses);
            mail.setSubject(emailSubject); 
            mail.setBccSender(false);
            
            mail.setEmailPriority(emailPriority);
            mail.setUseSignature(false);
            if(emailIsHtml)
            {
                mail.setHtmlBody(emailMessage);
            }
            else
            {	
                
                mail.setPlainTextBody(orgDetails + emailMessage); 
            }
            
            if(fileAttachments != null && fileAttachments.size()>0)mail.setFileAttachments(fileAttachments);
            Messaging.SendEmailResult[] sendEmailResults = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
    }
    
    public AppProcessHistory StartServiceNowObjectHistory(string snObject) 
    {
        AppProcessHistory aph = new AppProcessHistory();
        string appName = 'ServiceNow.' + snObject;
        id appId = null; 
        string appLastRecord= null;
        boolean appProcessRunning = true;
        datetime appEndDate= System.now();
        datetime appStartDate= datetime.valueOf('2005-01-01 00:00:000Z');
        
        List<ApplicationProcessRunning__c> apr = [Select a.Id,a.ProcessFinished__c,a.ProcessStart__c,ProcessEnd__c, a.Name, a.ProcessCalled__c, a.ProcessLastRecord__c, a.ProcessRunning__c, a.SystemModstamp, a.CreatedDate, a.Error_Message__c,a.ProcessFailed__c,a.ProcessMessage__c,ProcessCount__c,ProcessCountTotal__c from ApplicationProcessRunning__c a where a.Name=:appName order by a.SystemModstamp desc limit 1];
        
        if (apr.Size() == 0)
        {
            ApplicationProcessRunning__c insertAPR = new ApplicationProcessRunning__c(name=appName,ProcessRunning__c= true ,ProcessStart__c=appStartDate,ProcessEnd__c=appEndDate );
            insert(insertAPR);
            appId = insertAPR.Id;
            appProcessRunning = false;
        }
        else
        {
            if (apr[0].ProcessRunning__c == true)
            {
                Datetime createdDate = apr[0].CreatedDate;
                
                //if greater than 45min reset to run and update with error message
                if (createdDate.addMinutes(45) < System.Now())
                {
                    apr[0].ProcessFailed__c = true;
                    apr[0].Error_Message__c = 'Process running to long. Failing and running again!';
                    apr[0].ProcessMessage__c = apr[0].Error_Message__c;
                    FinishServiceNowObjectHistory( apr[0].Id,true, apr[0].ProcessLastRecord__c, apr[0].Error_Message__c,apr[0].ProcessMessage__c,system.now(),null,null ); 
                    apr[0].ProcessRunning__c = false;
                    appProcessRunning = false;
                }
                
            }
            
            if (apr[0].ProcessRunning__c == false)
            {
                if(apr[0].ProcessFailed__c || apr[0].ProcessCount__c < apr[0].ProcessCountTotal__c )
                {
                    appStartDate=apr[0].ProcessStart__c;
                    appLastRecord=apr[0].ProcessLastRecord__c;
                    
                }
                else
                {
                    if(apr[0].ProcessEnd__c != null)appStartDate= apr[0].ProcessEnd__c;
                }
                
                ApplicationProcessRunning__c insertAPR = new ApplicationProcessRunning__c(ProcessLastRecord__c=appLastRecord,name=appName,ProcessFailed__c=false,ProcessRunning__c= true ,ProcessStart__c=appStartDate,ProcessEnd__c=appEndDate);
                insert(insertAPR);
                
                appId = insertAPR.Id;
                appLastRecord= apr[0].ProcessLastRecord__c;
                appProcessRunning = false;
            }
        }
        
        if (appId != null)
        {   
            aph.appId=appId;
            aph.appProcessRunning = appProcessRunning;
            aph.appName=appName; 
            aph.appLastRecord=appLastRecord;
            aph.appStartDate=appStartDate;
            aph.appEndDate=appEndDate;
        }
        return aph;
    }
    
    public void FinishServiceNowObjectHistory(id appId, boolean appFailed, string appLastRecord, string appShortMessage, string appLongMessage, datetime processCalled, integer appRecordCount, integer appRecordCountTotal) 
    {
        if(appShortMessage.length() > 255)appShortMessage = appShortMessage.left(255);
        if(appLongMessage.length() > 32760)appLongMessage = appLongMessage.left(32760);
        DateTime processFinish = System.now();
        
        ApplicationProcessRunning__c fp = new ApplicationProcessRunning__c(Id= appId,ProcessFailed__c= appFailed,ProcessCalled__c = processCalled, ProcessRunning__c = false,ProcessFinished__c = processFinish, ProcessLastRecord__c = appLastRecord, Error_Message__c=appShortMessage, ProcessMessage__c=appLongMessage,ProcessCount__c=appRecordCount,ProcessCountTotal__c=appRecordCountTotal);
        
        System.debug('### FinishProcessRunning: fp.Id=' + fp.Id);
        System.debug('### FinishProcessRunning: fp.ProcessRunning__c =' + fp.ProcessRunning__c);
        System.debug('### FinishProcessRunning: fp.ProcessStart__c =' + fp.ProcessStart__c);
        System.debug('### FinishProcessRunning: fp.ProcessFinished__c =' + fp.ProcessFinished__c);
        
        UPDATE(fp);
    }
    
    public class AppProcessHistory 
    {
        public Id appId ;
        public string appName ;
        public string appLastRecord;
        public boolean appProcessRunning;
        public datetime appStartDate;
        public datetime appEndDate;
    }
    
    public EndpointHeaderResponse EndpointResponseHeaderDetails(HttpResponse webResponse, string requestUrl)
    {
        EndpointHeaderResponse ehr = new EndpointHeaderResponse();
        Integer total =0;
        String response ='';
        response += 'Web Request Url: ' + requestUrl + '\n\r';
        response += 'Web Response Status/Code: '  + webResponse.getStatus() + '/'+webResponse.getStatusCode() + '\n\r';
        for(String para:webResponse.getHeaderKeys())
        {
           if(para != null)response += para + '=' +webResponse.getHeader(para) + '\n\r';       
        }
        
        ehr.FullDetails = response;
        ehr.totalCount = integer.valueOf(webResponse.getHeader('X-Total-Count'));
		return ehr;        
    }
    
    public class EndpointHeaderResponse 
    {
        public string FullDetails;
        public integer totalCount;
        
    } 
    
    Public void TestCreateCustomSettings()
    {
        if(Test.isRunningTest())
        {
            Id orgWideEmailAddressId = [SELECT Id FROM OrgWideEmailAddress WHERE Address = 'do_not_reply.sfdc@informausa.com'].Id;
            Service_Now_API__c sna = new Service_Now_API__c();
            sna.Name = 'setup';
            sna.API_Base_64_Encode__c='xxxx';
            sna.Error_Debug_Emails__c='Do_Not_Reply.SFDC@informausa.com;Shay.Spoonmore@informaUSA.com';
             sna.Notes__c='Test';
              sna.Org_Wide_Email_Id__c= orgWideEmailAddressId ;
              sna.Production_EndPoint__c='informa.service-now.com';
              sna.Sandbox_EndPoint__c='informatest.service-now.com';
              sna.SN_SFDC_Org_Indentifier__c='Main';
              sna.SN_User_Division_Filter__c='Test1;test2';
              sna.Username__c='Test';
            
            upsert sna Name;
        }
    }
}