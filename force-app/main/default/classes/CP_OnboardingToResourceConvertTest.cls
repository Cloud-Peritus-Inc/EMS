/**
* @author Mukesh Rawat
* @date 1/02/2023
* @description  createContact to Convert Onboarding Records to Resource-Contact Resource
*
*               Test code coverage for CP_OnboardingToResourceConvert class
*        
*
* CHANGE HISTORY
* ====================================================================================================
* DATE          NAME                    DESCRIPTION
* N/A           N/A                     N/A
* ====================================================================================================
**/

@istest
public class CP_OnboardingToResourceConvertTest {
    
    static testmethod void createContactTest(){
        List<EMS_EM_Onboarding_Request__c> RequestList = new List<EMS_EM_Onboarding_Request__c>();
        EMS_EM_Onboarding_Request__c onboard =new EMS_EM_Onboarding_Request__c();
        onboard.EMS_EM_First_Name__c='test';
        onboard.EMS_EM_Last_Name__c='last';
        onboard.Is_Inegration_Needed__c=true;
        onboard.Google_Drive_ID__c = '';
        onboard.Status__c = 'Approved';
        insert onboard;
        ems_EM_Additional_Detail__c addionalDetail=new ems_EM_Additional_Detail__c();
        addionalDetail.Onboarding_Request__c = onboard.id;
        insert addionalDetail;
        ContentVersion content=new ContentVersion(); 
        content.Title='Header_Picture1'; 
        content.PathOnClient='/' + content.Title + '.jpg'; 
        Blob bodyBlob=Blob.valueOf('Unit Test ContentVersion Body'); 
        content.VersionData=bodyBlob; 
        //content.LinkedEntityId=sub.id;
        content.origin = 'H';
        insert content;
        ContentDocumentLink contentlink = new ContentDocumentLink();
        contentlink.LinkedEntityId=onboard.id;
        contentlink.contentdocumentid=[select contentdocumentid from contentversion where id =: content.id].contentdocumentid;
        contentlink.ShareType = 'I';
        contentlink.Visibility = 'AllUsers'; 
        insert contentlink;
        ContentDocumentLink contentlink1 = new ContentDocumentLink();
        contentlink1.LinkedEntityId=addionalDetail.id;
        contentlink1.contentdocumentid=[select contentdocumentid from contentversion where id =: content.id].contentdocumentid;
        contentlink1.ShareType = 'I';
        contentlink1.Visibility = 'AllUsers'; 
        insert contentlink1;
        Map<Id,EMS_EM_Onboarding_Request__c> oldOnboardRecordMap = new Map<Id,EMS_EM_Onboarding_Request__c>();
        onboard.Status__c = 'Converted';
        update onboard;
        oldOnboardRecordMap.put(onboard.Id,onboard);
        RequestList.add(onboard);
        
        test.startTest();
        CP_OnboardingToResourceConvert.createContact(onboard.Id);
        test.stopTest();     
    }
    
}