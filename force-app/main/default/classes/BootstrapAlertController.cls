/**
 * Created By   :   Girikon(Mahesh)[Regarding:-(TES-15)]
 * Created On   :   May 06 2019
 * @description :   [Apex Class to convert standard apex page messages into string lists used in BootStrapAlert component
 to render message in bootstrap styling instead of standard salesforce messages style.]
 * Test Class   :   BootstrapAlertControllerTest
 * Modification Log----- 
 * Modified by  :   
 **/
public with sharing class BootstrapAlertController {
 
  public Boolean hasMessages {
    get{
      return buildMessageLists();
    }
    private set;
  }
 
  // Lists to hold error messages to display in bootstrap alerts
    public List<String> warnMsgs      {get; private set;}
    public List<String> successMsgs      {get; private set;}
    public List<String> infoMsgs      {get; private set;}
    public List<String> errorMsgs    {get; private set;}
 
    // CONSTRUCTOR
  public BootstrapAlertController() {
    setNewMessageLists();
  }
 
  // Instaniates new lists to clear previous error messages
  private void setNewMessageLists(){
    warnMsgs = new List<String>();
    successMsgs = new List<String>();
    infoMsgs = new List<String>();
    errorMsgs = new List<String>();
    }
 
    private Boolean buildMessageLists(){
 
      Boolean hasMessages = false;
 
      // Clear list
      setNewMessageLists();
 
      // Add list of error types to map for ease of assigning values when looping through errors
      Map<String, Set<String>> msgMap = new Map<String, Set<String>>();
      msgMap.put(ApexPages.Severity.CONFIRM.name().toUpperCase(), new Set<String>());
      msgMap.put(ApexPages.Severity.ERROR.name().toUpperCase(), new Set<String>());
      msgMap.put(ApexPages.Severity.FATAL.name().toUpperCase(), new Set<String>());
      msgMap.put(ApexPages.Severity.INFO.name().toUpperCase(), new Set<String>());
      msgMap.put(ApexPages.Severity.WARNING.name().toUpperCase(), new Set<String>());
 
      if(ApexPages.hasMessages()){
 
        hasMessages = true;
 
            System.debug('ApexPages.getMessages()): ' + ApexPages.getMessages());
 
        // Loop through standard apex messages and add them to their respective list
        for(ApexPages.Message msg : ApexPages.getMessages()){
 
                // build up the type of message, as messages are duplicated when a component label is defined.
                String msgStr = '';
                msgStr = (String.isNotBlank(msg.getComponentLabel())) ? msg.getComponentLabel() + ': ' : '';
                msgStr += msg.getSummary();
 
                String msgType = msg.getSeverity().name().toUpperCase();
                 
                // If message has not already been added, add to the set
                if(msg.getSeverity() != null && msgMap.containsKey(msgType)){
              Set<String> msgSet = msgMap.get(msgType);
 
                    if(msgSet != null && !msgSet.contains(msgStr)){
                        msgSet.add(msgStr);
                        msgMap.put(msgType, msgSet);
                    }
                }
        }
      }
        system.debug('ApexPages.Severity.ERROR.name()===='+ApexPages.Severity.ERROR.name());
        // Now assign set values to list
        warnMsgs = new List<String>(msgMap.get(ApexPages.Severity.WARNING.name().toUpperCase()));
        successMsgs = new List<String>(msgMap.get(ApexPages.Severity.CONFIRM.name().toUpperCase()));
        infoMsgs = new List<String>(msgMap.get(ApexPages.Severity.INFO.name().toUpperCase()));
        errorMsgs = new List<String>(msgMap.get(ApexPages.Severity.ERROR.name().toUpperCase()));
        errorMsgs.addAll(msgMap.get(ApexPages.Severity.FATAL.name().toUpperCase()));
 
      return hasMessages;
    }
}