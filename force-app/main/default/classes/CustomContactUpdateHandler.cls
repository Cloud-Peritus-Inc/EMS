public class CustomContactUpdateHandler {
    public static boolean iscontactTriggerExecuted = false;
	public static void updateCustomContact(List<Contact> contactList){
        Set<Id> contactIdSet=new Set<Id>();
        
        For(Contact c:contactList)
        {
            contactIdSet.add(c.id);
        }
        
        List<CP_Sales_Contact__c> contactUpdateList = new List<CP_Sales_Contact__c>(); 
        
        List<Contact> scope =[Select Id,CP_Sales_Contact__c, AccountId,Name__c,EMS_RM_Applicant_Profile_Completed__c,AssistantName,AssistantPhone,EMS_TM_Billable__c,
                           Birthdate,EMS_RM_Candidate_Id__c,EMS_RM_Certifications__c,EMS_Client_id__c,EMS_RM_University_Name__c,EMS_Company_name__c,
                           Current_Active_Assignments__c,EMS_RM_Current_CTC__c,EMS_RM_Current_Location__c,Department,EMS_RM_Industry__c,Description,
                           EMS_RM_Current_Job_Role__c,DoNotCall,EMS_Domain_Technology__c,EMS_RM_Domain_Technology__c,EMS_RM_Education__c,Email,EMS_RM_Resource_Email_id__c,
                           HasOptedOutOfEmail,EMS_RM_Employee_Id__c,EMS_Employee_type__c,EMS_RM_Expected_CTC__c,EMS_RM_Months__c,EMS_RM_Years__c,
                           Fax,HasOptedOutOfFax,EMS_RM_FirstName__c,HomePhone,EMS_TM_In_Billing__c,Interviewer__c,EMS_RM_Job_Title__c,
                           EMS_RM_LastName__c,LastCURequestDate,LastCUUpdateDate,EMS_RM_Last_Working_day__c,LeadSource,Linkedin__c,Location__c,MailingAddress,
                           MobilePhone,EMS_RM_Resource_Mobile_no__c,Name,EMS_RM_Notice_Period__c,Official_Mail__c,OtherAddress,OtherPhone,EMS_RM_Permanent_Address__c,
                           Phone,EMS_Phone_Number__c,EMS_RM_Phone_Number__c,EMS_RM_Previous_Company_Name__c,EMS_Projet_Budget__c,EMS_Recruiter__c,ReportsToId,Resume__c,EMS_RM_Serving_Notice_Period__c,
                          EMS_RM_ApplicantStatus_Update__c,Title,EMS_TM_User__c,EMS_RM_CheckUserMail__c,EMS_website__c,EMS_Year_Founded_in__c
                			from Contact Where Id=:contactIdSet AND RecordType.Name='Sales Contact'];
        
         for(Contact s : scope){	
                    
                    CP_Sales_Contact__c cp = new CP_Sales_Contact__c();
                    cp.Id = s.CP_Sales_Contact__c;
                    cp.Account__c=s.AccountId;
                    cp.Name=s.Name;
                    cp.Phone_Number__c=s.EMS_Phone_Number__c;

                    cp.EMS_RM_Applicant_Profile_Completed__c=s.EMS_RM_Applicant_Profile_Completed__c;
                    cp.AssistantName__c=s.AssistantName;
                    cp.AssistantPhone__c=s.AssistantPhone;
                    //le.EMS_TM_Billable__c =s.EMS_TM_Billable__c;
                    cp.Birthdate__c= s.Birthdate;
                    cp.EMS_RM_Certifications__c=s.EMS_RM_Certifications__c;
                  
                    
                    cp.EMS_RM_Applicant_Profile_Completed__c=s.EMS_RM_Applicant_Profile_Completed__c;
                    cp.AssistantName__c=s.AssistantName;
                    cp.AssistantPhone__c=s.AssistantPhone;
                    cp.Billable__c=s.EMS_TM_Billable__c;
                    cp.Birthdate__c=s.Birthdate;
                    cp.Company_Name__c=s.EMS_Company_name__c;
                    cp.Name=s.Name;
                    //le.CreatedById__c=s.CreatedById;
                    //le.CreatedById=s.
                    cp.Current_Active_Assignments__c=s.Current_Active_Assignments__c;
                    cp.Current_CTC__c=s.EMS_RM_Current_CTC__c;
                    cp.Current_Location__c=s.EMS_RM_Current_Location__c;
                    cp.Department__c=s.Department;
                    cp.Department_Name__c=s.EMS_RM_Industry__c;
                    cp.Description__c=s.Description;
                    cp.Designation__c=s.EMS_RM_Current_Job_Role__c;
                    cp.Do_Not_Call__c=s.DoNotCall;
                    cp.Domain_Technology__c=s.EMS_Domain_Technology__c;
                    cp.Education__c=s.EMS_RM_Education__c;
                    cp.Email__c=s.Email;
                    cp.Email_id__c=s.EMS_RM_Resource_Email_id__c;
                    cp.Email_Opt_Out__c=s.HasOptedOutOfEmail;
                    //le.Employee_Id__c=s.EMS_RM_Employee_Id__c;  --AutoNumber
                    cp.Employee_type__c=s.EMS_Employee_type__c;
                    cp.Expected_CTC__c=s.EMS_RM_Expected_CTC__c;
                    cp.Experience_months__c=s.EMS_RM_Months__c;
                    cp.Experience_Years__c=s.EMS_RM_Years__c;
                    cp.Fax__c=s.Fax;
                    cp.Fax_Opt_Out__c=s.HasOptedOutOfFax;
                    cp.First_Name__c=s.EMS_RM_FirstName__c;
                    cp.Home_Phone__c=s.HomePhone;
                    cp.In_Billing__c=s.EMS_TM_In_Billing__c;
                    cp.Interviewer__c=s.Interviewer__c;
                    //le.Job_Application_Id__c=s.EMS_Job_Application_Id__c;
                    cp.Job_Title__c=s.EMS_RM_Job_Title__c;
                    //le.LastModifiedById=s.
                    cp.Last_Name__c=s.EMS_RM_LastName__c;
                    cp.Last_Stay_in_Touch_Request_Date__c=s.LastCURequestDate;
                    cp.Last_Stay_in_Touch_Save_Date__c=s.LastCUUpdateDate;
                    cp.Last_Working_Day__c=s.EMS_RM_Last_Working_day__c;
                    cp.Lead_Source__c=s.LeadSource;
                    cp.Linkedin__c=s.Linkedin__c;
                    cp.Location__c=s.Location__c;
                    cp.MobilePhone__c=s.MobilePhone;
                    cp.Mobile_no__c=s.EMS_RM_Resource_Mobile_no__c;
                    cp.Name_C__c=s.Name;
                    //le.Notice_period__c=s.EMS_RM_Notice_Period__c;
                    cp.Official_Mail__c=s.Official_Mail__c;
                    cp.Other_Phone__c=s.OtherPhone;
                    //le.OwnerId=s.
                    cp.Permanent_Address__c=s.EMS_RM_Permanent_Address__c;
                    cp.Phone__c=s.Phone;
                    //le.Phone_Number__c=s.EMS_Phone_Number__c;
                    cp.Previous_Company_Name__c=s.EMS_RM_Previous_Company_Name__c;
                    cp.Project_Budget__c=s.EMS_Projet_Budget__c;
                    //le.RecordTypeId=s.
                    cp.EMS_Recruiter__c=s.EMS_Recruiter__c;
                    cp.Reports_To__c=s.ReportsToId;
                    cp.Resume__c=s.Resume__c;
                    cp.Serving_Notice_Period__c=s.EMS_RM_Serving_Notice_Period__c;
                    cp.Status__c=s.EMS_RM_ApplicantStatus_Update__c;
                    cp.Title__c=s.Title;
                    cp.User__c=s.EMS_TM_User__c;
                    cp.User_Email__c=s.EMS_RM_CheckUserMail__c;
                    cp.Website__c=s.EMS_website__c;
                    cp.Year_Founded_in__c=s.EMS_Year_Founded_in__c;
             		
                    contactUpdateList.add(cp);
                   
            
        }
        
        If(contactUpdateList.size()>0)
        {
            iscontactTriggerExecuted = true;
            Database.upsert(contactUpdateList,true);
            
            
        }
    }
}