//Ticket No.-BK-14522 Updating API Version
public class ServiceNowLicensingController {
	
    private User_ServiceNowLicenseReport uslr= new User_ServiceNowLicenseReport();
    public List<User_ServiceNowLicenseReport.UserLicensingProblem>  ulpList {get; set;}
    Public String fileName {get; set;}
    Public String orgUrl {get; set;}
    public Integer numberUsersActive{get; set;}
    public Integer numberUsersMatchedSnUsers{get; set;}
    public Integer numberUsersMissingActiveDirectory{get; set;}
    public Integer numberUsersMissingLicenseType{get; set;}
    public Integer numberUsersNotMatchServiceNow{get; set;}
    public Integer numberUsersMutiLicenseing{get; set;}
    public ServiceNowLicensingController() 
    {	ulpList=uslr.GenerateReport();
        System.debug('Host: ' + URL.getSalesforceBaseUrl().getHost());  
        numberUsersActive = uslr.numberUsersActive;
        numberUsersMatchedSnUsers = uslr.numberUsersMatchedSnUsers;
        numberUsersMissingActiveDirectory = uslr.numberUsersMissingActiveDirectory;
        numberUsersMissingLicenseType = uslr.numberUsersMissingLicenseType;
        numberUsersNotMatchServiceNow = uslr.numberUsersNotMatchServiceNow;
		numberUsersMutiLicenseing =      uslr.numberUsersMutiLicenseing;	
        orgUrl = system.Url.getSalesforceBaseUrl().toExternalForm();
        fileName = uslr.Filename;
        
        
    }
    
    
}