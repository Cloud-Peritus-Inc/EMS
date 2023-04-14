public without Sharing class EMS_EM_CreationOnboard {
   
    public string contactId;
     public class relatedFile {
        public String PathOnClient;
        public String Title;
        public Blob VersionData;
    }
    public static string onboardformId;
     
    
    @AuraEnabled
    public static EMS_EM_Onboarding_Request__c createGuest(EMS_EM_Onboarding_Request__c newRecord, ems_EM_Additional_Detail__c newaddRecord,
                                                           List<Object> files) {
        string contactId; 
        insert newRecord;  
       	contactId = newRecord.Id; 
            
        newaddRecord.Onboarding_Request__c=newRecord.Id;
        insert newaddRecord;
                                                               
       List<ContentVersion> relatedDocuments = new List<ContentVersion>();
       for (Object file : files) {
           system.debug('the file'+file);
            String fileJson = JSON.serialize(file);
            relatedFile relatedDocument = (relatedFile) JSON.deserialize(fileJson, relatedFile.class);
            ContentVersion contentVersionFile = new ContentVersion();
            contentVersionFile.PathOnClient = relatedDocument.PathOnClient;
            contentVersionFile.Title = relatedDocument.Title;
            contentVersionFile.FirstPublishLocationId= newRecord.Id;
            contentVersionFile.VersionData = relatedDocument.VersionData;
            relatedDocuments.add(contentVersionFile);
           system.debug('contentVersionFile-->'+contentVersionFile);
       }
        Database.saveResult[] srFiles = Database.insert(relatedDocuments);
        return newRecord;
    }
    

    
     @AuraEnabled
    public static void sendEmail( String subject,String recordId,String body) {  
        //EmailTemplate emailTemp = [Select id,Subject,Body From EmailTemplate Where Name = 'Email Notification'];
        Messaging.reserveSingleEmailCapacity(1);
        try{
        messaging.SingleEmailMessage mail = new messaging.SingleEmailMessage();
        
            List<String> toAddress=new List<String>{'sangharsh.kamble@cloudperitus.com','deeksha.maddirala@cloudperitus.com','kiran.kanna@cloudperitus.com'};
      
        // toAddress.add('er.rajat15@gmail.com');
                
        mail.setToAddresses(toAddress);
        mail.setReplyTo('no-reply@xooa.com');
        mail.setSenderDisplayName('Cloud Peritus');
        mail.setSubject(subject);
            
        mail.setHtmlBody(body);
       // mail.setTemplateId(emailTemp.Id);
        // mail.setEntityAttachments(files);
        Messaging.sendEmail(new List<messaging.SingleEmailMessage> {mail});
        }
        catch (exception e){
            throw new AuraHandledException(e.getMessage());
            //return null;
        }
    }
    
     @AuraEnabled
    public static EMS_EM_Onboarding_Request__c getUserOnboardInfo(String recordId){
        
        EMS_EM_Onboarding_Request__c onboardlist=[Select EMS_EM_First_Name__c,EMS_EM_Last_Name__c,EMS_EM_Father__c,Name,EMS_EM_Mother__c,EMS_EM_Gender__c,Phone_Number__c,
                                                  EMS_EM_Phone_Number__c,EMS_EM_DOB__c,EMS_EM_Mstatus__c,EMS_EM_Spouse__c,EMS_EM_DOW__c,Status__c,EMS_EM_BG__c,EMS_EM_Personal_Email__c, 
                                                  EMS_EM_AadhaarNo__c,EMS_EM_PanNo__c,EMS_EM_PassportNo__c,EMS_EM_UAN_Number__c,EMS_EM_Nationality__c,Permanent_Address_Line_1__c,Permanent_Address_Line_2__c,
                                                  Current_Address_Line_1__c,Current_Address_Line_2__c,EMS_EM_CA_State__c,EMS_EM_PA_State__c,EMS_EM_CA_Zip__c,EMS_EM_PA_Zip__c,EMS_EM_CA_City__c,EMS_EM_PA_City__c,
                                                  EMS_EM_Education__c,EMS_EM_Education1__c,EMS_EM_Education2__c,EMS_EM_Education3__c,
                                                  EMS_EM_Education4__c,EMS_EM_Education5__c,EMS_EM_Degree__c,EMS_EM_Degree1__c,EMS_EM_Degree2__c,EMS_EM_Degree3__c,EMS_EM_Degree4__c,EMS_EM_Degree5__c,
                                                  EMS_EM_IName__c,EMS_EM_IName1__c,EMS_EM_IName2__c,EMS_EM_IName3__c,EMS_EM_IName4__c,EMS_EM_IName5__c,
                                                  EMS_EM_Field_of_Study__c,EMS_EM_Field_of_Study1__c,EMS_EM_Field_of_Study2__c,EMS_EM_Field_of_Study3__c,EMS_EM_Field_of_Study4__c,EMS_EM_Field_of_Study5__c,
                                                  EMS_EM_GDate__c,EMS_EM_GDate1__c,EMS_EM_GDate2__c,EMS_EM_GDate3__c,EMS_EM_GDate4__c,EMS_EM_GDate5__c,
                                                  EMS_EM_Job_Title__c,EMS_EM_Job_Title1__c,EMS_EM_Job_Title2__c,EMS_EM_Job_Title3__c,EMS_EM_Job_Title4__c,EMS_EM_Job_Title5__c,
                                                  EMS_EM_Previous_Company_Name__c,EMS_EM_Previous_Company_Name1__c,EMS_EM_Previous_Company_Name2__c,EMS_EM_Previous_Company_Name3__c,EMS_EM_Previous_Company_Name4__c,EMS_EM_Previous_Company_Name5__c,
                                                  EMS_EM_From_Date__c,EMS_EM_From_Date1__c,EMS_EM_From_Date2__c,EMS_EM_From_Date3__c,EMS_EM_From_Date4__c,EMS_EM_From_Date5__c,
                                                  EMS_EM_To_Date__c,EMS_EM_To_Date1__c,EMS_EM_To_Date2__c,EMS_EM_To_Date3__c,EMS_EM_To_Date4__c,EMS_EM_To_Date5__c,
                                                  EMS_EM_Previous_Company_HR_EmailId__c,EMS_EM_Certification_Name__c,EMS_EM_Certification_Name2__c,EMS_EM_Certification_Name3__c,EMS_EM_Certification_Name4__c,EMS_EM_Certification_Name5__c,EMS_EM_Certification_Name6__c,
                                                  EMS_EM_Certification_Name7__c,EMS_EM_Certification_Name8__c,EMS_EM_Certification_Name9__c,EMS_EM_Certification_Name10__c,EMS_EM_Certification_Name11__c,EMS_EM_Certification_Name12__c,
                                                  EMS_EM_Certification_Name13__c,EMS_EM_Certification_Name14__c,EMS_EM_Certification_Name15__c,EMS_EM_Certification_Name16__c,EMS_EM_Certification_Name17__c,EMS_EM_Certification_Name18__c,
                                                  EMS_EM_Certification_Name19__c
                                                  from EMS_EM_Onboarding_Request__c where Id=:recordId];
        
        return onboardlist;
        
    }
    
    @AuraEnabled
    public static EMS_EM_Onboarding_Request__c getonOnboardformInfo(String onboardEmailid){
        
        if(onboardEmailid!=Null){
        EMS_EM_Onboarding_Request__c onboardformlist=[Select Id, EMS_EM_First_Name__c, EMS_EM_Last_Name__c,EMS_EM_Father__c,Name,
                                                      EMS_EM_Mother__c,EMS_EM_Gender__c,Phone_Number__c,EMS_EM_Phone_Number__c,
                                                      EMS_EM_AadhaarNo__c,EMS_EM_PanNo__c,EMS_EM_PassportNo__c,EMS_EM_UAN_Number__c,
                                                      EMS_EM_Nationality__c,Permanent_Address_Line_1__c,Permanent_Address_Line_2__c,
                                                      Current_Address_Line_1__c,Current_Address_Line_2__c,EMS_EM_CA_State__c,EMS_EM_PA_State__c,
                                                      EMS_EM_CA_Zip__c,EMS_EM_PA_Zip__c,EMS_EM_CA_City__c,EMS_EM_PA_City__c,
                                                      EMS_EM_DOB__c,EMS_EM_BG__c,EMS_EM_Mstatus__c,EMS_EM_Certification_Name1__c, 
                                                      EMS_EM_Certification_Name__c, EMS_EM_Certification_Name2__c, EMS_EM_Certification_Name3__c, 
                                                      EMS_EM_Certification_Name4__c, EMS_EM_Certification_Name5__c, EMS_EM_Certification_Name6__c, 
                                                      EMS_EM_Certification_Name7__c, EMS_EM_Certification_Name8__c, EMS_EM_Certification_Name9__c, 
                                                      EMS_EM_Certification_Name11__c, EMS_EM_Certification_Name10__c, EMS_EM_Certification_Name12__c, 
                                                      EMS_EM_Certification_Name14__c, EMS_EM_Certification_Name13__c, EMS_EM_Certification_Name15__c,
                                                      EMS_EM_Certification_Name16__c, EMS_EM_Certification_Name17__c, EMS_EM_Certification_Name18__c, 
                                                      EMS_EM_Certification_Name19__c,EMS_EM_Job_Title5__c, EMS_EM_Degree__c, EMS_EM_Degree1__c, 
                                                      EMS_EM_Degree2__c, EMS_EM_Degree3__c, EMS_EM_Degree4__c, EMS_EM_Degree5__c,
                                                      EMS_EM_Education1__c, EMS_EM_Education2__c, EMS_EM_Education3__c,EMS_EM_Education4__c,
                                                      EMS_EM_Education5__c, EMS_EM_Education__c,EMS_EM_Field_of_Study1__c,
                                                      EMS_EM_Field_of_Study2__c, EMS_EM_Field_of_Study3__c, EMS_EM_Field_of_Study4__c, 
                                                      EMS_EM_Field_of_Study5__c, EMS_EM_Field_of_Study__c,EMS_EM_GDate2__c, EMS_EM_GDate1__c,
                                                      EMS_EM_GDate3__c, EMS_EM_GDate4__c,EMS_EM_GDate5__c, EMS_EM_GDate__c, EMS_EM_IName1__c,
                                                      EMS_EM_IName2__c,EMS_EM_IName3__c, EMS_EM_IName4__c, EMS_EM_IName5__c, EMS_EM_IName__c, 
                                                      EMS_EM_From_Date1__c, EMS_EM_From_Date2__c, EMS_EM_From_Date3__c,EMS_EM_From_Date4__c, 
                                                      EMS_EM_From_Date5__c, EMS_EM_From_Date__c,EMS_EM_Job_Title1__c, EMS_EM_Job_Title2__c,
                                                      EMS_EM_Job_Title3__c,EMS_EM_Job_Title4__c, EMS_EM_Job_Title__c, EMS_EM_To_Date1__c, 
                                                      EMS_EM_To_Date3__c, EMS_EM_To_Date2__c, EMS_EM_To_Date4__c, EMS_EM_To_Date5__c, 
                                                      EMS_EM_To_Date__c, EMS_EM_Previous_Company_HR_EmailId__c,EMS_EM_Previous_Company_Name1__c, 
                                                      EMS_EM_Previous_Company_Name2__c,EMS_EM_Previous_Company_Name3__c, 
                                                      EMS_EM_Previous_Company_Name4__c,EMS_EM_Previous_Company_Name5__c, 
                                                      EMS_EM_Previous_Company_Name__c,Do_you_have_work_experience__c
                                                  	  from EMS_EM_Onboarding_Request__c where EMS_EM_Personal_Email__c=:onboardEmailid];
        
        
        return onboardformlist;
        }else{
            return null;
        }
        
    }
    
    @AuraEnabled
    public static ems_EM_Additional_Detail__c getonOnboardAdditionalInfo(String getContactid){     
       
        if(getContactid!=Null){
            ems_EM_Additional_Detail__c onboardAdditionallist=[SELECT Id,EMS_EM_Job_Title5__c, EMS_EM_Degree__c, EMS_EM_Degree1__c, 
                                                           EMS_EM_Degree2__c, EMS_EM_Degree3__c, EMS_EM_Degree4__c, EMS_EM_Degree5__c,
                                                           EMS_EM_Education1__c, EMS_EM_Education2__c, EMS_EM_Education3__c, 
                                                           EMS_EM_Education4__c, EMS_EM_Education5__c, EMS_EM_Education__c, 
                                                           EMS_EM_Field_of_Study1__c, EMS_EM_Field_of_Study2__c, EMS_EM_Field_of_Study3__c, 
                                                           EMS_EM_Field_of_Study4__c, EMS_EM_Field_of_Study5__c, EMS_EM_Field_of_Study__c, 
                                                           EMS_EM_GDate2__c, EMS_EM_GDate1__c, EMS_EM_GDate3__c, EMS_EM_GDate4__c, 
                                                           EMS_EM_GDate5__c, EMS_EM_GDate__c, EMS_EM_IName1__c, EMS_EM_IName2__c, 
                                                           EMS_EM_IName3__c, EMS_EM_IName4__c, EMS_EM_IName5__c, EMS_EM_IName__c, 
                                                           EMS_EM_From_Date1__c, EMS_EM_From_Date2__c, EMS_EM_From_Date3__c, 
                                                           EMS_EM_From_Date4__c, EMS_EM_From_Date5__c, EMS_EM_From_Date__c, 
                                                           EMS_EM_Job_Title1__c, EMS_EM_Job_Title2__c, EMS_EM_Job_Title3__c, 
                                                           EMS_EM_Job_Title4__c, EMS_EM_Job_Title__c, EMS_EM_To_Date1__c, 
                                                           EMS_EM_To_Date3__c, EMS_EM_To_Date2__c, EMS_EM_To_Date4__c, EMS_EM_To_Date5__c, 
                                                           EMS_EM_To_Date__c, EMS_EM_Previous_Company_HR_EmailId__c, 
                                                           EMS_EM_Previous_Company_Name1__c, EMS_EM_Previous_Company_Name2__c,
                                                           EMS_EM_Previous_Company_Name3__c, EMS_EM_Previous_Company_Name4__c,
                                                           EMS_EM_Previous_Company_Name5__c, EMS_EM_Previous_Company_Name__c, 
                                                           Onboarding_Request__c, ContactId__c FROM ems_EM_Additional_Detail__c 
                                                           where ContactId__c=:getContactid];
            
            return onboardAdditionallist;
        }else{
            return null;
        }     
    }
  }