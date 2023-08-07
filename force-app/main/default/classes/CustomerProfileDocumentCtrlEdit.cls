/**
 * Created/Modified By: Girikon(Amish,Archit)
 * Created On:          10/4/2017
 * Description/Purpose: This class is the controller for "CustomerProfileDocumentEdit" VF pages
 *                      This class add  new documents or update the existing documents on customer profile
 * Methods:             saveDocument, checkFileFormat
 * Test Class:          CustomerProfileDocumentCtrlEdit_Test 
 **/

public class CustomerProfileDocumentCtrlEdit
{
    public Exhibiting_Document__c  oExhibitorDocList{get;set;}
    public Attachment att{get;set;}
    public String sMessage{get;set;}
    public String fileName{get;set;}
    public boolean check{get;set;}
    public String docuId{get;set;}
    public String Title{ get; set; }
    public String Description{ get; set; }   
    public String Contact{ get; set; }
    public String eventEdition{ get; set; }
    public String ExpocadBooth{ get; set; }
    public String existingDoc{ get; set; }
    public String existingDocId{ get; set; }
    public transient blob Photo{get;set;}
    public Boolean found {get;set;}
    public String errorMessage{get;set;}
    //public String BrandingColor{get;set;}  
    public String ButtonBackgroundColor{get;set;}
    public String ButtonTextColor{get;set;}
    public Exhibiting_Document__c docListing{ get; set; }    
     // Constructer that will grab the URL parameters            
    public CustomerProfileDocumentCtrlEdit()
    {
        oExhibitorDocList = new Exhibiting_Document__c();
        String docuId = ApexPages.currentPage().getParameters().get('docId').escapeHtml4();
        String scheck = ApexPages.currentPage().getParameters().get('check').escapeHtml4();
        String eventId = ApexPages.currentPage().getParameters().get('eventId').escapeHtml4();
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
        
        if(String.isNotBlank(scheck))
        {
            check=true;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Please Check for the correct file type Or you may have limit the max file size of 25MB')); 
        }             
        if(String.isNotBlank(docuId))
        {
               docListing= [select Id, Name, Description__c, Contact__c, Event_Edition__c, ExpocadBooth__c, Document_Upload_Id__c   from Exhibiting_Document__c where id=:docuId limit 1];
               Title = docListing.Name ;
               Description = docListing.Description__c ;
               Contact= docListing.Contact__c;
               List <Attachment> attach= [Select Id, name, parentId  from Attachment where parentId =: docListing.Id order by CreatedDate desc limit 1];
               if (attach.size()!=null && attach.size()>0)
               {
                   existingDoc=attach[0].Name;   
                   existingDocId= attach[0].Id; 
               }                       
        }   
    }
    //function is used to update record and attach the new file to the records, and also check for the file type
    public PageReference saveDocument()
    {
        try
        {
            String sEventId = ApexPages.currentPage().getParameters().get('eventId').escapeHtml4();
            String docuId = ApexPages.currentPage().getParameters().get('docId').escapeHtml4();
            Boolean flagCheck=true;
            Exhibiting_Document__c dList = new Exhibiting_Document__c();
            dList.ID = String.escapeSingleQuotes(docuId);
            dList.Name = Title ;
            dList.Description__c = Description;
            
            System.debug('fileName : '+fileName+'Photo '+Photo );
            //condition to check file and file type
            if(String.isNotBlank(fileName) && Photo != null &&checkFileFormat(fileName))
            {
                Attachment att = new Attachment();
                att.Name = fileName;
                att.Body = Photo;
                att.parentId = docuId ;
                if(att.body != null)
                { 
                    System.debug(att.body.size()+'size of file');        
                    if(att.body.size()>25000000)
                    {
                        flagCheck=false;
                    }
                    else
                        flagCheck=true;
                }
                system.debug('====flagcheck= '+flagCheck);
                if(flagCheck)
                {
                    List<Attachment> attList = [Select Id from Attachment where parentId =:docuId];
                        if(attList.size()>0)
                            delete attList;
                    insert att; 
                    dList.Document_Upload_Id__c = att.id;
                }
                
            }
            if (String.isNotBlank(fileName) && Photo != null &&!checkFileFormat(fileName))
            {
                 flagCheck=false;
            }
           
            
            if(flagCheck)
            { system.debug('In Flag====');
                if(String.isNotBlank(fileName))
                {
                    update dList;
                    system.debug('In Flag====1');
                    PageReference redirectPage = Page.CustomerProfileDocumentEdit;
                    redirectPage.setRedirect(true);
                    redirectPage.getParameters().put('eventId',sEventId);
                    redirectPage.getParameters().put('docId',docuId);
                    return redirectPage; 
                }    
                else
                {
                    update dList;
                    system.debug('In Flag====2');
                    PageReference redirectPage = Page.CustomerProfileDocumentEdit;
                    redirectPage.setRedirect(true);
                    redirectPage.getParameters().put('eventId',sEventId);
                    redirectPage.getParameters().put('docId',docuId);
                    return redirectPage; 
                }
            }
            else
            {
                PageReference redirectPage = Page.CustomerProfileDocumentEdit;
                redirectPage.setRedirect(true);
                redirectPage.getParameters().put('eventId',sEventId);
                redirectPage.getParameters().put('docId',docuId);
                redirectPage.getParameters().put('check','true');
                return redirectPage;
            }
        }
        catch(Exception e)
        {
           System.debug('Message:='+e.getMessage()+'**Line Number='+e.getLineNumber());
        }  
        return null;
    }
    
    // method to the file type
     public Boolean checkFileFormat(String fileName)
    {
        String sFileTypes = (AllowedFileTypes__c.getValues('FileTypes') != null) ? AllowedFileTypes__c.getValues('FileTypes').Value__c : 'pdf'; //retrieve file type format name from custom setting.
        set<String> setExtAllowed = new set<String>(sFileTypes.split(',')); //Adding file format type.
        fileName= fileName.toLowerCase();
        List<String> parts = fileName.splitByCharacterType();
        if(!setExtAllowed.contains(parts[parts.size()-1])) // checking file format.
        {
            return false; //show error file format does not have pdf format. 
        }
        return true;        
    }    
}