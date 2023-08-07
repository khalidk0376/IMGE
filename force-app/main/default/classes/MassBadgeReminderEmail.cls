/**
 * Created: Girikon(Aishwarya) [CCEN-153]
 * Created On:          09/25/2018
 * Description/Purpose: This class is called through the SKUID page: Badges_ExhibitorProfile_ForOps
 *                      This Class is for sending mass email reminder for badges.
 * Methods:             MassBadgeReminderEmail
 * Test Class:          MassBadgeReminderEmail_Test(100%)
 *
 * Modification Log----- 
 * Modified by   : Girikon(Name) [Jira#]
 * Modified On   : MM/DD/YYYY
**/

global class MassBadgeReminderEmail
{
    webservice static boolean massBadgeReminderNotification(String eventEditionId, String accList)
    { 
        MassBadgeReminderEmailBatch batch = new MassBadgeReminderEmailBatch(eventEditionId, accList);
        Database.executeBatch(batch, 10);
        return true;
    }
}