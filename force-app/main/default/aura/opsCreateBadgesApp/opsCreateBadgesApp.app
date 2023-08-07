<!--
Created By	 : (Mukesh Gupta[STL-216])
Created On	 : 3 Oct, 2019
@description : This app component used to call "createBadgesOpsAgent" and "createBadgesOps" existing components in LWC compoent.
 				This app called from customer list page.
Modification log : 
Modified By	: 
-->

<aura:application  access="GLOBAL" extends="ltng:outApp">
	<aura:attribute name="uType" type="String" default=""/>
    <aura:attribute name="eventId" type="String" default=""/>
    <aura:attribute name="eventCode" type="String" default=""/>
    <aura:attribute name="exhAccountID" type="String" default=""/>
    
    <!--<aura:handler name="init" value="{!this}" action="{!c.doInit}"/>-->
    
    <aura:dependency resource="c:createBadgesOps"/>
    <aura:dependency resource="c:createBadgesOpsAgent"/>
    
    <!--<aura:if isTrue="{!v.uType=='Agent'}">
    	<c:createBadgesOpsAgent accountId="{!v.exhAccountID}" eventId="{!v.eventId}" eventCode="{!v.eventCode}" uType="{!v.uType}" />
        <aura:set attribute="else">
    		<c:createBadgesOps accountId="{!v.exhAccountID}" eventId="{!v.eventId}" eventCode="{!v.eventCode}" uType="{!v.uType}" />    
        </aura:set>
    </aura:if>-->
    
</aura:application>