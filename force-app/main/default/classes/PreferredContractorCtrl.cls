/**
* Created By       :   Girikon(Rajeev)
* Created On       :   12/09/2019
* @description     :   This class selecting and deselecting multi picklist values for Preferred Contractor          
* Helper Class     :   
* Test Class       :   PreferredContractorCtrl_Test(85%)

* Modification log --
* Modified by      :   Girikon(Rajeev[BK-2354 Sep 13 2019], [Aishwarya BK-3037 Dec 11 2019])
**/
public class PreferredContractorCtrl {
    Public string searchText{get;set;}
    public boolean selSave{get;set;}
    Public List<String> leftSelected {get;set;}
    Public List<String> rightSelected {get;set;}
    public String EventId {get;set;}
    Set<String> leftValues = new Set<String>();
    Set<String> LeftNameValues = new Set<String>();
    Set<String> rightValues = new Set<String>();
    Set<String> mergedValues = new Set<String>();
    List<Account> acc = new List<Account>();
    List<Account> rghtAccs = new List<Account>();
    List<String> tempList = new List<String>();
    Event_Edition__c evntEdtn = new Event_Edition__c();
    Map<String,String> accVals = new Map<String,String>();
    public PreferredContractorCtrl(){
        EventId=apexpages.currentpage().getparameters().get('Id').escapeHtml4();
        system.debug('EventId'+EventId);
        leftSelected = new List<String>();
        rightSelected = new List<String>();
        acc =[select id , name from Account where Type = 'Stand Contractor' AND Inactive__c = False ORDER BY Name Asc LIMIT 999]; //BK-3037
        system.debug(acc);
        for(Account ac: acc){
           accVals.put(ac.id, ac.Name);
        }
        leftValues.addAll(accVals.keySet()); 
        evntEdtn=[select id , name , Preferred_Contractors__c from Event_Edition__c where id=:EventId];
        if(evntEdtn.Preferred_Contractors__c!=null){
            tempList.addall(evntEdtn.Preferred_Contractors__c.split(';'));
            if(leftValues.size()>0){
                for(String ac :leftValues){
                    for(String tp :tempList){
                        if(tp==ac){
                          leftValues.remove(tp);
                        }
                    }
                }   
            }
           system.debug('Cons......evntEdtn>>>>>leftValues'+leftValues.size());
           rightValues.addAll(tempList);   
        }
    }
    public PageReference getSelect(){
       
        rightSelected.clear();
        system.debug('leftSelected'+leftSelected);
        for(String s : leftSelected){
            leftValues.remove(s);
            rightValues.add(s);
        }
        selSave=true;
        save();
        return null;
    }
    
    public PageReference getDeselect(){    
        leftSelected.clear();
        system.debug('rightSelected_getDeselect'+rightSelected);
        for(String s : rightSelected){
            rightValues.remove(s);
            leftValues.add(s);
        }
        save();
        return null;
    }
    
    public List<SelectOption> getDeselectedValues(){
        List<SelectOption> options = new List<SelectOption>();
        List<String> objList = new List<String>();
        system.debug('getDeselectedValues_>>>>>leftValues'+leftValues.size());
        objList.addAll(leftValues);
        //objList.sort();
        for(String s : objList){
            options.add(new SelectOption(s,accVals.get(s).toLowerCase()));
        }
        return options;
    }
    
    public List<SelectOption> getSelectedValues(){
        List<SelectOption> options = new List<SelectOption>();
        List<String> objList = new List<String>();
        //acc =[select id , name from Account where ID in:rightValues AND Type = 'Stand Contractor' AND Inactive__c = False ORDER BY Name Asc];
        acc =[select id , name from Account where ID in:rightValues ORDER BY Name Asc];

        //objList.addAll(rightValues);
       //system.debug('objList--->>>'+objList);
        //objList.sort();
        for(integer i=0 ; i<acc.size(); i++){
            options.add(new SelectOption(acc[i].Id,acc[i].Name.toLowerCase()));
        }
        return options;
    }
    
    public void save() {
        system.debug('EventId'+EventId);
        Event_Edition__c Mem = new Event_Edition__c();
        system.debug('EventId'+EventId);
        Mem.id = EventId;
        String Interests = '';
        Boolean Start = true;
        if(!rightValues.isEmpty()) {           
            for(String Str : rightValues) {
                if(Start) {
                    Interests = Str;
                    Start = false;
                } else {               
                    Interests = Interests + ';' + Str;
                }
            }
        }
        system.debug('Interests'+Interests);
        Mem.Preferred_Contractors__c = Interests;
        update Mem;
    }
    
    public void cancel() {
        for(String s : rightValues){
            rightValues.remove(s);
            leftValues.add(s);
        }
        save(); 
    }
    
    public void srch()
    {
       if(searchText==''){
            leftValues.clear();
            rightValues.clear();
            leftValues.addAll(accVals.keySet());
            evntEdtn=[select id , name , Preferred_Contractors__c from Event_Edition__c where id=:EventId];
            if(evntEdtn.Preferred_Contractors__c!=null){
                tempList.addall(evntEdtn.Preferred_Contractors__c.split(';'));
                if(leftValues.size()>0){
                    for(String ac :leftValues){
                        for(String tp :tempList){
                            if(tp==ac){
                                leftValues.remove(tp);
                            }
                        }
                    }   
                }
                system.debug('Cons......evntEdtn>>>>>leftValues'+leftValues.size());
                rightValues.addAll(tempList);   
            }
        }
        else{
            LeftNameValues.addAll(leftValues);
            leftValues.clear();
            //system.debug(searchText);
            String Str = searchText.toLowerCase();
            system.debug('LeftNameValues'+LeftNameValues);
            if(LeftNameValues.size()>0){
                for(String ac :LeftNameValues){
                    if(accVals.get(ac).toLowerCase().contains(Str)){
                        system.debug('desiredValue'+accVals.get(ac));
                        leftValues.add(ac); 
                    }
                } 
            }
        }
    }
}