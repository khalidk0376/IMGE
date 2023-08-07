<aura:application extends="force:slds">
	<!--opsCustProfCompInfoTabApp Used on :customer list dashboard:-->
    <aura:attribute name="eventCode" type="String" default=""/>
    <aura:attribute name="eventId" type="String" default=""/>
    <aura:attribute name="exhAccountID" type="String" default=""/>
    <aura:attribute name="boothId" type="String" default=""/>
    
    <aura:handler name="init" value="{!this}" action="{!c.doInit}"/>
    
    <c:opsCustomerListCompanyTab  eventcode="{!v.eventCode}" 
                                 eventId="{!v.eventId}" 
                                 accountId="{!v.exhAccountID}" 
                                 boothId="{!v.boothId}" isReadOnly="false"/>
</aura:application>