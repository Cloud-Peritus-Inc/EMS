public class StandardLeadContactHandler {
   public static Boolean firstTime=false;

    public static void insertLead(List<CampaignMember>CampaignMember)
    { 
        Set<Id>leadId=new Set<Id>();
        List<CP_Sales_lead__c>leadlist2=new List<CP_Sales_lead__c>(); 
        Set<Id>camId=new Set<Id>();
        
        
         For(CampaignMember s :CampaignMember)

        {
                 camId.add(s.Id);
                System.debug(s.LeadId); 
        }
        List<CampaignMember>capaignmemberlist=[Select Id,Name,CampaignId,LeadId,Campaign.Name from CampaignMember where Id=:camId];
        
        For(CampaignMember cam:capaignmemberlist)
        {
            If(cam.Campaign.Name=='CP 5Rings Campaign')
            {
            leadId.add(cam.LeadId);
            System.debug('LeadId'+LeadId);
            }
        }
        
  List<Lead> listlead=[Select Id,Address,AnnualRevenue,Company,CreatedById,Jigsaw,Description,DoNotCall,Email,HasOptedOutOfEmail,Fax,HasOptedOutOfFax,Industry,LastTransferDate,OwnerId,LeadSource,Status,MobilePhone,Name,NumberOfEmployees,Notes__c,Phone,Rating,Title,Website from Lead where Id=:leadId];
        If(listlead!=null && listlead.size()>0)
        {
            For(Lead s:listlead)
            {
                CP_Sales_lead__c  le=new CP_Sales_lead__c();
                le.Lead__c=s.Id;
                le.Name=s.Name;
                le.Annual_Revenue__c=s.AnnualRevenue; 
                le.Annual_Revenue__c=s.AnnualRevenue;
                le.Company__c=s.Company;
                le.Description__c=s.Description;
                le.Do_Not_Call__c=s.DoNotCall;
                le.Email__c=s.Email;
                le.HasOptedOutOfEmail__c=s.HasOptedOutOfEmail;
                le.Fax__c=s.Fax;
                le.HasOptedOutOfFax__c=s.HasOptedOutOfFax;
                le.Industry__c=s.Industry;
                le.LastTransferDate__c=s.LastTransferDate;
                le.OwnerId=s.OwnerId;
                le.Lead_Source__c=s.LeadSource;
                le.Lead_Status__c=s.Status;
                le.MobilePhone__c=s.MobilePhone;
                le.Name=s.Name;
                le.NumberOfEmployees__c=s.NumberOfEmployees;
                le.Notes__c=s.Notes__c;
               // le.Notes_Campaign__c=s.Notes_Campaign__c;
                le.Phone__c=s.Phone;
                le.Rating__c=s.Rating;
                le.Title__c=s.Title;
                le.Website__c=s.Website;
                leadlist2.add(le);
                
                
            }
        }

        If(leadlist2.size()>0)
        {
            insert leadlist2;
            
        }         
    }
    public static void insertContact(List<CampaignMember>CampaignMember)
    {
        
       List<CP_Sales_Contact__c>contactlist2=new List<CP_Sales_Contact__c>(); 
       Set<Id>contactId=new Set<Id>();  
        Set<Id>camId=new Set<Id>();

      
          For(CampaignMember s :CampaignMember)

        {
                 camId.add(s.Id);
                System.debug(s.Id); 
        }
      
         List<CampaignMember>capaignmemberlist=[Select Id,Name,CampaignId,ContactId,Campaign.Name from CampaignMember where Id=:camId];
        
        For(CampaignMember cam:capaignmemberlist)
        {
            If(cam.Campaign.Name=='CP 5Rings Campaign')
            {
            contactId.add(cam.contactId);
            System.debug('contactId'+contactId);
            }
        }
        
       List<Contact>listcontact=[Select Id,AccountId,Name__c,EMS_RM_Applicant_Profile_Completed__c,AssistantName,AssistantPhone,EMS_TM_Billable__c,
                           Birthdate,EMS_RM_Candidate_Id__c,EMS_RM_Certifications__c,EMS_Client_id__c,EMS_RM_University_Name__c,EMS_Company_name__c,
                           Current_Active_Assignments__c,EMS_RM_Current_CTC__c,EMS_RM_Current_Location__c,Department,EMS_RM_Industry__c,Description,
                           EMS_RM_Current_Job_Role__c,DoNotCall,EMS_Domain_Technology__c,EMS_RM_Domain_Technology__c,EMS_RM_Education__c,Email,EMS_RM_Resource_Email_id__c,
                           HasOptedOutOfEmail,EMS_RM_Employee_Id__c,EMS_Employee_type__c,EMS_RM_Expected_CTC__c,EMS_RM_Months__c,EMS_RM_Years__c,
                           Fax,HasOptedOutOfFax,EMS_RM_FirstName__c,HomePhone,EMS_TM_In_Billing__c,Interviewer__c,EMS_Job_Application_Id__c	,EMS_RM_Job_Title__c,
                           EMS_RM_LastName__c,LastCURequestDate,LastCUUpdateDate,EMS_RM_Last_Working_day__c,LeadSource,Linkedin__c,Location__c,MailingAddress,
                           MobilePhone,EMS_RM_Resource_Mobile_no__c,Name,EMS_RM_Notice_Period__c,Official_Mail__c,OtherAddress,OtherPhone,EMS_RM_Permanent_Address__c,
                           Phone,EMS_Phone_Number__c,EMS_RM_Phone_Number__c,EMS_RM_Previous_Company_Name__c,EMS_Projet_Budget__c,EMS_Recruiter__c,ReportsToId,Resume__c,EMS_RM_Serving_Notice_Period__c,
                          EMS_RM_ApplicantStatus_Update__c,Title,EMS_TM_User__c,EMS_RM_CheckUserMail__c,EMS_website__c,EMS_Year_Founded_in__c
                            from Contact Where Id=:contactId];
        
        
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
                    //le.Notice_period__c=s.EMS_RM_Notice_Period__c;
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
      
         If(contactlist2.size()>0)
        {
           Database.insert(contactlist2,false);
            
        } 
                

  } 
}