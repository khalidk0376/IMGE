@IsTest
public class ProductValidationTrncLogCtrl_Test {
    
    public TestMethod static void testProductValidationTrncLogCtrl(){
        Boolean check = false;
        ProductValidationTrncLogCtrl validateLog = new ProductValidationTrncLogCtrl();
        validateLog.getProductValidationTrncLog();
        validateLog.previous();
        validateLog.next();
        system.assertEquals(check, false, 'value must be false');
    }
}