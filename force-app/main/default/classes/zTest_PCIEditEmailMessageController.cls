/************************************************************************** 
** 
** Modified by Hailey Niemand - 31/10/2019 - Amendments of P1 SCA violations Hardcoded Ids
**   
***************************************************************************/ 
@isTest
private class zTest_PCIEditEmailMessageController {
    
    static PCI_Scanner__c psSetting =new PCI_Scanner__c();
    //static User testUser =insertUser();
    
    @testSetup static void Settings() 
    {
        CreateApplicationBypass();
        psSetting =CreatePCISetting();    
    }
    
    static testMethod void PCI_EmailMessage() 
    {
        CaseComment cc= [SELECT Id,ParentId FROM CaseComment where Id =:CreateCaseComment() LIMIT 1];
        system.debug('####CASE():' + cc.ParentId);
        // line 188 & 189
        EmailMessage insertEmailMessage = new EmailMessage
            (
                ToAddress = 'PCI.Test@test.com', 
                TextBody = 'PCI TEST', 
                Subject = 'PCI TEST',
                ParentId = cc.ParentId, 
                //Incoming, 
                HtmlBody = '<HTML>PCI TEST</HTML>',
                FromName = 'PCI.FromTest@test.com', 
                FromAddress = 'PCI.FromTest@test.com'           
            );
        
        insert insertEmailMessage;
        system.debug('####EmailMessag():' + insertEmailMessage.Id);
        
        PCI_Credit_Card_Numbers__c pciCCN1 = new PCI_Credit_Card_Numbers__c
            (
                CCN_Last_4_Digits__c  = '0140'
                , CCN_Length__c =13
                , CCN_Type__c = 'Unknown'
                , CNN_Match_Length__c=true
                , CNN_Match_Luhn__c=true
                , Object_Name__c = 'EmailMessage'
                , Field_Name__c='TextBody'
                , Field_Value__c='#########0140'
                , Record_Action__c = 'Pending'
                , Record_Group__c = null
                , Record_Id__c = insertEmailMessage.Id
                , System_CCN_Id__c = 'EmailMessage1'
                , System_Scan_Id__c = 'em190'
                
            );
        insert pciCCN1;
        system.debug('####pciCCN1:' + pciCCN1.Id);
        
        PCI_Credit_Card_Numbers__c pciCCN2 = new PCI_Credit_Card_Numbers__c
            (
                CCN_Last_4_Digits__c  = '0140'
                , CCN_Length__c =13
                , CCN_Type__c = 'Unknown'
                , CNN_Match_Length__c=true
                , CNN_Match_Luhn__c=true
                , Object_Name__c = 'EmailMessage'
                , Field_Name__c='HtmlBody'
                , Field_Value__c='#########0140'
                , Record_Action__c = 'Pending'
                , Record_Group__c = null
                , Record_Id__c = insertEmailMessage.Id
                , System_CCN_Id__c = 'EmailMessage2'
                , System_Scan_Id__c = 'em189'
            );
        insert pciCCN2;
        
        system.debug('####pciCCN2:' + pciCCN2.Id);
        
        Test.startTest();
        //Test blank id
        PageReference pref = new PageReference('/apex/PCI_Edit_Email_Message');
        Test.setCurrentPage(pref);
        //Test blank PCI Id
        pref = new PageReference('/apex/PCI_Edit_Email_Message?Id=' + insertEmailMessage.Id);
        Test.setCurrentPage(pref);
        //Test a fieldName
        pref = new PageReference('/apex/PCI_Edit_Email_Message?Id=' + insertEmailMessage.Id + '&PCIID='+ pciCCN1.Id + '&FieldName='+ pciCCN1.Field_Name__c);
        Test.setCurrentPage(pref);
        PCIEditEmailMessageController editEmail= new PCIEditEmailMessageController();
        pref = editEmail.save();
        
        PCI_Credit_Card_Numbers__c getNewEmailId = [Select Id, Record_Id__c FROM PCI_Credit_Card_Numbers__c WHERE Id=:pciCCN2.Id];
        system.debug('####getNewEmailId.Record_Id__c:' + getNewEmailId.Record_Id__c);
        //Test all fieldName
        pref =  pref = new PageReference('/apex/PCI_Edit_Email_Message?Id=' + getNewEmailId.Record_Id__c + '&PCIID='+ pciCCN2.Id + '&FieldName='+ pciCCN2.Field_Name__c);
        Test.setCurrentPage(pref);
        editEmail= new PCIEditEmailMessageController();
        pref = editEmail.save();
        
        getNewEmailId = [Select Id, Record_Id__c FROM PCI_Credit_Card_Numbers__c WHERE Id=:pciCCN2.Id];
        system.debug('####getNewEmailId.Record_Id__c:' + getNewEmailId.Record_Id__c);
        //Test cancel
        pref = pref = new PageReference('/apex/PCI_Edit_Email_Message?Id=' + getNewEmailId.Record_Id__c + '&PCIID='+ pciCCN2.Id + '&FieldName='+ pciCCN2.Field_Name__c);
        Test.setCurrentPage(pref);
        editEmail= new PCIEditEmailMessageController();
        pref = editEmail.cancel();

        // Instantiate a new controller with all parameters in the page
        editEmail= new PCIEditEmailMessageController();
        editEmail.em = [Select e.ToAddress, e.TextBody, e.SystemModstamp, e.Subject, e.Status, e.ReplyToEmailMessageId, e.ParentId, e.MessageDate, e.LastModifiedDate, e.LastModifiedById, e.IsDeleted, e.Incoming, e.Id, e.HtmlBody, e.Headers, e.HasAttachment, e.FromName, e.FromAddress, e.CreatedDate, e.CreatedById, e.CcAddress, e.BccAddress, e.ActivityId From EmailMessage e Where e.Id = :getNewEmailId.Record_Id__c];
        editEmail.showHTML=true;
        editEmail.showControllers=true;
        editEmail.Id='';
        editEmail.pciId='';
        editEmail.fieldName='';
        editEmail.isValidId();
        Test.stopTest();
        
        System.AssertEquals('EmailMessage',pciCCN2.Object_Name__c,'test');
    }
    
    private static String CreateCaseComment(){
        
        Case c = new Case();
        c.Description= 'PCI Test ';
        c.Subject = 'PCI Test ';
        
        insert c;
        CaseComment cc = new CaseComment(
            CommentBody = 'PCI Test '
            , ParentId = c.id
        );
        insert cc;
        
        return cc.id;
    }
    
    public static PCI_Scanner__c CreatePCISetting(){

        user u =insertUser();
        Id orgWideEmailAddressId = [SELECT Id FROM OrgWideEmailAddress WHERE Address = 'do_not_reply.sfdc@informausa.com'].Id;
        PCI_Scanner__c pcSetting = new PCI_Scanner__c(Name='PCI Defaults',Default_Ownership_Name__c='Test Default',Default_User_Queue__c=u.Id,
                                                      Error_Emails__c='do_not_reply.sfdc@informausa.com',Org_Wide_Email_Id__c=orgWideEmailAddressId);
        Insert pcSetting;
        return pcSetting;                                    
    }
    
    public static User insertUser(){
        
        Organization o = [SELECT Country,Id,InstanceName,IsSandbox,Name,State FROM Organization limit 1]; 
        User u = new User(alias='test', email='test@example.com', firstname='Testing',
                          emailencodingkey='UTF-8', lastname='Testing', languagelocalekey=Userinfo.getLanguage(), 
                          localesidkey=Userinfo.getLocale(), country=o.Country,
                          timezonesidkey=Userinfo.getTimeZone().getID(),
                          username='test@example.com.informaplc' + system.now().second() + system.now().millisecond() + math.random(),
                          profileid=system.UserInfo.getProfileId() //System Administrator
                         // ,Active_Directory_Username__c='testinguser1' + system.now().second() + system.now().millisecond(),Active_Directory_OU__c='ukcorplan'
                          );
        insert u;    
        return u;
    }
    
    public static void CreateApplicationBypass()
    {
        //Bypass Validation Rules
        List<Application_Bypass__c> applicationBypass =[Select Id,Bypass_Validation_Rules__c,SetupOwnerId from Application_Bypass__c WHERE SetupOwnerId=:UserInfo.getUserId()];
        if(applicationBypass.size() == 0)
        {
            applicationBypass.add(new Application_Bypass__c(Bypass_Validation_Rules__c=true,SetupOwnerId=UserInfo.getUserId()));
            insert applicationBypass;
        }                                     
    }
}