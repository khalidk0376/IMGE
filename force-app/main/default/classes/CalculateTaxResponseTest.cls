/**
* Created by stevelohrenz on 5/4/17.
*/

@IsTest
private class CalculateTaxResponseTest {
    static testMethod void testParse() {
        String json = '{\"Header\": {'+
            '    \"Systems\": {'+
            '      \"CallingApplication\": \"SFDC-GE\",'+
            '      \"MessageDate\": \"2019-03-14\",'+
            '      \"MessageStatus\": \"OK\",'+
            '      \"MessageStatusText\": null'+
            '    }'+
            '  },'+
            '  \"Content\": {'+
            '    \"Transaction\": {'+
            '      \"MetaData\": {'+
            '        \"Customer\": {'+
            '          \"CustomerNumber\": \"0003718346\",'+
            '          \"CustomerEmail\": \"anshika.sharma@girikon.com\"'+
            '        },'+
            '        \"TransactionDetail\": null,'+
            '        \"AddressGroup\": {'+
            '          \"BillTo\": {'+
            '            \"PersonName\": {'+
            '              \"Prefix\": null,'+
            '              \"FirstNames\": \"Shaswat\",'+
            '              \"LastName\": \"Kar\"'+
            '            },'+
            '            \"Address\": {'+
            '              \"Organisation\": null,'+
            '              \"Department\": null,'+
            '              \"AddressLine1\": \"3-4 Apex Court\\nBassendale Road\",'+
            '              \"AddressLine2\": null,'+
            '              \"City\": \"Bromborough\",'+
            '              \"PostalCode\": \"CH62 3RE\",'+
            '              \"State\": \"AB\",'+
            '              \"Country\": \"UK\",'+
            '              \"PhoneNumber\": null,'+
            '              \"PhoneExtension\": null,'+
            '              \"FaxNumber\": null'+
            '            }'+
            '          },'+
            '          \"ShipTo\": {'+
            '            \"PersonName\": {'+
            '              \"Prefix\": null,'+
            '              \"FirstNames\": \"Shaswat\",'+
            '              \"LastName\": \"Kar\"'+
            '            },'+
            '            \"Address\": {'+
            '              \"Organisation\": null,'+
            '              \"Department\": null,'+
            '              \"AddressLine1\": \"3-4 Apex Court\\nBassendale Road\",'+
            '              \"AddressLine2\": null,'+
            '              \"City\": \"Bromborough\",'+
            '              \"PostalCode\": \"CH62 3RE\",'+
            '              \"State\": \"AB\",'+
            '              \"Country\": \"UK\",'+
            '              \"PhoneNumber\": null,'+
            '              \"PhoneExtension\": null,'+
            '              \"FaxNumber\": null'+
            '            }'+
            '          }'+
            '        },'+
            '        \"PaymentMethod\": null,'+
            '        \"Currency\": \"GBP\",'+
            '        \"TaxLabel\": \"TAX\"'+
            '      },'+
            '      \"CartItems\": ['+
            '        {'+
            '          \"CartItem\": {'+
            '            \"Quantity\": 400,'+
            '            \"Price\": 200000,'+
            '            \"Tax\": 0,'+
            '            \"TaxRates\": ['+
            '              {'+
            '                \"TaxRate\": 500,'+
            '                \"TaxAmount\": 10000'+
            '              },'+
            '              {'+
            '                \"TaxRate\": -500,'+
            '                \"TaxAmount\": -10000'+
            '              }'+
            '            ],'+
            '            \"ItemData\": {'+
            '              \"ProductCode\": \"GE20AH.002\"'+
            '            }'+
            '          }'+
            '        },'+
            '        {'+
            '          \"CartItem\": {'+
            '            \"Quantity\": 100,'+
            '            \"Price\": 0,'+
            '            \"Tax\": 0,'+
            '            \"TaxRates\": ['+
            '              {'+
            '                \"TaxRate\": 500,'+
            '                \"TaxAmount\": 0'+
            '              },'+
            '              {'+
            '                \"TaxRate\": -500,'+
            '                \"TaxAmount\": 0'+
            '              }'+
            '            ],'+
            '            \"ItemData\": {'+
            '              \"ProductCode\": \"GE20AH.080\"'+
            '            }'+
            '          }'+
            '        },'+
            '        {'+
            '          \"CartItem\": {'+
            '            \"Quantity\": 9000,'+
            '            \"Price\": 7128000,'+
            '            \"Tax\": 0,'+
            '            \"TaxRates\": ['+
            '              {'+
            '                \"TaxRate\": 500,'+
            '                \"TaxAmount\": 356400'+
            '              },'+
            '              {'+
            '                \"TaxRate\": -500,'+
            '                \"TaxAmount\": -356400'+
            '              }'+
            '            ],'+
            '            \"ItemData\": {'+
            '              \"ProductCode\": \"GE20AH.133\"'+
            '            }'+
            '          }'+
            '        },'+
            '        {'+
            '          \"CartItem\": {'+
            '            \"Quantity\": 100,'+
            '            \"Price\": 27500,'+
            '            \"Tax\": 0,'+
            '            \"TaxRates\": ['+
            '              {'+
            '                \"TaxRate\": 500,'+
            '                \"TaxAmount\": 1375'+
            '              },'+
            '              {'+
            '                \"TaxRate\": -500,'+
            '                \"TaxAmount\": -1375'+
            '              }'+
            '            ],'+
            '            \"ItemData\": {'+
            '              \"ProductCode\": \"GEDGOMNIA.101-1001\"'+
            '            }'+
            '          }'+
            '        }'+
            '      ],'+
            '      \"TaxItems\": null'+
            '    }'+
            '  },'+
            '  \"Messages\": ['+
            '    {'+
            '      \"MessageReference\": \"anshika.sharma@girikon.com\",'+
            '      \"MessageSeverity\": \"5\",'+
            '      \"MessageType\": \"Success\",'+
            '      \"MessageID\": \"0\",'+
            '      \"MessageText\": null'+
            '    }'+
            '  ]'+
            '}}';
        
        CalculateTaxResponse obj = CalculateTaxResponse.parse(json);
        System.assertNotEquals(obj , null,'Tax response is empty');
        System.assertNotEquals(obj.Content.Transaction_x, null,'No data in Content_Transaction');
        System.assertEquals('GBP', obj.Content.Transaction_x.MetaData.Currency_x,'No data in Content_Transaction_MetaData_Currency_x');
        CalculateTaxResponse.serializeToString(obj);
    }
}