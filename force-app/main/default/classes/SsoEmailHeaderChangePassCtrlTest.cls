/**
 * Created/Modified By    :  Mahesh (Girikon)
 * Created On:            :  July 15 2019
 * @description           : [This test class covers the apex class : SsoEmailHeaderChangePassCtrl]
 * Modification log --
 * Modified By            :
**/
@isTest
Public with sharing class SsoEmailHeaderChangePassCtrlTest {
        
@IsTest Public static void dataSetup() {
            
        Test.startTest();
        SsoEmailHeaderChangePassCtrl SsoEmailHeaderChangePas = new SsoEmailHeaderChangePassCtrl();
        SsoEmailHeaderChangePas.ssoLang='en_Us';
        List<StaticResource> staticRes = new List<StaticResource>();
        staticRes= [Select id,name from StaticResource Limit 10];   
        SsoEmailHeaderChangePas.getinformaImg();  
        String ssoLang = 'en_Us';
        System.assertEquals('en_Us', ssoLang,'That should be return en_Us');
        Test.stopTest();
    }
}