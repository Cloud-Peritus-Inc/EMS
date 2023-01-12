public class LeadHandler {
    public static boolean isCustomLeadExcecution = false;
    public static void updateStandardHandler(List<CP_Sales_lead__c> leadlist2)
    {
         Set<Id>setid=new Set<Id>();
        For(CP_Sales_lead__c l:leadlist2)
        {
            setid.add(l.id);
        }
        List<CP_Sales_lead__c>leadlist=[Select Id,Address__c,Company__c,Description__c,Do_Not_Call__c,Email__c,
                         HasOptedOutOfEmail__c,OwnerId,Fax__c,HasOptedOutOfFax__c,Industry__c,Lead_Source__c,Lead_Status__c,MobilePhone__c,
                         Name,NumberOfEmployees__c,Annual_Revenue__c,Notes__c,Phone__c,Rating__c,Title__c,Website__c,(Select Id,Address,AnnualRevenue,Company,CreatedById,Jigsaw,Description,DoNotCall,Email,
                         HasOptedOutOfEmail,Fax,HasOptedOutOfFax,Industry,LastTransferDate,OwnerId,LeadSource,Status,MobilePhone,Name,NumberOfEmployees,Notes__c,Notes_Campaign__c,
                         Phone,Rating,Title,Website from Leads__r) from CP_Sales_lead__c
                         Where Id=:setid];
        
         List<Lead>leadlist1=new List<Lead>(); 
        
          For(CP_Sales_lead__c s:leadlist)
        {
            For(Lead le:s.Leads__r) 
            {
                     le.Sales_Lead__c=s.Id;
                    // le.Name=s.Name;
                     le.AnnualRevenue=s.Annual_Revenue__c; 
                     le.Company=s.Company__c;
                     le.Description=s.Description__c;
                     le.DoNotCall=s.Do_Not_Call__c;
                     le.Email=s.Email__c;
                     le.HasOptedOutOfEmail=s.HasOptedOutOfEmail__c;
                     le.Fax=s.Fax__c;
                     le.HasOptedOutOfFax=s.HasOptedOutOfFax__c;
                     le.Industry=s.Industry__c;
                     le.OwnerId=s.OwnerId;
                     le.LeadSource=s.Lead_Source__c;
                     le.Status=s.Lead_Status__c;
                     le.MobilePhone=s.MobilePhone__c;
                     le.NumberOfEmployees=Integer.valueOf(s.NumberOfEmployees__c);
                     le.Notes__c=s.Notes__c;
                     le.Phone=s.Phone__c;
                     le.Rating=s.Rating__c;
                     le.Title=s.Title__c;
                     le.Website=s.Website__c;
                     leadlist1.add(le);  
                 
                 
            }
        
        }
         If(leadlist1.size()>0)
           {
                       Database.update(leadlist1,false);
  
           }
        
    }
   public static void insertCustomHandler(List<CP_Sales_lead__c> leadlist2)
    {
        
         Set<Id>setid=new Set<Id>();
        For(CP_Sales_lead__c l:leadlist2)
        {
            setid.add(l.id);
        } 
        List<CP_Sales_lead__c>leadlist=[Select Id,Address__c,Company__c,Description__c,Do_Not_Call__c,Email__c,
                         HasOptedOutOfEmail__c,OwnerId,Fax__c,HasOptedOutOfFax__c,Industry__c,Lead_Source__c,Lead_Status__c,MobilePhone__c,
                         Name,NumberOfEmployees__c,Annual_Revenue__c,Notes__c,Phone__c,Rating__c,Title__c,Website__c, (Select Id from Leads__r) from CP_Sales_lead__c
                         Where Id=:setid];
        
        
       List<Lead> leadlist1 = new List<Lead>(); 
        For(CP_Sales_lead__c s:leadlist)
        {
            if(s.Leads__r.size()==0){
                     Lead le=new Lead();
                     le.Sales_Lead__c=s.Id;
                     le.LastName=s.Name;
                     le.AnnualRevenue=s.Annual_Revenue__c; 
                     le.Company=s.Company__c;
                     le.Description=s.Description__c;
                     le.DoNotCall=s.Do_Not_Call__c;
                     le.Email=s.Email__c;
                     le.HasOptedOutOfEmail=s.HasOptedOutOfEmail__c;
                     le.Fax=s.Fax__c;
                     le.HasOptedOutOfFax=s.HasOptedOutOfFax__c;
                     le.Industry=s.Industry__c;
                     le.OwnerId=s.OwnerId;
                     le.LeadSource=s.Lead_Source__c;
                     le.Status=s.Lead_Status__c;
                     le.MobilePhone=s.MobilePhone__c;
                     le.NumberOfEmployees=Integer.valueOf(s.NumberOfEmployees__c);
                     le.Notes__c=s.Notes__c;
                     le.Phone=s.Phone__c;
                     le.Rating=s.Rating__c;
                     le.Title=s.Title__c;
                     le.Website=s.Website__c;
                     leadlist1.add(le);  
            }
                 
        }
         If(leadlist1.size()>0)
           {	
               isCustomLeadExcecution = true;
               Database.insert(leadlist1,false);
  
           }


        
    }
    
}