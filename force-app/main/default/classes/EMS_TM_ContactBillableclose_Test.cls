@istest
public class EMS_TM_ContactBillableclose_Test {
   
    public static testmethod void contactBilableClose(){
        recordtype r =[SELECT Id, Name, SobjectType, DeveloperName, IsActive FROM RecordType where name ='Client Projects'];
        EMS_TM_Project__c p = new EMS_TM_Project__c();
        p.EMS_TM_StartDate__c = System.today();
        p.EMS_TM_Status__c = 'ongoing';
        p.Name = 'project1';
        p.RecordTypeId = r.id;
        insert p;
        recordtype r1 =[SELECT Id, Name, SobjectType, DeveloperName, IsActive FROM RecordType where name ='Resource' AND Isactive = true];
        contact c = new contact();
        c.LastName = 'rk';
        c.Official_Mail__c ='rama@rama.com';
        c.Phone = '9652901075';
        c.EMS_Phone_Number__c = '9652901075';
        c.RecordTypeId = r1.Id;
        c.EMS_EM_JD__c = system.today();
        insert c;
        
        
        EMS_TM_Assignment__c a = new EMS_TM_Assignment__c();
        a.EMS_TM_EmployeeName__c = c.id;
        a.EMS_TM_ProjectName_Asgn__c = p.id;
        a.EMS_TM_StartDate_Asgn__c = system.today();
        a.EMS_TM_Billable__c = true;
       // a.Name = 'assign1';
        insert a;
        
        test.startTest();
        EMS_TM_Assignment__c aa =[Select id,EMS_TM_EmployeeName__c,EMS_TM_Status_Asgn__c,EMS_TM_Billable__c from EMS_TM_Assignment__c 
                                       where EMS_TM_EmployeeName__r.lastname  = 'rk'];
        aa.EMS_TM_Billable__c = false;
        update aa;
        test.stopTest();
        
               
    }
}