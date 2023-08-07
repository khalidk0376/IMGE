/**************************************************************************
** Last Modified by Shay Spoonmore (shay.spoonmore@informausa.com)2016-10-31
***************************************************************************/
global class User_ServiceNowLicenseUpdateSchedule implements Schedulable
{
	global boolean sendStatus = false;
    global void execute(SchedulableContext SC)    
    {
        System.debug('To remove SCA violation');
         /**
    	Set<Id> batchProcessIds = new Set<Id>();
		User_ServiceNowLicenseUpdate x = new User_ServiceNowLicenseUpdate();
		x.isTesting=false;
		batchProcessIds.add(Database.executeBatch(x)); 
		
		
		Boolean sendMessage = false;
    	String emailMessage = '';
    	String emailCreated = '';
    	for(AsyncApexJob apexJob: [Select Id, Status, NumberOfErrors, JobItemsProcessed,TotalJobItems, ExtendedStatus, CreatedBy.Email from AsyncApexJob where Id =:batchProcessIds])
    	{
    		if (apexJob.NumberOfErrors > 0  || x.isTesting || sendStatus)
			{
				sendMessage = true; 
				emailCreated = apexJob.CreatedBy.Email;
				emailMessage += apexJob.Id + ') The batch Apex job processed ' + apexJob.TotalJobItems + ' batches with '+ apexJob.NumberOfErrors + ' failures.\n\n' + apexJob.ExtendedStatus + '\n\n';
			}
    	}
    	
    	if (sendMessage)
    	{
    		User_ServiceNowLicenseUpdate.SendErrorEmail( emailCreated + ';Shay.Spoonmore@informaUSA.com;Do_Not_Reply.SFDC@informausa.com','SFDC - ServiceNow Licensing', emailMessage );
    	}
		**/
		
    }
	

}