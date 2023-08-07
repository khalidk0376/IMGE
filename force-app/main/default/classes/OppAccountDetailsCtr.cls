/**
 * Created/Modified By: Girikon(Amish,Bappi, Aishwarya, Archit)
 * Created On:          9/6/2017
 * Modified By:    Girikon(Amish) - CCEN 274, Mahesh-CCEN-420, Sunil-CCEN-444, Prashant-CCEN-416
 * Modified On:    08/29/20188,11/05/2018,11/22/2018
 * Description/Purpose: This class is used for the Financial and Billing tab on Customer Community
 *                      All the functionality for the Account and Billing section is perforrmed in this class. such as Invoices, Payments, Comtract and Summary.
 * Methods:             getOppAccountDetails, getBoothItems, totalBoothSummaryDisplay, getBoothMessage, getInvoiceRecord,getInvoiceDetails, getInvoiceAndProductDetail, 
 *                      getContractDetail, getOppProducts, getPaymentRecord, getPaymentDetailgetPaymentDetailForInvoice, isShowOnePaymentDetail, isShowOnePaymentDetailForInvoice, 
 *                      processPayment,multipleInvoicePayment, getOppAccountDetailsInvoice, changeDateFormatInvoice, getInvoiceRecordDetails, getInvoiceRecordDetailsForPastInv, 
 *                      downloadInvoicePDF
 * Test Class:          OppAccountDetailsCtr_Test
**/
public class OppAccountDetailsCtr
    {
        public string BoothItemId{get;set;}
        public string toReturn{get;set;}
        public Boolean evnSetting{get;set;}
        public static String eventId{get;set;}
        private String sortDirection = 'ASC';
        private String sortExp = 'name';
        private String sortExpContract = 'ContractNumber';
        private String sortExpPayment = 'blng__Transaction__r.Name';
        public String sSelectcontractId{get;set;}
        public List<SelectOption> PlicklistContract{get;set;}
        public List<SelectOption> PlicklistDueDate{get;set;}
        public List<SelectOption> PlicklistStatus{get;set;}
        public String sSelPlicklistStatusId{get;set;}
        public Decimal TotalAmountInvoice{get;set;}
        public Boolean TotalAmountInvoiceCheck{get;set;}    
        Public Decimal RemTotalAmount{get; set;}
        public List<PaymentSchedule> lstPaymentSchedule{get;set;}
        public String sCurrencySymbol{get;set;}
        public Map<Integer,String> mapPaymentSchedule {get;set;}
        public Boolean isInvoiceDetailShow{get;set;}
        public Boolean isContractDetailShow{get;set;}
        public Boolean isPaymentDetailShow{get;set;}
        public Boolean isPaymentDetailShowForInvoice{get;set;}
        public Boolean isInvoiceDetailShowForInvoice{get;set;}
        public Boolean isPaymentDetailShowForPayment{get;set;}
        public Boolean isInvoiceDetailShowForPayment{get;set;}
        public String sInvoiceId{get;set;}
        public String sSelectDueDate{get;set;}
        private integer counter=0;  //keeps track of the offset
        private integer list_size=20; //sets the page size or number of rows
        public integer total_size=1; //used to show user the total size of the list
        public String sEventName{get;set;}
        public String contactId;
        public String eventCode{get;set;}
        
        public string dottedLine{get;set;}
        Map<String,String> mapPickListDueDate{get;set;}
        public List<String> lstPickListDueDate{get;set;}
        public Map<String,String> mapContract{get;set;}
        public List<String> lstContract{get;set;}
        public List<String> lstPlicklistStatus{get;set;}
        public String BrandingColor{get;set;}
        public static String displayBoothData{get;set;}
        public static Set<Id> setBoothIds;
        public static Boolean checkIfAllBooth{get;set;}
        public static boolean firstLoad = false;
        public string sessionId{get;set;}
        public string serverURL{get;set;}
        public boolean isAccountHome {get;set;} 
        public Event_Settings__c eventSet{get;set;}
        public List<Event_Settings__c> lstEventSetting {get;set;}
        public String ButtonColor{get;set;}
        public String ButtonTextColor{get;set;}
        //Using installation variable and creating some record event and invoice.
        public OppAccountDetailsCtr()
        {
            eventId = ApexPages.currentPage().getParameters().get('eventId').escapeHtml4();
            serverURL = ApexPages.currentPage().getParameters().get('serverURL').escapeHtml4();
            checkIfAllBooth = false;
            evnSetting = false;
            try
            {
                sessionId = UserInfo.getSessionId();
                sSelectcontractId ='Contract';
                TotalAmountInvoice = 0.00;
                RemTotalAmount=0.00;
                sCurrencySymbol ='USD';
                dottedLine='---';
                isInvoiceDetailShow = false;
                isContractDetailShow = false;
                isPaymentDetailShow =false;
                isPaymentDetailShowForInvoice=true;
                isInvoiceDetailShowForInvoice=true;
                isAccountHome = true;
                lstPlicklistStatus = new List<String>();
                isPaymentDetailShowForPayment=true;
                isInvoiceDetailShowForPayment=true;
                mapPaymentSchedule  = new Map<Integer,String>();
                plicklistContract = new List<SelectOption>();
                PlicklistDueDate = new List<SelectOption>();
                PlicklistStatus = new List<SelectOption>();
                List<blng__Invoice__c> lstInvoice = getInvoiceRecord();
                mapContract = new Map<String,String>();
                Map<String,String> mapStatus = new Map<String,String>();
                sSelPlicklistStatusId ='Status';
                lstPaymentSchedule = new List<PaymentSchedule>();
                mapPickListDueDate = new Map<String,String>();
                mapContract.put('Contract','Contract');
                plicklistContract.add(new SelectOption('Contract','Contract'));
                PlicklistStatus.add(new SelectOption('Status','Status'));
                PlicklistDueDate.add(new SelectOption('Due Date','Due Date'));
                lstPickListDueDate = new List<String>();
                lstPickListDueDate.add('Due Date');
                mapPickListDueDate.put('Due Date','Due Date');
                sSelectDueDate='Due Date';
                lstContract = new List<String>(); 
                lstContract.add('Contract');
                lstPlicklistStatus.add('Status');
                if(eventId != null)
                {
                    eventSet = [Select Id, Name, Branding_Color__c,Map_it_button_visibility__c, Button_colors__c, Button_Text_Color__c, Booth_Name__c,Booth_size__c,Classification__c,Exhibiting_As__c,Open_Sides__c,Event_Edition__c, Event_Edition__r.Event_Code__c from Event_Settings__c where Event_Edition__c =: eventId];
                    BrandingColor = eventSet.Branding_Color__c; 
                    ButtonColor = eventSet.Button_colors__c; 
                    ButtonTextColor = eventSet.Button_Text_Color__c;
                    evnSetting = eventSet.Map_it_button_visibility__c;
                    //add Paynow disable functionality from Event Setting object
                    lstEventSetting = [SELECT Id, Is_Disable_E_Commerce__c FROM Event_Settings__c WHERE Event_Edition__c = :eventId AND Is_Disable_E_Commerce__c=true];
                }
                if(lstInvoice != null && lstInvoice.size()>0)
                {                   
                    for(blng__Invoice__c invoice :lstInvoice)
                    {
                        if(invoice.blng__Order__r.ContractId != null && !mapContract.containsKey(invoice.blng__Order__r.Contract.ContractNumber+'-' +invoice.blng__Order__r.Contract.Name)){
                            plicklistContract.add(new SelectOption(invoice.blng__Order__r.ContractId,invoice.blng__Order__r.Contract.ContractNumber +(invoice.blng__Order__r.Contract.Name != null? '-' +invoice.blng__Order__r.Contract.Name:'')));
                            mapContract.put(invoice.blng__Order__r.Contract.ContractNumber+'-' +invoice.blng__Order__r.Contract.Name,invoice.blng__Order__r.ContractId);
                            lstContract.add(invoice.blng__Order__r.Contract.ContractNumber+'-' +invoice.blng__Order__r.Contract.Name);
                        }
                        if(invoice.blng__PaymentStatus__c != null && !mapStatus.containsKey(invoice.blng__PaymentStatus__c))
                        {
                            PlicklistStatus.add(new SelectOption(invoice.blng__PaymentStatus__c,invoice.blng__PaymentStatus__c));
                            mapStatus.put(invoice.blng__PaymentStatus__c,invoice.blng__PaymentStatus__c);
                            lstPlicklistStatus.add(invoice.blng__PaymentStatus__c);
                        }
                        if(invoice.blng__Subtotal__c != null) { TotalAmountInvoice += invoice.blng__Subtotal__c;
                        }
                        if(invoice.blng__PaymentStatus__c!='Paid'){RemTotalAmount+=invoice.blng__Subtotal__c;
                        }
                        if(invoice.blng__DueDate__c != null && !mapPickListDueDate.containsKey(convertDate(invoice.blng__DueDate__c,true))) {
                            PlicklistDueDate.add(new SelectOption(convertDate(invoice.blng__DueDate__c,false),convertDate(invoice.blng__DueDate__c,true)));
                            lstPickListDueDate.add(convertDate(invoice.blng__DueDate__c,true));
                            mapPickListDueDate.put(convertDate(invoice.blng__DueDate__c,true),convertDate(invoice.blng__DueDate__c,false));
                        }
                    }   
                }
                if(TotalAmountInvoice!=0.00) {
                   TotalAmountInvoiceCheck=true;
                   TotalAmountInvoice = TotalAmountInvoice.setScale(2, RoundingMode.HALF_UP);         
                }
                if(String.isNotBlank(eventId))
                {
                    list <Event_Edition__c> eventLst = new list<Event_Edition__c>();
                    eventLst= [Select Name ,Event_code__c,EventCurrency__r.Name,Payment_Schedule__c,X50_Cutoff_Date__c,Cutoff_Date_1__c,Cutoff_Date_2__c,CutoffDate_3__c from Event_Edition__c where Id=:eventId ];
                    if(eventLst!=null && eventLst.size()>0)
                    {
                        for(Event_Edition__c eventObj : eventLst)
                        {
                            eventCode = eventObj.Event_code__c;
                            if(eventObj.EventCurrency__c != null){
                                sCurrencySymbol=eventObj.EventCurrency__r.Name;
                                sEventName = eventObj.Name;
                            }
                            if(eventObj.Payment_Schedule__c != null)
                            {
                                Integer icountPay = 1;
                                mapPaymentSchedule.put(1,'0');
                                mapPaymentSchedule.put(2,'0');
                                mapPaymentSchedule.put(3,'0');
                                mapPaymentSchedule.put(4,'0');
                                for(String Paymenet : eventObj.Payment_Schedule__c.split('-'))
                                {
                                    PaymentSchedule paySchObj= new PaymentSchedule();
                                    paySchObj.sPaymentScheduleItem = Paymenet; 
                                    mapPaymentSchedule.put(icountPay,Paymenet);
                                    if(icountPay ==1) { paySchObj.CutoffDate=  eventObj.X50_Cutoff_Date__c;
                                    }
                                    else if(icountPay ==2){paySchObj.CutoffDate=  eventObj.Cutoff_Date_1__c;
                                    }
                                    else if(icountPay ==3) {paySchObj.CutoffDate=  eventObj.Cutoff_Date_2__c;
                                    }
                                    else if(icountPay ==4){ paySchObj.CutoffDate=  eventObj.CutoffDate_3__c ;
                                    }
                                    lstPaymentSchedule.add(paySchObj);  
                                    icountPay ++; 
                                }
                            }
                           if(eventObj.Payment_Schedule__c == null)
                           {
                               mapPaymentSchedule.put(1,'100');
                               PaymentSchedule paySchObj= new PaymentSchedule();
                               paySchObj.sPaymentScheduleItem = '100';
                               paySchObj.CutoffDate= null; 
                               lstPaymentSchedule.add(paySchObj);                                 
                           }                           
                        }
                    }  
                }
            }
            catch(Exception e){System.debug('Error :--' +e.getMessage()+' Line number >>' +e.getLineNumber());
            }
        } 
        //create Booth record behalf of event and account.   
        public static accountDetailsWrapper getOppAccountDetails()
        {
            String accountId = ApexPages.currentPage().getParameters().get('accountId').escapeHtml4();
            String eventId = ApexPages.currentPage().getParameters().get('eventId').escapeHtml4();
            Date currentDate =  date.today();
            accountDetailsWrapper acctDetail = new accountDetailsWrapper();
            acctDetail.amount =0.0;
            acctDetail.remainingAmount =0.0;
            set<string> quoteIds = new set<string>();
            if(string.isNotBlank(accountId) && string.isNotBlank(eventId))
            {
                List<opportunity> opp = [select id,Name,Account.Name,Amount,Paid_Amount__c,Payment_Status__c,SBQQ__PrimaryQuote__c,EventEdition__r.Cutoff_Date_1__c,
                                        EventEdition__r.Cutoff_Date_2__c,EventEdition__r.Cutoff_Date_3__c,(select id,Event_Product_Type__c,Product2.name from OpportunityLineItems)
                                         from opportunity where AccountId=:accountId AND
                                          EventEdition__c=:eventId AND (StageName='Closed Won' OR StageName='Closed Booked') order by createdDate];
                List<boothOpptyWrapper> listBoothOpptyWrapper = new List<boothOpptyWrapper>();
                Decimal paidAmount =0.0;
                if(opp!=null && opp.size()>0)
                {
                    for(opportunity oppty: opp){
						acctDetail.account=oppty.Account.Name;
                        if(oppty.SBQQ__PrimaryQuote__c!=null){ quoteIds.add(oppty.SBQQ__PrimaryQuote__c);
                        }                       
                        boothOpptyWrapper bow = new boothOpptyWrapper();
                        bow.opptyId = oppty.Id;
                        listBoothOpptyWrapper.add(bow);
                        if(oppty.Paid_Amount__c != null){ paidAmount += oppty.Paid_Amount__c;
                        }
                        if(oppty.Amount !=null){acctDetail.amount +=oppty.Amount;
                        }
                        if(oppty.Payment_Status__c!='Paid' && oppty.EventEdition__r.Cutoff_Date_1__c != null && oppty.EventEdition__r.Cutoff_Date_1__c > currentDate)
                        {  acctDetail.dueDate = changeDateFormat(oppty.EventEdition__r.Cutoff_Date_1__c);
                        }
                        else if(oppty.Payment_Status__c!='Paid' && oppty.EventEdition__r.Cutoff_Date_1__c != null && oppty.EventEdition__r.Cutoff_Date_2__c > currentDate)
                        {  acctDetail.dueDate = changeDateFormat(oppty.EventEdition__r.Cutoff_Date_2__c);
                        }
                        else if(oppty.Payment_Status__c!='Paid' && oppty.EventEdition__r.Cutoff_Date_1__c != null && oppty.EventEdition__r.Cutoff_Date_3__c > currentDate)
                        {   acctDetail.dueDate = changeDateFormat(oppty.EventEdition__r.Cutoff_Date_3__c);
                        }
                        else{acctDetail.dueDate = null;
                        }
                        if(oppty.OpportunityLineItems.size()>0 && oppty.OpportunityLineItems!=null)
                        {
                            list<OLIWrapper> lstproductWrapper = new List<OLIWrapper>();
                            for(OpportunityLineItem product : oppty.OpportunityLineItems)
                            {
                                OLIWrapper productW = new OLIWrapper();
                                productW.productName = product.Product2.name;
                                if(product.Event_Product_Type__c== null){ productW.productType = '';
                                }
                                productW.productType = product.Event_Product_Type__c;
                                lstproductWrapper.add(productW);
                            }
                            acctDetail.lstproduct = lstproductWrapper;
                        }
                      
                    }
                    acctDetail.remainingAmount = acctDetail.amount -paidAmount;
              }
                if(opp!=null && opp.size()>0)
                {
                  //Added condition of Related_Opportunity__c and Related_Opportunity__r.User_Type__r.Name for [CCEN-416]
                  List<ExpocadBooth__c> expoBooths = [Select Id, Booth_Number__c, Area_Number__c, Unit_Type__c, Opportunity__c, Opportunity__r.Name, Opportunity__r.createdDate, Display_Name__c, Status__c From  
                                                             ExpocadBooth__c where status__c='Rented' AND quote__c IN:quoteIds AND (Related_Opportunity__c  = null OR Related_Opportunity__r.User_Type__r.Name = 'Exhibitor')  order by Opportunity__r.createdDate];
                  List<boothDetailsWrapper> expoBoothWrpr =new List<boothDetailsWrapper>();
                 if(expoBooths !=null && expoBooths.size()>0)              
                  {
                      for(ExpocadBooth__c ecb: expoBooths)
                      {
                          boothDetailsWrapper bdw=new boothDetailsWrapper();
                          bdw.boothName=ecb.Booth_Number__c;
                          bdw.boothArea = string.valueOf(ecb.Area_Number__c);
                          bdw.unitType=ecb.Unit_Type__c;
                          bdw.boothId=ecb.Id;
                          bdw.oppty = ecb.Opportunity__r.Name;
                          bdw.displayName = ecb.Display_Name__c;
                          bdw.boothStatus = ecb.Status__c;
                          expoBoothWrpr.add(bdw);
                       }
                  }
                  acctDetail.boothDetails=expoBoothWrpr;
                  acctDetail.boothOppty = listBoothOpptyWrapper;
                  }
            }return acctDetail ;
      }
       //created Date format in this function.
       public static String changeDateFormat(Date d)
       {
           String dt = DateTime.newInstance(d.year(),d.month(),d.day()).format('d/MM/YYYY');
           return dt;
       }
       //Created picklist for Booth behalf event base and current user.
       public List<SelectOption> getBoothItems(){
           setBoothIds = new set<Id>();
           List<SelectOption> options = new List<SelectOption>();
           options.add(new SelectOption('All','All')); // Commented as per ticket CCEN-95
           accountDetailsWrapper accDetails= getOppAccountDetails();
           if(accDetails != null)
           {
               if(accDetails.boothDetails!=null)
               {
                   for(boothDetailsWrapper boothDetail :accDetails.boothDetails)
                   {   // Added Display Name for CCEN-420 
                       if(!String.isBlank(boothDetail.displayName))//!=null && boothDetail.displayName!='')
                       {
                       options.add(new SelectOption(boothDetail.boothId,boothDetail.displayName+' - '+boothDetail.boothName +' ('+boothDetail.boothArea +' '+boothDetail.unitType+')'));
                       setBoothIds.add(boothDetail.boothId);
                       }
                       else {
                       options.add(new SelectOption(boothDetail.boothId,accDetails.account+' '+boothDetail.boothName +' ('+boothDetail.boothArea +' '+boothDetail.unitType+')'));
                       setBoothIds.add(boothDetail.boothId);
                       }
                   }             
             }
           }
           if(firstLoad == false){totalBoothSummaryDisplay();
           } return options;
       }       
       //Created picklist for Booth behalf event base and current user and for the ImportExhibitor button the Badges as there is no need of picklist value - "All Booth"
       public List<SelectOption> getBoothItems2(){
           setBoothIds = new set<Id>();
           List<SelectOption> options = new List<SelectOption>();
           accountDetailsWrapper accDetails= getOppAccountDetails();
           if(accDetails != null)
           {
               if(accDetails.boothDetails!=null)
               {
                   for(boothDetailsWrapper boothDetail :accDetails.boothDetails)
                   {
                        // Added Display Name for CCEN-420 
                       if(!String.isBlank(boothDetail.displayName))//!=null && boothDetail.displayName!='')
                       {
                       options.add(new SelectOption(boothDetail.boothId,boothDetail.displayName+' - '+boothDetail.boothName +' ('+boothDetail.boothArea +' '+boothDetail.unitType+')'));
                       setBoothIds.add(boothDetail.boothId);
                       }
                       else {
                       options.add(new SelectOption(boothDetail.boothId,accDetails.account+' '+boothDetail.boothName +' ('+boothDetail.boothArea +' '+boothDetail.unitType+')'));
                       setBoothIds.add(boothDetail.boothId);
                       }
                   }
             }
           }
           if(firstLoad == false){totalBoothSummaryDisplay();
           }return options;
       }       
       // method for showing totalBoothSummary for picklist value - All Booths
       // CCEN-444
       public static string totalBoothSummaryDisplay(){
           List<ExpocadBooth__c> listExpocadBooth = new List<ExpocadBooth__c>();
           Decimal totalBadgesUsed = 0;
           Decimal totalArea = 0;
           Decimal totalBadgesAllotment = 0;
           Decimal totalBadgesRemaining = 0;
           String initialAllBoothDisplay ='';
           string eventCode;
           Decimal badgeLimitAll = 0;
           //String accountId = ApexPages.currentPage().getParameters().get('accountId');
           if(setBoothIds.size()>0 && firstLoad == false){
            listExpocadBooth = [Select Area_Number__c,Badge_Limit__c, CountBadges__c, Event_Code__c from ExpocadBooth__c where status__c='Rented' AND Id IN:setBoothIds];
            list<decimal> listAreas = new list<decimal>();
            for(ExpocadBooth__c booth :listExpocadBooth){
                totalBadgesUsed = totalBadgesUsed + booth.CountBadges__c;
                if(booth.Area_Number__c != null)
                {
                    totalArea = totalArea + booth.Area_Number__c;
                    listAreas.add(booth.Area_Number__c);
                    //badgeLimitAll = badgeLimitAll + booth.Badge_Limit__c;
                    if(booth.Badge_Limit__c == null)
                        booth.Badge_Limit__c = 0;
                    badgeLimitAll = badgeLimitAll + booth.Badge_Limit__c;
                }
                if(string.isNotBlank(booth.Event_Code__c)){eventCode = booth.Event_Code__c;
                }
            }
            decimal totalBadgesAllowed = 0;
            List<Booth_Size_Badge_Limit__c> lstBoothSizeBadgeLimit1 = new List<Booth_Size_Badge_Limit__c>();
            lstBoothSizeBadgeLimit1 =[Select Badges_Allowed__c, Booth_Size_From__c, Booth_Size_To__c from Booth_Size_Badge_Limit__c where Event_Edition__r.Event_Code__c =:eventCode]; 
            if(lstBoothSizeBadgeLimit1.size()> 0 && listAreas.size()>0)
            {
                for(Booth_Size_Badge_Limit__c badge :lstBoothSizeBadgeLimit1){
                    for(decimal area :listAreas){
                        if((badge.Booth_Size_From__c <= area) && (area <= badge.Booth_Size_To__c)){
                            totalBadgesAllowed = totalBadgesAllowed + badge.Badges_Allowed__c;
                        }
                    }
                } 
            }
            totalBadgesAllowed=totalBadgesAllowed+badgeLimitAll; 
            totalBadgesRemaining = totalBadgesAllowed - totalBadgesUsed;
            // modified as per ticket CCEN-94
            displayBoothData = '<span style="font-weight:700;color: black; font-size:16px;"> Total Sq. Meters: &nbsp;</span>' +totalArea+'&nbsp;&nbsp;&nbsp;&nbsp;<span style="font-weight:700;color: black;font-size:16px;"> Total Allotment:&nbsp; </span>'+totalBadgesAllowed;
            displayBoothData +='&nbsp;&nbsp;&nbsp;&nbsp;<span style="font-weight:700;color: black;font-size:16px;"> Total used:&nbsp;</span>'+ totalBadgesUsed +'&nbsp;&nbsp;&nbsp;&nbsp;<span style="font-weight:700;color: black;font-size:16px;"> Total Remaining:&nbsp;</span>'+totalBadgesRemaining;       
           }
           firstLoad = true;
           return displayBoothData;
       }
        //Showing Booth message in this function like area and booth size.
        //CCEN-444
        public static string getBoothMessage(String sBoothItemId){
            if(sBoothItemId == 'All'){ checkIfAllBooth = false;}
            else {checkIfAllBooth = true;}
              String eventId = ApexPages.currentPage().getParameters().get('eventId').escapeHtml4();
              List<Booth_Size_Badge_Limit__c> lstBoothSizeBadgeLimit = new List<Booth_Size_Badge_Limit__c>();
              List<ExpocadBooth__c> lstExpocadBooth = new List<ExpocadBooth__c>();
              Decimal availableBadges;
              Decimal allowedBadges;
              Decimal badgeLimit;

              String toReturn ='';
              if(sBoothItemId != null && sBoothItemId !=''){
                  lstExpocadBooth = [Select Id, Name, CountBadges__c, Area_Number__c ,Badge_Limit__c from ExpocadBooth__c where status__c='Rented' AND Id=:sBoothItemId];
              }
              if(lstExpocadBooth.size()>0)
              {
                  if(lstExpocadBooth[0].Area_Number__c != null)
                  {
                      Decimal expocadArea = lstExpocadBooth[0].Area_Number__c; 
                      lstBoothSizeBadgeLimit =[Select Id, Badges_Allowed__c, Booth_Size_From__c, Booth_Size_To__c from Booth_Size_Badge_Limit__c where 
                                                     Event_Edition__c=:eventId AND 
                                                     (Booth_Size_From__c <=:expocadArea AND Booth_Size_To__c >=:expocadArea)];
                  }
                  if(lstBoothSizeBadgeLimit.size()>0)
                  {
                      allowedBadges = lstBoothSizeBadgeLimit[0].Badges_Allowed__c;
                      availableBadges = lstBoothSizeBadgeLimit[0].Badges_Allowed__c - lstExpocadBooth[0].CountBadges__c;
                      if (availableBadges<0){
                          availableBadges=0;
                      }
                      string avlBadges = string.valueOf(availableBadges);
                      if(lstExpocadBooth[0].Badge_Limit__c == null)
                          lstExpocadBooth[0].Badge_Limit__c = 0;
                      decimal totalBadges = lstBoothSizeBadgeLimit[0].Badges_Allowed__c+lstExpocadBooth[0].Badge_Limit__c;   
                      decimal totalUsed = totalBadges- availableBadges;
                      decimal totalSqFeet = lstExpocadBooth[0].Area_Number__c;    
                      decimal totRemaining = totalBadges-lstExpocadBooth[0].CountBadges__c;
                      // modified as per ticket CCEN-94
                      toReturn = '<span style="font-weight:700;color: black; font-size:16px;"> Total Sq. Meters: &nbsp;</span>' +totalSqFeet +'&nbsp;&nbsp;&nbsp;&nbsp;<span style="font-weight:700;color: black;font-size:16px;"> Total Allotment:&nbsp; </span>'+totalBadges; 
                      toReturn +='&nbsp;&nbsp;&nbsp;&nbsp;<span style="font-weight:700;color: black;font-size:16px;"> Total used:&nbsp;</span>'+ lstExpocadBooth[0].CountBadges__c +'&nbsp;&nbsp;&nbsp;&nbsp;<span style="font-weight:700;color: black;font-size:16px;"> Total Remaining:&nbsp;</span>'+totRemaining;
                  }
              }
              return toReturn ;
        }
        //Calling show badges and booth detail with message.
        public PageReference detailBadges()
        {
            toReturn= getBoothMessage(BoothItemId);
            return null;
        }
        //Calling show badges and booth detail with message.
       public PageReference detailBadgesAddButton()
        {
             toReturn= getBoothMessage(BoothItemId);
             return null;
        }
        //purpose for bind Financial and Account
        public class accountDetailsWrapper
        {
          public double amount{get;set;}
          public string account{get;set;}
          public double remainingAmount{get;set;}
          public string dueDate{get;set;}
          public list<double> lstAmount{get; set;}
          public list<OLIWrapper> lstproduct{get; set;}
          public List<boothDetailsWrapper> boothDetails{get; set;}
          public List<boothOpptyWrapper> boothOppty{get; set;}
          public List<boothOpptyAmountWrapper> boothOpptyAmount{get; set;}
        }
        
        //purpose for bind Product
        public class OLIWrapper
        {
            public string productType{get;set;}
            public string productName{get;set;}
        }
        //purpose for bind booth Detail
        public class boothDetailsWrapper
        {
          public string boothId{get;set;}
          public string boothName{get;set;}
          public string boothArea{get;set;}
          public string unitType{get;set;}
          public string oppty{get;set;}
          public string displayName{get;set;}
          public string boothStatus{get;set;}
        }
         //purpose for bind Oppty
        public class boothOpptyWrapper
        {
          public string opptyId{get;set;}          
        }
        //purpose for bind booth Oppty Amount
        public class boothOpptyAmountWrapper
        {
              public double Amount{get;set;}
              public double remainingAmount{get; set;}              
        }
        //purpose for bind Payment
        public class PaymentSchedule{
            public String sPaymentScheduleItem{get;set;}
            public Date CutoffDate{get;set;}
        }         
        // Starting Code invoice 
        //creating a invoice record behalf of account and event.
        public List<blng__Invoice__c> getInvoiceRecord()
        {
            String accountId = ApexPages.currentPage().getParameters().get('accountId').escapeHtml4();
            String eventId = ApexPages.currentPage().getParameters().get('eventId').escapeHtml4();            
            System.debug('eventId :'+ eventId +' accountId :'+accountId);
            List<blng__Invoice__c> lstInvoice = new List<blng__Invoice__c>();
           try{
            if(string.isNotBlank(accountId) && string.isNotBlank(eventId))
            {
                List<opportunity> listOpp = [select id,(Select id from Orders) from opportunity where AccountId=:accountId AND 
                                          EventEdition__c=:eventId AND (StageName='Closed Won' OR StageName='Closed Booked') order by createdDate];
                List<String> lstOrderId = new List<String>();
                if(listOpp != null && listOpp.size()>0){
                    for(Opportunity OppObj:listOpp)
                    {
                        if(OppObj.Orders != null){
                            for(Order  oOrderObj: OppObj.Orders){
                                lstOrderId.add('\''+oOrderObj.id+'\'');
                            }
                        }
                    }
                    if(lstOrderId != null && lstOrderId.size()>0){
                        string sortFullExp = sortExpression  + ' ' + sortDirection;
                        String query ='SELECT blng__InvoiceDate__c, blng__DueDate__c,   Schedule_Number__c, Name, Id, blng__Order__c,blng__Order__r.ContractId,blng__Order__r.Contract.ContractNumber,blng__Order__r.Contract.Name, blng__Account__c, blng__ARStatus__c, blng__TotalAmount__c,blng__Subtotal__c, blng__TaxStatus__c, blng__PaymentStatus__c,blng__InvoiceStatus__c,blng__TaxAmount__c FROM blng__Invoice__c where blng__Order__c IN';
                        String countQuery ='SELECT count() FROM blng__Invoice__c where blng__Order__c IN';
                        query +=' ('+String.join(lstOrderId,',') +')';
                        countQuery +=' ('+String.join(lstOrderId,',') +')';
                        if(String.isNotBlank(sSelectcontractId) && sSelectcontractId !='Contract')
                        {
                            query +=' and blng__Order__r.ContractId =\''+mapContract.get(sSelectcontractId)+'\'';
                            countQuery +=' and blng__Order__r.ContractId =\''+mapContract.get(sSelectcontractId)+'\'';
                        }
                        if(String.isNotBlank(sSelPlicklistStatusId) && sSelPlicklistStatusId != 'Status'){
                            query +=' And blng__PaymentStatus__c =\''+sSelPlicklistStatusId+'\'';
                             countQuery +=' And blng__PaymentStatus__c =\''+sSelPlicklistStatusId+'\'';
                        }
                        if(String.isNotBlank(sSelectDueDate) && sSelectDueDate != 'Due Date')
                        {
                             query +=' And blng__DueDate__c ='+mapPickListDueDate.get(sSelectDueDate);
                             countQuery +=' And blng__DueDate__c ='+mapPickListDueDate.get(sSelectDueDate);
                        }
                        query +=' order by ' + sortFullExp + ' limit 2000';
                        total_size = Database.countQuery(countQuery);
                        lstInvoice = Database.query(query);                                                
                    }
                }
            }
            }
            catch(Exception e){System.debug('Error :--' +e.getMessage()+' Line number >>' +e.getLineNumber());
            }
            return lstInvoice;
        }        
        public string sSelectDueDateOld{get;set;}
        public string sSelectcontractIdOld{get;set;}
        public string sSelPlicklistStatusIdOld{get;set;}        
        //Populating invoice record behalf of current user account and current selected eventId.
        public List<blng__Invoice__c> getInvoiceDetails()
        {            
            String accountId = ApexPages.currentPage().getParameters().get('accountId').escapeHtml4();
            String eventId = ApexPages.currentPage().getParameters().get('eventId').escapeHtml4();
            List<blng__Invoice__c> lstInvoice = new List<blng__Invoice__c>();
            try{
                if(string.isNotBlank(accountId) && string.isNotBlank(eventId))
                {
                    List<opportunity> listOpp = [select id,(Select id from Orders) from opportunity where AccountId=:accountId AND 
                                              EventEdition__c=:eventId AND (StageName='Closed Won' OR StageName='Closed Booked') order by createdDate];
                    List<String> lstOrderId = new List<String>();
                    if(listOpp != null && listOpp.size()>0){
                        for(Opportunity OppObj:listOpp)
                        {
                            if(OppObj.Orders != null){
                                for(Order  oOrderObj: OppObj.Orders) { lstOrderId.add('\''+oOrderObj.id+'\'');
                                }
                            }
                        }
                        if(lstOrderId != null && lstOrderId.size()>0){
                            string sortFullExp = sortExpression  + ' ' + sortDirection;
                            String query ='SELECT blng__InvoiceDate__c, blng__DueDate__c,   Schedule_Number__c, Name, Id, blng__Order__c,blng__Order__r.ContractId,blng__Order__r.Contract.ContractNumber,blng__Order__r.Contract.Name, blng__Account__c, blng__ARStatus__c, blng__TotalAmount__c,blng__Subtotal__c, blng__TaxStatus__c, blng__PaymentStatus__c,blng__InvoiceStatus__c,blng__TaxAmount__c,(Select id,Name from blng__Payments__r) FROM blng__Invoice__c where blng__Order__c IN';
                            String countQuery ='SELECT count() FROM blng__Invoice__c where blng__Order__c IN';
                            query +=' ('+String.join(lstOrderId,',') +')';
                            countQuery +=' ('+String.join(lstOrderId,',') +')';
                            if(String.isNotBlank(sSelectcontractId) && sSelectcontractId !='Contract')
                            {
                                query +=' and blng__Order__r.ContractId =\''+mapContract.get(sSelectcontractId)+'\'';
                                countQuery +=' and blng__Order__r.ContractId =\''+mapContract.get(sSelectcontractId)+'\'';
                                if(sSelPlicklistStatusId != sSelPlicklistStatusIdOld){
                                    sSelPlicklistStatusIdOld = sSelPlicklistStatusId ;
                                    list_size=20;
                                    counter =0;
                                 }
                            }
                            else{sSelPlicklistStatusIdOld = sSelPlicklistStatusId ;
                            }
                            if(String.isNotBlank(sSelPlicklistStatusId) && sSelPlicklistStatusId != 'Status'){
                                query +=' And blng__PaymentStatus__c =\''+sSelPlicklistStatusId+'\'';
                                 countQuery +=' And blng__PaymentStatus__c =\''+sSelPlicklistStatusId+'\'';
                                if(sSelPlicklistStatusId != sSelPlicklistStatusIdOld){
                                     list_size=20;
                                    counter =0;
                                    sSelPlicklistStatusIdOld = sSelPlicklistStatusId;
                                }
                            }
                            else{sSelPlicklistStatusIdOld = sSelPlicklistStatusId;
                            }
                            if(String.isNotBlank(sSelectDueDate) && sSelectDueDate != 'Due Date')
                            {
                                query +=' And blng__DueDate__c ='+mapPickListDueDate.get(sSelectDueDate);
                                 countQuery +=' And blng__DueDate__c ='+mapPickListDueDate.get(sSelectDueDate);
                                 if(sSelectDueDate != sSelectDueDateOld){
                                     list_size=20;
                                     counter =0;
                                     sSelectDueDateOld=  sSelectDueDate ;
                                 }
                            }
                            else{sSelectDueDateOld=  sSelectDueDate ;
                            }
                            query +=' order by ' + sortFullExp + ' limit '+list_size+' offset '+counter;
                            total_size = Database.countQuery(countQuery);
                            lstInvoice = Database.query(query);
                            }
                    }
                }
            }
            catch(Exception e){System.debug('Error :--' +e.getMessage()+' Line number >>' +e.getLineNumber());
            }
            return lstInvoice;
        }
        //changing sorting Expression
        public String sortExpression
        {
            get{return sortExp;
            }
            set
            {
               //if the column is clicked on then switch between Ascending and Descending modes
               if (value == sortExp)
                 sortDirection = (sortDirection == 'ASC')? 'DESC' : 'ASC';
               else
                 sortDirection = 'ASC';
               sortExp = value;
            }
        }
         //changing sorting Expression on Contract
        public String sortExpressionContract
        {
            get{return sortExpContract;
            }
            set
            {
               //if the column is clicked on then switch between Ascending and Descending modes
               if (value == sortExpContract)
                 sortDirection = (sortDirection == 'ASC')? 'DESC' : 'ASC';
               else
                 sortDirection = 'ASC';
               sortExpContract = value;
            }
        }
         //changing sorting Expression on Payment
        public String sortExpressionPayment
        {
            get{return sortExpPayment;
            }
            set
            {
               //if the column is clicked on then switch between Ascending and Descending modes
               if (value == sortExpPayment)
                 sortDirection = (sortDirection == 'ASC')? 'DESC' : 'ASC';
               else
                 sortDirection = 'ASC';
               sortExpPayment = value;
            }
        }
        //Getting sorting Direction 
        public String getSortDirection()
        {
            //if not column is selected 
            if (sortExpression == null || sortExpression == '')
              return 'ASC';
            else
             return sortDirection;
        }
        //setting sorting Direction
        public void setSortDirection(String value){sortDirection = value;
        }
        
        //In this method refersh the Vf page 
        public PageReference viewData() {return null;
        }
        //In this method showing  on Invoice Detail
        public PageReference isShowOneInvoiceDetail()
        {
            isInvoiceDetailShow = (isInvoiceDetailShow==true?false:true);
            if(TotalAmountInvoice!=0.00)
                    {
                       TotalAmountInvoiceCheck=true;
                    }
            return null;
        }
        //In this method showing  on Invoice Detail and Payment Detail
        public PageReference isShowOneInvoiceDetailForPayment()
        {
            isPaymentDetailShow = (isPaymentDetailShow==true?false:true);
            isPaymentDetailShowForPayment = (isPaymentDetailShowForPayment==true?false:true);
            isInvoiceDetailShowForPayment = (isInvoiceDetailShowForPayment==true?false:true);
         if(TotalAmountInvoice!=0.00)
                    {
                       TotalAmountInvoiceCheck=true;
                    }
            return null;
        }
        //Showing Invoice product detail
        public List<ProductWrapper> getInvoiceAndProductDetail()
        {
        List<ProductWrapper> lstProd = new List<ProductWrapper>();
        ProductWrapper productWrap = new ProductWrapper();
        productWrap.InvoiceNumber ='# 00000';
        productWrap.InvoiceTotal =0.0;
        List<InvoiceLineItemWrapper> lineItemLst = new List<InvoiceLineItemWrapper>();
        productWrap.Product = lineItemLst;
        List<blng__Invoice__c> lstInvoice  =new List<blng__Invoice__c>([SELECT blng__InvoiceDate__c,PullQuoteID__c,TaxRate__c,blng__PaymentStatus__c,blng__InvoiceStatus__c,InvoiceTemplate__c,Schedule_Number__c,  Name, Id, blng__Order__c, blng__TotalAmount__c, blng__Subtotal__c, blng__TaxStatus__c, (select id , BodyLength  FROM Attachments Order by CreatedDate desc LIMIT 1),blng__TaxAmount__c,blng__Order__r.OpportunityId,(Select id,Name,blng__UnitPrice__c,blng__TotalAmount__c,blng__Subtotal__c,blng__Quantity__c,blng__Product__c,blng__Product__r.Name, blng__Product__r.Booth_Product_Type__c from blng__InvoiceInvoiceLines__r) FROM blng__Invoice__c  where Id=:sInvoiceId]);
        If(lstInvoice != null && lstInvoice.size()>0){
            productWrap.InvoiceNumber=lstInvoice[0].name;
            productWrap.InovoiceDate=lstInvoice[0].blng__InvoiceDate__c;
            productWrap.InovoiceDate=lstInvoice[0].blng__InvoiceDate__c;
            productWrap.InvoiceSubTotal = lstInvoice[0].blng__TotalAmount__c.setScale(2, RoundingMode.HALF_UP);
            productWrap.InvoiceTemplate = lstInvoice[0].InvoiceTemplate__c;
            productWrap.PaymentStatus = lstInvoice[0].blng__PaymentStatus__c;
            productWrap.PullQuoteID = lstInvoice[0].PullQuoteID__c;
             if(lstInvoice[0].Schedule_Number__c != null){ productWrap.PaySchedule =mapPaymentSchedule.get(Integer.valueOf(lstInvoice[0].Schedule_Number__c));
            }
            else{productWrap.PaySchedule ='0.0 ' ;
            }
            productWrap.InvoiceSubTotal = lstInvoice[0].blng__Subtotal__c.setScale(2, RoundingMode.HALF_UP);
            productWrap.TaxRate = lstInvoice[0].TaxRate__c;
            productWrap.TaxAmount =lstInvoice[0].blng__TaxAmount__c.setScale(2, RoundingMode.HALF_UP);
            productWrap.ContractSubTotal =0.0;
            productWrap.Product = lineItemLst;
            productWrap.InvoiceTotal = (productWrap.TaxAmount+productWrap.InvoiceSubTotal).setScale(2, RoundingMode.HALF_UP);
            for(blng__InvoiceLine__c oInvLineItem:lstInvoice[0].blng__InvoiceInvoiceLines__r)
            {
                productWrap.ContractSubTotal +=oInvLineItem.blng__Subtotal__c;
                InvoiceLineItemWrapper invLineItem = new InvoiceLineItemWrapper();
                invLineItem.OppLineItemId =oInvLineItem.id;
                invLineItem.Event_Product_Type =oInvLineItem.blng__Product__r.Booth_Product_Type__c;
                invLineItem.UnitPrice =oInvLineItem.blng__UnitPrice__c.setScale(2, RoundingMode.HALF_UP);
                invLineItem.Quantity =oInvLineItem.blng__Quantity__c;
                invLineItem.Name =oInvLineItem.Name;
                invLineItem.TotalAmount = (oInvLineItem.blng__UnitPrice__c*oInvLineItem.blng__Quantity__c).setScale(2, RoundingMode.HALF_UP);
                invLineItem.TotalPrice =oInvLineItem.blng__Subtotal__c;
                lineItemLst.add(invLineItem);
            }
            productWrap.AttachmentId ='NoAttachment';
            for(Attachment ObjAtt:lstInvoice[0].Attachments){
                productWrap.AttachmentId = ObjAtt.id;
            }
            productWrap.Product = lineItemLst;
            productWrap.InvoiceTotal = productWrap.TaxAmount+productWrap.InvoiceSubTotal.setScale(2, RoundingMode.HALF_UP);            
        }         
        lstProd.add(productWrap);  
        return lstProd;
    }
        //purpose for bind Invoice Line Item record
        public class InvoiceLineItemWrapper{
            public Id OppLineItemId{get;set;}
            public String Event_Product_Type{get;set;}
            public Decimal UnitPrice{get;set;}
            public Decimal Quantity{get;set;}
            public String Name{get;set;}
            public Decimal TotalPrice{get;set;}
            public Decimal TotalAmount{get;set;}
        }
        //purpose for bind Invoice  with InvoiceLineItem record
        public class ProductWrapper{
            public String InvoiceNumber{get;set;}
            public Date InovoiceDate{get;set;}
            public List<InvoiceLineItemWrapper> Product{get;set;}
            public String PaymentStatus{get;set;}
            public Decimal ContractSubTotal{get;set;}
            public String PaySchedule{get;set;}
            public Decimal InvoiceSubTotal{get;set;}
            public Decimal TaxRate{get;set;}
            public Decimal TaxAmount{get;set;}
            public Decimal InvoiceTotal{get;set;}
            public String AttachmentId{get;set;}
            public string InvoiceTemplate{get;set;}
            public string PullQuoteID{get;set;}
        }        
        //Converted date format into the string format
        public static String convertDate(Date dateConvert,Boolean isCreateDate)
        {
            if(isCreateDate){
                Date dt = dateConvert;
                String d = String.valueOf(dt.day());
                String month = String.valueOf(dt.month());
                Integer yr = dt.year();
                return (month.length()==1?'0'+month:month)+'/'+(d.length()==1?'0'+d:d) +'/'+yr;
            }  
            else{return string.valueOf(dateConvert);
            }
        }
        //End invoice code.        
        //Starting Pagination Code
        //user clicked beginning
        public PageReference beginning() { 
          counter = 0;
          return null;
       }
        //user clicked previous button
       public PageReference previous() { 
          counter -= list_size;
          return null;
       }
        //user clicked next button
       public PageReference next() { 
          counter += list_size;
          return null;
       }
        //user clicked end
       public PageReference end() { 
          counter = total_size - math.mod(total_size, list_size);
          return null;
       }
         //this will disable the previous and beginning buttons
       public Boolean getDisablePrevious() { if (counter>0) return false; else return true;
       }
        //this will disable the next and end buttons
       public Boolean getDisableNext() { if (counter + list_size < total_size) return false; else return true;
       }
      //Getting record list size
       public Integer getTotal_size() {return total_size;
       }
      //Get total pages in records
       public Integer getPageNumber() { return counter/list_size + 1;
       }
        //Get total page number. 
       public Integer getTotalPages() {
          if (math.mod(total_size, list_size) > 0) {return total_size/list_size + 1;
          } else {return (total_size/list_size);
          }
       }
       //End Pagenation Code       
        //Starting Contract Code 
        //Creating Contract records behalf of account and event.
        public List<Contract> getContractRecord()
        {
            String accountId = ApexPages.currentPage().getParameters().get('accountId').escapeHtml4();
            String eventId = ApexPages.currentPage().getParameters().get('eventId').escapeHtml4();
            List<Contract> lstContract = new List<Contract> ();
            if(String.isNotBlank(accountId) && String.isNotBlank(eventId)) 
            {
                string sortFullExp = sortExpressionContract  + ' ' + sortDirection;
                String sQuery = 'SELECT Id, AccountId,Account.Name,Amount__c, StartDate, EndDate,Description, ContractNumber, LastModifiedDate,CreatedDate,SBQQ__Opportunity__r.Amount FROM Contract where (SBQQ__Opportunity__r.StageName=\'Closed Won\' OR SBQQ__Opportunity__r.StageName=\'Closed Booked\') and SBQQ__Opportunity__r.EventEdition__c =\''+eventId+'\' and AccountId =\''+accountId +'\'';
                String sCountQuery = 'SELECT Count() FROM Contract where (SBQQ__Opportunity__r.StageName=\'Closed Won\' OR SBQQ__Opportunity__r.StageName=\'Closed Booked\') and SBQQ__Opportunity__r.EventEdition__c =\''+eventId+'\' and AccountId =\''+accountId +'\'';
                total_size = Database.countQuery(sCountQuery);
                sQuery +=' order by ' + sortFullExp + ' limit '+list_size+' offset '+counter;
                lstContract = Database.query(sQuery);                     
            }                
            return lstContract;
        }
        public string sSelectedContractId{get;set;}
        public String sAgreementId{get;set;}
        //Showing a Contract Detail.
        public Contract getContractDetail()
        {
            Contract oContract = new Contract();
            sAgreementId ='NoAttachment';
            if(String.isNotBlank(sSelectedContractId)){
                oContract = [SELECT Id, AccountId,Account.Name,Amount__c, StartDate, EndDate,Description, ContractNumber,Name,Status, LastModifiedDate,CreatedDate,SBQQ__Opportunity__c,SBQQ__Opportunity__r.Amount FROM Contract where Id =:sSelectedContractId];
                if(oContract != null && oContract.SBQQ__Opportunity__c != null){
                    List<Agreement__c> agreementLst = new List<Agreement__c>([Select Id,(Select id FROM Attachments ORDER BY CreatedDate desc LIMIT 1)FROM Agreement__c where Opportunity__c =:oContract.SBQQ__Opportunity__c ORDER BY CreatedDate desc LIMIT 1]);
                    if(agreementLst != null &&agreementLst.size()>0)
                    {
                        for(Attachment att: agreementLst[0].Attachments){sAgreementId=att.id;
                        }
                    }
                }
            }return oContract;
        }
        //Showing a Contract Detail
        public PageReference isShowOneContactDetail()
        {
            isContractDetailShow = (isContractDetailShow==true?false:true);
            return null;
        }        
        //End Contract Code
        /* Merge Contract Code Start */
        public Map<String,List<OppLineItemWrapper>> mapOppLineItem{get;set;}
        //purpose for bind Contract record
        public class ContractWrap
        {
            public String ContractNumber{get;set;}
            public Date StartDate{get;set;}
            public Decimal SubTotal{get;set;}
            public List<OppLineItemWrapper> oppLItemWrap{get;set;}
            public String sAgreementAttId{get;set;}
        }
        //purpose for bind Opp Line Item
        public class OppLineItemWrapper
        {
            public String ProductType{get;set;}
            public String ProductName{get;set;}
            public Decimal Quantity{get;set;}
            public Decimal Rate{get;set;}
            public Decimal Amount{get;set;}
        }
        //Creating a Contract behalf of current user account and current selected event
        public List<ContractWrap> getOppProducts(){
            String accountId = ApexPages.currentPage().getParameters().get('accountId');
            String eventId = ApexPages.currentPage().getParameters().get('eventId');
            Map<String,ContractWrap> mapContract = new Map<String,ContractWrap>();
            Map<String,String> mapContractWithOpp= new Map<String,String>();
            if(String.isNotBlank(accountId) && String.isNotBlank(eventId)) 
            {
                List<Opportunity> lstOpp = new List<Opportunity>([SELECT Id, StageName, AccountId, EventEdition__c,(SELECT Id, AccountId, Account.Name, Amount__c, 
                StartDate, EndDate, Description, ContractNumber FROM SBQQ__Contracts__r LIMIT 1),(Select  Id, Name, OpportunityId, Quantity, UnitPrice, TotalPrice, Product2.Booth_Product_Type__c from OpportunityLineItems),(Select Id FROM Agreements__r LIMIT 1) 
                FROM Opportunity where StageName IN('Closed Won', 'Closed Booked') AND EventEdition__c =:eventId AND AccountId =:accountId]);                
                for(Opportunity opp:lstOpp)
                {
                    ContractWrap oContWrap = new ContractWrap();
                    oContWrap.ContractNumber ='';
                    oContWrap.SubTotal =0.0;
                    List<OppLineItemWrapper> oppLiItem =new List<OppLineItemWrapper>();
                    if(opp.SBQQ__Contracts__r!=null && opp.SBQQ__Contracts__r.size()>0)
                    {
                        oContWrap.ContractNumber =opp.SBQQ__Contracts__r[0].ContractNumber;
                        oContWrap.StartDate =opp.SBQQ__Contracts__r[0].StartDate;                                            
                        for(OpportunityLineItem oppLItem:opp.OpportunityLineItems){
                            OppLineItemWrapper oOppLineItemWrapper = new OppLineItemWrapper();
                            oOppLineItemWrapper.ProductType = oppLItem.Product2.Booth_Product_Type__c;
                            oOppLineItemWrapper.ProductName = oppLItem.Name;
                            oOppLineItemWrapper.Quantity = oppLItem.Quantity;
                            oOppLineItemWrapper.Rate =oppLItem.UnitPrice;
                            oOppLineItemWrapper.Amount =oppLItem.TotalPrice;
                            oContWrap.SubTotal +=oOppLineItemWrapper.Amount;
                            oppLiItem.add(oOppLineItemWrapper);
                        }                    
                        if(oppLiItem != null && oppLiItem.size()>0){oContWrap.oppLItemWrap = oppLiItem;
                        }
                        else{oContWrap.oppLItemWrap = new List<OppLineItemWrapper>();
                        }
                        for(Agreement__c agree : opp.Agreements__r){mapContractWithOpp.put(opp.id,opp.SBQQ__Contracts__r[0].ContractNumber);
                        }    
                        mapContract.put(opp.SBQQ__Contracts__r[0].ContractNumber,oContWrap);
                    }
                }                
                List<Agreement__c> agreementLst = new List<Agreement__c>([Select Id,Opportunity__c,(Select id FROM Attachments ORDER BY CreatedDate desc LIMIT 1)FROM Agreement__c where Opportunity__c IN :lstOpp]);
                if(agreementLst != null &&agreementLst.size()>0)
                {
                    for(Agreement__c agree:agreementLst)
                    {
                        for(Attachment att: agreementLst[0].Attachments)
                        {
                            if(agree.Opportunity__c != null && mapContractWithOpp.containsKey(agree.Opportunity__c))
                            {
                                string sContractId = mapContractWithOpp.get(agree.Opportunity__c);
                                if(String.isNotBlank(sContractId) && mapContract.containsKey(sContractId)){
                                    ContractWrap oContWrap = mapContract.get(sContractId);
                                    oContWrap.sAgreementAttId =att.id;
                                    mapContract.put(sContractId,oContWrap);
                                } 
                            }
                        }
                    }
                }
            }return mapContract.values();
        }
       /*  Merge Contract Code End  */               
        //Starting Payment Code
        //Creating Payment record behalf of current user account and current event.
        public List<blng__Payment__c> getPaymentRecord()
        {
            String accountId = ApexPages.currentPage().getParameters().get('accountId');
            String eventId = ApexPages.currentPage().getParameters().get('eventId');
            List<blng__Payment__c> lstPayment = new List<blng__Payment__c> ();
            if(String.isNotBlank(accountId) && String.isNotBlank(eventId)) 
            {
                string sortFullExp = sortExpressionPayment  + ' ' + sortDirection;
                Map<String,Order> mapOrder = new Map<String,Order>([select id from Order where opportunity.AccountId=:accountId AND 
                                              opportunity.EventEdition__c=:eventId AND (opportunity.StageName='Closed Won' OR opportunity.StageName='Closed Booked') order by createdDate]);
                if(mapOrder != null && mapOrder.size()>0)
                {
                    Map<String,blng__Invoice__c> mapInvoice  =new Map<String,blng__Invoice__c>([SELECT id FROM blng__Invoice__c  where  blng__Order__c IN :mapOrder.keyset()]);
                String sInvoiceIds = '';
                    for(String sId:mapInvoice.keySet()){
                        sInvoiceIds +=(String.isNotBlank(sInvoiceIds)? ',\''+sId+'\'':'\''+sId+'\'');
                    }
                    if(String.isNotBlank(sInvoiceIds)){
                        String sCountQuery = 'SELECT Count() FROM blng__Payment__c where blng__Invoice__c IN ('+sInvoiceIds+')';
                        total_size = Database.countQuery(sCountQuery);
                        String sQuery  = 'SELECT Id, Name, blng__Account__c, blng__Transaction__r.Name,blng__Amount__c, blng__Invoice__c,blng__Invoice__r.Name, blng__PaymentDate__c, blng__PaymentMethod__c,blng__PaymentType__c, blng__PaymentMethod__r.Name, blng__Transaction__c FROM blng__Payment__c where blng__Invoice__c IN ('+sInvoiceIds+')';
                        sQuery +=' order by ' + sortFullExp + ' limit '+list_size+' offset '+counter;
                        lstPayment = Database.query(sQuery);
                    }
                }                    
            }return lstPayment;
        }
        public string sSelectedPaymentId{get;set;}
        //Creating Payment Detail.
        public blng__Payment__c getPaymentDetail()
        {
            blng__Payment__c oPayment = new blng__Payment__c();
            if(String.isNotBlank(sSelectedPaymentId)){
                oPayment = [SELECT Id, Name,blng__Status__c,blng__PaymentDescription__c,blng__Balance__c,blng__PaymentMethod__r.blng__PaymentGateway__c,blng__Account__c, blng__Amount__c, blng__Invoice__c,blng__Invoice__r.Name,blng__Transaction__r.Name, blng__PaymentDate__c, blng__PaymentMethod__c, blng__Transaction__c,blng__PaymentType__c, blng__PaymentMethod__r.Name FROM blng__Payment__c where Id =:sSelectedPaymentId];
            }
            return oPayment;
        }
        //Creating record for payment behalf Invoice.
        public List<blng__Payment__c> getPaymentDetailForInvoice()
        {
            List <blng__Payment__c> oPayment = new List<blng__Payment__c>();
            if(String.isNotBlank(sSelectedPaymentId)){
                oPayment = [SELECT Id, Name, blng__Account__c, blng__Amount__c, blng__Invoice__c,blng__Invoice__r.Name,blng__Transaction__r.Name, blng__PaymentDate__c, blng__PaymentMethod__c, blng__Transaction__c,blng__PaymentType__c, blng__PaymentMethod__r.Name FROM blng__Payment__c where blng__Invoice__c =:sSelectedPaymentId];
            }
            return oPayment;
        }
        //Showing a Payment Detail.
        public PageReference isShowOnePaymentDetail()
        {
            isPaymentDetailShow = (isPaymentDetailShow==true?false:true);
            return null;
        }
        // Showing payment detail for Invoice. 
        public PageReference isShowOnePaymentDetailForInvoice()
        {
            isPaymentDetailShowForInvoice = (isPaymentDetailShowForInvoice==true?false:true);
            isInvoiceDetailShow = (isInvoiceDetailShow==true?false:true);
            isInvoiceDetailShowForInvoice = (isInvoiceDetailShowForInvoice==true?false:true);            
            return null;
        }
        //End Payment Code        
        // Process payment of Invoice
        public PageReference processPayment()
        {
            try
            {
                contactId = ApexPages.currentPage().getParameters().get('contactId');
                String eventId = ApexPages.currentPage().getParameters().get('eventId');
                PageReference page=new PageReference('/apex/InvoicePayment?contactId='+contactId+'&eventId='+eventId+'&InvoiceId='+sInvoiceId);
                page.setRedirect(true);
                return page;
            }
            catch(Exception e){System.debug('message:='+e.getmessage()+'**Line Number:='+e.getLineNumber());
            }
            return null;
        }        
        // Process multiple Invoice payment
        public PageReference multipleInvoicePayment()
        {
            try
            {   
                contactId = ApexPages.currentPage().getParameters().get('contactId');
                String eventId = ApexPages.currentPage().getParameters().get('eventId');
                String invoiceIds=ApexPages.CurrentPage().getParameters().get('checkedIds');
                PageReference pageRef=new PageReference('/apex/InvoicePayment?ids='+invoiceIds+'&type=multiple&contactId='+contactId+'&eventId='+eventId);
                pageRef.setRedirect(true);
                return pageRef;
            }
            catch(Exception e){System.debug('Message:='+e.getMessage()+'**Line Number='+e.getLineNumber());
            }
            return null;
        }        
        //----------------------Financial Summary Tab New Work----------------------//
        public static string dueDateInvoice;
        public static date dueDateForInvoice {get; set;}
        public decimal invoiceAmountDue {get; set;}
        public decimal invoiceAmountPastDue {get; set;}
        public static integer paymentDuePercent {get; set;}
        //creating record for Invoice behalf current user account and current selected event.
        //Firstly, Check opportunity stage is Closed won and Closed booked.
        //Then after creating invoice record.
        public static accountDetailsWrapperForInvoice getOppAccountDetailsInvoice()
        {
            String accountId = ApexPages.currentPage().getParameters().get('accountId');
            String eventId = ApexPages.currentPage().getParameters().get('eventId');
            accountDetailsWrapperForInvoice acctDetail = new accountDetailsWrapperForInvoice();
            Date currentDate =  date.today();
            acctDetail.amount =0.0;
            acctDetail.paidAmount =0.0;
            acctDetail.remainingAmount =0.0;
            acctDetail.check=false;
            paymentDuePercent = 0;
            if(string.isNotBlank(accountId) && string.isNotBlank(eventId))
            {
                List<opportunity> oppLst = [select id,Name,Amount,Paid_Amount__c,Payment_Status__c,EventEdition__r.Cutoff_Date_1__c, EventEdition__r.Payment_Schedule__c, 
                                            EventEdition__r.Cutoff_Date_2__c,EventEdition__r.Cutoff_Date_3__c,EventEdition__r.EventCurrency__r.name from opportunity
                                            where AccountId=:accountId AND 
                                            EventEdition__c=:eventId AND (StageName='Closed Won' OR StageName='Closed Booked') order by createdDate];
                List<Account> accLst  = [Select Id, name,  Has_Balance__c from Account where id=:accountId  ];   
                List<Account> newAccLst= new List<Account>();   
                List<string> eventPaymentSchedule= new List<string>();
                integer checkPaymentScheduleCount = 0;                                  
                if(oppLst!=null && oppLst.size()>0)
                {
                    list<Date> dueDateLst = new list<Date>();
                    for(opportunity opp:oppLst)
                    {
                        if(opp.Paid_Amount__c != null){ acctDetail.paidAmount += opp.Paid_Amount__c;
                        }
                        if (opp.Amount!=null){acctDetail.Amount += opp.Amount;
                        }                        
                        Date dueDate;                        
                        if(opp.Payment_Status__c!='Paid' && opp.EventEdition__r.Cutoff_Date_1__c != null && opp.EventEdition__r.Cutoff_Date_1__c > currentDate)
                        {
                            dueDate = opp.EventEdition__r.Cutoff_Date_1__c; checkPaymentScheduleCount = 0;
                        }
                        else if(opp.Payment_Status__c!='Paid' && opp.EventEdition__r.Cutoff_Date_1__c != null && opp.EventEdition__r.Cutoff_Date_2__c > currentDate)
                        {
                            dueDate = opp.EventEdition__r.Cutoff_Date_2__c; checkPaymentScheduleCount = 1;
                        }
                        else if(opp.Payment_Status__c!='Paid' && opp.EventEdition__r.Cutoff_Date_1__c != null && opp.EventEdition__r.Cutoff_Date_3__c > currentDate)
                        {
                            dueDate = opp.EventEdition__r.Cutoff_Date_3__c; checkPaymentScheduleCount = 2;
                        }                       
                        if(dueDate!=null){dueDateLst.add(dueDate);
                        }
                        if (String.IsNotBlank(opp.EventEdition__r.Payment_Schedule__c)){eventPaymentSchedule = opp.EventEdition__r.Payment_Schedule__c.split('-');
                        }
                        else{eventPaymentSchedule.add('100');
                        }
                    }
                    if(eventPaymentSchedule != null && eventPaymentSchedule.size()>0){paymentDuePercent = Integer.valueOf(eventPaymentSchedule[checkPaymentScheduleCount]);
                    }                   
                    Double rAmount= acctDetail.Amount - acctDetail.paidAmount;
                    if (rAmount!=0)
                    {                                                                           
                        acctDetail.check=true;
                        acctDetail.remainingAmount = acctDetail.Amount - acctDetail.paidAmount;
                        acctDetail.currencyType = oppLst[0].EventEdition__r.EventCurrency__r.name;
                        if(dueDateLst.size()>0 && dueDateLst!=null)
                        {
                            dueDateLst.sort();
                            acctDetail.dueDate = changeDateFormatInvoice(dueDateLst[0]);
                            dueDateInvoice = changeDateFormatInvoice(dueDateLst[0]);
                            dueDateForInvoice = dueDateLst[0];
                        }
                    }                                         
                }
            }
            return acctDetail ;
        }
        //Converting Date into String Format
        public static String changeDateFormatInvoice(Date d)
        {
           String dt = DateTime.newInstance(d.year(),d.month(),d.day()).format('YYYY-MM-d');
           return dt;
        }        
        //purpose for bind Invoice record
        public class accountDetailsWrapperForInvoice
        {
          public decimal amount{get;set;}
          public decimal paidAmount{get;set;}
          public decimal remainingAmount{get;set;}
          public string dueDate{get;set;}
          public string currencyType{get;set;}
          public boolean check{get;set;}
        } 
        // invoice method start
        //Creating Invoice record behalf of account and event.
        public List<blng__Invoice__c> getInvoiceRecordDetails()
        {
            getOppAccountDetailsInvoice();
            String accountId = ApexPages.currentPage().getParameters().get('accountId');
            String eventId = ApexPages.currentPage().getParameters().get('eventId');
            accountDetailsWrapper accDetailWrap = new accountDetailsWrapper();
            List<blng__Invoice__c> lstInvoice = new List<blng__Invoice__c>();
            List<blng__Invoice__c > listInvoiceDetails = new List<blng__Invoice__c >();
           try{
            if(string.isNotBlank(accountId) && string.isNotBlank(eventId))
            {
                List<opportunity> listOpp = [select id,(Select id from Orders) from opportunity where AccountId=:accountId AND 
                                          EventEdition__c=:eventId AND (StageName='Closed Won' OR StageName='Closed Booked') order by createdDate];                
                List<String> lstOrderId = new List<String>();
                Set<Id> setOrderIds = new  Set<Id>();
                if(listOpp != null && listOpp.size()>0){
                    for(Opportunity OppObj:listOpp)
                    {
                        if(OppObj.Orders != null){
                            for(Order  oOrderObj: OppObj.Orders) { lstOrderId.add('\''+oOrderObj.id+'\'');
                                setOrderIds.add(oOrderObj.id);
                            }
                        }
                    }
                    date invDate = date.valueOf(dueDateInvoice);
                    if(lstOrderId != null && lstOrderId.size()>0){
                        listInvoiceDetails =[SELECT blng__InvoiceDate__c, blng__DueDate__c,TaxRate__c, Schedule_Number__c, Name, Id, blng__Order__c,blng__Order__r.ContractId,blng__Order__r.Contract.ContractNumber,blng__Order__r.Contract.Name, blng__Account__c, blng__ARStatus__c, blng__TotalAmount__c,blng__Subtotal__c, blng__TaxStatus__c, blng__PaymentStatus__c,blng__InvoiceStatus__c,blng__TaxAmount__c FROM blng__Invoice__c 
                        where blng__Order__c IN: setOrderIds AND blng__DueDate__c=:invDate AND blng__PaymentStatus__c != 'Paid'];
                    }
                    invoiceAmountDue = 0;
                    if(listInvoiceDetails != null && listInvoiceDetails.size()>0)
                        for(blng__Invoice__c inv :listInvoiceDetails){
                            invoiceAmountDue += inv.blng__Subtotal__c;
                        }                     
                    }
            }
            }
            catch(Exception e){System.debug('Error :--' +e.getMessage()+' Line number >>' +e.getLineNumber());
            }
            return listInvoiceDetails;
        } // invoice method end        
        // invoice method start for Past Due Invoices
        public List<blng__Invoice__c> getInvoiceRecordDetailsForPastInv()
        {          
            getOppAccountDetailsInvoice();
            String accountId = ApexPages.currentPage().getParameters().get('accountId');
            String eventId = ApexPages.currentPage().getParameters().get('eventId');
            accountDetailsWrapper accDetailWrap = new accountDetailsWrapper();
            List<blng__Invoice__c> lstInvoice = new List<blng__Invoice__c>();
            List<blng__Invoice__c > listInvoiceDetails = new List<blng__Invoice__c >();
            try
            {
                if(string.isNotBlank(accountId) && string.isNotBlank(eventId))
                {
                    List<opportunity> listOpp = [select id,(Select id from Orders) from opportunity where AccountId=:accountId AND 
                                              EventEdition__c=:eventId AND (StageName='Closed Won' OR StageName='Closed Booked') order by createdDate];                    
                    List<String> lstOrderId = new List<String>();
                    Set<Id> setOrderIds = new  Set<Id>();
                    if(listOpp != null && listOpp.size()>0){
                        for(Opportunity OppObj:listOpp)
                        {
                            if(OppObj.Orders != null){
                                for(Order  oOrderObj: OppObj.Orders){
                                    lstOrderId.add('\''+oOrderObj.id+'\'');
                                    setOrderIds.add(oOrderObj.id);
                                }
                            }
                        }
                        date invDate = date.valueOf(dueDateInvoice);
                        if(lstOrderId != null && lstOrderId.size()>0){
                            listInvoiceDetails =[SELECT blng__InvoiceDate__c, blng__DueDate__c,TaxRate__c, Schedule_Number__c, Name, Id, blng__Order__c,blng__Order__r.ContractId,blng__Order__r.Contract.ContractNumber,blng__Order__r.Contract.Name, blng__Account__c, blng__ARStatus__c, blng__TotalAmount__c,blng__Subtotal__c, blng__TaxStatus__c, blng__PaymentStatus__c,blng__InvoiceStatus__c,blng__TaxAmount__c FROM blng__Invoice__c 
                            where blng__Order__c IN: setOrderIds AND blng__InvoiceStatus__c ='Posted' AND blng__PaymentStatus__c != 'Paid' AND blng__DueDate__c < today];
                        }
                        invoiceAmountPastDue = 0;
                        if(listInvoiceDetails != null && listInvoiceDetails.size()>0)
                            for(blng__Invoice__c inv :listInvoiceDetails){
                                invoiceAmountPastDue+= inv.blng__Subtotal__c;
                            }                        
                        }
                }
            }
            catch(Exception e){System.debug('Error :--' +e.getMessage()+' Line number >>' +e.getLineNumber());
            }
            return listInvoiceDetails;
        } // invoice method end        
        //Method to download Invoice using conga template
        public PageReference downloadInvoicePDF()
        {
            try
            {   
            String queryIds='[AllInvoiceLines]a2Q18000000cgbA,[BillToContact]a2Q5000000Hyol1, [PaymentsByInvoice]a2Q5000000Hyol6,[PaymentsByOrder]a2Q5000000HyolB,[AcctBlngAddress]a2Q18000000corS,[QuotePMTTerms]a2Q18000000ck3m';
            String retpath='/apex/CongaPreviewPage?quoteId='+sInvoiceId+'-Preview';
             string url = '/apex/APXTConga4__Conga_Composer?SolMgr=1&sessionId='+sessionId+'&serverUrl='+serverURL+'&Id='+sInvoiceId+'&TemplateId=a2Y50000001fJ1z'+'&QueryId='+queryIds+'&DS7=1&BML=Generating+Invoice+for+'+'&SC0=1&SC1=Documents&DefaultPDF=1&DocFolderID=00l50000001GfAf&ReturnPath='+retPath;            
               PageReference pageRef=new PageReference(url);
                return pageRef;
            }
            catch(Exception e){System.debug('Message:='+e.getMessage()+'**Line Number='+e.getLineNumber());
            }
            return null;
        }        
        //Method to fetch Opportunity Booth Summary
        public List<OppBoothDetailsWrapper> getOppBoothDetails()
        {
            String accountId = ApexPages.currentPage().getParameters().get('accountId');
            String eventId = ApexPages.currentPage().getParameters().get('eventId');
            set<string> quoteIds = new set<string>();
            List<OppBoothDetailsWrapper> oppBoothWrprLst =new List<OppBoothDetailsWrapper>();
            List<ExpocadBooth__c> expoBooths= new List<ExpocadBooth__c>();
            if(string.isNotBlank(accountId) && string.isNotBlank(eventId))
            {
                List<opportunity> opp = [select id,Name,Amount,Paid_Amount__c,Payment_Status__c,SBQQ__PrimaryQuote__c,EventEdition__r.Cutoff_Date_1__c,
                                            EventEdition__r.Cutoff_Date_2__c,EventEdition__r.Cutoff_Date_3__c,(select id,Event_Product_Type__c,Product2.name from OpportunityLineItems)
                                            from opportunity where AccountId=:accountId AND 
                                            EventEdition__c=:eventId AND (StageName='Closed Won' OR StageName='Closed Booked') order by createdDate];               
                if(!opp.IsEmpty())
                {
                    for(opportunity oppty: opp)
                    {
                        if(oppty.SBQQ__PrimaryQuote__c!=null){quoteIds.add(oppty.SBQQ__PrimaryQuote__c);
                        }
                    }
                    if(!quoteIds.IsEmpty()){expoBooths = [Select Id, Account__r.Name, Booth_Type__c, Booth_Number__c, Area_Number__c, Unit_Type__c,Dimensions__c,Open_Corners__c,Booth_Product_Type__c,Opportunity__c, Opportunity__r.Name, Opportunity__r.createdDate, Display_Name__c, Status__c From  
                                      ExpocadBooth__c where status__c='Rented' AND quote__c IN:quoteIds order by Opportunity__r.createdDate];
                    }                                     
                    if(!expoBooths.IsEmpty())
                    {
                        for(ExpocadBooth__c ecb: expoBooths){
                              OppBoothDetailsWrapper bdw=new OppBoothDetailsWrapper();
                              bdw.boothName=ecb.Booth_Number__c;
                              bdw.boothArea = string.valueOf(ecb.Dimensions__c);
                              bdw.BoothType=ecb.Booth_Product_Type__c;
                              bdw.Corners=ecb.Open_Corners__c;
                              bdw.exhibitingAs = ecb.Display_Name__c;
                              bdw.exhibitingAcc = ecb.Account__r.Name;
                              if(eventSet!=null){
                                bdw.boothNameTitle = eventSet.Booth_Name__c;
                                bdw.boothAreaTitle = eventSet.Booth_size__c;
                                bdw.BoothTypeTitle = eventSet.Classification__c;
                                bdw.CornersTitle = eventSet.Open_Sides__c;
                                bdw.exhibitingAsTitle = eventSet.Exhibiting_As__c;
                              }
                              else{
                                bdw.boothNameTitle = 'Booth Name';
                                bdw.boothAreaTitle = 'Booth Area';
                                bdw.BoothTypeTitle = 'Classification';
                                bdw.CornersTitle = 'Open Sides';
                                bdw.exhibitingAsTitle = 'Exhibiting As';
                              }oppBoothWrprLst.add(bdw);
                        }return oppBoothWrprLst;
                    }
                    else {isAccountHome = false;
                    }
                }
            }return oppBoothWrprLst;
        }
		//purpose for bind Opp booth Detail
        public class OppBoothDetailsWrapper
        {
          public string boothName{get;set;}
          public string boothArea{get;set;}
          public string BoothType{get;set;}
          public decimal Corners{get;set;}
          public string exhibitingAs{get;set;}
          public string boothNameTitle{get;set;}
          public string boothAreaTitle{get;set;}
          public string BoothTypeTitle{get;set;}
          public string CornersTitle{get;set;}
          public string exhibitingAsTitle{get;set;}
          public string exhibitingAcc{get;set;}
        }
}