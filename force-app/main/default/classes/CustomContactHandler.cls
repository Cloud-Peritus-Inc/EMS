public class CustomContactHandler 
{
    public static boolean isCustomContactExcecution = false;
    public static void updateStadContactFromCustom(List<CP_Sales_Contact__c>leadlist2)
    {
         Set<Id>setid=new Set<Id>();
        For(CP_Sales_Contact__c con:leadlist2)
        {
            setid.add(con.Id);
            
        }
       List<CP_Sales_Contact__c>conlist=[SELECT Id, OwnerId, IsDeleted, Name, RecordTypeId, CreatedDate, CreatedById, LastModifiedDate, 
                                         LastModifiedById, SystemModstamp, LastViewedDate, LastReferencedDate, Account__c, Name__c, EMS_RM_Applicant_Profile_Completed__c, 
                                         AssistantName__c, AssistantPhone__c, Billable__c, Birthdate__c, EMS_RM_Candidate_Id__c, EMS_RM_Certifications__c, Client_id__c, 
                                         College_University_Name__c, Company_Name__c, Owner__c, CreatedById__c, Current_Active_Assignments__c, Current_CTC__c, 
                                         Current_Location__c, Jigsaw__c, Department__c, Department_Name__c, Description__c, Designation__c, Do_Not_Call__c, Domain_Technology__c,
                                         Education__c, Email__c, Email_id__c, Email_Opt_Out__c, Employee_Id__c, Employee_type__c, Expected_CTC__c, Experience_months__c, 
                                         Experience_Years__c, Fax__c, Fax_Opt_Out__c, First_Name__c, Home_Phone__c, In_Billing__c, Interviewer__c, Job_Application_Id__c, Job_Title__c, 
                                         Last_Name__c, Last_Stay_in_Touch_Request_Date__c, Last_Stay_in_Touch_Save_Date__c, Last_Working_Day__c, Lead_Source__c, Linkedin__c, Location__c,
                                         Mailing_Address__c, MobilePhone__c, Mobile_no__c, Contact__c, Name_C__c, Notice_period__c, Official_Mail__c, Other_Address__c, Other_Phone__c, Permanent_Address__c,
                                         Phone__c, Phone_Number__c, Previous_Company_Name__c, Project_Budget__c, EMS_Recruiter__c, Reports_To__c, Resume__c, Serving_Notice_Period__c, Status__c, Title__c, User__c,
                                         User_Email__c, Website__c, Year_Founded_in__c,
                                         (Select Id,AccountId,Name__c,EMS_RM_Applicant_Profile_Completed__c,AssistantName,AssistantPhone,EMS_TM_Billable__c,
                                         Birthdate,EMS_RM_Candidate_Id__c,EMS_RM_Certifications__c,EMS_Client_id__c,EMS_RM_University_Name__c,EMS_Company_name__c,
                                         Current_Active_Assignments__c,EMS_RM_Current_CTC__c,EMS_RM_Current_Location__c,Department,EMS_RM_Industry__c,Description,
                                         EMS_RM_Current_Job_Role__c,DoNotCall,EMS_Domain_Technology__c,EMS_RM_Domain_Technology__c,EMS_RM_Education__c,Email,EMS_RM_Resource_Email_id__c,
                                          HasOptedOutOfEmail,EMS_RM_Employee_Id__c,EMS_Employee_type__c,EMS_RM_Expected_CTC__c,EMS_RM_Months__c,EMS_RM_Years__c,
                                          Fax,HasOptedOutOfFax,EMS_RM_FirstName__c,HomePhone,EMS_TM_In_Billing__c,Interviewer__c,EMS_Job_Application_Id__c  ,EMS_RM_Job_Title__c,
                                          EMS_RM_LastName__c,LastCURequestDate,LastCUUpdateDate,EMS_RM_Last_Working_day__c,LeadSource,Linkedin__c,Location__c,MailingAddress,
                                          MobilePhone,EMS_RM_Resource_Mobile_no__c,Name,Notice_Period__c,Official_Mail__c,OtherAddress,OtherPhone,EMS_RM_Permanent_Address__c,
                                          Phone,EMS_Phone_Number__c,EMS_RM_Phone_Number__c,EMS_RM_Previous_Company_Name__c,EMS_Projet_Budget__c,EMS_Recruiter__c,ReportsToId,Resume__c,EMS_RM_Serving_Notice_Period__c,
                                          EMS_RM_ApplicantStatus_Update__c,Title,EMS_TM_User__c,EMS_RM_CheckUserMail__c,EMS_website__c,EMS_Year_Founded_in__c from Contacts__r)
                                          FROM CP_Sales_Contact__c where Id=:setid]; 
        
                  System.debug('conlist'+conlist);

                 List<Contact>conlist1=new List<Contact>(); 
           For(CP_Sales_Contact__c s:conlist)
        {
            For(Contact le:s.Contacts__r) 
            {
                System.debug('s.Contacts__r'+s.Contacts__r);
                    le.AccountId=s.Account__c;
                    le.LastName=s.Name;
                    le.EMS_RM_Phone_Number__c=s.Phone_Number__c;
                    le.EMS_RM_Applicant_Profile_Completed__c=s.EMS_RM_Applicant_Profile_Completed__c;
                    le.AssistantName=s.AssistantName__c;
                    le.AssistantPhone=s.AssistantPhone__c;
                    //le.EMS_TM_Billable__c =s.EMS_TM_Billable__c;
                    le.Birthdate= s.Birthdate__c;
                    le.EMS_RM_Certifications__c=s.EMS_RM_Certifications__c;
                    le.EMS_Company_name__c=s.Company_Name__c;
                    le.EMS_RM_Current_CTC__c=s.Current_CTC__c;
                    le.EMS_RM_Current_Location__c=s.Current_Location__c;
                    le.Department=s.Department__c;
                    le.EMS_RM_Industry__c=s.Department_Name__c;
                    le.Description=s.Description__c;
                    le.EMS_RM_Current_Job_Role__c=s.Designation__c;
                    le.DoNotCall=s.Do_Not_Call__c;
                    le.EMS_Domain_Technology__c=s.Domain_Technology__c;
                    le.EMS_RM_Education__c=s.Education__c;
                    le.Email=s.Email__c;
                    le.EMS_RM_Resource_Email_id__c=s.Email_id__c;
                    le.HasOptedOutOfEmail=s.Email_Opt_Out__c;
                    le.EMS_Employee_type__c=s.Employee_type__c;
                    le.EMS_RM_Expected_CTC__c=s.Expected_CTC__c;
                    le.EMS_RM_Months__c=s.Experience_months__c;
                    le.EMS_RM_Years__c=s.Experience_Years__c;
                    le.Fax=s.Fax__c;
                    le.HasOptedOutOfFax=s.Fax_Opt_Out__c;
                    le.EMS_RM_FirstName__c=s.First_Name__c;
                    le.HomePhone=s.Home_Phone__c;
                    le.EMS_TM_In_Billing__c=s.In_Billing__c;
                    le.Interviewer__c=s.Interviewer__c;
                    le.EMS_Job_Application_Id__c=s.Job_Application_Id__c;
                    le.EMS_RM_Job_Title__c=s.Job_Title__c;
                    le.EMS_RM_LastName__c=s.Last_Name__c;
                    le.EMS_RM_Last_Working_day__c=s.Last_Working_Day__c;
                    le.LeadSource=s.Lead_Source__c;
                    le.Linkedin__c=s.Linkedin__c;
                    le.Location__c=s.Location__c;
                    le.MobilePhone=s.MobilePhone__c;
                    le.EMS_RM_Resource_Mobile_no__c=s.Mobile_no__c;
                    le.Official_Mail__c=s.Official_Mail__c;
                   // le.Other_Phone=s.OtherPhone__c;
                    le.EMS_RM_Permanent_Address__c=s.Permanent_Address__c;
                    le.Phone=s.Phone__c;
                    le.EMS_RM_Previous_Company_Name__c=s.Previous_Company_Name__c;
                    le.EMS_Projet_Budget__c=s.Project_Budget__c;
                    le.EMS_Recruiter__c=s.EMS_Recruiter__c;
                    le.ReportsToId=s.Reports_To__c;
                    le.Resume__c=s.Resume__c;
                    le.EMS_RM_Serving_Notice_Period__c=s.Serving_Notice_Period__c;
                    le.EMS_RM_ApplicantStatus_Update__c=s.Status__c;
                    le.Title=s.Title__c;
                    le.EMS_TM_User__c=s.User__c;
                    le.EMS_RM_CheckUserMail__c=s.User_Email__c;
                    le.EMS_website__c=s.Website__c;
                    le.EMS_Year_Founded_in__c=s.Year_Founded_in__c;
                    conlist1.add(le);
                
            }
            
        }
        System.debug('conlist1'+conlist1.size());
        If(conlist1.size()>0)
           {
                       update conlist1;
  
           }
        
        
    }
    
    public static void insertStadContact(List<CP_Sales_Contact__c>leadlist2)
    {
                 Set<Id>setid=new Set<Id>();
        For(CP_Sales_Contact__c con:leadlist2)
        {
            setid.add(con.Id);
            
        }
       List<CP_Sales_Contact__c>conlist=[SELECT Id, OwnerId, IsDeleted, Name, RecordTypeId, CreatedDate, CreatedById, LastModifiedDate, 
                                         LastModifiedById, SystemModstamp, LastViewedDate, LastReferencedDate, Account__c, Name__c, EMS_RM_Applicant_Profile_Completed__c, 
                                         AssistantName__c, AssistantPhone__c, Billable__c, Birthdate__c, EMS_RM_Candidate_Id__c, EMS_RM_Certifications__c, Client_id__c, 
                                         College_University_Name__c, Company_Name__c, Owner__c, CreatedById__c, Current_Active_Assignments__c, Current_CTC__c, 
                                         Current_Location__c, Jigsaw__c, Department__c, Department_Name__c, Description__c, Designation__c, Do_Not_Call__c, Domain_Technology__c,
                                         Education__c, Email__c, Email_id__c, Email_Opt_Out__c, Employee_Id__c, Employee_type__c, Expected_CTC__c, Experience_months__c, 
                                         Experience_Years__c, Fax__c, Fax_Opt_Out__c, First_Name__c, Home_Phone__c, In_Billing__c, Interviewer__c, Job_Application_Id__c, Job_Title__c, 
                                         Last_Name__c, Last_Stay_in_Touch_Request_Date__c, Last_Stay_in_Touch_Save_Date__c, Last_Working_Day__c, Lead_Source__c, Linkedin__c, Location__c,
                                         Mailing_Address__c, MobilePhone__c, Mobile_no__c, Contact__c, Name_C__c, Notice_period__c, Official_Mail__c, Other_Address__c, Other_Phone__c, Permanent_Address__c,
                                         Phone__c, Phone_Number__c, Previous_Company_Name__c, Project_Budget__c, EMS_Recruiter__c, Reports_To__c, Resume__c, Serving_Notice_Period__c, Status__c, Title__c, User__c,
                                         User_Email__c, Website__c, Year_Founded_in__c,(Select Id from Contacts__r) FROM CP_Sales_Contact__c where Id=:setid]; 
        
        
         List<Contact>conlist1=new List<Contact>(); 
        For(CP_Sales_Contact__c s:conlist)
        {
            if(s.Contacts__r.size()==0){
            Contact le=new Contact();
                    le.AccountId=s.Account__c;
                    le.RecordTypeId=Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Sales Contact').getRecordTypeId();
                    le.LastName=s.Name;
                    le.CP_Sales_Contact__c=s.Id;
                    le.EMS_Phone_Number__c=s.Phone_Number__c;
                    le.EMS_RM_Phone_Number__c=s.Phone_Number__c;
                    le.EMS_RM_Applicant_Profile_Completed__c=s.EMS_RM_Applicant_Profile_Completed__c;
                    le.AssistantName=s.AssistantName__c;
                    le.AssistantPhone=s.AssistantPhone__c;
                    //le.EMS_TM_Billable__c =s.EMS_TM_Billable__c;
                    le.Birthdate= s.Birthdate__c;
                    le.EMS_RM_Certifications__c=s.EMS_RM_Certifications__c;
            
                    le.EMS_Company_name__c=s.Company_Name__c;
                    le.EMS_RM_Current_CTC__c=s.Current_CTC__c;
                    le.EMS_RM_Current_Location__c=s.Current_Location__c;
                    le.Department=s.Department__c;
                    le.EMS_RM_Industry__c=s.Department_Name__c;
                    le.Description=s.Description__c;
                    le.EMS_RM_Current_Job_Role__c=s.Designation__c;
                    le.DoNotCall=s.Do_Not_Call__c;
                    le.EMS_Domain_Technology__c=s.Domain_Technology__c;
                    le.EMS_RM_Education__c=s.Education__c;
                    le.Email=s.Email__c;
                    le.EMS_RM_Resource_Email_id__c=s.Email_id__c;
                    le.HasOptedOutOfEmail=s.Email_Opt_Out__c;
                    le.EMS_Employee_type__c=s.Employee_type__c;
                    le.EMS_RM_Expected_CTC__c=s.Expected_CTC__c;
                    le.EMS_RM_Months__c=s.Experience_months__c;
                    le.EMS_RM_Years__c=s.Experience_Years__c;
                    le.Fax=s.Fax__c;
                    le.HasOptedOutOfFax=s.Fax_Opt_Out__c;
                    le.EMS_RM_FirstName__c=s.First_Name__c;
                    le.HomePhone=s.Home_Phone__c;
                    le.EMS_TM_In_Billing__c=s.In_Billing__c;
                    le.Interviewer__c=s.Interviewer__c;
                    le.EMS_Job_Application_Id__c=s.Job_Application_Id__c;
                    le.EMS_RM_Job_Title__c=s.Job_Title__c;
                    le.EMS_RM_LastName__c=s.Last_Name__c;
                    le.EMS_RM_Last_Working_day__c=s.Last_Working_Day__c;
                    le.LeadSource=s.Lead_Source__c;
                    le.Linkedin__c=s.Linkedin__c;
                    le.Location__c=s.Location__c;
                    le.MobilePhone=s.MobilePhone__c;
                    le.EMS_RM_Resource_Mobile_no__c=s.Mobile_no__c;
                    le.Official_Mail__c=s.Official_Mail__c;
                   // le.Other_Phone=s.OtherPhone__c;
                    le.EMS_RM_Permanent_Address__c=s.Permanent_Address__c;
                    le.Phone=s.Phone__c;
                    le.EMS_RM_Previous_Company_Name__c=s.Previous_Company_Name__c;
                    le.EMS_Projet_Budget__c=s.Project_Budget__c;
                    le.EMS_Recruiter__c=s.EMS_Recruiter__c;
                    le.ReportsToId=s.Reports_To__c;
                    le.Resume__c=s.Resume__c;
                    le.EMS_RM_Serving_Notice_Period__c=s.Serving_Notice_Period__c;
                    le.EMS_RM_ApplicantStatus_Update__c=s.Status__c;
                    le.Title=s.Title__c;
                    le.EMS_TM_User__c=s.User__c;
                    le.EMS_RM_CheckUserMail__c=s.User_Email__c;
                    le.EMS_website__c=s.Website__c;
                    le.EMS_Year_Founded_in__c=s.Year_Founded_in__c;
                    conlist1.add(le);
            }
            
        }
        
                  If(conlist1.size()>0)
                {
                       isCustomContactExcecution = true;
                       insert conlist1;
  
                 }            
    }
}