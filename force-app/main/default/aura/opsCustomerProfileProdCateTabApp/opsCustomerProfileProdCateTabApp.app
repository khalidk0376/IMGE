<!--
Created By	 : (Mukesh Gupta[STL-216])
Created On	 : 3 Oct, 2019
@description : This app component used to call "AddCustomerProductCategoryLtng" existing component in LWC compoent.
 				This app called from customer list page.
Modification log : 
Modified By	: 
-->
<aura:application extends="force:slds">
	<!--opsCustomerProfileProdCateTabApp Used on :customer list dashboard:-->
    <aura:attribute name="eventCode" type="String" default=""/>
    <aura:attribute name="eventId" type="String" default=""/>
    <aura:attribute name="exhAccountID" type="String" default=""/>
    <aura:attribute name="boothId" type="String" default=""/>
    
    <aura:handler name="init" value="{!this}" action="{!c.doInit}"/>
    <c:AddCustomerProductCategoryLtngOps eventId="{!v.eventId}" eventcode="{!v.eventCode}"
                                    expoId="{!v.boothId}" AccountId="{!v.exhAccountID}" uId="" ContactId="" />
</aura:application>