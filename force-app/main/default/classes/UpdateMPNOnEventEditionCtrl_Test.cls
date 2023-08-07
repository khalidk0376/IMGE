/**
* Created/Modified By   : Girikon(Aishwarya)
* Created On    :       04/09/2018
* @description  :       Test class of controller - UpdateMPNOnEventEditionCtrl   
* Apex Class    :       UpdateMPNOnEventEditionCtrl(96%) 
* Last Modified By:      
**/
@isTest
public class UpdateMPNOnEventEditionCtrl_Test {
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
        
        Event_Series__c oESeries = new Event_Series__c(name='World of Concrete',Event_Edition_Pool__c='WOC',Status__c='Active');
        insert oEseries;
        system.assertEquals(oEseries.Event_Edition_Pool__c, 'WOC', 'Both values should be the same.');
        
        Event_Edition__c eEve = new Event_Edition__c();
        eEve.Name='World of Concrete 2017';
        eEve.Event_Code__c='WOC17';
        eEve.End_Date__c=System.Today();
        eEve.Start_Date__c=System.Today();
        eEve.Event_Currency__c='USD';
        eEve.Event_Edition_Status__c ='Confirmed';
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
        //CCEN-578 Replace Booth Product Type with Matched Product Name
        eEve.Booth_Product_Type__c = 'Space Only';
        eEve.Part_of_Series__c=oEseries.id;
        insert eEve;
        System.assertEquals(eEve.Event_Code__c,'WOC17', 'Event Code');
        
        Booth_Product_Type_Configuration__c bptc = new Booth_Product_Type_Configuration__c();
        bptc.Booth_Product_Type__c='Space Only';
        bptc.Matched_Product_Name__c = 'Artist Alley';
        insert bptc;
        
        Booth_Product_Type_Configuration__c bptc1 = new Booth_Product_Type_Configuration__c();
        bptc1.Booth_Product_Type__c='Shell Scheme';
        bptc1.Matched_Product_Name__c = 'Artist Alley'; 
        insert bptc1;
        
        
        //Call trigger app handler for update event
        TriggerInterfaceHelper.runTrigger('BadgesAssignmentByBoothType','Event_Edition__c',99, 'au', null,null,'All');
        
        eEve.Booth_Product_Type__c = 'Shell Scheme';
        update eEve;
        Test.stopTest();
    }
   
}