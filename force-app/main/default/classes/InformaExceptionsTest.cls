/**
 * Test class for the custom exceptions
 */

@IsTest
private class InformaExceptionsTest {
    
    static testMethod void testHttpException() {
        InformaExceptions.InformaHttpException eek1 = new InformaExceptions.InformaHttpException(200, 'TEST');
       // System.assert(!eek1.hasErrorMessage(),'condition should match');
        System.assertEquals('' + 200 + ' TEST ', eek1.getMessage(),'condition should match');

        InformaExceptions.InformaHttpException eek2 = new InformaExceptions.InformaHttpException(200, 'TEST', 'Bad Data');
     //   System.assert(eek2.hasErrorMessage(),'condition should match');
        System.assertEquals('' + 200 + ' TEST Bad Data', eek2.getMessage(),'condition should match');
    }

    static testMethod void testInvalidInputException() {
        InformaExceptions.InformaInvalidInputException eek1 = new InformaExceptions.InformaInvalidInputException(200, 'TEST');
      //  System.assert(!eek1.hasErrorMessage(),'condition should match');
        System.assertEquals('' + 200 + ' TEST ', eek1.getMessage(),'condition should match');

        InformaExceptions.InformaInvalidInputException eek2 = new InformaExceptions.InformaInvalidInputException(200, 'TEST', 'Bad Data');
     //  System.assert(eek2.hasErrorMessage(),'condition should match');
        System.assertEquals('' + 200 + ' TEST Bad Data', eek2.getMessage(),'condition should match');
    }

    static testMethod void testInvalidCustomSettingException() {
        InformaExceptions.InformaInvalidCustomSettingsException eek1 = new InformaExceptions.InformaInvalidCustomSettingsException(200, 'TEST');
     //   System.assert(!eek1.hasErrorMessage(),'condition should match');
        System.assertEquals('' + 200 + ' TEST ', eek1.getMessage(),'condition should match');

        InformaExceptions.InformaInvalidCustomSettingsException eek2 = new InformaExceptions.InformaInvalidCustomSettingsException(200, 'TEST', 'Bad Data');
     //   System.assert(eek2.hasErrorMessage(),'condition should match');
        System.assertEquals('' + 200 + ' TEST Bad Data', eek2.getMessage(),'condition should match');
    }

    static testMethod void testValueDoesNotExistException() {
        InformaExceptions.InformaValueDoesNotExistException eek1 = new InformaExceptions.InformaValueDoesNotExistException(200, 'TEST');
        System.assert(!eek1.hasErrorMessage(),'condition should match');
        System.assertEquals('' + 200 + ' TEST ', eek1.getMessage(),'condition should match');

        InformaExceptions.InformaValueDoesNotExistException eek2 = new InformaExceptions.InformaValueDoesNotExistException(200, 'TEST', 'Bad Data');
      //  System.assert(eek2.hasErrorMessage(),'condition should match');
        System.assertEquals('' + 200 + ' TEST Bad Data', eek2.getMessage(),'condition should match');
    }
}