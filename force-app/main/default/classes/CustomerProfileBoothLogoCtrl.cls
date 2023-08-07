/**
 * Created/Modified By: Girikon(Amish)
 * Created On:          10/5/2017
 * Description/Purpose: his class is the controller for "CustomerProfileBoothLogo" VF pages
 *                      This class uplaod the new logo or update the existing logo at the booth level on customer profile
 * Methods:             saveBoothLogo, updateAttOnBoothRecord
 * Test Class:          CustomerProfileBoothLogoCtrl_Test
 * 
 * 
 **/

public class CustomerProfileBoothLogoCtrl
{
    public String fileName{get;set;}
    public String Title{get;set;}
    public boolean check{get;set;}
    public String imageURL{ get; set; }
    public transient blob Photo{get;set;}
    public Boolean found {get;set;}
    public ExpocadBooth__c  boothLst{ get; set; }
    public String ButtonBackgroundColor{get;set;}
    public String ButtonTextColor{get;set;}    
    
     // Constructer that will grab the URL parameters          
    public CustomerProfileBoothLogoCtrl()
    {
        String boothId = ApexPages.currentPage().getParameters().get('boothId').escapeHtml4();
        String scheck = ApexPages.currentPage().getParameters().get('check');
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
        if(String.isNotBlank(boothId))
        {
               boothLst= [select Id,Event_Code__c,Booth_Logo_Id__c  from  ExpocadBooth__c where id=:boothId limit 1];
                system.debug('boothLst='+boothLst);
               // Added for enhancement
                List<Event_Settings__c> eventSet = [Select Id, Name, Button_Text_Color__c,Button_colors__c, Branding_Color__c,Event_Edition__c, Event_Edition__r.Event_Code__c from Event_Settings__c where Event_Edition__r.Event_Code__c=: boothLst.Event_Code__c];
                if(!eventSet.IsEmpty())
                {
                    ButtonBackgroundColor= eventSet[0].Button_colors__c;
                    ButtonTextColor = eventSet[0].Button_Text_Color__c;
                }    
               if(String.isNotBlank(boothLst.Booth_Logo_Id__c))
               {             
                   imageURL='/servlet/servlet.FileDownload?file='+boothLst.Booth_Logo_Id__c  ;
               }
        }   
    }
    
    //This method  add the new booth logo at the booth level, also check the condition for the file type
    public PageReference saveBoothLogo()
    {
        try
        {
            String boothId = ApexPages.currentPage().getParameters().get('boothId').escapeHtml4();
            found = false;
            List <AllowedImageTypes__c> acceptedImgType = [Select name from AllowedImageTypes__c];
            Set<String> rejectedExtensions = new Set<String> {'.pdf'};
           
            for(AllowedImageTypes__c s : acceptedImgType)
            {
                //Condition that check the file type
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
                    //Condition that check the file type
                    if(found = fileName.endsWith(s))
                    {   system.debug('Test2');
                        found = false;
                        break;
                    }
                }
            }
            if(!found){ // after the whole loop it's still false?
                system.debug('found='+found);                
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.WARNING,'Please upload correct Image.'));
                PageReference redirectPage = Page.CustomerProfileBoothLogo;
                redirectPage.setRedirect(true);
                redirectPage.getParameters().put('boothId',boothId);
                redirectPage.getParameters().put('found','false');
                return redirectPage;
            }
            else
            {
                Boolean flagCheck=true;        
                boothLst= [select Id, Booth_Logo_Id__c  from ExpocadBooth__c  where id=:boothId limit 1];          
                System.debug('fileName : '+fileName+'Photo '+Photo );
                Attachment attch = new Attachment();
                    
                if(String.isNotBlank(fileName) && Photo != null)
                {
                    attch.Name = fileName;
                    attch.Body = Photo;
                    attch.parentId =boothId;
                    if(attch.body != null)
                    { 
                        System.debug(attch.body.size()+'size of file');        
                        if(attch.body.size()>250000)
                        {
                            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'File is not Uploaded:Max.File Size is 250KB')); 
                            check=true;
                            flagCheck=false;
                        }
                        else
                            flagCheck=true;
                    }
                    system.debug('====flagcheck= '+flagCheck);
                    if(flagCheck)
                    {
                        List<Attachment> attList = [Select Id from Attachment where parentId =:boothId ];
                            if(attList.size()>0)
                                delete attList;
                        insert attch;                         
                    }                    
                }
                
                if(flagCheck)
                { system.debug('In Flag====');
                    if(String.isNotBlank(fileName))
                    {    
                        system.debug('boothId== '+boothId);
                        system.debug('attid== '+attch.Id);
               
                        updateAttOnBoothRecord( boothId ,attch.id);
                        system.debug('In Flag====1');
                        PageReference redirectPage = Page.CustomerProfileBoothLogo;
                        redirectPage.setRedirect(true);
                        redirectPage.getParameters().put('boothId',boothId);
                        return redirectPage; 
                    }    
                    else
                    {
                       updateAttOnBoothRecord( boothId ,attch.id);
                        system.debug('In Flag====2');
                        PageReference redirectPage = Page.CustomerProfileBoothLogo;
                        redirectPage.setRedirect(true);
                        redirectPage.getParameters().put('boothId',boothId);
                        return redirectPage; 
                    }
                }
                else
                {
                    PageReference redirectPage = Page.CustomerProfileBoothLogo;
                    redirectPage.setRedirect(true);
                    redirectPage.getParameters().put('boothId',boothId);
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
    
    //Method that will update the field on ExpocatBooth( adding booth logo to the expocatbooth object)
    public void updateAttOnBoothRecord(String boothId, String attid)     
    { 
        system.debug('boothId== '+boothId);
        system.debug('attid== '+attid);
        if(string.isNotBlank(boothId) && string.isNotBlank(attid))
        {   
            ExpocadBooth__c booth = new ExpocadBooth__c();
            booth.Id=boothId;
            booth.Booth_Logo_Id__c =attid;
            update booth ;                
         }
    }
}