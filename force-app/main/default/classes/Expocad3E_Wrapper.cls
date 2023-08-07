/**
* File          :   Expocad3E_Wrapper
* Project       :   3E Integration
* Created Date  :   10th June 2022
* Created By    :   Aradhana(Girikon)
* Test Class    :   
* Coverage      :   
* *******************************************************************************************************
* @description :  [EX-5] wrapper class to parse the JSON payloads of different 3E endpoints
* *******************************************************************************************************
* Modification log :

*/
public class Expocad3E_Wrapper {
    public Expocad3E_Wrapper(){ 
        String isCover = 'YES';
    }
    
    // Constants
    
	//Constant for Expocad Future methods
	public static final String EXPOCAD_BOOTH_HOLD = 'ExpoCAD Booth Hold'; 
	public static final String EXPOCAD_BOOTH_UNHOLD = 'ExpoCAD Booth Unhold'; 
	public static final String EXPOCAD_BOOTH_UNRENT = 'ExpoCAD Booth Unrent'; 
	public static final String EXPOCAD_BOOTH_RENT = 'ExpoCAD Booth Rent'; 
	public static final String EXPOCAD_BOOTH_RENTTOHOLD = 'ExpoCAD Booth RentToHold';
	public static final String EXPOCAD_ADDEXHIBITOR = 'ExpoCAD Add Exhibitor';
    // --- End-- 
	
    public static final String EXPOCAD3E = '3E ExpoCAD';  
    public static final String EXPOCAD = 'ExpoCAD';
    public static final String EXPOCAD_EDGE = 'ExpoCAD Edge';

    public static final String EXPOCAD3E_BOOTH_DETAILS = '3E Expocad Get Booth Details';
    public static final String EXPOCAD3E_BOOTH_FINANCIALS = '3E Expocad Get Booth Financials';
    public static final String EXPOCAD3E_BOOTH_REQITEMS = '3E Expocad Get Booth Request Items';
    public static final String EXPOCAD3E_QUOTE_CALCULATE = '3E Expocad Quote Calculate';
    public static final String EXPOCAD3E_OPP_UPDATE = '3E Expocad Opportunity Update';
    public static final String EXPOCAD3E_EXHIBITOR_INVITE = '3E Expocad Exhibitor Invite';

    public static final String EXPOCAD3E_CONTRACT_PULL = '3E Expocad PDF Contract Pull Request';
    public static final String EXPOCAD3E_CONTRACT_PULL_END = '3E Expocad PDF Contract Pull End Request';
    public static final String EXPOCAD3E_COMPANY_TYPE = '3E Expocad Company Type Setup';
    public static final String EXPOCAD3E_COMPANY_TYPE_ASSIGN = '3E Expocad CompanyType Assign';//EX-21
    public static final String EXPOCAD3E_COMPANY_TYPE_UNASSIGN = '3E Expocad CompanyType Unassign';//EX-21
    
    public static final String GET = 'GET';
    
    public static final String PUT = 'PUT';
    
    public static final String POST = 'POST';
    
    public static final String X3E_ExpoCAD = 'X3E_ExpoCAD';
    
    public static final String OPPORTUNITY = 'Opportunity';
    
     
    public static final String ACCOUNT = 'Account';
    
    public static final String CONTACT = 'Contact';
    
    public static final String OPEN = 'Open';
    
    public static final String COMPLETED = 'Completed';
    
    public static final String BOOTHS_ALL = 'BOOTHS ALL';
      
    public static final String ASYNCHRONOUS = 'Asynchronous';
    
    public static final String OPPORTUNITY_CONTACT_ROLE = 'Opportunity Contact Role';
    
    public static final String PROCESSING = 'Processing';
    
    public static final String SUCCESS = 'Success';
    
    public static final String SYNCHRONOUS = 'Synchronous';
    
    public static final String QUEUED = 'Queued';
    
    public static final String REQUEUE_ALL = 'Requeue All';
    
    public static final String ERROR = 'Error';
    
    public static final String BOOTH_HOLD = 'BOOTH HOLD';
    
    public static final String BOOTH_RENT = 'BOOTH RENT';
    
    public static final String BOOTH_UNHOLD = 'BOOTH UNHOLD';
    
    public static final String BOOTH_UNRENT = 'BOOTH UNRENT';
    
    public static final String BOOTH_HOLDTORENT = 'BOOTH HOLDTORENT';
    
    public static final String BOOTHS_AUDIT = 'BOOTHS AUDIT';
    
    public static final String ACTIVE = 'Active';
    
    public static final String INACTIVE = 'Inactive';
    
    public static final String PAUSED = 'Paused';
    
    public static final String UPDATE_VAR = 'Update';
    
     
    public static final String RENTED = 'Rented';
    
    public static final String ONHOLD = 'On Hold';
    
    public static final String REGISTERED = 'Registered';
    
    public static final String RELEASED = 'Released';
    
    public static final String OBSOLETE = 'Obsolete';
    
    public static final String PURCHASED = 'Purchased';
    
    public static final String RECONCILE = 'RECONCILE';
    
    public static final String INCLUDEALL = 'IncludeAll';
    
    public static final String CLOSED_WON = 'Closed Won';
    
    public static final String CLOSED_LOST = 'Closed Lost';
    
    public static final String COMPLETE = 'Complete';
    
    public static final String COMPLETED_WITH_ERRORS =  'Completed With Errors';
    
    public static final String OPPORTUNITY_OWNER = 'OPPORTUNITY OWNER';
    
    /*********** API Callout Data Sets**********/
    
    public String callOutStatus; // callout Status;
    /**@description Constructor.*/
    public class CalloutErrorDetails{
        
    }
    
    /**@description Response Wrapper Class.*/
    public class WrapperResponse 
    {
        public HttpResponse response;
        public String requestBody;
    }
    
    public class APITokenWrapper {
        public String email;
        public String apiKey;
    }
    
    /**@description InviteExhibitor for 3E Expocad*/
    public class InviteExhibitor
    {
        Public String customerId;	//ZJ-0002
        public String email;	//mohdzuheab@gmail.com
        public String password;
    }
    
    
    /**@description Response InviteExhibitor(3E Expocad)*/
    public class ResponseInviteExhibitor{
        public String message;	//Invitation Emails Queued!
        public String[] errors;
    }
    public class cls_companyTypeList {
        public boolean isDefaultType;
        public String companyType;	//Test1
        public String description;	//Test1
        public Integer typeId;	//2
        public cls_companyListIds[] companyListIds;
        public String unassignedCompanyListIds;
        public String[] views;
        public List<String> showInShows;
    }
    public class cls_companyListIds {
        public String name;	//DK TEST 2
        public String companyId;	//IM-25667
    }
    /**@description CompanyTypes (3E Expocad)*/
    public class CompanyTypes{
        public cls_companyTypeList[] companyTypeList;
        public String[] availableViews;
        public String[] availableSIS;
        
       /* public CompanyTypes(){
            
            //return (fromJSON) System.JSON.deserialize(json, fromJSON.class);
        }*/
        
        
    } 
     /**@description Send Contract Pdf (3E Expocad)*/
    public class SendContractpdf{
        public Blob contractpdf;
    }

    

    public class GetAllBoothsWrapper{
        public String ExhibitorId;	//0012J00002WLrU1QAL
        public String BoothNumber;	//C.B105 Booth_Number__c
        public String Dimensions;	//3m x 3m Dimensions__c
        public String DisplayNameOverride;	//  Display_Name__c
        public String XSize;	//3m
        public String YSize;	//3m
        public String Area;	//9 m² Area__c
        public Decimal NumericArea;	//9
        public String Status;	// Status__c
        //public cls_BoothClasses[] BoothClasses;
		//public cls_ChildExhibitors[] ChildExhibitors;
        public List<String> BoothClasses;
        public List<String>  ChildExhibitors;
        public String Pavilion;	//  Pavilion__c
        public String ShowInShow;	//  ShowInShow__c
        public String BoothType;	//Inline  Booth_Type__c	
        public String UnitType;	//m  Unit_Type__c
        public String HoldExhibitorId;	//
        public String HoldExhibitorName;	//
        public String HoldComment;	//
        public Decimal OpenCorners;	//0  Open_Corners__c
        public boolean IsDeleted;
        public boolean IsOnHold;
        public boolean IsRented;
        /*class cls_BoothClasses {
            
        }
        class cls_ChildExhibitors {
        }
        public  GetAllBoothsWrapper parse(String json){//static
            return (GetAllBoothsWrapper) System.JSON.deserialize(json, GetAllBoothsWrapper.class);
        }*/
    
    }

    public class financialBooth{
        public String BoothNumber;	//C.B105
        public String ExhibitorId;	//0012J00002WLrU1QAL
        public String Invoice;	//1154
        public Decimal BillableArea;	//9
        public Decimal Discount;	//0
        public Decimal DiscountValue;	//0
        public Decimal GrossRate;	//1698
        public Decimal NetRate;	//1698
        public Decimal TotalNonSpace;	//795
        public Decimal TotalDue;	//16077
        public String CommitDate;	//
        public String ReceivedDate;	//
        public String DepositDate;	//
        public String Comment;	//
        public String RatePlan;	//Premium Sustain Concourse
        public String BoothStatus;	//
        public  financialBooth parse(String json){//static
            return (financialBooth) System.JSON.deserialize(json, financialBooth.class);
        }
    }

    public class RelatedItems {
		public String ExhibitorId;	//0012J00002WLrU1QAL
		public String InvoiceNumber;	//1154
		public String BoothNumber;	//C.B105
		public String GlCode;	//Administration Fee
		public String TransactionCode;	//Administration Fee
		public String Description;	//Administration & Registration Fee
		public Decimal UnitCost;	//275
		public Decimal Quantity;	//1
		public Decimal LineTotal;	//275
		public String Date1;	//20220113 //Date is reserved in apex --doubt???????????????????
	}
}