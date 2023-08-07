/**
 * File:            RelatedlistQuote_Test
 * Project:         GAP
 * Date:            3/1/2017 1:07 AM
 * Test Class For:  RelatedlistQuote
 * Code Coverage:   94%
 * Created By:      Rajesh Kumar
 * *************************************************************************
 * @description     Test class for relatedlistQuote class
 * *************************************************************************
 * History: GGCW-1798
 */

@isTest
public class RelatedlistQuote_Test {
    static testMethod void relatedlistQuoteTest() {
        Account oacc = new Account (Name = 'Test');
        insert oacc ;
        
        User user = [SELECT Id FROM User WHERE Id = : UserInfo.getUserId()];
        AccountTeamMember oAtm = new AccountTeamMember(AccountId = oacc.id,userId = user.id);
        insert oAtm;
        
        Product2 prd1 = new Product2(Name = 'Linear Booth',Family = 'Booth', Number_of_Corners__c = 0);
        insert prd1;
        
        Opportunity opp = new opportunity (name = 'test' , closeDate = Date.Today(), StageName= 'Qalification' , AccountId = oacc.id);
        insert opp;
        
        Event_Edition__c eEdit = new Event_Edition__c();
        eEdit.Name='test';
        eEdit.Cutoff_Date_1__c= Date.Today();        
        eEdit.Payment_Schedule__c='50-50';
        eEdit.Tab1__c = 'Tab1';
        eEdit.Tab7__c = 'Tab7';
        eEdit.Cutoff_Date_2__c= Date.Today(); 
        insert eEdit;
        System.assertEquals('test' , eEdit.Name, true);
        eEdit.Payment_Schedule__c='10-40-50';
        update eEdit;                
        
        Contact con = new Contact();
        con.LastName='test';
        insert con;
        
        Contact con1 = new Contact();
        con1.LastName='test 2';
        insert con1;
        
        Opportunity opp1 = new opportunity (name = 'test' , closeDate = Date.Today(), StageName= 'Qalification' , AccountId = oacc.id , EventEdition__c = eEdit.id);
        insert opp1;
        
        SBQQ__Quote__c oQuote = new SBQQ__Quote__c(SBQQ__Status__c = 'Quote',IsCreatedByReviewProcess__c = false, Billing_Contact__c = con.id ,SBQQ__Type__c = 'Quote',Alternate_Currency2__c='AED', SBQQ__Opportunity2__c = opp1.id , SBQQ__Primary__c = true);
        insert oQuote; 
                
        oQuote.Billing_Contact__c = con1.id;        
        update oQuote;
        
        SBQQ__QuoteLine__c oQuoteLine = new SBQQ__QuoteLine__c(SBQQ__Quote__c = oQuote.Id, SBQQ__Product__c = prd1.Id, SBQQ__Quantity__c = 2, SBQQ__Number__c = 1, Line_Description__c = 'Test', Booth_Number__c = 'TESTBN3', Booth__c = True);
        insert oQuoteLine ;        
        
        List<SBQQ__Quote__c> quotelist = new List<SBQQ__Quote__c>();        
        quotelist.add(oQuote);
                
        Map<id,SBQQ__Quote__c> quoteMap = new Map<id,SBQQ__Quote__c>();  
        quoteMap.put(oQuote.id,oQuote);
        RelatedlistQuote obj = new RelatedlistQuote(quotelist,quoteMap,true,true,true,true); 
        obj.quoteRelatedList();
        
    }
    
    static testMethod void billingUpdateTest() {
        Account oacc = new Account (Name = 'Test');
        insert oacc ;
        User user = [SELECT Id FROM User WHERE Id = : UserInfo.getUserId()];
        
        AccountTeamMember oAtm =new AccountTeamMember(AccountId = oacc.id,userId = user.id);
        insert oAtm;
        
        Product2 prd1 = new Product2(Name = 'Linear Booth',Family = 'Booth', Number_of_Corners__c = 0);
        insert prd1;
        
        Event_Edition__c eEdit1 = new Event_Edition__c();
        eEdit1.Name='test';
        eEdit1.Cutoff_Date_1__c= Date.Today();        
        eEdit1.Payment_Schedule__c='50-50';
        eEdit1.Tab1__c = 'Tab1';
        eEdit1.Tab7__c = 'Tab7';
        eEdit1.Cutoff_Date_2__c= Date.Today(); 
        insert eEdit1;
        
        System.assertEquals('test' , eEdit1.Name, true);
        eEdit1.Payment_Schedule__c='10-45-45';
        update eEdit1;  
        
        Opportunity opp2 = new opportunity (name = 'test' , closeDate = Date.Today(), StageName= 'Qalification' , AccountId = oacc.id , EventEdition__c = eEdit1.id);
        insert opp2;
        
        SBQQ__Quote__c oQuote1 = new SBQQ__Quote__c(SBQQ__Status__c = 'Quote',SBQQ__Type__c = 'Quote',Alternate_Currency2__c='AED', SBQQ__Opportunity2__c = opp2.id , SBQQ__Primary__c = true);
        insert oQuote1;               
        
        SBQQ__QuoteLine__c oQuoteLine1 = new SBQQ__QuoteLine__c(SBQQ__Quote__c = oQuote1.Id, SBQQ__Product__c = prd1.Id, SBQQ__Quantity__c = 2, SBQQ__Number__c = 1, Line_Description__c = 'Test', Booth_Number__c = 'TESTBN3', Booth__c = True);
        insert oQuoteLine1 ; 
    }
    static testMethod void paymentTermTest() {
        Account oacc = new Account (Name = 'Test');
        insert oacc ;
        User user = [SELECT Id FROM User WHERE Id = : UserInfo.getUserId()];
        AccountTeamMember oAtm =new AccountTeamMember(AccountId = oacc.id,userId = user.id);
        insert oAtm;
        
        Product2 prd1 = new Product2(Name = 'Linear Booth',Family = 'Booth', Number_of_Corners__c = 0);
        insert prd1;
        Event_Edition__c eEdit1 = new Event_Edition__c();
        eEdit1.Name='test';
        eEdit1.Cutoff_Date_1__c= Date.Today();        
        eEdit1.Payment_Schedule__c='50-50';
        eEdit1.Tab1__c = 'Tab1';
        eEdit1.Tab7__c = 'Tab7';
        eEdit1.Cutoff_Date_2__c= Date.Today(); 
        eEdit1.Cutoff_Date_3__c= Date.Today(); 
        
        insert eEdit1;
        System.assertEquals('test' , eEdit1.Name, true);
        eEdit1.Payment_Schedule__c='25-25-50';
        update eEdit1;  
        
        Opportunity opp2 = new opportunity (name = 'test' , closeDate = Date.Today(), StageName= 'Qalification' , AccountId = oacc.id , EventEdition__c = eEdit1.id);
        insert opp2;
        
        SBQQ__Quote__c oQuote1 = new SBQQ__Quote__c(SBQQ__Status__c = 'Quote',SBQQ__Type__c = 'Quote',Alternate_Currency2__c='AED', SBQQ__Opportunity2__c = opp2.id , SBQQ__Primary__c = true);
        insert oQuote1;
        
        SBQQ__QuoteLine__c oQuoteLine1 = new SBQQ__QuoteLine__c(SBQQ__Quote__c = oQuote1.Id, SBQQ__Product__c = prd1.Id, SBQQ__Quantity__c = 2, SBQQ__Number__c = 1, Line_Description__c = 'Test', Booth_Number__c = 'TESTBN3', Booth__c = True);
        insert oQuoteLine1 ; 
    }
    static testMethod void byPassClosedTest() {
        Account oacc = new Account (Name = 'Test');
        insert oacc ;
        User user = [SELECT Id FROM User WHERE Id = : UserInfo.getUserId()];
        AccountTeamMember oAtm =new AccountTeamMember(AccountId = oacc.id,userId = user.id);
        insert oAtm;
        
        Product2 prd1 = new Product2(Name = 'Linear Booth',Family = 'Booth', Number_of_Corners__c = 0);
        insert prd1;
        Event_Edition__c eEdit1 = new Event_Edition__c();
        eEdit1.Name='test';
        eEdit1.Cutoff_Date_1__c= Date.Today();        
        eEdit1.Payment_Schedule__c='50-50';
        eEdit1.Tab1__c = 'Tab1';
        eEdit1.Tab7__c = 'Tab7';
        eEdit1.Cutoff_Date_2__c= Date.Today(); 
        eEdit1.Cutoff_Date_3__c= Date.Today();
        insert eEdit1;
        System.assertEquals('test' , eEdit1.Name, true);
        eEdit1.Payment_Schedule__c='25-25-25-25';
        update eEdit1;          
        
        Opportunity opp2 = new opportunity (name = 'test' , closeDate = Date.Today(), StageName= 'Qalification' , AccountId = oacc.id , EventEdition__c = eEdit1.id);
        insert opp2;
        
        SBQQ__Quote__c oQuote1 = new SBQQ__Quote__c(SBQQ__Status__c = 'Quote',SBQQ__Type__c = 'Quote',Alternate_Currency2__c='AED', SBQQ__Opportunity2__c = opp2.id , SBQQ__Primary__c = true);
        insert oQuote1;
        
        SBQQ__QuoteLine__c oQuoteLine1 = new SBQQ__QuoteLine__c(SBQQ__Quote__c = oQuote1.Id, SBQQ__Product__c = prd1.Id, SBQQ__Quantity__c = 2, SBQQ__Number__c = 1, Line_Description__c = 'Test', Booth_Number__c = 'TESTBN3', Booth__c = True);
        insert oQuoteLine1 ; 
    }
}