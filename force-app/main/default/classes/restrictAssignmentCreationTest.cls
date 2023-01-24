/**
* @author SAI
* @date 10/01/2023
* @description  restrictAssignmentCreation Class to when Project status as a Commpleate
*               then need restric the Assignment
*
*               Test code coverage provided by the following test class:
*               - restrictAssignmentCreationTest
*
* CHANGE HISTORY
* ====================================================================================================
* DATE          NAME                    DESCRIPTION
* N/A           N/A                     N/A
* ====================================================================================================
**/
@isTest
public class restrictAssignmentCreationTest {
     @testSetup
    public static void setUp(){
        EMS_TM_Project__c projectRec = new EMS_TM_Project__c();
        projectRec.EMS_TM_StartDate__c = System.today();
        projectRec.EMS_TM_Status__c = 'Completed';
        projectRec.Name = 'project45';
        projectRec.RecordTypeId = ProjectConstant.PROJECT_RECORDTYPEID;
        insert projectRec;
        
        contact contactRec = new contact();
        contactRec.LastName = 'Sai';
        contactRec.Official_Mail__c ='saich737@gmail.com';
        contactRec.Phone = '9603226988';
        contactRec.EMS_Phone_Number__c = '7997756693';
        contactRec.RecordTypeId = ContactConstant.RESOURCE_RECORDTYPEID;
        contactRec.EMS_EM_JD__c = system.today();
        insert contactRec;
        
        
}
    public static testmethod void ProjectStausCompleate(){
        test.startTest();
        EMS_TM_Project__c ProjRco=[SELECT Id,
                                         EMS_TM_StartDate__c,
                                         EMS_TM_Status__c,
                                         Name
                                         FROM EMS_TM_Project__c 
                                         WHERE  Name = 'project45' 
                                         LIMIT 1];
         contact conRecord =[SELECT Id,
                            LastName,
                            EMS_TM_In_Billing__c 
                            FROM contact 
                            WHERE lastname ='Sai'
                            LIMIT 1];
        
        EMS_TM_Assignment__c assignmentRec = new EMS_TM_Assignment__c();
        assignmentRec.EMS_TM_EmployeeName__c = conRecord.Id;
        assignmentRec.EMS_TM_ProjectName_Asgn__c = ProjRco.Id;
        assignmentRec.EMS_TM_StartDate_Asgn__c = system.today();
        assignmentRec.EMS_TM_Billable__c = true;
        try{
              Insert assignmentRec;            
            }catch(Exception e){
            }
         test.stopTest();                    
        
    }
}