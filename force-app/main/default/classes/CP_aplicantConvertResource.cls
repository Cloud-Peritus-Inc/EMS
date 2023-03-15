/**
* @author Mukesh Rawat
* @date 2/02/2023
* @description  recordTypeChangeByLWC to Convert Record Type Applicant to Resource on Contact Object
*
*               Test code coverage provided by the following test class:
*               - CP_ConvertButtonOnOnboardingTest     
*
* CHANGE HISTORY
* ====================================================================================================
* DATE          NAME                    DESCRIPTION
* N/A           N/A                     N/A
* ====================================================================================================
**/
public class CP_aplicantConvertResource {
    public static final String APPLICANT_RECORD_TYPE = 'Resource';
    public static final String CONTACT_APPLICANT_RECORD_TYPE_ID = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(APPLICANT_RECORD_TYPE).getRecordTypeId();
    
    @AuraEnabled
    public static List<Contact> recordTypeChangeByLWC(String contactId){
        Set<Id> onboardingContentDocumentRecordIdsSet = new Set<Id>();
        List<Contact> contactRecordsList = new List<Contact>();
        
        For(EMS_EM_Onboarding_Request__c eachOnboardingRequestRecord : [ Select Id,
                                                                        Name,
                                                                        EMS_EM_First_Name__c,
                                                                        Status__c,
                                                                        EMS_EM_Last_Name__c,
                                                                        EMS_EM_Name__c,
                                                                        EMS_EM_Gender__c,
                                                                        Phone_Number__c,
                                                                        EMS_EM_Phone_Number__c,
                                                                        EMS_EM_DOB__c,
                                                                        EMS_EM_BG__c,
                                                                        EMS_EM_Personal_Email__c,
                                                                        EMS_EM_AadhaarNo__c,
                                                                        EMS_EM_PanNo__c,	
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
                                                                        ContactId1__c,
                                                                        (SELECT LinkedEntityId, Id, ContentDocumentId, Visibility, ShareType FROM ContentDocumentLinks)
                                                                        from EMS_EM_Onboarding_Request__c  where ContactId1__c = :contactId
                                                                       ]){
                                                                           Contact contactRecord = new Contact(
                                                                               Id = eachOnboardingRequestRecord.ContactId1__c,
                                                                               FirstName = eachOnboardingRequestRecord.EMS_EM_First_Name__c,
                                                                               LastName = eachOnboardingRequestRecord.EMS_EM_Last_Name__c, 
                                                                               
                                                                               RecordTypeId = CONTACT_APPLICANT_RECORD_TYPE_ID,                                          
                                                                               EMS_EM_Gender__c = eachOnboardingRequestRecord.EMS_EM_Gender__c,
                                                                               EMS_Phone_Number__c = eachOnboardingRequestRecord.Phone_Number__c, 
                                                                               EMS_EM_Alternate_Contact_Number__c = eachOnboardingRequestRecord.EMS_EM_Phone_Number__c, 
                                                                               EMS_EM_DOB__c = eachOnboardingRequestRecord.EMS_EM_DOB__c,
                                                                               EMS_EM_BG__c = eachOnboardingRequestRecord.EMS_EM_BG__c,
                                                                               Personal_Email__c = eachOnboardingRequestRecord.EMS_EM_Personal_Email__c, 
                                                                               EMS_EM_AadhaarNo__c = eachOnboardingRequestRecord.EMS_EM_AadhaarNo__c, 
                                                                               EMS_EM_PanNo__c = eachOnboardingRequestRecord.EMS_EM_PanNo__c,	
                                                                               Trailblazer_ID_or_Public_URL__c = eachOnboardingRequestRecord.Trailblazer_ID_or_Public_URL__c,
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
                                                                           
                                                                           contactRecordsList.add(contactRecord);
                                                                           for(ContentDocumentLink contentDocumentEach : eachOnboardingRequestRecord.ContentDocumentLinks){
                                                                               onboardingContentDocumentRecordIdsSet.add(contentDocumentEach.ContentDocumentId); 
                                                                           }
                                                                       } 
        Update contactRecordsList;
        //Insert CertificationsRecordsList;
        Set<Id> contactRecordsSet = new Set<Id>();
        For(Contact con : contactRecordsList){
            contactRecordsSet.add(con.Id);
        }
        
        Set<Id> allContentDocumetIds = new Set<Id>();
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
        
        system.debug('---->contactRecordsList'+contactRecordsList);
        
        
        
        return contactRecordsList;   
    }
    
    @AuraEnabled
    public static void ConvertButton(String contactId){
        List<Contact>conlist=new List<Contact>();
        EMS_EM_Onboarding_Request__c onlist =[Select Id,
                                              Name,
                                              Status__c
                                              from EMS_EM_Onboarding_Request__c
                                              where ContactId1__c = :contactId ];
        
        EMS_EM_Onboarding_Request__c onboard =new EMS_EM_Onboarding_Request__c();
        onboard.Id=onlist.Id;
        onboard.Status__c='Converted';
        update onboard;         
    }
    
}