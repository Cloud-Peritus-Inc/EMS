/**
* @author Mukesh Rawat
* @date 30/01/2023
* @description  createContact to Convert Onboarding Records to Resource-Contact Resource
*
*               Test code coverage provided by the following test class:
*               - CP_OnboardingToResourceConvertTest
*
* CHANGE HISTORY
* ====================================================================================================
* DATE          NAME                    DESCRIPTION
* N/A           N/A                     N/A
* ====================================================================================================
**/
public class CP_OnboardingToResourceConvert {
    public static final String APPLICANT_RECORD_TYPE = 'Resource';
    public static final String CONTACT_APPLICANT_RECORD_TYPE_ID = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(APPLICANT_RECORD_TYPE).getRecordTypeId();
    
    @AuraEnabled
    public static List<Contact> createContact(String onBoardRecordsIdsSet){
        Set<Id> onboardingContentDocumentRecordIdsSet = new Set<Id>();
        List<Contact> contactRecordsList = new List<Contact>();
        List<Certifications__c> CertificationsRecordsList = new List<Certifications__c>();
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
                                                                     Where Onboarding_Request__c = : onBoardRecordsIdsSet]){
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
                                                                        Trailblazer_ID_or_Public_URL__c,
                                                                        EMS_EM_Certification_Name10__c,
                                                                        EMS_EM_Certification_Name11__c,
                                                                        EMS_EM_Certification_Name12__c,
                                                                        EMS_EM_Certification_Name13__c,
                                                                        EMS_EM_Certification_Name14__c,
                                                                        EMS_EM_Certification_Name15__c,
                                                                        EMS_EM_Certification_Name16__c,
                                                                        EMS_EM_Certification_Name17__c,
                                                                        EMS_EM_Certification_Name18__c,
                                                                        EMS_EM_Certification_Name19__c,
                                                                        EMS_EM_Certification_Name1__c,
                                                                        EMS_EM_Certification_Name2__c,
                                                                        EMS_EM_Certification_Name3__c,
                                                                        EMS_EM_Certification_Name4__c,
                                                                        EMS_EM_Certification_Name5__c,
                                                                        EMS_EM_Certification_Name6__c,
                                                                        EMS_EM_Certification_Name7__c,
                                                                        EMS_EM_Certification_Name8__c,
                                                                        EMS_EM_Certification_Name9__c,
                                                                        EMS_EM_Certification_Name__c,
                                                                        Completion_Date__c,
                                                                        Completion_Date1__c,
                                                                        Completion_Date2__c,
                                                                        Completion_Date3__c,
                                                                        Completion_Date4__c,
                                                                        Completion_Date5__c,
                                                                        Completion_Date6__c,
                                                                        Completion_Date7__c,
                                                                        Completion_Date8__c,
                                                                        Completion_Date9__c,
                                                                        Completion_Date10__c,
                                                                        Completion_Date11__c,
                                                                        Completion_Date12__c,
                                                                        Completion_Date13__c,
                                                                        Completion_Date14__c,
                                                                        Completion_Date15__c,
                                                                        Completion_Date16__c,
                                                                        Completion_Date17__c,
                                                                        Completion_Date18__c,
                                                                        Completion_Date19__c,
                                                                        ContactId1__c,
                                                                        (SELECT LinkedEntityId, Id, ContentDocumentId, Visibility, ShareType FROM ContentDocumentLinks)
                                                                        from EMS_EM_Onboarding_Request__c  where Id =: onBoardRecordsIdsSet
                                                                       ]){
                                                                           Contact contactRecord = new Contact(
                                                                               Id = eachOnboardingRequestRecord.ContactId1__c,
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
                                                                               
                                                                               contactRecord.EMS_EM_JD__c = system.today();  
                                                                           }
                                                                           contactRecordsList.add(contactRecord); 
                                                                           
                                                                           Certifications__c certificateRecord =New Certifications__c();
                                                                           certificateRecord.Contact__c=eachOnboardingRequestRecord.ContactId1__c;
                                                                           certificateRecord.Trailblazer_ID_or_Public_URL__c = eachOnboardingRequestRecord.Trailblazer_ID_or_Public_URL__c;
                                                                           certificateRecord.EMS_EM_Certification_Name__c =eachOnboardingRequestRecord.EMS_EM_Certification_Name__c;
                                                                           certificateRecord.EMS_EM_Certification_Name1__c = eachOnboardingRequestRecord.EMS_EM_Certification_Name1__c;
                                                                           certificateRecord.EMS_EM_Certification_Name2__c =eachOnboardingRequestRecord.EMS_EM_Certification_Name2__c;
                                                                           certificateRecord.EMS_EM_Certification_Name3__c =eachOnboardingRequestRecord.EMS_EM_Certification_Name3__c;
                                                                           certificateRecord.EMS_EM_Certification_Name4__c = eachOnboardingRequestRecord.EMS_EM_Certification_Name4__c;
                                                                           certificateRecord.EMS_EM_Certification_Name5__c =eachOnboardingRequestRecord.EMS_EM_Certification_Name5__c;
                                                                           certificateRecord.EMS_EM_Certification_Name6__c = eachOnboardingRequestRecord.EMS_EM_Certification_Name6__c;
                                                                           certificateRecord.EMS_EM_Certification_Name7__c = eachOnboardingRequestRecord.EMS_EM_Certification_Name7__c;
                                                                           certificateRecord.EMS_EM_Certification_Name8__c =eachOnboardingRequestRecord.EMS_EM_Certification_Name8__c;
                                                                           certificateRecord.EMS_EM_Certification_Name9__c=eachOnboardingRequestRecord.EMS_EM_Certification_Name9__c;
                                                                           certificateRecord.EMS_EM_Certification_Name10__c = eachOnboardingRequestRecord.EMS_EM_Certification_Name10__c;
                                                                           certificateRecord.EMS_EM_Certification_Name11__c =eachOnboardingRequestRecord.EMS_EM_Certification_Name11__c;
                                                                           certificateRecord.EMS_EM_Certification_Name12__c = eachOnboardingRequestRecord.EMS_EM_Certification_Name12__c;
                                                                           certificateRecord.EMS_EM_Certification_Name13__c =eachOnboardingRequestRecord.EMS_EM_Certification_Name13__c;
                                                                           certificateRecord.EMS_EM_Certification_Name14__c = eachOnboardingRequestRecord.EMS_EM_Certification_Name14__c;
                                                                           certificateRecord.EMS_EM_Certification_Name15__c =eachOnboardingRequestRecord.EMS_EM_Certification_Name15__c;
                                                                           certificateRecord.EMS_EM_Certification_Name16__c = eachOnboardingRequestRecord.EMS_EM_Certification_Name16__c;
                                                                           certificateRecord.EMS_EM_Certification_Name17__c =eachOnboardingRequestRecord.EMS_EM_Certification_Name17__c;
                                                                           certificateRecord.EMS_EM_Certification_Name18__c = eachOnboardingRequestRecord.EMS_EM_Certification_Name18__c;
                                                                           certificateRecord.EMS_EM_Certification_Name19__c =eachOnboardingRequestRecord.EMS_EM_Certification_Name19__c;
                                                                           certificateRecord.Completion_Date__c=eachOnboardingRequestRecord.Completion_Date__c;
                                                                           certificateRecord.Completion_Date1__c=eachOnboardingRequestRecord.Completion_Date1__c;
                                                                           certificateRecord.Completion_Date2__c = eachOnboardingRequestRecord.Completion_Date2__c;
                                                                           certificateRecord.Completion_Date3__c =eachOnboardingRequestRecord.Completion_Date3__c;
                                                                           certificateRecord.Completion_Date4__c=eachOnboardingRequestRecord.Completion_Date4__c;
                                                                           certificateRecord.Completion_Date5__c = eachOnboardingRequestRecord.Completion_Date5__c;
                                                                           certificateRecord.Completion_Date6__c =eachOnboardingRequestRecord.Completion_Date6__c;
                                                                           certificateRecord.Completion_Date7__c=eachOnboardingRequestRecord.Completion_Date7__c;
                                                                           certificateRecord.Completion_Date8__c = eachOnboardingRequestRecord.Completion_Date8__c;
                                                                           certificateRecord.Completion_Date9__c =eachOnboardingRequestRecord.Completion_Date9__c;
                                                                           certificateRecord.Completion_Date10__c=eachOnboardingRequestRecord.Completion_Date10__c;
                                                                           certificateRecord.Completion_Date11__c = eachOnboardingRequestRecord.Completion_Date11__c;
                                                                           certificateRecord.Completion_Date12__c =eachOnboardingRequestRecord.Completion_Date12__c;
                                                                           certificateRecord.Completion_Date13__c=eachOnboardingRequestRecord.Completion_Date13__c;
                                                                           certificateRecord.Completion_Date14__c = eachOnboardingRequestRecord.Completion_Date14__c;
                                                                           certificateRecord.Completion_Date15__c =eachOnboardingRequestRecord.Completion_Date15__c;
                                                                           certificateRecord.Completion_Date16__c=eachOnboardingRequestRecord.Completion_Date16__c;
                                                                           certificateRecord.Completion_Date17__c = eachOnboardingRequestRecord.Completion_Date17__c;
                                                                           certificateRecord.Completion_Date18__c =eachOnboardingRequestRecord.Completion_Date18__c;
                                                                           certificateRecord.Completion_Date19__c=eachOnboardingRequestRecord.Completion_Date19__c;
                                                                           CertificationsRecordsList.add(certificateRecord);
                                                                           
                                                                           for(ContentDocumentLink contentDocumentEach : eachOnboardingRequestRecord.ContentDocumentLinks){
                                                                               onboardingContentDocumentRecordIdsSet.add(contentDocumentEach.ContentDocumentId); 
                                                                           }
                                                                       } 
        Update contactRecordsList;
        Insert CertificationsRecordsList;
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
                                                                     Where Onboarding_Request__c =: onBoardRecordsIdsSet 
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
                return null;
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
        return contactRecordsList;   
    }
}