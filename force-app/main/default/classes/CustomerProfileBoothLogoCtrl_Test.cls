/**
 * Created/Modified By: Girikon(Archit)
 * Created On:          10/13/2017
 * Description/Purpose: This test class covers the apex class : CustomerProfileBoothLogoCtrl 
 * Methods:             unitTest
 * Apex Class:          CustomerProfileBoothLogoCtrl 
 **/

@isTest
public class CustomerProfileBoothLogoCtrl_Test 
{
    static testMethod void unitTest() 
    {
        ExpocadBooth__c oEB = new ExpocadBooth__c(Booth_Number__c='1234',Booth_Logo_Id__c='testId111',Status__c='Rented');
        insert oEB;
        
        AllowedImageTypes__c oAllImg = new AllowedImageTypes__c(name='.img');
        insert oAllImg;
        
        System.assertEquals(oEB.Booth_Logo_Id__c,'testId111','Booth Logo Id');
        ApexPages.currentPage().getParameters().put('boothId',oEB.id);
        ApexPages.currentPage().getParameters().put('check','false');
        ApexPages.currentPage().getParameters().put('found','false');
        
        Test.StartTest();
        CustomerProfileBoothLogoCtrl obj = new CustomerProfileBoothLogoCtrl();
        obj.fileName ='';
        obj.saveBoothLogo();
        obj.fileName ='test.pdf';
        obj.saveBoothLogo();
        obj.photo =Blob.valueof('Lorem Jipsum Lorem Jipsum Lorem Jipsum Lorem Jipsum');
        obj.fileName ='test.img';
        obj.saveBoothLogo();        
        Test.StopTest();
    }
}