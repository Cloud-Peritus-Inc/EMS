public class CustomLeadUpdateFromStad implements Database.Batchable<sObject>{
    public Database.QueryLocator start(Database.BatchableContext BC)
    {
        String campaignName='CP 5Rings Campaign';
        String query='Select Id,Name,CampaignId,LeadId,Campaign.Name from CampaignMember where Campaign.Name=:campaignName';
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<CampaignMember> scope1){
        
        List<CP_Sales_lead__c>leadlist1=new List<CP_Sales_lead__c>(); 
        List<CP_Sales_lead__c>leadlist2=new List<CP_Sales_lead__c>(); 
        boolean value;
        Map<Id,Lead> mapId= new Map<Id,Lead>();
        Set<Id>leadId=new Set<Id>();
        For(CampaignMember s : scope1)
        {

                leadId.add(s.LeadId);
                System.debug(s.LeadId);
                // mapId.put(s.Id,s);
            
            
        }
        
       List<Lead>scope=[Select Id,Address,AnnualRevenue,Company,CreatedById,Jigsaw,Description,
                        DoNotCall,Email,HasOptedOutOfEmail,Fax,HasOptedOutOfFax,Industry,LastTransferDate,OwnerId,
                        LeadSource,Status,MobilePhone,Name,NumberOfEmployees,Notes__c,Phone,Rating,Title,
                        Website,(Select Id,Address__c,Company__c,Description__c,Do_Not_Call__c,Email__c, HasOptedOutOfEmail__c,Fax__c,
                         HasOptedOutOfFax__c,Industry__c,Lead_Source__c,Lead_Status__c,MobilePhone__c, Name,NumberOfEmployees__c,Annual_Revenue__c,
                         Notes__c,Phone__c,Rating__c,Title__c,Website__c,Lead__c from CP_Sales_leads__r) from Lead Where Id=:leadId];
        
        for(Lead s : scope)
        {
            For(CP_Sales_lead__c le:s.CP_Sales_leads__r)
            {
                
                System.debug(le.Lead__c);
                If(s.CP_Sales_leads__r.size()>0)
                {      System.debug('le.name'+le.Lead__c);
                 // le=new CP_Sales_lead__c();
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
                 le.NumberOfEmployees__c=s.NumberOfEmployees;
                 le.Notes__c=s.Notes__c;
                 //le.Notes_Campaign__c=s.Notes_Campaign__c;
                 le.Phone__c=s.Phone;
                 le.Rating__c=s.Rating;
                 le.Title__c=s.Title;
                 le.Website__c=s.Website;
                 leadlist1.add(le); 
                 leadId.remove(s.Id);
                }
                
            }
        }
        System.debug(leadId);
        
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
        If(leadlist1.size()>0)
        {
            Database.update(leadlist1,false);
            
        }
        If(leadlist2.size()>0)
        {
            Database.insert(leadlist2,false);
            
        } 
        
    }
    
    public void finish(Database.BatchableContext BC){
    }
}