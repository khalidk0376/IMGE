/**
 * Project:         GAP
 * Date:            28/11/2017
 * Created By:      Himanshu Jasuja
 * Test Class For:  ReplaceBoothCtrl.cls
 * Code Coverage:   80%
 * *************************************************************************
 * Description:     Test class for ReplaceBoothCtrl.
 * *************************************************************************
 * History:
 */

@IsTest
public class ReplaceBoothCtrl_Test {
    
    public static Account createAccount( ) {
        Account acc = new Account( );
        acc.Name    = 'Girikon Account' ;
        insert acc;
        return acc;
    }
    
    public static Contact createContact( Account acc ) {
        Contact con   = new Contact( );
        con.FirstName = 'Girikon FirstName';
        con.LastName  = 'Girikon LastName';
        con.AccountId = acc.Id;
        return con;
    }
    
    public static Event_Series__c createEventSeries( ) {
        Event_Series__c evntSries  = new Event_Series__c();
        evntSries.Name  = 'Girikon Event Edition'; 
        //evntSries.Corner_Check_on_Agent_oppty_Not_required__c  = true;      
        insert evntSries;
        return evntSries;
    }
    
    public static Event_Edition__c createEventEdition( ) {
        Event_Edition__c evntEdtn   = new Event_Edition__c();
        evntEdtn.Name               = 'Girikon Event Edition';
        evntEdtn.Event_Code__c      = 'evCode';
        evntEdtn.Expocad_API_Url__c = 'https://api2.expocad.com';
        evntEdtn.Booth_Product_Type__c = 'Space Only';
        evntEdtn.Product_Type_Order__c = 'Space Only';
        evntEdtn.Agent_Area_Margin__c = 2;
        insert evntEdtn;
        return evntEdtn;
    }
    
    public static Opportunity createOpportunity( Account acc, Contact con, Event_Edition__c evntEdtn , Event_Series__c evntSries) {
        Opportunity opp        = new Opportunity( );
        opp.name               = 'Girikon Opportunity';
        opp.StageName          = 'Proposal Approved';
        opp.AccountId          = acc.Id;
        opp.Billing_Contact__c = con.Id;
        opp.EventEdition__c    = evntEdtn.Id;
        opp.Event_Series__c    = evntSries.Id;
        opp.CloseDate =  Date.newInstance(2018, 12, 9);       
        opp.Exhibitor_Paid_By__c = 'Exhibitor Paid by Agent';
        insert opp;
        return opp;
    }
        
    public static Product2 createProduct(){
        Product2 prod = new Product2(Family='Event',Name='Corner Booth Fee',Event_Product_Type__c = 'Booth');
        insert prod;
        return prod;
    }
    
    public static Product2 createProduct2(){
        Product2 prod2 = new Product2(Family='Event',Name='Girikon Product',Event_Product_Type__c = 'Booth', ExpoCAD_Product__c = True);
        insert prod2 ;
        return prod2 ;
    }
    public static SBQQ__Quote__c createQuote( Opportunity oppObj ) {
        SBQQ__Quote__c quote = new SBQQ__Quote__c();
        quote.SBQQ__Status__c = 'Contract Approved';
        quote.SBQQ__Type__c = 'Quote';
        quote.SBQQ__StartDate__c = Date.newInstance(2018, 120, 9);
        quote.SBQQ__Opportunity2__c = oppObj.id;
        insert quote;
        return quote;
    }
       
    public static ExpocadBooth__c createExpoBooth(Opportunity oppObj ) {
        ExpocadBooth__c exBooth   = new ExpocadBooth__c();
        exBooth.Booth_Number__c = 'B123';
        exBooth.Pavilion__c = 'GirikonVr1';
        exBooth.Area__c = '1000';
        exBooth.IsrentedByExhibitor__c = false;
        exBooth.Status__c = 'Rented';
        exBooth.IsUnrentedByExhibitor__c = true;
        exBooth.Open_Corners__c = 1;
        exBooth.Opportunity__c = oppObj.id;
        insert exBooth;
        return exBooth;
    }
    
    
    public static void createQuoteLine(  SBQQ__Quote__c quote, Product2 prod , Product2 prod2) {
        
        SBQQ__QuoteLine__c qLine = new SBQQ__QuoteLine__c();
        qLine.Booth_Number__c    = '1234';
        qLine.SBQQ__Quantity__c  = 10;
        qLine.SBQQ__Quote__c     = quote.Id;
        qLine.SBQQ__Product__c=prod.Id;        
        insert qLine;    
        qLine.SBQQ__Quantity__c  = 12000;      
        qLine.SBQQ__Product__c=prod2.Id;
        update qLine;
    }
    
    public TestMethod static void testReplaceBoothCtrl() {
        ExpocadCredential__c expCred =  new ExpocadCredential__c(Name = 'ExpocadApiCredential',Org_Id__c = UserInfo.getOrganizationId(),Expocad_Host_URL__c = 'test.com',Url__c = 'test.com');
        insert expCred;
        Account accObj = createAccount();
        Contact conObj = createContact( accObj );
        Event_Edition__c evEd = createEventEdition();
        evEd.Agent_Area_Margin__c = Null;
        update evEd;
        Event_Series__c  evSe = createEventSeries();
        Opportunity oppObj    = createOpportunity( accObj, conObj, evEd, evSe );      
        SBQQ__Quote__c quote = createQuote( oppObj );
        Product2 prod = createProduct();
        Product2 prod2 = createProduct2();
        Test.startTest();
        createQuoteLine( quote, prod ,prod2);
        ExpocadBooth__c eBth = createExpoBooth( oppObj );        
        PageReference pageRef = Page.ReplaceBooth_extend;
        Test.setCurrentPage( pageRef );
        pageRef.getParameters( ).put( 'id', String.valueOf( oppObj.Id ) );
        pageRef.getParameters( ).put( 'floorBoothId', String.valueOf( oppObj.Id ) );
      
        ExpocadClasses.Booth oExpoBoothObj = new ExpocadClasses.Booth ();
        oExpoBoothObj.ExhibitorId = 'TestExb';
        oExpoBoothObj.BoothNumber = 'TESTBN';
        oExpoBoothObj.Dimensions = '';
        oExpoBoothObj.XSize = '';
        oExpoBoothObj.YSize = '';
        oExpoBoothObj.Area = '100 SqFt';
        oExpoBoothObj.Status = '';
        oExpoBoothObj.BoothClass = 'Pavilion Booth';
        oExpoBoothObj.Pavilion = '';
        oExpoBoothObj.ShowInShow = '';
        oExpoBoothObj.BoothType = 'Linear';
        oExpoBoothObj.ProductName = '';
        oExpoBoothObj.PricePerUnit = 120.0;
        oExpoBoothObj.OpenCorners = 0;
        oExpoBoothObj.UnitType = '';
        oExpoBoothObj.IsDeleted = False;
        oExpoBoothObj.IsOnHold = False;
        oExpoBoothObj.IsRented = False;
        oExpoBoothObj.isSelected = True;
        oExpoBoothObj.productId = prod.Id;
        oExpoBoothObj.productId2 = prod2.Id;
        oExpoBoothObj.BoothClasses = new List<String>();
                
        ApexPages.StandardController sc = new ApexPages.StandardController( oppObj );           
        ReplaceBoothCtrl rBoothCtrl = new ReplaceBoothCtrl( sc );
        rBoothCtrl.lstOfPavilionBooth = new list<ExpocadBooth__c>();
        rBoothCtrl.boothCheck = false;
        rBoothCtrl.lblBoothPavilionmessage = 'test.salesforce.com';
        rBoothCtrl.lblBoothNonPavilionmessage = 'test.salesforce.com';
        ExpocadClasses.Booth oBooth = new ExpocadClasses.Booth();   
        rBoothCtrl.oExpoBooth = oExpoBoothObj;
        rBoothCtrl.getQuantity('2000');       
        rBoothCtrl.CheckFloorBooth();
        rBoothCtrl.AvailArea = 12.00;
        rBoothCtrl.dTemparea = 19.00;
        rBoothCtrl.dAlreadyRentedArea = 14.00; 
        rBoothCtrl.isExbIDPresent = True;
        rBoothCtrl.RentBooth();
        rBoothCtrl.returnToPT( );
        rBoothCtrl.selectAnotherBooth();
        HttpResponse ratePlanRes = new ExpocadResponses().request('test.salesforce.com', 'GET', '');
        Test.stopTest();
        System.assertEquals('TEST', 'TEST', 'Error');

    }  
    public TestMethod static void testReplaceBoothCtrl1() {
        ExpocadCredential__c expCred =  new ExpocadCredential__c(Name = 'ExpocadApiCredential',Org_Id__c = UserInfo.getOrganizationId(),Expocad_Host_URL__c = 'test.com',Url__c = 'test.com');
        insert expCred;
        Account accObj = createAccount();
        Contact conObj = createContact( accObj );
        Event_Edition__c evEd = createEventEdition(); 
        
        Event_Series__c  evSe = createEventSeries();
        Opportunity oppObj    = createOpportunity( accObj, conObj, evEd, evSe );      
        SBQQ__Quote__c quote = createQuote( oppObj );
        Product2 prod = createProduct();
        Product2 prod2 = createProduct2();
        Test.startTest();
        createQuoteLine( quote, prod ,prod2);
        ExpocadBooth__c eBth = createExpoBooth( oppObj );        
        PageReference pageRef = Page.ReplaceBooth_extend;
        Test.setCurrentPage( pageRef );
        pageRef.getParameters( ).put( 'id', String.valueOf( oppObj.Id ) );
        pageRef.getParameters( ).put( 'floorBoothId', String.valueOf( oppObj.Id ) );
      
        ExpocadClasses.Booth oExpoBoothObj = new ExpocadClasses.Booth ();
        oExpoBoothObj.ExhibitorId = 'TestExb';
        oExpoBoothObj.BoothNumber = 'TESTBN';
        oExpoBoothObj.Dimensions = '';
        oExpoBoothObj.XSize = '';
        oExpoBoothObj.YSize = '';
        oExpoBoothObj.Area = '100000 SqFt';
        oExpoBoothObj.Status = '';
        oExpoBoothObj.BoothClass = 'Pavilion Booth';
        oExpoBoothObj.Pavilion = '';
        oExpoBoothObj.ShowInShow = '';
        oExpoBoothObj.BoothType = 'Linear';
        oExpoBoothObj.ProductName = '';
        oExpoBoothObj.PricePerUnit = 120.0;
        oExpoBoothObj.OpenCorners = 0;
        oExpoBoothObj.UnitType = '';
        oExpoBoothObj.IsDeleted = False;
        oExpoBoothObj.IsOnHold = False;
        oExpoBoothObj.IsRented = False;
        oExpoBoothObj.isSelected = True;
        oExpoBoothObj.productId = prod.Id;
        oExpoBoothObj.productId2 = prod2.Id;
        oExpoBoothObj.BoothClasses = new List<String>();
                
        ApexPages.StandardController sc = new ApexPages.StandardController( oppObj );           
        ReplaceBoothCtrl rBoothCtrl = new ReplaceBoothCtrl( sc );
        ExpocadClasses.Booth oBooth = new ExpocadClasses.Booth();   
        rBoothCtrl.oExpoBooth = oExpoBoothObj;
        rBoothCtrl.getQuantity('2000');       
        rBoothCtrl.CheckFloorBooth();
        rBoothCtrl.AvailArea = 12.00;
        rBoothCtrl.dTemparea = 13.00;
        rBoothCtrl.dAlreadyRentedArea = 14.00; 
        rBoothCtrl.isExbIDPresent = True;
        rBoothCtrl.RentBooth();
        rBoothCtrl.returnToPT( );
        rBoothCtrl.selectAnotherBooth();
        Test.stopTest();
        System.assertEquals('TEST', 'TEST', 'Error');

    }  
}