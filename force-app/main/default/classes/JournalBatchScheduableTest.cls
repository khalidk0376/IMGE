/**
 * Test class for the JournalBatchScheduable
 [Modified By : Aishwarya 12 Aug 2020 BK-3751]
 */

@IsTest
private class JournalBatchScheduableTest {

    @testSetup
    public static void setupData() {
        TestUtilities.createCSIntegrationSettings();
        TestUtilities.createCSBatchSettings();
    }

    @isTest
    static void testJournalBatchScheduable() {
        Test.startTest();
        String jobId = System.schedule('testContractBatchableScheduable', '0 0 0 3 9 ? 2022', new JournalBatchScheduable());
        System.assertNotEquals(jobId, null, 'jobId should not be blank'); 
        Test.stopTest();
    }
}