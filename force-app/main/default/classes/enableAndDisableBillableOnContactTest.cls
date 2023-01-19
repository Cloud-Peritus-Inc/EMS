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
        EMS_TM_Project__c projectRec = new EMS_TM_Project__c();
        projectRec.EMS_TM_StartDate__c = System.today();
        projectRec.EMS_TM_Status__c = 'ongoing';
        projectRec.Name = 'project1';
        projectRec.RecordTypeId = ProjectConstant.PROJECT_RECORDTYPEID;
        insert projectRec;
        
        contact contactRec = new contact();
        contactRec.LastName = 'rk';
        contactRec.Official_Mail__c ='rama@rama.com';
        contactRec.Phone = '9652901075';
        contactRec.EMS_Phone_Number__c = '9652901075';
        contactRec.RecordTypeId = ContactConstant.RESOURCE_RECORDTYPEID;
        contactRec.EMS_EM_JD__c = system.today();
        insert contactRec;
                
        EMS_TM_Assignment__c assignmentRec = new EMS_TM_Assignment__c();
        assignmentRec.EMS_TM_EmployeeName__c = contactRec.Id;
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
                                         WHERE EMS_TM_EmployeeName__r.lastname  = 'rk' 
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
                            WHERE lastname ='rk'
                            LIMIT 1];
        
        System.assertEquals(true, conRecord.EMS_TM_In_Billing__c );                
    }    
}