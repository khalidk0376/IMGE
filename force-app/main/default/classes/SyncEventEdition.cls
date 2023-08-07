/**
* File:        SyncEventEdition.cls
* Project:     GAP
* Date:        26/11/2019
* Created By:  Adarsh Sharma
* Test Class:  SyncEventEdition_test
* *************************************************************************
* Description: Sync present event Edition from previous event edition.
* *************************************************************************
*/
global class SyncEventEdition {
    
    public syncEventEdition(){
        system.debug('initializing..');
    }
    webservice static void syncPresentEventEdition(id evntEdtn, id evntSeries){
        List<Event_Edition__c> allEvntEdtn = new List <Event_Edition__c>([Select id, name, Previous_Event_Edition__c,Part_of_Series__c,Event_Currency__c,Alternate_Currency__c,Venue__c,Measurement__c,Event_Website__c,Event_Edition_Image_URL__c,
                                                                          Logo_Shape__c,Event_Price_Book__c,No_Billing__c,All_Contract_Need_Accounting_Approval__c,Allow_Docusign_Counter_Sign__c,X1st_Stage_Email_Template__c,
                                                                          Subsequent_Email_Template__c,Quote_Template__c,Contract_Template__c,Invoice_Template__c,Credit_Note_Template__c,Credit_Note_Email_Template__c,
                                                                          Terms_Condition_Template__c,Max_Hold_Days__c,Max_Hold_Booth__c,Put_Booth_OnHold__c,Corner_Validation__c,Corner_Configuration_Check__c,
                                                                          Allow_Unrenting_Rented_booths__c from Event_Edition__c where Part_of_Series__c =: evntSeries order by name DESC]);      
        
        
        if(allEvntEdtn[0].Previous_Event_Edition__c == null){System.debug('Please choose Previous year event edition to continue');
                                                            }
        else{
            
            if(allEvntEdtn[0].Event_Currency__c == null){
                allEvntEdtn[0].Event_Currency__c = allEvntEdtn[1].Event_Currency__c;
            }
            if(allEvntEdtn[0].Alternate_Currency__c == null){
                allEvntEdtn[0].Alternate_Currency__c = allEvntEdtn[1].Alternate_Currency__c;
            }
            if(allEvntEdtn[0].Venue__c == null){
                allEvntEdtn[0].Venue__c = allEvntEdtn[1].Venue__c;
            }
            if(allEvntEdtn[0].Measurement__c == null){
                allEvntEdtn[0].Measurement__c = allEvntEdtn[1].Measurement__c;
            }
            if(allEvntEdtn[0].Event_Website__c == null){
                allEvntEdtn[0].Event_Website__c = allEvntEdtn[1].Event_Website__c;
            }
            if(allEvntEdtn[0].Event_Edition_Image_URL__c == null){
                allEvntEdtn[0].Event_Edition_Image_URL__c = allEvntEdtn[1].Event_Edition_Image_URL__c;
            }
            if(allEvntEdtn[0].Logo_Shape__c == null){
                allEvntEdtn[0].Logo_Shape__c = allEvntEdtn[1].Logo_Shape__c;
            }
            if(allEvntEdtn[0].Event_Price_Book__c == null){
                allEvntEdtn[0].Event_Price_Book__c = allEvntEdtn[1].Event_Price_Book__c;
            }
            if(allEvntEdtn[0].No_Billing__c == null){allEvntEdtn[0].No_Billing__c = allEvntEdtn[1].No_Billing__c;
                                                    }
            if(allEvntEdtn[0].All_Contract_Need_Accounting_Approval__c == null){
                allEvntEdtn[0].All_Contract_Need_Accounting_Approval__c = allEvntEdtn[1].All_Contract_Need_Accounting_Approval__c;
            }
            if(allEvntEdtn[0].Allow_Docusign_Counter_Sign__c == null){
                allEvntEdtn[0].Allow_Docusign_Counter_Sign__c = allEvntEdtn[1].Allow_Docusign_Counter_Sign__c;
            }
            if(allEvntEdtn[0].X1st_Stage_Email_Template__c == null){
                allEvntEdtn[0].X1st_Stage_Email_Template__c = allEvntEdtn[1].X1st_Stage_Email_Template__c;
            }
            if(allEvntEdtn[0].Subsequent_Email_Template__c == null){
                allEvntEdtn[0].Subsequent_Email_Template__c = allEvntEdtn[1].Subsequent_Email_Template__c;
            }
            if(allEvntEdtn[0].Quote_Template__c == null){
                allEvntEdtn[0].Quote_Template__c = allEvntEdtn[1].Quote_Template__c;
            }
            if(allEvntEdtn[0].Contract_Template__c == null){
                allEvntEdtn[0].Contract_Template__c = allEvntEdtn[1].Contract_Template__c;
            }
            if(allEvntEdtn[0].Invoice_Template__c == null){
                allEvntEdtn[0].Invoice_Template__c = allEvntEdtn[1].Invoice_Template__c;
            }
            if(allEvntEdtn[0].Credit_Note_Template__c == null){
                allEvntEdtn[0].Credit_Note_Template__c = allEvntEdtn[1].Credit_Note_Template__c;
            }
            if(allEvntEdtn[0].Credit_Note_Email_Template__c == null){
                allEvntEdtn[0].Credit_Note_Email_Template__c = allEvntEdtn[1].Credit_Note_Email_Template__c;
            }
            if(allEvntEdtn[0].Terms_Condition_Template__c == null){
                allEvntEdtn[0].Terms_Condition_Template__c = allEvntEdtn[1].Terms_Condition_Template__c;
            }
            if(allEvntEdtn[0].Max_Hold_Days__c == null){
                allEvntEdtn[0].Max_Hold_Days__c = allEvntEdtn[1].Max_Hold_Days__c;
            }
            if(allEvntEdtn[0].Max_Hold_Booth__c == null){
                allEvntEdtn[0].Max_Hold_Booth__c = allEvntEdtn[1].Max_Hold_Booth__c;
            }
            if(allEvntEdtn[0].Put_Booth_OnHold__c == null){
                allEvntEdtn[0].Put_Booth_OnHold__c = allEvntEdtn[1].Put_Booth_OnHold__c;
            }
            if(allEvntEdtn[0].Corner_Validation__c == null){
                allEvntEdtn[0].Corner_Validation__c = allEvntEdtn[1].Corner_Validation__c;
            }
            if(allEvntEdtn[0].Corner_Configuration_Check__c == null){
                allEvntEdtn[0].Corner_Configuration_Check__c = allEvntEdtn[1].Corner_Configuration_Check__c;
            }
            if(allEvntEdtn[0].Allow_Unrenting_Rented_booths__c == null){allEvntEdtn[0].Allow_Unrenting_Rented_booths__c = allEvntEdtn[1].Allow_Unrenting_Rented_booths__c;
                                                                       }
        }
        Update (allEvntEdtn[0]);
    }
    @AuraEnabled
    public static Boolean syncPresentEventEditionLtng(id evntEdtn){
        Boolean successResult;
        List<Event_Edition__c> seriesRelEvtEdtn = new List<Event_Edition__c>();
        List<Id> srsIds = new List<Id>();
        List<Event_Series__c> evtSrs = new List<Event_Series__c>([Select id from Event_Series__c]);
        for(Event_Series__c evtSeries : evtSrs){
            srsIds.add(evtSeries.Id);
        }
        Map<Id,Event_Edition__c> allEvntEdtnLtng = new Map <Id,Event_Edition__c>([Select id, name, Previous_Event_Edition__c,Part_of_Series__c,Event_Currency__c,Alternate_Currency__c,Venue__c,Measurement__c,Event_Website__c,Event_Edition_Image_URL__c,
                                                                                  Logo_Shape__c,Event_Price_Book__c,No_Billing__c,All_Contract_Need_Accounting_Approval__c,Allow_Docusign_Counter_Sign__c,X1st_Stage_Email_Template__c,
                                                                                  Subsequent_Email_Template__c,Quote_Template__c,Contract_Template__c,Invoice_Template__c,Credit_Note_Template__c,Credit_Note_Email_Template__c,
                                                                                  Terms_Condition_Template__c,Max_Hold_Days__c,Max_Hold_Booth__c,Put_Booth_OnHold__c,Corner_Validation__c,Corner_Configuration_Check__c,
                                                                                  Allow_Unrenting_Rented_booths__c from Event_Edition__c order by name DESC]);      
        
        Id partOfSrs;
        for(Event_Edition__c evtEdtn : allEvntEdtnLtng.values()){
            if(evtEdtn.Id == evntEdtn){
                partOfSrs = evtEdtn.Part_of_Series__c;
            }
            
            if(evtEdtn.Part_of_Series__c == partOfSrs && srsIds.contains(evtEdtn.Part_of_Series__c)){
                seriesRelEvtEdtn.add(evtEdtn);
            }
        }
        
        if(seriesRelEvtEdtn.get(0).Previous_Event_Edition__c == null){
            throw new AuraHandledException('Please choose Previous year event edition to continue');
        }
        
        else{
            
            if(seriesRelEvtEdtn.get(0).Event_Currency__c == null){
                seriesRelEvtEdtn.get(0).Event_Currency__c = seriesRelEvtEdtn.get(1).Event_Currency__c;
            }
            if(seriesRelEvtEdtn.get(0).Alternate_Currency__c == null){
                seriesRelEvtEdtn.get(0).Alternate_Currency__c = seriesRelEvtEdtn.get(1).Alternate_Currency__c;
            }
            if(seriesRelEvtEdtn.get(0).Venue__c == null){
                seriesRelEvtEdtn.get(0).Venue__c = seriesRelEvtEdtn.get(1).Venue__c;
            }
            if(seriesRelEvtEdtn.get(0).Measurement__c == null){
                seriesRelEvtEdtn.get(0).Measurement__c = seriesRelEvtEdtn.get(1).Measurement__c;
            }
            if(seriesRelEvtEdtn.get(0).Event_Website__c == null){
                seriesRelEvtEdtn.get(0).Event_Website__c = seriesRelEvtEdtn.get(1).Event_Website__c;
            }
            if(seriesRelEvtEdtn.get(0).Event_Edition_Image_URL__c == null){
                seriesRelEvtEdtn.get(0).Event_Edition_Image_URL__c = seriesRelEvtEdtn.get(1).Event_Edition_Image_URL__c;
            }
            if(seriesRelEvtEdtn.get(0).Logo_Shape__c == null){
                seriesRelEvtEdtn.get(0).Logo_Shape__c = seriesRelEvtEdtn.get(1).Logo_Shape__c;
            }
            if(seriesRelEvtEdtn.get(0).Event_Price_Book__c == null){
                seriesRelEvtEdtn.get(0).Event_Price_Book__c = seriesRelEvtEdtn.get(1).Event_Price_Book__c;
            }
            if(seriesRelEvtEdtn.get(0).No_Billing__c == null){seriesRelEvtEdtn.get(0).No_Billing__c = seriesRelEvtEdtn.get(1).No_Billing__c;
                                                             }
            if(seriesRelEvtEdtn.get(0).All_Contract_Need_Accounting_Approval__c == null){
                seriesRelEvtEdtn.get(0).All_Contract_Need_Accounting_Approval__c = seriesRelEvtEdtn.get(1).All_Contract_Need_Accounting_Approval__c;
            }
            if(seriesRelEvtEdtn.get(0).Allow_Docusign_Counter_Sign__c == null){
                seriesRelEvtEdtn.get(0).Allow_Docusign_Counter_Sign__c = seriesRelEvtEdtn.get(1).Allow_Docusign_Counter_Sign__c;
            }
            if(seriesRelEvtEdtn.get(0).X1st_Stage_Email_Template__c == null){
                seriesRelEvtEdtn.get(0).X1st_Stage_Email_Template__c = seriesRelEvtEdtn.get(1).X1st_Stage_Email_Template__c;
            }
            if(seriesRelEvtEdtn.get(0).Subsequent_Email_Template__c == null){
                seriesRelEvtEdtn.get(0).Subsequent_Email_Template__c = seriesRelEvtEdtn.get(1).Subsequent_Email_Template__c;
            }
            if(seriesRelEvtEdtn.get(0).Quote_Template__c == null){
                seriesRelEvtEdtn.get(0).Quote_Template__c = seriesRelEvtEdtn.get(1).Quote_Template__c;
            }
            if(seriesRelEvtEdtn.get(0).Contract_Template__c == null){
                seriesRelEvtEdtn.get(0).Contract_Template__c = seriesRelEvtEdtn.get(1).Contract_Template__c;
            }
            if(seriesRelEvtEdtn.get(0).Invoice_Template__c == null){
                seriesRelEvtEdtn.get(0).Invoice_Template__c = seriesRelEvtEdtn.get(1).Invoice_Template__c;
            }
            if(seriesRelEvtEdtn.get(0).Credit_Note_Template__c == null){
                seriesRelEvtEdtn.get(0).Credit_Note_Template__c = seriesRelEvtEdtn.get(1).Credit_Note_Template__c;
            }
            if(seriesRelEvtEdtn.get(0).Credit_Note_Email_Template__c == null){
                seriesRelEvtEdtn.get(0).Credit_Note_Email_Template__c = seriesRelEvtEdtn.get(1).Credit_Note_Email_Template__c;
            }
            if(seriesRelEvtEdtn.get(0).Terms_Condition_Template__c == null){
                seriesRelEvtEdtn.get(0).Terms_Condition_Template__c = seriesRelEvtEdtn.get(1).Terms_Condition_Template__c;
            }
            if(seriesRelEvtEdtn.get(0).Max_Hold_Days__c == null){
                seriesRelEvtEdtn.get(0).Max_Hold_Days__c = seriesRelEvtEdtn.get(1).Max_Hold_Days__c;
            }
            if(seriesRelEvtEdtn.get(0).Max_Hold_Booth__c == null){
                seriesRelEvtEdtn.get(0).Max_Hold_Booth__c = seriesRelEvtEdtn.get(1).Max_Hold_Booth__c;
            }
            if(seriesRelEvtEdtn.get(0).Put_Booth_OnHold__c == null){
                seriesRelEvtEdtn.get(0).Put_Booth_OnHold__c = seriesRelEvtEdtn.get(1).Put_Booth_OnHold__c;
            }
            if(seriesRelEvtEdtn.get(0).Corner_Validation__c == null){
                seriesRelEvtEdtn.get(0).Corner_Validation__c = seriesRelEvtEdtn.get(1).Corner_Validation__c;
            }
            if(seriesRelEvtEdtn.get(0).Corner_Configuration_Check__c == null){
                seriesRelEvtEdtn.get(0).Corner_Configuration_Check__c = seriesRelEvtEdtn.get(1).Corner_Configuration_Check__c;
            }
            if(seriesRelEvtEdtn.get(0).Allow_Unrenting_Rented_booths__c == null){seriesRelEvtEdtn.get(0).Allow_Unrenting_Rented_booths__c = seriesRelEvtEdtn.get(1).Allow_Unrenting_Rented_booths__c;
                                                                                }
        }
        if(!seriesRelEvtEdtn.IsEmpty()){
            Database.SaveResult sr = Database.update(seriesRelEvtEdtn.get(0));   
            if(sr.isSuccess()){
                successResult = true;
            }
        }
        return successResult;
    }
}