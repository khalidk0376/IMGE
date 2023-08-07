/**
 * Created/Modified By  :  
 * Created On:          :  
 * @description         : 
 * Modification log --
 * * Modified By : Rajesh kumar Yadav Bk-3751
**/
@isTest
public class Test_checkbeforeDelete {
   static testmethod void validate(){

        //chkBeforeDelete c = new chkBeforeDelete();
        CPQ_Product_Clone__c objClone = new CPQ_Product_Clone__c();
        objClone.Event_Series__c ='World of Concrete';
        objClone.Cloned__c = false;
        objClone.Source_Event_Edition__c = 'World of Concrete 2017';
        objClone.Target_Event_Edition__c = 'World of Concrete 2018';
        insert objClone;     
		system.assertEquals(objClone.Event_Series__c, 'World of Concrete', 'Both values should be the same.');
       //delete objClone;
        CPQ_Clone_Progress__c cclone = new CPQ_Clone_Progress__c();
        cclone.CPQ_Product_Clone__c = objClone.Id;
        cclone.CurrencyIsoCode = 'USD';
        insert cclone;
        //delete cclone;
        delete objClone;
    }
}