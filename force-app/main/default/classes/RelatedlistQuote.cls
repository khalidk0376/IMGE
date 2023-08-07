/**
* File:        RelatedlistQuote 
* Project:     GAP
* Date:        16/1/2018 1:54 PM
* Created By:  Rajesh Kumar
* Test Class:  RelatedlistQuote_Test
* *************************************************************************
* @description This class is used in "QuoteTriggerMarge" Trigger.
* *************************************************************************
* History: 
* Last Modification BY Rajesh Kumar Yadav For Jira Ticket GGCW-2085 On 7/2/18
* Modified By Rajesh Kumar - GGCW-2925 - 17 Jan - 2019 
* Modified By : Rajesh Kumar 21/02/2019 on GGCW-GGCW-2997
* Modified By Rajesh Kumar On 25/02/2019 : Ticket # GGCW-2358
* Modified By Avinash Shukla On 28/08/2019 : Ticket # BK-2281
* Modified By Avinash Shukla On 17/10/2019 : Ticket # BK-2775
* Modified By Akshi Arora on 9/1/2020      : Ticket # BK-2974
* Modified By Rajesh Kumar : BK-11940 - 20-01-2021
*/
public without sharing class RelatedlistQuote {
  
    List<SBQQ__Quote__c> newQuoteLst        { get; set; }
    Map<Id, SBQQ__Quote__c> oldQuoteMap     { get; set; }
    Boolean isInsert                        { get; set; }
    Boolean isupdate                        { get; set; }
    Boolean isBefore                        { get; set; }
    Boolean isAfter                         { get; set; }
    List<SBQQ__QuoteLine__c> qlList         { get; set; }
    Set<Id> setQuoteIds                     { get; set; }
    Set<String> boothNumberString           { get; set; }
    String lblQuoteApprovedMessage        { get; set; }
    set<Id> setContact;
    set<Id> setOppId;
    Map<Id, Opportunity> mapOppty           { get; set; }
    List<Opportunity> lstUpdateOpp          { get; Set; }
    /**
     * [RelatedlistQuote description]
     * @param  newQuoteLst [List of records]
     * @param  oldQuoteMap [Map of sobject record]
     * @param  isInsert    [Insert action]
     * @param  isupdate    [Update]
     * @param  isBefore    [before]
     * @param  isAfter     [after]
     * @return             [null]
     */
    public RelatedlistQuote( List<SBQQ__Quote__c> newQuoteLst, Map<id, SBQQ__Quote__c> oldQuoteMap, Boolean isInsert, Boolean isupdate, Boolean isBefore, Boolean isAfter ) {
        this.newQuoteLst  = newQuoteLst; 
        this.oldQuoteMap  = oldQuoteMap;
        this.isInsert     = isInsert;
        this.isupdate     = isupdate;
        this.isBefore     = isBefore;
        this.isAfter      = isAfter;
        qlList            = new List<SBQQ__QuoteLine__c>( );
        setQuoteIds       = new Set<Id>( );
        lblQuoteApprovedMessage = ''; 
        boothNumberString = new Set<String>( );
        setContact = new set<Id>();
        setOppId    = new set<id>();
        lstUpdateOpp = new List<Opportunity> ();
        
    }
    /**
     * [quoteRelatedList quoteRelatedList method calling form Quote Document trigger]
     */
    public void quoteRelatedList( ) {
        try{
            system.debug('newQuoteLst' + newQuoteLst);
            for( SBQQ__Quote__c qut : newQuoteLst ) {
                if( qut.SBQQ__Opportunity2__c != null ) {
                    setOppId.add(qut.SBQQ__Opportunity2__c );
                }
            }
            if (setOppId != null){
                mapOppty = new Map<Id, Opportunity>([SELECT Id, Opportunity_Contact__r.Id , Contract_Attached__c , SBQQ__Contracted__c , CurrencyIsoCode , Event_Edition_Currency__c, Billing_Contact__r.Account.BillingCountryCode ,Billing_Contact__r.Account.Name , Billing_Contact__r.Account.BillingPostalCode, Billing_Contact__r.Account.BillingState, Billing_Contact__r.Account.BillingStreet, Billing_Contact__r.Account.Billing_Address_Line_2__c,  Billing_Contact__r.Account.BillingCity, Billing_Contact__r.Account.BillingCountry, StageName , SBQQ__PrimaryQuote__c , SBQQ__PrimaryQuote__r.SBQQ__Status__c ,SBQQ__PrimaryQuote__r.SBQQ__Primary__c , SBQQ__PrimaryQuote__r.IsCreatedByReviewProcess__c ,  SBQQ__PrimaryQuote__r.Manual__c, Quoted_Payment_Schedule__c, (Select id, SBQQ__Status__c, Payment_Schedule_percent1__c from SBQQ__Quotes2__r) FROM Opportunity WHERE Id IN: setOppId]);
            }

            if( isBefore && isInsert) {
                if (mapOppty != null){
                    String addressString  = '';
                    for (SBQQ__Quote__c oQuoteAsigned : newQuoteLst){
                        if( oQuoteAsigned.SBQQ__Opportunity2__c != null  && mapOppty.containsKey(oQuoteAsigned.SBQQ__Opportunity2__c)){
                            oQuoteAsigned.CurrencyIsoCode  = mapOppty.get(oQuoteAsigned.SBQQ__Opportunity2__c).CurrencyIsoCode;
                            oQuoteAsigned.EventCurrency__c = mapOppty.get(oQuoteAsigned.SBQQ__Opportunity2__c).Event_Edition_Currency__c;
                            //GGCW-2085
                            oQuoteAsigned.Billing_Country_ISO__c = mapOppty.get(oQuoteAsigned.SBQQ__Opportunity2__c).Billing_Contact__r.Account.BillingCountryCode;
                            //Update Addressontemplate on Quote creation.
                            
                            addressString = mapOppty.get(oQuoteAsigned.SBQQ__Opportunity2__c).Billing_Contact__r.Account.BillingStreet != null ? mapOppty.get(oQuoteAsigned.SBQQ__Opportunity2__c).Billing_Contact__r.Account.BillingStreet + '\n' : '';
                            addressString += mapOppty.get(oQuoteAsigned.SBQQ__Opportunity2__c).Billing_Contact__r.Account.Billing_Address_Line_2__c != null ? mapOppty.get(oQuoteAsigned.SBQQ__Opportunity2__c).Billing_Contact__r.Account.Billing_Address_Line_2__c + '\n' : '';
                            if (string.isBlank(mapOppty.get(oQuoteAsigned.SBQQ__Opportunity2__c).Billing_Contact__r.Account.BillingState) && string.isBlank(mapOppty.get(oQuoteAsigned.SBQQ__Opportunity2__c).Billing_Contact__r.Account.Billingpostalcode)) {
                                addressString += mapOppty.get(oQuoteAsigned.SBQQ__Opportunity2__c).Billing_Contact__r.Account.BillingCity != null ? mapOppty.get(oQuoteAsigned.SBQQ__Opportunity2__c).Billing_Contact__r.Account.BillingCity : ''; } else { addressString += mapOppty.get(oQuoteAsigned.SBQQ__Opportunity2__c).Billing_Contact__r.Account.BillingCity != null ? mapOppty.get(oQuoteAsigned.SBQQ__Opportunity2__c).Billing_Contact__r.Account.BillingCity + ', ' : '';
                            }
                            addressString += mapOppty.get(oQuoteAsigned.SBQQ__Opportunity2__c).Billing_Contact__r.Account.BillingState != null ? mapOppty.get(oQuoteAsigned.SBQQ__Opportunity2__c).Billing_Contact__r.Account.BillingState + ' ' : '';
                            addressString += mapOppty.get(oQuoteAsigned.SBQQ__Opportunity2__c).Billing_Contact__r.Account.Billingpostalcode != null ? mapOppty.get(oQuoteAsigned.SBQQ__Opportunity2__c).Billing_Contact__r.Account.Billingpostalcode + '\n' : '\n';
                            addressString += mapOppty.get(oQuoteAsigned.SBQQ__Opportunity2__c).Billing_Contact__r.Account.BillingCountry != null ? mapOppty.get(oQuoteAsigned.SBQQ__Opportunity2__c).Billing_Contact__r.Account.BillingCountry + '\n' : '';
                            if (String.isNotBlank (addressString)){ oQuoteAsigned.AddressOnTemplate__c = addressString;
                            }
                        }
                    } 
                }
            }
            
            if( isBefore && isUpdate ) {   
                
                for( SBQQ__Quote__c oQuoteTemp: newQuoteLst ) {
                   
                    //Below Code, We are getting the Contact Id From Quote and set It Into "setContact"
                    if(oldQuoteMap.get( oQuoteTemp.Id ).Billing_Contact__c != oQuoteTemp.Billing_Contact__c)
                    {  
                        setContact.add( oQuoteTemp.Billing_Contact__c);                         
                    }
                    
                    if( Utility.isReviewProcess == false && oQuoteTemp.IsCreatedByReviewProcess__c == false  && oQuoteTemp.SBQQ__Opportunity2__c != null) 
                    { 
                       setQuoteIds.add( oQuoteTemp.id );  
                    }
                    
                    if( oldQuoteMap.get( oQuoteTemp.Id ).Quote_Available_Currency__c != oQuoteTemp.Quote_Available_Currency__c ) 
                    { 
                        oQuoteTemp.CurrencyIsoCode = oQuoteTemp.Quote_Available_Currency__c;
                    }
                    
                    if( oQuoteTemp.EE_Payment_Schedule__c != null && oQuoteTemp.EE_Payment_Schedule__c != '' ) {
                        if( oQuoteTemp.EE_Payment_Schedule__c == '100' ) {oQuoteTemp.Pay_Sch_Amt__c = oQuoteTemp.ISO_Code_Logo__c + string.valueof((oQuoteTemp.SBQQ__NetAmount__c)) + '\n' + oQuoteTemp.ISO_Code_Logo__c + string.valueof((oQuoteTemp.SBQQ__NetAmount__c));}
                        if( oQuoteTemp.EE_Payment_Schedule__c == '50-50' ) { oQuoteTemp.Pay_Sch_Amt__c = oQuoteTemp.ISO_Code_Logo__c + string.valueof((oQuoteTemp.SBQQ__NetAmount__c * 0.50).setScale(2)) + '\n' + oQuoteTemp.ISO_Code_Logo__c + string.valueof((oQuoteTemp.SBQQ__NetAmount__c * 0.50).setScale(2)); }
                        if( oQuoteTemp.EE_Payment_Schedule__c == '10-45-45' ){ oQuoteTemp.Pay_Sch_Amt__c = oQuoteTemp.ISO_Code_Logo__c + string.valueof((oQuoteTemp.SBQQ__NetAmount__c * 0.10).setScale(2)) + '\n' + oQuoteTemp.ISO_Code_Logo__c + string.valueof((oQuoteTemp.SBQQ__NetAmount__c * 0.45).setScale(2)) + '\n' + oQuoteTemp.ISO_Code_Logo__c + string.valueof((oQuoteTemp.SBQQ__NetAmount__c * 0.45).setScale(2)); }
                        if( oQuoteTemp.EE_Payment_Schedule__c == '10-40-50' ) {  oQuoteTemp.Pay_Sch_Amt__c = oQuoteTemp.ISO_Code_Logo__c + string.valueof((oQuoteTemp.SBQQ__NetAmount__c * 0.10).setScale(2)) + '\n' + oQuoteTemp.ISO_Code_Logo__c + string.valueof((oQuoteTemp.SBQQ__NetAmount__c * 0.40).setScale(2)) + '\n' + oQuoteTemp.ISO_Code_Logo__c + string.valueof((oQuoteTemp.SBQQ__NetAmount__c * 0.50).setScale(2)); }
                        if( oQuoteTemp.EE_Payment_Schedule__c == '25-25-50' ) {  oQuoteTemp.Pay_Sch_Amt__c = oQuoteTemp.ISO_Code_Logo__c + string.valueof((oQuoteTemp.SBQQ__NetAmount__c * 0.25).setScale(2)) + '\n' + oQuoteTemp.ISO_Code_Logo__c + string.valueof((oQuoteTemp.SBQQ__NetAmount__c * 0.25).setScale(2)) + '\n' + oQuoteTemp.ISO_Code_Logo__c + string.valueof((oQuoteTemp.SBQQ__NetAmount__c * 0.50).setScale(2)); }
                        if( oQuoteTemp.EE_Payment_Schedule__c == '25-25-25-25' ) { oQuoteTemp.Pay_Sch_Amt__c = oQuoteTemp.ISO_Code_Logo__c + string.valueof((oQuoteTemp.SBQQ__NetAmount__c * 0.25).setScale(2)) + '\n' + oQuoteTemp.ISO_Code_Logo__c + string.valueof((oQuoteTemp.SBQQ__NetAmount__c * 0.25).setScale(2)) + '\n' + oQuoteTemp.ISO_Code_Logo__c + string.valueof((oQuoteTemp.SBQQ__NetAmount__c * 0.25).setScale(2)) + '\n' + oQuoteTemp.ISO_Code_Logo__c + string.valueof((oQuoteTemp.SBQQ__NetAmount__c * 0.25).setScale(2)); }
                    }
                    
                    if (mapOppty.values().size() > 0){
                        for (Opportunity opp : mapOppty.values()){
                            opp.Quoted_Payment_Schedule__c = oQuoteTemp.Payment_Schedule_percent1__c;
                        }
                    }
                    
                    //BK-2281 - Modified By Avinash Shukla
                    //BK-2775 - Modified By Avinash Shukla
                    If(mapOppty.containsKey(oQuoteTemp.SBQQ__Opportunity2__c)){
                        If(oQuoteTemp.SBQQ__BillingName__c != mapOppty.get(oQuoteTemp.SBQQ__Opportunity2__c).Billing_Contact__r.Account.Name){    oQuoteTemp.SBQQ__BillingName__c = mapOppty.get(oQuoteTemp.SBQQ__Opportunity2__c).Billing_Contact__r.Account.Name;}
                        If(oQuoteTemp.SBQQ__BillingStreet__c != mapOppty.get(oQuoteTemp.SBQQ__Opportunity2__c).Billing_Contact__r.Account.BillingStreet){    oQuoteTemp.SBQQ__BillingStreet__c = mapOppty.get(oQuoteTemp.SBQQ__Opportunity2__c).Billing_Contact__r.Account.BillingStreet;}
                        If(oQuoteTemp.SBQQ__BillingCity__c != mapOppty.get(oQuoteTemp.SBQQ__Opportunity2__c).Billing_Contact__r.Account.BillingCity){  oQuoteTemp.SBQQ__BillingCity__c = mapOppty.get(oQuoteTemp.SBQQ__Opportunity2__c).Billing_Contact__r.Account.BillingCity;}
                        If(oQuoteTemp.SBQQ__BillingState__c != mapOppty.get(oQuoteTemp.SBQQ__Opportunity2__c).Billing_Contact__r.Account.BillingState){   oQuoteTemp.SBQQ__BillingState__c = mapOppty.get(oQuoteTemp.SBQQ__Opportunity2__c).Billing_Contact__r.Account.BillingState;}
                        If(oQuoteTemp.SBQQ__BillingPostalCode__c != mapOppty.get(oQuoteTemp.SBQQ__Opportunity2__c).Billing_Contact__r.Account.BillingPostalCode){    oQuoteTemp.SBQQ__BillingPostalCode__c = mapOppty.get(oQuoteTemp.SBQQ__Opportunity2__c).Billing_Contact__r.Account.BillingPostalCode;}
                        If(oQuoteTemp.SBQQ__BillingCountry__c != mapOppty.get(oQuoteTemp.SBQQ__Opportunity2__c).Billing_Contact__r.Account.BillingCountry){ oQuoteTemp.SBQQ__BillingCountry__c = mapOppty.get(oQuoteTemp.SBQQ__Opportunity2__c).Billing_Contact__r.Account.BillingCountry;}
                    }
                }

                //Update Opportunity Stage first quote creation : GGCW-2925 
                if (mapOppty.values().size() > 0){
                    for (Opportunity opp : mapOppty.values()){
                        if(mapOppty.get(opp.Id).SBQQ__Quotes2__r !=null && mapOppty.get(opp.Id).SBQQ__Quotes2__r.size() > 0 && mapOppty.get(opp.Id).SBQQ__Quotes2__r.size() == 1 && mapOppty.get(opp.Id).SBQQ__PrimaryQuote__r.SBQQ__Status__c == 'Draft' && mapOppty.get(opp.Id).StageName == 'Discover' && mapOppty.get(opp.Id).SBQQ__PrimaryQuote__r.SBQQ__Primary__c){ opp.StageName = 'Customize';
                            Opp.Status__c = '';
                        }
                    }
                }
                
                if (mapOppty.values().size() > 0){
                    update mapOppty.values();
                }
                 
                
                //GGCW-2085
                //Start
                if(setContact != null && setContact.size() > 0){
                    Map<Id, String> mapCountryCode = new Map<Id, String>();
                    List<Contact> lstContact = new List<Contact> ();
                    if (!Schema.sObjectType.Contact.fields.AccountId.isAccessible()){
                      ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Error: Insufficient Access'));
                    }
                    else {
                        lstContact = [SELECT Id, Account.BillingCountryCode FROM Contact WHERE Id IN:setContact];
                    }
                    
                    if( lstContact != null && lstContact.size() > 0){
                        for(Contact oContact: lstContact){ mapCountryCode.put(oContact.Id, oContact.Account.BillingCountryCode); }
                    }
                    //In below Iteration we are trying to set the Billing Country Iso Code 
                    for( SBQQ__Quote__c qtSBQQQuote: newQuoteLst ) { qtSBQQQuote.Billing_Country_ISO__c = mapCountryCode.get(qtSBQQQuote.Billing_Contact__c); }
                }
                //END   
                Map<Id,List<SBQQ__QuoteLine__c>> deliverableMap = new Map<id,list<SBQQ__QuoteLine__c>>( );
                if( setQuoteIds.size( ) > 0) {
                    if (!Schema.sObjectType.SBQQ__QuoteLine__c.fields.Deliverables__c.isAccessible()){ ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Error: Insufficient Access'));
                    }
                    else {
                        qlList = [ Select id,name,Deliverables__c,SBQQ__Quote__c,Event_Edition_Name__c,SBQQ__Quote__r.id,SBQQ__Product__r.name, SBQQ__Product__r.Deliverables__c,SBQQ__Product__r.Event_Edition_Name__c,SBQQ__ProductName__c,SBQQ__Product__c,SBQQ__Product__r.Event_Product_Type__c ,Booth_Number__c,ProductBrand__c from SBQQ__QuoteLine__c where SBQQ__Quote__c IN : setQuoteIds]; 
                    }
                }
                   
                if( setQuoteIds.Size() > 0 ) {
                    lblQuoteApprovedMessage = System.Label.Quote_Approved_Message;
                    for( SBQQ__Quote__c qt : newQuoteLst ) {
                        qt.Quote_Line_Deliverables__c = '';
                        qt.Booth_No_s__c='';
                        SBQQ__Quote__c oldoquote = oldQuoteMap.get( qt.Id );
                        if( qlList.size( ) > 0 ) {
                            Set<String> s = new Set<String>( );
                            List<String> htmlbody = new List<String>( );
                            String prodString='';
                            for( integer i = 0; i < qlList.size( ); i++ ) {
                                boothNumberString.add(qlList[i].Booth_Number__c);
                                if( deliverableMap.get( qlList[i].SBQQ__Quote__c ) == null ) { deliverableMap.put( qlList[i].SBQQ__Quote__c,new list<SBQQ__QuoteLine__c>{qlList[i]} );} else { deliverableMap.get( qlList[i].SBQQ__Quote__c ).add( qlList[i] );    }
                            } 
                            qt.Booth_No_s__c= qt.Booth_No_s__c.removeEnd(';');
                            if( deliverableMap.size() > 0 && deliverableMap.get( qt.id ) != null ) {
                                for( SBQQ__QuoteLine__c  qli : deliverableMap.get( qt.id ) ) {                                
                                    if( qli.SBQQ__Product__r.Event_Product_Type__c == 'Sponsorship' ) { prodString = 'Sponsorship benifits :'; }
                                    if( qli.SBQQ__Product__r.Event_Product_Type__c != 'Sponsorship' ) { prodString = ' includes :'; }
                                    if( qli.Deliverables__c !=null && qli.Deliverables__c!='' ) { qt.Quote_Line_Deliverables__c = qt.Quote_Line_Deliverables__c + '<b>'+( qli.Event_Edition_Name__c !=null && !qt.Quote_Line_Deliverables__c.contains(qli.Event_Edition_Name__c) ?qli.Event_Edition_Name__c: '' ) +'<br>' + ( qli.SBQQ__ProductName__c!=null?qli.SBQQ__ProductName__c:'' ) +  prodString  +'</b><br>' + ( qli.Deliverables__c!=null?qli.Deliverables__c:'' )+'<br><br>'; }
                                }
                            }
                            if( ! String.isBlank( qt.Quote_Line_Deliverables__c ) ) {  qt.Quote_Line_Deliverables__c = '<html><b>'+ 'Deliverables : </b>' +'<br>'+ qt.Quote_Line_Deliverables__c+'</html>'; }
                            for( String st : boothNumberString ) {  if( st!=null )  { qt.Booth_No_s__c += st+';';} }         
                            qt.Booth_No_s__c= qt.Booth_No_s__c.removeEnd(';');   
                        } 
                    } 
                }
            }
            for( SBQQ__Quote__c oQuoteTemp : newQuoteLst ) {
                if (oQuoteTemp.EE_Payment_Schedule__c != null && oQuoteTemp.EE_Payment_Schedule__c != '') {
                    List<String> args = new String[]{'0','number','###,###,##0.00'};
                    if (oQuoteTemp.EE_Payment_Schedule__c == '100'){ decimal d = oQuoteTemp.SBQQ__NetAmount__c.setScale(2)*0.50;
                        oQuoteTemp.first_payment__c =  oQuoteTemp.ISO_Code_Logo__c + String.format(d.setScale(2).format(), args);
                        oQuoteTemp.Pay_Sch_Amt__c = oQuoteTemp.ISO_Code__c ;
                    }

                    if (oQuoteTemp.EE_Payment_Schedule__c == '50-50'){ decimal d = oQuoteTemp.SBQQ__NetAmount__c.setScale(2)*0.50;
                        String s = String.format(d.setScale(2).format(),args).contains('.') ? String.format(d.setScale(2).format(), args) : String.format(d.setScale(2).format(), args)+'.00';
                        oQuoteTemp.first_payment__c=oQuoteTemp.ISO_Code_Logo__c+String.format(d.setScale(2).format(), args);
                        oQuoteTemp.Pay_Sch_Amt__c = oQuoteTemp.ISO_Code__c +' '+ s + '\n' + oQuoteTemp.ISO_Code__c+' '+   s;
                    }

                    if( oQuoteTemp.EE_Payment_Schedule__c == '10-45-45') {
                        decimal d1 = oQuoteTemp.SBQQ__NetAmount__c.setScale(2)*0.10;
                        decimal d2 = oQuoteTemp.SBQQ__NetAmount__c.setScale(2)*0.45;
                        decimal d3 = oQuoteTemp.SBQQ__NetAmount__c.setScale(2)*0.45;
                        oQuoteTemp.first_payment__c=oQuoteTemp.ISO_Code_Logo__c+String.format(d1.setScale(2).format(), args);
                        String s1 = String.format(d1.setScale(2).format(),args).contains('.') ? String.format(d1.setScale(2).format(), args) : String.format(d1.setScale(2).format(), args)+'.00';
                        String s2 = String.format(d2.setScale(2).format(),args).contains('.') ? String.format(d2.setScale(2).format(), args) : String.format(d3.setScale(2).format(), args)+'.00';
                        String s3 = String.format(d3.setScale(2).format(),args).contains('.') ? String.format(d3.setScale(2).format(), args) : String.format(d3.setScale(2).format(), args)+'.00';
                        oQuoteTemp.Pay_Sch_Amt__c = oQuoteTemp.ISO_Code__c+' '+ s1 + '\n' + oQuoteTemp.ISO_Code__c+' '+ s2 + '\n' + oQuoteTemp.ISO_Code__c+' '+   s3;
                    }
                    if (oQuoteTemp.EE_Payment_Schedule__c == '10-40-50') {    
                        decimal d1 = oQuoteTemp.SBQQ__NetAmount__c.setScale(2)*0.10;
                        decimal d2 = oQuoteTemp.SBQQ__NetAmount__c.setScale(2)*0.40;
                        decimal d3 = oQuoteTemp.SBQQ__NetAmount__c.setScale(2)*0.50;
                        oQuoteTemp.first_payment__c=oQuoteTemp.ISO_Code_Logo__c+String.format(d1.setScale(2).format(), args);
                        String s1 = String.format(d1.setScale(2).format(),args).contains('.') ? String.format(d1.setScale(2).format(), args) : String.format(d1.setScale(2).format(), args)+'.00';
                        String s2 = String.format(d2.setScale(2).format(),args).contains('.') ? String.format(d2.setScale(2).format(), args) : String.format(d3.setScale(2).format(), args)+'.00';
                        String s3 = String.format(d3.setScale(2).format(),args).contains('.') ? String.format(d3.setScale(2).format(), args) : String.format(d3.setScale(2).format(), args)+'.00';
                        oQuoteTemp.Pay_Sch_Amt__c = oQuoteTemp.ISO_Code__c+' '+  s1 + '\n' + oQuoteTemp.ISO_Code__c+' '+ s2 + '\n' + oQuoteTemp.ISO_Code__c+' '+   s3;
                    }
                    
                    if( oQuoteTemp.EE_Payment_Schedule__c == '25-25-50' ) {
                        decimal d1 = oQuoteTemp.SBQQ__NetAmount__c.setScale(2)*0.25;
                        decimal d3 = oQuoteTemp.SBQQ__NetAmount__c.setScale(2)*0.50;
                        oQuoteTemp.first_payment__c=oQuoteTemp.ISO_Code_Logo__c+String.format(d1.setScale(2).format(), args);
                        String s1 = String.format(d1.setScale(2).format(),args).contains('.') ? String.format(d1.setScale(2).format(), args) : String.format(d1.setScale(2).format(), args)+'.00';
                        String s3 = String.format(d3.setScale(2).format(),args).contains('.') ? String.format(d3.setScale(2).format(), args) : String.format(d3.setScale(2).format(), args)+'.00';    
                        oQuoteTemp.Pay_Sch_Amt__c = oQuoteTemp.ISO_Code__c+' '+  s1 + '\n' + oQuoteTemp.ISO_Code__c+' '+  s1 + '\n' + oQuoteTemp.ISO_Code__c+' '+  s3;
                    }
                    if (oQuoteTemp.EE_Payment_Schedule__c == '25-25-25-25') {
                        decimal d1 = oQuoteTemp.SBQQ__NetAmount__c.setScale(2)*0.25;
                        oQuoteTemp.first_payment__c=oQuoteTemp.ISO_Code_Logo__c+String.format(d1.setScale(2).format(), args);
                        String s1 = String.format(d1.setScale(2).format(),args).contains('.') ? String.format(d1.setScale(2).format(), args) : String.format(d1.setScale(2).format(), args)+'.00';
                        oQuoteTemp.Pay_Sch_Amt__c = oQuoteTemp.ISO_Code__c+' '+   s1 + '\n' + oQuoteTemp.ISO_Code__c+' '+   s1 + '\n' + oQuoteTemp.ISO_Code__c+' '+   s1 + '\n' + oQuoteTemp.ISO_Code__c+' '+  s1;
                    }
                }
                String sClosedErrorMsg = System.Label.closed_booked_won_and_lost_message;
                Application_Bypass__c appBypass = Application_Bypass__c.getInstance();
                If(mapOppty != null && oQuoteTemp.SBQQ__Opportunity2__c != null){
                    String opptyStageName = mapOppty.get(oQuoteTemp.SBQQ__Opportunity2__c).StageName ;
                    if ( String.isNotBlank(opptyStageName) && (opptyStageName == 'Closed Won' || opptyStageName == 'Closed Lost' || opptyStageName == 'Closed Booked') && !appBypass.Bypass_Validation_Rules__c && !Utility.isAsync() && Utility.byPassClosedWon == false && oQuoteTemp.ownerId == mapOppty.get(oQuoteTemp.SBQQ__Opportunity2__c).OwnerId ){ oQuoteTemp.addError(sClosedErrorMsg  +' '+opptyStageName);
                   }
                }
            }           
        } 
        catch(Exception ex){
             Utility.logError(ex.getMessage(), ex.getCause(), ex.getLineNumber(), ex.getStackTraceString(), 'RelatedlistQuote Class for updating Currency,Event Series, Pricebook on Opportunity(OpportunityTriggerMerge)');
        }
    } 
}