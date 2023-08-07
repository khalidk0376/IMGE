/**
 * Created/Modified By: Girikon(Archit )
 * Created On:          08/30/2017
 * Description/Purpose: This class is used for the Product Listing tab on Customer Community
 *                      This class is used to edit the proudct Listingas per the Event Edition, Contact and Expocad Booth.
 *                      This class is the controller for "CustomerProfileProductListingEdit" VF pages
 * Methods:             saveProductList
 * Test Class:          CustomerProfileProductListingEdit_Test 
 **/
 
public class CustomerProfileProductListingEditCtrl
{
    public Exhibitor_Product_Listing__c oExhibitorProductList{get;set;}
    public Attachment Att{get;set;}
    public String sMessage{get;set;}
    public String fileName{get;set;}
    public boolean check{get;set;}
    public String productId{get;set;}
    public String Title{ get; set; }
    public String Description{ get; set; }
    public boolean IsNew{ get; set; }
    public String Contact{ get; set; }
    public String eventEdition{ get; set; }
    public String ExpocadBooth{ get; set; }
    public String Account{ get; set; }
    public String imageId{ get; set; }
    public String imageURL{ get; set; }
    public transient blob Photo{get;set;}
    public Boolean found {get;set;}
    public Exhibitor_Product_Listing__c prodListing{ get; set; }  
    //public String BrandingColor{get;set;}
    public String ButtonBackgroundColor{get;set;}
    public String ButtonTextColor{get;set;}  
    
    // Constructer that will grab the URL parameters        
    public CustomerProfileProductListingEditCtrl()
    {
        oExhibitorProductList = new Exhibitor_Product_Listing__c();
        String productId = ApexPages.currentPage().getParameters().get('pId').escapeHtml4();
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
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'File is not Uploaded: Max.File Size is 250KB')); 
        }  
        if((ApexPages.currentPage().getParameters().get('found'))=='false')
       {    
            check=true;
            ApexPages.Message myMsg1 = new ApexPages.Message(ApexPages.Severity.Info,'Please upload correct Image.');
            ApexPages.addMessage(myMsg1);
       }                   
        if(String.isNotBlank(productId))
        {
               prodListing= [select Id, Name, Description__c, Contact__c, Event_Edition__c, ExpocadBooth__c, Image_Id__c, Is_New__c  from Exhibitor_Product_Listing__c where id=:productId limit 1];
       
               Title = prodListing.Name;
               Description = prodListing.Description__c;
               Contact= prodListing.Contact__c;
               IsNew=prodListing.Is_New__c;
               
               imageURL='/servlet/servlet.FileDownload?file='+prodListing.Image_Id__c;
        }   
    }
    //function is used to upate record and attach the new file to the records, also check the file type
    public PageReference saveProductList()
    {
        try
        {
            String sEventId = ApexPages.currentPage().getParameters().get('eventId').escapeHtml4();
            String productId = ApexPages.currentPage().getParameters().get('pId').escapeHtml4();
            found = false;
            Boolean fCheck=true;
            List <AllowedImageTypes__c> acceptedImgType = [Select name from AllowedImageTypes__c];
            Set<String> acceptedExtensions = new Set<String> {'.png','.jpeg','.jpg','.gif'};
            Set<String> rejectedExtensions = new Set<String> {'.pdf'};
           
           if(String.isNotBlank(fileName) && Photo != null)
           {
                for(AllowedImageTypes__c s : acceptedImgType)
                {
                    // condition to check file type
                    if(found = fileName.endsWith(s.name))//s))
                    {    system.debug('Test1'+s);
                        found=true;
                        break;
                    }
                }
            }
            else
                found = true;
            
            if(!found)
            {   
                if(String.isNotBlank(fileName) && Photo != null)
                {
                    for(String s : rejectedExtensions ){
                        // condition to check file type
                        if(found = fileName.endsWith(s))
                        {   system.debug('Test2');
                            found = false;
                            break;
                        }
                    }
                }
            }
            if(!found)
            { 
                system.debug('found='+found);                
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.WARNING,'Please upload correct Image.'));
                PageReference redirectPage = Page.CustomerProfileProductListingEdit;
                redirectPage.setRedirect(true);
                redirectPage.getParameters().put('pId',productId );
                redirectPage.getParameters().put('found','false');              
                return redirectPage;
            }
            
            else
            {
                
                Boolean flagCheck=true;
                Exhibitor_Product_Listing__c prodList = new Exhibitor_Product_Listing__c();
                prodList.ID = productId;
                prodList.Name = Title ;
                prodList.Description__c = Description;
                prodList.Is_New__c = IsNew ;
                
                System.debug('fileName : '+fileName+'Photo '+Photo );
                if(String.isNotBlank(fileName) && Photo != null)
                {
                    Attachment Att = new Attachment();
                    Att.Name = fileName;
                    Att.Body = Photo;
                    Att.parentId =productId;
                    if(Att.body != null)
                    { 
                        System.debug(Att.body.size()+'size of file');        
                        if(Att.body.size()>250000)
                        {
                            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'File is not Uploaded:Max.File Size is 250KB')); 
                            check=true; flagCheck=false;
                        }
                        else
                            flagCheck=true;
                    }
                    system.debug('====flagcheck= '+flagCheck);
                    if(flagCheck)
                    {   
                        List<Attachment> attList = [Select Id from Attachment where parentId =:productId];
                        if(attList.size()>0)
                            delete attList;
                        insert Att; 
                        prodList.Image_Id__c = Att.id;
                    }
                    
                }
                
                if(flagCheck)
                { system.debug('In Flag====');
                    if(String.isNotBlank(fileName))
                    {
                        update prodList;
                        system.debug('In Flag====1');
                        PageReference redirectPage = Page.CustomerProfileProductListingEdit;
                        redirectPage.setRedirect(true);
                        redirectPage.getParameters().put('eventId',sEventId);
                        redirectPage.getParameters().put('pId',productId);
                        return redirectPage; 
                    }    
                    else
                    {
                        update prodList;
                        PageReference redirectPage = Page.CustomerProfileProductListingEdit;
                        redirectPage.setRedirect(true);
                        redirectPage.getParameters().put('eventId',sEventId);
                        redirectPage.getParameters().put('pId',productId);
                        return redirectPage; 
                    }
                }
                else
                {
                    PageReference redirectPage = Page.CustomerProfileProductListingEdit;
                    redirectPage.setRedirect(true);
                    redirectPage.getParameters().put('eventId',sEventId);
                    redirectPage.getParameters().put('pId',productId);
                    redirectPage.getParameters().put('check','true');
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
    
    public PageReference Cancel()
    {
        return null;
    }     
}