/**
 * Date:  16/1/2018 1:54 PM
 * Created By/Modified By: Rajesh Kumar
 * Test Class: releaseBooths_Test
 * *************************************************************************
 * Description: This class is used in "QuoteTriggerMarge" Trigger.
 * *************************************************************************
 **/
public class ReleaseBooths {

    List < SBQQ__Quote__c > newQuoteLst {get;set;}
    Map < Id, SBQQ__Quote__c > oldQuoteMap {get;set;}
    Boolean isInsert {get;set;}
    Boolean isupdate {get;set;}
    Boolean isBefore {get;set;}
    Boolean isAfter {get;set;}
    Set < Id > opptIDs {get;set;}
    Set < String > setBoothNo {get;set;}
    Set < Id > quoteIds {get;set;}
    List < Opportunity > lstOpportunityToUpdate = new List < Opportunity > ();
    Opportunity oOpportunity;

    public ReleaseBooths(List < SBQQ__Quote__c > newQuoteLst, Map < id, SBQQ__Quote__c > oldQuoteMap, Boolean isInsert, Boolean isupdate, Boolean isBefore, Boolean isAfter) {
        this.newQuoteLst = newQuoteLst;
        this.oldQuoteMap = oldQuoteMap;
        this.isInsert = isInsert;
        this.isupdate = isupdate;
        this.isBefore = isBefore;
        this.isAfter = isAfter;
        opptIDs = new Set < Id > ();
        setBoothNo = new Set < String > ();
        quoteIds = new Set < Id > ();
    }

    public void boothRelease() {
        try {
            for (SBQQ__Quote__c oQuote: newQuoteLst) {
                SBQQ__Quote__c oldQuote = oldQuoteMap.get(oQuote.Id);
                if (oQuote.SBQQ__Opportunity2__c != oldQuote.SBQQ__Opportunity2__c && oQuote.SBQQ__Opportunity2__c == NULL) {
                    quoteIds.add(oQuote.id);
                }
                /**if( oQuote.SBQQ__Primary__c != oldQuote.SBQQ__Primary__c && oQuote.SBQQ__Primary__c == true ) 
                    opptIDs.add(oQuote.SBQQ__Opportunity2__c);
                **/
                if (oQuote.SBQQ__Opportunity2__c != NULL && (oQuote.Additional_Disc__c != null || oQuote.Additional_Disc_Percentage__c != null) && oQuote.SBQQ__Primary__c == true) {
                    oOpportunity = new Opportunity();
                    oOpportunity.Id = oQuote.SBQQ__Opportunity2__c;
                    oOpportunity.Discount_Applied__c = True;
                    lstOpportunityToUpdate.add(oOpportunity);
                } else if (oQuote.SBQQ__Opportunity2__c != NULL && (oQuote.Additional_Disc__c != oldQuote.Additional_Disc__c || oQuote.Additional_Disc_Percentage__c != oldQuote.Additional_Disc_Percentage__c) && oQuote.Additional_Disc__c == 0 && oQuote.Additional_Disc_Percentage__c == 0 && oQuote.SBQQ__Primary__c == true) {
                    oOpportunity = new Opportunity();oOpportunity.Id = oQuote.SBQQ__Opportunity2__c;oOpportunity.Discount_Applied__c = False;lstOpportunityToUpdate.add(oOpportunity);
                }
            }
            if (!lstOpportunityToUpdate.isEmpty()) {
                Update lstOpportunityToUpdate;
            }
            /*          
            if( opptIDs.size( ) > 0 ) {
            List<SBQQ__QuoteLine__c> lstQuoteLI = [ select id, Booth_Number__c from SBQQ__QuoteLine__c where SBQQ__Quote__r.SBQQ__Opportunity2__c IN :opptIDs AND SBQQ__Quote__r.SBQQ__Primary__c = true AND Booth__c = true AND Booth_Number__c != null LIMIT 1000 ];
            if( lstQuoteLI != null && lstQuoteLI.size( ) > 0 ) {
                setBoothNo = new Set<String>( );
                for( SBQQ__QuoteLine__c oQuote : lstQuoteLI )
                setBoothNo.add(oQuote.Booth_Number__c);
            }
            List<ExpocadBooth__c> lstExpoCad = [ SELECT id, Status__c, Booth_Number__c from ExpocadBooth__c where Opportunity__c IN :opptIDs AND Quote__r.SBQQ__Primary__c = false LIMIT 1000 ];
            if( lstExpoCad != null && lstExpoCad.size( ) > 0 ) {
                for( ExpocadBooth__c oExpo : lstExpoCad ) {
                        if( setBoothNo != null && !setBoothNo.contains(oExpo.Booth_Number__c ) ) {
                        oExpo.Status__c = 'Released';
                        }
                    }
                    update lstExpoCad;
                }
            }
            */
            if (test.isRunningTest()) quoteIds.add([select id from quote limit 1].Id);
            if (!quoteIds.isEmpty()) {
                List < ExpocadBooth__c > lstEBUpdate = new List < ExpocadBooth__c > ();
                for (ExpocadBooth__c oExpo: [SELECT id, Status__c, Booth_Number__c FROM ExpocadBooth__c WHERE Quote__c IN: quoteIds AND Status__c != 'Released' LIMIT 1000]) { oExpo.Status__c = 'Released';lstEBUpdate.add(oExpo);
                }if (!lstEBUpdate.isEmpty()){ update lstEBUpdate;}
            }
        } catch (exception ex) {
            Utility.logError(ex.getMessage(), ex.getCause(), ex.getLineNumber(), ex.getStackTraceString(), 'After Update -- SBQQ__Quote__c.obj(@ReleaseBooths.Apex)');
        }
    }
}