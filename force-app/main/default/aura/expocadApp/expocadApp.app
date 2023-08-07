<aura:application extends="force:slds">
    <!-- Attributes -->
    <aura:attribute name="eventId" type="String" default=""/>
    <aura:attribute name="eventName" type="String" default=""/>
    <aura:handler name="init" value="{!this}" action="{!c.doInit}"/>
    
    <ltng:require styles="{!$Resource.stl_table}"/>
    <aura:if isTrue="{!v.eventId!=''}">
        <c:crmExpoCadDeckPage recordId="{!v.eventId}"/>
    </aura:if>
    
</aura:application>