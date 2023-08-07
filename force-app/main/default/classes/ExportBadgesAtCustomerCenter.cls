/**
 * Created By: Girikon(Aishwarya)
 * Created On:          12/12/2018
 * modified On:         
 * Description/Purpose: This class will be called through skuid page - "CustomerBadges" for exporting the exhibitor badges
 * Test Class:          ExportBadgesAtCustomerCenter_Test (79%)
 * Last Modified By :   
**/

public class ExportBadgesAtCustomerCenter
{
    private limitWrapper[] thousandBlocks = new limitWrapper[]{};
    public string eveId;
    public string accId;
    public string exBoothId;
    private final integer listLimit;
    
    public ExportBadgesAtCustomerCenter()
    {
        listLimit = 1000;
        eveId = apexpages.currentpage().getparameters().get('id');
        accId = apexpages.currentpage().getparameters().get('accId');
        exBoothId = apexpages.currentpage().getparameters().get('exBoothId');
    }
    
    public limitWrapper[] getthousandBlocks()
    {
        thousandBlocks = new limitWrapper[]{};
        
        integer counter = 0;
        integer loopCount = 0;
        Exhibitor_Badge__c [] badgeList = new Exhibitor_Badge__c[]{};
        List<Exhibitor_Badge__c> listBadges = new List<Exhibitor_Badge__c>();
        if(eveid != null && accid != null && exBoothId != null){
            listBadges = [Select User_Name__r.Contact.Account.Name, Account_Name__c, Status__c, ExpocadBooth__r.Booth_Number__c, Exhibitor_Name__c, First_Name__c, Last_Name__c, Email__c, toLabel(Country__c), Country_Code__c, ExpoBoothNumber__c, State__c, City__c, Address__c, Nationality__c, Age_Bracket__c, Job_Title__c, Mobile_Number__c FROM Exhibitor_Badge__c Where Event_Edition__c =:eveId AND ExpocadBooth__r.Quote__r.SBQQ__Primary__c = True  AND ExpocadBooth__r.Quote__r.SBQQ__Account__c != null AND ExpocadBooth__r.Status__c = 'Rented' AND Account__c =:accId AND ExpocadBooth__c =:exBoothId LIMIT 25025];
        }
        else{
            listBadges = [Select User_Name__r.Contact.Account.Name, Account_Name__c, Status__c, ExpocadBooth__r.Booth_Number__c, Exhibitor_Name__c, First_Name__c, Last_Name__c, Email__c, 
                                 toLabel(Country__c), Country_Code__c, ExpoBoothNumber__c, State__c, City__c, Address__c, Nationality__c, Age_Bracket__c, Job_Title__c, Mobile_Number__c FROM Exhibitor_Badge__c Where Event_Edition__c =:eveId 
                                 AND ExpocadBooth__r.Quote__r.SBQQ__Primary__c = True  AND ExpocadBooth__r.Quote__r.SBQQ__Account__c != null 
                                 AND ExpocadBooth__r.Status__c = 'Rented' AND Account__c =:accId LIMIT 25025];
        }  
        for(Exhibitor_Badge__c c: listBadges)
        {
            if(counter < listLimit) {
                badgeList.add(c);
                counter++;
            }
            else {
                loopCount++;
                thousandBlocks.add(new limitWrapper(badgeList,loopCount));
                badgeList = new Exhibitor_Badge__c[]{};
                badgeList.add(c);
                counter = 0;
            }            
        }
        
        if(thousandBlocks.size() == 0) {
            loopCount++;
            thousandBlocks.add(new limitWrapper(badgeList,loopCount));
        }
        
        return thousandBlocks;
    }
    
    public class limitWrapper
    {
        public Exhibitor_Badge__c [] badges {get;set;}
        public integer blockNumber {get;set;}
        public limitWrapper(Exhibitor_Badge__c[] badge, integer i)
        {
            badges = badge;
            blockNumber = i;
        }
        
    }
}