/**
 * @Author      : Sudip Halder
 * @Date        : 02/Nov/2017
 * @Description : This class convert Json response.It is used in 'ConnectCloudHubBatch' class.
 * Test Class   : SapSyncClasses_Test 
 */

public class SapSyncClasses {

    public Header Header;
	public Products[] Products;
	public Results[] Results;
	public Messages[] Messages;
	public class Header {
		public Systems Systems;
	}
	public class Systems {
		public String CallingApplication;
		public String MessageDate;
		public String MessageStatus;
		public String MessageStatusText;
	}
	public class Products {
		public String ProductCode;
	}
	public class Results {
		public String ProductCode;
		public boolean isValid;
        public boolean ProductExists;
	}
	public class Messages {
		public String MessageReference;
		public String MessageSeverity;
		public String MessageType;
		public String MessageID;
		public String MessageText;
	}
    public static SapSyncClasses parse( String json ) {
		return ( SapSyncClasses ) System.JSON.deserialize( json, SapSyncClasses.class );
	}
    
}