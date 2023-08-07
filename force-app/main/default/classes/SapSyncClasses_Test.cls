/**
 * @Author    : Sudip Halder
 * @Date      : 02/Nov/2017
 * Apex Class : SapSyncClasses
 */

@IsTest
public class SapSyncClasses_Test {
	
	static testMethod void testParse() {
		String json = '{'+
		'    \"Header\": {'+
		'        \"Systems\": {'+
		'            \"CallingApplication\": \"SFDC-GE\",'+
		'            \"MessageDate\": \"2017-11-01\",'+
		'            \"MessageStatus\": \"ERROR\",'+
		'            \"MessageStatusText\": \"Unknown product. See messages for more details.\"'+
		'        }'+
		'    },'+
		'    \"Products\": ['+
		'        {'+
		'            \"ProductCode\": \"TOCEUR2017\"'+
		'        },'+
		'        {'+
		'            \"ProductCode\": \"TOCEUR2018\"'+
		'        }'+
		'    ],'+
		'    \"Results\": ['+
		'        {'+
		'            \"ProductCode\": \"TOCEUR2017\",'+
		'            \"isValid\": false'+
		'        },'+
		'        {'+
		'            \"ProductCode\": \"TOCEUR2018\",'+
		'            \"isValid\": false'+
		'        }'+
		'    ],'+
		'    \"Messages\": ['+
		'        {'+
		'            \"MessageReference\": \"TOCEUR2017\",'+
		'            \"MessageSeverity\": \"1\",'+
		'            \"MessageType\": \"ERROR\",'+
		'            \"MessageID\": \"99\",'+
		'            \"MessageText\": \"Error \'EXCEPTION\': \'INVALID_MATERIAL\'.\"'+
		'        },'+
		'        {'+
		'            \"MessageReference\": \"TOCEUR2018\",'+
		'            \"MessageSeverity\": \"1\",'+
		'            \"MessageType\": \"ERROR\",'+
		'            \"MessageID\": \"99\",'+
		'            \"MessageText\": \"Error \'EXCEPTION\': \'INVALID_MATERIAL\'.\"'+
		'        }'+
		'    ]'+
		'}';
		SapSyncClasses obj = SapSyncClasses.parse(json);
		System.assert(obj != null,'Condition should match');
	}
}