/**
* @author RK & SAI
* @date 10/01/2023
* @description  enableAndDisableBillableOnContactTest  written for enableAndDisableBillableOnContact
*               Test code coverage provided by the following test class:
*               - enableAndDisableBillableOnContactTest
*
* CHANGE HISTORY
* ====================================================================================================
* DATE          NAME                    DESCRIPTION
* N/A           N/A                     N/A
* ====================================================================================================
**/
@isTest
public class enableAndDisableBillableOnContactTest {
    @testSetup
    public static void setUp(){
        Resource_Role__c role = TestDataFactory.createResourceRole(true);
          /* EMS_LM_Leave__c ee =TestDataFactory.createLeaveType(false);
         ee.EMS_LM_Leave_Type__c ='Loss of Pay';
         Insert ee;*/
         EMS_LM_Leave__c annualtype = TestDataFactory.createLeaveType('Annual Leave',true);
        EMS_LM_Leave__c loptype = TestDataFactory.createLeaveType('Loss of Pay',true);
        EMS_LM_Leave__c bretype = TestDataFactory.createLeaveType('Maternity Leave',true);
        EMS_LM_Leave__c compofftype = TestDataFactory.createLeaveType('Compensatory Off',true);
        EMS_LM_Leave__c workfromhome = TestDataFactory.createLeaveType('Work From Home',true);
         Account acc = TestDataFactory.createAccount(true);
		 Contact con=  TestDataFactory.createResourceContact(acc.id, false);
         con.EMS_RM_Employee_Id__c = 'CP10235';
         con.Resource_Role__c = role.Id;
         insert con;
         User u = Testdatafactory.createCommunityUserWithAccAndContact(acc.id,con.Id,false);
        
        EMS_TM_Project__c projectRec = new EMS_TM_Project__c();
        projectRec.EMS_TM_StartDate__c = System.today();
        projectRec.EMS_TM_EndDate__c = System.today()+20;
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
        insert assignmentRec;
        
    }
    
    public static testmethod void contactBilableClose(){
        
        test.startTest();
        EMS_TM_Assignment__c assignRec =[SELECT Id,
                                         EMS_TM_EmployeeName__c,
                                         EMS_TM_Status_Asgn__c,
                                         EMS_TM_Billable__c
                                         FROM EMS_TM_Assignment__c 
                                         WHERE EMS_TM_EmployeeName__r.EMS_RM_Employee_Id__c  = 'CP10235' 
                                         LIMIT 1];
        									assignRec.EMS_TM_Billable__c = true;
                                            assignRec.EMS_TM_Status_Asgn__c='Active';
                                            try{
                                                update assignRec;            
                                            }catch(Exception e){
                                                
                                            }
        test.stopTest();
        
        contact conRecord =[SELECT Id,
                            LastName,
                            EMS_TM_In_Billing__c 
                            FROM contact 
                            WHERE EMS_RM_Employee_Id__c ='CP10235'
                            LIMIT 1];
        
        System.assertEquals(true, conRecord.EMS_TM_In_Billing__c );                
    }    
}