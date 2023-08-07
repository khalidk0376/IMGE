/**
 * Application  :   Informa Markets Identity (IM IdP)
 * Created By   :   Shay.Spoonmore@informa.com
 * Created On   :   20200825
 * @description :   [IM IdP LinkedIn RegHandler]
 * Test Class   :
 * Modification Log-----
 * Modified by  : 	Shay.Spoonmore@informa.com (20200901)
 **/
@isTest
public with sharing class esso_RegHandlerInformaTest {

@testSetup static void setup()
{
	esso_ConfigurationTest.setupData();
	esso_UserTest.setupData();
}


static testMethod void testCreateUser()
{
	List<Network> communityNetworks = [SELECT Id, Name FROM Network LIMIT 1];
	esso_RegHandlerInforma handler = new esso_RegHandlerInforma();

	map<string,string> a = new map<string,string>();
	a.put('officeLocation', 'insert');
	a.put('jobTitle', 'insert');
	a.put('sfdc_networkid', communityNetworks[0].Id);
	a.put('language', 'en_US');

	String username = 'handler.' + esso_UserTest.imIdP.Username;
	system.debug('#### !DEBUG! username: ' + username);

	Auth.UserData data = new Auth.UserData(username,esso_UserTest.imIdP.FirstName,esso_UserTest.imIdP.LastName,'', username
	                                       ,null, username, 'en_US', 'informa-test',null, a);

	User u = handler.createUser(data.attributeMap.get('sfdc_networkid'), data);// insert user
	System.assertEquals(true,(u.Id != null ), 'Created user ' + username + '('+u.Id+')');




}

static testMethod void testUpdateUser()
{
	List<Network> communityNetworks = [SELECT Id, Name FROM Network LIMIT 1];
	esso_RegHandlerInforma handler = new esso_RegHandlerInforma();

	map<string,string> a = new map<string,string>();
	a.put('officeLocation', 'update');
	a.put('jobTitle', 'update');
	a.put('sfdc_networkid', communityNetworks[0].Id);
	a.put('language', 'en_US');

	String username = esso_UserTest.imIdpBusiness.Username;
	Auth.UserData data = new Auth.UserData(username,esso_UserTest.imIdpBusiness.FirstName + 'Update',esso_UserTest.imIdpBusiness.LastName + 'Update','', username
	                                       ,null, username, 'en_US', esso_RegHandlerInforma.PROVIDER,null, a);
	Test.startTest();
	User u = handler.createUser(data.attributeMap.get('sfdc_networkid'), data);
	System.assertEquals(true,(u.Id != null ), 'Updated user ' + username + '('+u+')');
	Test.stopTest();



}


}