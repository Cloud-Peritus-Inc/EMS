@isTest
public class activeAssignCountonContactTestclass {
 @testSetup
    public static void setUp(){
         Resource_Role__c role = TestDataFactory.createResourceRole(true);
         EMS_LM_Leave__c ee =TestDataFactory.createLeaveType(false);
         ee.EMS_LM_Leave_Type__c ='Loss of Pay';
         Insert ee;
         Account acc = TestDataFactory.createAccount(true);
		 Contact con=  TestDataFactory.createResourceContact(acc.id, false);
         con.EMS_RM_Employee_Id__c = 'CP10234';
         con.Resource_Role__c = role.Id;
         insert con;              
        EMS_TM_Project__c projectRec = new EMS_TM_Project__c();
        projectRec.EMS_TM_StartDate__c = System.today();
        projectRec.EMS_TM_EndDate__c = System.today()+10;
        projectRec.EMS_TM_Status__c = 'ongoing';
        projectRec.Name = 'project1';
        projectRec.Project_Manager__c = con.Id;
        projectRec.Type_Of_Project__c ='Client Projects';
        insert projectRec;        

        EMS_TM_Assignment__c assignmentRec = new EMS_TM_Assignment__c();
        assignmentRec.EMS_TM_EmployeeName__c = con.Id;
        assignmentRec.EMS_TM_ProjectName_Asgn__c = projectRec.Id;
        assignmentRec.EMS_TM_StartDate_Asgn__c = system.today();
        assignmentRec.EMS_TM_Billable__c = true;
        assignmentRec.EMS_TM_Status_Asgn__c ='Active';
        insert assignmentRec;
        EMS_TM_Assignment__c assignmentRec1 = new EMS_TM_Assignment__c();
        assignmentRec1.EMS_TM_EmployeeName__c = con.Id;
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
                            WHERE EMS_RM_Employee_Id__c ='CP10234'
                            LIMIT 1];
        //System.assertEquals(1, conRecord.Current_Active_Assignments__c );                
    }
}