/**
 * File:            SortProductTypeCtrl_Test
 * Project:         GAP
 * Date:            Jan 31, 2017
 * Apex Class :     SortProductTypeCtrl
 * Code Coverage:   89%
 * Created By:      Sudip Halder
 * *************************************************************************
 * Description: Test class for SortProductTypeCtrl.
 * *************************************************************************
 * History:
 */

@IsTest
public class SortProductTypeCtrl_Test {
    
    public static User createTestUser( Id roleId, Id profID, String fName, String lName ) {
        String orgId = UserInfo.getOrganizationId( );
        String dateString = String.valueof( Datetime.now( ) ).replace(' ','').replace(':','').replace('-','');
        
        Integer randomInt = Integer.valueOf( math.rint( math.random( ) * 1000000 ) );
        String uniqueName = orgId + dateString + randomInt;
        User tuser = new User( firstname        = fName,
                              lastName          = lName,
                              email             = uniqueName + '@test' + orgId + '.org',
                              Username          = uniqueName + '@test' + orgId + '.org',
                              EmailEncodingKey  = 'ISO-8859-1',
                              Alias             = uniqueName.substring(18, 23),
                              TimeZoneSidKey    = 'America/Los_Angeles',
                              LocaleSidKey      = 'en_US',
                              LanguageLocaleKey = 'en_US',
                              ProfileId         = profId,
                              UserRoleId        = roleId );
        return tuser;
    }
    
    public TestMethod static void testSortProductTypeCtrl( ) {

        Profile pf       = [ SELECT Id FROM Profile WHERE Name = 'System Administrator' ];
        UserRole usrRole = new UserRole( Name = 'CEO' );
        insert usrRole;        
        User usr = createTestUser( usrRole.Id, pf.Id, 'Test SortProduct', 'Test TypeCtrl' );
        System.runAs( usr ) {            
            Event_Series__c evntSeries = new Event_Series__c( name = 'test series' );
            insert evntSeries;
            Event_Series__c series = [ Select Id, Name From Event_Series__c Limit 1 ];
            System.assertEquals( evntSeries.name, series.name, 'event series cannot be null' );
            
            Event_Edition__c evntEdition = new Event_Edition__c( name = 'Test Edition', Product_Type_Order__c = 'test type', Booth_Product_Type__c = 'Space Only', Event_Currency__c = 'USD');
            evntEdition.Part_of_Series__c = evntSeries.id;
            insert evntEdition;
            Event_Edition__c edition = [ Select Id, Name FROM Event_Edition__c Limit 1 ];
            System.assertEquals( evntEdition.Name, edition.Name, 'event edition cannot be null');

            Test.startTest( );
            ApexPages.StandardController sc = new ApexPages.StandardController( evntEdition );
            SortProductTypeCtrl sortProduct = new SortProductTypeCtrl( sc );
            sortProduct.existingProductTypeOrder( );
            sortProduct.saveProductTypeOrder( );
            sortProduct.returnToEE( );
            Test.stopTest( );
        }
    }
}