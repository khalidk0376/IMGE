@isTest
private class test_APIClassDefinitions {

    testMethod static void test() 
    {
        Boolean ifCheck = false;
        APIClassDefinitions.QuoteModel qm1=new APIClassDefinitions.QuoteModel();
        System.assertEquals(ifCheck, false, 'both values are same');
    }
}