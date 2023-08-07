@isTest(seeAlldata = false)
public class MultiselectController_Test {
    static testMethod void unitTest() {
        
        MultiselectController oMultiselectController = new MultiselectController();
        string valueStr ='test&test1&test2';
        List<SelectOption> selOpts = new List<SelectOption>();
        selOpts.add(new SelectOption('US','US'));
        
        List<SelectOption> selOpts1 = oMultiselectController.leftOptions;
        List<SelectOption> selOpts2 = oMultiselectController.rightOptions;
        
        oMultiselectController.setOptions(selOpts,valueStr);
        
        string str1 = oMultiselectController.leftOptionsHidden;
        string str2 = oMultiselectController.rightOptionsHidden;
        
        System.assertEquals(str2, null , 'MultiselectController String cannot be null');
    }
    
    static testMethod void testMultiselectController() {
        MultiselectController c = new MultiselectController();
        c.leftOptions = new List<SelectOption>();
        c.rightOptions = new List<SelectOption>();
        c.leftOptionsHidden = 'A&a&b&b&C&c';
        c.rightOptionsHidden = '';
        System.assertEquals(c.leftOptions.size(), 3 , 'Value must be 3');
        System.assertEquals(c.rightOptions.size(), 0, 'Value must be 0');
    }
}