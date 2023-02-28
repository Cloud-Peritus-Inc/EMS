@isTest
public class activeAssignCountonContactTestclass {
 @testSetup
    public static void setUp(){
        contact contactRec = new contact();
        contactRec.LastName = 'rk';
        contactRec.Official_Mail__c ='rama@rama.com';
        contactRec.Phone = '9652901075';
        contactRec.EMS_Phone_Number__c = '9652901075';
        contactRec.RecordTypeId = ContactConstant.RESOURCE_RECORDTYPEID;
        contactRec.EMS_EM_JD__c = system.today();
        insert contactRec;               
        EMS_TM_Project__c projectRec = new EMS_TM_Project__c();
        projectRec.EMS_TM_StartDate__c = System.today();
        projectRec.EMS_TM_EndDate__c = System.today()+10;
        projectRec.EMS_TM_Status__c = 'ongoing';
        projectRec.Name = 'project1';
        projectRec.Project_Manager__c = contactRec.Id;
        projectRec.Type_Of_Project__c ='Client Projects';
        insert projectRec;        

        EMS_TM_Assignment__c assignmentRec = new EMS_TM_Assignment__c();
        assignmentRec.EMS_TM_EmployeeName__c = contactRec.Id;
        assignmentRec.EMS_TM_ProjectName_Asgn__c = projectRec.Id;
        assignmentRec.EMS_TM_StartDate_Asgn__c = system.today();
        assignmentRec.EMS_TM_Billable__c = true;
        insert assignmentRec;
        EMS_TM_Assignment__c assignmentRec1 = new EMS_TM_Assignment__c();
        assignmentRec1.EMS_TM_EmployeeName__c = contactRec.Id;
        assignmentRec1.EMS_TM_ProjectName_Asgn__c = projectRec.Id;
        assignmentRec1.EMS_TM_StartDate_Asgn__c = system.today();
        assignmentRec1.EMS_TM_Billable__c = true;
        insert assignmentRec1;        
    }    
    public static testmethod void activeAssignmentcount(){        
        test.startTest();
        EMS_TM_Assignment__c assignRec =[SELECT Id,
                                         EMS_TM_EmployeeName__c,
                                         EMS_TM_Status_Asgn__c,
                                         EMS_TM_Billable__c
                                         FROM EMS_TM_Assignment__c 
                                         LIMIT 1];
                                            try{
                                                Delete assignRec;            
                                            }catch(Exception e){
                                                
                                            }
        test.stopTest();       
        contact conRecord =[SELECT Id,
                            LastName,
                            Current_Active_Assignments__c 
                            FROM contact 
                            WHERE lastname ='rk'
                            LIMIT 1];
        System.assertEquals(1, conRecord.Current_Active_Assignments__c );                
    }
}