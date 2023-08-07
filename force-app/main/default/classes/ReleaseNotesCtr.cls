/*Created By: Avinash Singh
Description/Purpose: This is class is used to provide the Release Notes data for ReleaseNotes Vf page. SN Ticket - CHG0046785
Test Class: ReleaseNotesCtr_Test (100%)
 */
public class ReleaseNotesCtr {
    
    public List<Release_Note__c> ReleaseNotes {get;set;}
    public Map<String,List<Release_Note__c>> releaseMap {get;set;} 

    public ReleaseNotesCtr(){
    
        //validateUserSession();
        ReleaseNotes = new List<Release_Note__c>();
        releaseMap  = new Map<String,List<Release_Note__c>>();
        ReleaseNotes =[Select Id,Name,Release_Name__c,Version_Number__c,Project__c,Notes__c  
                        from Release_Note__c where IsPublished__c=true order by Version_Number__c limit 1000];
                                                                        
        
        for(Release_Note__c rn : ReleaseNotes){                              
                                                                                        
            List<Release_Note__c> rnList = new List<Release_Note__c>();   
                                                                          
                if(releaseMap.containsKey(rn.Project__c)){             
                    rnList = releaseMap.get(rn.Project__c);            
                    rnList.add(rn);                                      
                    releaseMap.put(rn.Project__c,rnList);              
            }
            else{                                                             
                rnList.add(rn);                                              
                releaseMap.put(rn.Project__c,rnList);                  
            }
            
        }
        
        System.Debug(releaseMap);
       
    }
    
    public PageReference validateUserSession(){
        
        String strUserName = UserInfo.getFirstName() + ' '+ UserInfo.getLastName();
        System.Debug(strUserName);
    
        if(strUserName == 'Release Notes Site Guest User' || Test.isRunningTest()){
        
            PageReference loginPage = new PageReference('/login');
            loginPage.setRedirect(true);
            return loginPage;
        }
        else { return null; } 
    }
    
}