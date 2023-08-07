/*
Created By		: Girikon(Sunil[STL-53])
Created On		: August 14 2019
@description 	: This class is test class for OPS_WelcomeEmailCtrl.
Test Class		: 

Modification log ------
Modified By		: 
*/

@IsTest
public class OPS_WelcomeEmailCtrl_Test {
	@IsTest static void getTest() {
        Event_Edition__c eventEdition = new Event_Edition__c(Name = 'test eventEdition',Event_Code__c = 'test code');
        insert eventEdition;
        
        Event_Settings__c eventSetting = new Event_Settings__c(Name = 'test eventSetting', Event_Edition__c = eventEdition.id);
        insert eventSetting;
        
        String settingJson1 = '{"EventId":"'+eventEdition.Id+'","boxType1Value":"<p>Exhibior 1 2</p>","boxType2Value":"<p>2</p>","selectedTab":"Exhibitor"}';
        String settingJson2 = '{"EventId":"'+eventEdition.Id+'","boxType1Value":"<p>Exhibior 1 2</p>","boxType2Value":"<p>2</p>","selectedTab":"Stand Contractor"}';
        String settingJson3 = '{"EventId":"'+eventEdition.Id+'","boxType1Value":"<p>Exhibior 1 2</p>","boxType2Value":"<p>2</p>","selectedTab":"Agent"}';
        String settingJson4 = '{"EventId":"'+eventEdition.Id+'","boxType1Value":"<p>Exhibior 1 2</p>","boxType2Value":"<p>2</p>","selectedTab":"Co-Exhibitor"}';
        String settingJson5 = '{"EventId":"'+eventEdition.Id+'","boxType1Value":"<p>Exhibior 1 2</p>","boxType2Value":"<p>2</p>","selectedTab":"Contractor"}';
        
        string base64='UHJvZHVjdF9vcl9CdW5kbGVfTmFtZSxQcm9kdWN0c19pbl9CdW5kbGUsUHJvZHVjdF9EZXNjcmlwdGlvbixQcm9kdWN0X0xpc3RfUHJpY2UsUHJvZHVjdF9DdXJyZW5jeSxQcm9kdWN0X0Nvc3QsUHJvZHVjdF9Db3N0X0N1cnJlbmN5LFByb2R1Y3RfaW5fQnVuZGxlX1F1YW50aXR5LFByb2R1Y3RfRmFtaWx5DQpQMSwsVGhpcyBpcyBQcm9kdWN0IERlc2NyaXB0aW9uLDI1MCxVU0QsNjAsVVNELCxCdW5kbGUgUHJvZHVjdA0KLFAyLFRoaXMgaXMgUHJvZHVjdCBEZXNjcmlwdGlvbiwxMDAsVVNELDIwLFVTRCwxLFNwZXgNCixTb21ldGhpbmcgUGFzcyxUaGlzIGlzIFByb2R1Y3QgRGVzY3JpcHRpb24sMTAwLFVTRCwyMCxVU0QsMTAsUGFzcw0KLFA0LFRoaXMgaXMgUHJvZHVjdCBEZXNjcmlwdGlvbiwxMDAsVVNELDIwLFVTRCwxLFNwZXgNCixQNSxUaGlzIGlzIFByb2R1Y3QgRGVzY3JpcHRpb24sMCxVU0QsMCxVU0QsMSxTcGV4DQpQMTAsLFRoaXMgaXMgUHJvZHVjdCBEZXNjcmlwdGlvbiwyNTAsVVNELDYwLFVTRCwsU3BleA0KUDYsLFRoaXMgaXMgUHJvZHVjdCBEZXNjcmlwdGlvbiwyNTAsVVNELDYwLFVTRCwsQnVuZGxlIFByb2R1Y3QNCixQNyxUaGlzIGlzIFByb2R1Y3QgRGVzY3JpcHRpb24sMTAwLFVTRCwyMCxVU0QsMSxTcGV4DQosU29tZXRoaW5nIE90aGVyIFBhc3MsVGhpcyBpcyBQcm9kdWN0IERlc2NyaXB0aW9uLDEwMCxVU0QsMjAsVVNELDEwLFBhc3MNCixQOCxUaGlzIGlzIFByb2R1Y3QgRGVzY3JpcHRpb24sMTAwLFVTRCwyMCxVU0QsMSxTcGV4DQosUDksVGhpcyBpcyBQcm9kdWN0IERlc2NyaXB0aW9uLDAsVVNELDAsVVNELDEsU3BleA0KUDExLCxUaGlzIGlzIFByb2R1Y3QgRGVzY3JpcHRpb24sMjUwLFVTRCw2MCxVU0QsLFNwZXgNClAxMiwsVGhpcyBpcyBQcm9kdWN0IERlc2NyaXB0aW9uLDI1MCxVU0QsNjAsVVNELCxTcGV4DQpQMTMsLFRoaXMgaXMgUHJvZHVjdCBEZXNjcmlwdGlvbiwyNTAsVVNELDYwLFVTRCwsQnVuZGxlIFByb2R1Y3QNCixQMTQsVGhpcyBpcyBQcm9kdWN0IERlc2NyaXB0aW9uLDEwMCxVU0QsMjAsVVNELDEsU3BleA0KLFNvbWV0aGluZyBPdGhlciBQYXNzLFRoaXMgaXMgUHJvZHVjdCBEZXNjcmlwdGlvbiwxMDAsVVNELDIwLFVTRCwxMCxQYXNzDQosUDIsVGhpcyBpcyBQcm9kdWN0IERlc2NyaXB0aW9uLDEwMCxVU0QsMjAsVVNELDEsU3BleA0KLEdvbGQgU3BvbnNvcixUaGlzIGlzIFByb2R1Y3QgRGVzY3JpcHRpb24sMTAxLFVTRCwyMSxVU0QsMixTcGV4DQo%3D';
        String nullSettingId;
        Test.startTest();
        OPS_WelcomeEmailCtrl.EventEditionSettingWrap testWrap = OPS_WelcomeEmailCtrl.getEventEditionSetting(eventEdition.Id);
        system.assertEquals('test eventEdition', testWrap.eventEdition.Name,'true');
        Boolean saveSettingReturn = OPS_WelcomeEmailCtrl.saveEventSetting(settingJson1);
        system.assertEquals(true,saveSettingReturn,'true');
        OPS_WelcomeEmailCtrl.saveEventSetting(settingJson2);
        OPS_WelcomeEmailCtrl.saveEventSetting(settingJson3);
        OPS_WelcomeEmailCtrl.saveEventSetting(settingJson4);
        OPS_WelcomeEmailCtrl.saveEventSetting(settingJson5);
        String attachmentId='';
        attachmentId=OPS_WelcomeEmailCtrl.saveFile(eventSetting.Id,'Test File',base64, eventEdition.Id); 
        OPS_WelcomeEmailCtrl.saveFile(nullSettingId,'Test File',base64, eventEdition.Id); 
        Boolean deleteImageReturn=OPS_WelcomeEmailCtrl.deleteImage(eventSetting.Id);
        system.assertEquals(true,deleteImageReturn,'true');
        OPS_WelcomeEmailCtrl.sendWelcomeEmailPreview('Exhibitor',eventEdition.Id);
        OPS_WelcomeEmailCtrl.sendWelcomeEmailPreview('StandContractor',eventEdition.Id);
        OPS_WelcomeEmailCtrl.sendWelcomeEmailPreview('Co-Exhibitor',eventEdition.Id);
        OPS_WelcomeEmailCtrl.sendWelcomeEmailPreview('Agent',eventEdition.Id);
        OPS_WelcomeEmailCtrl.sendWelcomeEmailPreview('Contractor',eventEdition.Id);
        Boolean attahDocumentReturn=OPS_WelcomeEmailCtrl.attachDocument(attachmentId, eventSetting.Id);
        system.assertEquals(true,attahDocumentReturn,'true');
        Test.stopTest();
    }
}