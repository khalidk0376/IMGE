/**
* File:        ExpocadClasses_Test
* Project:     GAP
* Date:        08/10/2017
* Created By:  Kumar Gaurav
* Test Coverage: 100%
* Description: Test class for ExpocadClasses.
* History:     Modified By [Yash Gupta 10/23/2019]
*/

@isTest(seeAlldata = false)
public class ExpocadClasses_Test {  
    static testMethod void unitTest() {
        ExpocadClasses.Booth oBooth = new ExpocadClasses.Booth();
        oBooth.ExhibitorId = 'TEST';
        oBooth.BoothNumber = 'TEST';
        oBooth.Dimensions = 'TEST';
        oBooth.XSize = 'TEST';
        oBooth.YSize = 'TEST';
        oBooth.Area = 'TEST';
        oBooth.Status = 'TEST';
        oBooth.BoothClass = 'TEST';
        oBooth.Pavilion = 'TEST';
        oBooth.ShowInShow = 'TEST';
        oBooth.BoothType = 'TEST';
        oBooth.ProductName = 'TEST';
        oBooth.PricePerUnit = 1.2;
        oBooth.BoothClasses = new List<String>();
        oBooth.ChildExhibitors = new List<String>();
        oBooth.OpenCorners = 1;
        oBooth.UnitType = 'TEST';
        oBooth.IsDeleted = True;
        oBooth.IsOnHold = True;
        oBooth.IsRented = True;
        oBooth.isSelected = True;
        oBooth.productId = '0060j000008XXXXXXX';
        oBooth.productId2 = '0060j000008XXXXXXX';
        oBooth.ExhibitorName = 'TestGirikon';
        oBooth.DisplayNameOverride = 'Test Display Name' ;
        
        ExpocadClasses.Exhibitor oExhibitor = new ExpocadClasses.Exhibitor();
        oExhibitor.Address1 = 'TEST';
        oExhibitor.Address2 = 'TEST';
        oExhibitor.City = 'TEST';
        oExhibitor.Contact = 'TEST';
        oExhibitor.Country = 'TEST';
        oExhibitor.DisplayOnDrawing = 'TEST';
        oExhibitor.Email = 'TEST';
        oExhibitor.ExhibitorId = 'TEST';
        oExhibitor.ExhibitorName = 'TEST';
        oExhibitor.DoingBusinessAsDisplayOnDrawing = 'TEST';
        oExhibitor.PostalCode = 'TEST';
        oExhibitor.Profile = 'TEST';
        oExhibitor.State = 'TEST';
        oExhibitor.Comments2 = 'TEST';

        ExpocadClasses.X3EExhibitor oX3EExhibitor = new ExpocadClasses.X3EExhibitor();
        oX3EExhibitor.Address1 = 'TEST';
        oX3EExhibitor.Address2 = 'TEST';
        oX3EExhibitor.City = 'TEST';
        oX3EExhibitor.Contact = 'TEST';
        oX3EExhibitor.Country = 'TEST';
        oX3EExhibitor.DisplayOnDrawing = 'TEST';
        oX3EExhibitor.Email = 'TEST';
        oX3EExhibitor.ExhibitorId = 'TEST';
        oX3EExhibitor.ExhibitorName = 'TEST';
        oX3EExhibitor.DoingBusinessAsDisplayOnDrawing = 'TEST';
        oX3EExhibitor.PostalCode = 'TEST';
        oX3EExhibitor.Profile = 'TEST';
        oX3EExhibitor.State = 'TEST';
        oX3EExhibitor.Comments2 = 'TEST';
        oX3EExhibitor.Phone = 'TEST';
        oX3EExhibitor.Salutation = 'TEST';
        oX3EExhibitor.Title = 'TEST';
        oX3EExhibitor.Website = 'TEST';
        
        ExpocadClasses.ratePlan ratePlan = new ExpocadClasses.ratePlan();
        ratePlan.Name = 'Test';
        
        ExpocadClasses.Stats oStats  = new ExpocadClasses.Stats();
        oStats.TotalBooths = '1000';
        oStats.RentedBooths = '1000';
        oStats.AvailableBooths= '1000';
        oStats.NonInventoryBooths= '1000';
        oStats.TotalExhibitors= '1000';
        oStats.TotalBoothArea= '1000';
        oStats.RentedBoothArea= '1000';
        oStats.AvailableBoothArea= '1000';
        oStats.NonInventoryBoothArea = '1000';
        oStats.RentedBoothPercentage= '1000';
        oStats.AvailableBoothPercentage = '1000';
        oStats.NetValueSold= '1000';
        oStats.HoldBoothArea= '1000';
        oStats.HoldBooths = '1000';
        oStats.HoldBoothPercentage= '1000';
        
        ExpocadClasses.ExistingCoExhibitor oExistingCoExhibitor = new ExpocadClasses.ExistingCoExhibitor();
        oExistingCoExhibitor.Code = '1234';
        oExistingCoExhibitor.Message = 'Hello Test';
        System.assertEquals('Hello Test', oExistingCoExhibitor.Message, 'Error');
    }
}