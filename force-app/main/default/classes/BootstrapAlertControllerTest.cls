/**
 * Created/Modified By   :  Mahesh (Girikon)
 * Created On:           :  June 12 2019
 * @description          :  [This test class covers the apex class : BootstrapAlertController]
 * Modification log --
 * Modified By           :
**/
@isTest
private class BootstrapAlertControllerTest {
   
  @isTest static void test_method_one() {
    BootstrapAlertController alertController = new BootstrapAlertController();
 
    System.assertEquals(true, alertController.warnMsgs.isEmpty(),'That should be return true');
    System.assertEquals(true, alertController.successMsgs.isEmpty(),'That should be return true');
    System.assertEquals(true, alertController.infoMsgs.isEmpty(),'That should be return true');
    System.assertEquals(true, alertController.errorMsgs.isEmpty(),'That should be return true');
    System.assertEquals(false, alertController.hasMessages,'That should be return false');
 
    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'This is an error'));
    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'This is some info'));
    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'This is a confirm'));
    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'This is a fatal error'));
    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'This is a warning'));
 
    System.assertEquals(true, alertController.hasMessages,'That should be return true');
 
    System.assertEquals(false, alertController.warnMsgs.isEmpty(),'That should be return false');
 
    System.assertEquals(false, alertController.successMsgs.isEmpty(),'That should be return false');
 
    System.assertEquals(false, alertController.infoMsgs.isEmpty(),'That should be return false');
 
    System.assertEquals(false, alertController.errorMsgs.isEmpty(),'That should be return false');
  } 
 
  @isTest static void test_method_two() {
    BootstrapAlertController alertController = new BootstrapAlertController();
 
    try{
      insert new Contact(); //
    }catch(Exception ex){
      ApexPages.addMessages(ex);
    }
 
    // calls getter that converts messages to message lists
    System.assertEquals(true, alertController.hasMessages,'That should be return true');
 
    System.assertEquals(false, alertController.errorMsgs.isEmpty(),'That should be return false');
  }
}