<aura:application extends="force:slds">
    <aura:attribute name="recordId" type="String" default=""/>
    <aura:handler name="init" value="{!this}" action="{!c.doInit}"/>
    <aura:if isTrue="{!v.recordId!=''}">
    	<c:pendingContractChatterTab recordId="{!v.recordId}"/>
    </aura:if>
</aura:application>