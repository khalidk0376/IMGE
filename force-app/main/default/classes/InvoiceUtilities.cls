/**
 * Created by stevelohrenz on 4/14/17.
 */

public with sharing class InvoiceUtilities {

    /**
     * Generates a guid.
     */
    public static String generateGUID() {
        Blob b = Crypto.GenerateAESKey(128);
        String h = EncodingUtil.ConvertToHex(b);
        String guid = h.SubString(0, 8) + '-' + h.SubString(8, 12) + '-' + h.SubString(12, 16) + '-' + h.SubString(16, 20) + '-' + h.substring(20);
        System.debug(guid);
        return guid;

    }

    /**
     * retrieve the billing contact.
     */
    public static Map<Id, Contact> retrieveBillingContact(List<Id> orderIds) {
        System.debug('InvoiceUtilities.retrieveBillingContact orderIds: ' + orderIds);
        Map<Id, Contact> returnContactsByOrderIds = new Map<Id, Contact>();
        List<Order> orders = [SELECT Id, BillToContact.FirstName, BillToContact.LastName, BillToContact.Email,
                BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, AccountId,
                Account.blng__BillToContact__c, BillToContactId, SBQQ__Quote__r.SBQQ__Opportunity2__r.Billing_Contact__c
            FROM Order
            WHERE Id IN :orderIds];

        for(Order order: orders) {
            Contact contact = null;
            /*if (order.BillToContactId != null) {
                System.debug('InvoiceUtilities.retrieveBillingContact using order.BillToContactId ' + order.BillToContactId);
                contact = [
                        SELECT Id, Email, Phone, Title, Name, FirstName, LastName, AccountId,
                                Account.BillingStreet, Account.BillingCity, Account.BillingPostalCode, Account.BillingState,
                                Account.BillingCountry, Fax
                        FROM Contact
                        WHERE Id = :order.BillToContactId
                        LIMIT 1
                ];
            } else */ if (order.SBQQ__Quote__r.SBQQ__Opportunity2__r.Billing_Contact__c != null) {
                System.debug('InvoiceUtilities.retrieveBillingContact using order.SBQQ__Quote__r.SBQQ__Opportunity2__r.Billing_Contact__c ' + order.SBQQ__Quote__r.SBQQ__Opportunity2__r.Billing_Contact__c);
                contact = [
                        SELECT Id, Email, Phone, Title, Name, FirstName, LastName, AccountId,
                                Account.BillingStreet, Account.BillingCity, Account.BillingPostalCode, Account.BillingState, Account.BillingStateCode, Account.Billing_Address_Line_2__c,
                                Account.BillingCountry, Account.BillingCountryCode, Fax
                        FROM Contact
                        WHERE Id = :order.SBQQ__Quote__r.SBQQ__Opportunity2__r.Billing_Contact__c
                        LIMIT 1
                ];
            } else if (account.blng__BillToContact__c == null) {
                System.debug('InvoiceUtilities.retrieveBillingContact using account.blng__BillToContact__c ' + account.blng__BillToContact__c);
                contact = [
                        SELECT Id, Email, Phone, Title, Name, FirstName, LastName, AccountId,
                                Account.BillingStreet, Account.BillingCity, Account.BillingPostalCode, Account.BillingState, Account.BillingStateCode, Account.Billing_Address_Line_2__c,
                                Account.BillingCountry, Account.BillingCountryCode, Fax
                        FROM Contact
                        WHERE Id = :order.Account.blng__BillToContact__c
                        LIMIT 1
                ];
            } else {

                contact = [
                        SELECT Id, Email, Phone, Title, Name, FirstName, LastName, AccountId,
                                Account.BillingStreet, Account.BillingCity, Account.BillingPostalCode, Account.BillingState, Account.BillingStateCode, Account.Billing_Address_Line_2__c,
                                Account.BillingCountry, Account.BillingCountryCode, Fax
                        FROM Contact
                        WHERE AccountId = :order.AccountId AND Inactive__c = false
                        LIMIT 1
                ];
                System.debug('InvoiceUtilities.retrieveBillingContact using first contact on Account ' + contact != null ? contact.Id : '');
            }

            if(contact != null) {
                // Here we override the settings in the contact with the values set on the order, if they had been set.
                /*if(String.isNotBlank(order.BillingStreet) && String.isNotBlank(order.BillingCity) && String.isNotBlank(order.BillingState) && String.isNotBlank(order.BillingPostalCode)) {
                    contact.MailingStreet = order.BillingStreet;
                    contact.MailingCity = order.BillingCity;
                    contact.MailingState = order.BillingState;
                    contact.MailingPostalCode = order.BillingPostalCode;
                    contact.MailingCountry = order.BillingCountry;
                } */
                returnContactsByOrderIds.put(order.Id, contact);
            }
        }
        return returnContactsByOrderIds;
    }

    public static String retrieveCountryCode(String countryName) {
        if(countryName == null) {
            return 'US';
        } else if(countryName.length() == 2) {
            return countryName;
        } else {
            return isoCountries.get(countryName);
        }
    }

    public static Map<Integer, String> splitAddress(String singleLineAddress) {
        Map<Integer, String> splitAddress = new Map<Integer, String>();
        if(String.isBlank(singleLineAddress)) {
            splitAddress.put(1, '');
            splitAddress.put(2, '');
        } else if(singleLineAddress.contains('\r\n')) {
            splitAddress.put(1, singleLineAddress.substringBefore('\r\n'));
            splitAddress.put(2, singleLineAddress.substringAfter('\r\n').replace('\r\n', ' '));
        } else {
            splitAddress.put(1, singleLineAddress);
            splitAddress.put(2, '');
        }
        return splitAddress;
    }

    private static Map<String, String> isoCountries = new Map<String, String>{
             'Afghanistan' => 'AF',
             'Aland Islands' => 'AX',
             'Albania' => 'AL',
             'Algeria' => 'DZ',
             'American Samoa' => 'AS' ,
             'Andorra' => 'AD',
             'Angola' => 'AO',
             'Anguilla' => 'AI',
             'Antarctica' => 'AQ',
             'Antigua And Barbuda' => 'AG',
             'Argentina' => 'AR',
             'Armenia' => 'AM',
             'Aruba' => 'AW',
             'Australia' => 'AU',
             'Austria' => 'AT',
             'Azerbaijan' => 'AZ',
             'Bahamas' => 'BS',
             'Bahrain' => 'BH',
             'Bangladesh' => 'BD',
             'Barbados' => 'BB',
             'Belarus' => 'BY',
             'Belgium' => 'BE',
             'Belize' => 'BZ',
             'Benin' => 'BJ',
             'Bermuda' => 'BM',
             'Bhutan' => 'BT',
             'Bolivia' => 'BO',
             'Bosnia And Herzegovina' => 'BA',
             'Botswana' => 'BW',
             'Bouvet Island' => 'BV',
             'Brazil' => 'BR',
             'British Indian Ocean Territory' => 'IO',
             'Brunei Darussalam' => 'BN',
             'Bulgaria' => 'BG',
             'Burkina Faso' => 'BF',
             'Burundi' => 'BI',
             'Cambodia' => 'KH',
             'Cameroon' => 'CM',
             'Canada' => 'CA',
             'Cape Verde' => 'CV',
             'Cayman Islands' => 'KY',
             'Central African Republic' => 'CF',
             'Chad' => 'TD',
             'Chile' => 'CL',
             'China' => 'CN',
             'Christmas Island' => 'CX',
             'Cocos (Keeling) Islands' => 'CC',
             'Colombia' => 'CO',
             'Comoros' => 'KM',
             'Congo' => 'CG',
             'Congo, Democratic Republic' => 'CD',
             'Cook Islands' => 'CK',
             'Costa Rica' => 'CR',
             'Cote D\'Ivoire' => 'CI',
             'Croatia' => 'HR',
             'Cuba' => 'CU',
             'Cyprus' => 'CY',
             'Czech Republic' => 'CZ',
             'Denmark' => 'DK',
             'Djibouti' => 'DJ',
             'Dominica' => 'DM',
             'Dominican Republic' => 'DO',
             'Ecuador' => 'EC',
             'Egypt' => 'EG',
             'El Salvador' => 'SV',
             'Equatorial Guinea' => 'GQ',
             'Eritrea' => 'ER',
             'Estonia' => 'EE',
             'Ethiopia' => 'ET',
             'Falkland Islands (Malvinas)' => 'FK',
             'Faroe Islands' => 'FO',
             'Fiji' => 'FJ',
             'Finland' => 'FI',
             'France' => 'FR',
             'French Guiana' => 'GF',
             'French Polynesia' => 'PF',
             'French Southern Territories' => 'TF',
             'Gabon' => 'GA',
             'Gambia => ' => 'GM',
             'Georgia' => 'GE',
             'Germany' => 'DE',
             'Ghana' => 'GH',
             'Gibraltar' => 'GI',
             'Greece' => 'GR',
             'Greenland' => 'GL',
             'Grenada' => 'GD',
             'Guadeloupe' => 'GP',
             'Guam' => 'GU',
             'Guatemala' => 'GT',
             'Guernsey' => 'GG',
             'Guinea' => 'GN',
             'Guinea-Bissau' => 'GW',
             'Guyana' => 'GY',
             'Haiti' => 'HT',
             'Heard Island & Mcdonald Islands' => 'HM',
             'Holy See (Vatican City State)' => 'VA',
             'Honduras' => 'HN',
             'Hong Kong' => 'HK',
             'Hungary' => 'HU',
             'Iceland' => 'IS',
             'India' => 'IN',
             'Indonesia' => 'ID',
             'Iran, Islamic Republic Of' => 'IR',
             'Iraq' => 'IQ',
             'Ireland' => 'IE',
             'Isle Of Man' => 'IM',
             'Israel' => 'IL',
             'Italy' => 'IT',
             'Jamaica ' => 'JM',
             'Japan' => 'JP',
             'Jersey' => 'JE',
             'Jordan' => 'JO',
             'Kazakhstan' => 'KZ',
             'Kenya' => 'KE',
             'Kiribati' => 'KI',
             'Korea' => 'KR',
             'Kuwait' => 'KW',
             'Kyrgyzstan' => 'KG',
             'Lao People\'s Democratic Republic' => 'LA',
             'Latvia' => 'LV',
             'Lebanon' => 'LB',
             'Lesotho' => 'LS',
             'Liberia' => 'LR',
             'Libyan Arab Jamahiriya' => 'LY',
             'Liechtenstein' => 'LI',
             'Lithuania' => 'LT',
             'Luxembourg' => 'LU',
             'Macao' => 'MO',
             'Macedonia' => 'MK',
             'Madagascar' => 'MG',
             'Malawi' => 'MW',
             'Malaysia' => 'MY',
             'Maldives' => 'MV',
             'Mali' => 'ML',
             'Malta' => 'MT',
             'Marshall Islands' => 'MH',
             'Martinique' => 'MQ',
             'Mauritania' => 'MR',
             'Mauritius' => 'MU',
             'Mayotte' => 'YT',
             'Mexico' => 'MX',
             'Micronesia, Federated States Of' => 'FM',
             'Moldova' => 'MD',
             'Monaco' => 'MC',
             'Mongolia' => 'MN',
             'Montenegro' => 'ME',
             'Montserrat' => 'MS',
             'Morocco' => 'MA',
             'Mozambique' => 'MZ',
             'Myanmar' => 'MM',
             'Namibia' => 'NA',
             'Nauru' => 'NR',
             'Nepal' => 'NP',
             'Netherlands' => 'NL',
             'Netherlands Antilles' => 'AN',
             'New Caledonia' => 'NC',
             'New Zealand' => 'NZ',
             'Nicaragua' => 'NI',
             'Niger' => 'NE',
             'Nigeria' => 'NG',
             'Niue' => 'NU',
             'Norfolk Island' => 'NF',
             'Northern Mariana Islands' => 'MP',
             'Norway' => 'NO',
             'Oman' => 'OM',
             'Pakistan' => 'PK',
             'Palau' => 'PW',
             'Palestinian Territory, Occupied' => 'PS',
             'Panama' => 'PA',
             'Papua New Guinea' => 'PG',
             'Paraguay' => 'PY',
             'Peru' => 'PE',
             'Philippines' => 'PH',
             'Pitcairn' => 'PN',
             'Poland' => 'PL',
             'Portugal' => 'PT',
             'Puerto Rico' => 'PR',
             'Qatar' => 'QA',
             'Reunion' => 'RE',
             'Romania' => 'RO',
             'Russian Federation' => 'RU',
             'Rwanda' => 'RW',
             'Saint Barthelemy' => 'BL',
             'Saint Helena' => 'SH',
             'Saint Kitts And Nevis' => 'KN',
             'Saint Lucia' => 'LC',
             'Saint Martin' => 'MF',
             'Saint Pierre And Miquelon' => 'PM',
             'Saint Vincent And Grenadines' => 'VC',
             'Samoa' => 'WS',
             'San Marino' => 'SM',
             'Sao Tome And Principe' => 'ST',
             'Saudi Arabia' => 'SA',
             'Senegal' => 'SN',
             'Serbia' => 'RS',
             'Seychelles' => 'SC',
             'Sierra Leone' => 'SL',
             'Singapore' => 'SG',
             'Slovakia' => 'SK',
             'Slovenia' => 'SI',
             'Solomon Islands' => 'SB',
             'Somalia' => 'SO',
             'South Africa' => 'ZA',
             'South Georgia And Sandwich Isl.' => 'GS',
             'Spain' => 'ES',
             'Sri Lanka' => 'LK',
             'Sudan' => 'SD',
             'Suriname' => 'SR',
             'Svalbard And Jan Mayen' => 'SJ',
             'Swaziland' => 'SZ',
             'Sweden' => 'SE',
             'Switzerland' => 'CH',
             'Syrian Arab Republic' => 'SY',
             'Taiwan' => 'TW',
             'Tajikistan' => 'TJ',
             'Tanzania' => 'TZ',
             'Thailand' => 'TH',
             'Timor-Leste' => 'TL',
             'Togo' => 'TG',
             'Tokelau' => 'TK',
             'Tonga' => 'TO',
             'Trinidad And Tobago' => 'TT',
             'Tunisia' => 'TN',
             'Turkey' => 'TR',
             'Turkmenistan' => 'TM',
             'Turks And Caicos Islands' => 'TC',
             'Tuvalu' => 'TV',
             'Uganda' => 'UG',
             'Ukraine' => 'UA',
             'United Arab Emirates' => 'AE',
             'United Kingdom' => 'GB',
             'United States' => 'US',
             'USA' => 'US',
             'United States Outlying Islands' => 'UM',
             'Uruguay' => 'UY',
             'Uzbekistan' => 'UZ',
             'Vanuatu' => 'VU',
             'Venezuela' => 'VE',
             'Viet Nam' => 'VN',
             'Virgin Islands, British' => 'VG',
             'Virgin Islands, U.S.' => 'VI',
             'Wallis And Futuna' => 'WF',
             'Western Sahara' => 'EH',
             'Yemen' => 'YE',
             'Zambia' => 'ZM',
             'Zimbabwe' => 'ZW'
    };

    public static String retrieveStateCode(String stateName) {
        if(stateName == null) {
            return '';
        } else if(stateName.length() < 3) {
            return stateName;
        } else {
            String stateValue = isoStates.get(stateName);
            if(stateValue == null) {
                return stateName;
            }
            return stateValue;
        }
    }

    public static void distributeCurrencyAmount(List<SObject> objects, String currencyField, Decimal totalAmount) {
        Integer numObjects = objects.size();
        System.debug('InvoiceUtilities.distributeCurrencyAmount numObjects: ' + numObjects);
        Decimal amountPerObject = (totalAmount / numObjects).setScale(2);
        System.debug('InvoiceUtilities.distributeCurrencyAmount amountPerObject: ' + amountPerObject);
        Decimal leftOverAmountRounded = (totalAmount - amountPerObject * numObjects).setScale(2, System.RoundingMode.HALF_UP);
        System.debug('InvoiceUtilities.distributeCurrencyAmount init leftOverAmountRounded: ' + leftOverAmountRounded);

        for (SObject obj : objects) {
            Decimal extraAmount;
            System.debug('InvoiceUtilities.distributeCurrencyAmount leftOverAmountRounded: ' + leftOverAmountRounded);
            if (leftOverAmountRounded != 0) {
                Decimal additionalAmount = leftOverAmountRounded > 0
                    ? 0.01
                    : -0.01;
                extraAmount = amountPerObject + additionalAmount;

                leftOverAmountRounded -= additionalAmount;
            } else {
                extraAmount = amountPerObject;
            }

            System.debug('InvoiceUtilities.distributeCurrencyAmount extraAmount: ' + extraAmount);
            Decimal currentAmount = (Decimal)obj.get(currencyField);
            System.debug('InvoiceUtilities.distributeCurrencyAmount currentAmount: ' + currentAmount);
            obj.put(currencyField, currentAmount + extraAmount);
        }
    }
    
    private static Map<String, String> isoStates = new Map<String, String>{
            'Arizona' => 'AZ',
            'Alabama' => 'AL',
            'Alaska' => 'AK',
            'Arizona' => 'AZ',
            'Arkansas' => 'AR',
            'California' => 'CA',
            'Colorado' => 'CO',
            'Connecticut' => 'CT',
            'Delaware' => 'DE',
            'Florida' => 'FL',
            'Georgia' => 'GA',
            'Hawaii' => 'HI',
            'Idaho' => 'ID',
            'Illinois' => 'IL',
            'Indiana' => 'IN',
            'Iowa' => 'IA',
            'Kansas' => 'KS',
            'Kentucky' => 'KY',
            'Kentucky' => 'KY',
            'Louisiana' => 'LA',
            'Maine' => 'ME',
            'Maryland' => 'MD',
            'Massachusetts' => 'MA',
            'Michigan' => 'MI',
            'Minnesota' => 'MN',
            'Mississippi' => 'MS',
            'Missouri' => 'MO',
            'Montana' => 'MT',
            'Nebraska' => 'NE',
            'Nevada' => 'NV',
            'New Hampshire' => 'NH',
            'New Jersey' => 'NJ',
            'New Mexico' => 'NM',
            'New York' => 'NY',
            'North Carolina' => 'NC',
            'North Dakota' => 'ND',
            'Ohio' => 'OH',
            'Oklahoma' => 'OK',
            'Oregon' => 'OR',
            'Pennsylvania' => 'PA',
            'Rhode Island' => 'RI',
            'South Carolina' => 'SC',
            'South Dakota' => 'SD',
            'Tennessee' => 'TN',
            'Texas' => 'TX',
            'Utah' => 'UT',
            'Vermont' => 'VT',
            'Virginia' => 'VA',
            'Washington' => 'WA',
            'West Virginia' => 'WV',
            'Wisconsin' => 'WI',
            'Wyoming' => 'WY'/*,
            'Alderney' => 'ALD',
            'County Atrium' => 'ATM',
            'Atrium' => 'ATM',
            'County Armagh' => 'ARM',
            'Armagh' => 'ARM',
            'Avon' => 'AVN',
            'Bedfordshire' => 'BFD',
            'Berkshire' => 'BRK',
            'Borders' => 'BDS',
            'Buckinghamshire' => 'BUX',
            'Cambridgeshire' => 'CBE',
            'Central' => 'CTR',
            'Cheshire' => 'CHS',
            'Cleveland' => 'CVE',
            'Clwyd' => 'CLD',
            'Cornwall' => 'CNL',
            'Cumbria' => 'CBA',
            'Derbyshire' => 'DYS',
            'Devon' => 'DVN',
            'Dorse' => 'DOR',
            'County Down' => 'DWN',
            'Down' => 'DWN',
            'Dumfries and Galloway' => 'DGL',
            'County Durham' => 'DHM',
            'Durham' => 'DHM',
            'Dyfed' => 'DFD',
            'Essex' => 'ESX',
            'County Fermanagh' => 'FMH',
            'Fermanagh' => 'FMH',
            'Fife' => 'FFE',
            'Mid Glamorgan' => 'GNM',
            'South Glamorgan' => 'GNS',
            'West Glamorgan' => 'GNW',
            'Gloucester' => 'GLR',
            'Grampian' => 'GRN',
            'Guernsey' => 'GUR',
            'Gwent' => 'GWT',
            'Gwynedd' => 'GDD',
            'Hampshire' => 'HPH',
            'Hereford and Worcester' => 'HWR',
            'Hertfordshire' => 'HFD',
            'Highlands' => 'HLD',
            'Humberside' => 'HBS',
            'Isle of Man' => 'IOM',
            'Isle of Wight' => 'IOW',
            'Jersey' => 'JER',
            'Kent' => 'KNT',
            'Lancashire' => 'LNH',
            'Leicestershire' => 'LEC',
            'Lincolnshire' => 'LCN',
            'Greater London' => 'LDN',
            'County Londonderry' => 'LDR',
            'Londonderry' => 'LDR',
            'Lothian' => 'LTH',
            'Greater Manchester' => 'MCH',
            'Merseyside' => 'MSY',
            'Norfolk' => 'NOR',
            'Northamptonshire' => 'NHM',
            'Northumberland' => 'NLD',
            'Nottinghamshire' => 'NOT',
            'Orkney' => 'ORK',
            'Oxfordshire' => 'OFE',
            'Powys' => 'PWS',
            'Shropshire' => 'SPE',
            'Sark' => 'SRK',
            'Shetland' => 'SLD',
            'Somerset' => 'SOM',
            'Staffordshire' => 'SFD',
            'Strathclyde' => 'SCD',
            'Suffolk' => 'SFK',
            'Surrey' => 'SRY',
            'East Sussex' => 'SXE',
            'West Sussex' => 'SXW',
            'Tayside' => 'TYS',
            'Tyne and Wear' => 'TWR',
            'County Tyrone' => 'TYR',
            'Warwickshire' => 'WKS',
            'Western Isles' => 'WIL',
            'West Midlands' => 'WMD',
            'Wiltshire' => 'WLT',
            'North Yorkshire' => 'YSN',
            'South Yorkshire' => 'YSS',
            'West Yorkshire' => 'YSW' */
    };

}