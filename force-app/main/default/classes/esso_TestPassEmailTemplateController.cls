/**
 * Created/Modified By   :  Shay.spoonmore@informa.com
 * Created On:           :  20200305
 * @description          : [This test class covers the apex class : esso_ChangePasswordTemplateControllerTest]
 * Modification log --
 * Modified By           :
 **/
//Ticket No. BK-14521 Updating API Version


public with sharing class esso_TestPassEmailTemplateController {

    public string ResponseInfo {get; set;}
    
    private System.PageReference ApexPage = null;


public esso_TestPassEmailTemplateController() 
{
    system.debug('Constructor Being Called');//Added by Palla Kishore for the ticket BK-19604
}



public PageReference SendEmail()
{
    ResponseInfo = 'userInfo.getUserType(): ' + userInfo.getUserType() + '; userInfo.getName():' + userInfo.getName() + '; ' + userInfo.getUserId() ;
    ResponseInfo += ';Network.getNetworkId(): '+  Network.getNetworkId() ;
    System.debug('####!DEBUG! ' + ResponseInfo);

    
    // ###Keeping comments to test in test Email template
    //Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
	// mail.setOrgWideEmailAddressId('0D2220000004EYE');
	// mail.setTargetObjectId(userInfo.getUserId());
	// mail.setTemplateId('00X22000000DxkF'); //
	// //mail.setWhatId('00522000001J4PD');
	// mail.setBccSender(false);
	// mail.setUseSignature(false);
	// //mail.setReplyTo('recruiting@acme.com');
	// //mail.setSenderDisplayName('HR Recruiting');
	// mail.setSaveAsActivity(false);
	// Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    

    
    
    return null;
}

}