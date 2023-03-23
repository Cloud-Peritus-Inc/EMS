public class CustomLeadUpdateHandler {
    public static boolean isLeadTriggerExecuted = false;
    public static void updateCustomLead(List<Lead> leadlist){
        Set<Id> leadIdSet=new Set<Id>();
        For(Lead l:leadlist)
        {
            leadIdSet.add(l.id);
        }
        
        List<CP_Sales_lead__c> leadlist1=new List<CP_Sales_lead__c>();
        //List<CampaignMember> campaignMemberList = [Select Id,Name,CampaignId,LeadId,Campaign.Name from CampaignMember where Campaign.Name='CP 5Rings Campaign'];
        List<Lead> scope=[Select Id,Sales_Lead__c, Address,AnnualRevenue,Company,CreatedById,Jigsaw,Description,
                        DoNotCall,Email,HasOptedOutOfEmail,Fax,HasOptedOutOfFax,Industry,LastTransferDate,OwnerId,
                        LeadSource,Status,MobilePhone,Name,NumberOfEmployees,Notes__c,Phone,Rating,Title,
                        Website from Lead Where Id=:leadIdSet];
        
        for(Lead s : scope)
        {
            
                CP_Sales_lead__c le = new CP_Sales_lead__c();
                
            if(s.Sales_Lead__c <> null)   {
                 // le=new CP_Sales_lead__c();
                 le.id = s.Sales_Lead__c;
                 //le.Lead__c=s.Id;
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
                 le.NumberOfEmployees__c=s.NumberOfEmployees;
                 le.Notes__c=s.Notes__c;
                 //le.Notes_Campaign__c=s.Notes_Campaign__c;
                 le.Phone__c=s.Phone;
                 le.Rating__c=s.Rating;
                 le.Title__c=s.Title;
                 le.Website__c=s.Website;
                 leadlist1.add(le); 
                 }                
        }
                
        
        If(leadlist1.size()>0)
        {
            isLeadTriggerExecuted = true;
            Database.update(leadlist1,true);
            
        }
    }
}