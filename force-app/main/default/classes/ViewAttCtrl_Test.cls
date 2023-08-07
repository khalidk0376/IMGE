/*Created By: {Girikon(Pramod)}
Created On: 09/14/2018
@ description/Purpose: [CCEN-695] Code Covrage to Class [ViewAttCtrl]
Apex Class: ViewAttCtrl (78%)
*/

@isTest
private class ViewAttCtrl_Test 
{    
    @isTest static void testmethodone() 
    {
        // Implement test code
        account acc = new account(Name='TestLName');
        Test.startTest();
        insert acc;
        system.assertNotEquals(null, acc.id,'Account not equal null');

        ViewAttCtrl obj =  new ViewAttCtrl();
        Test.stopTest();
        /*

        Blob b3 = Blob.valueOf('Test Data record');
        ContentVersion cVersion = new ContentVersion();
        cVersion.ContentLocation = 'S'; //S-Document is in Salesforce. E-Document is outside of Salesforce. L-Document is on a Social Netork.
        cVersion.PathOnClient = 'Completed Test Signed Files for Parent Manual.pdf';//File name with extention
        cVersion.Origin = 'H';//C-Content Origin. H-Chatter Origin.
        cVersion.OwnerId = userinfo.getUserId();//Owner of the file
        cVersion.Title ='Completed Test Signed Files for Parent Manual';//Name of the file
        cVersion.VersionData = b3;//File content
        insert cVersion;
        Id conDocument = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cVersion.Id].ContentDocumentId;
        ContentDocumentLink cDocLink = new ContentDocumentLink();
        cDocLink.ContentDocumentId = conDocument;//Add ContentDocumentId
        cDocLink.LinkedEntityId = acc.Id;//Add Files parentId
        cDocLink.ShareType = 'V';//V - Viewer permission. C - Collaborator permission. I - Inferred permission.
        cDocLink.Visibility = 'AllUsers';//AllUsers, InternalUsers, SharedUsers
        insert cDocLink;
        Test.startTest();
        string encrptCode = UtilityMethods.Encrypt_aes256(conDocument);
        ApexPages.currentPage().getParameters().put('file',conDocument);
        
        ViewAttCtrl obj =  new ViewAttCtrl();
        Test.stopTest();
        */
    }    
}