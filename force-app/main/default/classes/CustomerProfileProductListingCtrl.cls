/**
 * Created/Modified By: Girikon(Archit)
 * Created On:          08/30/2017
 * Description/Purpose: This class is used for the Product Listing tab on Customer Community
 *                      This class is used to add the proudct Listingas per the Event Edition, Contact and Expocad Booth.
 *                      This class is the controller for "CustomerProfileProductListing" VF pages
 * Methods:             saveProductList
 * Test Class:          CustomerProfileProductListingCtrl_Test 
 **/
 
public class CustomerProfileProductListingCtrl
{
    public Exhibitor_Product_Listing__c oExhibitorProductList{get;set;}
    public Attachment Att{get;set;}
    public String sMessage{get;set;}
    public blob Photo{get;set;}
    public String fileName{get;set;}
    public boolean check{get;set;}
    public Boolean found {get;set;}
    //public String BrandingColor{get;set;}
    public String ButtonBackgroundColor{get;set;}
    public String ButtonTextColor{get;set;}
    
     // Constructer that will grab the URL parameters
    public CustomerProfileProductListingCtrl()
    {    
        String eventId = ApexPages.currentPage().getParameters().get('eventId').escapeHtml4();
        if(eventId != null)
        {
            List<Event_Settings__c> eventSet = [Select Id, Name, Button_Text_Color__c,Button_colors__c, Branding_Color__c,Event_Edition__c, Event_Edition__r.Event_Code__c from Event_Settings__c where Event_Edition__c =: eventId];
            if(!eventSet.IsEmpty())
            {
                //BrandingColor = eventSet[0].Branding_Color__c;
                //Added on enhancement project
                ButtonBackgroundColor= eventSet[0].Button_colors__c;
                ButtonTextColor = eventSet[0].Button_Text_Color__c;
            }
        }    
        oExhibitorProductList = new Exhibitor_Product_Listing__c();
        String checkRender= ApexPages.currentPage().getParameters().get('checkRender');
                   
        if(String.isNotBlank(checkRender)&&checkRender=='true')
        {
                check=true;
                ApexPages.Message myMsg1 = new ApexPages.Message(ApexPages.Severity.Info,'Product listing has been added. Please close this window');
                ApexPages.addMessage(myMsg1);
        }
        if (String.isNotBlank(checkRender)&&checkRender=='false')
        {
            check=false;
            ApexPages.Message myMsg1 = new ApexPages.Message(ApexPages.Severity.WARNING,'ERROR ! Please check the uploaded document');
            ApexPages.addMessage(myMsg1);
        }   
    }
     //function is used to save record and attach the new file to the records, also check the file type
    public PageReference saveProductList()
    {
        try
        {
            String sEventId = ApexPages.currentPage().getParameters().get('eventId').escapeHtml4();
            String expoId = ApexPages.currentPage().getParameters().get('expoId').escapeHtml4();
            String conId = ApexPages.currentPage().getParameters().get('conId').escapeHtml4();              
            String checkRender= ApexPages.currentPage().getParameters().get('checkRender').escapeHtml4();           
            found = false;
            List <AllowedImageTypes__c> acceptedImgType = [Select name from AllowedImageTypes__c];          
            Set<String> rejectedExtensions = new Set<String> {'.pdf'};
            
            if(String.isNotBlank(fileName) && Photo != null)
            {
                for(AllowedImageTypes__c s : acceptedImgType)
                {
                    //condition to check the file type
                    if(found = fileName.endsWith(s.name))
                    {    system.debug('Test1'+s);
                        found=true;
                        break;
                    }
                }
                if(!found)
                {
                    for(String s : rejectedExtensions )
                    {
                        
                        if(found = fileName.endsWith(s))
                        {   system.debug('Test2');
                            found = false;
                            break;
                        }
                    }
                }
                if(!found){ 
                    system.debug('found='+found);                
                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.WARNING,'Error!!! Please Check for the Document Type.'));
                    PageReference redirectPage = Page.CustomerProfileProductListing;
                    redirectPage.setRedirect(true);
                    redirectPage.getParameters().put('eventId',sEventId);
                    redirectPage.getParameters().put('found','false');
                    redirectPage.getParameters().put('checkRender','false');              
                    redirectPage.getParameters().put('expoId',expoId);
                    redirectPage.getParameters().put('conId',conId);
                    return redirectPage;
                } 
            }
            else
            {
                found=true;
            }
            if (found)       
            {                         
                if(oExhibitorProductList != null && String.isNotBlank(sEventId ))
                {
                    oExhibitorProductList.Contact__c = conId ;
                    oExhibitorProductList.Event_Edition__c = sEventId;
                    oExhibitorProductList.ExpocadBooth__c = expoId;
                    insert oExhibitorProductList;
                    System.debug('fileName : '+fileName+'Photo '+Photo );
                    if(String.isNotBlank(fileName) && Photo != null)
                    {
                        Attachment Att = new Attachment();
                        Att.Name = fileName;
                        Att.Body = Photo;
                        Att.parentId = oExhibitorProductList.id;
                        insert Att; 
                        
                        oExhibitorProductList.Image_Id__c = Att.id;
                        update oExhibitorProductList;   
                        
                        PageReference redirectPage = Page.CustomerProfileProductListing;
                        redirectPage.setRedirect(true);
                        redirectPage.getParameters().put('eventId',sEventId);
                        redirectPage.getParameters().put('checkRender','true');
                        return redirectPage;                            
                    }
                    else
                    {
                        
                        PageReference redirectPage = Page.CustomerProfileProductListing;
                        redirectPage.setRedirect(true);
                        redirectPage.getParameters().put('eventId',sEventId);
                        redirectPage.getParameters().put('checkRender','true');
                        return redirectPage;
                    }
                }
            }
        }
        catch(Exception e)
        {
           System.debug('Message:='+e.getMessage()+'**Line Number='+e.getLineNumber());
        }  
        return null;
    }    
}