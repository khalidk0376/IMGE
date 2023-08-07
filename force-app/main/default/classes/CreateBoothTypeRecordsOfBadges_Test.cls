/**
 * Created/Modified By  : Girikon[Aishwarya-658]
 * Created On   :         21/02/2019
 * @description :         This class is called through the SKUID page: Badges_ExhibitorProfile_ForOps
 * Apex class   :         CreateBoothTypeRecordsOfBadges
 * Last Modified By :     Girikon[Aishwarya CCEN-578 Apr 1 2019]
**/

@isTest
public class CreateBoothTypeRecordsOfBadges_Test
{
    /**
     * @description : For data setup and test methods.
     * @return
    */
    public static testMethod void boothTypeDataSetup()
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
        
        Brand__c oBrand = new Brand__c(Name = 'World of Concrete', SSC_Email_Distribution_ID__c = 'test@test.tst');
        insert oBrand;

        Event_Series__c oEventseries = new Event_Series__c(Name = 'World Of Concrete', CurrencyISOCode = 'USD', Package_Identifier__c = 'WOC', Brand__c = oBrand.id, Event_Edition_Pool__c = 'WOC', Status__c = 'Active');
        insert oEventseries;
          
        Event_Edition__c eEve = new Event_Edition__c();
        eEve.Name='World of Concrete 2017';
        eEve.Event_Code__c='WOC17';
        eEve.Part_of_Series__c = oEventseries.Id;
        eEve.End_Date__c=System.Today();
        eEve.Start_Date__c=System.Today();
        eEve.Event_Currency__c='USD';
        //CCEN-578 Replace Booth Product Type with Matched Product Name
        eEve.Matched_Product_Name__c = 'Space Only';
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
        eEve.Event_Edition_Status__c = 'Confirmed';
        Test.StartTest();
        insert eEve;
        
        System.assertEquals(eEve.Event_Code__c,'WOC17', 'Event Code');
        
        Event_Settings__c eve = new Event_Settings__c();
        eve.Event_Edition__c = eEve.Id;
        eve.Allotment_By_Booth_Type__c = True;
        insert eve;
      
        
        CreateBoothTypeRecordsOfBadges.createBoothTypeRecordsBadges(eEve.Id);
        Test.StopTest();
    }

}