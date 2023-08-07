/**
 * Created By   :  Girikon(Sunil)
 * Created On   :  05/15/2018
 * @description : This test class provide code coverage to "MyExhibitorsCtrl" class.
 * Apex Class   : MyExhibitorsCtrl(84%)
 * Modification Log----- 
 * Modified by  : Girikon(Ashish)[CCEN-432 (Dec 5 2018)]
 * Modified On  : 12/05/2018
**/
    @isTest
    private class MyExhibitorsCtrl_Test
    {
        @testSetup
        static void dataSetUp() 
        {   
            //Create user
            Profile pro = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];

            User[] userList = new User[]{};
            User u = new User();

            u.FirstName = 'Alex';
            u.LastName = 'Sherwood';
            u.Email = 'test@wexeurope.com';
            u.Username = 'astest@wexeurope.com';
            u.Alias = 'astest';
            u.ProfileId = pro.Id;
            u.TimeZoneSidKey    = 'America/Denver';
            u.LocaleSidKey      = 'en_US';
            u.EmailEncodingKey  = 'UTF-8';
            u.LanguageLocaleKey = 'en_US';
            userList.add(u);


            Pricebook2 customPB = new Pricebook2(Name='ICRE', isActive=true);
            insert customPB;
            
            Id pricebookId = Test.getStandardPricebookId();
                
            //Create User_Type__c
            User_Type__c uT = new User_Type__c(Name='Stand Contractor');
            insert uT;
            
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
                Contact c = new Contact(AccountId = accounts[i].Id, FirstName = 'TstConFrst'+i, LastName = 'TstConLst1'+i, MobilePhone = '2121212145');
                contacts.add(c);    
            }
            insert contacts;
            
            string commUsrProfile='';
            //Fetch community user profile from label
            If(Label.Community_User_Profile!= NULL)
            {
                commUsrProfile= Label.Community_User_Profile;
            }  
            else
            {
                commUsrProfile='Customer Community Login User Custom';
            }  
            //Fetch community user profile
            list<Profile> comprofile =[select id , Name from Profile Where Name =:commUsrProfile];
            userList[0].profileid=comprofile[0].Id;
            userList[0].contactid=contacts[0].Id;
            //
            insert userList;
            
            //create Event_Edition__c
            List<Event_Edition__c> lstEE = new List<Event_Edition__c>();
            for(Integer i=0;i<3;i++)
            {
                Event_Edition__c eE = new Event_Edition__c(Name='World of Concrete 2017'+i,Event_Price_Book__c=customPB.Id,Price_Rule_object_Name__c='TOC__c',Event_Code__c='WOC17',End_Date__c=System.Today(),Start_Date__c=System.Today(),Payment_Schedule__c='50-50',X50_Cutoff_Date__c=System.Today(),Cutoff_Date_1__c=System.Today(),Cutoff_Date_2__c=System.Today(),Cutoff_Date_3__c=System.Today());
                lstEE.add(eE);   
            }
            insert lstEE;
            
            Opportunity oOpportunity = new Opportunity( Name = 'Expocad Opportunity', CloseDate = Date.today().addDays(7), StageName = 'Discover', EventEdition__c = lstEE[0].Id, AccountId = accounts[0].Id,  Payment_Status__c='Not Paid' );
            insert oOpportunity;
            
            oOpportunity.StageName = 'Closed Won';
            oOpportunity.Operations_Contact__c = contacts[1].Id; 
            update oOpportunity;
            System.AssertNotEquals(oOpportunity, null,'Opportunity is not null');
            
            //create ExpocadBooth__c
            List<ExpocadBooth__c> lstExpoBooth = new List<ExpocadBooth__c>();
            for(Integer i=0;i<3;i++)
            {
                ExpocadBooth__c eB = new ExpocadBooth__c(Booth_Number__c='TestBoothNo.'+i, Opportunity__c = oOpportunity.Id );
                lstExpoBooth.add(eB);   
            }
            insert lstExpoBooth;
            
             //create ExpocadBooth__c
            List<Opportunity_ExpoCAD_Booth_Mapping__c> lstExpoBoothMap = new List<Opportunity_ExpoCAD_Booth_Mapping__c>();
            for(Integer i=0;i<3;i++)
            {
                Opportunity_ExpoCAD_Booth_Mapping__c eBm = new Opportunity_ExpoCAD_Booth_Mapping__c(Expocad_Booth__c =lstExpoBooth[i].id, status__c = 'Active', Opportunity__c =oOpportunity.id);
                lstExpoBoothMap .add(eBm);   
            }
            insert lstExpoBoothMap ;
                        
            Product2 prd1 = new Product2(Name = 'Co-Exhibitor Fees',EAC_Fee__c=true,Family = 'Booth',Event_Edition__c=lstEE[0].Id,To_Be_Dispalyed_On_OBC__c = true,Expired__c='No', Number_of_Corners__c = 0, Event_Edition_Pool__c = 'WOC');
            insert prd1;
             PricebookEntry stndrdPrice = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prd1.Id,UnitPrice = 100, IsActive = true);
            insert stndrdPrice;
            
            PricebookEntry custmPrice = new PricebookEntry(Pricebook2Id = customPB.Id, Product2Id = prd1.Id,UnitPrice = 100, IsActive = true);
            insert custmPrice;
             ICRE__c objicre = new ICRE__c();
            objicre.PBName__c = customPB.id;
            objicre.PBName__c = customPB.id;
            objicre.Product__c = prd1.id;
            objicre.active__c = true;
            insert objicre;   
            
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
                TempContact__c tc = new TempContact__c(FirstName__c='TCFrst'+i,LastName__c='TCLst'+i, Account__c=accounts[i].Id,TempAccount__c=lstTempAcc[i].Id, Phone__c='1234567890',Fax__c='1234567890',Email__c='abc@test.com');
                lstTempCon.add(tc); 
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
                BoothContractorMapping__c bCM = new BoothContractorMapping__c(Approved__c=True,Opp_Booth_Mapping__c=lstExpoBoothMap[i].Id, ExpocadBooth__c=lstExpoBooth[i].Id, Contact__c=contacts[i].Id, TempContact__c=lstTempCon[i].Id,Event_Edition__c=lstEE[i].Id, status__c='Pending');
                lstBoothCM.add(bCM);    
            } 
            insert lstBoothCM;
            
            Stand_Detail__c standDetails = new Stand_Detail__c(ExpocadBooth__c =lstBoothCM[0].ExpocadBooth__c,Opp_Booth_Mapping__c=lstExpoBoothMap[0].Id,Stand_Height__c=2.0,Account__c=accounts[0].Id);
            insert standDetails;
            
            Stand_Design__c standDesign = new Stand_Design__c(ExpocadBooth__c =lstBoothCM[0].ExpocadBooth__c,Opp_Booth_Mapping__c=lstExpoBoothMap[0].Id,Account__c=accounts[0].Id,Is_Rejected__c=false);
            insert standDesign;
            
            //create CustomerContractorService__c
            List<CustomerContractorService__c> lstCstmrConSrvc = new List<CustomerContractorService__c>();
            for(Integer i=0;i<3;i++)
            {
                CustomerContractorService__c cCS = new CustomerContractorService__c(BoothContractorMapping__c=lstBoothCM[i].Id,ContractorService__c=cS.Id,Event_Edition__c=lstEE[i].Id);
                lstCstmrConSrvc.add(cCS);   
            }
            insert lstCstmrConSrvc;
            
            // Create User Manual Action
            User_Manual_Action__c uma = new User_Manual_Action__c();
            uma.User_Manual_Contact__c = contacts.get(0).id; 
            uma.Account__c = accounts.get(0).id; 
            uma.User_Type__c = uT.Id;
            //insert uma
        }
        
        @isTest static void validate()
        {
           string srchString='Tst';
           list<Event_Edition__c> lstEE=[SELECT Id, Name, Event_Code__c from Event_Edition__c LIMIT 1];
           System.assertNotEquals(null, lstEE,'opportunity is not null');
           string evntCode=lstEE[0].Event_Code__c;
           List<Contact> opp = [select id,AccountId, Account.Name from Contact];
           list<BoothContractorMapping__c> lstmap=[SELECT Id,ExpocadBooth__c,Opp_Booth_Mapping__c,ExpocadBooth__r.Opportunity__r.EventEdition__c, ExpocadBooth__r.Opportunity__r.Operations_Contact__r.Account.Name,Contact__r.AccountID from BoothContractorMapping__c Limit 1]; 
            
           Test.startTest();
           Event_Settings__c testEvntSttng=MyExhibitorsCtrl.getEventDetails(evntCode);
          
           BoothContractorMapping__c boothmap=MyExhibitorsCtrl.getExhibitorMapbyId(lstmap[0].Id);
            
           list<string> listState=MyExhibitorsCtrl.getContartorStatus();
           Stand_Detail__c standDetails =[SELECT ID, Name,Account__c,ExpocadBooth__c,Agent_Account__c,IsRigging__c,Opp_Booth_Mapping__c from Stand_Detail__c LIMIT 1];
           MyExhibitorsCtrl.updateStandDetails(standDetails);
           list<user> objusers=[select id,contactid from user limit 1];
            System.runAs(objusers[0])
            {  
                list<BoothContractorMapping__c> lstboothmap=MyExhibitorsCtrl.getExhibitors(evntCode);
            }
            Stand_Detail__c objStandDetail = MyExhibitorsCtrl.getStandDetail(lstmap[0].Opp_Booth_Mapping__c,lstmap[0].Contact__r.AccountID,'','');
            Stand_Design__c objStandDesign = MyExhibitorsCtrl.getStandDesign(lstmap[0].Opp_Booth_Mapping__c,lstmap[0].Contact__r.AccountID,'','');
            Stand_Detail__c objStandDetail2 = MyExhibitorsCtrl.getStandDetail('',lstmap[0].Contact__r.AccountID,'',lstmap[0].Contact__r.AccountID);
            Stand_Design__c objStandDesign2 = MyExhibitorsCtrl.getStandDesign('',lstmap[0].Contact__r.AccountID,'',lstmap[0].Contact__r.AccountID);
            Stand_Design__c standDesign = [SELECT Id, Name from Stand_Design__c Limit 1];
            MyExhibitorsCtrl.updateStandDesign(standDesign); 
            
            Id uploadedfile = MyExhibitorsCtrl.saveChunk(lstmap[0].Id,opp[0].AccountId,'test.csv','dsdsdsdsd','text/csv','','Non Complex',lstmap[0].Opp_Booth_Mapping__c,'E50','CAD',lstEE[0].Id,lstmap[0].Contact__r.AccountID);
        
             MyExhibitorsCtrl.saveChunk(lstmap[0].Id,opp[0].AccountId,'test.csv','dsdsdsdsd','text/csv',string.valueof(uploadedfile),'Non Complex',lstmap[0].Opp_Booth_Mapping__c,'E50','CAD',lstEE[0].Id,'');
            
            list<ContentDocument> objattachment =[Select Id From ContentDocument limit 1];
            list<Stand_Design__c> lststandDesign=[select id from Stand_Design__c limit 1];
            MyExhibitorsCtrl.deleteFile(objattachment[0].Id,lststandDesign[0].Id);
        
            list<BoothContractorMapping__c> lstboothmap1 = MyExhibitorsCtrl.updateStatus(evntCode,lstmap[0].Id,'Declined'); 
            list<BoothContractorMapping__c> lstboothmap2 = MyExhibitorsCtrl.updateStatus('WOC17',lstmap[0].Id,'Accepted');
        
            list<string> lstSides = MyExhibitorsCtrl.getOpenSides();
            list<Stand_Design_Attachments__c> lstStandDesignAttachments = MyExhibitorsCtrl.getStandDesignAttTypes();

            //list<User_Manual_Action__c> listUserManlActn =MyExhibitorsCtrl.fetchReqManuals(evntCode,opp[0].Id,opp[0].AccountId);
            list<User_Manual_Action__c> listUserManualActionObj = [SELECT id,Is_Agree__c FROM User_Manual_Action__c];
            //MyExhibitorsCtrl.saveUserManualAgreement(lstEE.get(0).id , true);
            Manual__c man = new Manual__c(Section__c = 12345, Name = 'Test Manual Toc', Event_Edition__c = lstEE[0].Id, User_Type__c = 'Exhibitor', Expocad_Booth_Class__c = '', Expocad_Booth_Type__c = 'Inline', Expocad_Product_Type__c = 'Barter Shell Scheme');
            insert man;
            Manuals_Permission__c mPermission = new Manuals_Permission__c(Manuals__c = man.id);
            insert mPermission;
            User_Manual_Action__c userManual = new User_Manual_Action__c(Manual_Permission__c=mPermission.id);
            insert userManual;
            ContactEventEditionMapping__c cEEM = new ContactEventEditionMapping__c(SFEventEditionID__c = man.Event_Edition__c, SFContactID__c = opp[0].Id, User_Type__c = mPermission.User_Type__c);
            insert cEEM;
            list<User_Manual_Action__c> listUserManlActn =MyExhibitorsCtrl.fetchReqManuals(evntCode,opp[0].Id,opp[0].AccountId);
            MyExhibitorsCtrl.checkManuals(evntCode,opp[0].Id,opp[0].AccountId);
            //MyExhibitorsCtrl.updateUserManualAction(userManual);
            list<BoothContractorMapping__c> listAgent =  MyExhibitorsCtrl.getAgents(evntCode);
            list<Opportunity_ExpoCAD_Booth_Mapping__c>  lstExpoBooth = MyExhibitorsCtrl.getAgentBooths(evntCode,'','');
            Test.stopTest();
        }
    }