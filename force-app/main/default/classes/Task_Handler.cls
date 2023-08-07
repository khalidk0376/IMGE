/**
* Class Name: Task_Handler
* Created By : Faisal Khan
* Created Date : 13/03/2023
* Test Class: Task_Handler_test(90%)
* **************************************************************************************************************************
* @description: This class is used to do the functionality to update activitydatetime field on queue assigment
* **************************************************************************************************************************
**/

public with sharing class Task_Handler implements TriggerInterface_Task.Runnable {

    
    public void run(TriggerInterface_Task.Trig trig) {
        System.debug('Inside running'+ Date.today());  
		System.debug('trig...'+ trig);
	/*
	Developed By - Faisal Khan(BK-26324)
	Description - We need to get populate ActivityDate field based on Owner Egypt Queue. 
	*/   
        if(trig.isbefore && trig.isInsert)
        {            
	        Datetime datetoUpdate;
            Group queueObj=[SELECT Id,Name FROM Group WHERE Type = 'Queue' AND Name = 'Egypt SSC'];
            for(Task taskobj : trig.newList){   
				if(taskobj.whatId!=null){
					String stringValue=taskobj.whatId;
					if(stringValue.startsWith('006') && taskobj.ownerId==queueObj.Id){
						System.debug('today date'+ Date.today());  
						System.debug('today now'+System.today());  
					   // DateTime now = System.today();
						Date dateToday=Date.today();
						Date weekStart = dateToday.toStartofWeek();
						Integer Difference=weekStart.daysBetween(dateToday);
						//String dayOfWeektoday=test.isRunningTest()?'Monday':now.format('EEEE');
						String dayOfWeek=returnWeekday(Difference);
					   
						 if(dayOfWeek=='Friday'){
							datetoUpdate=dateToday.adddays(3);
						} 
						else if(dayOfWeek=='Saturday'){
							datetoUpdate=dateToday.adddays(2);
						}
						else{
							  // DateTime twodayfromnow =now.addDays(1);
							   //String dayOfWeek = twodayfromnow.format('u');
							   //String dayOfWeek = twodayfromnow.format('EEEE');
								Date dateTodayAdd=Date.today().adddays(1);
								Date weekStartAdd = dateTodayAdd.toStartofWeek();
								Integer Differenceday=weekStartAdd.daysBetween(dateTodayAdd);
								String dayOfWeekonAddtion=returnWeekday(Differenceday);

								if(dayOfWeekonAddtion=='Friday'){
									datetoUpdate=dateTodayAdd.adddays(2);
								} 
								else if(dayOfWeekonAddtion=='Saturday'){
									datetoUpdate=dateTodayAdd.adddays(2);
								}
								else{
									datetoUpdate=dateTodayAdd;
								}
						
						}
						
				   
						if(datetoUpdate!=null){
							taskobj.ActivityDate=Date.valueof(datetoUpdate);
						}
					}
				}			
            }                               
        } 
        system.debug('trig.isbefore...'+trig.isbefore);
        system.debug('trig.isUpdate...'+trig.isUpdate);
        if(trig.isbefore && trig.isUpdate)
        {
		    Group queueObj=[SELECT Id,Name FROM Group WHERE Type = 'Queue' AND Name = 'Egypt SSC'];
            Datetime datetoUpdate;

            for(Task taskobj : trig.newList){ 
					System.debug('date==>'+taskobj.ownerId);
					if(taskobj.whatId!=null){
					String stringValue=taskobj.whatId;
					if(stringValue.startsWith('006') && taskobj.ownerId!=trig.oldmap.get(taskobj.id).ownerId && taskobj.ownerId==queueObj.Id){
						System.debug('today date'+ Date.today());  
						System.debug('today System.today()'+System.today());
						taskobj.recordtypeId=Schema.SObjectType.Task.getRecordTypeInfosByName().get('Egypt SSC').getRecordTypeId();
						
						Date dateToday=Date.today();
						Date weekStart = dateToday.toStartofWeek();
						Integer Difference=weekStart.daysBetween(dateToday);
					   // String dayOfWeektoday=test.isRunningTest()?'Monday':now.format('EEEE');
						String dayOfWeek=returnWeekday(Difference);

						 if(dayOfWeek=='Friday'){
							datetoUpdate=dateToday.adddays(3);
						} 
						else if(dayOfWeek=='Saturday'){
							datetoUpdate=dateToday.adddays(2);
						}
						
						else{
							  //DateTime twodayfromnow =now.addDays(1);
							  Date dateTodayAdd=Date.today().adddays(1);
							  Date weekStartAdd = dateTodayAdd.toStartofWeek();
							  Integer DifferenceDay=weekStartAdd.daysBetween(dateTodayAdd);
							  // String dayOfWeek = twodayfromnow.format('EEEE');
							  String dayOfWeekonAddtion=returnWeekday(DifferenceDay);

								if(dayOfWeekonAddtion=='Friday'){
									datetoUpdate=dateTodayAdd.adddays(2);
								} 
								else if(dayOfWeekonAddtion=='Saturday'){
									datetoUpdate=dateTodayAdd.adddays(2);
								}
							else{ 
								datetoUpdate=dateTodayAdd;
							}
						}
						if(datetoUpdate!=null){
							taskobj.ActivityDate=Date.valueof(datetoUpdate);
						}
					}
					else if(stringValue.startsWith('006') && taskobj.ownerId!=trig.oldmap.get(taskobj.id).ownerId && trig.oldmap.get(taskobj.id).ownerId==queueObj.Id && taskobj.ownerId!=queueObj.Id){
						taskobj.recordtypeId=Schema.SObjectType.Task.getRecordTypeInfosByName().get('Non Egypt').getRecordTypeId();
						taskobj.ActivityDate=Date.valueof(datetoUpdate);
					}
				}
				 
		    }           
        }  
    }
	
	    public static string returnWeekday(Integer difference ){
            String dayOfWeek;
        switch on difference {
                 when 0 {
                      dayOfWeek='Sunday';
                }
               when 1 {
                      dayOfWeek='Monday';
                }
               when 2 {
                      dayOfWeek='Tuesday';
               }
               when 3 {
                      dayOfWeek='Wednesday';
               }
                when 4 {
                      dayOfWeek='Thursday';
               }
                when 5 {
                      dayOfWeek='Friday';
               }
                when 6 {
                      dayOfWeek='Saturday';
               }
                when 7 {
                      dayOfWeek='Sunday';
               }
            }
                    
         return dayOfWeek;
      }
}