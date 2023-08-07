/**
* File:             BoothSelectionCtrl_Helper.cls
* Project:          GAP
* Date:             May 15, 2019
* Test Class Name:  BoothSelectionCtrl_Test
* Created By:       Avinash Shukla
* @description      Helper class, to remove excessive class length violations.
*/
public with sharing class BoothSelectionCtrl_Helper {
	public BoothSelectionCtrl_Helper() {
           system.debug('Constructor Being Called');//Added by Palla Kishore for the ticket BK-19604
	}

	/**
	 * Designed to get Product Name using BoothType, ShowInShow, BoothClasses (values returned by Expocad booth detail) and Event's Product Type.
	 * @param  oEB                 [Expocad Booth Ref]
	 * @param  oOpportunity        [Opportunity  Ref]
	 * @param  boothPackageProduct [Product package Ref]
	 * @return String              [Product Name]
	 */
	Public Static String sBPrd(Map < Id, SBQQ__ProductOption__c > mapProductOptionsId, ExpocadClasses.Booth oEB, Opportunity oOpportunity, Product2 boothPackageProduct) {
		System.debug('mapProductOptionsId : ' + mapProductOptionsId);
        System.debug('boothPackageProduct : ' + boothPackageProduct);
        System.debug('oEB : ' + oEB);
        System.debug('oOpportunity : ' + oOpportunity);
        String sReturnedPrdName = NULL;
		String sBoothType = NULL;
		String sShowInShow = NULL;
		String sPavilion = NULL;
		String sBoothProductType = NULL;
		List < String > lstBoothClasses = new List < String > ();

		if (!String.isBlank(oEB.BoothType) && !oEB.BoothType.containsIgnoreCase('Corner')) {
			sBoothType = oEB.BoothType;
		}
		if (!String.isBlank(oEB.ShowInShow) && !oEB.ShowInShow.containsIgnoreCase('Corner')) {
			sShowInShow = oEB.ShowInShow;
		}
		if (!String.isBlank(oEB.Pavilion) && !oEB.Pavilion.containsIgnoreCase('Corner')) {
			sPavilion = oEB.Pavilion;
		}
		if (!String.isBlank(oEB.BoothClass) && !oEB.BoothClass.containsIgnoreCase('Corner')) {
			sBoothProductType = oEB.BoothClass;
		}
		if (oEB.BoothClasses != null && !oEB.BoothClasses.isEmpty()) {
			for (String sTemp : oEB.BoothClasses) {
				if (sTemp != 'Standard Booth' && !sTemp.containsIgnoreCase('Corner')) {
					lstBoothClasses.add(sTemp);
				}
			}
		}
        System.debug('sBPrd : sBoothType : ' + sBoothType);
        System.debug('sBPrd : sShowInShow : ' + sShowInShow);
        System.debug('sBPrd : sPavilion : ' + sPavilion);
        System.debug('sBPrd : sBoothProductType : ' + sBoothProductType);
        System.debug('sBPrd : lstBoothClasses : ' + lstBoothClasses);
		If(!String.isBlank(sBoothType) || !String.isBlank(sShowInShow) || !String.isBlank(sPavilion) || !lstBoothClasses.isEmpty() || !String.isBlank(sBoothProductType)) {
			// All Param Included
			If(!String.isBlank(sBoothType) && !String.isBlank(sShowInShow) && !String.isBlank(sPavilion) && !lstBoothClasses.isEmpty() && !String.isBlank(sBoothProductType)) {
				sReturnedPrdName = matchedPrdName(mapProductOptionsId, sBoothType, sShowInShow, sPavilion, lstBoothClasses, sBoothProductType);
			}
			If(String.isBlank(sReturnedPrdName) && (!String.isBlank(sShowInShow) || !String.isBlank(sPavilion) || !String.isBlank(sBoothProductType) || !lstBoothClasses.isEmpty())) {

				If(!String.isBlank(sBoothType) && !String.isBlank(sShowInShow) && !String.isBlank(sPavilion) && !lstBoothClasses.isEmpty()) {
					sReturnedPrdName = matchedPrdName(mapProductOptionsId, sBoothType, sShowInShow, sPavilion, lstBoothClasses, null);
				}
				If(String.isBlank(sReturnedPrdName) && !String.isBlank(sBoothType) && !String.isBlank(sShowInShow) && !String.isBlank(sPavilion) && !String.isBlank(sBoothProductType)) {
					sReturnedPrdName = matchedPrdName(mapProductOptionsId, sBoothType, sShowInShow, sPavilion, null, sBoothProductType);
				}
				If(String.isBlank(sReturnedPrdName) && !String.isBlank(sBoothType) && !String.isBlank(sPavilion) && !lstBoothClasses.isEmpty() && !String.isBlank(sBoothProductType)) {
					sReturnedPrdName = matchedPrdName(mapProductOptionsId, sBoothType, null, sPavilion, lstBoothClasses, sBoothProductType);
				}
				If(String.isBlank(sReturnedPrdName) && !String.isBlank(sBoothType) && !String.isBlank(sPavilion) && !lstBoothClasses.isEmpty()) {
					sReturnedPrdName = matchedPrdName(mapProductOptionsId, sBoothType, null, sPavilion, lstBoothClasses, null);
				}
				If(String.isBlank(sReturnedPrdName) && !String.isBlank(sBoothType) && !String.isBlank(sPavilion) && !String.isBlank(sBoothProductType)) {
					sReturnedPrdName = matchedPrdName(mapProductOptionsId, sBoothType, null, sPavilion, null, sBoothProductType);
				}
				If(String.isBlank(sReturnedPrdName) && !String.isBlank(sBoothType) && !String.isBlank(sShowInShow) && !lstBoothClasses.isEmpty() && !String.isBlank(sBoothProductType)) {
					sReturnedPrdName = matchedPrdName(mapProductOptionsId, sBoothType, sShowInShow, null, lstBoothClasses, sBoothProductType);
				}
				If(String.isBlank(sReturnedPrdName) && !String.isBlank(sBoothType) && !String.isBlank(sShowInShow) && !lstBoothClasses.isEmpty()) {
					sReturnedPrdName = matchedPrdName(mapProductOptionsId, sBoothType, sShowInShow, null, lstBoothClasses, null);
				}
				If(String.isBlank(sReturnedPrdName) && !String.isBlank(sBoothType) && !String.isBlank(sShowInShow) && !String.isBlank(sBoothProductType)) {
					sReturnedPrdName = matchedPrdName(mapProductOptionsId, sBoothType, sShowInShow, null, null, sBoothProductType);
				}
				If(String.isBlank(sReturnedPrdName) && !String.isBlank(sShowInShow) && !String.isBlank(sPavilion) && !lstBoothClasses.isEmpty() && !String.isBlank(sBoothProductType)) {
					sReturnedPrdName = matchedPrdName(mapProductOptionsId, null, sShowInShow, sPavilion, lstBoothClasses, sBoothProductType);
				}
				If(String.isBlank(sReturnedPrdName) && !String.isBlank(sShowInShow) && !String.isBlank(sPavilion) && !lstBoothClasses.isEmpty()) {
					sReturnedPrdName = matchedPrdName(mapProductOptionsId, null, sShowInShow, sPavilion, lstBoothClasses, null);
				}
				If(String.isBlank(sReturnedPrdName) && !String.isBlank(sShowInShow) && !String.isBlank(sPavilion) && !String.isBlank(sBoothProductType)) {
					sReturnedPrdName = matchedPrdName(mapProductOptionsId, null, sShowInShow, sPavilion, null, sBoothProductType);
				}
				If(String.isBlank(sReturnedPrdName) && !String.isBlank(sBoothType) && !lstBoothClasses.isEmpty() && !String.isBlank(sBoothProductType)) {
					sReturnedPrdName = matchedPrdName(mapProductOptionsId, sBoothType, null, null, lstBoothClasses, sBoothProductType);
				}
				If(String.isBlank(sReturnedPrdName) && !String.isBlank(sBoothType) && !lstBoothClasses.isEmpty()) {
					sReturnedPrdName = matchedPrdName(mapProductOptionsId, sBoothType, null, null, lstBoothClasses, null);
				}
				If(String.isBlank(sReturnedPrdName) && !String.isBlank(sBoothType) && !String.isBlank(sBoothProductType)) {
					sReturnedPrdName = matchedPrdName(mapProductOptionsId, sBoothType, null, null, null, sBoothProductType);
				}
				If(String.isBlank(sReturnedPrdName) && !String.isBlank(sPavilion) && !lstBoothClasses.isEmpty() && !String.isBlank(sBoothProductType)) {
					sReturnedPrdName = matchedPrdName(mapProductOptionsId, null, null, sPavilion, lstBoothClasses, sBoothProductType);
				}
				If(String.isBlank(sReturnedPrdName) && !String.isBlank(sPavilion) && !lstBoothClasses.isEmpty()) {
					sReturnedPrdName = matchedPrdName(mapProductOptionsId, null, null, sPavilion, lstBoothClasses, null);
				}
				If(String.isBlank(sReturnedPrdName) && !String.isBlank(sPavilion) && !String.isBlank(sBoothProductType)) {
					sReturnedPrdName = matchedPrdName(mapProductOptionsId, null, null, sPavilion, null, sBoothProductType);
				}
				If(String.isBlank(sReturnedPrdName) && !String.isBlank(sShowInShow) && !lstBoothClasses.isEmpty() && !String.isBlank(sBoothProductType)) {
					sReturnedPrdName = matchedPrdName(mapProductOptionsId, null, sShowInShow, null, lstBoothClasses, sBoothProductType);
				}
				If(String.isBlank(sReturnedPrdName) && !String.isBlank(sShowInShow) && !lstBoothClasses.isEmpty()) {
					sReturnedPrdName = matchedPrdName(mapProductOptionsId, null, sShowInShow, null, lstBoothClasses, null);
				}
				If(String.isBlank(sReturnedPrdName) && !String.isBlank(sShowInShow) && !String.isBlank(sBoothProductType)) {
					sReturnedPrdName = matchedPrdName(mapProductOptionsId, null, sShowInShow, null, null, sBoothProductType);
				}
				If(String.isBlank(sReturnedPrdName) && !String.isBlank(sBoothType)) {
					sReturnedPrdName = matchedPrdName(mapProductOptionsId, sBoothType, null, null, null, null);
				}
				If(String.isBlank(sReturnedPrdName) && !String.isBlank(sPavilion)) {
					sReturnedPrdName = matchedPrdName(mapProductOptionsId, null, null, sPavilion, null, null);
				}
				If(String.isBlank(sReturnedPrdName) && !String.isBlank(sShowInShow)) {
					sReturnedPrdName = matchedPrdName(mapProductOptionsId, null, sShowInShow, null, null, null);
				}
				If(String.isBlank(sReturnedPrdName) && !lstBoothClasses.isEmpty()) {
					sReturnedPrdName = matchedPrdName(mapProductOptionsId, null, null, null, lstBoothClasses, null);
				}
				If(String.isBlank(sReturnedPrdName) && !String.isBlank(sBoothProductType)) {
					sReturnedPrdName = matchedPrdName(mapProductOptionsId, null, null, null, null, sBoothProductType);
				}
			}
		}
        return sReturnedPrdName;
	}

	/**
	 * @description Matching Product with Expocad Booth's Details.
	 * @param  sBoothType        [Booth Type]
	 * @param  sShowInShow       [ShowInShow]
	 * @param  sPavilion         [Pavilion]
	 * @param  lstBoothClasses   [Classe]
	 * @param  sBoothProductType [Event Edition's Product Type]
	 * @return String            [Product Name]
	 */
	public Static String matchedPrdName(Map < Id, SBQQ__ProductOption__c > mapProductOptionsId, String sBoothType, String sShowInShow, String sPavilion, List < String > lstBoothClasses, String sBoothProductType) {
		Set < Boolean > setAllChkd;
		Boolean isContainsOrNot;
		String matchedProductName = NULL;
		for (SBQQ__ProductOption__c oPrdOption : mapProductOptionsId.Values()) {
			setAllChkd = new Set < Boolean > { TRUE };
			System.debug('sBoothType : ' + sBoothType);
            System.debug('sShowInShow : ' + sShowInShow);
            System.debug('sPavilion : ' + sPavilion);
            System.debug('sBoothProductType : ' + sBoothProductType);
            System.debug('lstBoothClasses : ' + lstBoothClasses);
			// Matching Expocad's BoothType From Product's Booth Type Value
			if (!String.isBlank(sBoothType)) {
				isContainsOrNot = containsOrNot(sBoothType, oPrdOption.SBQQ__OptionalSKU__r.Booth_Type__c);
                System.debug('setAllChkd : sBoothType : ' + isContainsOrNot);
				setAllChkd.add(isContainsOrNot);
			}

			// Matching Expocad's ShowInShow From Product's Show In Show Value
			if (!String.isBlank(sShowInShow)) {
				isContainsOrNot = containsOrNot(sShowInShow, oPrdOption.SBQQ__OptionalSKU__r.Show_In_Show__c);
                System.debug('setAllChkd : sShowInShow : ' + isContainsOrNot);
				setAllChkd.add(isContainsOrNot);
			}

			// Matching Expocad's Pavilion From Product's Pavilion Value
			if (!String.isBlank(sPavilion)) {
				isContainsOrNot = containsOrNot(sPavilion, oPrdOption.SBQQ__OptionalSKU__r.Booth_Pavilion__c);
                System.debug('setAllChkd : sShowInShow : ' + isContainsOrNot);
				setAllChkd.add(isContainsOrNot);
			}

			// Matching Selected Event Edition's Product Type From Product's Booth Product Type Value
			if (!String.isBlank(sBoothProductType)) {
				Boolean isContains = FALSE;
				if (!String.isBlank(oPrdOption.SBQQ__OptionalSKU__r.Booth_Product_Type__c) && (oPrdOption.SBQQ__OptionalSKU__r.Booth_Product_Type__c == sBoothProductType)) {
					isContains = TRUE;
				}
                System.debug('setAllChkd : sBoothProductType : ' + isContains);
                setAllChkd.add(isContains);
			}

			// Matching Expocad's BoothClasses From Product's Booth Classes Value
			if (lstBoothClasses != NULL && !lstBoothClasses.isEmpty()) {
				Boolean isContains = FALSE;
				if (!String.isBlank(oPrdOption.SBQQ__OptionalSKU__r.Booth_Class__c)) {
					Set < String > setBoothClasses = new Set < String > (oPrdOption.SBQQ__OptionalSKU__r.Booth_Class__c.split(';'));
					if (setBoothClasses.containsAll(lstBoothClasses)) {
						isContains = TRUE;
					}
				}
                System.debug('setAllChkd : lstBoothClasses : ' + isContains);
				setAllChkd.add(isContains);
			}
			if (setAllChkd.size() == 1) {
				matchedProductName = oPrdOption.SBQQ__OptionalSKU__r.Name;
				break;
			}
		}
        System.debug('setAllChkd : ' + setAllChkd);
        System.debug('matchedProductName : ' + matchedProductName);
		return matchedProductName;
	}

	/**
	 * @description Checking Pick-list Values has a particular values or not
	 * @param  sValueToCompare [PickList Value]
	 * @param  sCompareFrom    [Value which needs to check]
	 * @return Boolean
	 */
	Public Static Boolean containsOrNot(String sValueToCompare, String sCompareFrom) {
		Boolean isContains = FALSE;
		if (!String.isBlank(sCompareFrom)) {
			Set < String > setCompareFrom = new Set < String > (sCompareFrom.split(';'));
			if (setCompareFrom.contains(sValueToCompare)) {
				isContains = TRUE;
			}
		}
		return isContains;
	}
}