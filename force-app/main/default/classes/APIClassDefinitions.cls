public with sharing class APIClassDefinitions { 
    public with sharing class QuoteModel { 
        public QuoteModel (){
            // Added by Palla Kishore for the ticket BK-19604
            system.debug('Constructor Being Called');
        }
        /** 
         * The record represented by this model 
         */ 
        public SBQQ__Quote__c record; 
        /** 
         * The lines contained in this quote 
         */ 
        public QuoteLineModel[] lineItems; 
        /** 
         * The groups contained in this quote 
         */ 
        public QuoteLineGroupModel[] lineItemGroups; 
 
        /** 
         * The next key that will be used for new groups or lines. 
         * To ensure uniqueness of keys, this value should never be changed to a lower value. 
         */ 
        public Integer nextKey; 
        /** 
         * Corresponds to the 'magic field', SBQQ__Quote__c.ApplyAdditionalDiscountLast__c 
         */ 
        public Boolean applyAdditionalDiscountLast; 
        /** 
         * Corresponds to the 'magic field', SBQQ__Quote__c.ApplyPartnerDiscountFirst__c 
         */ 
        public Boolean applyPartnerDiscountFirst; 
        /** 
         * Corresponds to the 'magic field', SBQQ__Quote__c.ChannelDiscountsOffList__c 
         */ 
        public Boolean channelDiscountsOffList; 
        /** 
         * SBQQ__Quote__c.SBQQ__CustomerAmount__c is a Roll-up Summary Field, so its accuracy can only be guaranteed 
         * after a quote is persisted. As such, its current value is stored here until then. 
         */ 
        public Decimal customerTotal; 
        /** 
         * SBQQ__Quote__c.SBQQ__NetAmount__c is a Roll-up Summary Field, so its accuracy can only be guaranteed 
         * after a quote is persisted. As such, its current value is stored here until then. 
         */ 
        public Decimal netTotal; 
        /** 
         * The Net Total for all non-multidimensional quote lines. 
         */ 
        public Decimal netNonSegmentTotal; 
    } 
 
    public with sharing class QuoteLineModel { 
        /** 
         * The record represented by this model. 
         */ 
        public SBQQ__QuoteLine__c record; 
        /** 
         * Corresponds to the 'magic field', SBQQ__QuoteLine__c.ProrateAmountDiscount__c. 
         */ 
        public Boolean amountDiscountProrated; 
        /** 
         * The unique key of this line's group, if this line is part of a grouped quote. 
         */ 
        public Integer parentGroupKey; 
        /** 
         * The unique key of this line's parent, if this line is part of a bundle. 
         */ 
        public Integer parentItemKey; 
        /** 
         * Each quote line and group has a key that is unique against all other keys on the same quote. 
         */ 
        public Integer key; 
        /** 
         * True if this line is an MDQ segment that can be uplifted from a previous segment. 
         */ 
        public Boolean upliftable; 
        /** 
         * Indicates the configuration type of the product this line represents. 
         */ 
        public String configurationType; 
        /** 
         * Indicates the configuration event of the product this line represents. 
         */ 
        public String configurationEvent; 
        /** 
         * If true, this line cannot be reconfigured. 
         */ 
        public Boolean reconfigurationDisabled; 
        /** 
         * If true, this line's description cannot be changed. 
         */ 
        public Boolean descriptionLocked; 
        /** 
         * If true, this line's quantity cannot be changed. 
         */ 
        public Boolean productQuantityEditable; 
        /** 
         * The number of decimal places to which this line's quantity shall be rounded. 
         */ 
        public Decimal productQuantityScale; 
        /** 
         * The type of MDQ dimension this line represents. 
         */ 
        public String dimensionType; 
        /** 
         * If true, the underlying product can be represented as a Multi-dimensional line. 
         */ 
        public Boolean productHasDimensions; 
        /** 
         * The unit price towards which this quote line will be discounted. 
         */ 
        public Decimal targetCustomerAmount; 
        /** 
         * The customer amount towards which this quote line will be discounted. 
         */ 
        public Decimal targetCustomerTotal; 
        /** 
         * The net total towards which this quote line will be discounted. 
         */ 
    } 
 
    public with sharing class QuoteLineGroupModel { 
        /** 
         * The record represented by this model. 
         */ 
        public SBQQ__QuoteLineGroup__c record; 
 
        /** 
         * The Net Total for all non-multidimensional quote lines. 
         */ 
        public Decimal netNonSegmentTotal; 
        /** 
         * Each quote line and group has a key that is unique against all other keys on the same quote. 
         */ 
        public Integer key; 
    } 
}