/**
 * Created/Modified By  :  Mahesh (Girikon)
 * Created On:          :  June 11 2019
 * @description         : [This test class covers the apex class : SiteBrandingIdentifier]
 * Modification log --
 * Modified By          :   Shay.Spoonmore@informa.com (20200901)   
 **/
@isTest
public class SiteBrandingIdentifierTest {

@testSetup static void setup()
{
    esso_ConfigurationTest.setupData();
}
@isTest static void test_method_one() {

    SiteBrandingIdentifier siteBranding;

    try{
        siteBranding = new SiteBrandingIdentifier();
    }catch(Exception ex)
    {
        System.assertEquals('No branding found', ex.getMessage(), 'test failed');
    }
}


@isTest static void testDefaultBranding() {

    esso_Site_Branding__c sb = SiteBrandingIdentifierTest.defaultSiteBranding();

    Test.setCurrentPage(Page.registration);
    ApexPages.currentPage().getParameters().put('referralid', esso_Configuration.setting.Branding_Default__c);

    SiteBrandingIdentifier siteBranding = new SiteBrandingIdentifier();
    siteBranding.defaultClientServicesEmail = 'service@informa.com';
   // System.assertEquals(esso_Configuration.setting.Branding_Default__c, ApexPages.currentPage().getCookies().get('brand').getValue(),'This should be return true');
   // System.assertEquals(sb.Default_Landing_Page__c, ApexPages.currentPage().getCookies().get('rurl').getValue(),'Return https://www.informa.com');
}

@isTest static void testNoQueryParams() {

    //create custom branding
    SiteBrandingIdentifierTest.createSiteBranding('Some Product', 'testId', 'Test Product', 'informa markets', true);
    esso_Site_Branding__c sb = SiteBrandingIdentifierTest.defaultSiteBranding();

    Test.setCurrentPage(Page.registration);
    //Page set but no referral Id so default record of informa should be found
    SiteBrandingIdentifier siteBranding = new SiteBrandingIdentifier();
   // System.assertEquals(sb.Default_Landing_Page__c, ApexPages.currentPage().getCookies().get('rurl').getValue(),'Return url should be ' + sb.Default_Landing_Page__c);
   // System.assertEquals(esso_Configuration.setting.Branding_Default__c, ApexPages.currentPage().getCookies().get('brand').getValue(),'Default Brand ' + esso_Configuration.setting.Branding_Default__c);
}

@isTest static void test_method_three_without_referral_exisiting_cookies() {

    // Setup default branding where non is found
    esso_Site_Branding__c siteBrandingObject = SiteBrandingIdentifierTest.createSiteBranding('test brand', 'Informa', 'testbrand', 'informa markets', false);
    siteBrandingObject.Default_Landing_Page__c = 'http://www.informa.com';
    insert siteBrandingObject;
    Blob b3 = Blob.valueOf('Test Data record');
    ContentVersion cVersion = new ContentVersion();
    cVersion.ContentLocation = 'S'; //S-Document is in Salesforce. E-Document is outside of Salesforce. L-Document is on a Social Netork.
    cVersion.PathOnClient = 'logo.jpeg';//File name with extention
    cVersion.Origin = 'H';//C-Content Origin. H-Chatter Origin.
    cVersion.OwnerId = userinfo.getUserId();//Owner of the file
    cVersion.Title ='Completed Test Signed Files for Parent Manual';//Name of the file
    cVersion.VersionData = b3;//File content
    insert cVersion;
    Id conDocument = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cVersion.Id].ContentDocumentId;
    ContentDocumentLink cDocLink = new ContentDocumentLink();
    cDocLink.ContentDocumentId = conDocument;//Add ContentDocumentId
    cDocLink.LinkedEntityId = siteBrandingObject.Id;//Add Files parentId
    cDocLink.ShareType = 'V';//V - Viewer permission. C - Collaborator permission. I - Inferred permission.
    cDocLink.Visibility = 'AllUsers';//AllUsers, InternalUsers, SharedUsers
    insert cDocLink;
    Blob b2 = Blob.valueOf('Test Data record');
    ContentVersion cVersion1 = new ContentVersion();
    cVersion1.ContentLocation = 'S'; //S-Document is in Salesforce. E-Document is outside of Salesforce. L-Document is on a Social Netork.
    cVersion1.PathOnClient = 'pageImage.jpeg';//File name with extention
    cVersion1.Origin = 'H';//C-Content Origin. H-Chatter Origin.
    cVersion1.OwnerId = userinfo.getUserId();//Owner of the file
    cVersion1.Title ='pageImage.jpeg';//Name of the file
    cVersion1.VersionData = b2;//File content
    insert cVersion1;
    Id conDocument1 = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cVersion1.Id].ContentDocumentId;
    ContentDocumentLink cDocLink1 = new ContentDocumentLink();
    cDocLink1.ContentDocumentId = conDocument1;//Add ContentDocumentId
    cDocLink1.LinkedEntityId = siteBrandingObject.Id;//Add Files parentId
    cDocLink1.ShareType = 'V';//V - Viewer permission. C - Collaborator permission. I - Inferred permission.
    cDocLink1.Visibility = 'AllUsers';//AllUsers, InternalUsers, SharedUsers
    insert cDocLink1;
    Blob b1 = Blob.valueOf('Test Data record');
    ContentVersion cVersion13 = new ContentVersion();
    cVersion13.ContentLocation = 'S'; //S-Document is in Salesforce. E-Document is outside of Salesforce. L-Document is on a Social Netork.
    cVersion13.PathOnClient = 'productImage.jpeg';//File name with extention
    cVersion13.Origin = 'H';//C-Content Origin. H-Chatter Origin.
    cVersion13.OwnerId = userinfo.getUserId();//Owner of the file
    cVersion13.Title ='productImage.jpeg';//Name of the file
    cVersion13.VersionData = b1;//File content
    insert cVersion13;
    Id conDocument13 = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cVersion13.Id].ContentDocumentId;
    ContentDocumentLink cDocLink13 = new ContentDocumentLink();
    cDocLink13.ContentDocumentId = conDocument13;//Add ContentDocumentId
    cDocLink13.LinkedEntityId = siteBrandingObject.Id;//Add Files parentId
    cDocLink13.ShareType = 'V';//V - Viewer permission. C - Collaborator permission. I - Inferred permission.
    cDocLink13.Visibility = 'AllUsers';//AllUsers, InternalUsers, SharedUsers
    insert cDocLink13;
    Cookie brand = new Cookie('brand', 'Informa', null, 1, false);
    Cookie rurl = new Cookie('rurl', 'http://www.informa.com', null, 1, false);

    PageReference regPage = Page.registration;
    regpage.setCookies(new List<Cookie> {brand, rurl});


    Test.setCurrentPage(regpage);

    // Page set but no referral Id so default record of informa should be found
    SiteBrandingIdentifier siteBranding = new SiteBrandingIdentifier();

    System.assertEquals('informa', SiteBrandingIdentifier.referralId,'Should Match');
    System.assertEquals('http://www.informa.com', siteBranding.referralUrl,'Should Match');

    // Assert the SiteBrandingIdentifier picked up brand from cookie
    System.assertEquals(siteBrandingObject.Id, siteBranding.branding.Id,'The Id should be match');
    //System.assertEquals(verticalLogo.Id, siteBranding.verticalLogo.Id,'The Id should be match');
    //System.assertEquals(pageImage.Id, siteBranding.pageImage.Id,'The Id should be match');
    System.assertEquals('http://www.informa.com', regpage.getCookies().get('rurl').getValue(),'This should be return true');
    System.assertEquals('informa', regpage.getCookies().get('brand').getValue(),'This should be return true');
}

@isTest static void test_method_three_without_referral_cookies() {

    // Setup default branding where non is found
    esso_Site_Branding__c siteBrandingObject = SiteBrandingIdentifierTest.createSiteBranding('test brand', 'Informa', 'testbrand', 'informa markets', false);
    siteBrandingObject.Default_Landing_Page__c = 'http://www.informa.com';
    insert siteBrandingObject;

    Blob b3 = Blob.valueOf('Test Data record');
    ContentVersion cVersion = new ContentVersion();
    cVersion.ContentLocation = 'S'; //S-Document is in Salesforce. E-Document is outside of Salesforce. L-Document is on a Social Netork.
    cVersion.PathOnClient = 'logo.jpeg';//File name with extention
    cVersion.Origin = 'H';//C-Content Origin. H-Chatter Origin.
    cVersion.OwnerId = userinfo.getUserId();//Owner of the file
    cVersion.Title ='Completed Test Signed Files for Parent Manual';//Name of the file
    cVersion.VersionData = b3;//File content
    insert cVersion;
    Id conDocument = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cVersion.Id].ContentDocumentId;
    ContentDocumentLink cDocLink = new ContentDocumentLink();
    cDocLink.ContentDocumentId = conDocument;//Add ContentDocumentId
    cDocLink.LinkedEntityId = siteBrandingObject.Id;//Add Files parentId
    cDocLink.ShareType = 'V';//V - Viewer permission. C - Collaborator permission. I - Inferred permission.
    cDocLink.Visibility = 'AllUsers';//AllUsers, InternalUsers, SharedUsers
    insert cDocLink;
    Blob b2 = Blob.valueOf('Test Data record');
    ContentVersion cVersion1 = new ContentVersion();
    cVersion1.ContentLocation = 'S'; //S-Document is in Salesforce. E-Document is outside of Salesforce. L-Document is on a Social Netork.
    cVersion1.PathOnClient = 'pageImage.jpeg';//File name with extention
    cVersion1.Origin = 'H';//C-Content Origin. H-Chatter Origin.
    cVersion1.OwnerId = userinfo.getUserId();//Owner of the file
    cVersion1.Title ='pageImage.jpeg';//Name of the file
    cVersion1.VersionData = b2;//File content
    insert cVersion1;
    Id conDocument1 = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cVersion1.Id].ContentDocumentId;
    ContentDocumentLink cDocLink1 = new ContentDocumentLink();
    cDocLink1.ContentDocumentId = conDocument1;//Add ContentDocumentId
    cDocLink1.LinkedEntityId = siteBrandingObject.Id;//Add Files parentId
    cDocLink1.ShareType = 'V';//V - Viewer permission. C - Collaborator permission. I - Inferred permission.
    cDocLink1.Visibility = 'AllUsers';//AllUsers, InternalUsers, SharedUsers
    insert cDocLink1;
    Blob b1 = Blob.valueOf('Test Data record');
    ContentVersion cVersion13 = new ContentVersion();
    cVersion13.ContentLocation = 'S'; //S-Document is in Salesforce. E-Document is outside of Salesforce. L-Document is on a Social Netork.
    cVersion13.PathOnClient = 'productImage.jpeg';//File name with extention
    cVersion13.Origin = 'H';//C-Content Origin. H-Chatter Origin.
    cVersion13.OwnerId = userinfo.getUserId();//Owner of the file
    cVersion13.Title ='productImage.jpeg';//Name of the file
    cVersion13.VersionData = b1;//File content
    insert cVersion13;
    Id conDocument13 = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cVersion13.Id].ContentDocumentId;
    ContentDocumentLink cDocLink13 = new ContentDocumentLink();
    cDocLink13.ContentDocumentId = conDocument13;//Add ContentDocumentId
    cDocLink13.LinkedEntityId = siteBrandingObject.Id;//Add Files parentId
    cDocLink13.ShareType = 'V';//V - Viewer permission. C - Collaborator permission. I - Inferred permission.
    cDocLink13.Visibility = 'AllUsers';//AllUsers, InternalUsers, SharedUsers
    insert cDocLink13;



    //Cookie brand = new Cookie('brand', 'testbrand', null, 1, false);
    //Cookie rurl = new Cookie('rurl', 'http://www.informa.com', null, 1, false);

    PageReference regPage = Page.registration;
    //regpage.setCookies(new List<Cookie>{brand, rurl});

    regPage.getParameters().put('referralid', 'informa');
    regPage.getParameters().put('referralurl', 'http://www.informa.com/informamarkets');

    Test.setCurrentPage(regpage);

    // Page set but no referral Id so default record of informa should be found
    SiteBrandingIdentifier siteBranding = new SiteBrandingIdentifier();

    // Set cookies based on referral id and url
    siteBranding.setCookies(regpage, false);

    Cookie referralUrlCookie = ApexPages.currentPage().getCookies().get('rurl');
    Cookie brandCookie = ApexPages.currentPage().getCookies().get('brand');

    System.assertEquals('informa', brandCookie.getValue(),'The value should be match');
    System.assertEquals('http://www.informa.com/informamarkets', referralUrlCookie.getValue(), 'The value should be match: ' + referralUrlCookie.getValue());

    // Assert the SiteBrandingIdentifier picked up brand from cookie
    System.assertEquals(siteBrandingObject.Id, siteBranding.branding.Id,'The value should be match');
    //System.assertEquals(verticalLogo.Id, siteBranding.verticalLogo.Id,'The value should be match');
    //System.assertEquals(pageImage.Id, siteBranding.pageImage.Id,'The value should be match');

    // Set the cookie expiry to now
    siteBranding.setCookies(regpage, true);

    System.assertEquals(0, regpage.getCookies().get('rurl').getMaxAge(),'The value should be match');
    System.assertEquals(0, regpage.getCookies().get('brand').getMaxAge(),'The value should be match');
}

@isTest static void test_vertical_default_landing() {

    // Setup default branding where non is found


    Network community = [SELECT Id, Name FROM Network ORDER BY Name DESC LIMIT 1];

    esso_Site_Branding__c verticalBrand = SiteBrandingIdentifierTest.createSiteBranding('informamarkets', esso_Configuration.setting.Branding_Default__c, 'informa markets', 'informa markets', false);
    verticalBrand.Default_Landing_Page__c = 'http://www.apex-unit-testing-vertical.com';
    insert verticalBrand;

    Blob b3 = Blob.valueOf('Test Data record');
    ContentVersion cVersion = new ContentVersion();
    cVersion.ContentLocation = 'S'; //S-Document is in Salesforce. E-Document is outside of Salesforce. L-Document is on a Social Netork.
    cVersion.PathOnClient = 'logo.jpeg';//File name with extention
    cVersion.Origin = 'H';//C-Content Origin. H-Chatter Origin.
    cVersion.OwnerId = userinfo.getUserId();//Owner of the file
    cVersion.Title ='logo';//Name of the file
    cVersion.VersionData = b3;//File content
    insert cVersion;
    Id conDocument = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cVersion.Id].ContentDocumentId;
    ContentDocumentLink cDocLink = new ContentDocumentLink();
    cDocLink.ContentDocumentId = conDocument;//Add ContentDocumentId
    cDocLink.LinkedEntityId = verticalBrand.Id;//Add Files parentId
    cDocLink.ShareType = 'V';//V - Viewer permission. C - Collaborator permission. I - Inferred permission.
    cDocLink.Visibility = 'AllUsers';//AllUsers, InternalUsers, SharedUsers
    insert cDocLink;
    Blob b2 = Blob.valueOf('Test Data record');
    ContentVersion cVersion1 = new ContentVersion();
    cVersion1.ContentLocation = 'S'; //S-Document is in Salesforce. E-Document is outside of Salesforce. L-Document is on a Social Netork.
    cVersion1.PathOnClient = 'pageImage.jpeg';//File name with extention
    cVersion1.Origin = 'H';//C-Content Origin. H-Chatter Origin.
    cVersion1.OwnerId = userinfo.getUserId();//Owner of the file
    cVersion1.Title ='pageImage.jpeg';//Name of the file
    cVersion1.VersionData = b2;//File content
    insert cVersion1;
    Id conDocument1 = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cVersion1.Id].ContentDocumentId;
    ContentDocumentLink cDocLink1 = new ContentDocumentLink();
    cDocLink1.ContentDocumentId = conDocument1;//Add ContentDocumentId
    cDocLink1.LinkedEntityId = verticalBrand.Id;//Add Files parentId
    cDocLink1.ShareType = 'V';//V - Viewer permission. C - Collaborator permission. I - Inferred permission.
    cDocLink1.Visibility = 'AllUsers';//AllUsers, InternalUsers, SharedUsers
    insert cDocLink1;
    Blob b1 = Blob.valueOf('Test Data record');
    ContentVersion cVersion13 = new ContentVersion();
    cVersion13.ContentLocation = 'S'; //S-Document is in Salesforce. E-Document is outside of Salesforce. L-Document is on a Social Netork.
    cVersion13.PathOnClient = 'productImage.jpeg';//File name with extention
    cVersion13.Origin = 'H';//C-Content Origin. H-Chatter Origin.
    cVersion13.OwnerId = userinfo.getUserId();//Owner of the file
    cVersion13.Title ='productImage.jpeg';//Name of the file
    cVersion13.VersionData = b1;//File content
    insert cVersion13;
    Id conDocument13 = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cVersion13.Id].ContentDocumentId;
    ContentDocumentLink cDocLink13 = new ContentDocumentLink();
    cDocLink13.ContentDocumentId = conDocument13;//Add ContentDocumentId
    cDocLink13.LinkedEntityId = verticalBrand.Id;//Add Files parentId
    cDocLink13.ShareType = 'V';//V - Viewer permission. C - Collaborator permission. I - Inferred permission.
    cDocLink13.Visibility = 'AllUsers';//AllUsers, InternalUsers, SharedUsers
    insert cDocLink13;



    esso_Site_Branding__c siteBrandingObject = SiteBrandingIdentifierTest.createSiteBranding('informamarkets Product', 'informamarkets', 'informamarkets', 'informa markets', false);
    siteBrandingObject.Branding_Type__c = 'Product';
    siteBrandingObject.Default_Landing_Page__c = 'https://www.informa.com';
    //siteBrandingObject.Client_Services_Contact_Email__c = null;
    insert siteBrandingObject;

    //Blob b3 = Blob.valueOf('Test Data record');
    ContentVersion cVersion0 = new ContentVersion();
    cVersion0.ContentLocation = 'S'; //S-Document is in Salesforce. E-Document is outside of Salesforce. L-Document is on a Social Netork.
    cVersion0.PathOnClient = 'logo.jpeg';//File name with extention
    cVersion0.Origin = 'H';//C-Content Origin. H-Chatter Origin.
    cVersion0.OwnerId = userinfo.getUserId();//Owner of the file
    cVersion0.Title ='Completed Test Signed Files for Parent Manual';//Name of the file
    cVersion0.VersionData = b3;//File content
    insert cVersion0;
    Id conDocument0 = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cVersion0.Id].ContentDocumentId;
    ContentDocumentLink cDocLink0 = new ContentDocumentLink();
    cDocLink0.ContentDocumentId = conDocument0;//Add ContentDocumentId
    cDocLink0.LinkedEntityId = siteBrandingObject.Id;//Add Files parentId
    cDocLink0.ShareType = 'V';//V - Viewer permission. C - Collaborator permission. I - Inferred permission.
    cDocLink0.Visibility = 'AllUsers';//AllUsers, InternalUsers, SharedUsers
    insert cDocLink0;
   // Blob b2 = Blob.valueOf('Test Data record');
    ContentVersion cVersion11 = new ContentVersion();
    cVersion11.ContentLocation = 'S'; //S-Document is in Salesforce. E-Document is outside of Salesforce. L-Document is on a Social Netork.
    cVersion11.PathOnClient = 'pageImage.jpeg';//File name with extention
    cVersion11.Origin = 'H';//C-Content Origin. H-Chatter Origin.
    cVersion11.OwnerId = userinfo.getUserId();//Owner of the file
    cVersion11.Title ='pageImage.jpeg';//Name of the file
    cVersion11.VersionData = b2;//File content
    insert cVersion11;
    Id conDocument122 = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cVersion11.Id].ContentDocumentId;
    ContentDocumentLink cDocLink11 = new ContentDocumentLink();
    cDocLink11.ContentDocumentId = conDocument122;//Add ContentDocumentId
    cDocLink11.LinkedEntityId = siteBrandingObject.Id;//Add Files parentId
    cDocLink11.ShareType = 'V';//V - Viewer permission. C - Collaborator permission. I - Inferred permission.
    cDocLink11.Visibility = 'AllUsers';//AllUsers, InternalUsers, SharedUsers
    insert cDocLink11;
    //Blob b11 = Blob.valueOf('Test Data record');
    ContentVersion cVersion131 = new ContentVersion();
    cVersion131.ContentLocation = 'S'; //S-Document is in Salesforce. E-Document is outside of Salesforce. L-Document is on a Social Netork.
    cVersion131.PathOnClient = 'productImage.jpeg';//File name with extention
    cVersion131.Origin = 'H';//C-Content Origin. H-Chatter Origin.
    cVersion131.OwnerId = userinfo.getUserId();//Owner of the file
    cVersion131.Title ='productImage.jpeg';//Name of the file
    cVersion131.VersionData = b1;//File content
    insert cVersion131;
    Id conDocument132 = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cVersion13.Id].ContentDocumentId;
    ContentDocumentLink cDocLink132 = new ContentDocumentLink();
    cDocLink132.ContentDocumentId = conDocument132;//Add ContentDocumentId
    cDocLink132.LinkedEntityId = siteBrandingObject.Id;//Add Files parentId
    cDocLink132.ShareType = 'V';//V - Viewer permission. C - Collaborator permission. I - Inferred permission.
    cDocLink132.Visibility = 'AllUsers';//AllUsers, InternalUsers, SharedUsers
    insert cDocLink132;

    Test.setCurrentPage(Page.registration);
    ApexPages.currentPage().getParameters().put('referralid', 'informamarkets');//doesn't exist

    SiteBrandingIdentifier siteBranding = new SiteBrandingIdentifier();
    siteBranding.unitTestInitialise(community.Name);

    System.assertEquals(siteBrandingObject.Id, siteBranding.branding.Id,'The value should be match');
    //System.assertEquals(verticalLogo2.Id, siteBranding.verticalLogo.Id,'The value should be match');
    //System.assertEquals(pageImage2.Id, siteBranding.pageImage.Id,'The value should be match');
    System.assertEquals('https://www.informa.com', siteBranding.defaultLandingUrl,'The value should be match');
}

@isTest static void test_product_default_values() {

    Network community = [SELECT Id, Name FROM Network ORDER BY Name DESC LIMIT 1];

    esso_Site_Branding__c verticalBrand = SiteBrandingIdentifierTest.createSiteBranding('informamarketsbusiness', community.Name, 'informa markets Business', 'informa markets', false);
    verticalBrand.Default_Landing_Page__c = 'http://www.apex-unit-testing-vertical.com';
    verticalBrand.Customer_Support_Page__c = 'http://www.apex-unit-testing-vertical.com/contact-us';
    //verticalBrand.Client_Services_Contact_Email__c = 'customerservices@informa.vertical.apextest.com';
    verticalBrand.Favourite_Icon_Logo_File_Name__c = 'favicon.ico';
    insert verticalBrand;

    Blob b3 = Blob.valueOf('Test Data record');
    ContentVersion cVersion = new ContentVersion();
    cVersion.ContentLocation = 'S'; //S-Document is in Salesforce. E-Document is outside of Salesforce. L-Document is on a Social Netork.
    cVersion.PathOnClient = 'logo.jpeg';//File name with extention
    cVersion.Origin = 'H';//C-Content Origin. H-Chatter Origin.
    cVersion.OwnerId = userinfo.getUserId();//Owner of the file
    cVersion.Title ='Completed Test Signed Files for Parent Manual';//Name of the file
    cVersion.VersionData = b3;//File content
    insert cVersion;
    Id conDocument = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cVersion.Id].ContentDocumentId;
    ContentDocumentLink cDocLink = new ContentDocumentLink();
    cDocLink.ContentDocumentId = conDocument;//Add ContentDocumentId
    cDocLink.LinkedEntityId = verticalBrand.Id;//Add Files parentId
    cDocLink.ShareType = 'V';//V - Viewer permission. C - Collaborator permission. I - Inferred permission.
    cDocLink.Visibility = 'AllUsers';//AllUsers, InternalUsers, SharedUsers
    insert cDocLink;
    Blob b2 = Blob.valueOf('Test Data record');
    ContentVersion cVersion1 = new ContentVersion();
    cVersion1.ContentLocation = 'S'; //S-Document is in Salesforce. E-Document is outside of Salesforce. L-Document is on a Social Netork.
    cVersion1.PathOnClient = 'pageImage.jpeg';//File name with extention
    cVersion1.Origin = 'H';//C-Content Origin. H-Chatter Origin.
    cVersion1.OwnerId = userinfo.getUserId();//Owner of the file
    cVersion1.Title ='pageImage.jpeg';//Name of the file
    cVersion1.VersionData = b2;//File content
    insert cVersion1;
    Id conDocument1 = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cVersion1.Id].ContentDocumentId;
    ContentDocumentLink cDocLink1 = new ContentDocumentLink();
    cDocLink1.ContentDocumentId = conDocument1;//Add ContentDocumentId
    cDocLink1.LinkedEntityId = verticalBrand.Id;//Add Files parentId
    cDocLink1.ShareType = 'V';//V - Viewer permission. C - Collaborator permission. I - Inferred permission.
    cDocLink1.Visibility = 'AllUsers';//AllUsers, InternalUsers, SharedUsers
    insert cDocLink1;
    Blob b1 = Blob.valueOf('Test Data record');
    ContentVersion cVersion13 = new ContentVersion();
    cVersion13.ContentLocation = 'S'; //S-Document is in Salesforce. E-Document is outside of Salesforce. L-Document is on a Social Netork.
    cVersion13.PathOnClient = 'productImage.jpeg';//File name with extention
    cVersion13.Origin = 'H';//C-Content Origin. H-Chatter Origin.
    cVersion13.OwnerId = userinfo.getUserId();//Owner of the file
    cVersion13.Title ='productImage.jpeg';//Name of the file
    cVersion13.VersionData = b1;//File content
    insert cVersion13;
    Id conDocument13 = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cVersion13.Id].ContentDocumentId;
    ContentDocumentLink cDocLink13 = new ContentDocumentLink();
    cDocLink13.ContentDocumentId = conDocument13;//Add ContentDocumentId
    cDocLink13.LinkedEntityId = verticalBrand.Id;//Add Files parentId
    cDocLink13.ShareType = 'V';//V - Viewer permission. C - Collaborator permission. I - Inferred permission.
    cDocLink13.Visibility = 'AllUsers';//AllUsers, InternalUsers, SharedUsers
    insert cDocLink13;
    Blob b22 = Blob.valueOf('Test Data record');
    ContentVersion cVersion22 = new ContentVersion();
    cVersion22.ContentLocation = 'S'; //S-Document is in Salesforce. E-Document is outside of Salesforce. L-Document is on a Social Netork.
    cVersion22.PathOnClient = 'favicon.ico';//File name with extention
    cVersion22.Origin = 'H';//C-Content Origin. H-Chatter Origin.
    cVersion22.OwnerId = userinfo.getUserId();//Owner of the file
    cVersion22.Title ='favicon.ico';//Name of the file
    cVersion22.VersionData = b22;//File content
    insert cVersion22;
    Id conDocument22 = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cVersion22.Id].ContentDocumentId;
    ContentDocumentLink cDocLink22 = new ContentDocumentLink();
    cDocLink22.ContentDocumentId = conDocument22;//Add ContentDocumentId
    cDocLink22.LinkedEntityId = verticalBrand.Id;//Add Files parentId
    cDocLink22.ShareType = 'V';//V - Viewer permission. C - Collaborator permission. I - Inferred permission.
    cDocLink22.Visibility = 'AllUsers';//AllUsers, InternalUsers, SharedUsers
    insert cDocLink22;

    esso_Site_Branding__c siteBrandingObject = SiteBrandingIdentifierTest.createSiteBranding('informamarketsbusiness', 'Informa', 'informa markets Business', 'informa markets', false);
    siteBrandingObject.Default_Landing_Page__c = 'http://www.apex-unit-testing-product.com';
    siteBrandingObject.Customer_Support_Page__c = 'http://www.apex-unit-testing-product.com/contact-us';
    //siteBrandingObject.Client_Services_Contact_Email__c = 'customerservices@informa.product.apextest.com';
    siteBrandingObject.Favourite_Icon_Logo_File_Name__c = 'favicon.ico';
    insert siteBrandingObject;
    Test.setCurrentPage(Page.registration);
    ApexPages.currentPage().getParameters().put('referralid', 'Informa');

    SiteBrandingIdentifier siteBranding = new SiteBrandingIdentifier();
    siteBranding.unitTestInitialise(community.Name);

    System.assertEquals(siteBrandingObject.Id, siteBranding.branding.Id,'The value should be match');
    //System.assertEquals(verticalLogo2.Id, siteBranding.verticalLogo.Id,'The value should be match');
    //System.assertEquals(pageImage2.Id, siteBranding.pageImage.Id,'The value should be match');
    //System.assertEquals(favicon2.Id, siteBranding.favicon.Id,'The value should be match');
    System.assertEquals('http://www.apex-unit-testing-product.com', siteBranding.defaultLandingUrl,'The value should be match');
    System.assertEquals('http://www.apex-unit-testing-product.com/contact-us', siteBranding.defaultCustomerSupportPage,'The value should be match');
    //System.assertEquals('customerservices@informa.product.apextest.com', siteBranding.defaultClientServicesEmail);
}

@isTest static void test_referral_values_IdeAppSecurity_Enabled_Whitelisted() {

    XssSecurityHelperTest.setupSettings(true);

    // Setup default branding where non is found
    esso_Site_Branding__c siteBrandingObject = SiteBrandingIdentifierTest.createSiteBranding('test brand', 'informa', 'testbrand', 'informa markets', false);
    insert siteBrandingObject;

    Blob b3 = Blob.valueOf('Test Data record');
    ContentVersion cVersion = new ContentVersion();
    cVersion.ContentLocation = 'S'; //S-Document is in Salesforce. E-Document is outside of Salesforce. L-Document is on a Social Netork.
    cVersion.PathOnClient = 'logo.jpeg';//File name with extention
    cVersion.Origin = 'H';//C-Content Origin. H-Chatter Origin.
    cVersion.OwnerId = userinfo.getUserId();//Owner of the file
    cVersion.Title ='Completed Test Signed Files for Parent Manual';//Name of the file
    cVersion.VersionData = b3;//File content
    insert cVersion;
    Id conDocument = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cVersion.Id].ContentDocumentId;
    ContentDocumentLink cDocLink = new ContentDocumentLink();
    cDocLink.ContentDocumentId = conDocument;//Add ContentDocumentId
    cDocLink.LinkedEntityId = siteBrandingObject.Id;//Add Files parentId
    cDocLink.ShareType = 'V';//V - Viewer permission. C - Collaborator permission. I - Inferred permission.
    cDocLink.Visibility = 'AllUsers';//AllUsers, InternalUsers, SharedUsers
    insert cDocLink;
    Blob b2 = Blob.valueOf('Test Data record');
    ContentVersion cVersion1 = new ContentVersion();
    cVersion1.ContentLocation = 'S'; //S-Document is in Salesforce. E-Document is outside of Salesforce. L-Document is on a Social Netork.
    cVersion1.PathOnClient = 'pageImage.jpeg';//File name with extention
    cVersion1.Origin = 'H';//C-Content Origin. H-Chatter Origin.
    cVersion1.OwnerId = userinfo.getUserId();//Owner of the file
    cVersion1.Title ='pageImage.jpeg';//Name of the file
    cVersion1.VersionData = b2;//File content
    insert cVersion1;
    Id conDocument1 = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cVersion1.Id].ContentDocumentId;
    ContentDocumentLink cDocLink1 = new ContentDocumentLink();
    cDocLink1.ContentDocumentId = conDocument1;//Add ContentDocumentId
    cDocLink1.LinkedEntityId = siteBrandingObject.Id;//Add Files parentId
    cDocLink1.ShareType = 'V';//V - Viewer permission. C - Collaborator permission. I - Inferred permission.
    cDocLink1.Visibility = 'AllUsers';//AllUsers, InternalUsers, SharedUsers
    insert cDocLink1;
    Blob b1 = Blob.valueOf('Test Data record');
    ContentVersion cVersion13 = new ContentVersion();
    cVersion13.ContentLocation = 'S'; //S-Document is in Salesforce. E-Document is outside of Salesforce. L-Document is on a Social Netork.
    cVersion13.PathOnClient = 'productImage.jpeg';//File name with extention
    cVersion13.Origin = 'H';//C-Content Origin. H-Chatter Origin.
    cVersion13.OwnerId = userinfo.getUserId();//Owner of the file
    cVersion13.Title ='productImage.jpeg';//Name of the file
    cVersion13.VersionData = b1;//File content
    insert cVersion13;
    Id conDocument13 = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cVersion13.Id].ContentDocumentId;
    ContentDocumentLink cDocLink13 = new ContentDocumentLink();
    cDocLink13.ContentDocumentId = conDocument13;//Add ContentDocumentId
    cDocLink13.LinkedEntityId = siteBrandingObject.Id;//Add Files parentId
    cDocLink13.ShareType = 'V';//V - Viewer permission. C - Collaborator permission. I - Inferred permission.
    cDocLink13.Visibility = 'AllUsers';//AllUsers, InternalUsers, SharedUsers
    insert cDocLink13;


    PageReference regPage = Page.registration;
    //regpage.setCookies(new List<Cookie>{brand, rurl});

    regPage.getParameters().put('referralid', siteBrandingObject.Referral_ID__c);
    regPage.getParameters().put('referralurl', siteBrandingObject.Default_Landing_Page__c);

    Test.setCurrentPage(regpage);

    // Page set but no referral Id so default record of informa should be found
    SiteBrandingIdentifier siteBranding = new SiteBrandingIdentifier();

    // Set cookies based on referral id and url
    //siteBranding.setCookies(regpage, false);

    Cookie referralUrlCookie = ApexPages.currentPage().getCookies().get('rurl');
    Cookie brandCookie = ApexPages.currentPage().getCookies().get('brand');

    System.assertEquals(siteBrandingObject.Referral_ID__c, brandCookie.getValue(),'The value should be match');
    System.assertEquals(siteBrandingObject.Default_Landing_Page__c, referralUrlCookie.getValue(),'The value should be match');

    // Assert the SiteBrandingIdentifier picked up brand from cookie
    System.assertEquals(siteBrandingObject.Id, siteBranding.branding.Id,'The value should be match');
    //System.assertEquals(verticalLogo.Id, siteBranding.verticalLogo.Id,'The value should be match');
    //System.assertEquals(pageImage.Id, siteBranding.pageImage.Id,'The value should be match');

    // Set the cookie expiry to now
    siteBranding.setCookies(regpage, true);

    System.assertEquals(0, regpage.getCookies().get('rurl').getMaxAge(),'The value should be match');
    System.assertEquals(0, regpage.getCookies().get('brand').getMaxAge(),'The value should be match');
}

@isTest static void test_referral_values_IdeAppSecurity_Enabled_Non_Whitelist() {

    XssSecurityHelperTest.setupSettings(true);
    // Setup default branding where non is found
    esso_Site_Branding__c siteBrandingObject = SiteBrandingIdentifierTest.createSiteBranding('Defaul Informa Brand', 'informa', 'Informa', 'informa markets', false);
    insert siteBrandingObject;

    Blob b3 = Blob.valueOf('Test Data record');
    ContentVersion cVersion = new ContentVersion();
    cVersion.ContentLocation = 'S'; //S-Document is in Salesforce. E-Document is outside of Salesforce. L-Document is on a Social Netork.
    cVersion.PathOnClient = 'logo.jpeg';//File name with extention
    cVersion.Origin = 'H';//C-Content Origin. H-Chatter Origin.
    cVersion.OwnerId = userinfo.getUserId();//Owner of the file
    cVersion.Title ='Completed Test Signed Files for Parent Manual';//Name of the file
    cVersion.VersionData = b3;//File content
    insert cVersion;
    Id conDocument = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cVersion.Id].ContentDocumentId;
    ContentDocumentLink cDocLink = new ContentDocumentLink();
    cDocLink.ContentDocumentId = conDocument;//Add ContentDocumentId
    cDocLink.LinkedEntityId = siteBrandingObject.Id;//Add Files parentId
    cDocLink.ShareType = 'V';//V - Viewer permission. C - Collaborator permission. I - Inferred permission.
    cDocLink.Visibility = 'AllUsers';//AllUsers, InternalUsers, SharedUsers
    insert cDocLink;
    Blob b2 = Blob.valueOf('Test Data record');
    ContentVersion cVersion1 = new ContentVersion();
    cVersion1.ContentLocation = 'S'; //S-Document is in Salesforce. E-Document is outside of Salesforce. L-Document is on a Social Netork.
    cVersion1.PathOnClient = 'pageImage.jpeg';//File name with extention
    cVersion1.Origin = 'H';//C-Content Origin. H-Chatter Origin.
    cVersion1.OwnerId = userinfo.getUserId();//Owner of the file
    cVersion1.Title ='pageImage.jpeg';//Name of the file
    cVersion1.VersionData = b2;//File content
    insert cVersion1;
    Id conDocument1 = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cVersion1.Id].ContentDocumentId;
    ContentDocumentLink cDocLink1 = new ContentDocumentLink();
    cDocLink1.ContentDocumentId = conDocument1;//Add ContentDocumentId
    cDocLink1.LinkedEntityId = siteBrandingObject.Id;//Add Files parentId
    cDocLink1.ShareType = 'V';//V - Viewer permission. C - Collaborator permission. I - Inferred permission.
    cDocLink1.Visibility = 'AllUsers';//AllUsers, InternalUsers, SharedUsers
    insert cDocLink1;
    Blob b1 = Blob.valueOf('Test Data record');
    ContentVersion cVersion13 = new ContentVersion();
    cVersion13.ContentLocation = 'S'; //S-Document is in Salesforce. E-Document is outside of Salesforce. L-Document is on a Social Netork.
    cVersion13.PathOnClient = 'productImage.jpeg';//File name with extention
    cVersion13.Origin = 'H';//C-Content Origin. H-Chatter Origin.
    cVersion13.OwnerId = userinfo.getUserId();//Owner of the file
    cVersion13.Title ='productImage.jpeg';//Name of the file
    cVersion13.VersionData = b1;//File content
    insert cVersion13;
    Id conDocument13 = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cVersion13.Id].ContentDocumentId;
    ContentDocumentLink cDocLink13 = new ContentDocumentLink();
    cDocLink13.ContentDocumentId = conDocument13;//Add ContentDocumentId
    cDocLink13.LinkedEntityId = siteBrandingObject.Id;//Add Files parentId
    cDocLink13.ShareType = 'V';//V - Viewer permission. C - Collaborator permission. I - Inferred permission.
    cDocLink13.Visibility = 'AllUsers';//AllUsers, InternalUsers, SharedUsers
    insert cDocLink13;


    PageReference regPage = Page.registration;
    //regpage.setCookies(new List<Cookie>{brand, rurl});

    regPage.getParameters().put('referralid', 'BAD_ID');
    regPage.getParameters().put('referralurl', 'http://bad-site.com');

    Test.setCurrentPage(regpage);

    // Page set but no referral Id so default record of informa should be found
    SiteBrandingIdentifier siteBranding = new SiteBrandingIdentifier();

    Cookie referralUrlCookie = ApexPages.currentPage().getCookies().get('rurl');
    Cookie brandCookie = ApexPages.currentPage().getCookies().get('brand');

    System.assertEquals('informa', brandCookie.getValue(),'The value should be match');
    System.assertEquals('https://www.informa.com', referralUrlCookie.getValue(),'The value should be match');

    // Assert the SiteBrandingIdentifier picked up brand from cookie
    System.assertEquals(siteBrandingObject.Id, siteBranding.branding.Id,'The value should be match');
    //System.assertEquals(verticalLogo.Id, siteBranding.verticalLogo.Id,'The value should be match');
    //System.assertEquals(pageImage.Id, siteBranding.pageImage.Id,'The value should be match');

    // Set the cookie expiry to now
    siteBranding.setCookies(regpage, true);

    System.assertEquals(0, regpage.getCookies().get('rurl').getMaxAge(),'The value should be match');
    System.assertEquals(0, regpage.getCookies().get('brand').getMaxAge(),'The value should be match');
}


public static esso_Site_Branding__c createSiteBranding(String brandName, String referralId, String productName, String division, Boolean isInsert){

    esso_Site_Branding__c siteBrandingObject = new esso_Site_Branding__c(
        Name = brandName,
        Footer_Background_Colour__c = '#000000',
        Footer_Font_Colour__c  = '#FFFFFF',
        Footer_Logo_File_Name__c = 'logo.jpeg',
        Headings_Font_Colour__c = '#AAAAAA',
        Page_Background_Colour__c = '#FFFFFF',
        Page_Image__c = 'pageImage.jpeg',
        Product_Logo_File_Name__c = 'productImage.jpeg',
        Primary_Colour__c = '#BBBBBB',
        Referral_Id__c = referralId,
        Secondary_Colour__c = '#CCCCCC',
        Standard_Font_Colour__c = '#000000',
        Product_Name__c = productName,
        Division__c = division,
        Language__c='en_US',
        Branding_Type__c = 'Vertical',
        // Client_Services_Contact_Email__c = 'help@informa.com',
        Default_Landing_Page__c = 'https://www.informa.com',
        Registration_Contact_Source__c = 'A55_Website Registrant (FREE)',
        Customer_Support_Page__c = 'https://informa.com/contact-us'
        );
    if(isInsert) {
        insert siteBrandingObject;

        Blob b3 = Blob.valueOf('Test Data record');
    ContentVersion cVersion = new ContentVersion();
    cVersion.ContentLocation = 'S'; //S-Document is in Salesforce. E-Document is outside of Salesforce. L-Document is on a Social Netork.
    cVersion.PathOnClient = 'logo.jpeg';//File name with extention
    cVersion.Origin = 'H';//C-Content Origin. H-Chatter Origin.
    cVersion.OwnerId = userinfo.getUserId();//Owner of the file
    cVersion.Title ='Completed Test Signed Files for Parent Manual';//Name of the file
    cVersion.VersionData = b3;//File content
    insert cVersion;
    Id conDocument = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cVersion.Id].ContentDocumentId;
    ContentDocumentLink cDocLink = new ContentDocumentLink();
    cDocLink.ContentDocumentId = conDocument;//Add ContentDocumentId
    cDocLink.LinkedEntityId = siteBrandingObject.Id;//Add Files parentId
    cDocLink.ShareType = 'V';//V - Viewer permission. C - Collaborator permission. I - Inferred permission.
    cDocLink.Visibility = 'AllUsers';//AllUsers, InternalUsers, SharedUsers
    insert cDocLink;
    Blob b2 = Blob.valueOf('Test Data record');
    ContentVersion cVersion1 = new ContentVersion();
    cVersion1.ContentLocation = 'S'; //S-Document is in Salesforce. E-Document is outside of Salesforce. L-Document is on a Social Netork.
    cVersion1.PathOnClient = 'pageImage.jpeg';//File name with extention
    cVersion1.Origin = 'H';//C-Content Origin. H-Chatter Origin.
    cVersion1.OwnerId = userinfo.getUserId();//Owner of the file
    cVersion1.Title ='pageImage.jpeg';//Name of the file
    cVersion1.VersionData = b2;//File content
    insert cVersion1;
    Id conDocument1 = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cVersion1.Id].ContentDocumentId;
    ContentDocumentLink cDocLink1 = new ContentDocumentLink();
    cDocLink1.ContentDocumentId = conDocument1;//Add ContentDocumentId
    cDocLink1.LinkedEntityId = siteBrandingObject.Id;//Add Files parentId
    cDocLink1.ShareType = 'V';//V - Viewer permission. C - Collaborator permission. I - Inferred permission.
    cDocLink1.Visibility = 'AllUsers';//AllUsers, InternalUsers, SharedUsers
    insert cDocLink1;
    Blob b1 = Blob.valueOf('Test Data record');
    ContentVersion cVersion13 = new ContentVersion();
    cVersion13.ContentLocation = 'S'; //S-Document is in Salesforce. E-Document is outside of Salesforce. L-Document is on a Social Netork.
    cVersion13.PathOnClient = 'productImage.jpeg';//File name with extention
    cVersion13.Origin = 'H';//C-Content Origin. H-Chatter Origin.
    cVersion13.OwnerId = userinfo.getUserId();//Owner of the file
    cVersion13.Title ='productImage.jpeg';//Name of the file
    cVersion13.VersionData = b1;//File content
    insert cVersion13;
    Id conDocument13 = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cVersion13.Id].ContentDocumentId;
    ContentDocumentLink cDocLink13 = new ContentDocumentLink();
    cDocLink13.ContentDocumentId = conDocument13;//Add ContentDocumentId
    cDocLink13.LinkedEntityId = siteBrandingObject.Id;//Add Files parentId
    cDocLink13.ShareType = 'V';//V - Viewer permission. C - Collaborator permission. I - Inferred permission.
    cDocLink13.Visibility = 'AllUsers';//AllUsers, InternalUsers, SharedUsers
    insert cDocLink13;
    }
    return siteBrandingObject;
}

public static esso_Site_Branding__c defaultSiteBranding()
{
    List<Esso_Site_Branding__c> s = [SELECT Id FROM Esso_Site_Branding__c WHERE Referral_Id__c =: esso_Configuration.setting.Branding_Default__c.toLowerCase() ];
    
    if(s.size() == 0)
    {
        //esso_Site_Branding__c brand =SiteBrandingIdentifierTest.createSiteBranding(esso_Configuration.setting.Branding_Default__c, esso_Configuration.setting.Branding_Default__c, esso_Configuration.setting.Branding_Default__c, 'Informa Markets', false);
        esso_Site_Branding__c brand =SiteBrandingIdentifierTest.createSiteBranding(esso_Configuration.setting.Branding_Default__c, 'informa markets Business', 'testbrand', 'Informa Markets', false);
        brand.Default_Landing_Page__c = 'https://www.informa.com';
        insert brand;
        
    }

    Map<string,Esso_Site_Branding__c> siteBrandings = SiteBrandingIdentifier.siteBrandings;

 return siteBrandings.get(esso_Configuration.setting.Branding_Default__c);
}


//private static void securitySettingsSetup(Boolean settingsOn){
//  insert new esso_Application_Security_Settings__c(Enable_Xss_Input_Detection__c = settingsOn, Enable_Return_URL_Whitelist_Check__c = settingsOn, Enable_Xss_Parameter_Detection__c = settingsOn);
//}
}