/******************
 * Last Modified By : [Aishwarya BK-3759 27 Aug 2020]
******************/

global class btch_updateAssociation implements Database.Batchable<sObject>{
public list<Association_List__c> lstUpdateAssociationList;  
list<Account_Associations__c> objAccAscLst;
public boolean flag =false;
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT id,Association_ID__c,Member_Status__c,City__c,Country_Region__c,Exhibitor_Account_Name__c,State_Province__c,Expiry_Date__c FROM Association_List__c WHERE BatchProcessed__c = False' ; 
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Association_List__c> scope) {
        lstUpdateAssociationList = new list<Association_List__c>();
        set<string> associationListIds = new set<string>();
        set<string> accountStateCountrySet = new set<string>();
        for(Association_List__c objAssLst : scope){
            associationListIds.add(objAssLst.Association_ID__c);
            accountStateCountrySet.add(objAssLst.City__c+objAssLst.Country_Region__c);
        }
        
        list<Account_Associations__c> lstAccAsc = [select id,Member_Status__c,Expiry_Date__c,Association_ID__c from Account_Associations__c where Association_ID__c IN : associationListIds];
        for(integer i=0;i<lstAccAsc.size();i++){
            for(integer j=0;j<scope.size();j++){
                
                if(scope[j].Association_ID__c == lstAccAsc[i].Association_ID__c){
                    system.debug('----Id Matched----');
                    flag = true;
                    if(lstAccAsc[i].Member_Status__c != null && lstAccAsc[i].Member_Status__c !=''){
                        scope[j].Member_Status__c = lstAccAsc[i].Member_Status__c;
                    }
                    
                    if(lstAccAsc[i].Expiry_Date__c!=null){
                        scope[j].Expiry_Date__c = lstAccAsc[i].Expiry_Date__c;
                    }
                    
                    scope[j].BatchProcessed__c = true;
                    lstUpdateAssociationList.add(scope[j]);
                }
                else{
                    break;
                }
            }
            system.debug('-----Bol Flag if block-----'+flag);
        }
        
        if(!flag){
        system.debug('-----Bol Flag else block-----'+flag);
            list<Account> lstAccounts = [select id,Name,State_Country__c from Account where State_Country__c IN : accountStateCountrySet];
            objAccAscLst = new list<Account_Associations__c>();
            for(integer i=0;i<lstAccounts.size();i++){
                 for(integer j=0;j<scope.size();j++){
                 
                    system.debug('----Name Loop----');
                    
                    if(scope[j].Exhibitor_Account_Name__c+scope[j].City__c+scope[j].Country_Region__c == lstAccounts[i].Name+lstAccounts[i].State_Country__c){
                        system.debug('----Name Matched----');
                        Account_Associations__c objAccAsc = new Account_Associations__c();
                        objAccAsc.Account__c = lstAccounts[i].id;
                        
                        if(scope[j].Association_ID__c !=null && scope[j].Association_ID__c!=''){
                            objAccAsc.Association_ID__c = scope[j].Association_ID__c;
                        }
                        
                        if(scope[j].Member_Status__c!=''){
                            objAccAsc.Member_Status__c=scope[j].Member_Status__c;    
                        }
                        
                        if(scope[j].Expiry_Date__c !=null ){
                            objAccAsc.Expiry_Date__c=scope[j].Expiry_Date__c;  
                        }
                        objAccAscLst.add(objAccAsc);  
                        
                        scope[j].BatchProcessed__c = true;
                        lstUpdateAssociationList.add(scope[j]);
                    }
                    else{
                        break;
                    }
                }
            }
        }        
        try{
            if(lstUpdateAssociationList!=null && lstUpdateAssociationList.size()>0){
                update lstUpdateAssociationList;
            }
            
            system.debug('----objAccAscLst----'+objAccAscLst);
            if(objAccAscLst!=null && objAccAscLst.size()>0){
                insert objAccAscLst;
            }
        }
        catch(exception ex){
           //BK-3754          
                Utility.logsError(ex.getMessage(), ex.getCause(), ex.getLineNumber(), ex.getStackTraceString(), 'btch_updateAssociation' , 'Integration');
        }
    }
    
    global void finish(Database.BatchableContext BC) {
        // Added by Palla Kishore for the ticket Bk-19604
          system.debug('Batch job completed successfully');
    }
}