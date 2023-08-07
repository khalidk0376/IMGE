/**
 * Methods for helping with building unit tests.
 * History : 
 * 1/11/2018 : Modified by Avinash for Jira Ticket GGCW-2736
 */

@isTest
public class TestUtilities {
    ////public static Id Idd;
    static Integer sObjectIdCounter = 1;
    public static String getFakeId(Schema.SobjectType sot) {
        String result = String.valueOf(sObjectIdCounter++);
        return sot.getDescribe().getKeyPrefix() + '0'.repeat(12 - result.length()) + result;
    }

    public static void createBillingPrefix() {

        List < blng__BillingPrefix__c > billingPrefixes = [SELECT Name FROM blng__BillingPrefix__c WHERE blng__BarPrefix__c = 'blng__'
            AND blng__DotPrefix__c = 'blng.'
            AND blng__RawPrefix__c = 'blng'
            LIMIT 1
        ];
        if (billingPrefixes.size() == 0) {
            blng__BillingPrefix__c billingPrefix = new blng__BillingPrefix__c();
            billingPrefix.Name = 'Test';
            billingPrefix.blng__BarPrefix__c = 'blng__';
            billingPrefix.blng__DotPrefix__c = 'blng.';
            billingPrefix.blng__RawPrefix__c = 'blng';
            try {
                insert billingPrefix;
            } catch (System.DmlException eek) {
                system.debug( 'Message: '+eek.getMessage()+' Cause: '+eek.getCause()+' Line Number: '+eek.getLineNumber()+' Trace: '+eek.getStackTraceString() );
            }
        }
    }

    public static List < blng__BillingConfig__c > createBillingConfigs() {
        List < blng__BillingConfig__c > billingConfigs = new List < blng__BillingConfig__c > ();

        billingConfigs.add(new blng__BillingConfig__c(Name = 'AVALARA_AVATAX', blng__BooleanValue__c = false, blng__Category__c = 'Tax', blng__StringValue__c = 'Avalara AvaTax'));

        billingConfigs.add(new blng__BillingConfig__c(Name = 'INSERT_SAMPLE_DATA', blng__BooleanValue__c = false, blng__Description__c = 'Insert Sample Data', blng__FieldType__c = 'Boolean'));

        billingConfigs.add(new blng__BillingConfig__c(Name = 'ADVANCED_AR_APPLICATION', blng__BooleanValue__c = true, blng__Category__c = 'Invoice', blng__Description__c = 'Advanced AR application', blng__FieldType__c = 'Boolean', blng__Sequence__c = 2));

        billingConfigs.add(new blng__BillingConfig__c(Name = 'ORDER_LEGAL_ENTITY_FIELD_NAME', blng__BooleanValue__c = false, blng__Category__c = 'General', blng__Description__c = 'Select Order field that holds the Legal Entity (This will override the Account Legal Entity field)', blng__FieldType__c = 'Picklist', blng__PicklistIndicator__c = 'OrderList', blng__Sequence__c = 3, blng__StringValue__c = 'Order Number'));

        billingConfigs.add(new blng__BillingConfig__c(Name = 'TAX_CALCULATION_BASED_ON', blng__BooleanValue__c = false, blng__Category__c = 'General', blng__Description__c = 'Tax calculation is based on?', blng__FieldType__c = 'Picklist', blng__PicklistIndicator__c = 'TaxcCalculationList', blng__Sequence__c = 3, blng__StringValue__c = 'Line Level Address'));

        billingConfigs.add(new blng__BillingConfig__c(Name = 'ALIGN_BILLDAYOFMONTH_TO_ORDERSTARTDATE', blng__BooleanValue__c = true, blng__Category__c = 'General', blng__Description__c = 'Align Billing day of month to Order start date', blng__FieldType__c = 'Boolean', blng__Sequence__c = 3));

        billingConfigs.add(new blng__BillingConfig__c(Name = 'PRORATION_TYPE', blng__BooleanValue__c = false, blng__Category__c = 'Invoice', blng__Description__c = 'Proration type.', blng__FieldType__c = 'String', blng__PicklistIndicator__c = 'CalendarDaysList', blng__Sequence__c = 3, blng__StringValue__c = 'Calendar Days'));

        billingConfigs.add(new blng__BillingConfig__c(Name = 'PARTIAL_PERIOD_BILLING_PRORATION', blng__BooleanValue__c = false, blng__Category__c = 'Invoice', blng__Description__c = 'Partial Proration Type', blng__FieldType__c = 'Picklist', blng__PicklistIndicator__c = 'PartialProrationTypeList', blng__Sequence__c = 3, blng__StringValue__c = 'Month + Daily'));

        billingConfigs.add(new blng__BillingConfig__c(Name = 'INVOICE_TO_BE_CHARGED_ON', blng__BooleanValue__c = false,blng__Category__c = 'Invoice',blng__Description__c = 'Payment Scheduler to pickup unpaid invoices on OR after',blng__FieldType__c = 'Picklist',blng__PicklistIndicator__c = 'PaymentSchedulerList',blng__Sequence__c = 2,blng__StringValue__c = 'Due Date'));

        billingConfigs.add(new blng__BillingConfig__c(Name = 'PERIOD_PRICE_ROUNDING',blng__BooleanValue__c = false,blng__Category__c = 'General',blng__Description__c = 'Billable Unit Price Rounding',blng__FieldType__c = 'Picklist',blng__PicklistIndicator__c = 'PeriodPriceRoundingList',blng__Sequence__c = 8,blng__StringValue__c = 'HALF_UP'));

        billingConfigs.add(new blng__BillingConfig__c(Name = 'USAGE_RATING_PROCESS',blng__BooleanValue__c = false,blng__Category__c = 'General',blng__Description__c = 'Usage Rating Process based on',blng__FieldType__c = 'Picklist',blng__PicklistIndicator__c = 'UsageRatingProcessList',blng__Sequence__c = 9,blng__StringValue__c = 'On Trigger'));

        billingConfigs.add(new blng__BillingConfig__c(Name = 'BILLING_REMAINDER_PROCESS',blng__BooleanValue__c = false,blng__Category__c = 'Invoice',blng__Description__c = 'Billing Remainder Process',blng__FieldType__c = 'Picklist',blng__PicklistIndicator__c = 'billingRemainderProcessList',blng__Sequence__c = 5,blng__StringValue__c = 'Last Period'));

        billingConfigs.add(new blng__BillingConfig__c(Name = 'REVENUE_REMAINDER_PROCESS',blng__BooleanValue__c = false,blng__Category__c = 'Invoice',blng__Description__c = 'Revenue Remainder Process',blng__FieldType__c = 'Picklist',blng__PicklistIndicator__c = 'RevenueRemainderProcessList',blng__Sequence__c = 6,blng__StringValue__c = 'Last Period'));

        billingConfigs.add(new blng__BillingConfig__c(Name = 'SAVE_CREDIT_CARD_ON_PAYMENT_PAGE',blng__BooleanValue__c = false,blng__Category__c = 'General',blng__Description__c = 'Save credit card details', blng__FieldType__c = 'Boolean',blng__Sequence__c = 6));

        billingConfigs.add(new blng__BillingConfig__c(Name = 'ENABLE_STATE_AND_COUNTRY_PICKLIST',blng__BooleanValue__c = false,blng__Category__c = 'General',blng__Description__c = 'Enable state and country picklist in Site Page and Virtual Terminal(works when state and country feature is enabled in Salesforce)',blng__FieldType__c = 'Boolean',blng__Sequence__c = 6));

        billingConfigs.add(new blng__BillingConfig__c(Name = 'ACCOUNT_LEGAL_ENTITY_FIELD_NAME',blng__BooleanValue__c = false,blng__Category__c = 'General',blng__Description__c = 'Select Account field that holds the legal entity information',blng__FieldType__c = 'Picklist',blng__PicklistIndicator__c = 'AccountList',blng__Sequence__c = 1,blng__StringValue__c = 'BillingCity'));

        insert billingConfigs;
        return billingConfigs;
    }

    /** Create default legal entity */
    public static blng__LegalEntity__c createLegalEntity(Boolean doInsert) {
        blng__LegalEntity__c obj = new blng__LegalEntity__c();

        obj.blng__Active__c = true;
        obj.blng__City__c = 'Los Angeles';
        obj.blng__Country__c = 'USA';
        obj.blng__County__c = 'Los Angeles';
        obj.blng__State__c = 'California';
        obj.blng__Street1__c = '5764 W. Jefferson Blvd.';
        obj.blng__Street2__c = null;
        obj.blng__ZipPostalCode__c = '90016';
        obj.Legal_Entity_Code__c = 'GB157';
        obj.CurrencyIsoCode = 'USD'; // Uncomment for multi-currency orgs
        obj.Name = 'Company Name ' + InvoiceUtilities.generateGUID();
        if (!doInsert) {
            obj.Id = getFakeId(blng__LegalEntity__c.SObjectType);
        }
        if (doInsert) {
            insert obj;
        }
        return obj;
    }
    // Ensure a contact exists
    public static Account getAcct() {
        return getAcct(true);
    }
    public static Account getAcct(Boolean doInsert) {
        return getAcct(new Account(), doInsert);
    }
    public static Account getAcct(Account account, Boolean doInsert) {
        Contact contact = createContact(doInsert);
        if (account.Name == null) {
            account.Name = 'Test Account';
        }
        if (account.BillingCity == null) {
            account.BillingCity = 'Oxnard';
        }
        if (account.BillingCountry == null) {
            account.BillingCountry = 'USA';
        }
        if (account.BillingPostalCode == null) {
            account.BillingPostalCode = '93030';
        }
        if (account.BillingState == null) {
            account.BillingState = 'CA';
        }
        if (account.BillingStreet == null) {
            account.BillingStreet = '121 North G Street';
        }
        if (account.ShippingCity == null) {
            account.ShippingCity = 'Los Angeles';
        }
        if (account.ShippingCountry == null) {
            account.ShippingCountry = 'USA';
        }
        if (account.ShippingPostalCode == null) {
            account.ShippingPostalCode = '90033';
        }
        if (account.ShippingState == null) {
            account.ShippingState = 'California';
        }
        if (account.ShippingStreet == null) {
            account.ShippingStreet = '1600 Pennsylvania Avenue';
        }
        account.blng__BillToContact__c = contact.Id;

        if (doInsert) {
            insert account;
            contact.AccountId = account.Id;
            update contact;
        }
        return account;
    }

    /** Create account */
    public static Account createAccount(Boolean doInsert) {
        return createAccount(null, doInsert);
    }
    public static Account createAccount(Contact contact, Boolean doInsert) {
        Account account = new Account();

        account.Name = 'Test Account for the Ages';
        account.BillingCity = 'Oxnard';
        account.BillingCountry = 'USA';
        account.BillingPostalCode = '93030';
        account.BillingState = 'California';
        account.BillingStreet = '121 North G Street';
        account.ShippingCity = 'Los Angeles';
        account.ShippingCountry = 'USA';
        account.ShippingPostalCode = '90033';
        account.ShippingState = 'California';
        account.ShippingStreet = '1600 Pennsylvania Avenue';
        if (contact != null) {
            account.blng__BillToContact__c = contact.Id;
        }
        if (!doInsert) {
            account.Id = getFakeId(Account.getSObjectType());
        }
        if (doInsert) {
            insert account;
            // Update
            if (contact != null && contact.accountId == null) {
                contact.AccountId = account.Id;
            }
        }
        return account;
    }

    /** Create contact for given account */
    public static Contact createContact(Boolean doInsert) {
        return createContact(null, doInsert);
    }
    public static Contact createContact(Account acct, Boolean doInsert) {
        Contact obj = new Contact();

        obj.Email = 'testUtilEmail@testUtil.com';
        obj.FirstName = 'Test';
        obj.LastName = 'Contact';
        obj.MailingCity = 'Los Angeles';
        obj.MailingCountry = 'USA';
        obj.MailingPostalCode = '90033';
        obj.MailingState = 'California';
        obj.MailingStreet = '1600 Pennsylvania Avenue';
        if (acct != null) {
            obj.AccountId = acct.Id;
        }
        if (!doInsert) {
            obj.Id = getFakeId(obj.getSObjectType());
        }
        if (doInsert) {
            insert obj;
        }
        return obj;
    }


    /**
     * ************  STEELBRICK BILLING CONFIGURATIONS ********************
     */


    public static blng__BillingRule__c createBillingRule(Boolean doInsert) {
        blng__BillingRule__c obj = new blng__BillingRule__c();

        obj.Name = 'Generate Invoice - Separate Partial Period';
        obj.blng__Active__c = true;
        obj.blng__GenerateInvoices__c = 'Yes';
        obj.blng__InitialBillingTrigger__c = 'Order Product Activation Date';
        obj.blng__PartialPeriodTreatment__c = 'Separate';
        obj.CurrencyIsoCode = 'USD'; // Uncomment for multi-currency orgs
        if (!doInsert) {
            obj.Id = getFakeId(blng__BillingRule__c.getSObjectType());
        }
        if (doInsert) {
            insert obj;
        }
        return obj;
    }

    public static blng__TaxRule__c createTaxRule(Boolean doInsert) {
        blng__TaxRule__c obj = new blng__TaxRule__c();

        obj.Name = 'No Tax Calculation';
        obj.blng__Active__c = true;
        obj.blng__TaxableYesNo__c = 'No';
        obj.CurrencyIsoCode = 'USD'; // Uncomment for multi-currency orgs
        if (!doInsert) {
            obj.Id = getFakeId(blng__TaxRule__c.getSObjectType());
        }
        if (doInsert) {
            insert obj;
        }
        return obj;
    }

    public static blng__RevenueRecognitionRule__c createRevRecRuleRule(Boolean doInsert) {
        blng__RevenueRecognitionRule__c obj = new blng__RevenueRecognitionRule__c();

        obj.Name = 'Standard Revenue Recognition Rule';
        obj.blng__Active__c = true;
        obj.blng__CreateRevenueSchedule__c = 'Yes';
        obj.CurrencyIsoCode = 'USD'; // Uncomment for multi-currency orgs
        if (!doInsert) {
            obj.Id = getFakeId(blng__RevenueRecognitionRule__c.getSObjectType());
        }
        if (doInsert) {
            insert obj;
        }
        return obj;
    }

    public static blng__GLRule__c createGlRule(Boolean doInsert) {
        blng__GLRule__c obj = new blng__GLRule__c();

        obj.Name = 'Standard GL Rule';
        obj.blng__Active__c = true;
        obj.CurrencyIsoCode = 'USD'; // Uncomment for multi-currency orgs
        if (!doInsert) {
            obj.Id = getFakeId(blng__GLRule__c.getSObjectType());
        }
        if (doInsert) {
            insert obj;
        }
        return obj;
    }

    public static blng__FinanceBook__c createFinanceBookRevenue(Boolean doInsert) {
        blng__FinanceBook__c obj = new blng__FinanceBook__c();

        obj.Name = 'Revenue Book';
        obj.blng__Active__c = true;
        obj.blng__PeriodType__c = 'Revenue';
        obj.CurrencyIsoCode = 'USD'; // Uncomment for multi-currency orgs
        if (!doInsert) {
            obj.Id = getFakeId(blng__FinanceBook__c.getSObjectType());
        }
        if (doInsert) {
            insert obj;
        }
        return obj;
    }

    public static blng__FinanceBook__c createFinanceBookAccounting(Boolean doInsert) {
        blng__FinanceBook__c obj = new blng__FinanceBook__c();

        obj.Name = 'Accounting Book';
        obj.blng__Active__c = true;
        obj.blng__PeriodType__c = 'Accounting';
        obj.CurrencyIsoCode = 'USD'; // Uncomment for multi-currency orgs
        if (!doInsert) {
            obj.Id = getFakeId(blng__FinanceBook__c.getSObjectType());
        }
        if (doInsert) {
            insert obj;
        }
        return obj;
    }

    public static blng__BillingTreatment__c createBillingTreatment(blng__BillingRule__c billingRule,
        blng__GLRule__c glRule,
        blng__FinanceBook__c finBook,
        Boolean doInsert) {
        blng__BillingTreatment__c obj = new blng__BillingTreatment__c();

        obj.Name = 'Standard Billing Treatment';
        obj.blng__Active__c = true;
        //obj.blng__BillingLegalEntity__c = 'Revenue';
        obj.blng__BillingGLRule__c = glRule.Id;
        obj.blng__BillingFinanceBook__c = finBook.Id;
        obj.blng__BillingRule__c = billingRule.Id;
        obj.CurrencyIsoCode = 'USD'; // Uncomment for multi-currency orgs
        if (!doInsert) {
            obj.Id = getFakeId(blng__BillingTreatment__c.getSObjectType());
        }
        if (doInsert) {
            insert obj;
        }
        return obj;
    }

    public static blng__RevenueDistributionMethod__c createRevenueDistMethod(Boolean doInsert) {
        blng__RevenueDistributionMethod__c obj = new blng__RevenueDistributionMethod__c();

        obj.Name = 'Standard Revenue Distribution Method - Order';
        obj.blng__Active__c = true;
        obj.blng__RevenueTransactionCreationProcess__c = 'Automatic';
        obj.blng__MonthlyRecognitionProration__c = 'Number of Days';
        obj.blng__Type__c = 'Order';
        obj.blng__DistributionMethod__c = 'Monthly';
        obj.blng__RevenueScheduleTermStartDate__c = 'Order Product Start Date';
        obj.blng__RevenueScheduleTermEndDate__c = 'Order Product End Date';
        obj.CurrencyIsoCode = 'USD'; // Uncomment for multi-currency orgs
        if (!doInsert) {
            obj.Id = getFakeId(blng__RevenueDistributionMethod__c.getSObjectType());
        }
        if (doInsert) {
            insert obj;
        }
        return obj;
    }

    public static blng__RevenueRecognitionTreatment__c createRevRecTreatment(blng__RevenueRecognitionRule__c revRecRule,
        blng__GLRule__c glRule,
        blng__FinanceBook__c finBook,
        blng__RevenueDistributionMethod__c revDistMethod,
        Boolean doInsert) {
        blng__RevenueRecognitionTreatment__c obj = new blng__RevenueRecognitionTreatment__c();

        obj.Name = 'Standard Revenue Recognition Treatment - Order Activation';
        obj.blng__Active__c = true;
        //obj.blng__BillingLegalEntity__c = 'Revenue';
        obj.blng__ProcessingOrder__c = 1.0;
        obj.blng__Type__c = 'Percentage';
        obj.blng__Percentage__c = 100.0;
        obj.blng__RevenueRecognitionRule__c = revRecRule.Id;
        obj.blng__RevenueGLRule__c = glRule.Id;
        obj.blng__RevenueFinanceBook__c = finBook.Id;
        obj.blng__RevenueScheduleCreationAction__c = 'Order Activation';
        obj.blng__RevenueDistributionMethod__c = revDistMethod.Id;
        obj.CurrencyIsoCode = 'USD'; // Uncomment for multi-currency orgs
        if (!doInsert) {
            obj.Id = getFakeId(blng__RevenueRecognitionTreatment__c.getSObjectType());
        }
        if (doInsert) {
            insert obj;
        }
        return obj;
    }

    /** Finance periods - this is optional in most use-cases */
    public static List < blng__FinancePeriod__c > createFinancePeriods(blng__LegalEntity__c legalEntity, blng__FinanceBook__c finBook, Date startDate, Integer numPeriods, Boolean doInsert) {
        List < blng__FinancePeriod__c > periods = new List < blng__FinancePeriod__c > ();
        for (Integer i = 0; i < numPeriods; i++) {
            blng__FinancePeriod__c obj = new blng__FinancePeriod__c(
                Name = String.valueOf(startDate.year()) + '-' + String.valueOf(startDate.month()),
                blng__LegalEntity__c = legalEntity.Id,
                blng__LegalEntity__r = legalEntity,
                blng__FinanceBook__c = finBook.Id,
                blng__FinanceBook__r = finBook,
                blng__PeriodEndDate__c = startDate.addMonths(1).addDays(-1),
                blng__PeriodStartDate__c = startDate,
                blng__PeriodStatus__c = 'Open',
                CurrencyIsoCode = 'USD'
            );
            if (!doInsert) {
                obj.Id = getFakeId(blng__FinancePeriod__c.SObjectType);
            }
            periods.add(obj);
            startDate = startDate.addMonths(1);
        }
        if (doInsert) {
            insert periods;
        }
        return periods;
    }


    /** Create subscription product */
    public static Product2 createProduct(Id billingRuleId, Id taxRuleId, Id revRecRuleId, Boolean doInsert) {
        Product2 obj = new Product2();

        obj.Name = 'Test Product';
        obj.IsActive = true;
        obj.ProductCode = 'CL01';
        obj.Description = 'Product of Clip Licensing, used to quote for In Library videos';
        obj.SBQQ__OptionSelectionMethod__c = 'Click';
        obj.SBQQ__ConfigurationType__c = null;
        obj.SBQQ__QuantityEditable__c = true;
        obj.SBQQ__SubscriptionBase__c = 'List';
        obj.SBQQ__Taxable__c = false;
        obj.SBQQ__BlockPricingField__c = 'Quantity';
        obj.SBQQ__Component__c = false;
        obj.SBQQ__DefaultQuantity__c = 1;
        obj.SBQQ__ExcludeFromOpportunity__c = false;
        obj.SBQQ__PriceEditable__c = true;
        obj.SBQQ__PricingMethod__c = 'List';
        obj.SBQQ__SubscriptionPricing__c = 'Fixed Price';
        obj.SBQQ__SubscriptionType__c = 'Renewable';
        obj.SBQQ__SubscriptionTerm__c = 12;
        obj.SBQQ__ChargeType__c = 'Recurring';
        obj.SBQQ__BillingType__c = 'Advance';
        obj.SBQQ__BillingFrequency__c = 'Monthly';
        obj.validated_in_sap__c = true;
        if (billingRuleId != null) {
            obj.blng__BillingRule__c = billingRuleId;
        }
        if (taxRuleId != null) {
            obj.blng__TaxRule__c = taxRuleId;
        }
        if (revRecRuleId != null) {
            obj.blng__RevenueRecognitionRule__c = revRecRuleId;
        }
        if (!doInsert) {
            obj.Id = getFakeId(Product2.getSObjectType());
        }
        if (doInsert) {
            insert obj;
        }
        return obj;
    }

    public static Product2 createProductUsage(Id billingRuleId, Id taxRuleId, Id revRecRuleId, Boolean doInsert) {
        Product2 obj = new Product2();
        //obj.Name = 'Test Product';
        //obj.IsActive = true;
        //obj.ProductCode = 'CL01';
        //obj.Description = 'Product of Clip Licensing, used to quote for In Library videos';
        //obj.SBQQ__OptionSelectionMethod__c = 'Click';
        //obj.SBQQ__ConfigurationType__c = null;
        //obj.SBQQ__QuantityEditable__c = true;
        //obj.SBQQ__SubscriptionBase__c = 'List';
        //obj.SBQQ__Taxable__c = false;
        //obj.SBQQ__BlockPricingField__c = 'Quantity';
        //obj.SBQQ__Component__c = false;
        //obj.SBQQ__DefaultQuantity__c = 1;
        //obj.SBQQ__ExcludeFromOpportunity__c = false;
        //obj.SBQQ__PriceEditable__c = true;
        //obj.SBQQ__PricingMethod__c = 'List';
        //obj.SBQQ__SubscriptionPricing__c = null;
        //obj.SBQQ__SubscriptionType__c = 'Renewable';
        //obj.SBQQ__SubscriptionTerm__c = null;
        //obj.SBQQ__ChargeType__c = 'Usage';
        //obj.SBQQ__BillingType__c = null;
        //obj.SBQQ__BillingFrequency__c = null;


        obj.CurrencyIsoCode = 'USD';
        obj.Description = 'Product of Clip Licensing, used to quote for In Library videos';
        obj.Family = 'Family';
        obj.IsActive = true;
        obj.Name = 'In Library';
        obj.ProductCode = 'CL02';
        obj.SBQQ__AssetAmendmentBehavior__c = 'Default';
        obj.SBQQ__AssetConversion__c = 'One per quote line';
        obj.SBQQ__BlockPricingField__c = 'Quantity';
        obj.SBQQ__ChargeType__c = 'Usage';
        obj.SBQQ__Component__c = true;
        obj.SBQQ__CostEditable__c = false;
        obj.SBQQ__CustomConfigurationRequired__c = false;
        obj.SBQQ__DefaultQuantity__c = 1;
        obj.SBQQ__DescriptionLocked__c = false;
        obj.SBQQ__ExcludeFromMaintenance__c = false;
        obj.SBQQ__ExcludeFromOpportunity__c = false;
        obj.SBQQ__ExternallyConfigurable__c = false;
        obj.SBQQ__HasConfigurationAttributes__c = false;
        obj.SBQQ__Hidden__c = false;
        obj.SBQQ__HidePriceInSearchResults__c = false;
        obj.SBQQ__IncludeInMaintenance__c = true;
        obj.SBQQ__NewQuoteGroup__c = false;
        obj.SBQQ__NonDiscountable__c = false;
        obj.SBQQ__NonPartnerDiscountable__c = false;
        obj.SBQQ__Optional__c = true;
        obj.SBQQ__OptionSelectionMethod__c = 'Click';
        obj.SBQQ__PriceEditable__c = false;
        obj.SBQQ__PricingMethod__c = 'List';
        obj.SBQQ__PricingMethodEditable__c = false;
        obj.SBQQ__QuantityEditable__c = true;
        obj.SBQQ__ReconfigurationDisabled__c = false;
        obj.SBQQ__SubscriptionBase__c = 'List';
        obj.SBQQ__SubscriptionType__c = 'Renewable';
        obj.SBQQ__Taxable__c = false;
        obj.validated_in_sap__c = true;
        if (billingRuleId != null) {
            obj.blng__BillingRule__c = billingRuleId;
        }
        if (taxRuleId != null) {
            obj.blng__TaxRule__c = taxRuleId;
        }
        if (revRecRuleId != null) {
            obj.blng__RevenueRecognitionRule__c = revRecRuleId;
        }
        if (!doInsert) {
            obj.Id = getFakeId(Product2.getSObjectType());
        }
        if (doInsert) {
            insert obj;
        }
        return obj;
    }

    /** Create one-time product */
    public static Product2 createOneTimeProduct(blng__BillingRule__c billingRule, blng__TaxRule__c taxRule, blng__RevenueRecognitionRule__c revRecRule, blng__LegalEntity__c legalEntity, Boolean doInsert) {
        Product2 obj = new Product2();
        obj.Name = 'Retroactive License';
        obj.IsActive = true;
        obj.Family = 'Event';
        obj.Brand__c = 'TOC';
        obj.ProductCode = 'UKCOMI-TOCEU2018';
        obj.Description = 'Product of Rights Management, used to invoice video infringers';
        obj.SBQQ__OptionSelectionMethod__c = 'Click';
        //obj.SBQQ__ConfigurationType__c = 'Required';
        obj.SBQQ__QuantityEditable__c = true;
        //obj.SBQQ__BlockPricingField__c = 'Quantity';
        obj.SBQQ__DefaultQuantity__c = 1;
        obj.SBQQ__PriceEditable__c = true;
        obj.SBQQ__PricingMethod__c = 'List';
        obj.SBQQ__ChargeType__c = 'One-Time';
        obj.SBQQ__Taxable__c = false;
        obj.validated_in_sap__c = true;
        if (legalEntity != null) {
            obj.LegalEntityLookup__c = legalEntity.Id;
            obj.LegalEntityLookup__r = legalEntity;
        }

        if (billingRule != null && billingRule.Id != null) {
            obj.blng__BillingRule__c = billingRule.Id;
            obj.blng__BillingRule__r = billingRule;
        }
        if (taxRule != null && taxRule.Id != null) {
            obj.blng__TaxRule__c = taxRule.Id;
            obj.blng__TaxRule__r = taxRule;
        }
        if (revRecRule != null && revRecRule.Id != null) {
            obj.blng__RevenueRecognitionRule__c = revRecRule.Id;
            obj.blng__RevenueRecognitionRule__r = revRecRule;
        }
        if (!doInsert) {
            obj.Id = getFakeId(Product2.getSObjectType());
        }
        if (doInsert) {
            insert obj;
        }
        return obj;
    }

    public static Pricebook2 createPricebook(Boolean doInsert) {
        Pricebook2 obj = new Pricebook2();

        if (!doInsert) {
            obj.Name = 'Test Pricebook';
            obj.Id = getFakeId(Pricebook2.getSObjectType());
        }
        if (doInsert) {
            obj.Id = Test.getStandardPricebookId();
        }
        return obj;
    }

    /** Create pricebook entry */
    public static PricebookEntry createPriceBookEntry(Product2 product, Pricebook2 pricebook, Boolean doInsert) {
        PricebookEntry obj = new PricebookEntry();

        obj.Pricebook2Id = pricebook.Id;
        obj.Pricebook2 = pricebook;
        obj.Product2Id = product.Id;
        obj.Product2 = product;
        obj.UnitPrice = 10;
        //obj.StandardPrice = 10;
        obj.IsActive = true;
        if (!doInsert) {
            obj.Id = getFakeId(PricebookEntry.getSObjectType());
        }
        if (doInsert) {
            insert obj;
        }
        return obj;
    }

    public static Event_Edition__c createEventEdition(String paymentSchedule, Boolean doInsert) {
        date myDate = date.today();
        Event_Series__c evntSeries = new Event_Series__c( name='test series '+myDate , Status__c = 'Active' , Event_Series_Code__c = 'test'+myDate );
        insert evntSeries;
        
        Event_Edition__c edition = new Event_Edition__c();
        edition.Part_of_Series__c = evntSeries.Id;
        edition.Name = 'Test Event';
        edition.Status__c = 'Current';
        // edition.Payment_Schedule__c = paymentSchedule;
        edition.Cutoff_Date_1__c = Date.today().addMonths(1);
        edition.Cutoff_Date_2__c = Date.today().addMonths(3);
        edition.Cutoff_Date_3__c = Date.today().addMonths(6);
        edition.Tab1__c = 'TAB1';
        edition.Tab2__c = 'TAB2';
        edition.Tab3__c = 'TAB3';
        edition.Tab4__c = 'TAB4';
        edition.Tab5__c = 'TAB5';
        edition.Tab6__c = 'TAB6';
        edition.Tab7__c = 'TAB7';
        edition.Tab8__c = 'TAB8';
        edition.No_Billing__c = false;
        edition.Event_Edition_Status__c = 'Confirmed';
        if (!doInsert) {
            edition.Id = getFakeId(Event_Edition__c.getSObjectType());
        }
        if (doInsert) {
            insert edition;
        }

        return edition;
    }

    public static Contract createContract(Account account, Opportunity anOpportunity, Boolean doInsert) {
        Contract obj = new Contract();
        obj.Name = 'Test Contract';
        obj.AccountId = account.Id;
        obj.Account = account;
        //obj.CurrencyIsoCode = 'USD';
        obj.Main_Contract__c = false;
        obj.SBQQ__Opportunity__r = anOpportunity;
        if (!doInsert) {
            obj.Id = getFakeId(Contract.getSObjectType());
        }
        if (doInsert) {
            insert obj;
        }
        return obj;
    }

    /** Create opportunity */
    public static Opportunity createOpportunity(Account acct, Contact billToContact, Event_Edition__c eventEdition, Pricebook2 pricebook, Boolean doInsert) {
        Opportunity obj = new Opportunity();

        obj.Name = 'test';
        obj.Type = 'New';
        obj.CloseDate = Date.today();
        obj.StageName = 'Proposal Sent';
        obj.Probability = 50;
        obj.AccountId = acct.Id;
        obj.Account = acct;
        obj.Billing_Contact__c = billToContact.Id;
        obj.Billing_Contact__r = billToContact;
        obj.EventEdition__c = eventEdition.Id;
        obj.EventEdition__r = eventEdition;
        obj.Tax_Rule_SAP__c = 'UAE VAT Refund';
        //obj.CurrencyIsoCode = 'USD'; // Uncomment for multi-currency orgs
        obj.Pricebook2Id = pricebook.Id;
        obj.By_Pass_Validation_Rule__c = True;
        obj.Pricebook2 = pricebook;
        obj.Custom_Payment__c = true;
        obj.Start_Date__c = Date.today();
        obj.Total_No_of_payment__c = 4;
        obj.SBQQ__Contracted__c = true;
        obj.Milestone_1_Delivery_Date__c = Date.today();
        obj.Milestone_1_Amount__c = 0.08;
        obj.Milestone_2_Delivery_Date__c = Date.today().addMonths(1);
        obj.Milestone_2_Amount__c = 0.08;
        obj.Milestone_3_Delivery_Date__c = Date.today().addMonths(2);
        obj.Milestone_3_Amount__c = 0.08;
        obj.Milestone_4_Delivery_Date__c = Date.today().addMonths(3);
        obj.Milestone_4_Amount__c = 0.08;
        obj.Milestone_5_Delivery_Date__c = Date.today().addMonths(4);
        obj.Milestone_5_Amount__c = 0.08;
        obj.Milestone_6_Delivery_Date__c = Date.today().addMonths(5);
        obj.Milestone_6_Amount__c = 0.08;
        obj.Milestone_7_Delivery_Date__c = Date.today().addMonths(6);
        obj.Milestone_7_Amount__c = 0.08;
        obj.Milestone_8_Delivery_Date__c = Date.today().addMonths(7);
        obj.Milestone_8_Amount__c = 0.08;
        obj.Milestone_9_Delivery_Date__c = Date.today().addMonths(8);
        obj.Milestone_9_Amount__c = 0.08;
        obj.Milestone_10_Delivery_Date__c = Date.today().addMonths(9);
        obj.Milestone_10_Amount__c = 0.08;
        obj.Milestone_11_Delivery_Date__c = Date.today().addMonths(10);
        obj.Milestone_11_Amount__c = 0.08;
        obj.Milestone_12_Delivery_Date__c = Date.today().addMonths(11);
        obj.Milestone_12_Amount__c = 0.08;
        obj.Total_No_of_payment__c = 12;
        if (!doInsert) {
            obj.Id = getFakeId(obj.getSObjectType());
        }
        if (doInsert) {
            insert obj;
        }
        return obj;
    }

    /** Create opportunity line item WITHOUT SBQQ quote reference */
    public static OpportunityLineItem createOpportunityLine(Opportunity opp, PricebookEntry pbEntry, Boolean doInsert) {
        return createOpportunityLine(opp, pbEntry, null, doInsert);
    }

    /** Create opportunity line item WITH SBQQ quote reference */
    public static OpportunityLineItem createOpportunityLine(Opportunity opp, PricebookEntry pbEntry, SBQQ__QuoteLine__c quoteLine, Boolean doInsert) {
        OpportunityLineItem obj = new OpportunityLineItem();

        obj.OpportunityId = opp.Id;
        obj.Opportunity = opp;
        obj.Quantity = 1;
        obj.PricebookEntryId = pbEntry.Id;
        obj.PricebookEntry = pbEntry;
        obj.TotalPrice = obj.Quantity * pbEntry.UnitPrice;
        if (quoteLine != null) {
            obj.SBQQ__QuoteLine__c = quoteLine.Id;
            obj.SBQQ__QuoteLine__r = quoteLine;
        }
        if (!doInsert) {
            obj.Id = getFakeId(OpportunityLineItem.getSObjectType());
        }
        if (doInsert) {
            insert obj;
        }
        return obj;
    }

    /** Create quote */
    public static SBQQ__Quote__c createQuote(Account acct, Opportunity opp, Pricebook2 pricebook, Boolean doInsert) {
        SBQQ__Quote__c obj = new SBQQ__Quote__c();
        obj.SBQQ__Status__c = 'Draft';
        obj.SBQQ__Primary__c = true;
        obj.SBQQ__StartDate__c = Date.today();
        obj.SBQQ__EndDate__c = Date.today().addMonths(1);
        obj.SBQQ__Opportunity2__c = opp.Id;
        obj.SBQQ__Opportunity2__r = opp;
        obj.SBQQ__SubscriptionTerm__c = 12;
        obj.SBQQ__ExpirationDate__c = Date.today() + 30;
        obj.SBQQ__Account__c = acct.Id;
        obj.SBQQ__Account__r = acct;
        obj.SBQQ__Type__c = 'Quote';
        obj.SBQQ__PriceBook__c = pricebook.Id;
        obj.SBQQ__PriceBook__r = pricebook;
        obj.invoice_payment1__c = 200;
        obj.invoice_Percentage1__c = 8;
        obj.invoice_payment2__c = 200;
        obj.invoice_Percentage2__c = 8;
        obj.invoice_payment3__c = 200;
        obj.invoice_Percentage3__c = 8;
        obj.invoice_payment4__c = 200;
        obj.invoice_Percentage4__c = 8;
        obj.invoice_payment5__c = 200;
        obj.invoice_Percentage5__c = 8;
        obj.invoice_payment6__c = 200;
        obj.invoice_Percentage6__c = 8;
        obj.invoice_payment7__c = 200;
        obj.invoice_Percentage7__c = 8;
        obj.invoice_payment8__c = 200;
        obj.invoice_Percentage8__c = 8;
        obj.invoice_payment9__c = 200;
        obj.invoice_Percentage9__c = 8;
        obj.invoice_payment10__c = 200;
        obj.invoice_Percentage10__c = 8;
        obj.invoice_payment11__c = 200;
        obj.invoice_Percentage11__c = 8;
        obj.invoice_payment12__c = 200;
        obj.invoice_Percentage12__c = 8;

        if (!doInsert) {
            obj.Id = getFakeId(SBQQ__Quote__c.getSObjectType());
        }
        if (doInsert) {
            insert obj;
        }
        return obj;
    }

    /** Create quote line */
    public static SBQQ__QuoteLine__c createQuoteLine(Product2 product, SBQQ__Quote__c quote, Boolean doInsert) {
        SBQQ__QuoteLine__c obj = new SBQQ__QuoteLine__c();

        obj.SBQQ__Quote__c = quote.Id;
        obj.SBQQ__Quote__r = quote;
        obj.SBQQ__Product__c = product.Id;
        obj.SBQQ__Product__r = product;
        obj.SBQQ__PricingMethod__c = 'List';
        obj.SBQQ__StartDate__c = Date.today();
        obj.SBQQ__ListPrice__c = 10;
        obj.SBQQ__Quantity__c = 1;
        obj.SBQQ__RegularPrice__c = 10;
        obj.SBQQ__NetPrice__c = 10;
        obj.SBQQ__Number__c = 1;
        obj.SBQQ__ProrateMultiplier__c = 1;
        obj.SBQQ__SubscriptionPricing__c = 'Fixed Price';
        obj.SBQQ__SubscriptionScope__c = 'Quote';
        obj.SBQQ__DefaultSubscriptionTerm__c = 1;
        obj.SBQQ__ChargeType__c = product.SBQQ__ChargeType__c;
        obj.SBQQ__BillingType__c = product.SBQQ__BillingType__c;
        obj.SBQQ__BillingFrequency__c = product.SBQQ__BillingFrequency__c;
        if (!doInsert) {
            obj.Id = getFakeId(SBQQ__QuoteLine__c.getSObjectType());
        }
        if (doInsert) {
            insert obj;
        }
        return obj;
    }

    /**
     * Creates order from Opportunity.
     * This relies on the SBQQ order checkbox to create the order to allow SB to cover
     * most of the heavy lifting
     */
    public static Order createAutomatedOrderFromOpportunity(Id oppId) {
        Opportunity opp = new Opportunity(Id = oppId, SBQQ__Ordered__c = true);
        update opp;
        return queryOrderFromOpportunityId(oppId)[0];
    }

    public static Order createAutomatedOrderFromOpportunity(Opportunity opp) {
        //Opportunity opp = new Opportunity(Id = oppId, SBQQ__Ordered__c= true);
        opp.SBQQ__Ordered__c = true;
        ///opp.Main_Contract__c= Idd;
        update opp;
        System.debug(queryOrderFromOpportunityId((opp.Id)));
        return queryOrderFromOpportunityId(opp.Id)[0];
    }

    /**
     * Close Won the opportunity.
     */
    public static Opportunity closeWonOpportunity(Id oppId, Boolean doInsert) {
        Opportunity opp = new Opportunity(Id = oppId, StageName = 'Closed Won', Status__c = 'Pending Accounting Approval', Tax_Rule_SAP__c = 'UAE VAT Refund');
        
        if (doInsert) {
            update opp;
        }
        // TODO need to select opportunity?
        return opp;
    }

    /**
     * Activate order - status and status code are both updated
     * This should upadte all lines as well.  Order lines are queried and returned
     */
    public static List < OrderItem > activateOrder(Order order, Boolean doInsert) {
        // Update status and status code
        order.Status = 'Activated';
        order.StatusCode = 'A';
        order.Create_Customer_Result__c = 'Success';
        order.SBQQ__PriceCalcStatus__c = 'Completed';
        order.SBQQ__PriceCalcStatusMessage__c = '';
        order.Cancelled__c = True;
        if (doInsert) {
            update order;
        }
        // order line: SBQQ__Status__c
        return queryOrderItemsByOrderId(order.Id);
    }

    /**
     * Contract the opportunity
     */
    public static List < Contract > contractOpportunity(Opportunity opp) {
        opp.SBQQ__Contracted__c = true;
        update opp;
        return queryContractWithSubscriptionsByOpportunityId(opp.Id);
    }

    /**
     * Contract order.
     * Returns Contract with subscriptions as a sub-query
     */
    public static List < Contract > contractOrder(Order order) {
        // Update status and status code
        order.SBQQ__Contracted__c = true;
        update order;
        // order line: SBQQ__Status__c
        return queryContractWithSubscriptionsByOrderId(order.Id);
    }

    /**
     * Create invoice for order.
     * Returns Invoice with invoice line subquery for easy reference
     */
    public static List < blng__Invoice__c > billOrderNow(Order order) {
        // Update status and status code
        order.blng__BillNow__c = true;
        update order;
        // order line: SBQQ__Status__c
        return queryInvoiceWithInvoiceLineFromOrderId(order.Id);
    }

    public static Order createOrder(Account account, Opportunity opp, Boolean doInsert) {
        Order order = new Order();

        order.OpportunityId = opp.Id;
        order.Opportunity = opp;
        order.AccountId = account.Id;
        order.Account = account;
        order.EffectiveDate = Date.today();
        order.Status = 'Draft';
        if (!doInsert) {
            order.Id = getFakeId(Order.getSObjectType());
        }
        if (doInsert) {
            insert order;
        }
        return order;
    }

    public static OrderItem createOrderItem(Order order, Product2 product, SBQQ__QuoteLine__c quoteLine, blng__LegalEntity__c legalEntity, blng__BillingRule__c billingRule, blng__RevenueRecognitionRule__c revRecRule,
        blng__TaxRule__c taxRule, Boolean doInsert) {
        OrderItem orderItem = new OrderItem();

        orderItem.OrderId = order.Id;
        orderItem.Order = order;
        orderItem.Product2Id = product.Id;
        orderItem.Product2 = product;
        orderItem.SBQQ__QuoteLine__c = quoteLine.Id;
        orderItem.SBQQ__QuoteLine__r = quoteLine;
        orderItem.UnitPrice = 10;
        orderItem.Quantity = 1;
        orderItem.blng__BilledAmountwithouttax__c = 10;
        orderItem.SBQQ__TotalAmount__c = 10;
        orderItem.blng__LegalEntity__c = legalEntity.Id;
        orderItem.blng__LegalEntity__r = legalEntity;
        orderItem.blng__BillingRule__c = billingRule.Id;
        orderItem.blng__BillingRule__r = billingRule;
        orderItem.blng__RevenueRecognitionRule__c = revRecRule.Id;
        orderItem.blng__RevenueRecognitionRule__r = revRecRule;
        orderItem.SBQQ__ChargeType__c = product.SBQQ__ChargeType__c;
        if (product.SBQQ__ChargeType__c == 'Recurring') {
            orderItem.SBQQ__BillingType__c = 'Advance';
        }
        orderItem.blng__TaxRule__c = taxRule.Id;
        orderItem.blng__TaxRule__r = taxRule;
        orderItem.Actual_Tax__c = 2;
        if (!doInsert) {
            orderItem.Id = getFakeId(OrderItem.getSObjectType());
        }
        if (doInsert) {
            insert orderItem;
        }
        return orderItem;
    }

    public static blng__Invoice__c createInvoice(Account account, Order order, Boolean doInsert) {
        return createInvoice(account, order, doInsert, InvoiceUtilities.generateGuid());
    }

    public static blng__Invoice__c createInvoice(Account account, Order order, Boolean doInsert, String uniqeId) {
        blng__Invoice__c invoice = new blng__Invoice__c();

        invoice.blng__InvoiceStatus__c = 'Draft';
        invoice.blng__Account__c = account.Id;
        invoice.blng__Account__r = account;
        invoice.blng__DueDate__c = Date.today();
        invoice.blng__InvoiceDate__c = Date.today();
        invoice.blng__Order__c = order != null ? order.Id : null;
        invoice.blng__Order__r = order != null ? order : null;
        invoice.blng__TargetDate__c = Date.today();
        invoice.blng__UniqueId__c = uniqeId;
        invoice.Schedule_Number__c = 1;
        invoice.Invoice_Submissions__c = 0;
        if (!doInsert) {
            invoice.Id = getFakeId(blng__Invoice__c.SObjectType);
        }
        if (doInsert) {
            insert invoice;
        }
        return invoice;
    }

    public static blng__Invoice__c createInvoiceById(Id accountId, Id orderId, Boolean doInsert, String uniqeId) {
        blng__Invoice__c invoice = new blng__Invoice__c();

        invoice.blng__InvoiceStatus__c = 'Draft';
        invoice.blng__Account__c = accountId;
        invoice.blng__DueDate__c = Date.today();
        invoice.blng__InvoiceDate__c = Date.today();
        invoice.blng__Order__c = orderId;
        invoice.blng__TargetDate__c = Date.today();
        invoice.blng__UniqueId__c = uniqeId;
        if (!doInsert) {
            invoice.Id = getFakeId(blng__Invoice__c.SObjectType);
        }
        if (doInsert) {
            insert invoice;
        }
        return invoice;
    }

    public static blng__InvoiceLine__c createInvoiceLine(blng__Invoice__c invoice, OrderItem op, Product2 p, Boolean doInsert) {
        return createInvoiceLine(invoice, op, p, doInsert, '8027A000000PUXOQA4_2017-6-13_2019-6-12___a1z7A000000Hn6iQAC__01t7A000001jG2aQAE');
    }

    public static blng__InvoiceLine__c createInvoiceLine(blng__Invoice__c invoice, OrderItem op, Product2 p, Boolean doInsert, String uniqeId) {
        blng__InvoiceLine__c invoiceLine = new blng__InvoiceLine__c();

        invoiceLine.Name = 'Branded Content';
        invoiceLine.CurrencyIsoCode = 'USD';
        invoiceLine.blng__BillingFinanceBook__c = op.blng__FinanceBookAccounting__c;
        invoiceLine.blng__BillingRule__c = op.blng__BillingRule__c;
        invoiceLine.blng__BillingTreatment__c = op.blng__BillingTreatment__c;
        invoiceLine.blng__CalculatedQuantity__c = 1;
        invoiceLine.blng__ChargeDate__c = Date.today();
        invoiceLine.blng__ChargeType__c = 'One-Time';
        invoiceLine.blng__EndDate__c = Date.today().addMonths(1);
        invoiceLine.blng__InvoiceLineState__c = 'Regular';
        invoiceLine.blng__InvoiceLineStatus__c = 'Draft';
        invoiceLine.blng__Invoice__c = invoice.Id;
        invoiceLine.blng__Invoice__r = invoice;
        invoiceLine.blng__LegalEntityReference__c = op.blng__LegalEntityReference__c;
        invoiceLine.blng__NegativeLineConversion__c = 0;
        invoiceLine.blng__OrderProduct__c = op.Id;
        invoiceLine.blng__OrderProduct__r = op;
        invoiceLine.blng__Product__c = p.Id;
        invoiceLine.blng__Product__r = p;
        invoiceLine.blng__Quantity__c = 1;
        invoiceLine.blng__StartDate__c = Date.today();
        invoiceLine.blng__Subtotal__c = 10.00;
        invoiceLine.blng__TaxErrorMessage__c = 'This line is not taxable';
        invoiceLine.blng__TaxRule__c = op.blng__TaxRule__c;
        invoiceLine.blng__TaxStatus__c = 'Completed';
        //invoiceLine.blng__TaxTreatment__c = 'a2g7A000000DKFLQA4';
        invoiceLine.blng__TotalAmount__c = 10.0;
        invoiceLine.blng__UniqueId__c = uniqeId;
        invoiceLine.blng__UnitPrice__c = 10.0;
        invoiceLine.SAP_Order_ID__c = 'SAPID1';
        invoiceLine.SAPBillingDocumentNumber__c = 'SAPBD1';
        if (!doInsert) {
            invoiceLine.Id = getFakeId(blng__InvoiceLine__c.SObjectType);
        }
        if (doInsert) {
            insert invoiceLine;
        }
        return invoiceLine;
    }

    public static blng__Payment__c createPayment(Account account, blng__Invoice__c invoice, Boolean doInsert) {
        blng__Payment__c payment = new blng__Payment__c();

        payment.blng__Account__c = account.Id;
        payment.blng__Account__r = account;
        payment.blng__Amount__c = 10;
        if (invoice != null) {
            payment.blng__Invoice__c = invoice.Id;
            payment.blng__Invoice__r = invoice;
        }
        payment.blng__PaymentDate__c = Date.today();
        payment.blng__PaymentType__c = 'Cash';
        if (!doInsert) {
            payment.Id = getFakeId(blng__Payment__c.SObjectType);
        }
        if (doInsert) {
            insert payment;
        }
        return payment;
    }

    /**
     * ********************** Query Helpers ********************
     */

    /** Get all feilds for an sobject as a list - helpful for dynamic SOQL */
    public static List < String > getAllFieldsForSobj(String sobjectName) {
        List < String > allFields = new List < String > (Schema.getGlobalDescribe().get(sobjectName).getDescribe().fields.getMap().keySet());
        return allFields;
    }

    /** Get comma delimited string list of all sobject fields */
    public static String getAllFieldsForSObjAsStr(String sobjectName) {
        return String.join(getAllFieldsForSobj(sobjectName), ', ');
    }

    /**
     * ********************** Queries ********************
     * These are here to allow easily querying data that may be needed often
     * These are used in some test methods, but can also be called directly
     * These queries dynamically populat fields, this has poor performance, so it is
     * not ideal for production code in most cases, but is fine for tests
     */

    /** Get dynamic query for object. There is a space at the end to allow the caller to add SOQL filters */
    public static String getDynamicQuery(String SObjectName) {
        String soql = 'SELECT ' + getAllFieldsForSObjAsStr(SObjectName) + ' FROM ' + SObjectName + ' ';
        System.debug(soql);
        return soql;
    }

    /** Get dynamic query with a subquery. There is a space at the end to allow the caller to add SOQL filters */
    public static String getDynamicQueryWithSubQuery(String parentSObjectName, String childSObjectName, String childRelationshipName) {
        String soql = 'SELECT ' + getAllFieldsForSObjAsStr(parentSObjectName);
        soql += ', (SELECT ' + getAllFieldsForSObjAsStr(childSObjectName) + ' FROM ' + childRelationshipName + ') FROM ' + parentSObjectName + ' ';
        System.debug(soql);
        return soql;
    }

    /** Get dynamic query for object. There is a space at the end to allow the caller to add SOQL filters */
    public static List < SObject > executeDynamicQuery(String SObjectName) {
        String soql = 'SELECT ' + getAllFieldsForSObjAsStr(SObjectName) + ' FROM ' + SObjectName + ' ';
        System.debug(soql);
        return Database.query(soql);
    }

    /** Query order from opp id */
    public static List < Order > queryOrderFromOpportunityId(Id oppId) {
        String soql = 'SELECT ' + getAllFieldsForSObjAsStr('Order') + ' FROM Order WHERE OpportunityId = \'' + oppId + '\'';
        System.debug(soql);
        return Database.query(soql);
    }

    /** Query order with lines (OrderItems) from opp id */
    public static List < Order > queryOrderWithLinesFromOpportunityId(Id oppId) {
        String soql = 'SELECT ' + getAllFieldsForSObjAsStr('Order') + ', (SELECT ' + getAllFieldsForSObjAsStr('OrderItem') + ' FROM OrderItems) FROM Order WHERE OpportunityId = \'' + oppId + '\'';
        System.debug(soql);
        return Database.query(soql);
    }

    /** Query order items by order id */
    //Modified by Avinash : GGCW-2736
    public static List < OrderItem > queryOrderItemsByOrderId(Id orderId) {
        String soql = 'SELECT ' + getAllFieldsForSObjAsStr('OrderItem') + ', Product2.ProductCode, Product2.Event_Product_Type__c, Order.Opportunity.Parent_Opportunity__c,Order.Parent_Opp_Order__c, Order.Parent_Opp_Order__r.TotalAmount,Order.Tax_Rule_SAP__c FROM OrderItem WHERE OrderId = \'' + orderId + '\'';
        return Database.query(soql);
    }

    /** Query quote with quote lines by id */
    public static List < SBQQ__Quote__c > queryQuoteWithQuoteline(Id quoteId) {
        String soql = 'SELECT ' + getAllFieldsForSObjAsStr('SBQQ__Quote__c') + ', (SELECT ' + getAllFieldsForSObjAsStr('SBQQ__QuoteLine__c') + ' FROM SBQQ__LineItems__r) FROM SBQQ__Quote__c WHERE Id = \'' + quoteId + '\'';
        System.debug(soql);
        return Database.query(soql);
    }

    /** Query contract with lines (subscriptions) by order  */
    public static List < Contract > queryContractWithSubscriptionsByOrderId(Id orderId) {
        String soql = 'SELECT ' + getAllFieldsForSObjAsStr('Contract') + ', (SELECT ' + getAllFieldsForSObjAsStr('SBQQ__Subscription__c') + ' FROM SBQQ__Subscriptions__r) FROM Contract WHERE SBQQ__Order__c = \'' + orderId + '\'';
        System.debug(soql);
        return Database.query(soql);
    }

    /** Query contract with lines (subscriptions) by opportunity  */
    public static List < Contract > queryContractWithSubscriptionsByOpportunityId(Id oppId) {
        String soql = 'SELECT ' + getAllFieldsForSObjAsStr('Contract') + ', (SELECT ' + getAllFieldsForSObjAsStr('SBQQ__Subscription__c') + ' FROM SBQQ__Subscriptions__r) FROM Contract WHERE SBQQ__Opportunity__c = \'' + oppId + '\'';
        System.debug(soql);
        return Database.query(soql);
    }


    /** Query invoice with lines by order id  */
    public static List < blng__Invoice__c > queryInvoiceWithInvoiceLineFromOrderId(Id orderId) {
        String soql = 'SELECT ' + getAllFieldsForSObjAsStr('blng__Invoice__c') + ', (SELECT ' + getAllFieldsForSObjAsStr('blng__InvoiceLine__c') + ' FROM blng__InvoiceInvoiceLines__r) FROM blng__Invoice__c WHERE blng__Order__c = \'' + orderId + '\'';
        System.debug(soql);
        return Database.query(soql);
    }

    /** Query invoice lines by invoice id */
    public static List < blng__InvoiceLine__c > queryInvoiceLinesByInvoiceId(Id invoiceId) {
        String soql = 'SELECT ' + getAllFieldsForSObjAsStr('OrderItem') + ' FROM blng__InvoiceLine__c WHERE blng__Invoice__c = \'' + invoiceId + '\'';
        return Database.query(soql);
    }

    public static void createCSIntegrationSettings() {
        List < Integration_Settings__c > intCSList = new List < Integration_Settings__c > ();

        intCSList.add(new Integration_Settings__c(Name = 'CUSTOMER',
            Endpoint__c = 'https://adsystemneworder.com',
            Timeout_Duration__c = 120,
            //Max_Retries_Per_Batch__c=1.0,
            //Total_Max_Retries__c=3.0,
            //Sync_Interval__c=3.0,
            Username__c = 'none',
            Password__c = 'password'));

        intCSList.add(new Integration_Settings__c(Name = 'VALIDATE_CUSTOMER',
            Endpoint__c = 'https://www.getavail.com',
            Timeout_Duration__c = 120,
            //Logging_Enabled__c=false,
            //Max_Retries_Per_Batch__c=1.0,
            //Total_Max_Retries__c=3.0,
            //Sync_Interval__c=5.0,
            Username__c = 'none',
            Password__c = 'password'));

        intCSList.add(new Integration_Settings__c(Name = 'INVOICE',
            Endpoint__c = 'https://www.makeres.com',
            Timeout_Duration__c = 120,
            //Logging_Enabled__c=false,
            //Max_Retries_Per_Batch__c=1.0,
            //Total_Max_Retries__c=3.0,
            //Sync_Interval__c=5.0,
            Username__c = 'none',
            Password__c = 'password'));

        intCSList.add(new Integration_Settings__c(Name = 'TAX_CALCULATION',
            Endpoint__c = 'https://www.calctax.com',
            Timeout_Duration__c = 120,
            //Logging_Enabled__c=false,
            //Max_Retries_Per_Batch__c=1.0,
            //Total_Max_Retries__c=3.0,
            //Sync_Interval__c=5.0,
            Username__c = 'none',
            Password__c = 'password'));

        intCSList.add(new Integration_Settings__c(Name = 'NullValues',
            Endpoint__c = null,
            Timeout_Duration__c = 120,
            //Logging_Enabled__c=false,
            //Max_Retries_Per_Batch__c=1.0,
            //Total_Max_Retries__c=3.0,
            //Sync_Interval__c=5.0,
            Username__c = null,
            Password__c = null));

        intCSList.add(new Integration_Settings__c(Name = 'VAT_VALIDATION',
            Endpoint__c = 'https://vatvalidation.com',
            Timeout_Duration__c = 120,
            //Max_Retries_Per_Batch__c=1.0,
            //Total_Max_Retries__c=3.0,
            //Sync_Interval__c=3.0,
            Username__c = 'none',
            Password__c = 'password'));

        insert intCSList;
    }

    public static void createCSBatchSettings() {
        List < Batch_Settings__c > batchCSList = new List < Batch_Settings__c > ();

        batchCSList.add(new Batch_Settings__c(Name = 'JOURNAL_INVOICE',
            Retries__c = 2));

        insert batchCSList;
    }

    public static Map < String, SObject > createSBQQStack(Boolean doInsert) {
        Map < String, SObject > objectMap = new Map < String, SObject > ();

        User_Type__c userType = new User_Type__c(Name = 'Exhibitor', CurrencyIsoCode = 'USD');
        insert userType;

        Account account = TestUtilities.createAccount(doInsert);
        Contact billingContact = TestUtilities.createContact(account, doInsert);

        Product2 product = TestUtilities.createOneTimeProduct(null, null, null, null, doInsert);
        Pricebook2 priceBook = TestUtilities.createPricebook(doInsert);
        PricebookEntry pbEntry = TestUtilities.createPriceBookEntry(product, priceBook, doInsert);
        Event_Edition__c eventEdition = TestUtilities.createEventEdition('50-50', doInsert);
        Opportunity opportunity = TestUtilities.createOpportunity(account, billingContact, eventEdition, pricebook, doInsert);
        Contract aContract = TestUtilities.createContract(account, opportunity, doInsert);
        ///Idd=aContract.Id;
        SBQQ__Quote__c quote = TestUtilities.createQuote(account, opportunity, pricebook, doInsert);
        SBQQ__QuoteLine__c quoteLine = TestUtilities.createQuoteLine(product, quote, doInsert);
        OpportunityLineItem oli = TestUtilities.createOpportunityLine(opportunity, pbEntry, quoteLine, doInsert);

        objectMap.put(TestUtilities.EVENT_EDITION, eventEdition);
        objectMap.put(TestUtilities.ACCOUNT, account);
        objectMap.put(TestUtilities.CONTACT, billingContact);
        objectMap.put(TestUtilities.PRODUCT, product);
        objectMap.put(TestUtilities.PRICEBOOK_ENTRY, pbEntry);

        objectMap.put(TestUtilities.OPPORTUNITY, opportunity);
        objectMap.put(TestUtilities.QUOTE, quote);
        objectMap.put(TestUtilities.QUOTE_LINE, quoteLine);
        objectMap.put(TestUtilities.OPPORTUNITY_LINE_ITEM, oli);

        return objectMap;
    }

    public static Map < String, SObject > createBillingBackgroundStack(Boolean doInsert) {

        Map < String, SObject > objectMap = createSBQQStack(doInsert);
        Product2 product = (Product2) objectMap.get(TestUtilities.PRODUCT);

        blng__LegalEntity__c legalEntity = TestUtilities.createLegalEntity(doInsert);
        blng__BillingRule__c billingRule = TestUtilities.createBillingRule(doInsert);

        blng__TaxRule__c taxRule = TestUtilities.createTaxRule(doInsert);
        blng__RevenueRecognitionRule__c revRecRule = TestUtilities.createRevRecRuleRule(doInsert);
        blng__GLRule__c glRule = TestUtilities.createGlRule(doInsert);
        blng__RevenueDistributionMethod__c revDistMethod = TestUtilities.createRevenueDistMethod(doInsert);
        blng__FinanceBook__c financeBookRev = TestUtilities.createFinanceBookRevenue(doInsert);
        blng__FinanceBook__c financeBookAcct = TestUtilities.createFinanceBookAccounting(doInsert);
        blng__RevenueRecognitionTreatment__c revRecTreatment = TestUtilities.createRevRecTreatment(revRecRule, glRule, financeBookRev, revDistMethod, doInsert);
        blng__BillingTreatment__c billingTreatmentAcct = TestUtilities.createBillingTreatment(billingRule, glRule, financeBookAcct, doInsert);

        List < blng__FinancePeriod__c > financePeriodsRev = TestUtilities.createFinancePeriods(legalEntity, financeBookRev, Date.today().toStartOfMonth(), 1, doInsert);
        List < blng__FinancePeriod__c > financePeriodsAcct = TestUtilities.createFinancePeriods(legalEntity, financeBookAcct, Date.today().toStartOfMonth(), 1, doInsert);

        product.blng__BillingRule__c = billingRule.Id;
        product.blng__TaxRule__c = taxRule.Id;
        product.blng__RevenueRecognitionRule__c = revRecRule.Id;
        product.LegalEntityLookup__c = legalEntity.Id;
        if (doInsert) {
            update product;
        }

        objectMap.put(TestUtilities.LEGAL_ENTITY, legalEntity);
        objectMap.put(TestUtilities.BILLING_RULE, billingRule);

        objectMap.put(TestUtilities.TAX_RULE, taxRule);
        objectMap.put(TestUtilities.REVENUE_RECOGNITION_RULE, revRecRule);
        objectMap.put(TestUtilities.GL_RULE, glRule);
        objectMap.put(TestUtilities.FINANCE_BOOK_REVENUE, financeBookRev);
        objectMap.put(TestUtilities.FINANCE_BOOK_ACCOUNTING, financeBookAcct);
        objectMap.put(TestUtilities.FINANCE_PERIOD_REVENUE, financePeriodsRev.get(0));
        objectMap.put(TestUtilities.FINANCE_PERIOD_ACCOUNTING, financePeriodsAcct.get(0));
        //objectMap.put(TestUtilities.REV_REC_TREATMENT_REVENUE, revRecTreatment);
        objectMap.put(TestUtilities.BILLING_TREATMENT_ACCOUNTING, billingTreatmentAcct);

        return objectMap;
    }

    public static Map < String, SObject > createToOrderStack(Boolean doInsert) {
        Map < String, SObject > sbObjectMap = TestUtilities.createBillingBackgroundStack(doInsert);
        blng__LegalEntity__c legalEntity = (blng__LegalEntity__c) sbObjectMap.get(TestUtilities.LEGAL_ENTITY);
        Account account = (Account) sbObjectMap.get(TestUtilities.ACCOUNT);
        Product2 product = (Product2) sbObjectMap.get(TestUtilities.PRODUCT);
        SBQQ__QuoteLine__c quoteLine = (SBQQ__QuoteLine__c) sbObjectMap.get(TestUtilities.QUOTE_LINE);
        Opportunity opportunity = (Opportunity) sbObjectMap.get(TestUtilities.OPPORTUNITY);
        opportunity = TestUtilities.closeWonOpportunity(opportunity.Id, doInsert);

        blng__BillingRule__c billingRule = (blng__BillingRule__c) sbObjectMap.get(TestUtilities.BILLING_RULE);
        blng__RevenueRecognitionRule__c revRecRule = (blng__RevenueRecognitionRule__c) sbObjectMap.get(TestUtilities.REVENUE_RECOGNITION_RULE);
        blng__TaxRule__c taxRule = (blng__TaxRule__c) sbObjectMap.get(TestUtilities.TAX_RULE);

        Order anOrder = TestUtilities.createOrder(account, opportunity, doInsert);
        OrderItem anOrderItem = TestUtilities.createOrderItem(anOrder, product, quoteLine, legalEntity, billingRule, revRecRule, taxRule, doInsert);
        sbObjectMap.put(TestUtilities.ORDER, anOrder);
        sbObjectMap.put(TestUtilities.ORDER_ITEM, anOrderItem);

        return sbObjectMap;
    }

    public static Map < String, SObject > createToInvoiceStack(Boolean doInsert) {
        Map < String, SObject > sbObjectMap = TestUtilities.createToOrderStack(doInsert);
        Account account = (Account) sbObjectMap.get(TestUtilities.ACCOUNT);
        Product2 product = (Product2) sbObjectMap.get(TestUtilities.PRODUCT);
        Order anOrder = (Order) sbObjectMap.get(TestUtilities.ORDER);
        OrderItem anOrderItem = (OrderItem) sbObjectMap.get(TestUtilities.ORDER_ITEM);
        //List<OrderItem> orderItems = TestUtilities.activateOrder(anOrder, doInsert);

        blng__Invoice__c invoice = TestUtilities.createInvoice(account, anOrder, doInsert);
        blng__InvoiceLine__c invoiceLine = TestUtilities.createInvoiceLine(invoice, anOrderItem, product, doInsert);

        sbObjectMap.put(TestUtilities.INVOICE, invoice);
        sbObjectMap.put(TestUtilities.INVOICE_LINE, invoiceLine);
        return sbObjectMap;
    }

    public static String EVENT_EDITION = 'Event_Edition__c';
    public static String ACCOUNT = 'Account';
    public static String CONTACT = 'Contact';
    public static String LEGAL_ENTITY = 'blng__LegalEntity__c';
    public static String BILLING_RULE = 'blng__BillingRule__c';
    public static String TAX_RULE = 'blng__TaxRule__c';
    public static String REVENUE_RECOGNITION_RULE = 'blng__RevenueRecognitionRule__c';
    public static String GL_RULE = 'blng__GLRule__c';
    public static String FINANCE_BOOK_REVENUE = 'blng__FinanceBook__cRev';
    public static String FINANCE_BOOK_ACCOUNTING = 'blng__FinanceBook__cAcct';
    public static String FINANCE_PERIOD_REVENUE = 'blng__FinancePeriod__cRev';
    public static String FINANCE_PERIOD_ACCOUNTING = 'blng__FinancePeriod__cAcct';
    public static String REV_REC_TREATMENT_REVENUE = 'blng__BillingTreatment__cRev';
    public static String BILLING_TREATMENT_ACCOUNTING = 'blng__BillingTreatment__cAcct';
    public static String PRODUCT = 'Product2';
    public static String PRICEBOOK_ENTRY = 'PricebookEntry';
    public static String OPPORTUNITY = 'Opportunity';
    public static String QUOTE = 'SBQQ__Quote__c';
    public static String QUOTE_LINE = 'SBQQ__QuoteLine__c';
    public static String OPPORTUNITY_LINE_ITEM = 'OpportunityLineItem';
    public static String ORDER = 'Order';
    public static String ORDER_ITEM = 'OrderItem';
    public static String INVOICE = 'blng__Invoice__c';
    public static String INVOICE_LINE = 'blng__InvoiceLine__c';

}