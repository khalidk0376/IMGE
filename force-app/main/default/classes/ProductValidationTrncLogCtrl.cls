/**
 *  @Author      : Sudip Halder
 *  @Date        : 12/Oct/2017
 *  @Description : This extension class entends 'Event_Edition__c' and used in 'ProductSyncToSap' vf page. 
 */
public with sharing class ProductValidationTrncLogCtrl {

    /**
     * Menber Variables
	 */
    public integer index { get; set; }
    public integer blockSize { get; set; } 
    public integer totalRecord { get; set; }
    
    /**
     * Constructor
	 */
    public ProductValidationTrncLogCtrl() {
        index     = 0;
        blockSize = 10;
        getTotalLogRecords();
    }
    
     public void getTotalLogRecords(){
        totalRecord = 0;
        if( Schema.SObjectType.ProductValidationTrncLog__c.isQueryable() && 
            Schema.SObjectType.ProductValidationTrncLog__c.fields.id.isAccessible() ) {
            	AggregateResult count = [ Select count(id) FROM ProductValidationTrncLog__c ];   
                totalRecord = integer.valueOf( count.get('expr0') );
           }
    }
    
    
    /**
     * @method :  getProductValidationTrncLog() method
     * @return :  List of ProductValidationTrncLog__c
	 */
    public List<ProductValidationTrncLog__c> getProductValidationTrncLog() {
        
        List<ProductValidationTrncLog__c> ProdTrLog = new List<ProductValidationTrncLog__c>();
        /*
        if( Schema.SObjectType.ProductValidationTrncLog__c.isQueryable() && 
            Schema.SObjectType.ProductValidationTrncLog__c.fields.ID.isAccessible() && 
            Schema.SObjectType.ProductValidationTrncLog__c.fields.Name.isAccessible() && 
            Schema.SObjectType.ProductValidationTrncLog__c.fields.Success_Transaction__c.isAccessible() && 
            Schema.SObjectType.ProductValidationTrncLog__c.fields.Success_ProductCode__c.isAccessible() && 
            Schema.SObjectType.ProductValidationTrncLog__c.fields.Failure_Transaction__c.isAccessible() && 
            Schema.SObjectType.ProductValidationTrncLog__c.fields.Error_ProductCodeWithErr__c.isAccessible() && 
            Schema.SObjectType.ProductValidationTrncLog__c.fields.CreatedDate.isAccessible() 
             ) { 
            */
            ProdTrLog = [ SELECT ID, Name, Success_Transaction__c, Success_ProductCode__c, Failure_Transaction__c, Error_ProductCodeWithErr__c, CreatedDate, CreatedBy.Name FROM ProductValidationTrncLog__c ORDER BY CreatedDate DESC LIMIT :blockSize OFFSET :index ];
       // }
        return ProdTrLog;
    }
    
    public void previous() {
        index = index - blockSize;
        if( index < 0 )
            index = 0;
    }
    
    public void next() {
        index = index + blockSize;
        integer value = totalRecord - index;
        if( value < blockSize )
            index = index - blockSize;
    }
}