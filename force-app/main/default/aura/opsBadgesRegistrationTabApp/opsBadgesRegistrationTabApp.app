<!--
Created By :Rajeev Mishra(Girikon)
Discription :For the Url In badges 	
-->
<aura:application extends="force:slds">
	<aura:attribute name="uType" type="String" default=""/>
    <aura:attribute name="eventId" type="String" default=""/>
    <aura:attribute name="exhAccountID" type="String" default=""/>
    <aura:attribute name="eventCode" type="String" default=""/>
    
    <aura:handler name="init" value="{!this}" action="{!c.doInit}"/>
	<aura:if isTrue="{!v.uType == 'Agent'}">
     <c:createBadgesOpsAgent accountId="{!v.exhAccountID}" eventId="{!v.eventId}" eventCode="{!v.eventCode}" uType="{!v.uType}" />
    <aura:set attribute="else">
      <c:createBadgesOps accountId="{!v.exhAccountID}" eventId="{!v.eventId}" eventCode="{!v.eventCode}" uType="{!v.uType}" />
    </aura:set>
  </aura:if> 
  
</aura:application>