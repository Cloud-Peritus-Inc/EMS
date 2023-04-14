public class EMS_EM_Request {

    @AuraEnabled
    public static contact getUserContactInfo(Id userId){
        //  id userid = userinfo.getUserId();
        // System.debug(userId+'uuuseerrid');
        user u =[Select id,name, Contactid from user where id =: userId  AND Contactid != null];
        System.debug('userid'+U);
        contact contactDetails =[SELECT  id, LastName, FirstName, Name, EMS_RM_Industry__c, EMS_RM_Employee_Id__c,visiable_to_edit__c,
                                                    EMS_RM_Domain_Technology__c,EMS_Domain_Technology__c, EMS_RM_Current_Job_Role__c,
                                                EMS_Phone_Number__c,EMS_RM_Resource_Email_id__c, EMS_EM_Mstatus__c  FROM Contact where id =: u.contactid];

        return contactDetails;
        
    }
    @AuraEnabled
    public static contact getContactInfo(Id recordId){
        //  id userid = userinfo.getUserId();
        // System.debug(userId+'uuuseerrid');
        EMS_EM_Request__c req =[select Name, Contact__c from EMS_EM_Request__c where id  =: recordId  AND Contact__c != null];
        
        contact contactDetails =[SELECT  LastName, FirstName, Name, EMS_RM_Industry__c, EMS_RM_Employee_Id__c,visiable_to_edit__c,
                                                    EMS_RM_Domain_Technology__c,EMS_Domain_Technology__c, EMS_RM_Current_Job_Role__c,
                                                EMS_Phone_Number__c,EMS_RM_Resource_Email_id__c, Email, Department FROM Contact where id =: req.Contact__c];

        return contactDetails;
        
    }
    @AuraEnabled
    public static EMS_EM_Request__c createRequest(EMS_EM_Request__c newRecord) {
        contact contactDetails =[SELECT  EMS_EM_CAddress_Line_1__c, EMS_EM_CAddress_Line_2__c, EMS_EM_CA_State__c, EMS_EM_CA_City__c,
                                 EMS_EM_CA_Zip__c, EMS_EM_PAddress_Line_1__c, EMS_EM_PAddress_Line_2__c, EMS_EM_PA_State__c, EMS_EM_PA_City__c, EMS_EM_PA_Zip__c,
                                 EMS_EM_ED_Name__c, EMS_EM_ED_Relation__c, EMS_EM_ED_Address__c, EMS_EM_ED_Phone__c, EMS_EM_ED_Email__c,
                                 Vehicle_Number__c, Vehicle_Type__c, Bank_Name__c, Account_Number__c, IFSC_Code__c, Account_Holder_Name__c,
                                 EMS_RM_Phone_Number__c, Email, EMS_EM_Mstatus__c, EMS_EM_Spouse__c, EMS_EM_DOW__c, EMS_Phone_Number__c, Personal_Email__c
                                 FROM Contact where id =: newRecord.Contact__c];
        
        //old address
        newRecord.EMS_EM_CAddress_Line_1_Old__c = contactDetails.EMS_EM_CAddress_Line_1__c;
        newRecord.EMS_EM_PAddress_Line_1_Old__c = contactDetails.EMS_EM_PAddress_Line_1__c;
        newRecord.EMS_EM_CAddress_Line_2_Old__c = contactDetails.EMS_EM_CAddress_Line_2__c;
        newRecord.EMS_EM_PAddress_Line_2_Old__c = contactDetails.EMS_EM_PAddress_Line_2__c;
        newRecord.EMS_EM_CA_State_Old__c = contactDetails.EMS_EM_CA_State__c;
        newRecord.EMS_EM_PA_State_Old__c = contactDetails.EMS_EM_PA_State__c;
        newRecord.EMS_EM_CA_City_Old__c = contactDetails.EMS_EM_CA_City__c;
        newRecord.EMS_EM_PA_City_Old__c = contactDetails.EMS_EM_PA_City__c;
        newRecord.EMS_EM_CA_Zip_Old__c = contactDetails.EMS_EM_CA_Zip__c;
        newRecord.EMS_EM_PA_Zip_Old__c = contactDetails.EMS_EM_PA_Zip__c;
            
        //old Emergency Details
        newRecord.EMS_EM_ED_Name_Old__c = contactDetails.EMS_EM_ED_Name__c;
        newRecord.EMS_EM_ED_Relation_Old__c = contactDetails.EMS_EM_ED_Relation__c;
        newRecord.EMS_EM_ED_Address_Old__c = contactDetails.EMS_EM_ED_Address__c;
        newRecord.EMS_EM_ED_Phone_Old__c = contactDetails.EMS_EM_ED_Phone__c;
        newRecord.EMS_EM_ED_Email_Old__c = contactDetails.EMS_EM_ED_Email__c;
            
        //Old vehicle details
        newRecord.EMS_EM_Vehicle_Number_old__c = contactDetails.Vehicle_Number__c;
        newRecord.EMS_EM_Vehicle_Type_old__c = contactDetails.Vehicle_Type__c;
            
        //Old Bank details
        newRecord.EMS_EM_Bank_Name_Old__c = contactDetails.Bank_Name__c;
        newRecord.EMS_EM_Account_Number_Old__c = contactDetails.Account_Number__c;
        newRecord.EMS_EM_IFSC_Code_Old__c = contactDetails.IFSC_Code__c;
        newRecord.EMS_EM_Account_Holder_Name_Old__c = contactDetails.Account_Holder_Name__c;
        
        //Old Personal Details
        newRecord.EMS_EM_Contact_Number_Old__c = contactDetails.EMS_Phone_Number__c;
        newRecord.Personal_Email_Id_Old__c = contactDetails.Personal_Email__c;
        
        newRecord.EMS_EM_Mstatus_Old__c = contactDetails.EMS_EM_Mstatus__c;
        newRecord.EMS_EM_Spouse_Name_Old__c = contactDetails.EMS_EM_Spouse__c;
        newRecord.EMS_EM_DOW_Old__c = contactDetails.EMS_EM_DOW__c; 		
            
       insert newRecord;
       return newRecord;
    }

    @AuraEnabled
    public static void uploadFileToNewContact(EMS_EM_Request__c newRecord, String base64, String filename){
        insert newRecord;
        
        uploadFile(base64, filename, newRecord.ID);
    }


    @AuraEnabled
    public static String uploadFile(String base64, String filename, String recordId) {
        
            ContentVersion cv = createContentVersion(base64, filename);
            ContentDocumentLink cdl = createContentLink(cv.Id, recordId);
            if (cv == null || cdl == null) { return null; }
            return cdl.Id;
    }
    
    private static ContentVersion createContentVersion(String base64, String filename) {
        ContentVersion cv = new ContentVersion();
        cv.VersionData = EncodingUtil.base64Decode(base64);
        cv.Title = filename;
        cv.PathOnClient = filename;
        try {
        insert cv;
        return cv;
        } catch(DMLException e) {
        System.debug(e);
        return null;
        }
    }

    
    private static ContentDocumentLink createContentLink(String contentVersionId, String recordId) {
                if (contentVersionId == null || recordId == null) { return null; }
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = [
        SELECT ContentDocumentId 
        FROM ContentVersion 
        WHERE Id =: contentVersionId
        ].ContentDocumentId;
        cdl.LinkedEntityId = recordId;
        // ShareType is either 'V', 'C', or 'I'
        // V = Viewer, C = Collaborator, I = Inferred
        cdl.ShareType = 'V';
        try {
        insert cdl;
        return cdl;
        } catch(DMLException e) {
        System.debug(e);
        return null;
        }
    }
}