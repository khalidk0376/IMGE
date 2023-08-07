/**
* Created/Modified By   : Girikon(Prashant)
* Created On    :       12/03/2018
* @description  :       Test class for the below apex classes
* Apex Class    :       Trigger_EventEdition(96%), TriggerInterface_EventEdition(100%), BadgesAssignmentByBoothType(100%), CreateBoothTypeBadgeLimitRecords(81%)
* Last Modified By:     Girikon[Aishwarya CCEN-578 Apr 1 2019]
* Modified By Palla Kishore for the Api version Ticket EMEA-264
**/
@isTest
public class BadgesAssignmentByBoothType_Test {
    @isTest
    public static void eventEditionDataSetup()
    {
        //Create APXTConga4__Conga_Template__c
        APXTConga4__Conga_Template__c conga = new APXTConga4__Conga_Template__c();
        conga.APXTConga4__Template_Type__c = 'Document';
        insert conga;
        
        //Insert event edition image
        Document doc = new Document(); 
        doc.Name = 'TEV17-Event-Image'; 
        doc.FolderId = UserInfo.getUserId();//documents[0].FolderId;
        doc.IsPublic = true; 
        doc.Body =Blob.valueOf('Some Text'); 
        doc.ContentType = 'image/jpeg';
        insert doc;
        Test.startTest();
        //Call event edition trigger interface
        TriggerInterface_EventEdition obj = new TriggerInterface_EventEdition();
        
        //Call trigger app handler for insert event
        TriggerInterfaceHelper.runTrigger('BadgesAssignmentByBoothType','Event_Edition__c',99, 'ai', null,null,'All');
        
        Brand__c oBrand = new Brand__c(Name = 'World Of Concrete', Business_Unit__c = 'Life Science');
        Insert oBrand;
        Event_Series__c oEventseries = new Event_Series__c(Name = 'World Of Concrete', Brand__c = oBrand.Id , CurrencyISOCode = 'USD', Package_Identifier__c = 'WOC', Event_Edition_Pool__c = 'WOC', Status__c = 'Active');
        Insert oEventseries;
        
        Event_Edition__c eEve = new Event_Edition__c();
        eEve.Name='World of Concrete 2017';
        eEve.Part_of_Series__c=oEventseries.id;
        eEve.Event_Code__c='WOC17';
        eEve.End_Date__c=System.Today();
        eEve.Start_Date__c=System.Today();
        eEve.Event_Currency__c='USD';
        eEve.Event_Edition_Status__c = 'Confirmed';
        eEve.Contract_Template__c = conga.id;
        eEve.Event_Website__c ='http://www.testevent.com';
        eEve.Event_Edition_Image_URL__c= doc.Id;
        eEve.Invoice_From_Email_ID__c='Test';
        eEve.Max_Hold_Booth__c=15;
        eEve.Max_Hold_Days__c=365;
        eEve.Measurement__c='Feet';
        eEve.Next_Edition__c='2019';
        eEve.Payment_Schedule__c='50-50';
        eEve.Quote_Template__c=conga.id;
        eEve.Start_Date__c=date.today()-1;
        eEve.Venue__c='Las Vegas Convention Center';
        eEve.Year__c='2019';
        eEve.Informa_Logo__c=doc.Id;
        eEve.Cutoff_Date_1__c=date.today()+1;
        eEve.Cutoff_Date_2__c=date.today()-10;
        eEve.Cutoff_Date_3__c=date.today()-15;
        eEve.Matched_Product_Name__c = 'Pavilion Space';
            //CCEN-578 Replace Booth Product Type with Matched Product Name
        eEve.Booth_Product_Type__c = 'Shell Scheme';
       // eEve.Event_Edition_Status__c = 'Completed';
        insert eEve;
        System.assertEquals(eEve.Event_Code__c,'WOC17', 'Event Code');
        
             
        Booth_Size_Badge_Limit__c badgelimit = new Booth_Size_Badge_Limit__c();
        badgelimit.Name ='Shell Scheme';
        badgelimit.Booth_Type__c ='Shell Scheme';
        badgelimit.Event_Edition__c = eEve.Id;
        insert badgelimit;
        System.assertEquals(badgelimit.Name,'Shell Scheme', 'Shell Scheme');
        
        Booth_Product_Type_Configuration__c bptc = new Booth_Product_Type_Configuration__c();
        bptc.Booth_Product_Type__c='Space Only';
        bptc.Matched_Product_Name__c = 'Artist Alley';
        insert bptc;
        //Call trigger app handler for insert event
       	// TriggerInterfaceHelper.runTrigger('BadgesAssignmentByBoothType','Event_Edition__c',99, 'ai', null,null,'All');
      /*  CreateBoothTypeBadgeLimitRecords boothType = new CreateBoothTypeBadgeLimitRecords();
        boothType.createBoothTypeRecords(new set<id>{eEve.Id});*/
        //Call trigger app handler for update event
        TriggerInterfaceHelper.runTrigger('BadgesAssignmentByBoothType','Event_Edition__c',99, 'au', null,null,'All');
        
        eEve.Booth_Product_Type__c = 'Space Only';
        update eEve;

        Booth_Product_Type_Configuration__c bptc1 = new Booth_Product_Type_Configuration__c();
        bptc1.Booth_Product_Type__c='Shell Scheme';
        bptc1.Matched_Product_Name__c = 'Artist Alley'; 
        insert bptc1;
     	eEve.Booth_Product_Type__c = 'Space Only';
        update eEve;
       	eEve.Booth_Product_Type__c = '';
        update eEve;
        Test.stopTest();
    }
   
}