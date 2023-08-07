/************************************************************************** 
** Last Modified by Shay Spoonmore (shay.spoonmore@informausa.com)2015-12-03 
***************************************************************************/
global class DatabaseCleansingSchedule implements Schedulable
{
    global void execute(SchedulableContext SC)    
    { 
	DatabaseCleansing.GetSettings(null);
    }
}