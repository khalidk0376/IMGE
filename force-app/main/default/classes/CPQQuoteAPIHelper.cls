/**
* File          :   CPQQuoteAPIHelper
* Project       :   (3E Intregration)
* Created Date  :   
* Created By    :   (Girikon)
* Test Class    :  Expo3EAPIUtils_Test 
* Coverage      :   100%
* *******************************************************************************************************
* @description : 
* *******************************************************************************************************
* Last Modified By : Girikon(Aradhana),on 13th Oct 2022[EX-23]for code coverage
*/
public class CPQQuoteAPIHelper {

    public class CalculatorContext {
        public QuoteModel quote;
    }
    
    public QuoteModel read(String quoteId) { 
        String quoteJSON = SBQQ.ServiceRouter.read('SBQQ.QuoteAPI.QuoteReader', quoteId);
        return (QuoteModel) JSON.deserialize(quoteJSON, QuoteModel.class);
    }
    
     public QuoteModel save(QuoteModel quote) {
        String quoteJSON = SBQQ.ServiceRouter.save('SBQQ.QuoteAPI.QuoteSaver', JSON.serialize(quote));
        return (QuoteModel) JSON.deserialize(quoteJSON, QuoteModel.class);
    } 
}