/**
 * Created/Modified By: Girikon(Prashant)
 * Created On:          12/03/2018
 * Description/Purpose: This class is a test class for CustomLoggedInDetailCtrl
 * Test Class:          CustomLoggedInDetailCtrl(86%)
 * Last Modified By :   Rajesh Kumar - BK-3856 - -1-06-2020
**/

@IsTest
public class CustomLoggedInDetailCtrl_Test {
    @IsTest
    private static void test1()
    {
        CustomLoggedInDetailCtrl obj = new CustomLoggedInDetailCtrl();
        obj = CustomLoggedInDetailCtrl.getGenericObjectRecord('SetupAuditTrail','Display,CreatedById,CreatedBy.Name,CreatedDate',10,false,false,0.0,'Id','asc','','');
        obj = CustomLoggedInDetailCtrl.getGenericObjectRecord('SetupAuditTrail','Display,CreatedById,CreatedBy.Name,CreatedDate',10,false,false,0.0,'Id','asc','12/04/2018','');
        obj = CustomLoggedInDetailCtrl.getGenericObjectRecord('SetupAuditTrail','Display,CreatedById,CreatedBy.Name,CreatedDate',10,false,false,0.0,'Id','asc','12/04/2018','12/05/2018');
        obj = CustomLoggedInDetailCtrl.getGenericObjectRecord('SetupAuditTrail','Display,CreatedById,CreatedBy.Name,CreatedDate',10,false,false,0.0,'Id','asc','','12/05/2018');
        CustomLoggedInDetailCtrl.hasprevious(0);
        CustomLoggedInDetailCtrl.hasnxt (1,2,3);
        system.assertNotEquals(null, obj,'CustomLoggedInDetailCtrl must not be null ');
        
    }
}