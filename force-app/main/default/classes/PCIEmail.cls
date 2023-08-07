/************************************************************************** 
** 
** Last Modified by Shay Spoonmore (shay.spoonmore@informausa.com)2012-02-14
Test Class: zTest_PCI
Last Modified By: [Aishwarya 31 Aug 2020 BK-6577]
**   
***************************************************************************/ 
public class PCIEmail {
    
    private static PCI_Scanner__c pciSettings = PCI_Scanner__c.getall().values()[0];
    private static Boolean orgIsSandbox = null;
    private static String orgInstanceName = null;
    
    private void PCIEmailOnLoad()
    {
        if(orgIsSandbox == null || orgInstanceName == null)
        {
            Organization org = [select Id, IsSandbox, InstanceName from Organization where Id=:UserInfo.getOrganizationId() limit 1];
            orgIsSandbox = org.IsSandbox;
            orgInstanceName = org.InstanceName;
            System.debug('####orgIsSandbox: '+ orgIsSandbox + '; orgInstanceName: ' + orgInstanceName);   
        }
    }
    
    class QueueSendEmails {
        String queueEmail;
        String queueDescription;
        //String objectCount;
        QueueSendEmails (String queueEmail,String queueDescription) //,String objectCount
        {
            this.queueEmail = queueEmail;
            this.queueDescription = queueDescription;
            //this.objectCount = objectCount;
        }
    } 
    
    
    public void GetPCIPending()
    { 
        PCIEmailOnLoad();
        
        //Get Queue Emails
        Set <String> setEmails= new Set <String>();
        Map <String,String> mapQueueEmails= new Map <String,String>();
        GetOwnershipQueue(setEmails , mapQueueEmails);
        
        //Get Mapped Groups
        Map <Id,String> mapQueue=GetMappedGroups();
        String queueDefaultName = mapQueue.get(pciSettings.Default_User_Queue__c);
        System.debug('Debug#######Default User Queue:' + queueDefaultName + '('+ pciSettings.Default_User_Queue__c +')');
        
        //Get Object to Queue Count
        Map <String,Integer> mapQueueCount= new Map <String,Integer>();
        Set <String> setObjects= new Set <String>();//Get list objects to use for mapKey
        GetMappedQueueCount(setObjects , mapQueueCount, mapQueue);
        
        
        //Build email for each person
        List<QueueSendEmails> queEmails = new List<QueueSendEmails>();
        
        //1.loop emails 
        
        List <string> listQueue = new List <string>(mapQueue.values());
        listQueue.sort();
        
        List <string> listObjects = new List <string>(setObjects);
        listObjects.sort();
        setObjects.clear();
        setObjects.addall(listObjects);
        
        Integer TotalCount = 0;
        String htmlDescription ='';
        
        for (String email :setEmails)
        {
            
            TotalCount = 0;
            htmlDescription = '<style type="text/css">.auto-style4 {font-family: Verdana, Geneva, Tahoma, sans-serif;font-size: medium;}' +
                '.auto-style5 {font-family: Verdana, Geneva, Tahoma, sans-serif;}</style><table border="0" cellpadding="0" cellspacing="0" >'; 
            //2. loop queues to to mapping to email
            
            for (Integer i=0;i<listQueue.Size();i++)   
            {
                
                
                if(mapQueueEmails.containsKey(email + '|' + (String)listQueue[i]) && (String)listQueue[i] != queueDefaultName ) 
                {
                    
                    /***
Integer totalQueueCount = 0;
System.debug('######DEBUG: email--'+ email + '|' + (String)listQueue[i]  );
//htmlDescription = htmlDescription + (String)listQueue[i];//Queue Name
//htmlDescription = htmlDescription + '<tr><td style="background: #AAAAFF; padding: 0in 0in 0in 0in" colspan="2" class="auto-style4">' +
//                                  '<strong>'+ listQueue[i] +'</strong></td></tr>';//Queue Name

String htmlObjects='';
//3. loop through Objects
for (String objectName :setObjects)
{
System.debug('######DEBUG: Objects--'+ objectName );
if(mapQueueCount.containsKey((String)listQueue[i]+ '|' + objectName))
{


//QueueDataCounts qdc = new QueueDataCounts();
//String objectName = mapQueueCount.get(listQueue[i]+ '|' + objectName).objectName;
Integer objectCount = mapQueueCount.get(listQueue[i]+ '|' + objectName);
totalQueueCount = totalQueueCount + objectCount;
TotalCount = TotalCount + totalQueueCount;
System.debug('######DEBUG: Object'+ objectName + '::' + objectCount.format() );
//htmlDescription = htmlDescription + objectName + ' ' + objectCount;//Queue Name
htmlObjects = htmlObjects + '<tr><td  style="background: #AAAAAA; padding: 0in 0in 0in 0in; width: 196px;" class="auto-style4">' +      
objectName + '</td><td  style="background: #AAAAAA; padding: 0in 0in 0in 0in; width: 257px;" class="auto-style4">' +        
objectCount + '</td></tr>';


}
}


//htmlDescription = htmlDescription + (String)listQueue[i] + ' ' + totalQueueCount;

htmlDescription = htmlDescription + '<tr><td style="background: #AAAAFF; padding: 0in 0in 0in 0in" colspan="2" class="auto-style4">' +
'<strong>'+ listQueue[i] +' Total('+ totalQueueCount +')</strong></td></tr>';//Queue Name


htmlDescription = htmlDescription + htmlObjects + '<tr ><td style="padding: 0in 0in 0in 0in" valign="top" colspan="2">&nbsp;</td></tr>';
//'<tr><td style="background: #AAAAFF; padding: 0in 0in 0in 0in; height: 18px;" colspan="2" class="auto-style4">'+
//'<strong>'+ listQueue[i] +' Total('+ totalQueueCount +')</strong></td></tr>'+

**/
                    
                    String[] htmlCount = BuildObjectCountHTML(listQueue[i], email, setObjects,mapQueueCount,TotalCount);
                    htmlDescription = htmlDescription + htmlCount[0] ;
                    TotalCount = integer.valueOf(htmlCount[1].replace(',',''));
                    
                    System.debug('######DEBUG: email--'+ email + '|' + (String)listQueue[i]);// + ':: TotalCount-' + totalQueueCount.format() );
                    System.debug('Debug#######htmlDescription' + htmlDescription);
                }
                else if(mapQueueEmails.containsKey(email + '|' + (String)listQueue[i]) && (String)listQueue[i] == queueDefaultName )
                {
                    //Send To Default Queue
                    for (Integer j=0;j<listQueue.Size();j++)   
                    {
                        
                        String[] htmlCount = BuildObjectCountHTML(listQueue[j], email, setObjects,mapQueueCount,TotalCount);
                        htmlDescription = htmlDescription + htmlCount[0] ;
                        System.debug('Debug#######htmlCount[1]' + htmlCount[1]);
                        
                        TotalCount = integer.valueOf(htmlCount[1].replace(',',''));
                        System.debug('Debug#######htmlDescription' + htmlDescription);
                    }
                    
                }
                
                
            } 
            //QueueSendEmails queEmail = new QueueSendEmails(queueEmail = email, queueDescription = htmlDescription);
            //queEmail.queueEmail = email;
            //queEmail.queueDescription = htmlDescription;
            htmlDescription = htmlDescription + '<tr><td style="background: #AAAAFF;padding: 0in 0in 0in 0in" colspan="2" class="auto-style5"><strong>' +
                'Grand Totals (' + TotalCount  + ')</strong></td></tr></table>';
            queEmails.add(new QueueSendEmails(email, htmlDescription));
        }
        
        
        //for (Integer i=0;i<queEmails.Size();i++)   
        //  {
        //      System.debug('######DEBUG: queueEmail--'+ queEmails[i].queueEmail + '|' + queEmails[i].queueDescription);
        //  }   
        
        
        if (queEmails.Size() > 0)
        {
            SendPCIEmails(queEmails);   
        }   
        
        
        
    }
    
    
    public String[] BuildObjectCountHTML(String listQueue, String email, set <String> setObjects, Map <String,Integer> mapQueueCount, Integer TotalCount)
    {
        
        String htmlDescription ='';
        
        Integer totalQueueCount = 0;
        System.debug('######DEBUG: email--'+ email + '|' + listQueue  );
        
        
        String htmlObjects='';
        //3. loop through Objects
        for (String objectName :setObjects)
        {
            System.debug('######DEBUG: Objects--'+ objectName );
            if(mapQueueCount.containsKey(listQueue + '|' + objectName))
            {
                
                
                //QueueDataCounts qdc = new QueueDataCounts();
                //String objectName = mapQueueCount.get(listQueue[i]+ '|' + objectName).objectName;
                Integer objectCount = mapQueueCount.get(listQueue + '|' + objectName);
                totalQueueCount = totalQueueCount + objectCount;
                
                System.debug('######DEBUG: Object'+ objectName + '::' + objectCount.format() );
                //htmlDescription = htmlDescription + objectName + ' ' + objectCount;//Queue Name
                htmlObjects = htmlObjects + '<tr><td  style="background: #AAAAAA; padding: 0in 0in 0in 0in; width: 196px;" class="auto-style4">' +      
                    objectName + '</td><td  style="background: #AAAAAA; padding: 0in 0in 0in 0in; width: 257px;" class="auto-style4">' +        
                    objectCount + '</td></tr>';
                
                
            }
        }
        
        TotalCount = TotalCount + totalQueueCount;
        //htmlDescription = htmlDescription + (String)listQueue[i] + ' ' + totalQueueCount;
        
        htmlDescription = htmlDescription + '<tr><td style="background: #AAAAFF; padding: 0in 0in 0in 0in" colspan="2" class="auto-style4">' +
            '<strong>'+ listQueue +' Total('+ totalQueueCount +')</strong></td></tr>';//Queue Name
        
        
        htmlDescription = htmlDescription + htmlObjects + '<tr><td style="padding: 0in 0in 0in 0in" valign="top" colspan="2">&nbsp;</td></tr>';
        //'<tr><td style="background: #AAAAFF; padding: 0in 0in 0in 0in; height: 18px;" colspan="2" class="auto-style4">'+
        //'<strong>'+ listQueue[i] +' Total('+ totalQueueCount +')</strong></td></tr>'+
        
        String[] htmlCount = new String[2];
        htmlCount[0] = htmlDescription;
        htmlCount[1] = TotalCount.format();
        
        return htmlCount;
    }
    
    public void SendPCIEmails(list<QueueSendEmails> queEmails)
    {
        if (queEmails.Size() > 0)
        {
            
            if ((Limits.getEmailInvocations() < Limits.getLimitEmailInvocations()))
            {              
                
                String orgEmail =pciSettings.Org_Wide_Email_Id__c;//'0D260000000TNCXCA4';
                String orgId =[select Id from Organization].Id;
                
                
                //Production Organization Id = '00D300000001NXOEA2'
                Boolean testing = false;
                If (orgIsSandbox)testing = true;
                
                System.debug('*****queEmails.Size( = ' + queEmails.Size());
                Messaging.SingleEmailMessage[] mail = new Messaging.SingleEmailMessage[queEmails.Size()];
                
                
                Integer currentRecord= 0;
                for (Integer i=0;i<queEmails.Size();i++)   
                {
                    System.debug('*****currentRecord = ' + currentRecord);
                    mail[currentRecord] = new Messaging.SingleEmailMessage();
                    String[] toAddresses;
                    String[] ccAddresses;
                    String emailInfo;
                    
                    if (testing)
                    {
                        
                        toAddresses = pciSettings.Error_Emails__c.split(';');
                        if(Test.isRunningTest())
                            toAddresses.add('for error testing');
                        
                        emailInfo = '(' + queEmails[i].queueEmail  + ')' + queEmails[i].queueDescription;
                        //errorEmail.setSubject('Error - Sending Inspection Copy Emails');
                    }
                    else
                    {
                        toAddresses = new String[] {queEmails[i].queueEmail}; //, 'Shay.Spoonmore@informaUSA.com' ,'SASInforma@gmail.com', 'Haley.McCarthy@informausa.com'
                            emailInfo = queEmails[i].queueDescription;
                        
                    }
                    //System.debug('******SendingLead.Owner.Email:' + SendingLead.Owner.Email);
                    //mail[currentRecord].setReplyTo('no-reply@informa.com');
                    //mail[currentRecord].setSenderDisplayName('Unread by Owner');
                    mail[currentRecord].setToAddresses(toAddresses);
                    mail[currentRecord].setCcAddresses(ccAddresses);
                    
                    mail[currentRecord].setSubject('Salesforce PCI Records Pending Review');
                    //mail[currentRecord].setPlainTextBody(emailInfo[1]);
                    mail[currentRecord].setHtmlBody(emailInfo);
                    //mail[currentRecord].setTemplateId(templateId);
                    //The Target object is a Contact and will not work with out one
                    //A Contact setup with the do_not_reply_textbookfeedback@taylorandfrancis.com email is the only way to make this work
                    //mail[currentRecord].setTargetObjectId(SendingLead.Id);//
                    //mail[currentRecord].setwhatId(SendingLead.Id);
                    mail[currentRecord].setEmailPriority('High');
                    mail[currentRecord].setSaveAsActivity(false);
                    mail[currentRecord].setBccSender(false);
                    mail[currentRecord].setUseSignature(false);
                    //CHANGE THE ORG WIDE EMAIL WITH PRODUCTION!!!
                    mail[currentRecord].setOrgWideEmailAddressId(orgEmail);
                    //**/
                    currentRecord = currentRecord + 1;
                }
                
                //= NEW Messaging.SendEmailResult();
                Messaging.SendEmailResult[] sendEmailResults = Messaging.sendEmail(mail, false);
                
                System.debug('******EMAIL RESULTS:' + sendEmailResults.size()); 
                
                //loop through email results                
                Integer errorCount = 0;
                String emailMessage = '';
                //for(Integer i = 0, j = 0; i < sendEmailResults.size(); i++)
                for(Integer i = 0; i < sendEmailResults.size(); i++)
                { 
                    if(!sendEmailResults[i].isSuccess())
                    {       
                        for (Messaging.Sendemailerror sendEmailError : sendEmailResults[i].getErrors()) 
                        {
                            
                            System.debug('******Error Message:' + sendEmailError.Message);
                            
                            //Build Email Error Message
                            emailMessage = emailMessage + sendEmailError.Message + '\n\r';
                            
                            errorCount++;// keep count of how many records errored
                        }
                        
                    } 
                }
                
                if (errorCount > 0 )
                {
                    //System.debug('##### Error Count:' + errorCount); 
                    //System.debug('##### Update Forum Error Records:' + updateICopyError.size()); 'getEmailInvocations:' + Limits.getEmailInvocations + 
                    String countMessage = 'getEmailInvocations:' + Limits.getEmailInvocations() + '\n\rError Count:' + errorCount ;
                    System.debug('##### ' + countMessage); 
                    
                    SendErrorEmail(pciSettings.Error_Emails__c,'Error - Sending PCI Alerts',countMessage + 'Error sending...\n\r' + emailMessage);
                    System.debug('#### Sent Error Message:' + emailMessage);
                }
            }
        }
    }
    
    //@@Avi : 
    Public static void SendErrorEmail(string emailTo,String emailSubject, String emailMessage )
    {
        
        if (Limits.getEmailInvocations() < Limits.getLimitEmailInvocations())
        {
            //Send Error Email
            Messaging.SingleEmailMessage errorEmail = new Messaging.SingleEmailMessage();
            //Build Email Error Message
            errorEmail = new Messaging.SingleEmailMessage();
            String[] toAddresses = emailTo.split(';',-1);
            errorEmail.setToAddresses(toAddresses);
            errorEmail.setSubject(emailSubject); 
            errorEmail.setBccSender(false);
            errorEmail.setEmailPriority('High');
            errorEmail.setUseSignature(false);
            errorEmail.setPlainTextBody(emailMessage);
            
            
            Messaging.SendEmailResult[] sendEmailErrorResults = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { errorEmail });
        }
    }
    
    public static map <Id,string> GetMappedGroups()
    {
        List<Group> pciGroups = [Select g.Id, g.Name from Group g where g.Type = 'Queue' and g.Name LIKE '%PCI CCN'];
        Map <Id,string> mapQueue= new Map <Id,string>();
        for (Group pciGroup : pciGroups)
        {
            String[] bu = pciGroup.Name.split('-', 2);
            //System.debug('######DEBUG: pciGroup'+ pciGroup.Name +':' + bu[0]);
            //System.debug('######DEBUG: MATCH Queue'+ pciGroup.Name +':' + mapBusinessOwners(bu[0]));
            mapQueue.put(pciGroup.Id  , pciGroup.Name);
        }
        
        return mapQueue;
    }
    
    public static void GetMappedQueueCount(Set <string> setObjects , Map <string,integer> mapQueueCount,map <Id,string>mapQueue)
    {
        AggregateResult[] cnnPennding= [Select   p.OwnerId, p.Object_Name__c, count(p.Id)PendingCount From PCI_Credit_Card_Numbers__c p Where  p.Record_Action__c IN ('Pending', 'Positive') 
                                        GROUP BY p.Object_Name__c, p.OwnerId ];
        
        Map<String, Schema.SObjectType> globalSchemaDesc = Schema.getGlobalDescribe();
        //Set<String> objNames = globalSchemaDesc.keySet();
        //System.debug('How many objects do we see? ' + globalSchemaDesc.size() + globalSchemaDesc.get('Product2').getDescribe().getLabel());
        
        for (integer i=0;i<cnnPennding.Size();i++)   
        {       
            String objectLabel = (string)cnnPennding[i].get('Object_Name__c');
            if (objectLabel != null && !objectLabel.endsWith('.PixAlert'))
            {
                objectLabel = globalSchemaDesc.get((string)cnnPennding[i].get('Object_Name__c')).getDescribe().getLabel();
            }
            
            if (objectLabel == null)//Use object name if ever null
            {
                objectLabel = (string)cnnPennding[i].get('Object_Name__c');
            }
            String queueName =  mapQueue.get((string) cnnPennding[i].get('OwnerId'));
            //System.debug('######DEBUG: '+ objectLabel + '--' + cnnPennding[i].get('Object_Name__c') + ' :: OwnerId' + cnnPennding[i].get('OwnerId') + '::' + queueName + ' :: Count:' + cnnPennding[i].get('PendingCount'));
            Integer pendingCount = (Integer)cnnPennding[i].get('PendingCount');
            setObjects.add(objectLabel);
            mapQueueCount.put(queueName + '|' + objectLabel,pendingCount);//new QueueDataCounts(queueName, objectLabel,pendingCount.format())
        } 
    }
    
    public static void GetOwnershipQueue(Set <string> setEmails  ,  Map <string,string> mapQueueEmails)
    {
        //Set <String> 
        //setEmails= new Set <String>(); 
        //Map <String,String> 
        //mapQueueEmails= new Map <String,String>();
        AggregateResult[] queueEmail = [Select  p.Business_Queue__c, p.PCI_Contact_Email__c from PCI_Business_Ownership__c p GROUP BY p.Business_Queue__c, p.PCI_Contact_Email__c order by p.Business_Queue__c];
        for (Integer i=0;i<queueEmail.Size();i++)   
        {
            
            //System.debug('######DEBUG: Queue' + queueEmail[i].get('Business_Queue__c') + ' :: Email:' + queueEmail[i].get('PCI_Contact_Email__c'));
            String contactEmail = (String)queueEmail[i].get('PCI_Contact_Email__c');
            
            if (contactEmail != null)
            {
                String[] queEmails = contactEmail.replace(',',';').split(';');
                
                for (Integer j=0;j<queEmails.Size();j++)   
                {
                    //setEmailQueues.add(queEmails[j].trim() + '|' + (String)queueEmail[i].get('Business_Queue__c'));
                    //mapQueueEmails.put((String)queueEmail[i].get('Business_Queue__c'),queEmails[j].trim());
                    setEmails.add(queEmails[j].trim());
                    mapQueueEmails.put((String)queEmails[j].trim() + '|' + (String)queueEmail[i].get('Business_Queue__c'), (String)queueEmail[i].get('Business_Queue__c'));
                    
                } 
            }
            
        }
    }
}