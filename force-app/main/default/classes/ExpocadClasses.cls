/**
* File:        ExpocadClasses.cls
* Project:     GAP 
* Date:        09/22/2016
* Created By:  Kumar Gaurav
* Test Class: ExpocadClasses_Test 94%
* *************************************************************************
* Description: Contains all Parser Class from Expocad
* *************************************************************************
* History: Modified By [Yash Gupta 10/23/2019]
*/

public class ExpocadClasses  {
    
    // Apex class for coming booth detials from expocad
    public class Booth {
        @AuraEnabled public String ExhibitorId {get; set;}
        @AuraEnabled public String BoothNumber {get; set;}
        @AuraEnabled public String Dimensions {get; set;}
        @AuraEnabled public String XSize {get; set;}
        @AuraEnabled public String YSize {get; set;}
        @AuraEnabled public String Area {get; set;}
        @AuraEnabled public String Status {get; set;}
        @AuraEnabled public String BoothClass {get; set;}
        @AuraEnabled public String Pavilion {get; set;}
        @AuraEnabled public String ShowInShow {get; set;}
        @AuraEnabled public String BoothType {get; set;}
        @AuraEnabled public String ProductName{get; set;}
        @AuraEnabled public Double PricePerUnit{get; set;}
        @AuraEnabled public String ExhibitorName {get; set;}
        @AuraEnabled public List<String> BoothClasses {get; set;}
        @AuraEnabled public List<String>  ChildExhibitors{get; set;}
        @AuraEnabled public Integer OpenCorners {get; set { OpenCorners = value == null ? 0: Integer.valueof(value) ;} }
        @AuraEnabled public String UnitType {get; set;}
        @AuraEnabled public Boolean IsDeleted {get; set;}
        @AuraEnabled public Boolean IsOnHold {get; set;}
        @AuraEnabled public Boolean IsRented {get; set;}
        @AuraEnabled public Boolean isSelected {get; set;}
        @AuraEnabled public ID productId {get; set;}
        @AuraEnabled public ID productId2 {get; set;}
        @AuraEnabled public String DisplayNameOverride {get; set;}
        
    }
    
    // Apex class for coming Exibitor detials from expocad
    public class Exhibitor {
        public String Address1{get; set { Address1 = value == null ? '': value;} }
        public String Address2{get; set { Address2 = value == null ? '': value;} }
        public String City{get; set { City = value == null ? '': value;} }
        public String Contact{get; set { Contact = value == null ? '': value;} }
        public String Country{get; set { Country = value == null ? '': value;} }
        public String DisplayOnDrawing{get; set { DisplayOnDrawing = value == null ? '': value;} }
        public String Email{get; set { Email = value == null ? '': value;} }
        public String ExhibitorId{get; set { ExhibitorId = value == null ? '': value;} }
        public String ExhibitorName{get; set { ExhibitorName = value == null ? '': value;} }
        public string DoingBusinessAsDisplayOnDrawing {get; set {DoingBusinessAsDisplayOnDrawing = value == null ? '' :value;}}
        public String PostalCode{get; set { PostalCode = value == null ? '': value;} }
        public String Profile{get; set { Profile = value == null ? '': value;} }
        public String State{get; set { State = value == null ? '': value;} }
        public String Comments2 {get; set { Comments2 = value == null ? '': value;} }
    }
    
    public class X3EExhibitor {
        public String Address1{get; set { Address1 = value == null ? '': value;} }
        public String Address2{get; set { Address2 = value == null ? '': value;} }
        public String City{get; set { City = value == null ? '': value;} }
        public String Contact{get; set { Contact = value == null ? '': value;} }
        public String Country{get; set { Country = value == null ? '': value;} }
        public String DisplayOnDrawing{get; set { DisplayOnDrawing = value == null ? '': value;} }
        public String Email{get; set { Email = value == null ? '': value;} }
        public String ExhibitorId{get; set { ExhibitorId = value == null ? '': value;} }
        public String ExhibitorName{get; set { ExhibitorName = value == null ? '': value;} }
        public string DoingBusinessAsDisplayOnDrawing {get; set {DoingBusinessAsDisplayOnDrawing = value == null ? '' :value;}}
        public String PostalCode{get; set { PostalCode = value == null ? '': value;} }
        public String Profile{get; set { Profile = value == null ? '': value;} }
        public String State{get; set { State = value == null ? '': value;} }
        public String Comments2 {get; set { Comments2 = value == null ? '': value;} }
        public String Phone {get; set { Phone = value == null ? '': value;} }
        public String Salutation {get; set { Salutation = value == null ? '': value;} }
        public String Title {get; set { Title = value == null ? '': value;} }
        public String Website {get; set { Website = value == null ? '': value;} }  
        
    }
    
    // Apex class for coming RatePlan detials from expocad
    public class RatePlan {
        @AuraEnabled public String Name;
    }
    
    // Apex class for coming booth details from expocad //added by rajesh
    public class Stats {
        @AuraEnabled public String TotalBooths {get; set;}
        @AuraEnabled public String RentedBooths{get; set;}
        @AuraEnabled public String AvailableBooths{get; set;}
        @AuraEnabled public String NonInventoryBooths{get; set;}
        @AuraEnabled public String TotalExhibitors{get; set;}
        @AuraEnabled public String TotalBoothArea{get; set;}
        @AuraEnabled public String RentedBoothArea{get; set;}
        @AuraEnabled public String AvailableBoothArea{get; set;}
        @AuraEnabled public String NonInventoryBoothArea{get; set;}
        @AuraEnabled public String RentedBoothPercentage{get; set;}
        @AuraEnabled public String AvailableBoothPercentage{get; set;}
        @AuraEnabled public string NetValueSold{get; set;}
        @AuraEnabled public string HoldBoothArea{get; set;}
        @AuraEnabled public string HoldBooths{get; set;}
        @AuraEnabled public string HoldBoothPercentage{get; set;}
        
    }
    
    //Apex class for coming booth details from expocad //added by rajesh
    public class ExistingCoExhibitor {
        @AuraEnabled public String Code {get; set;}
        @AuraEnabled public String Message {get; set;}
    }
}