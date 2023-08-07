/*
* Project:             GAP
* Date:                Dec 4, 2018
* Created By:          Avinash Shukla
* Test Class For:      AccountLtnCtrl.cls.
* Code Coverage:       89%
* *************************************************************************
* Description:         Test class for AccountLtnCtrl.
* *************************************************************************
* History:             BSM-371 Modified by - Garima Gupta Date - 17/11/2020
*/
@isTest
private class AccountLtnCtrl_Test {
    private class AddressAutoComplete implements HTTPCalloutMock{
        /**
        * @description mock class for address responses
        * @param  req
        * @return  res
        */
        public HTTPResponse respond(HTTPRequest req){
            HttpResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/JSON');
            res.setBody('{predictions : [{description : Girikon - Salesforce Consulting, North Tatum Boulevard, Phoenix, AZ, USA,id : 36f85aab59c54f4d93f3dd5ee5c76ec30837fb55,matched_substrings : [{length : 7,offset : 0}],place_id : ChIJe2Fsc5YNK4cRsyMLNVZi0Po,reference : ChIJe2Fsc5YNK4cRsyMLNVZi0Po,structured_formatting : {main_text : Girikon - Salesforce Consulting,main_text_matched_substrings : [{length : 7,offset : 0}],secondary_text : North Tatum Boulevard, Phoenix, AZ, USA},terms : [{offset : 0,value : Girikon - Salesforce Consulting},{offset : 33,value : North Tatum Boulevard},{offset : 56,value : Phoenix},{offset : 65,value : AZ},{offset : 69,value : USA}],types : [ establishment ]},{description : Girikon USA, South 48th Street, Tempe, AZ, USA,id : 35c9ef1cb6700c0754f5e9c46d79e83ae906841f,matched_substrings : [{length : 7,offset : 0}],place_id : ChIJwXcapeAOK4cR1jC6B-hR7nk,reference : ChIJwXcapeAOK4cR1jC6B-hR7nk,structured_formatting : {main_text : Girikon USA,main_text_matched_substrings : [{length : 7,offset : 0}],secondary_text : South 48th Street, Tempe, AZ, USA},terms : [{offset : 0,value : Girikon USA},{offset : 13,value : South 48th Street},{offset : 32,value : Tempe},{offset : 39,value : AZ},{offset : 43,value : USA}],types : [ establishment ]},{description : Kirkenes, Norway,id : c5273ef6d456f35e6cc08dd7bc856f0f96fdac9b,matched_substrings : [{length : 8,offset : 0}],place_id : ChIJD0qdGM5Iy0URrY07tVlYRyE,reference : ChIJD0qdGM5Iy0URrY07tVlYRyE,structured_formatting : {main_text : Kirkenes,main_text_matched_substrings : [{length : 8,offset : 0}],secondary_text : Norway},terms : [{offset : 0,value : Kirkenes},{offset : 10,value : Norway}],types : [ locality, political, geocode ]},{description : Girkonjárgohppi, Russenes, Norway,id : 270ddcbe7b7058d4c1f5adb4f92973e926b77d2d,matched_substrings : [{length : 6,offset : 0}],place_id : ChIJPSiTnk8kyUURXQOhSFZjmyg,reference : ChIJPSiTnk8kyUURXQOhSFZjmyg,structured_formatting : {main_text : Girkonjárgohppi,main_text_matched_substrings : [{length : 6,offset : 0}],secondary_text : Russenes, Norway},terms : [{offset : 0,value : Girkonjárgohppi},{offset : 17,value : Russenes},{offset : 27,value : Norway}],types : [ natural_feature, establishment, geocode ]},{description : Girkonuorri, Tana, Norway,id : 9a66fe5ad1ca6c2a1cf8a0e1ea9c6daebc1738b5,matched_substrings : [{length : 6,offset : 0}],place_id : ChIJ0_VBaMeWy0UReKPpORLIbag,reference : ChIJ0_VBaMeWy0UReKPpORLIbag,structured_formatting : {main_text : Girkonuorri,main_text_matched_substrings : [{length : 6,offset : 0}],secondary_text : Tana, Norway},terms : [{offset : 0,value : Girkonuorri},{offset : 13,value : Tana},{offset : 19,value : Norway}],types : [ natural_feature, establishment, geocode ]}],status : OK}');
            res.setStatusCode(200);
            return res;
        }
    }

    static testMethod void testAllMethods() {
        Account ac = new Account(Name = 'Test Account');
        insert ac;
        
        AccountTeamMember act = new AccountTeamMember();
        act.AccountId = ac.Id;
        act.UserId = UserInfo.getUserId();
        act.TeamMemberRole = 'Default Team';
        act.AccountAccessLevel = 'Edit';
        act.OpportunityAccessLevel = 'None';
        act.CaseAccessLevel = 'None';
        insert act;
        System.AssertEquals(act.CaseAccessLevel,'None','Wrong Case Access level');
        String response='';
        AccountLtnCtrl.getAcDetail(ac.Id);
        AccountLtnCtrl.getCurrentUserDtls();
        AccountLtnCtrl.getaccTranslatedDetail(ac.Id);
        AccountLtnCtrl.getUserRecordAccess(ac.Id);
        AccountLtnCtrl.AccountTeams(ac.Id,0);
        AccountLtnCtrl.addNewTeam(ac.Id);
        AccountLtnCtrl.getAccountAssociation(ac.Id,0);
        AccountLtnCtrl.getAssets(ac.Id);
        AccountLtnCtrl.getBpNumberRecords(ac.Id);
        AccountLtnCtrl.getNatureOfBusiness(ac.Id);
        AccountLtnCtrl.getQuotes(ac.Id,0);
        AccountLtnCtrl.getInterestLevelMappings(ac.Id);
        AccountLtnCtrl.getaccountPartner(ac.Id,0);
        AccountLtnCtrl.deleteAcTeam(act.Id);
        AccountLtnCtrl.getAccountPicklist();
        AccountLtnCtrl.getRecordType(ac.Id);
        AccountLtnCtrl.isAMember(act.Id);
        Map<String,Google_Place_Api_Field_Mapping__mdt> data = AccountLtnCtrl.getGoogleApiMetaData(); // BSM-371
        System.AssertNotEquals(null,data,'data not retrived.'); // BSM-371
        AccountLtnCtrl.Wrap_CL reqParam = new AccountLtnCtrl.Wrap_CL();
        Test.startTest();       
        Test.setMock(HttpCalloutMock.class, new AddressAutoComplete());
        reqParam.searchKey='girikon';
        response = AccountLtnCtrl.getAddressAutoComplete(JSON.serialize(reqParam));
        reqParam.placeId = 'asdasdda';
        response = AccountLtnCtrl.getAddressDetails(JSON.serialize(reqParam));
        Test.stopTest();
        
    }
}