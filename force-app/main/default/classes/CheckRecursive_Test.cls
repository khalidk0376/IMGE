/**
 * Project:         GAP
 * Date:            16/2/2018
 * Code Coverage:   100%
 * Created By:      Rajesh Kumar
 * * Modified By : Rajesh kumar Yadav Bk-3751
 * *************************************************************************
 * Description: This test class is used to cover "checkRecursive" class.
 * *************************************************************************
 */
@isTest
public class CheckRecursive_Test
{
    @isTest static void checkRecursive() 
    {
        
        CheckRecursive.run = True;
        CheckRecursive.runForOLI = True;
        CheckRecursive.runOnce();
        CheckRecursive.runOnceForOLI();
        CheckRecursive.runOnceForInvoice();
        CheckRecursive.runOnce();
        CheckRecursive.runOnceForOLI();
        CheckRecursive.runOnceForInvoice();
        CheckRecursive.runtaxCalculation();
        CheckRecursive.runAutoPopulate();
        CheckRecursive.runAutoPopulate();
        system.assertEquals(CheckRecursive.run, false, 'Both values should be the same.');
    }
}