global class ServiceNowUserSchedule implements Schedulable{
    global void execute(SchedulableContext SC)  
    {  
    	ServiceNowUser snu = new ServiceNowUser();
		snu.GetObjectData();
         
    }
}