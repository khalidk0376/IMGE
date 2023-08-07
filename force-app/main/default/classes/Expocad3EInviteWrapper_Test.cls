@isTest
public with sharing class Expocad3EInviteWrapper_Test {

    @isTest
    static void testInviteWrapper(){
        //Expocad3EInviteWrapper inviteWrapper = new Expocad3EInviteWrapper();
        String json = '{"message": "The following invitation failed","errors": [{"email": "test@girikon.com", "customerId": "ACCT-005774", "reason": "CustoemrId not found in event" } ] }';
        Expocad3EInviteWrapper inviteWrapper = Expocad3EInviteWrapper.parse(json);
        System.assertNotEquals(inviteWrapper,Null,'Body not Found');//EX-101

    }

}