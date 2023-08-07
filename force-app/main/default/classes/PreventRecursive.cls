/*
* Created By:  Aishwarya Kumar (Girikon)
* Created on : 06/11/2018
* Modified by :  
* Modified On: 
* Description: The purpose of this class is to prevent the recursion in trigger 
* Test Class:  PreventRecursive_Test(100%)
*/

Public class PreventRecursive
{
    public static Boolean runOnce = TRUE;
    public static Boolean runOnceCreate()
    {
        if(runOnce) 
        {
            runOnce = FALSE;
            return TRUE;
        }
        else
        {
            return runOnce;
        }
    }
}