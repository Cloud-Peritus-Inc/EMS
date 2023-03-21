public class CustomContactUpdateFromStad implements Database.Batchable<sObject>{
 public Database.QueryLocator start(Database.BatchableContext BC)
    {
        String campaignName='CP 5Rings Campaign';
        String query='Select Id,Name,CampaignId,ContactId,Campaign.Name from CampaignMember where Campaign.Name=:campaignName';
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<CampaignMember> scope1)
    {
        List<CP_Sales_Contact__c>contactlist1=new List<CP_Sales_Contact__c>(); 
        List<CP_Sales_Contact__c>contactlist2=new List<CP_Sales_Contact__c>(); 

        Set<Id>conId=new set<Id>();
        For(CampaignMember s : scope1)
        {

                conId.add(s.ContactId);
               
        }
        List<Contact>scope=[Select Id,AccountId,Name__c,EMS_RM_Applicant_Profile_Completed__c,AssistantName,AssistantPhone,EMS_TM_Billable__c,
                           Birthdate,EMS_RM_Candidate_Id__c,EMS_RM_Certifications__c,EMS_Client_id__c,EMS_RM_University_Name__c,EMS_Company_name__c,
                           Current_Active_Assignments__c,EMS_RM_Current_CTC__c,EMS_RM_Current_Location__c,Department,EMS_RM_Industry__c,Description,
                           EMS_RM_Current_Job_Role__c,DoNotCall,EMS_Domain_Technology__c,EMS_RM_Domain_Technology__c,EMS_RM_Education__c,Email,EMS_RM_Resource_Email_id__c,
                           HasOptedOutOfEmail,EMS_RM_Employee_Id__c,EMS_Employee_type__c,EMS_RM_Expected_CTC__c,EMS_RM_Months__c,EMS_RM_Years__c,
                           Fax,HasOptedOutOfFax,EMS_RM_FirstName__c,HomePhone,EMS_TM_In_Billing__c,Interviewer__c,EMS_Job_Application_Id__c ,EMS_RM_Job_Title__c,
                           EMS_RM_LastName__c,LastCURequestDate,LastCUUpdateDate,EMS_RM_Last_Working_day__c,LeadSource,Linkedin__c,Location__c,MailingAddress,
                           MobilePhone,EMS_RM_Resource_Mobile_no__c,Name,Notice_Period__c,Official_Mail__c,OtherAddress,OtherPhone,EMS_RM_Permanent_Address__c,
                           Phone,EMS_Phone_Number__c,EMS_RM_Phone_Number__c,EMS_RM_Previous_Company_Name__c,EMS_Projet_Budget__c,EMS_Recruiter__c,ReportsToId,Resume__c,EMS_RM_Serving_Notice_Period__c,
                          EMS_RM_ApplicantStatus_Update__c,Title,EMS_TM_User__c,EMS_RM_CheckUserMail__c,EMS_website__c,EMS_Year_Founded_in__c,
                            (SELECT Id, OwnerId, IsDeleted, Name, RecordTypeId, CreatedDate, CreatedById, LastModifiedDate, 
                           LastModifiedById, SystemModstamp, LastViewedDate, LastReferencedDate, Account__c, Name__c, EMS_RM_Applicant_Profile_Completed__c, 
                          AssistantName__c, AssistantPhone__c, Billable__c, Birthdate__c, EMS_RM_Candidate_Id__c, EMS_RM_Certifications__c, Client_id__c, College_University_Name__c,Company_Name__c, 
                          Owner__c, CreatedById__c, Current_Active_Assignments__c, Current_CTC__c, Current_Location__c, Jigsaw__c, Department__c, Department_Name__c, Description__c,
                           Designation__c, Do_Not_Call__c, Domain_Technology__c, Education__c, Email__c, Email_id__c, Email_Opt_Out__c, Employee_Id__c, Employee_type__c, Expected_CTC__c,
                          Experience_months__c, Experience_Years__c, Fax__c, Fax_Opt_Out__c, First_Name__c, Home_Phone__c, In_Billing__c, Interviewer__c, Job_Application_Id__c, Job_Title__c,
                         Last_Name__c, Last_Stay_in_Touch_Request_Date__c, Last_Stay_in_Touch_Save_Date__c, Last_Working_Day__c, Lead_Source__c, Linkedin__c, Location__c, Mailing_Address__c, 
                         MobilePhone__c, Mobile_no__c, Contact__c, Name_C__c, Notice_period__c, Official_Mail__c, Other_Address__c, Other_Phone__c, Permanent_Address__c, Phone__c, Phone_Number__c,
                           Previous_Company_Name__c, Project_Budget__c, EMS_Recruiter__c, Reports_To__c, Resume__c, Serving_Notice_Period__c, Status__c, Title__c, User__c, User_Email__c, Website__c, 
                          Year_Founded_in__c FROM CP_Sales_Contacts__r)
                            from Contact Where Id=:conId];
        
         for(Contact s : scope)
        {
            For(CP_Sales_Contact__c le:s.CP_Sales_Contacts__r)
            {
               
                If(s.CP_Sales_Contacts__r!=null && s.CP_Sales_Contacts__r.size()>0)
                {  
                    le.Account__c=s.AccountId;
                    le.Name=s.Name;
                     le.Phone_Number__c=s.EMS_RM_Phone_Number__c;

                    le.EMS_RM_Applicant_Profile_Completed__c=s.EMS_RM_Applicant_Profile_Completed__c;
                    le.AssistantName__c=s.AssistantName;
                    le.AssistantPhone__c=s.AssistantPhone;
                    //le.EMS_TM_Billable__c =s.EMS_TM_Billable__c;
                   le.Birthdate__c= s.Birthdate;
                    le.EMS_RM_Certifications__c=s.EMS_RM_Certifications__c;
                  
                    
                    le.EMS_RM_Applicant_Profile_Completed__c=s.EMS_RM_Applicant_Profile_Completed__c;
                    le.AssistantName__c=s.AssistantName;
                    le.AssistantPhone__c=s.AssistantPhone;
                    le.Billable__c=s.EMS_TM_Billable__c;
                    le.Birthdate__c=s.Birthdate;
                    le.Company_Name__c=s.EMS_Company_name__c;
                    le.Name=s.Name;
                    //le.CreatedById__c=s.CreatedById;
                    //le.CreatedById=s.
                    le.Current_Active_Assignments__c=s.Current_Active_Assignments__c;
                    le.Current_CTC__c=s.EMS_RM_Current_CTC__c;
                    le.Current_Location__c=s.EMS_RM_Current_Location__c;
                    le.Department__c=s.Department;
                    le.Department_Name__c=s.EMS_RM_Industry__c;
                    le.Description__c=s.Description;
                    le.Designation__c=s.EMS_RM_Current_Job_Role__c;
                    le.Do_Not_Call__c=s.DoNotCall;
                    le.Domain_Technology__c=s.EMS_Domain_Technology__c;
                    le.Education__c=s.EMS_RM_Education__c;
                    le.Email__c=s.Email;
                    le.Email_id__c=s.EMS_RM_Resource_Email_id__c;
                    le.Email_Opt_Out__c=s.HasOptedOutOfEmail;
                    //le.Employee_Id__c=s.EMS_RM_Employee_Id__c;  --AutoNumber
                    le.Employee_type__c=s.EMS_Employee_type__c;
                    le.Expected_CTC__c=s.EMS_RM_Expected_CTC__c;
                    le.Experience_months__c=s.EMS_RM_Months__c;
                    le.Experience_Years__c=s.EMS_RM_Years__c;
                    le.Fax__c=s.Fax;
                    le.Fax_Opt_Out__c=s.HasOptedOutOfFax;
                    le.First_Name__c=s.EMS_RM_FirstName__c;
                    le.Home_Phone__c=s.HomePhone;
                    le.In_Billing__c=s.EMS_TM_In_Billing__c;
                    le.Interviewer__c=s.Interviewer__c;
                    le.Job_Application_Id__c=s.EMS_Job_Application_Id__c;
                    le.Job_Title__c=s.EMS_RM_Job_Title__c;
                    //le.LastModifiedById=s.
                    le.Last_Name__c=s.EMS_RM_LastName__c;
                    le.Last_Stay_in_Touch_Request_Date__c=s.LastCURequestDate;
                    le.Last_Stay_in_Touch_Save_Date__c=s.LastCUUpdateDate;
                    le.Last_Working_Day__c=s.EMS_RM_Last_Working_day__c;
                    le.Lead_Source__c=s.LeadSource;
                    le.Linkedin__c=s.Linkedin__c;
                    le.Location__c=s.Location__c;
                    le.MobilePhone__c=s.MobilePhone;
                    le.Mobile_no__c=s.EMS_RM_Resource_Mobile_no__c;
                    le.Name_C__c=s.Name;
                    //le.Notice_period__c=s.Notice_Period__c;
                    le.Official_Mail__c=s.Official_Mail__c;
                    le.Other_Phone__c=s.OtherPhone;
                    //le.OwnerId=s.
                    le.Permanent_Address__c=s.EMS_RM_Permanent_Address__c;
                    le.Phone__c=s.Phone;
                    //le.Phone_Number__c=s.EMS_Phone_Number__c;
                    le.Previous_Company_Name__c=s.EMS_RM_Previous_Company_Name__c;
                    le.Project_Budget__c=s.EMS_Projet_Budget__c;
                    //le.RecordTypeId=s.
                    le.EMS_Recruiter__c=s.EMS_Recruiter__c;
                    le.Reports_To__c=s.ReportsToId;
                    le.Resume__c=s.Resume__c;
                    le.Serving_Notice_Period__c=s.EMS_RM_Serving_Notice_Period__c;
                    le.Status__c=s.EMS_RM_ApplicantStatus_Update__c;
                    le.Title__c=s.Title;
                    le.User__c=s.EMS_TM_User__c;
                    le.User_Email__c=s.EMS_RM_CheckUserMail__c;
                    le.Website__c=s.EMS_website__c;
                    le.Year_Founded_in__c=s.EMS_Year_Founded_in__c;
                    contactlist1.add(le);
                    conId.remove(s.Id);
                    
                }
                
                
                
            }
            
        }
        
        List<Contact>listcontact=[Select Id,AccountId,Name__c,EMS_RM_Applicant_Profile_Completed__c,AssistantName,AssistantPhone,EMS_TM_Billable__c,
                           Birthdate,EMS_RM_Candidate_Id__c,EMS_RM_Certifications__c,EMS_Client_id__c,EMS_RM_University_Name__c,EMS_Company_name__c,
                           Current_Active_Assignments__c,EMS_RM_Current_CTC__c,EMS_RM_Current_Location__c,Department,EMS_RM_Industry__c,Description,
                           EMS_RM_Current_Job_Role__c,DoNotCall,EMS_Domain_Technology__c,EMS_RM_Domain_Technology__c,EMS_RM_Education__c,Email,EMS_RM_Resource_Email_id__c,
                           HasOptedOutOfEmail,EMS_RM_Employee_Id__c,EMS_Employee_type__c,EMS_RM_Expected_CTC__c,EMS_RM_Months__c,EMS_RM_Years__c,
                           Fax,HasOptedOutOfFax,EMS_RM_FirstName__c,HomePhone,EMS_TM_In_Billing__c,Interviewer__c,EMS_Job_Application_Id__c ,EMS_RM_Job_Title__c,
                           EMS_RM_LastName__c,LastCURequestDate,LastCUUpdateDate,EMS_RM_Last_Working_day__c,LeadSource,Linkedin__c,Location__c,MailingAddress,
                           MobilePhone,EMS_RM_Resource_Mobile_no__c,Name,Notice_Period__c,Official_Mail__c,OtherAddress,OtherPhone,EMS_RM_Permanent_Address__c,
                           Phone,EMS_Phone_Number__c,EMS_RM_Phone_Number__c,EMS_RM_Previous_Company_Name__c,EMS_Projet_Budget__c,EMS_Recruiter__c,ReportsToId,Resume__c,EMS_RM_Serving_Notice_Period__c,
                          EMS_RM_ApplicantStatus_Update__c,Title,EMS_TM_User__c,EMS_RM_CheckUserMail__c,EMS_website__c,EMS_Year_Founded_in__c
                            from Contact Where Id=:conId];
        
        If(listcontact!=null && listcontact.size()>0)
        {
            For(Contact s:listcontact)
            {
               CP_Sales_Contact__c con=new CP_Sales_Contact__c(); 
                 con.Contact__c=s.Id;
                 con.Account__c=s.AccountId;
                 con.Name=s.Name;        
                // con.Phone_Number__c=s.EMS_RM_Phone_Number__c;
                 con.Phone_Number__c='123456789';

                 con.EMS_RM_Applicant_Profile_Completed__c=s.EMS_RM_Applicant_Profile_Completed__c;
                 con.AssistantName__c=s.AssistantName;
                 con.AssistantPhone__c=s.AssistantPhone;
                    //le.EMS_TM_Billable__c =s.EMS_TM_Billable__c;
                 con.Birthdate__c= s.Birthdate;
                 con.EMS_RM_Certifications__c=s.EMS_RM_Certifications__c;
                  con.EMS_RM_Applicant_Profile_Completed__c=s.EMS_RM_Applicant_Profile_Completed__c;
                   con.AssistantName__c=s.AssistantName;
                   con.AssistantPhone__c=s.AssistantPhone;
                   con.Billable__c=s.EMS_TM_Billable__c;
                   con.Birthdate__c=s.Birthdate;
                    con.Company_Name__c=s.EMS_Company_name__c;
                    con.Name=s.Name;
                    //le.CreatedById__c=s.CreatedById;
                    //le.CreatedById=s.
                    con.Current_Active_Assignments__c=s.Current_Active_Assignments__c;
                    con.Current_CTC__c=s.EMS_RM_Current_CTC__c;
                    con.Current_Location__c=s.EMS_RM_Current_Location__c;
                    con.Department__c=s.Department;
                    con.Department_Name__c=s.EMS_RM_Industry__c;
                    con.Description__c=s.Description;
                    con.Designation__c=s.EMS_RM_Current_Job_Role__c;
                    con.Do_Not_Call__c=s.DoNotCall;
                    con.Domain_Technology__c=s.EMS_Domain_Technology__c;
                    con.Education__c=s.EMS_RM_Education__c;
                    con.Email__c=s.Email;
                    con.Email_id__c=s.EMS_RM_Resource_Email_id__c;
                    con.Email_Opt_Out__c=s.HasOptedOutOfEmail;
                    //le.Employee_Id__c=s.EMS_RM_Employee_Id__c;  --AutoNumber
                    con.Employee_type__c=s.EMS_Employee_type__c;
                    con.Expected_CTC__c=s.EMS_RM_Expected_CTC__c;
                    con.Experience_months__c=s.EMS_RM_Months__c;
                    con.Experience_Years__c=s.EMS_RM_Years__c;
                    con.Fax__c=s.Fax;
                    con.Fax_Opt_Out__c=s.HasOptedOutOfFax;
                    con.First_Name__c=s.EMS_RM_FirstName__c;
                    con.Home_Phone__c=s.HomePhone;
                    con.In_Billing__c=s.EMS_TM_In_Billing__c;
                    con.Interviewer__c=s.Interviewer__c;
                    con.Job_Application_Id__c=s.EMS_Job_Application_Id__c;
                    con.Job_Title__c=s.EMS_RM_Job_Title__c;
                    //le.LastModifiedById=s.
                    con.Last_Name__c=s.EMS_RM_LastName__c;
                    con.Last_Stay_in_Touch_Request_Date__c=s.LastCURequestDate;
                    con.Last_Stay_in_Touch_Save_Date__c=s.LastCUUpdateDate;
                    con.Last_Working_Day__c=s.EMS_RM_Last_Working_day__c;
                    con.Lead_Source__c=s.LeadSource;
                    con.Linkedin__c=s.Linkedin__c;
                    con.Location__c=s.Location__c;
                    con.MobilePhone__c=s.MobilePhone;
                    con.Mobile_no__c=s.EMS_RM_Resource_Mobile_no__c;
                    con.Name_C__c=s.Name;
                    //le.Notice_period__c=s.Notice_Period__c;
                     con.Official_Mail__c=s.Official_Mail__c;
                    con.Other_Phone__c=s.OtherPhone;
                    //le.OwnerId=s.
                    con.Permanent_Address__c=s.EMS_RM_Permanent_Address__c;
                    con.Phone__c=s.Phone;
                    //le.Phone_Number__c=s.EMS_Phone_Number__c;
                    con.Previous_Company_Name__c=s.EMS_RM_Previous_Company_Name__c;
                    con.Project_Budget__c=s.EMS_Projet_Budget__c;
                    //le.RecordTypeId=s.
                    con.EMS_Recruiter__c=s.EMS_Recruiter__c;
                    con.Reports_To__c=s.ReportsToId;
                    con.Resume__c=s.Resume__c;
                    con.Serving_Notice_Period__c=s.EMS_RM_Serving_Notice_Period__c;
                    con.Status__c=s.EMS_RM_ApplicantStatus_Update__c;
                    con.User__c=s.EMS_TM_User__c;
                    con.User_Email__c=s.EMS_RM_CheckUserMail__c;
                    con.Website__c=s.EMS_website__c;
                    con.Year_Founded_in__c=s.EMS_Year_Founded_in__c;
                     contactlist2.add(con);
                
            }
        }
        
        
        If(contactlist1.size()>0)
        {
           Database.update(contactlist1,false);
            
        } 
         If(contactlist2.size()>0)
        {
           Database.insert(contactlist2,false);
            
        } 
        
    }
     public void finish(Database.BatchableContext BC){
    }
}