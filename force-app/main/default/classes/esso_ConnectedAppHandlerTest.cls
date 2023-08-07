/**
 * Application  :   Informa Markets Identity (IM IdP)
 * Created By   :   Shay.Spoonmore@informa.com
 * Created On   :   20200831
 * @description :   [IM IdP Connected App Handler for custom attributes]
 * Test Class   :
 * Modification Log-----
 * Modified by  : 	Shay.Spoonmore@informa.com (20200901)
 **/
@isTest
public with sharing class esso_ConnectedAppHandlerTest {


@testSetup static void setup()
{
	esso_ConfigurationTest.setupData();
	esso_UserTest.setupData();
    SiteBrandingIdentifierTest.defaultSiteBranding();
    

}



static testMethod void UnitTestThirdPartyLink()
{
    esso_ConnectedAppHandler cah= new esso_ConnectedAppHandler();

    esso_ConnectedAppHandler.ThirdPartyLink informaLink = new esso_ConnectedAppHandler.ThirdPartyLink();
    informaLink.UserId= esso_UserTest.imIdP.Id;
    informaLink.Provider= esso_RegHandlerInforma.PROVIDER;
    informaLink.RemoteIdentifier= esso_UserTest.imIdP.Username;
    cah.tpls.add(informaLink);

    esso_ConnectedAppHandler.ThirdPartyLink linkedinLink = new esso_ConnectedAppHandler.ThirdPartyLink(esso_UserTest.imIdP.Username,esso_RegHandlerInforma.PROVIDER,esso_UserTest.imIdP.Id);
    // linkedinLink .UserId= esso_UserTest.imIdP.Id;
    // linkedinLink .Provider= esso_RegHandlerInforma.PROVIDER;
    // linkedinLink .RemoteIdentifier= esso_UserTest.imIdP.Username;
    cah.tpls.add(linkedinLink);

	Map<String,String> formulaDefinedAttributes = new Map<String,String>();
    formulaDefinedAttributes = cah.customAttributes(esso_UserTest.imIdP.Id,null,formulaDefinedAttributes,null);
    
    System.assertEquals(true, (formulaDefinedAttributes.get('ThirdPartyProviders') !='[]'),'The value should be return true');

}

static testMethod void UnitTestNoProvider()
{
    esso_ConnectedAppHandler cah= new esso_ConnectedAppHandler();

    User u = new User(id=esso_UserTest.imIdpBusiness.Id,esso_LastLoginProviderType__c=null);
    update u;

	Map<String,String> formulaDefinedAttributes = new Map<String,String>();
    formulaDefinedAttributes = cah.customAttributes(esso_UserTest.imIdpBusiness.Id,null,formulaDefinedAttributes,null);
    
    System.assertEquals(true, (formulaDefinedAttributes.get('ThirdPartyProviders') =='[]'),'The value should be return true');

}


}