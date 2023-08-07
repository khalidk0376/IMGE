/**************************************************************************
** Last Modified by Shay Spoonmore (shay.spoonmore@informausa.com)2016-10-31
** NOTE: 
***************************************************************************/

public class User_ServiceNowLicenseReport 
{
    User_ServiceNowLicense usnl = new User_ServiceNowLicense();
    ServiceNowUtils snu = new ServiceNowUtils();
	public Integer numberUsersActive=0;
    public Integer numberUsersMatchedSnUsers=0;
    public Integer numberUsersMissingActiveDirectory=0;
    public Integer numberUsersMissingLicenseType=0;
    public Integer numberUsersNotMatchServiceNow=0;
    public Integer numberUsersMutiLicenseing=0;
    public String fileName='SFDC_UserLicensing.'+ Userinfo.getOrganizationId() + '.' + System.Now().format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'','UTC') + '.xls';
    public  List<UserLicensingProblem> GenerateReport()
    {
        //fileName = 'MissingLicensing.' + System.Now().format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'','UTC') + '.' +Userinfo.getOrganizationId() + '.xls';
		List<UserLicensingProblem> userProblem = new List<UserLicensingProblem>();
        
        
     
        List<User> usersActiveList = [SELECT Active_Directory_OU__c, Active_Directory_Username__c, Email, Id, License_Type__c, Name, Name_for_Service_Now__c,Username FROM User WHERE IsActive = true AND FederationIdentifier != ''];
    	numberUsersActive = usersActiveList.size();
        
        Map<Id,String> usersIdActiveDirectory = new Map<Id,String>();
        //set<Id> userIdsMissingActiveDirectory = new set<Id>();
        
        for (User u: usersActiveList)
        {
			String problemText = null; 
            
            if (u.Active_Directory_Username__c == null)
            {
                numberUsersMissingActiveDirectory +=1;
                problemText = 'Missing Active Directory Information!';
            }
            else if (u.License_Type__c==Null || !usnl.salesforceLic.keyset().contains(u.License_Type__c.toLowerCase()))
            {
                numberUsersMissingLicenseType+=1;
                problemText = 'Missing License Type in ServiceNow!';
            }
            else
            {
                usersIdActiveDirectory.put(u.Id, u.Name_for_Service_Now__c);
            }
            
            
            if(problemText != null)
            {   
              userProblem.add(addUser(u, problemText));    
            }
            
        }
        
        //Match SFDC User AD information to Service-Now User (Active_Directory_Details__c)
        Set<String> snUsersMatchSfUser = new Set<String>();
        List<Active_Directory_Details__c> snUsersMatchList = [SELECT Active__c,Email__c,Id,Name,User_Name__c,u_office_365__c FROM Active_Directory_Details__c WHERE User_Name__c =:usersIdActiveDirectory.values()];
        for (Active_Directory_Details__c a: snUsersMatchList)
        {
            numberUsersMatchedSnUsers+=1;
            snUsersMatchSfUser.add(a.User_Name__c.toLowerCase());
        }
        for (User u: usersActiveList)
        {
			String problemText = null; 
            if( usersIdActiveDirectory.containsKey(u.id) && !snUsersMatchSfUser.contains(u.Name_for_Service_Now__c.toLowerCase()))
            {
                numberUsersNotMatchServiceNow +=1;
                problemText = 'No Match Found in Service-Now!';
                userProblem.add(addUser(u, problemText)); 
            }
            
        }
  		
        numberUsersMutiLicenseing = numberUsersActive-(numberUsersMatchedSnUsers + numberUsersMissingActiveDirectory + numberUsersNotMatchServiceNow);
        
        return userProblem;
    }
    
    public void EmailReport()
    {
        List<Messaging.Emailfileattachment> fileAttachments  = new List<Messaging.Emailfileattachment>();
        
        List<UserLicensingProblem> userProblem = GenerateReport();
        string errorMessage = '';
        String htmlStyleError = '';
        String htmlError = '';
        String htmlRows = '';
        
        for (UserLicensingProblem ulp: userProblem)
        {
            htmlRows += '<tr><td>'+ ulp.Problem +'</td><td>'+ ulp.Id +'</td><td>'+ ulp.Name +'</td><td>'+ ulp.Email +'</td><td>'+ ulp.Username +'</td><td>'+ ulp.LicenseType +'</td><td>'+ ulp.DomainUsername +'</td><td><a href="http://'+ URL.getSalesforceBaseUrl().getHost() +'/'+ulp.Id+'" target="_top">view</a></td></tr>';
        }
        
        try
        {
        Messaging.Emailfileattachment efa = new Messaging.Emailfileattachment();    
        PageReference pr = Page.ServiceNowLicensing;//Limit in salesforce is 1000 records
        Blob content = pr.getContent();
        
        
		efa.setFileName(fileName);
			efa.setBody(content);
        fileAttachments.add(efa);
        }catch(System.Exception e)
        {
            errorMessage = 'Message:' + e.getMessage() + '\r\nLineNumber:'+ e.getLineNumber() + '\r\nStackTrace:' + e.getStackTraceString();
        	htmlStyleError = '#table-Error{border: 1px solid #FF0700;background-color: #FBACAC;width: 100%;-moz-border-radius: 3px;-webkit-border-radius: 3px;border-radius: 3px;font-family: Arial, "Bitstream Vera Sans", Helvetica, Verdana, sans-serif;color: #F90A05;}#table-Error td, #table-Error th{border-top-color: white;border-bottom: 1px solid #DFDFDF;color: #030303;}#table-Error th{text-shadow: rgba(255, 255, 255, 0.796875) 0px 1px 0px;font-family: Arial, "Times New Roman", "Bitstream Charter", Times, serif;font-weight: bold;padding: 7px 7px 8px;text-align: left;line-height: 1.3em;font-size: xx-large, 14px;}#table-Error td{font-size: 12px;padding: 4px 7px 2px;vertical-align: top;}';
            htmlError = '<table id="table-Error"><tr><th>Application Exception Error Thrown</th></tr><tr><td>' + errorMessage.Replace('\n\r', '</br>').Replace('\r\n', '</br>').Replace('\n', '</br>').Replace('\r', '</br>') + '</td></tr></table><br/>';
   
        }
        
        
        String htmlApplication = '<table id="table-3"><tr><th>Active</th><th>Missing AD</th><th>SN Matched</th><th>SN Mutiple Licensing</th><th>SN Not Matched</th><th>SN Missing License Type</th></tr>';
        htmlApplication +='<tr><td>'+numberUsersActive+'</td><td>'+numberUsersMissingActiveDirectory+'</td><td>'+numberUsersMatchedSnUsers+'</td><td>'+numberUsersMutiLicenseing+'</td><td>'+ numberUsersNotMatchServiceNow +'</td><td>'+ numberUsersMissingLicenseType +'</td></tr>';
        htmlApplication +='</table><br/>'; //applicationName, triggerObject, WebUtility.HtmlEncode(triggerQuery), triggerCount);
        
        String htmlStyle = '<style>' + htmlStyleError + '#table-3 {	border: 1px solid #DFDFDF;	background-color: #F9F9F9;	width: 100%;	-moz-border-radius: 3px;	-webkit-border-radius: 3px;	border-radius: 3px;	font-family: Arial,"Bitstream Vera Sans",Helvetica,Verdana,sans-serif;	color: #333;}#table-3 td, #table-3 th {	border-top-color: white;	border-bottom: 1px solid #DFDFDF;	color: #555;}#table-3 th {	text-shadow: rgba(255, 255, 255, 0.796875) 0px 1px 0px;	font-family: Arial, Georgia,"Times New Roman","Bitstream Charter",Times,serif;font-weight: bold;padding: 7px 7px 8px;text-align: left;line-height: 1.3em;font-size: xx-large, 14px;}#table-3 td {	font-size: 12px;padding: 4px 7px 2px;vertical-align: top;}</style>';
        //String htmlFooter = '<tr><th></th><th>Total:</th><th>{0}</th><th>{1}</th><th>{2}</th><th>{3}</th><th></th></tr>", totalUploadNotProcessed, totalUploadProcessed, totalUploadSuccess, totalUploadFailure);
        String htmlHeader = '<tr><th>Problem</th><th>Id</th><th>Name</th><th>Email</th><th>Username</th><th>License Type</th><th>AD Username</th><th></th></tr>';
        String htmlTable = '<table id="table-3">'+htmlHeader + htmlRows + '</table><br/>';
        
        String htmlOrgInformation = '<div id="table-3"><b>Org Id:</b> ' + userInfo.getOrganizationId() + '<br/><b>Org Name:</b> ' + userInfo.getOrganizationName()+ '<br/><b>Org Domain:</b> ' + URL.getSalesforceBaseUrl().getHost() + '</div><br/>';
        
        
        snu.SendEmail( usnl.snEmails, usnl.snOrgIndentifier + ': SFDC/SN Licensing', htmlStyle + htmlOrgInformation + htmlError + htmlApplication + htmlTable,'High',null,usnl.snOrgWideEmailId,true,fileAttachments );
        
    }
    
    private UserLicensingProblem addUser(User u, String problem)
    {
        
        UserLicensingProblem ulp =  new UserLicensingProblem();
        ulp.Problem = problem;
        ulp.Id = u.Id;
        ulp.Name = u.name;
        ulp.Email=u.Email;
        ulp.Username=u.Username;
        ulp.LicenseType=u.License_Type__c;
        ulp.DomainUsername=u.Name_for_Service_Now__c;
        ulp.ActiveDirectoryDomain=u.Active_Directory_OU__c;
        ulp.ActiveDirectoryDomain=u.Active_Directory_OU__c;
        ulp.ActiveDirectoryUsername=u.Active_Directory_Username__c;  
       
        return ulp;
    }
    
    public class UserLicensingProblem 
    {
		//public String __status{ get; set; }   
		public String Problem { get; set; }
		public String Id { get; set; }
		public String Name { get; set; }
		public String Email { get; set; }    
		public String Username { get; set; }
        public String LicenseType { get; set; }
        public String DomainUsername { get; set; }
        public String ActiveDirectoryDomain { get; set; }
        public String ActiveDirectoryUsername { get; set; }
	}
}