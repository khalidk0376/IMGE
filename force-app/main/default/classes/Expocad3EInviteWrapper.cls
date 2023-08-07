/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 07-27-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public class Expocad3EInviteWrapper{
    public String message;	
    public cls_errors[] errors;
    class cls_errors {
        public String email;	
        public String customerId;	
        public String reason;	
    }
    public static Expocad3EInviteWrapper parse(String json){
        return (Expocad3EInviteWrapper) System.JSON.deserialize(json, Expocad3EInviteWrapper.class);
        }
}