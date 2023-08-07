/**
* Project:     Informa Markets
* Date:        Dec, 9 2019
* Created By:  Avinash Shukla
* Test Class:  Opp_Handler_ContactRoles_Test(88%)
* *************************************************************************
* @description This is Handler for Opportunity Trigger. It is used mainly for contactrole creation and updation.
* *************************************************************************
*/
public without sharing class Opp_Handler_ContactRoles {
    /**
     * @description Perform all Operations on Contact Role, Contact Event Edition Mapping, Contact Update, Account Partner.
     * @param oppNewList New Opportunity List
     * @param oppOldList Old Opportunity List
     * @param oppNewMap  New Opportunity Map
     * @param oppOldMap  Old Opportunity Map
     * @param isAfter    Trigger Event
     * @param isBefore   Trigger Event
     * @param isInsert   Trigger Event
     * @param isUpdate   Trigger Event
     */
    public static void contactRolesAutomation(List<opportunity> oppNewList, List<opportunity> oppOldList, Map<Id, Opportunity> oppNewMap, Map<Id, Opportunity> oppOldMap, Boolean isAfter, Boolean isBefore, Boolean isInsert, Boolean isUpdate) {
        if (isAfter) {
            /** Variable Declaration */
            List<OpportunityContactRole> oppConRoles = new List<OpportunityContactRole>() ;
            List<OpportunityContactRole> lstConRoles = new List<OpportunityContactRole>();
            List<Partner> lstPartnerToInsert = new List<Partner>( );
            List<ContactEventEditionMapping__c> lstCEEM1 = new List<ContactEventEditionMapping__c>();
            List<Contact> lstContactToUpdate = new List<Contact>( );
            List<OpportunityContactRole> newContactRoleList = new List<OpportunityContactRole>();
            Map<Id, Set<Id>> mapPartnerAccounts = new Map<Id, Set<Id>>();
            Set<Opportunity> setOppty = new Set<Opportunity>();
            Map<Id, Id> mapOpptyBillingContact  = new Map<Id, Id>();
            Map<Id, set<string>> mapContactType = new Map<Id, set<string>>();
            Set<String> lstTempIds = new Set<String>();
            Map <id, set <id>> mapEeventmapp = new Map<Id, Set<Id>>();
            Set<Id> setOpptyAccountIds = new Set<Id>();
            /** Variable Declaration */
            lstConRoles = [SELECT id, OpportunityId, ContactId, Role FROM OpportunityContactRole where OpportunityId = :oppNewMap.KeySet()];
            for (OpportunityContactRole oCR : lstConRoles) {
                OpportunityContactRole orc = new OpportunityContactRole();
                orc.OpportunityId   = oCR.OpportunityId ;
                orc.ContactId       = oCR.ContactId ;
                orc.Role            = oCR.Role ;
                oppConRoles.add(orc);
            }
            System.debug('OCR LIST ::: ' + lstConRoles);
            for (Opportunity opp : oppNewList) {
                Opportunity oldOpp;
                if (isUpdate) {
                    //Get Old Opp Instance //
                    oldOpp = oppOldMap.get( opp.Id );
                }
                OpportunityContactRole oppc = new OpportunityContactRole();

                if (isUpdate && opp.Exhibitor_Paid_By__c != 'Non-Exhibiting Customer' && opp.EventEdition__c != null && opp.Operations_Contact__c != null && ((opp.StageName == 'Closed Won' && oldOpp.StageName != 'Closed Won' ) || (opp.StageName == 'Closed Won' && (opp.Operations_Contact__c != oldOpp.Operations_Contact__c)))) {
                    lstTempIds.add(opp.EventEdition__c);
                    lstTempIds.add(opp.Operations_Contact__c);
                }
                if ( opp.Opportunity_Contact__c != null ) {
                    mapContactType = updateMap( mapcontactType, opp.Opportunity_Contact__c, 'Primary Contact' );
                    if (isInsert) {
                        newContactRoleList.add(new OpportunityContactRole(ContactId = opp.Opportunity_Contact__c, OpportunityId = opp.Id, Role = 'Primary', IsPrimary = true));
                    } else if (isUpdate && isFieldUpdated(opp, 'Opportunity_Contact__c', oppOldMap)) {
                        oppc.OpportunityId = opp.id ;
                        oppc.ContactId = opp.Opportunity_Contact__c ;
                        oppc.Role = 'Primary';
                        if ( !oppConRoles.contains(oppc) ) {
                            newContactRoleList.add(new OpportunityContactRole(ContactId = opp.Opportunity_Contact__c, OpportunityId = opp.Id, Role = 'Primary', IsPrimary = true));
                        }
                    }
                }
                if ( opp.Nota_Fiscal__c != null ) {
                    //Update Not Fiscal on Contact Object
                    mapContactType = updateMap( mapContactType, opp.Nota_Fiscal__c, 'Nota Fiscal' );
                }
                if ( opp.Operations_Contact__c != null ) {
                    mapContactType = updateMap( mapContactType, opp.Operations_Contact__c, 'Operations Contact' );
                    if (isInsert) {
                        newContactRoleList.add(new OpportunityContactRole(ContactId = opp.Operations_Contact__c, OpportunityId = opp.Id, Role = 'Operation', IsPrimary = false));
                    } else if (isUpdate && isFieldUpdated(opp, 'Operations_Contact__c', oppOldMap)) {
                        oppc = new OpportunityContactRole();
                        oppc.OpportunityId = opp.id ;
                        oppc.ContactId = opp.Operations_Contact__c ;
                        oppc.Role = 'Operation';
                        if ( !oppConRoles.contains(oppc) ) {
                            newContactRoleList.add(new OpportunityContactRole(ContactId = opp.Operations_Contact__c, OpportunityId = opp.Id, Role = 'Operation', IsPrimary = false));
                        }
                    }
                }
                if ( opp.Marketing_Contact__c != null ) {
                    mapContactType = updateMap( mapContactType, opp.Marketing_Contact__c, 'Marketing' );
                    if (isInsert) {
                        newContactRoleList.add(new OpportunityContactRole(ContactId = opp.Marketing_Contact__c, OpportunityId = opp.Id, Role = 'Marketing', IsPrimary = false));
                    } else if (isUpdate && isFieldUpdated(opp, 'Marketing_Contact__c', oppOldMap)) {
                        oppc = new OpportunityContactRole();
                        oppc.OpportunityId = opp.id ;
                        oppc.ContactId = opp.Marketing_Contact__c ;
                        oppc.Role = 'Marketing';
                        if ( !oppConRoles.contains(oppc) ) {
                            newContactRoleList.add(new OpportunityContactRole(ContactId = opp.Marketing_Contact__c, OpportunityId = opp.Id, Role = 'Marketing', IsPrimary = false));
                        }
                    }
                }
                if ( opp.Billing_Contact__c != null ) {
                    mapContactType = updateMap( mapContactType, opp.Billing_Contact__c, 'Invoice Contact' );
                    if (isInsert) {
                        mapOpptyBillingContact.put( opp.Id, opp.Billing_Contact__c );
                        setOpptyAccountIds.add( opp.AccountId );
                        newContactRoleList.add(new OpportunityContactRole(ContactId = opp.Billing_Contact__c, OpportunityId = opp.Id, Role = 'Invoice Contact', IsPrimary = false));
                        if (opp.Partner_Account__c != null) {
                            setOppty.add(opp);
                            setOpptyAccountIds.add(opp.AccountId);
                        }
                    } else if (isUpdate && isFieldUpdated(opp, 'Billing_Contact__c', oppOldMap)) {
                        oppc = new OpportunityContactRole();
                        oppc.OpportunityId = opp.id ;
                        oppc.ContactId = opp.Billing_Contact__c ;
                        oppc.Role = 'Invoice Contact';
                        if ( !oppConRoles.contains(oppc) ) {
                            newContactRoleList.add(new OpportunityContactRole(ContactId = opp.Billing_Contact__c, OpportunityId = opp.Id, Role = 'Invoice Contact', IsPrimary = false));
                        }
                        mapOpptyBillingContact.put(opp.Id, opp.Billing_Contact__c);
                        setOpptyAccountIds.add(opp.AccountId);
                    } else if ( oldOpp.Partner_Account__c != opp.Partner_Account__c && opp.Partner_Account__c != null ) {
                        setOppty.add( opp );
                        setOpptyAccountIds.add( opp.AccountId );
                    }
                }
                if ( opp.Agreement_Contact__c != null ) {
                    mapContactType = updateMap( mapContactType, opp.Agreement_Contact__c, 'Agreement Contact' );
                    if (isInsert) {
                        newContactRoleList.add(new OpportunityContactRole(ContactId = opp.Agreement_Contact__c, OpportunityId = opp.Id, Role = 'Agreement Decision Maker', IsPrimary = false));
                    } else if (isUpdate && isFieldUpdated(opp, 'Agreement_Contact__c', oppOldMap)) {
                        oppc = new OpportunityContactRole();
                        oppc.OpportunityId = opp.id ;
                        oppc.ContactId = opp.Agreement_Contact__c ;
                        oppc.Role = 'Agreement Decision Maker';
                        if ( !oppConRoles.contains(oppc) ) {
                            newContactRoleList.add(new OpportunityContactRole(ContactId = opp.Agreement_Contact__c, OpportunityId = opp.Id, Role = 'Agreement Decision Maker', IsPrimary = false));
                        }
                    }
                }
                if ( opp.Safety_Contact__c != null ) {
                    mapContactType = updateMap( mapContactType, opp.Safety_Contact__c, 'Health and Safety Contact' );
                    if (isInsert) {
                        newContactRoleList.add(new OpportunityContactRole(ContactId = opp.Safety_Contact__c, OpportunityId = opp.Id, Role = 'Safety', IsPrimary = false));
                    } else if (isUpdate && isFieldUpdated(opp, 'Safety_Contact__c', oppOldMap)) {
                        oppc = new OpportunityContactRole();
                        oppc.OpportunityId = opp.id ;
                        oppc.ContactId = opp.Safety_Contact__c ;
                        oppc.Role = 'Safety';
                        if ( !oppConRoles.contains(oppc) ) {
                            newContactRoleList.add(new OpportunityContactRole(ContactId = opp.Safety_Contact__c, OpportunityId = opp.Id, Role = 'Safety', IsPrimary = false));
                        }
                    }
                }
                if ( opp.Stand_Contractor__c != null ) {
                    mapContactType = updateMap( mapContactType, opp.Stand_Contractor__c, 'Stand Contractor' );
                    if (isInsert) {
                        newContactRoleList.add(new OpportunityContactRole(ContactId = opp.Stand_Contractor__c, OpportunityId = opp.Id, Role = 'Stand', IsPrimary = false));
                    } else if (isUpdate && isFieldUpdated(opp, 'Stand_Contractor__c', oppOldMap)) {
                        oppc = new OpportunityContactRole();
                        oppc.OpportunityId = opp.id ;
                        oppc.ContactId = opp.Stand_Contractor__c ;
                        oppc.Role = 'Stand';
                        if ( !oppConRoles.contains(oppc) ) {
                            newContactRoleList.add(new OpportunityContactRole(ContactId = opp.Stand_Contractor__c, OpportunityId = opp.Id, Role = 'Stand', IsPrimary = false));
                        }
                    }
                }
                if ( opp.Operation_Contact_2__c != null ) {
                    mapContactType = updateMap( mapcontactType, opp.Operation_Contact_2__c, 'Operation Contact 2' );
                    if (isInsert) {
                        newContactRoleList.add(new OpportunityContactRole(ContactId = opp.Operation_Contact_2__c, OpportunityId = opp.Id, Role = 'Operation Contact 2', IsPrimary = false));
                    } else if (isUpdate && isFieldUpdated(opp, 'Operation_Contact_2__c', oppOldMap)) {
                        oppc = new OpportunityContactRole();
                        oppc.OpportunityId = opp.id ;
                        oppc.ContactId = opp.Operation_Contact_2__c ;
                        oppc.Role = 'Operation Contact 2';
                        if ( !oppConRoles.contains(oppc) ) {
                            newContactRoleList.add(new OpportunityContactRole(ContactId = opp.Operation_Contact_2__c, OpportunityId = opp.Id, Role = 'Operation Contact 2', IsPrimary = false));
                        }
                    }
                }
                if ( opp.MarkitMkr_Contact__c != null ) {
                    mapContactType = updateMap( mapcontactType, opp.MarkitMkr_Contact__c, 'MarkitMkr' );
                    if (isInsert) {
                        newContactRoleList.add(new OpportunityContactRole(ContactId = opp.MarkitMkr_Contact__c, OpportunityId = opp.Id, Role = 'MarkitMkr', IsPrimary = false));
                    } else if (isUpdate && isFieldUpdated(opp, 'MarkitMkr_Contact__c', oppOldMap)) {
                        oppc = new OpportunityContactRole();
                        oppc.OpportunityId = opp.id ;
                        oppc.ContactId = opp.MarkitMkr_Contact__c ;
                        oppc.Role = 'MarkitMkr';
                        if ( !oppConRoles.contains(oppc) ) {
                            newContactRoleList.add(new OpportunityContactRole(ContactId = opp.MarkitMkr_Contact__c, OpportunityId = opp.Id, Role = 'MarkitMkr', IsPrimary = false));
                        }
                    }
                }
                if ( opp.Local_Representative__c != null ) {
                    mapContactType = updateMap( mapcontactType, opp.Local_Representative__c, 'Local Representative' );
                    if (isInsert) {
                        newContactRoleList.add(new OpportunityContactRole(ContactId = opp.Local_Representative__c, OpportunityId = opp.Id, Role = 'Local Representative', IsPrimary = false));
                    } else if (isUpdate && isFieldUpdated(opp, 'Local_Representative__c', oppOldMap)) {
                        oppc = new OpportunityContactRole();
                        oppc.OpportunityId = opp.id ;
                        oppc.ContactId = opp.Local_Representative__c ;
                        oppc.Role = 'Local Representative';
                        if ( !oppConRoles.contains(oppc) ) {
                            newContactRoleList.add(new OpportunityContactRole(ContactId = opp.Local_Representative__c, OpportunityId = opp.Id, Role = 'Local Representative', IsPrimary = false));
                        }
                    }
                }
                if ( opp.Legal_Representative_1__c != null ) {
                    mapContactType = updateMap( mapcontactType, opp.Legal_Representative_1__c, 'Legal Representative 1' );
                    if (isInsert) {
                        newContactRoleList.add(new OpportunityContactRole(ContactId = opp.Legal_Representative_1__c, OpportunityId = opp.Id, Role = 'Legal Representative 1', IsPrimary = false));
                    } else if (isUpdate && isFieldUpdated(opp, 'Legal_Representative_1__c', oppOldMap)) {
                        oppc = new OpportunityContactRole();
                        oppc.OpportunityId = opp.id ;
                        oppc.ContactId = opp.Legal_Representative_1__c ;
                        oppc.Role = 'Legal Representative 1';
                        if ( !oppConRoles.contains(oppc) ) {
                            newContactRoleList.add(new OpportunityContactRole(ContactId = opp.Legal_Representative_1__c, OpportunityId = opp.Id, Role = 'Legal Representative 1', IsPrimary = false));
                        }
                    }
                }
                if ( opp.Legal_Representative_2__c != null ) {
                    mapContactType = updateMap( mapcontactType, opp.Legal_Representative_2__c, 'Legal Representative 2' );
                    if (isInsert) {
                        newContactRoleList.add(new OpportunityContactRole(ContactId = opp.Legal_Representative_2__c, OpportunityId = opp.Id, Role = 'Legal Representative 2', IsPrimary = false));
                    } else if (isUpdate && isFieldUpdated(opp, 'Legal_Representative_2__c', oppOldMap)) {
                        oppc = new OpportunityContactRole();
                        oppc.OpportunityId = opp.id ;
                        oppc.ContactId = opp.Legal_Representative_2__c ;
                        oppc.Role = 'Legal Representative 2';
                        if ( !oppConRoles.contains(oppc) ) {
                            newContactRoleList.add(new OpportunityContactRole(ContactId = opp.Legal_Representative_2__c, OpportunityId = opp.Id, Role = 'Legal Representative 2', IsPrimary = false));
                        }
                    }
                }
                if ( opp.Witness_Contact__c != null ) {
                    mapContactType = updateMap( mapcontactType, opp.Witness_Contact__c, 'Witness' );
                    if (isInsert) {
                        newContactRoleList.add(new OpportunityContactRole(ContactId = opp.Witness_Contact__c, OpportunityId = opp.Id, Role = 'Witness', IsPrimary = false));
                    } else if (isUpdate && isFieldUpdated(opp, 'Witness_Contact__c', oppOldMap)) {
                        oppc = new OpportunityContactRole();
                        oppc.OpportunityId = opp.id ;
                        oppc.ContactId = opp.Witness_Contact__c ;
                        oppc.Role = 'Witness';
                        if ( !oppConRoles.contains(oppc) ) {
                            newContactRoleList.add(new OpportunityContactRole(ContactId = opp.Witness_Contact__c, OpportunityId = opp.Id, Role = 'Witness', IsPrimary = false));
                        }
                    }
                }
            }

            System.debug('Final Opportunity Contact List to Insert ::: ' + newContactRoleList);

            /** Contact Type Update Iteration */
            if ( !mapContactType.isEmpty( ) ) {
                for ( Contact oTempCon : [SELECT Id, Contact_Type__c FROM Contact WHERE Id IN : mapContactType.KeySet() LIMIT 10000 ] ) {
                    Contact oTempContoAdd = oTempCon ;
                    String sContactype = oTempContoAdd.Contact_Type__c;
                    for ( String sTemp : mapContactType.get( oTempCon.Id ) ) {
                        if ( sContactype == NULL ) { sContactype = sTemp ; }
                        else if ( !sContactype.contains( sTemp ) ) { sContactype += ';' + sTemp ;  System.debug('Picklist values ::::: ' + sContactype );}
                    }
                    if ( !String.isBlank( sContactype ) && sContactype != oTempContoAdd.Contact_Type__c ) {
                        oTempContoAdd.Contact_Type__c = sContactype ;
                        lstContactToUpdate.add(oTempContoAdd);
                    }
                }
            }
            /** Contact Event Edition Mapping Iteation */
            if (!lstTempIds.isEmpty()) {
                User_Type__c oUserType = new User_Type__c();
                if (!test.isRunningTest()) { oUserType = [Select Id, Name from User_Type__c where Name = 'Exhibitor' LIMIT 1]; }
                List<ContactEventEditionMapping__c> lstCEEMToProcess = new List<ContactEventEditionMapping__c>();
                lstCEEMToProcess = [SELECT SFEventEditionID__c, SFContactID__c  FROM ContactEventEditionMapping__c WHERE  SFEventEditionID__c IN : lstTempIds AND SFContactID__c IN : lstTempIds];
                for (ContactEventEditionMapping__c oCEM : lstCEEMToProcess) {
                    if (mapEeventmapp.containsKey(oCEM.SFEventEditionID__c)) {
                        mapEeventmapp.get(oCEM.SFEventEditionID__c).add(oCEM.SFContactID__c);
                    } else {
                        set < id > sContact = new set < id > ();
                        sContact.add(oCEM.SFContactID__c);
                        mapEeventmapp.put(oCEM.SFEventEditionID__c, sContact);
                    }
                }

                ContactEventEditionMapping__c  oCEEM ;
                for (Opportunity opp1 : oppNewList ) {
                    if (!mapEeventmapp.containsKey(opp1.EventEdition__c) || (mapEeventmapp.containsKey(opp1.EventEdition__c) && !mapEeventmapp.get(opp1.EventEdition__c).contains(opp1.Operations_Contact__c))) {
                        oCEEM = new ContactEventEditionMapping__c();
                        oCEEM.SFEventEditionID__c = opp1.EventEdition__c;
                        oCEEM.SFContactID__c = opp1.Operations_Contact__c;
                        oCEEM.Status__c = true;
                        //add user type in contact mapping object.
                        if (opp1.User_Type__c != null) { oCEEM.User_Type__c = opp1.User_Type__c;
                        } else if (oUserType != null) { oCEEM.User_Type__c = oUserType.Id;
                        }

                        lstCEEM1.add(oCEEM);
                        if (mapEeventmapp.containsKey(opp1.EventEdition__c)) { mapEeventmapp.get(opp1.EventEdition__c).add(opp1.Operations_Contact__c);
                        } else {
                            set <id> sContact = new set <id> ();
                            sContact.add(opp1.Operations_Contact__c);
                            mapEeventmapp.put(opp1.accountId, sContact);
                        }
                    }
                }
            }
            /** Get Map Of Account Ids of Opportunity to that of Partner Accounts */
            if ( !setOpptyAccountIds.isEmpty( ) ) {
                list<Partner> lstPartnerToProcess = new list<Partner>();
                lstPartnerToProcess = [ SELECT ID, AccountFromId, AccountToId FROM Partner WHERE AccountFromId IN: setOpptyAccountIds ];
                for ( Partner oTempPartner : lstPartnerToProcess ) {
                    if ( !mapPartnerAccounts.containsKey( oTempPartner.AccountFromId ) ) {
                        Set<Id> setTempAccToHold = new Set<Id>( );
                        setTempAccToHold.add( oTempPartner.AccountToId );
                        mapPartnerAccounts.put( oTempPartner.AccountFromId, setTempAccToHold );
                    } else  { mapPartnerAccounts.get( oTempPartner.AccountFromId ).add( oTempPartner.AccountToId );
                    }
                }
            }
            /** Account partner insertion processing */
            if ( !mapOpptyBillingContact.isEmpty( ) ) {
                Map<Id, Contact> mapBillingContact = new Map<Id, Contact>([SELECT ID, AccountID FROM Contact WHERE Id IN: mapOpptyBillingContact.values() AND AccountID != NULL ]);
                Partner oRefPartner ;
                for ( Opportunity opp : oppNewList ) {
                    if (opp.Billing_Contact__c != null) {
                        if ( mapOpptyBillingContact.containsKey( opp.id ) && opp.AccountId != mapBillingContact.get( opp.Billing_Contact__c ).AccountID ) {
                            if ( !mapPartnerAccounts.containsKey( opp.AccountId ) || ( mapPartnerAccounts.containsKey( opp.AccountId ) && !mapPartnerAccounts.get( opp.AccountId ).contains( mapBillingContact.get( opp.Billing_Contact__c ).AccountID ) ) ) {
                                oRefPartner = new Partner( AccountFromId = opp.AccountId, AccountToId = mapBillingContact.get( opp.Billing_Contact__c ).AccountID, Role = 'Agency' );
                                lstPartnerToInsert.add( oRefPartner );
                                if (!mapPartnerAccounts.containsKey( opp.AccountId ) ) {
                                    Set<Id> setTempAccToHold = new Set<Id>( );
                                    setTempAccToHold.add( mapBillingContact.get( opp.Billing_Contact__c ).AccountID );
                                    mapPartnerAccounts.put( opp.AccountId, setTempAccToHold );
                                } else { mapPartnerAccounts.get(opp.AccountId).add(mapBillingContact.get(opp.Billing_Contact__c).AccountID );
                                }
                            }
                        }
                    }
                }
            } else if ( !setOppty.isEmpty( ) ) {
                for ( Opportunity tempOppty : setOppty ) {
                    if ( !mapPartnerAccounts.containsKey( tempOppty.AccountId ) || ( mapPartnerAccounts.containsKey( tempOppty.AccountId ) && !mapPartnerAccounts.get( tempOppty.AccountId ).contains( tempOppty.Partner_Account__c ) ) ) {
                        if (tempOppty.Partner_Account__c != tempOppty.AccountId) { lstPartnerToInsert.add( new Partner( AccountToId = tempOppty.Partner_Account__c, OpportunityId = tempOppty.id , Role = 'Agency', IsPrimary = true ) );
                        }
                    }
                }

            }


            /** Insert New Contact Roles */
            if ( !newContactRoleList.isEmpty( ) ) { insert newContactRoleList; }
            /** Update Contacts */
            if ( !lstContactToUpdate.isEmpty( ) ) { update lstContactToUpdate ; }
            /** Insert New Contact Event Edition Mapping */
            if ( !lstCEEM1.isEmpty() ) { insert lstCEEM1; }
            /** Insert Account Partner */
            if (!lstPartnerToInsert.isEmpty() ) { insert lstPartnerToInsert; }
        }
    }
    /**
     *
     * @description  mapContactType Method to update the map of Contact and its contactType to be updated after opportunity is inserted or Updated.
     * @param  conId          Contact Id
     * @param  contactType    Contact Type
     * @return                NONE
     */
    public static Map<Id, Set<String>> updateMap( Map<Id, Set<String>> mapContactType, Id conId, String contactType ) {
        if ( mapContactType.containsKey( conId ) ) {
            mapContactType.get( conId ).add( contactType );
        } else {
            Set<String> sContacttype = new Set<String>( );
            sContacttype.add( contactType );
            mapContactType.put( conId, sContacttype );
        }
        return mapContactType;
    }
    /**
     * @description Check if the field is updated
     * @param  opp       Opportunity Instance
     * @param  fieldApi  Field Api Name
     * @param  oldOppMap Old Opportunity Map
     * @return           None
     */
    private static Boolean isFieldUpdated(Opportunity opp, String fieldApi, Map<ID, Opportunity> oldOppMap) {
        Boolean retVal = false;
        if (opp.get(fieldApi) != oldOppMap.get(opp.Id).get(fieldApi)) {
            retVal = true;
        }
        return retVal;
    }
}