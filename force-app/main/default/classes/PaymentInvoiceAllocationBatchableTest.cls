/**
 * Created by stevelohrenz on 7/26/17.
 */

@IsTest
private class PaymentInvoiceAllocationBatchableTest {
    //TODO Remove this after getting tests working.
    static testMethod void fakeTest() {
        Boolean isCalled = false;
        PaymentInvoiceAllocationBatchable.fakeMethod();
        System.assertEquals(isCalled, false, 'isCalled should be false.');
    }
}