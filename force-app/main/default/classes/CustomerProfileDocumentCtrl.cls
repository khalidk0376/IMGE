/**
 * Created/Modified By: Girikon(Amish)
 * Created On:          9/27/2017
 * Description/Purpose: This class is the controller for "CustomerProfileDocument" VF pages
 *                      This class upload new  documents on customer profile
 * Methods:             saveDocument, checkFileFormat
 * Test Class:          CustomerProfileDocumentCtrl_Test 
 **/

public class CustomerProfileDocumentCtrl
{
    public Exhibiting_Document__c oExhibitorDocument{get;set;}
    public Attachment Att{get;set;}
    public String sMessage{get;set;}
    public boolean check{get;set;}
    public boolean faultCheck{get;set;}
    public Transient Blob attBody{get;set;}
    public String attName{get;set;}
    public boolean flagMessage{get;set;}
    //public String BrandingColor{get;set;}
    public String ButtonBackgroundColor{get;set;}
    public String ButtonTextColor{get;set;}
   
    // Constructer that will grab the URL parameters
    public CustomerProfileDocumentCtrl()
    {
        oExhibitorDocument = new Exhibiting_Document__c(); 
        String eventId = ApexPages.currentPage().getParameters().get('eventId');
        if(eventId != null)
        {
            List<Event_Settings__c> eventSet = [Select Id, Name,Button_Text_Color__c,Button_colors__c, Branding_Color__c,Event_Edition__c, Event_Edition__r.Event_Code__c from Event_Settings__c where Event_Edition__c =: eventId];
            if(!eventSet.IsEmpty())
            {
                //BrandingColor = eventSet[0].Branding_Color__c; 
                //Added on enhancement project                
                ButtonBackgroundColor= eventSet[0].Button_colors__c;
                ButtonTextColor = eventSet[0].Button_Text_Color__c;
            }
        } 
        String checkRender= ApexPages.currentPage().getParameters().get('checkRender');  
        if(String.isNotBlank(checkRender)&&checkRender=='true')
        {
                check=true; 
                flagMessage=true;
                ApexPages.Message myMsg1 = new ApexPages.Message(ApexPages.Severity.Info,'Document has been added. Please close this window');
                ApexPages.addMessage(myMsg1);
        }     
        if (String.isNotBlank(checkRender)&&checkRender=='false')
        {
            flagMessage=false; 
            check=false;
            ApexPages.Message myMsg1 = new ApexPages.Message(ApexPages.Severity.WARNING,'ERROR !!!!   Please check the document type');
            ApexPages.addMessage(myMsg1);
        }
         
    }
    // function is used to create new record and attach the file to the records, also check for the file type
    public PageReference saveDocument()
    {
        try
        {
            String sEventId = ApexPages.currentPage().getParameters().get('eventId').escapeHtml4();
            String expoId = ApexPages.currentPage().getParameters().get('expoId').escapeHtml4();
            String conId = ApexPages.currentPage().getParameters().get('conId').escapeHtml4();          
            String checkRender= ApexPages.currentPage().getParameters().get('checkRender');
            
            if(oExhibitorDocument != null && String.isNotBlank(sEventId ) && String.isNotBlank(expoId) && String.isNotBlank(conId ))//&& String.isBlank(checkRender))
            {               
                    if((String.isNotBlank(attName) && checkFileFormat(attName)))
                    {
                        oExhibitorDocument.Contact__c= conId ;
                        oExhibitorDocument.Event_Edition__c =sEventId;
                        oExhibitorDocument.ExpocadBooth__c= expoId;                      
                        insert oExhibitorDocument;
                        
                        system.debug ('amish');
                        Attachment  att = new Attachment(Name=attName, Body = attBody,ParentId = oExhibitorDocument.id);                 
                        insert att;
                        
                        oExhibitorDocument.Document_Upload_Id__c= Att.id;
                        update oExhibitorDocument; 
                        
                        PageReference redirectPage = Page.CustomerProfileDocument;
                        redirectPage.setRedirect(true);
                        redirectPage.getParameters().put('eventId',sEventId);
                        redirectPage.getParameters().put('checkRender','true');
                        return redirectPage;   
                    }
                    else
                    {
                        PageReference redirectPage = Page.CustomerProfileDocument;
                        redirectPage.setRedirect(true);
                        redirectPage.getParameters().put('eventId',sEventId);
                        redirectPage.getParameters().put('checkRender','false');
                        redirectPage.getParameters().put('expoId',expoId);
                        redirectPage.getParameters().put('conId',conId);
                        return redirectPage; 
                    }
            }
        }
        catch(Exception e)
        {
           System.debug('Message:='+e.getMessage()+'**Line Number='+e.getLineNumber());
        }  
        return null;
    }
    // function is used to check the file format
    public Boolean checkFileFormat(String fileName)
    {
        String sFileTypes = (AllowedFileTypes__c.getValues('FileTypes') != null) ? AllowedFileTypes__c.getValues('FileTypes').Value__c : 'pdf'; //retrieve file type format name from custom setting.
        set<String> setExtAllowed = new set<String>(sFileTypes.split(',')); //Adding file format type.
        string fname=fileName.toLowerCase();
        List<String> parts = fname.splitByCharacterType();
        if(!setExtAllowed.contains(parts[parts.size()-1])) // checking file format.
        {
            return false; //show error file format does not have pdf format. 
        }
        return true;        
    }
}