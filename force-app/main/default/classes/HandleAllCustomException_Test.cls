@isTest
public class HandleAllCustomException_Test {
	

    @isTest
    private static void testException()
    {
        Test.startTest();
        

        List<Account> acc = [Select id from Account LIMIT 1];


        try
        {
           HandleAllCustomException.logException(null,null,null);
        }
        catch (Exception ex) 
        {
            HandleAllCustomException.logException(ex,null, 'After Update');
        }
        System.assertEquals(acc.size(),0, 'Account not Found');//EX-101
        Test.stopTest();
    }
    
}