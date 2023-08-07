/**
 * This trigger insert record to 'Currency Update' object
 * @Author    : Sudip Halder
 * @Date      : 27/Feb/2018 
 * Test Class : CurrencyTypeCtrl_Test  
 */
trigger CurrencyTypeUpdaterTrg on Currency_Master__c ( after insert ) {
    CurrencyTypeCtrl.createCurrencyUpdateDatedExchangeRates( Trigger.new );
}