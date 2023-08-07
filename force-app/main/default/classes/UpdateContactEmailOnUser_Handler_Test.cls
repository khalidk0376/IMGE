/**
* Created/Modified By: Girikon(Prashant)
* Created On:          12/03/2018
* Apex Class: TriggerInterface_Con(100%), Trigger_Con(96%), UpdateContactEmailOnUser(100%), UpdateContactEmailOnUser_Handler(100%)
* Modified By: Himanshu Jasuja[BK - 3676] - 96%, [Aishwarya 14 Aug 2020 BK-3751]
**/
@isTest
public class UpdateContactEmailOnUser_Handler_Test {
 
    @isTest
    public static void contactDataSetup()
    {
        //Data Setup
        Account oAccount = new Account(Name = 'Expocad Account', CurrencyIsoCode = 'USD', Phone = '2423122323');
        insert oAccount;
        System.assertNotEquals(null,oAccount.Name,'Account Name should not be null');
        
        Contact oCon = new Contact(LastName = 'ContTest1', Email = 'test1contact@duptest.com', AccountId = oAccount.Id, MailingStreet = 'Test', MailingCity = 'Test', MailingState='', MailingCountry='India', MailingPostalCode = 'MailingPostalCode', Phone = '2423122323', AssistantPhone = '2423122323', HomePhone = '2121212121', MobilePhone = '2121212145', OtherPhone = '2154215421');
        insert oCon;
        //BK - 3676
        System.assertNotEquals(null,oCon.LastName ,'Contact LastName should not be null');
       
        User usr = new User(); 
        Profile pro = UtilityMethods.getProfileid();
        usr.FirstName = 'Alex';
        usr.LastName = 'Sherwood';
        usr.Email =oCon.Email;
        usr.Username = 'astest@wexeurope.com';
        usr.Alias = 'astest';
        usr.ProfileId = pro.Id;
        usr.TimeZoneSidKey    = 'America/Denver';
        usr.LocaleSidKey      = 'en_US';
        usr.EmailEncodingKey  = 'UTF-8';
        usr.LanguageLocaleKey = 'en_US';
        usr.ContactId = oCon.Id;
        insert usr;        
        //End
        
        Profile prf = [Select Id FROM Profile where Name ='System Administrator'];
        
        User usrAdmin = new User(); 
        usrAdmin.FirstName = 'Jack';
        usrAdmin.LastName = 'Paro';
        usrAdmin.Email ='jackparo11@gmail.com';
        usrAdmin.Username = 'jackparo11@gmail.com';
        usrAdmin.Alias = 'pjack';
        usrAdmin.ProfileId = prf.Id;
        usrAdmin.TimeZoneSidKey    = 'America/Denver';
        usrAdmin.LocaleSidKey      = 'en_US';
        usrAdmin.EmailEncodingKey  = 'UTF-8';
        usrAdmin.LanguageLocaleKey = 'en_US';
        insert usrAdmin; 
        
        //Call contact trigger interface
        TriggerInterface_Con obj=new TriggerInterface_Con();
        
        //Call trigger app handler
        TriggerInterfaceHelper.runTrigger('UpdateContactEmailOnUser','Contact',99, 'au,bu', null,null,'All');
        
        //Create scenario to execute after update trigger on contact
        System.runAs(usrAdmin) 
        {
            oCon.Email='astest@wexeurope.com';
            oCon.LastName = 'Con22';
            oCon.MailingCity = 'Noida';
            oCon.MailingCountry ='India';
            oCon.MailingStreet ='Girikon';
            oCon.MailingState ='Uttar Pradesh';
            oCon.MailingPostalCode = '201303';
            update oCon;
        }
    }
}