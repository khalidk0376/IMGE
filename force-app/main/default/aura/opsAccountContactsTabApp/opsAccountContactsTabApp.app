<!--
Created By	 : (Mukesh Gupta[STL-216])
Created On	 : 3 Oct, 2019
@description : This component currently not used on Customer List Page. we can remove this component.
Modification log : 
Modified By	: 
-->

<aura:application extends="force:slds">
	<aura:attribute name="uType" type="String" default=""/>
    <aura:attribute name="eventId" type="String" default=""/>
    <aura:attribute name="exhAccountID" type="String" default=""/>
    
    <aura:handler name="init" value="{!this}" action="{!c.doInit}"/>
    
    <c:AccountContacts AccountId="{!v.exhAccountID}" EventId="{!v.eventId}" uType="{!v.uType}" />
</aura:application>