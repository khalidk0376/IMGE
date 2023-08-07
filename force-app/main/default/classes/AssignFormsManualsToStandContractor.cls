/**
 * Created/Modified By: Girikon(Aishwarya)/Aishwarya
 * Created On:          7/08/2018
 * @description : Handler class which will be called by the trigger trgDeleteServicesMap/ CCEN-193
 * Methods:             AssignFormsManualsToStandContractor
 * Test Class:          AssignFormsManualsToStandContractor_Test(76%)
 * Last Modified By :   Girikon[Aishwarya CCEN-570, CCEN-623 March 20 2019, Aishwarya CCEN-735/738 April 1 2019]
**/

public without sharing class AssignFormsManualsToStandContractor
{
    public Set<String> setUTypeAndEEForm = new Set<String>();  
     // Method AssignFormsManualsToStandContractor Start
    // Method name changed by Palla Kishore for the ticket BK-19606 
     public void assignFormsManualsToStandContractorMethod(List<BoothContractorMapping__c> listBoothContractMapping)
     {
           List<BoothContractorMapping__c> listBoothContrcatMap = New List<BoothContractorMapping__c>();
           Set<String> eventEditionIds = new Set<String>();
           Set<String> eventEditionFormIds=new Set<String>();
           List<User_Form_Action__c> ufaList = new List<User_Form_Action__c>();
           List<Forms_Permission__c > listFormPermissionToInsert = new List<Forms_Permission__c >();
           List<Event_Edition_Form__c> eefList = new List<Event_Edition_Form__c>(); 
           List<Event_Edition_Form__c> listBlankExpoFormId = new List<Event_Edition_Form__c>();
           List<Manual__c> listBlankExpoManualId = new List<Manual__c>();
           List<Forms_Permission__c> listFP = new List<Forms_Permission__c>();
           
           Set<String> setBoothContrMappingIds = new Set<String>();
           Set<String> setFPIds = new Set<String>();
           List<Forms_Permission__c> listFinalFP = new List<Forms_Permission__c>();
           List<Forms_Permission__c> listFinalFP2 = new List<Forms_Permission__c>();
           Map<string, List<string>> mapFormWithExpoProductType = new Map<string, List<string>>();
           Map<string, List<string>> mapFormWithExpoBoothType = new Map<string, List<string>>();
           
           for(BoothContractorMapping__c bcm: listBoothContractMapping)
           {
               setBoothContrMappingIds.add(bcm.Id);
           }
           if(Schema.sObjectType.BoothContractorMapping__c.isAccessible())
           {
               // CCEN-735/738 - Modified the query corrsponding to expocad changes
               listBoothContrcatMap = [Select Id, ContractorRequestStatus__c, Opp_Booth_Mapping__r.Expocad_Booth__r.Booth_Type__c, Opp_Booth_Mapping__r.Expocad_Booth__r.Matched_Product_Name__c, Contact__c, Contact__r.AccountId, Event_Edition__c FROM BoothContractorMapping__c where Id IN: setBoothContrMappingIds LIMIT 1];
           }
           system.debug('@@@@@@@@@@@@@@@@@List '+listBoothContrcatMap+'SIZE '+listBoothContrcatMap.size());
           for(BoothContractorMapping__c boothConMapping : listBoothContrcatMap)
           {
               eventEditionIds.add(boothConMapping.Event_Edition__c);
           }
           User_Type__c userType = new User_Type__c();
           if(Schema.sObjectType.User_Type__c.isAccessible())
           {
               userType = [select Id, Name from User_Type__c where Name = 'Stand Contractor' LIMIT 1];
           }
           
           system.debug('==================UTYPE '+userType);
           // Forms assignnment Start //CCEN-570
           if(Schema.sObjectType.Event_Edition_Form__c.isAccessible())
           {
               eefList = [Select Id, User_Type__c, Expocad_Booth_Class__c, Expocad_Booth_Type__c, Expocad_Product_Type__c, Event_Edition__c, Event_Edition__r.Name from Event_Edition_Form__c where Event_Edition__c IN: eventEditionIds AND User_Type__c INCLUDES ('Stand Contractor')];
           }
           system.debug('============================'+eefList+'Size '+eefList.size());
           List<String> listExpProductIds = new List<String>();
           List<String> listExpBoothIds = new List<String>();
           
           if(eefList.size()>0)
           {
               for(Event_Edition_Form__c eef :eefList)
               {
                   if((eef.Expocad_Booth_Class__c != null) || (eef.Expocad_Booth_Type__c != null) || (eef.Expocad_Product_Type__c != null))
                   {
                       listBlankExpoFormId.add(eef);
                       eventEditionFormIds.add(eef.id);
                   }
               }
           }
           system.debug('###############'+listBlankExpoFormId +'SIZE:: '+listBlankExpoFormId.size());
           if(listBlankExpoFormId.size()>0)
           {
               eefList.clear();
               for(Event_Edition_Form__c eef : listBlankExpoFormId)
               {
                   eefList.add(eef);
                   eventEditionFormIds.add(eef.id);
               }
           }
           system.debug('============================eefList2'+eefList+'Size2 '+eefList.size());
           if(Schema.sObjectType.Forms_Permission__c.isAccessible())
           {
               listFP = [Select Id, User_Type__c, User_Type__r.Name, Event_Edition_Form__c, Event_Edition_Form__r.Name FROM Forms_Permission__c where User_Type__c != null AND User_Type__r.Name = 'Stand Contractor' AND Event_Edition_Form__r.Event_Edition__c IN:eventEditionIds AND Event_Edition_Form__c IN: eventEditionFormIds];
           }
           system.debug('&&&&&&&&&&&&&&&&'+listFP +'SIZEFP'+listFP.size());
           if(listFP.size()>0)
           {
               for(Forms_Permission__c fp :listFP)
               {
                   setUTypeAndEEForm.add(fp.User_Type__r.Name +''+ fp.Event_Edition_Form__c);
               }
           }
           system.debug('$$$$$$$$$$$$$$$$'+setUTypeAndEEForm);
           
           if(eefList.size()>0)
           {
              for(Event_Edition_Form__c eef : eefList){
                  for(BoothContractorMapping__c bcm : listBoothContrcatMap){
                      system.debug('usertype name::'+userType.Name);
                      system.debug('eeeefffidddd::'+ eef.id);
                      if(!setUTypeAndEEForm.contains(userType.Name +''+ eef.Id))
                      {
                          Forms_Permission__c formPermission = new Forms_Permission__c();
                          FormPermission.Active__c = True;FormPermission.Event_Edition_Form__c = eef.Id;
                          FormPermission.User_Type__c = userType.Id; FormPermission.PreventStandContractForm__c = true;
                          listFormPermissionToInsert.add(formPermission);
                      }
                  }
              }
              if(listFormPermissionToInsert.size()>0 && Schema.sObjectType.Forms_Permission__c.isCreateable())
              {
                  insert listFormPermissionToInsert;
              }   
              
              if(listFP.size()>0)
              {
                  for(Forms_Permission__c fp :listFP)
                  {
                      listFormPermissionToInsert.add(fp);
                  }
              }
              system.debug('===================FP'+listFP+'SIZE::'+listFormPermissionToInsert.size());
              
              for(Forms_Permission__c fp :listFormPermissionToInsert)
              {
                  setFPIds.add(fp.id);
              }
              
              listFinalFP = [Select Id, Event_Edition_Form__r.Expocad_Product_Type__c, Event_Edition_Form__r.Expocad_Booth_Type__c, User_Type__c FROM Forms_Permission__c where Id IN:setFPIds];
              system.debug('---------------------------------LISTFINAL'+listFinalFP +'SIZE'+listFinalFP.size());
              
              if(listFinalFP.size()>0)
              {
                  for(Forms_Permission__c fp: listFinalFP){
                      if( (fp.Event_Edition_Form__r.Expocad_Booth_Type__c != null) || (fp.Event_Edition_Form__r.Expocad_Product_Type__c != null))
                      {
                          listFinalFP2.add(fp);
                      }
                      String productType = '';            
                      if(fp.Event_Edition_Form__r.Expocad_Product_Type__c != null){
                          //CCEN-623 making Comparision of Expocad Product is case insensitive Start
                          productType = fp.Event_Edition_Form__r.Expocad_Product_Type__c.toLowerCase(); 
                          listExpProductIds = productType.split(';');
                          mapFormWithExpoProductType.put(fp.id,listExpProductIds);
                      }
                      system.debug('################'+listExpProductIds+'===SIZE()'+listExpProductIds.size());
                      String boothType ='';            
                      if(fp.Event_Edition_Form__r.Expocad_Booth_Type__c !=null){
                          boothType = fp.Event_Edition_Form__r.Expocad_Booth_Type__c.toLowerCase(); //CCEN-623
                          listExpBoothIds = boothType.split(';');
                          mapFormWithExpoBoothType.put(fp.id,listExpBoothIds);
                      }
                          //CCEN-623 making Comparision of Expocad Product is case insensitive end
                      system.debug('################'+listExpBoothIds);
                  }
              }
              listFinalFP.clear();
              listFinalFP = listFinalFP2;
              List<User_Form_Action__c> listExistingUFA = new List<User_Form_Action__c>();
              if(Schema.sObjectType.User_Form_Action__c.isAccessible())
              {
                  listExistingUFA =[Select Id, Account__c, User_Type__c, Form_Permission__c FROM User_Form_Action__c where Form_Permission__c IN: SetFPIds AND User_Type__r.Name ='Stand Contractor'];
              }
              System.debug('**********************'+listExistingUFA +'SIZE '+listExistingUFA.size());
              
              Set<String> accountAndUserTypeSetUFA = new Set<String>();
              if(listExistingUFA.size()>0)
              {
                  for(User_Form_Action__c ufa: listExistingUFA){
                      accountAndUserTypeSetUFA.add(ufa.Account__c + '' +ufa.User_Type__c + '' +ufa.Form_Permission__c);
                  }
              }
              
              system.debug('^^^^^^^^^^^^^FINALMP '+listFinalFP+'size::'+listFinalFP.size());
              Set<String> setPreventDuplicateUFA = new Set<String>();
              if(listFinalFP.size()>0 && mapFormWithExpoProductType.size()>0)
              {
                  for(integer i=0; i<listFinalFP.size(); i++)
                  {
                      for(BoothContractorMapping__c bcm : listBoothContrcatMap)
                      {
                          if(mapFormWithExpoProductType.containsKey(listFinalFP[i].Id))
                          {
                              for(String str :mapFormWithExpoProductType.get(listFinalFP[i].Id))
                              {
                                  // CCEN-735 add reference of Opp_Booth_Mapping__c 
                                  if( (!accountAndUserTypeSetUFA.contains(bcm.Contact__r.AccountId + '' +userType.Id + '' + listFinalFP[i].Id)) && ((String.isNotBlank(bcm.Opp_Booth_Mapping__r.Expocad_Booth__r.Matched_Product_Name__c) && String.isNotBlank(listFinalFP[i].Event_Edition_Form__r.Expocad_Product_Type__c) && str == bcm.Opp_Booth_Mapping__r.Expocad_Booth__r.Matched_Product_Name__c.toLowerCase())) && !setPreventDuplicateUFA.contains(bcm.Contact__r.AccountId+'-'+userType.Id+'-'+listFinalFP[i].Id) )
                                  {
                                      User_Form_Action__c ufa = new User_Form_Action__c();
                                      ufa.User_Form_Contact__c = bcm.Contact__c; ufa.Account__c = bcm.Contact__r.AccountId;
                                      ufa.User_Type__c = userType.Id;ufa.Form_Permission__c = listFinalFP[i].Id; ufa.BoothContractorMapping__c = bcm.id;
                                      if(ufa.Account__c !=null){ ufaList.add(ufa);
                                      }
                                      setPreventDuplicateUFA.add(ufa.Account__c+'-'+ufa.User_Type__c+'-'+ufa.Form_Permission__c);
                                  }
                              }
                          }
                      }
                  }
              }
              system.debug('=============================SET DUP CHECK'+setPreventDuplicateUFA);
              
              if(listFinalFP.size()>0 && mapFormWithExpoBoothType.size()>0)
              {
                  for(integer i=0; i<listFinalFP.size(); i++)
                  {
                      for(BoothContractorMapping__c bcm : listBoothContrcatMap)
                      {
                          if(mapFormWithExpoBoothType.containsKey(listFinalFP[i].Id))
                          {
                              for(String str :mapFormWithExpoBoothType.get(listFinalFP[i].Id))
                              {
                                  // CCEN-735 add reference of Opp_Booth_Mapping__c
                                  if( (!accountAndUserTypeSetUFA.contains(bcm.Contact__r.AccountId + '' +userType.Id + '' + listFinalFP[i].Id)) && ((String.isNotBlank(bcm.Opp_Booth_Mapping__r.Expocad_Booth__r.Booth_Type__c) && String.isNotBlank(listFinalFP[i].Event_Edition_Form__r.Expocad_Booth_Type__c)  && str == bcm.Opp_Booth_Mapping__r.Expocad_Booth__r.Booth_Type__c.toLowerCase())) && !setPreventDuplicateUFA.contains(bcm.Contact__r.AccountId+'-'+userType.Id+'-'+listFinalFP[i].Id) )
                                  {
                                      User_Form_Action__c ufa = new User_Form_Action__c();
                                      ufa.User_Form_Contact__c = bcm.Contact__c;ufa.Account__c = bcm.Contact__r.AccountId;
                                      ufa.User_Type__c = userType.Id;ufa.Form_Permission__c = listFinalFP[i].Id; ufa.BoothContractorMapping__c = bcm.id;
                                      if(ufa.Account__c !=null){ 
                                          ufaList.add(ufa);
                                      }  
                                      setPreventDuplicateUFA.add(ufa.Account__c+'-'+ufa.User_Type__c+'-'+ufa.Form_Permission__c);
                                  }
                              }
                          }
                      }
                  }
              }
              system.debug('&&&&&&&&&&&&&&&&&&&&&UFA '+ufaList+'SIZEUFA '+ufaList.size());
              if(ufaList.size()>0 && Schema.sObjectType.User_Form_Action__c.IsCreateable())
              {
                  insert ufaList;
              }    
          }
          // Forms assignment end
          
          // Manuals assignmnet Start
          List<Manual__c> manualList = new List<Manual__c>();
          Set<String> manualIds=new Set<String>();
          List<Manuals_Permission__c> listManualPermissionToInsert = new List<Manuals_Permission__c>();
          List<Manuals_Permission__c> listMP = new List<Manuals_Permission__c>();
          Set<String> setUTypeAndManual = new Set<String>();
          List<User_Manual_Action__c> umaList = new List<User_Manual_Action__c>();
          List<String> listExpProductIdsManual = new List<String>();
          List<String> listExpBoothIdsManual = new List<String>();
          Set<String> setMPIds = new Set<String>();
          List<Manuals_Permission__c> listFinalMP = new List<Manuals_Permission__c>();
          List<Manuals_Permission__c> listFinalMP2 = new List<Manuals_Permission__c>();
          Map<string, List<string>> mapManualWithExpoProductType = new Map<string, List<string>>();
          Map<string, List<string>> mapManualWithExpoBoothType = new Map<string, List<string>>();
          if(Schema.sObjectType.Manual__c.isAccessible())
          {
              manualList = [Select Id, Expocad_Booth_Class__c, Expocad_Booth_Type__c, Expocad_Product_Type__c, Event_Edition__c from Manual__c where Event_Edition__c IN: eventEditionIds AND User_Type__c INCLUDES ('Stand Contractor')]; //CCEN-570
          }
          system.debug('============================Manual'+manualList+'ManualSize '+manualList.size());
           
          for(Manual__c manual :manualList)
          {
               if((manual.Expocad_Booth_Class__c != null) || (manual.Expocad_Booth_Type__c != null) || (manual.Expocad_Product_Type__c != null))
               {
                   listBlankExpoManualId.add(manual);
                   manualIds.add(manual.id);
               }    
          }
          system.debug('###############listBlankExpoManualId'+listBlankExpoManualId+'listBlankExpoManualId SIZE:: '+listBlankExpoManualId.size());
          if(listBlankExpoManualId.size()>0)
          {
              manualList.clear();
              for(Manual__c manual : listBlankExpoManualId)
              {
                  manualList.add(manual);
                  manualIds.add(manual.id);
              }
           }
           
           if(Schema.sObjectType.Manuals_Permission__c.isAccessible())
           {
               listMP =[Select Id, Manuals__c, Manuals__r.Event_Edition__c, User_Type__c, User_Type__r.Name FROM Manuals_Permission__c where User_Type__c != null AND User_Type__r.Name = 'Stand Contractor' AND Manuals__c IN: manualIds];
           }
           system.debug('####################MP Records '+listMP +'MP Size '+listMP.size());
           
           if(listMP.size()>0){
               for(Manuals_Permission__c mp :listMP){
                   setUTypeAndManual.add(mp.User_Type__r.Name +''+ mp.Manuals__c);
               }
           }
           system.debug('$$$$$$$$$$$$$$$$'+setUTypeAndManual);
           if(manualList.size()>0)
           {
              for(Manual__c manual : manualList){
                  for(BoothContractorMapping__c bcm : listBoothContrcatMap){
                      if((!setUTypeAndManual.contains(userType.Name +''+manual.Id)) )
                      {
                          system.debug('HELLOOOOO');
                          Manuals_Permission__c manualPermission = new Manuals_Permission__c();
                          ManualPermission.Active__c = True;ManualPermission.Manuals__c = Manual.Id;
                          ManualPermission.User_Type__c = userType.Id;ManualPermission.PreventStandContractManual__c = true;
                          listManualPermissionToInsert.add(manualPermission);
                          setUTypeAndManual.add(userType.Name +''+manual.Id);
                      }
                  }
              }
              if(listManualPermissionToInsert.size()>0 && Schema.sObjectType.Manuals_Permission__c.IsCreateable())
              {
                  insert listManualPermissionToInsert; 
              }
              
              if(listMP.size()>0)
              {
                  for(Manuals_Permission__c mp:listMP)
                  {
                      listManualPermissionToInsert.add(mp);
                  }
              }
              for(Manuals_Permission__c mp :listManualPermissionToInsert){
                  setMPIds.add(mp.id);
              }
              listFinalMP = [Select Id, Manuals__c, Manuals__r.Expocad_Product_Type__c, Manuals__r.Expocad_Booth_Type__c, User_Type__c, User_Type__r.Name FROM Manuals_Permission__c where Id IN:SetMPIds];
              if(listFinalMP.size()>0)
              {
                  for(Manuals_Permission__c mp :listFinalMP)
                  {
                      if((mp.Manuals__r.Expocad_Booth_Type__c != null) || (mp.Manuals__r.Expocad_Product_Type__c != null))
                      {
                          listFinalMP2.add(mp);
                      }
                          
                      String productType ='';          
                      if(mp.Manuals__r.Expocad_Product_Type__c != null){ 
                          //CCEN-623 making Comparision of Expocad Product is case insensitive start
                          productType = mp.Manuals__r.Expocad_Product_Type__c.toLowerCase();
                          listExpProductIdsManual = productType.split(';');
                          mapManualWithExpoProductType.put(mp.id,listExpProductIdsManual);
                      }
                      system.debug('^^^^^^^^^^^^^^^^^^^^^^^^'+mapManualWithExpoProductType+'Size'+mapManualWithExpoProductType.size());
                      String boothType ='';          
                      if(mp.Manuals__r.Expocad_Booth_Type__c != null){
                          boothType = mp.Manuals__r.Expocad_Booth_Type__c.toLowerCase();
                          listExpBoothIdsManual = boothType.split(';');
                          mapManualWithExpoBoothType.put(mp.id,listExpBoothIdsManual);
                      }
                      //CCEN-623 making Comparision of Expocad Product is case insensitive end
                      system.debug('%%%%%%%%%%%%%%%%%%mapManualWithExpoBoothType'+mapManualWithExpoBoothType+'SIZEEE'+mapManualWithExpoBoothType.size());
                  }
              }
              listFinalMP.clear();
              listFinalMP = listFinalMP2;
              List<User_Manual_Action__c> listExistingUMA = new List<User_Manual_Action__c>();
              if(Schema.sObjectType.User_Manual_Action__c.isAccessible()){
                  listExistingUMA =[Select Id, Account__c, User_Type__c, Manual_Permission__c FROM User_Manual_Action__c where Manual_Permission__c IN: setMPIds AND User_Type__r.Name ='Stand Contractor'];
              }
              System.debug('**********************'+listExistingUMA +'SIZE '+listExistingUMA.size());
              Set<String> accountAndUserTypeSet = new Set<String>();
              if(listExistingUMA.size()>0)
              {
                  for(User_Manual_Action__c uma: listExistingUMA)
                  {
                      accountAndUserTypeSet.add(uma.Account__c + '' +uma.User_Type__c + '' +uma.Manual_Permission__c);
                  }
              }
              
              Set<String> setPreventDuplicateUMA = new Set<String>();
              if(listFinalMP.size()>0 && mapManualWithExpoProductType.size()>0)
              {
                  for(integer i=0; i<listFinalMP.size(); i++)
                  {
                      for(BoothContractorMapping__c bcm : listBoothContrcatMap)
                      {
                          if(mapManualWithExpoProductType.containsKey(listFinalMP[i].Id))
                          {
                              for(String str :mapManualWithExpoProductType.get(listFinalMP[i].Id))
                              {
                                  // CCEN-738 add reference of Opp_Booth_Mapping__c
                                  if( (!accountAndUserTypeSet.contains(bcm.Contact__r.AccountId + '' +userType.Id + '' + listFinalMP[i].Id)) && ((String.isNotBlank(bcm.Opp_Booth_Mapping__r.Expocad_Booth__r.Matched_Product_Name__c) && String.isNotBlank(listFinalMP[i].Manuals__r.Expocad_Product_Type__c)  && str == bcm.Opp_Booth_Mapping__r.Expocad_Booth__r.Matched_Product_Name__c.toLowerCase())) && !setPreventDuplicateUMA.contains(bcm.Contact__r.AccountId+'-'+userType.Id+'-'+listFinalMP[i].Id) )
                                  {
                                      User_Manual_Action__c uma = new User_Manual_Action__c();
                                      uma.User_Manual_Contact__c = bcm.Contact__c;uma.Account__c = bcm.Contact__r.AccountId; uma.User_Type__c = userType.Id;
                                      uma.Manual_Permission__c = listFinalMP[i].Id;uma.BoothContractorMapping__c = bcm.id;
                                      if(uma.Account__c != null){ umaList.add(uma);
                                      }
                                      setPreventDuplicateUMA.add(uma.Account__c+'-'+uma.User_Type__c+'-'+uma.Manual_Permission__c);
                                  }
                              }
                          }
                      }
                  }
              }
              system.debug('=============================SET DUP CHECK'+setPreventDuplicateUMA);
              
              if(listFinalMP.size()>0 && mapManualWithExpoBoothType.size()>0)
              {
                  for(integer i=0; i<listFinalMP.size(); i++)
                  {
                      for(BoothContractorMapping__c bcm : listBoothContrcatMap)
                      {
                          if(mapManualWithExpoBoothType.containsKey(listFinalMP[i].Id))
                          {
                              for(String str :mapManualWithExpoBoothType.get(listFinalMP[i].Id))
                              {
                                  // CCEN-738 add reference of Opp_Booth_Mapping__c
                                  if( (!accountAndUserTypeSet.contains(bcm.Contact__r.AccountId + '' +userType.Id + '' + listFinalMP[i].Id)) && ((String.isNotBlank(bcm.Opp_Booth_Mapping__r.Expocad_Booth__r.Booth_Type__c) && String.isNotBlank(listFinalMP[i].Manuals__r.Expocad_Booth_Type__c)  && str == bcm.Opp_Booth_Mapping__r.Expocad_Booth__r.Booth_Type__c.toLowerCase())) && !setPreventDuplicateUMA.contains(bcm.Contact__r.AccountId+'-'+userType.Id+'-'+listFinalMP[i].Id) )
                                  {
                                      User_Manual_Action__c uma = new User_Manual_Action__c();
                                      uma.User_Manual_Contact__c = bcm.Contact__c;uma.Account__c = bcm.Contact__r.AccountId;
                                      uma.User_Type__c = userType.Id;uma.Manual_Permission__c = listFinalMP[i].Id; uma.BoothContractorMapping__c = bcm.id;
                                      if(uma.Account__c != null){umaList.add(uma);
                                      }
                                      setPreventDuplicateUMA.add(uma.Account__c+'-'+uma.User_Type__c+'-'+uma.Manual_Permission__c);
                                  }
                              }
                          }
                      }
                  }
              }
              system.debug('&&&&&&&&&&&&&&&&&&&&&UMASContract '+umaList+'SIZEUMA '+umaList.size());
              if(umaList.size()>0 && Schema.sObjectType.User_Manual_Action__c.IsCreateable())
              {
                  insert umaList;
              }
          }// Manuals assignment End
     }
}