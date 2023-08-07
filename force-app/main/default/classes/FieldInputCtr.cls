/**
 * Created/Modified By: Girikon(Mahesh/Divaker)
 * Created On:          26 Apr 2018
 * Description/Purpose: Using in Lightning Component for create input record 
 * Test Class:  FieldInputCtr_Test
 * Code Coverage: 78%
**/
public class FieldInputCtr{
    /**
     * Create question and question questionnaire.
     * @param  qnaireId: Questionnaire id.
     * @param  qGroupId: Question group id.
     * @param  question: Question object values.
     * @param  qnaireName : Questionnaire name.
     * @param  qOrder: Order of question.
     * @param  colNumber: column number of question.
     */
    @AuraEnabled
    public static void createQuestnAndQuestnQnaire(String qnaireId,String qGroupId,Question__c question,String qnaireName,String qOrder,String colNumber){
        try{
            String sQLib = NewCreateTemplateCtr.getDefaultQuestnLibraryId();
            question.Related_To_Column__c = colNumber;
            if(String.isNotBlank(sQLib)){
                question.Question_Library__c = sQLib; 
            }
            qOrder = String.valueOf(FieldInputCtr.countQuestnQuestnnaireRecord(qnaireId, qGroupId));
            question.Name = qOrder;
            insert question;
            Question_Questionnaire__c oQQuesnaire= new Question_Questionnaire__c(Required__c=question.Required__c,
              Allow_Currency__c =question.Allow_Currency__c,Decimal_value__c =question.Decimal_value__c,
              Related_To_Column__c=colNumber,Help_Text__c=question.Help_Text__c,Help_Text_Required__c=question.Help_Text_Required__c,
              Category__c=question.Category__c,Allow_Attachments__c=question.Allow_Attachments__c,Allow_Comment__c=question.Allow_Comment__c,
              Questionnaire__c = qnaireId,Name=qnaireName,Question_Group__c =qGroupId,Question__c=question.id,
              Question_Order__c=Integer.valueOf(qOrder),Is_Allow_Branching__c =question.Is_Allow_Branching__c);
            oQQuesnaire.Max_Char_Length__c=(question.Max_Char_Length__c != null?question.Max_Char_Length__c:0);
            oQQuesnaire.Minimum_Value__c=(question.Minimum_Value__c != null?question.Minimum_Value__c:0);
            oQQuesnaire.Maximum_value__c=(question.Maximum_value__c != null?question.Maximum_value__c:0);
            oQQuesnaire.Step_Size__c=(question.Step_Size__c != null?question.Step_Size__c:0);
            oQQuesnaire.Default_Value__c=(question.Default_Value__c != null?question.Default_Value__c:0);
            if(String.isNotBlank(question.lookup_Object_API_Name__c )){
                oQQuesnaire.lookup_Object_API_Name__c =question.lookup_Object_API_Name__c;
                oQQuesnaire.lookup_Object_Field_Name__c =question.lookup_Object_Field_Name__c;  
            }
            if(String.isNotBlank(question.Currency_Symbol__c)){
                oQQuesnaire.Currency_Symbol__c=question.Currency_Symbol__c;
            }
            insert oQQuesnaire;
            if(question.type__c=='Checkbox'){
               List<Question_Option__c> listQuestnOption = new List<Question_Option__c>();
               Question_Option__c questnOptionChecked = new Question_Option__c(Question__c=question.id,Name='Checked',Name__c='Checked');
               listQuestnOption.add(questnOptionChecked);
               Question_Option__c questnOptionUnchecked = new Question_Option__c(Question__c=question.id,Name='Unchecked',Name__c='Unchecked');
               listQuestnOption.add(questnOptionUnchecked);
               insert listQuestnOption;
            }
        }
        catch(Exception ex){
            throw new AuraHandledException(ex.getMessage());
        } 
    }
     
    /**
     * count Question Questionnaire record.
     * @param  qnaireId : Questionnaire record id
     * @param  qnaireId : Queston Group record id
     */
    public static Integer countQuestnQuestnnaireRecord(String qnaireId,String qGroupId){
        if(Schema.SObjectType.Question_Questionnaire__c.isAccessible()){
            return [Select count() From Question_Questionnaire__c where Questionnaire__c =:qnaireId AND Question_Group__c =:qGroupId];    
        }
        return 0;
    }
    /**
     * save edited Question and Question Questionniare record
     * @param  oQues: Question object values.
     * @param  qnaireId: Questionnaire id.
     * @param  sectionId: Question group(Section) Id.
     */
    @AuraEnabled
    public static void saveEditQuesRecord(Question__c oQues,String qnaireId,String sectionId,Boolean isUnderBranching) {
        if(Schema.SObjectType.Question__c.isUpdateable() && Schema.SObjectType.Question__c.fields.Help_Text__c.isUpdateable())
        if (oQues != null) 
        {
            if(oQues.Help_Text_Required__c==false){
                oQues.Help_Text__c='';
            }
            if(Schema.SObjectType.Question__c.isUpdateable() && Schema.SObjectType.Question__c.Fields.Help_Text__c.isUpdateable()){
              update oQues;
            }
            
            if(Schema.SObjectType.Question_Questionnaire__c.isAccessible() && Schema.SObjectType.Question_Questionnaire__c.Fields.Id.isAccessible() &&
                  Schema.SObjectType.Question_Questionnaire__c.Fields.Questionnaire__c.isAccessible() && Schema.SObjectType.Question_Questionnaire__c.Fields.Question__c.isAccessible()&&
                  Schema.SObjectType.Question_Questionnaire__c.Fields.Question_Group__c.isAccessible() && Schema.SObjectType.Question_Questionnaire__c.Fields.Is_Allow_Branching__c.isAccessible())
            {
              List<Question_Questionnaire__c> lstQQnnaire=[Select Id,Is_Allow_Branching__c from Question_Questionnaire__c where Question__c=:oQues.id and Questionnaire__c=:qnaireId and Question_Group__c=:sectionId];
              if(lstQQnnaire!=null && lstQQnnaire.size()>0)
              {
                  if(Schema.SObjectType.Question_Questionnaire__c.Fields.Allow_Attachments__c.isUpdateable()){
                      lstQQnnaire[0].Allow_Attachments__c=oQues.Allow_Attachments__c;
                  }
                  if(Schema.SObjectType.Question_Questionnaire__c.Fields.Allow_Comment__c.isUpdateable()){
                      lstQQnnaire[0].Allow_Comment__c=oQues.Allow_Comment__c;
                  }
                  if(Schema.SObjectType.Question_Questionnaire__c.Fields.Help_Text_Required__c.isUpdateable()){
                      lstQQnnaire[0].Help_Text_Required__c=oQues.Help_Text_Required__c;
                  }
                  if(Schema.SObjectType.Question_Questionnaire__c.Fields.Help_Text__c.isUpdateable()){
                      lstQQnnaire[0].Help_Text__c='';
                  }
                  if(Schema.SObjectType.Question_Questionnaire__c.Fields.Required__c.isUpdateable()){
                      lstQQnnaire[0].Required__c=oQues.Required__c;
                  }

                  if(oQues.Help_Text_Required__c==true && Schema.SObjectType.Question_Questionnaire__c.Fields.Help_Text__c.isUpdateable()){
                      lstQQnnaire[0].Help_Text__c=oQues.Help_Text__c;
                  }
                  if(String.isNotBlank(oQues.Currency_Symbol__c) && Schema.SObjectType.Question_Questionnaire__c.Fields.Currency_Symbol__c.isUpdateable()){
                      lstQQnnaire[0].Currency_Symbol__c=oQues.Currency_Symbol__c;
                  }
                  if(String.isNotBlank(oQues.lookup_Object_API_Name__c )){
                    if(Schema.SObjectType.Question_Questionnaire__c.Fields.lookup_Object_API_Name__c.isUpdateable()){
                      lstQQnnaire[0].lookup_Object_API_Name__c =oQues.lookup_Object_API_Name__c;
                    }
                    if(Schema.SObjectType.Question_Questionnaire__c.Fields.lookup_Object_Field_Name__c.isUpdateable()){
                      lstQQnnaire[0].lookup_Object_Field_Name__c =oQues.lookup_Object_Field_Name__c;  
                    }
                  }

                  if(Schema.SObjectType.Question_Questionnaire__c.Fields.Is_Allow_Branching__c.isUpdateable()){
                    lstQQnnaire[0].Is_Allow_Branching__c =oQues.Is_Allow_Branching__c;
                  }


                  if(lstQQnnaire[0].Is_Allow_Branching__c==false && oQues.Type__c=='Checkbox' && isUnderBranching ==false){
                      NewCreateTemplateCtr.delQuestnDynLogic(lstQQnnaire[0].id);
                  }
                  if(Schema.SObjectType.Question_Questionnaire__c.Fields.Minimum_Value__c.isUpdateable()){
                  lstQQnnaire[0].Minimum_Value__c=(oQues.Minimum_Value__c != null?oQues.Minimum_Value__c:0);
                  }
                  if(Schema.SObjectType.Question_Questionnaire__c.Fields.Maximum_value__c.isUpdateable()){
                  lstQQnnaire[0].Maximum_value__c=(oQues.Maximum_value__c != null?oQues.Maximum_value__c:0);
                  }
                  if(Schema.SObjectType.Question_Questionnaire__c.Fields.Step_Size__c.isUpdateable()){
                  lstQQnnaire[0].Step_Size__c=(oQues.Step_Size__c != null?oQues.Step_Size__c:0);
                  }
                  if(Schema.SObjectType.Question_Questionnaire__c.Fields.Default_Value__c.isUpdateable()){
                  lstQQnnaire[0].Default_Value__c=(oQues.Default_Value__c != null?oQues.Default_Value__c:0);
                  }
                  if(Schema.SObjectType.Question_Questionnaire__c.Fields.Decimal_value__c.isUpdateable()){
                  lstQQnnaire[0].Decimal_value__c =oQues.Decimal_value__c;
                  }
                  if(Schema.SObjectType.Question_Questionnaire__c.Fields.Allow_Currency__c.isUpdateable()){
                  lstQQnnaire[0].Allow_Currency__c =oQues.Allow_Currency__c;
                  }
                  if(Schema.SObjectType.Question_Questionnaire__c.Fields.Max_Char_Length__c.isUpdateable()){
                  lstQQnnaire[0].Max_Char_Length__c =(oQues.Max_Char_Length__c != null?oQues.Max_Char_Length__c:0);
                  }
                  if(Schema.SObjectType.Question_Questionnaire__c.Fields.Category__c.isUpdateable()){
                  lstQQnnaire[0].Category__c=oQues.Category__c;
                  }
                  if(Schema.SObjectType.Question_Questionnaire__c.isUpdateable()){
                    update lstQQnnaire;
                  }
              }
            }
        } 
    }
    
    /**
     * fetch Question Currency Symbols picklist value
     * @return : list of Question Currency sysmbol.
     */
    @AuraEnabled
    public static List<String> getQueCurrencySymbol(){
        List<String> options = new List<String>();
        Schema.DescribeFieldResult fieldResult = Question__c.Currency_Symbol__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry f: ple) {
            options.add(f.getLabel());
        }
        return options;
    }
    
    /**
     * fetch all sobject name in org.
     * @return : list of sobject name.
     */
    @AuraEnabled
    public static List<ObjectWrapper> getAllsObjectName(){
        List<ObjectWrapper> sObjectList = new List<ObjectWrapper>();        
  		for ( Schema.SObjectType o : Schema.getGlobalDescribe().values() )
        {
            Schema.DescribeSObjectResult objResult = o.getDescribe();
            sObjectList.add(new ObjectWrapper(objResult.getName(),objResult.getLabel()));
        }
        
        /*
        if(Schema.sObjectType.ObjectPermissions.isAccessible() && Schema.sObjectType.ObjectPermissions.Fields.SObjectType.isAccessible())
        {
          AggregateResult[] groupedObjPermResult =[SELECT SObjectType From ObjectPermissions 
                                                  where SObjectType NOT IN('Question__c','Question_Library__c','Question_Option__c','Question_Group__c','Questionnaire__c','Question_Questionnaire__c'
                                                  ,'Questionnaire_Dynamic_Logic__c','Question_Response__c','Questionnaire_Form__c','Questionnaire_Schedule__c','Questionnaire_Schedule_User__c')  Group By SObjectType order by SObjectType ASC ];
          for(AggregateResult arResult : groupedObjPermResult){
             if(arResult.get('SObjectType') != null && Type.forName(String.valueOf(arResult.get('SObjectType'))) != null && ((SObject)Type.forName(String.valueOf(arResult.get('SObjectType'))).newInstance()).getSObjectType() != null)
             {
                  SObjectType objTyp = ((SObject)Type.forName(String.valueOf(arResult.get('SObjectType'))).newInstance()).getSObjectType();
                 // Exclude all the unwanted Sobjects e.g. History, Share etc..
                if(!(objTyp.getDescribe().getName()).containsignorecase('history') && ! (objTyp.getDescribe().getName()).containsignorecase('tag')&&
                  !(objTyp.getDescribe().getName()).containsignorecase('share') && !(objTyp.getDescribe().getName()).containsignorecase('feed') 
                  && objTyp.getDescribe().isAccessible() && objTyp.getDescribe().isQueryable()){
                    sObjectList.add(new ObjectWrapper(objTyp.getDescribe().getName(),objTyp.getDescribe().getLabel()));
                }
             }
          }
        }*/
        return sObjectList;
    }
    /**
     * SelcetOption for Object
     */
    public class ObjectWrapper{
        @AuraEnabled public String apiName{get;set;} 
        @AuraEnabled public String apiLabelName{get;set;} 
        ObjectWrapper(String apiName,String apiLabelName){
            this.apiName =apiName;
            this.apiLabelName =apiLabelName;
        }
    }
     /**
     * fetch all sobject name in org.
     * @return : list of sobject name.
     */
    @AuraEnabled
    public static List<ObjectWrapper> getAllsObjectFieldName(String objectName){
      System.debug('objectName: '+objectName);

        List<ObjectWrapper> sObjectList = new List<ObjectWrapper>();
        SObjectType objToken = ((SObject)Type.forName(objectName).newInstance()).getSObjectType();
        DescribeSObjectResult objDef = objToken.getDescribe();
        Map<String, SObjectField> fields = objDef.fields.getMap();  
        for(String key:fields.keySet())
        {
            Schema.DisplayType fielddataType = fields.get(key).getDescribe().getType();
            if(fielddataType  == Schema.DisplayType.String || fielddataType == Schema.DisplayType.EMAIL || fielddataType == Schema.DisplayType.Picklist){
                SObjectField fieldToken = fields.get(key);
                if(fieldToken.getDescribe().isAccessible() && fieldToken.getDescribe().isUpdateable()){
                    sObjectList.add(new ObjectWrapper(fieldToken.getDescribe().getName(),fieldToken.getDescribe().getLabel()));
                    
                }
            } 
        }
        return  sObjectList;
    }

    @AuraEnabled
    public static String getBaseUrl()
    {
        return URL.getSalesforceBaseUrl().toExternalForm()+'__'+UserInfo.getOrganizationId();
    }
    @AuraEnabled
    public static DocumentWrapper getAllDocuments(Decimal pageNumber){
        DocumentWrapper dwObj = new DocumentWrapper();
        List<Document> uploadedDoc = new List<Document>();        
        Integer pageSize = 25;
        Integer offset = ((Integer)pageNumber - 1) * pageSize;
        dwObj.pageSize = pageSize;
        dwObj.page = (Integer) pageNumber;
        dwObj.total=0;
        if(Schema.sObjectType.Folder.isAccessible() && Schema.sObjectType.Folder.fields.Id.isAccessible() && Schema.sObjectType.Folder.fields.Name.isAccessible()){               
            if(Schema.sObjectType.Folder.isAccessible() && Schema.sObjectType.Folder.fields.Id.isAccessible() && Schema.sObjectType.Folder.fields.Name.isAccessible()){                
                String []docType =new String[]{'png','jpg','jpeg','gif','bmp'};
                dwObj.total=Database.countQuery('Select count() from document where Type IN (\'png\',\'jpg\',\'jpeg\',\'gif\',\'bmp\') AND IsInternalUseOnly=false AND IsPublic=true AND DeveloperName Not IN (\'SMS_Logo\',\'table_icon\',\'template_icon\',\'dashboard_icon\',\'add\')');                    
                uploadedDoc = [Select id,Name from document where Type IN:docType AND IsInternalUseOnly=false AND IsPublic=true ORDER BY CreatedDate DESC LIMIT :dwObj.pageSize OFFSET :offset];
            }            
        }
        dwObj.uploadedDoc = uploadedDoc;
        return dwObj;
    }
    public class DocumentWrapper {
        @AuraEnabled public Integer pageSize {get;set;}
        @AuraEnabled public Integer page {get;set;}
        @AuraEnabled public Integer total {get;set;}
        @AuraEnabled public List<Document> uploadedDoc {get;set;}
    }
}