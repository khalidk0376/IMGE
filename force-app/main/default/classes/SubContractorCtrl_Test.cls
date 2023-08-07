/**
 * Created By        :  Girikon(Pramod)
 * Created On        :  05/28/2018
 * *************************************************************************
 * @description      :  This test class provide code coverage to "SubContractorCtrl" class.
 * *************************************************************************
 * Apex Class Name   :  SubContractorCtrl
 * Methods Covered   :  getSubcontactor(),getCountries(),sDeleteRecord(string sBoothId),sUpdatecon(BoothContractorMapping__c sCon,list<string> lstServices,string AccountName,
                        string Firstname,string LastName,string Email,string Phone,string Country,string ContId,string AccId,string vMapID),sUpdateSubContact (String sMapId),
                        getBoothsMapping(String sEventcode),createContactandMapping(contact con,string sEventId,string tempAccount,list<string> lstServices,Id boothId,string sAccountName,string Country),
                        getServices(String sEventcode),getContartorStatus(),getExhibitorMapbyId(String mapId),getExhibitors(String sEventcode),getEventDetails(String sEventcode)  
 
 * Modification Log----- 
 * Modified by   :  Girikon(Garima) [CCEN-756 April 4 2019]
 * Apex Class        :  SubContractorCtrl (89%)
 **/
@isTest
private class SubContractorCtrl_Test {
   @testSetup
    static void dataSetUp() {
            
        //Create user
        Profile pro = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        User[] userList = new User[]{};
        User u = new User();
        u.FirstName = 'Pramod';
        u.LastName = 'Kumar';
        u.Email = 'test@wexeurope.com';
        u.Username = 'astest@wexeurope.com';
        u.Alias = 'astest';
        u.ProfileId = pro.Id;
        u.TimeZoneSidKey    = 'America/Denver';
        u.LocaleSidKey      = 'en_US';
        u.EmailEncodingKey  = 'UTF-8';
        u.LanguageLocaleKey = 'en_US';
        userList.add(u);
        system.debug('u contains ' + u);
        insert userList;
        
        //Create User_Type__c
        User_Type__c uT = new User_Type__c(Name='Contractor');
        insert uT;
         System.AssertEquals(uT.Name, 'Contractor','Not a Valid Usertype');
        
        //Create Account
        List<Account> accounts = new List<Account>();
        for(Integer i=0;i<3;i++)
        {
            Account a = new Account(Name='TstAccFrst' + i, BillingStreet='testStreet',BillingCity='test', BillingState='Delhi', BillingPostalCode='13245', BillingCountry='India');
            accounts.add(a);    
        }
        insert accounts;
        
        //create some contacts
        List<Contact> contacts = new List<Contact>();
        for(Integer i=0;i<3;i++)
        {
            Contact c = new Contact(AccountId = accounts[i].Id, FirstName = 'TstConFrst'+i, LastName = 'TstConLst1'+i);
            contacts.add(c);    
        }
        insert contacts;
      
        
        //create ExpocadBooth__c
        List<ExpocadBooth__c> lstExpoBooth = new List<ExpocadBooth__c>();
        for(Integer i=0;i<3;i++)
        {
            ExpocadBooth__c eB = new ExpocadBooth__c(Booth_Number__c='TestBoothNo.'+i);
            lstExpoBooth.add(eB);   
        }
        insert lstExpoBooth;
        
        
        List<Opportunity_ExpoCAD_Booth_Mapping__c> lstOppExpoBooth = new List<Opportunity_ExpoCAD_Booth_Mapping__c>();   
        for(Integer i=0;i<3;i++)
        {
            Opportunity_ExpoCAD_Booth_Mapping__c oEB = new Opportunity_ExpoCAD_Booth_Mapping__c(Expocad_Booth__c= lstExpoBooth[i].id);
            lstOppExpoBooth.add(oEB);   
        }
        insert lstOppExpoBooth;
        
        
        //create Event_Edition__c
        List<Event_Edition__c> lstEE = new List<Event_Edition__c>();
        for(Integer i=0;i<3;i++)
        {
            Event_Edition__c eE = new Event_Edition__c(Name='World of Concrete 2017'+i,Event_Code__c='WOC17',End_Date__c=System.Today(),Start_Date__c=System.Today(),Payment_Schedule__c='50-50',X50_Cutoff_Date__c=System.Today(),Cutoff_Date_1__c=System.Today(),Cutoff_Date_2__c=System.Today(),Cutoff_Date_3__c=System.Today());
            lstEE.add(eE);  
        }
        insert lstEE;
        
        //Create ContractorService__c
        ContractorService__c cS = new ContractorService__c(Event_Edition__c=lstEE[0].Id);
        insert cS;
        
        //create TempAccount__c
        List<TempAccount__c> lstTempAcc = new List<TempAccount__c>();
        for(Integer i=0;i<3;i++)
        {
            TempAccount__c tA = new TempAccount__c(Name='TestTC'+i,Address__c='Address'+i,State__c='Delhi',Country__c='India',City__c='test', Zip__c='111111');
            lstTempAcc.add(tA); 
        }
        insert lstTempAcc;
        
        //create TempContact__c
        List<TempContact__c> lstTempCon = new List<TempContact__c>();
        for(Integer i=0;i<3;i++)
        {
            TempContact__c tC = new TempContact__c(FirstName__c='TCFrst'+i,LastName__c='TCLst'+i, Account__c=accounts[i].Id,TempAccount__c=lstTempAcc[i].Id, Phone__c='1234567890',Fax__c='1234567890',Email__c='abc@test.com');
            lstTempCon.add(tC); 
        }
        insert lstTempCon;
        
        //Create Event_Settings__c
        Event_Settings__c evntSttng = new Event_Settings__c(Name='Test',About_Show__c='Test',ShowHours1__c='test',ShowHours2__c='Test',Branding_Color__c='Black',Link_1__c='http://m.www.google.com/',Is_Stand_Design_Visible__c=True,Is_Stand_Detail_Visible__c=True,Is_SubContractors_Visible__c=True,Is_Amount_Visible__c=True,
        Link_2__c='http://m.www.google.com/',Link_3__c='http://m.www.google.com/',Link_4__c='http://m.www.google.com/',Link_1_Label__c='TestLink1',Link_2_Label__c='TestLink2',Link_3_Label__c='TestLink3',Link_4_Label__c='TestLink4',
        FaceBook__c='http://m.www.facebook.com/',LinkedIn__c='http://m.www.linkedin.com/',Twitter__c='http://m.www.Twitter.com/',YouTube__c='http://m.www.youtube.com/',Custom_1_Title__c='CstmTitle',Event_Edition__c=lstEE[0].Id,E_Commerce_Title__c='EC Title',Welcome_Stand_Contractor__c='WSC Test',Disable_this_information__c=True);
        
        insert evntSttng;
        
        //create BoothContractorMapping__c
        List<BoothContractorMapping__c> lstBoothCM = new List<BoothContractorMapping__c>();
        for(Integer i=0;i<3;i++)
        {
            BoothContractorMapping__c bCM = new BoothContractorMapping__c(Approved__c=True, Opp_Booth_Mapping__c=lstOppExpoBooth[0].Id, Contact__c=contacts[i].Id, TempContact__c=lstTempCon[i].Id,Event_Edition__c=lstEE[i].Id, status__c='Pending');
            lstBoothCM.add(bCM);    
        }
        insert lstBoothCM;
        
        //create CustomerContractorService__c
        List<CustomerContractorService__c> lstCstmrConSrvc = new List<CustomerContractorService__c>();
        for(Integer i=0;i<3;i++)
        {
            CustomerContractorService__c cCS = new CustomerContractorService__c(BoothContractorMapping__c=lstBoothCM[i].Id,ContractorService__c=cS.Id,Event_Edition__c=lstEE[i].Id);
            lstCstmrConSrvc.add(cCS);   
        }
        insert lstCstmrConSrvc;  
    }
    
    @isTest static void validateMethods() 
    {
        string srchString='Tst';
        list<Event_Edition__c> lstEE=[SELECT Id, Name, Event_Code__c from Event_Edition__c LIMIT 1];
        System.assertNotEquals(null, lstEE,'Event Edition not equal null');
        string evntCode=lstEE[0].Event_Code__c;
        SubContractorCtrl.getEventDetails(evntCode);
        SubContractorCtrl.getExhibitors('test');
        list<BoothContractorMapping__c> lstBCM=[SELECT Id FROM BoothContractorMapping__c];
        string bCMIdStrng=string.valueOf(lstBCM[0].Id);
        SubContractorCtrl.getExhibitorMapbyId(bCMIdStrng);
        SubContractorCtrl.getContartorStatus(); 
        SubContractorCtrl.getServices(evntCode);
        SubContractorCtrl.getBoothsMapping(evntCode);
        SubContractorCtrl.getSubContractor (bCMIdStrng);
        
        SubContractorCtrl.getCountries();
        SubContractorCtrl.getSubcontactor(evntCode,bCMIdStrng);
    }
     @isTest static void validateCreateContactandMapping()
    {
        list<contact> lstCon=[SELECT Id, FirstName, LastName,Email from contact limit 1];
        System.assertNotEquals(null, lstCon,'contact not equal null');
        contact objCon=lstCon[0];
        
        list<TempContact__c> lsttempContact= [SELECT Id, Name__c, Phone__c, FirstName__c, LastName__c, Email__c FROM TempContact__c limit 1];
        string tempConId=lsttempContact[0].Id;
        string firstName=lsttempContact[0].FirstName__c;
        string lastName=lsttempContact[0].LastName__c;
        string email=lsttempContact[0].Email__c;
        string phone=lsttempContact[0].Phone__c;
        
        //string SrchString='test';
        list<Event_Edition__c> lstEE=[SELECT Id, Name, Event_Code__c from Event_Edition__c LIMIT 1];
        string evntId=string.valueOf(lstEE[0].id);
        
        
        list<TempAccount__c> lstTmpAcc=[SELECT Id, Name,Country__c from TempAccount__c LIMIT 1];
        string tempId=string.valueOf(lstTmpAcc[0].Id);
        string tempName=string.valueOf(lstTmpAcc[0].Name);
        string tempCountry=string.valueOf(lstTmpAcc[0].Country__c);
        List<BoothContractorMapping__c> lstEBooth =[SELECT Id , Opp_Booth_Mapping__c from BoothContractorMapping__c LIMIT 1];
        Id boothId=lstEBooth[0].Opp_Booth_Mapping__c;
        //list<string> lstEBoothId = new list<string>();
        //for(ExpocadBooth__c eB: lstEBooth)
        //{
            //lstEBoothId.add(string.valueOf(eB.id));
        //}
        list<ContractorService__c> lstCS=[SELECT Id from ContractorService__c];
        list<string> lstCsIDS=new list<string>();
        for(ContractorService__c cS: lstCS)
        {
            lstCsIDS.add(string.valueOf(cS.Id));            
        }


        BoothContractorMapping__c objBooth= [SELECT Id FROM BoothContractorMapping__c limit 1];
        system.debug(objCon+ '##'+evntId+ '##'+tempId+ '##'+lstCsIDS+ '##'+boothId+ '##'+tempName+ '##'+tempCountry);
        Contact obj=new Contact(FirstName = 'TstConFrst', LastName = 'TstConLst1');
        SubContractorCtrl.createSubConMapping(obj,evntId,tempId,lstCsIDS,boothId,tempName,tempCountry);
        SubContractorCtrl.createSubConMapping(objCon,evntId,tempId,lstCsIDS,boothId,tempName,tempCountry);
        SubContractorCtrl.updateContact(lstCsIDS, tempName, firstName, lastName, email, phone, tempCountry, tempConId, tempId, '');
        SubContractorCtrl.sDeleteRecord(objBooth.id);
        //SubContractorCtrl.sUpdatecon(list<string> lstServices,string AccountName,string Firstname,string LastName,string Email,string Phone,string Country,string ContId,string AccId,string vMapID);
    }
    
}