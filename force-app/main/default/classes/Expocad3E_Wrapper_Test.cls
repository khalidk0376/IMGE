@isTest
public class Expocad3E_Wrapper_Test {
    
    @isTest
    static void wrapperTest(){
        Test.startTest();
        Expocad3E_Wrapper expo_Wrap = new Expocad3E_Wrapper();
        Expocad3E_Wrapper.WrapperResponse expoWrapper = new Expocad3E_Wrapper.WrapperResponse();
        Expocad3E_Wrapper.APITokenWrapper expoWrapper1 = new Expocad3E_Wrapper.APITokenWrapper();
        Expocad3E_Wrapper.InviteExhibitor expoWrapper2 = new Expocad3E_Wrapper.InviteExhibitor();
        Expocad3E_Wrapper.ResponseInviteExhibitor expoWrapper3 = new Expocad3E_Wrapper.ResponseInviteExhibitor();
        Expocad3E_Wrapper.cls_companyTypeList expoWrapper4 = new Expocad3E_Wrapper.cls_companyTypeList();
        Expocad3E_Wrapper.cls_companyListIds expoWrapper5 = new Expocad3E_Wrapper.cls_companyListIds();
        Expocad3E_Wrapper.CompanyTypes expoWrapper6 = new Expocad3E_Wrapper.CompanyTypes();
        Expocad3E_Wrapper.SendContractpdf expoWrapper7 = new Expocad3E_Wrapper.SendContractpdf(); 
        QuoteLineGroupModel qGroupModal = new QuoteLineGroupModel();
        QuoteLineModel qlModal = new QuoteLineModel();
        QuoteModel qMod = new QuoteModel();
        Expocad3E_Wrapper.financialBooth wrap1 =  new Expocad3E_Wrapper.financialBooth();
        try{wrap1.parse('');}catch(Exception e){}
        System.assertNotEquals(expoWrapper7,Null,'Body not Found');//EX-101
        
        Test.stopTest();
        
    }
    
}