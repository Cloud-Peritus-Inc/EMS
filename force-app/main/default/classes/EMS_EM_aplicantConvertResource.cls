public class EMS_EM_aplicantConvertResource {
    public static final String APPLICANT_RECORD_TYPE = 'Resource';
    public static final String CONTACT_APPLICANT_RECORD_TYPE_ID = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(APPLICANT_RECORD_TYPE).getRecordTypeId();
    public static final String ONBOARDING_STATUS_APPROVED = 'Approved';
    public static final String ONBOARDING_STATUS_PENDING = 'Pending';
    public static final String ACTIVE_PROBATION = 'Active - Probation';
    
    
    
   /* public static void recordTypeChange(List<contact> contactList,map<id, contact> oldContact){
        RecordType  recordId= [SELECT Id, Name, IsActive FROM RecordType where name ='Resource' and IsActive =true];
        system.debug('RecordType'+ recordId);
        for(contact con: contactList){
            if(con.EMS_EM_JD__c != oldContact.get(con.id).EMS_EM_JD__c){
                con.RecordTypeId = recordId.id;
            }
        }      
    }*/
    public static void sendTheWelcomeMailtoEmployee(List<contact> conList, map<id, contact> oldContact){
        List<Messaging.SingleEmailMessage> mails =  new List<Messaging.SingleEmailMessage>(); 
        List<string>  oficialMailIds = new List<string>(); 
        EmailTemplate emailTemplate =[Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate
                                      where name ='EMS_EM_Welcome_Template'];
        OrgWideEmailAddress emailid = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress where DisplayName ='Cloud Peritus'];
        
        System.debug('emailTemplate'+emailTemplate);
        for(contact conData:conList){
            if( conData.Official_Mail__c != oldContact.get(conData.id).Official_Mail__c && conData.EMS_RM_ApplicantStatus_Update__c == 'Active - Probation'){
                oficialMailIds.add(conData.Official_Mail__c);
                
                System.debug('EMAILID=====>'+conData.Official_Mail__c);
                System.debug('oficialMailIds'+oficialMailIds);
                Messaging.SingleEmailMessage mail =  new Messaging.SingleEmailMessage();
                
                mail.setToAddresses(oficialMailIds);
                mail.setOrgWideEmailAddressId(emailid.Id);
                mail.setTemplateID(emailTemplate.Id);
                mail.setTargetObjectId(conData.id);
                mail.setSaveAsActivity(false);         
                mail.setTreatTargetObjectAsRecipient(false);
                
                System.debug('mail '+mail); 
                mails.add(mail);
                
            }        
        }
        System.debug('mails'+mails);
        Messaging.sendEmail(mails);
    }
    
    @AuraEnabled   
    public static Contact recordTypeChangeByLWC(String Id,Contact newcon){
        map<id, contact> oldContact;
        RecordType  recordId= [SELECT Id, Name, IsActive FROM RecordType where name ='Applicant'and IsActive =true];
        RecordType  recordId2= [SELECT Id, Name, IsActive FROM RecordType where name ='Resource'and IsActive =true];
        
        newcon=[Select Id,LastName,RecordTypeId from Contact where Id=:Id ];
        
        
        newcon.RecordTypeId = recordId2.id;
        update newcon;
        return null;
        
        
    }
    
    public static void createContact(List<EMS_EM_Onboarding_Request__c> onBoardRecordsdlist, Map<Id,EMS_EM_Onboarding_Request__c> onBoardRecordsOldMap){
        Set<Id>  onBoardRecordsIdsSet = new Set<Id>();
        For(EMS_EM_Onboarding_Request__c onboardEachRecord :onBoardRecordsdlist){
            if(onboardEachRecord.Status__c == ONBOARDING_STATUS_APPROVED && onboardEachRecord.Status__c != onBoardRecordsOldMap.get(onboardEachRecord.Id).Status__c){
                onBoardRecordsIdsSet.add(onboardEachRecord.Id); 
            }
        }
        if(onBoardRecordsIdsSet.isEmpty()){
            return;
        }
         Set<Id> onboardingContentDocumentRecordIdsSet = new Set<Id>();
        List<Contact> contactRecordsList = new List<Contact>();
          Map<Id,ems_EM_Additional_Detail__c> emsEMAdditionalDetailMap = new Map<Id,ems_EM_Additional_Detail__c>(); 
                try{
        For(ems_EM_Additional_Detail__c eachAdditionalDetails : [ Select Id,
                                                                 EMS_EM_Education__c,	
                                                                 EMS_EM_Education1__c,	
                                                                 EMS_EM_Education2__c,	
                                                                 EMS_EM_Education3__c,
                                                                 EMS_EM_Education4__c,
                                                                 EMS_EM_Education5__c,
                                                                 EMS_EM_Degree__c,
                                                                 EMS_EM_Degree1__c,
                                                                 EMS_EM_Degree2__c,
                                                                 EMS_EM_Degree3__c,
                                                                 EMS_EM_Degree4__c,
                                                                 EMS_EM_Degree5__c,	
                                                                 EMS_EM_IName__c,
                                                                 EMS_EM_IName1__c,
                                                                 EMS_EM_IName2__c,
                                                                 EMS_EM_IName3__c,
                                                                 EMS_EM_IName4__c,
                                                                 EMS_EM_IName5__c,
                                                                 EMS_EM_Field_of_Study__c,
                                                                 EMS_EM_Field_of_Study1__c,
                                                                 EMS_EM_Field_of_Study2__c,
                                                                 EMS_EM_Field_of_Study3__c,
                                                                 EMS_EM_Field_of_Study4__c,
                                                                 EMS_EM_Field_of_Study5__c,
                                                                 EMS_EM_GDate__c,
                                                                 EMS_EM_GDate1__c,
                                                                 EMS_EM_GDate2__c,
                                                                 EMS_EM_GDate3__c,
                                                                 EMS_EM_GDate4__c,
                                                                 EMS_EM_GDate5__c,
                                                                 EMS_EM_Job_Title__c,
                                                                 EMS_EM_Job_Title1__c,
                                                                 EMS_EM_Job_Title2__c,
                                                                 EMS_EM_Job_Title3__c,
                                                                 EMS_EM_Job_Title4__c,
                                                                 EMS_EM_Job_Title5__c,
                                                                 EMS_EM_Previous_Company_HR_EmailId__c,
                                                                 EMS_EM_Previous_Company_Name__c,
                                                                 EMS_EM_Previous_Company_Name1__c,
                                                                 EMS_EM_Previous_Company_Name2__c,
                                                                 EMS_EM_Previous_Company_Name3__c,
                                                                 EMS_EM_Previous_Company_Name4__c,
                                                                 EMS_EM_Previous_Company_Name5__c,
                                                                 EMS_EM_From_Date__c,
                                                                 EMS_EM_From_Date1__c,
                                                                 EMS_EM_From_Date2__c,
                                                                 EMS_EM_From_Date3__c,
                                                                 EMS_EM_From_Date4__c,
                                                                 EMS_EM_From_Date5__c,
                                                                 EMS_EM_To_Date__c,
                                                                 EMS_EM_To_Date1__c,
                                                                 EMS_EM_To_Date2__c,
                                                                 EMS_EM_To_Date3__c,
                                                                 EMS_EM_To_Date4__c,
                                                                 EMS_EM_To_Date5__c,
                                                                 Onboarding_Request__c,
                                                                 CreatedDate
                                                                 from ems_EM_Additional_Detail__c 
                                                                 Where Onboarding_Request__c IN : onBoardRecordsIdsSet]){
                                                                 emsEMAdditionalDetailMap.put(eachAdditionalDetails.Onboarding_Request__c, eachAdditionalDetails);
                                                                 }
        }Catch(Exception ex){
            System.debug('### Exception Occured With'+ ex.getMessage());
            System.debug('### Exception Occured With'+ ex.getStackTraceString());
        }
        For(EMS_EM_Onboarding_Request__c eachOnboardingRequestRecord : [ Select Id,
                                                                        Name,
                                                                        EMS_EM_First_Name__c,
                                                                        Status__c,
                                                                        EMS_EM_Last_Name__c,
                                                                        EMS_EM_Name__c,
                                                                        EMS_EM_Father__c,EMS_EM_Mother__c,
                                                                        EMS_EM_Gender__c,
                                                                        Phone_Number__c,
                                                                        EMS_EM_Phone_Number__c,
                                                                        EMS_EM_DOB__c,
                                                                        EMS_EM_Mstatus__c,
                                                                        EMS_EM_Spouse__c,
                                                                        EMS_EM_DOW__c,
                                                                        EMS_EM_BG__c,
                                                                        EMS_EM_Personal_Email__c,
                                                                        EMS_EM_AadhaarNo__c,
                                                                        EMS_EM_PanNo__c,	
                                                                        EMS_EM_PassportNo__c,
                                                                        EMS_EM_Nationality__c,	
                                                                        Permanent_Address_Line_1__c,
                                                                        Permanent_Address_Line_2__c,	
                                                                        Current_Address_Line_1__c,	
                                                                        Current_Address_Line_2__c,
                                                                        EMS_EM_CA_State__c,
                                                                        EMS_EM_PA_State__c,	
                                                                        EMS_EM_CA_City__c,	
                                                                        EMS_EM_PA_City__c,	
                                                                        EMS_EM_CA_Zip__c,	
                                                                        EMS_EM_PA_Zip__c,
                                                                        (SELECT LinkedEntityId, Id, ContentDocumentId, Visibility, ShareType FROM ContentDocumentLinks)
                                                                        from EMS_EM_Onboarding_Request__c  where Id =: onBoardRecordsIdsSet
                                                                       ]){
                                                                           Contact contactRecord = new Contact(
                                                                               FirstName = eachOnboardingRequestRecord.EMS_EM_First_Name__c,
                                                                               LastName = eachOnboardingRequestRecord.EMS_EM_Last_Name__c, 
                                                                               RecordTypeId = CONTACT_APPLICANT_RECORD_TYPE_ID,                                          
                                                                               EMS_EM_Father__c = eachOnboardingRequestRecord.EMS_EM_Father__c, 
                                                                               EMS_EM_Mother__c = eachOnboardingRequestRecord.EMS_EM_Mother__c,
                                                                               EMS_EM_Gender__c = eachOnboardingRequestRecord.EMS_EM_Gender__c,
                                                                               EMS_Phone_Number__c = eachOnboardingRequestRecord.Phone_Number__c, 
                                                                               EMS_EM_Alternate_Contact_Number__c = eachOnboardingRequestRecord.EMS_EM_Phone_Number__c, 
                                                                               EMS_EM_DOB__c = eachOnboardingRequestRecord.EMS_EM_DOB__c,
                                                                               EMS_EM_Mstatus__c = eachOnboardingRequestRecord.EMS_EM_Mstatus__c, 
                                                                               EMS_EM_Spouse__c = eachOnboardingRequestRecord.EMS_EM_Spouse__c, 
                                                                               EMS_EM_DOW__c = eachOnboardingRequestRecord.EMS_EM_DOW__c,  
                                                                               EMS_EM_BG__c = eachOnboardingRequestRecord.EMS_EM_BG__c,
                                                                               Personal_Email__c = eachOnboardingRequestRecord.EMS_EM_Personal_Email__c, 
                                                                               EMS_EM_AadhaarNo__c = eachOnboardingRequestRecord.EMS_EM_AadhaarNo__c, 
                                                                               EMS_EM_PanNo__c = eachOnboardingRequestRecord.EMS_EM_PanNo__c,		
                                                                               EMS_EM_PassportNo__c = eachOnboardingRequestRecord.EMS_EM_PassportNo__c,
                                                                               EMS_EM_Nationality__c =	eachOnboardingRequestRecord.EMS_EM_Nationality__c,	
                                                                               EMS_EM_PAddress_Line_1__c = eachOnboardingRequestRecord.Permanent_Address_Line_1__c,
                                                                               EMS_EM_PAddress_Line_2__c = eachOnboardingRequestRecord.Permanent_Address_Line_2__c,
                                                                               EMS_EM_CAddress_Line_1__c = eachOnboardingRequestRecord.Current_Address_Line_1__c,
                                                                               EMS_EM_CAddress_Line_2__c = eachOnboardingRequestRecord.Current_Address_Line_2__c,
                                                                               EMS_EM_CA_State__c =	eachOnboardingRequestRecord.EMS_EM_CA_State__c,
                                                                               EMS_EM_PA_State__c =	eachOnboardingRequestRecord.EMS_EM_PA_State__c,
                                                                               EMS_EM_CA_City__c = eachOnboardingRequestRecord.EMS_EM_CA_City__c,	
                                                                               EMS_EM_PA_City__c = 	eachOnboardingRequestRecord.EMS_EM_PA_City__c,	
                                                                               EMS_EM_CA_Zip__c = eachOnboardingRequestRecord.EMS_EM_CA_Zip__c,	
                                                                               EMS_EM_PA_Zip__c = eachOnboardingRequestRecord.EMS_EM_PA_Zip__c);
                                                                             if(emsEMAdditionalDetailMap.containsKey(eachOnboardingRequestRecord.Id)){
                                                                               contactRecord.EMS_EM_Level_of_Education__c = String.isNotBlank(emsEMAdditionalDetailMap.get(eachOnboardingRequestRecord.Id).EMS_EM_Education__c)  ? emsEMAdditionalDetailMap.get(eachOnboardingRequestRecord.Id).EMS_EM_Education__c  : '';
                                                                               contactRecord.EMS_EM_Level_of_Education1__c = String.isNotBlank(emsEMAdditionalDetailMap.get(eachOnboardingRequestRecord.Id).EMS_EM_Education1__c)  ? emsEMAdditionalDetailMap.get(eachOnboardingRequestRecord.Id).EMS_EM_Education1__c  : '';
                                                                               contactRecord.EMS_EM_Level_of_Education2__c = String.isNotBlank(emsEMAdditionalDetailMap.get(eachOnboardingRequestRecord.Id).EMS_EM_Education2__c)  ? emsEMAdditionalDetailMap.get(eachOnboardingRequestRecord.Id).EMS_EM_Education2__c  : '';
                                                                               contactRecord.EMS_EM_Level_of_Education3__c = String.isNotBlank(emsEMAdditionalDetailMap.get(eachOnboardingRequestRecord.Id).EMS_EM_Education3__c)  ? emsEMAdditionalDetailMap.get(eachOnboardingRequestRecord.Id).EMS_EM_Education3__c  : '';
                                                                               contactRecord.EMS_EM_Level_of_Education4__c = String.isNotBlank(emsEMAdditionalDetailMap.get(eachOnboardingRequestRecord.Id).EMS_EM_Education4__c)  ? emsEMAdditionalDetailMap.get(eachOnboardingRequestRecord.Id).EMS_EM_Education4__c  : '';
                                                                               contactRecord.EMS_EM_Level_of_Education5__c = String.isNotBlank(emsEMAdditionalDetailMap.get(eachOnboardingRequestRecord.Id).EMS_EM_Education5__c)  ? emsEMAdditionalDetailMap.get(eachOnboardingRequestRecord.Id).EMS_EM_Education5__c  : '';
                                                                               contactRecord.EMS_EM_Degree__c =  String.isNotBlank(emsEMAdditionalDetailMap.get(eachOnboardingRequestRecord.Id).EMS_EM_Degree__c)  ? emsEMAdditionalDetailMap.get(eachOnboardingRequestRecord.Id).EMS_EM_Degree__c  : '';	
                                                                               contactRecord.EMS_EM_Degree1__c =  String.isNotBlank(emsEMAdditionalDetailMap.get(eachOnboardingRequestRecord.Id).EMS_EM_Degree1__c)  ? emsEMAdditionalDetailMap.get(eachOnboardingRequestRecord.Id).EMS_EM_Degree1__c  : '';
                                                                               contactRecord.EMS_EM_Degree2__c =  String.isNotBlank(emsEMAdditionalDetailMap.get(eachOnboardingRequestRecord.Id).EMS_EM_Degree2__c)  ? emsEMAdditionalDetailMap.get(eachOnboardingRequestRecord.Id).EMS_EM_Degree2__c  : '';
                                                                               contactRecord.EMS_EM_Degree3__c =  String.isNotBlank(emsEMAdditionalDetailMap.get(eachOnboardingRequestRecord.Id).EMS_EM_Degree3__c)  ? emsEMAdditionalDetailMap.get(eachOnboardingRequestRecord.Id).EMS_EM_Degree3__c  : '';
                                                                               contactRecord.EMS_EM_Degree4__c =  String.isNotBlank(emsEMAdditionalDetailMap.get(eachOnboardingRequestRecord.Id).EMS_EM_Degree4__c)  ? emsEMAdditionalDetailMap.get(eachOnboardingRequestRecord.Id).EMS_EM_Degree4__c  : '';
                                                                               contactRecord.EMS_EM_Degree5__c =  String.isNotBlank(emsEMAdditionalDetailMap.get(eachOnboardingRequestRecord.Id).EMS_EM_Degree5__c)  ? emsEMAdditionalDetailMap.get(eachOnboardingRequestRecord.Id).EMS_EM_Degree5__c  : '';
                                                                               contactRecord.EMS_EM_Field_of_Study__c =  String.isNotBlank(emsEMAdditionalDetailMap.get(eachOnboardingRequestRecord.Id).EMS_EM_Field_of_Study__c)  ? emsEMAdditionalDetailMap.get(eachOnboardingRequestRecord.Id).EMS_EM_Field_of_Study__c  : '';
                                                                               contactRecord.EMS_EM_Field_of_Study1__c =  String.isNotBlank(emsEMAdditionalDetailMap.get(eachOnboardingRequestRecord.Id).EMS_EM_Field_of_Study1__c)  ? emsEMAdditionalDetailMap.get(eachOnboardingRequestRecord.Id).EMS_EM_Field_of_Study1__c  : '';
                                                                               contactRecord.EMS_EM_Field_of_Study2__c =  String.isNotBlank(emsEMAdditionalDetailMap.get(eachOnboardingRequestRecord.Id).EMS_EM_Field_of_Study2__c)  ? emsEMAdditionalDetailMap.get(eachOnboardingRequestRecord.Id).EMS_EM_Field_of_Study__c  : '';
                                                                               contactRecord.EMS_EM_Field_of_Study3__c =  String.isNotBlank(emsEMAdditionalDetailMap.get(eachOnboardingRequestRecord.Id).EMS_EM_Field_of_Study3__c)  ? emsEMAdditionalDetailMap.get(eachOnboardingRequestRecord.Id).EMS_EM_Field_of_Study__c  : '';
                                                                               contactRecord.EMS_EM_Field_of_Study4__c =  String.isNotBlank(emsEMAdditionalDetailMap.get(eachOnboardingRequestRecord.Id).EMS_EM_Field_of_Study4__c)  ? emsEMAdditionalDetailMap.get(eachOnboardingRequestRecord.Id).EMS_EM_Field_of_Study__c  : '';
                                                                               contactRecord.EMS_EM_Field_of_Study5__c =  String.isNotBlank(emsEMAdditionalDetailMap.get(eachOnboardingRequestRecord.Id).EMS_EM_Field_of_Study5__c)  ? emsEMAdditionalDetailMap.get(eachOnboardingRequestRecord.Id).EMS_EM_Field_of_Study__c  : '';
                                                                               contactRecord.EMS_EM_IName__c =  String.isNotBlank(emsEMAdditionalDetailMap.get(eachOnboardingRequestRecord.Id).EMS_EM_IName__c)  ? emsEMAdditionalDetailMap.get(eachOnboardingRequestRecord.Id).EMS_EM_IName__c  : '';
                                                                               contactRecord.EMS_EM_IName1__c =  String.isNotBlank(emsEMAdditionalDetailMap.get(eachOnboardingRequestRecord.Id).EMS_EM_IName1__c)  ? emsEMAdditionalDetailMap.get(eachOnboardingRequestRecord.Id).EMS_EM_IName__c  : '';
                                                                               contactRecord.EMS_EM_IName2__c =  String.isNotBlank(emsEMAdditionalDetailMap.get(eachOnboardingRequestRecord.Id).EMS_EM_IName1__c)  ? emsEMAdditionalDetailMap.get(eachOnboardingRequestRecord.Id).EMS_EM_IName__c  : '';
                                                                               contactRecord.EMS_EM_IName3__c =  String.isNotBlank(emsEMAdditionalDetailMap.get(eachOnboardingRequestRecord.Id).EMS_EM_IName1__c)  ? emsEMAdditionalDetailMap.get(eachOnboardingRequestRecord.Id).EMS_EM_IName__c  : '';
                                                                               contactRecord.EMS_EM_IName4__c =  String.isNotBlank(emsEMAdditionalDetailMap.get(eachOnboardingRequestRecord.Id).EMS_EM_IName1__c)  ? emsEMAdditionalDetailMap.get(eachOnboardingRequestRecord.Id).EMS_EM_IName__c  : '';
                                                                               contactRecord.EMS_EM_IName5__c =  String.isNotBlank(emsEMAdditionalDetailMap.get(eachOnboardingRequestRecord.Id).EMS_EM_IName1__c)  ? emsEMAdditionalDetailMap.get(eachOnboardingRequestRecord.Id).EMS_EM_IName__c  : '';
                                                                               contactRecord.EMS_EM_GDate__c =   emsEMAdditionalDetailMap.get(eachOnboardingRequestRecord.Id).EMS_EM_GDate__c;
                                                                               contactRecord.EMS_EM_GDate1__c =  emsEMAdditionalDetailMap.get(eachOnboardingRequestRecord.Id).EMS_EM_GDate1__c;
                                                                               contactRecord.EMS_EM_GDate2__c =  emsEMAdditionalDetailMap.get(eachOnboardingRequestRecord.Id).EMS_EM_GDate2__c; 
                                                                               contactRecord.EMS_EM_GDate3__c =  emsEMAdditionalDetailMap.get(eachOnboardingRequestRecord.Id).EMS_EM_GDate3__c; 
                                                                               contactRecord.EMS_EM_GDate4__c =  emsEMAdditionalDetailMap.get(eachOnboardingRequestRecord.Id).EMS_EM_GDate4__c; 
                                                                               contactRecord.EMS_EM_GDate5__c =  emsEMAdditionalDetailMap.get(eachOnboardingRequestRecord.Id).EMS_EM_GDate5__c; 
       																		   contactRecord.EMS_EM_Job_Title__c =  String.isNotBlank(emsEMAdditionalDetailMap.get(eachOnboardingRequestRecord.Id).EMS_EM_Job_Title__c)  ? emsEMAdditionalDetailMap.get(eachOnboardingRequestRecord.Id).EMS_EM_Job_Title__c  : '';
        																	   contactRecord.EMS_EM_Job_Title1__c = String.isNotBlank(emsEMAdditionalDetailMap.get(eachOnboardingRequestRecord.Id).EMS_EM_Job_Title1__c) ? emsEMAdditionalDetailMap.get(eachOnboardingRequestRecord.Id).EMS_EM_Job_Title1__c : '';
                                                                               contactRecord.EMS_EM_Job_Title2__c = String.isNotBlank(emsEMAdditionalDetailMap.get(eachOnboardingRequestRecord.Id).EMS_EM_Job_Title2__c) ? emsEMAdditionalDetailMap.get(eachOnboardingRequestRecord.Id).EMS_EM_Job_Title2__c : '';
                                                                               contactRecord.EMS_EM_Job_Title3__c = String.isNotBlank(emsEMAdditionalDetailMap.get(eachOnboardingRequestRecord.Id).EMS_EM_Job_Title3__c) ? emsEMAdditionalDetailMap.get(eachOnboardingRequestRecord.Id).EMS_EM_Job_Title3__c : '';
                                                                               contactRecord.EMS_EM_Job_Title4__c = String.isNotBlank(emsEMAdditionalDetailMap.get(eachOnboardingRequestRecord.Id).EMS_EM_Job_Title4__c) ? emsEMAdditionalDetailMap.get(eachOnboardingRequestRecord.Id).EMS_EM_Job_Title4__c : '';
                                                                               contactRecord.EMS_EM_Job_Title5__c = String.isNotBlank(emsEMAdditionalDetailMap.get(eachOnboardingRequestRecord.Id).EMS_EM_Job_Title5__c) ? emsEMAdditionalDetailMap.get(eachOnboardingRequestRecord.Id).EMS_EM_Job_Title5__c : '';
                                                                               contactRecord.EMS_EM_Previous_Company_HR_EmailId__c =  String.isNotBlank(emsEMAdditionalDetailMap.get(eachOnboardingRequestRecord.Id).EMS_EM_Previous_Company_HR_EmailId__c)  ? emsEMAdditionalDetailMap.get(eachOnboardingRequestRecord.Id).EMS_EM_Previous_Company_HR_EmailId__c  : '';
                                                                               contactRecord.EMS_RM_Previous_Company_Name__c =  String.isNotBlank(emsEMAdditionalDetailMap.get(eachOnboardingRequestRecord.Id).EMS_EM_Previous_Company_Name__c)  ? emsEMAdditionalDetailMap.get(eachOnboardingRequestRecord.Id).EMS_EM_Previous_Company_Name__c  : '';
                                                                               contactRecord.EMS_EM_Previous_Company_Name1__c =  String.isNotBlank(emsEMAdditionalDetailMap.get(eachOnboardingRequestRecord.Id).EMS_EM_Previous_Company_Name1__c)  ? emsEMAdditionalDetailMap.get(eachOnboardingRequestRecord.Id).EMS_EM_Previous_Company_Name1__c  : '';
                                                                               contactRecord.EMS_EM_Previous_Company_Name2__c =  String.isNotBlank(emsEMAdditionalDetailMap.get(eachOnboardingRequestRecord.Id).EMS_EM_Previous_Company_Name2__c)  ? emsEMAdditionalDetailMap.get(eachOnboardingRequestRecord.Id).EMS_EM_Previous_Company_Name2__c  : '';
                                                                               contactRecord.EMS_EM_Previous_Company_Name3__c =  String.isNotBlank(emsEMAdditionalDetailMap.get(eachOnboardingRequestRecord.Id).EMS_EM_Previous_Company_Name3__c)  ? emsEMAdditionalDetailMap.get(eachOnboardingRequestRecord.Id).EMS_EM_Previous_Company_Name3__c  : '';
                                                                               contactRecord.EMS_EM_Previous_Company_Name4__c =  String.isNotBlank(emsEMAdditionalDetailMap.get(eachOnboardingRequestRecord.Id).EMS_EM_Previous_Company_Name4__c)  ? emsEMAdditionalDetailMap.get(eachOnboardingRequestRecord.Id).EMS_EM_Previous_Company_Name4__c  : '';
                                                                               contactRecord.EMS_EM_Previous_Company_Name5__c =  String.isNotBlank(emsEMAdditionalDetailMap.get(eachOnboardingRequestRecord.Id).EMS_EM_Previous_Company_Name5__c)  ? emsEMAdditionalDetailMap.get(eachOnboardingRequestRecord.Id).EMS_EM_Previous_Company_Name5__c  : '';
                                                                               contactRecord.From_Date__c =  emsEMAdditionalDetailMap.get(eachOnboardingRequestRecord.Id).EMS_EM_From_Date__c;
                                                                               contactRecord.EMS_EM_From_Date1__c = emsEMAdditionalDetailMap.get(eachOnboardingRequestRecord.Id).EMS_EM_From_Date1__c;
                                                                               contactRecord.EMS_EM_From_Date2__c = emsEMAdditionalDetailMap.get(eachOnboardingRequestRecord.Id).EMS_EM_From_Date2__c;
                                                                               contactRecord.EMS_EM_From_Date3__c = emsEMAdditionalDetailMap.get(eachOnboardingRequestRecord.Id).EMS_EM_From_Date3__c;
                                                                               contactRecord.EMS_EM_From_Date4__c = emsEMAdditionalDetailMap.get(eachOnboardingRequestRecord.Id).EMS_EM_From_Date4__c;
                                                                               contactRecord.EMS_EM_From_Date5__c = emsEMAdditionalDetailMap.get(eachOnboardingRequestRecord.Id).EMS_EM_From_Date5__c;
                                                                               contactRecord.To_Date__c =  emsEMAdditionalDetailMap.get(eachOnboardingRequestRecord.Id).EMS_EM_To_Date__c;
                                                                               contactRecord.EMS_EM_To_Date1__c = emsEMAdditionalDetailMap.get(eachOnboardingRequestRecord.Id).EMS_EM_To_Date1__c;
                                                                               contactRecord.EMS_EM_To_Date2__c = emsEMAdditionalDetailMap.get(eachOnboardingRequestRecord.Id).EMS_EM_To_Date2__c;
                                                                               contactRecord.EMS_EM_To_Date3__c = emsEMAdditionalDetailMap.get(eachOnboardingRequestRecord.Id).EMS_EM_To_Date3__c;
                                                                               contactRecord.EMS_EM_To_Date4__c = emsEMAdditionalDetailMap.get(eachOnboardingRequestRecord.Id).EMS_EM_To_Date4__c;
                                                                               contactRecord.EMS_EM_To_Date5__c = emsEMAdditionalDetailMap.get(eachOnboardingRequestRecord.Id).EMS_EM_To_Date5__c;
                                                                               //setting Contact Status to "Active-Probation"
                                                                               contactRecord.EMS_RM_ApplicantStatus_Update__c = ACTIVE_PROBATION;
                                                                               contactRecord.EMS_EM_JD__c = system.today();  
                                                                             }
                                                                             contactRecordsList.add(contactRecord);    
                                                                           for(ContentDocumentLink contentDocumentEach : eachOnboardingRequestRecord.ContentDocumentLinks){
                                                                              onboardingContentDocumentRecordIdsSet.add(contentDocumentEach.ContentDocumentId); 
                                                                           }
                                                                       } 
        Insert contactRecordsList;
        Set<Id> contactRecordsSet = new Set<Id>();
        For(Contact con : contactRecordsList){
            contactRecordsSet.add(con.Id);
        }
        Set<Id> additionalDetailsContentDocumentRecordIdsSet = new Set<Id>();
        List<ems_EM_Additional_Detail__c> additionsDetailsList = new List<ems_EM_Additional_Detail__c>();
        try{
            For(ems_EM_Additional_Detail__c eachAdditionalDetails : [ SELECT Id,
                                                                     Onboarding_Request__c,
                                                                     ContactId__c ,
                                                                     (SELECT LinkedEntityId, Id, ContentDocumentId, Visibility, ShareType FROM ContentDocumentLinks)
                                                                     FROM ems_EM_Additional_Detail__c
                                                                     Where Onboarding_Request__c IN : onBoardRecordsIdsSet 
                                                                     AND ContactId__c = null]){
                                                                         For(Id contactId : contactRecordsSet){
                                                                             eachAdditionalDetails.ContactId__c = contactId;
                                                                             additionsDetailsList.add(eachAdditionalDetails);
                                                                         }
                                                                          for(ContentDocumentLink contentDocumentEach : eachAdditionalDetails.ContentDocumentLinks){
                                                                              additionalDetailsContentDocumentRecordIdsSet.add(contentDocumentEach.ContentDocumentId); 
                                                                           }
                                                                         
                                                                     }
            update additionsDetailsList;
            
            Set<Id> allContentDocumetIds = new Set<Id>();
            allContentDocumetIds.addAll(additionalDetailsContentDocumentRecordIdsSet);
            allContentDocumetIds.addAll(onboardingContentDocumentRecordIdsSet);
            if(allContentDocumetIds.isEmpty()){
                return;
            }

            List<ContentDocumentLink> contentDocumentLinkRecordsList = new List<ContentDocumentLink>();
            For(Id contentIds : allContentDocumetIds){
                    ContentDocumentLink cdl = New ContentDocumentLink();
                    cdl.LinkedEntityId = contactRecordsList[0].Id;
                    cdl.ContentDocumentId = contentIds;
                    cdl.shareType = 'V';
                    contentDocumentLinkRecordsList.add(cdl);  
            }
            
            Insert contentDocumentLinkRecordsList;
            
            system.debug('---->additionsDetailsList'+additionsDetailsList);
            system.debug('---->contactRecordsList'+contactRecordsList);
            
        }Catch(Exception ex){
            System.debug('### Exception Occured With'+ ex.getMessage());
            System.debug('### Exception Occured With'+ ex.getStackTraceString());
        }
        
    }
     @AuraEnabled
    public static void approveButton(String recordId){
            List<Contact>conlist=new List<Contact>();
            EMS_EM_Onboarding_Request__c onlist =[Select Id,
                                                  Name,
                                                  Status__c
                                                  from EMS_EM_Onboarding_Request__c
                                                  where Id=:recordId ];
       
          EMS_EM_Onboarding_Request__c onboard =new EMS_EM_Onboarding_Request__c(Id=recordId);
        
           onboard.Status__c='Approved';
           update onboard;
         
          
    }
     @AuraEnabled
    public static void rejectButton(String recordId){
            List<Contact>conlist=new List<Contact>();
            EMS_EM_Onboarding_Request__c onlist =[Select Id,
                                                  Name,
                                                  Status__c
                                                  from EMS_EM_Onboarding_Request__c
                                                  where Id=:recordId ];
       
          EMS_EM_Onboarding_Request__c onboard =new EMS_EM_Onboarding_Request__c(Id=recordId);
        
           onboard.Status__c='Rejected';
           update onboard;
    }
}