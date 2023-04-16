@isTest
public class createGoalForNewEmployeesTest {
    static List<Contact> conList;
    static Map<Id, Contact> conMap;
    @testSetup static void setup() {
        user adminuser = TestDataFactory.createAdminUser(true);
        Resource_Role__c techLead;
        Resource_Role__c emp;
        Resource_Role__c projectManager;
        Account acc;
        Contact con;
        Contact leadcontact;
        EMS_LM_Leave__c annualtype;
        Resource_Resource_Relationship__c rrr;
        conList = new List<Contact>();
        conMap = new Map<Id, Contact>();
        system.runAs(adminuser) {
            
            techLead = TestDataFactory.createResourceRole('Software Engineer',true); 
            emp = TestDataFactory.createResourceRole('tech Engineer',false);
            emp.Level_of_Approval__c = 2;
            insert emp;
            
            annualtype = TestDataFactory.createLeaveType('Annual Leave',true);
            EMS_LM_Leave__c loptype = TestDataFactory.createLeaveType('Loss of Pay',true);
            EMS_LM_Leave__c bretype = TestDataFactory.createLeaveType('Maternity Leave',true);
            EMS_LM_Leave__c compofftype = TestDataFactory.createLeaveType('Compensatory Off',true);
            EMS_LM_Leave__c wfhtype = TestDataFactory.createLeaveType('Work From Home',true);
            
            
            acc = TestDataFactory.createAccount(true);
            con = TestDataFactory.createResourceContact(acc.id, false);
            con.EMS_RM_Employee_Id__c = 'CP10234';
            con.Resource_Role__c = techLead.Id;
            con.EMS_LM_No_Of_Maternity_Leaves_Credit__c = 0;
            con.EMS_LM_No_Of_Leaves_Credit__c = 10;
            con.RecordTypeId = ContactConstant.RESOURCE_RECORDTYPEID;
            con.EMS_RM_ApplicantStatus_Update__c = 'Active';
            insert con;
            if (con.Id != null) {
                conList.add(con);
                conMap.put(con.Id, con);
            }
            
            System.debug('con'+ con);
            leadcontact = TestDataFactory.createResourceContactForRRR(acc.id, false);
            leadcontact.EMS_RM_Employee_Id__c = 'CP10235';
            leadcontact.Resource_Role__c = emp.Id;
            leadcontact.EMS_LM_No_Of_Maternity_Leaves_Credit__c = 0;
            leadcontact.EMS_LM_No_Of_Leaves_Credit__c = 10;
            insert leadcontact;
            rrr = TestDataFactory.createRRR(con.Id, true, leadcontact.Id);
            rrr = TestDataFactory.createRRR(leadcontact.Id, true, con.Id);
            List<Resource_Resource_Relationship__c> rrrList = [SELECT Id, Name, Resource__c, Resource_Reports_To__c,Resource_Reports_To_User__c FROM Resource_Resource_Relationship__c WHERE Resource__c =: con.Id];
        }
        User contactuser;
        User leaduser;
        system.runAs(adminuser) {
            contactuser = Testdatafactory.createCommunityUserWithAccAndContact(acc.id,con.Id,true);
            leaduser = Testdatafactory.createCommunityUser2WithAccAndContact(acc.id,leadcontact.Id,true);
            System.debug('### leaduser'+ leaduser.Id);
        }
    }
    
    static testMethod void testGoalForNewEmp() {
        User resourceUser = [SELECT Id,ContactId FROM User WHERE Email = 'testemail@testclass.com.they'];
        User LeadUser = [SELECT Id,ContactId FROM User WHERE Email = 'testemail4@testclass.com.they']; 
        Resource_Role__c resRole = [SELECT ID, Name FROM Resource_Role__c WHERE Name = 'Software Engineer'];
        Contact con = [SELECT Id, EMS_TM_User__c, Resource_Role__r.Name FROM Contact WHERE Resource_Role__r.Name = 'Software Engineer'];
        con.EMS_TM_User__c = resourceUser.Id;
        System.runAs(LeadUser){
            update con;
            Grid_Configuration__c config = TestDataFactory.createGridConfig('Test Grid Configuration','test','Org Level Goal',resRole.Id, true);
            
            //createGoalForNewEmployees.createGoals(conList, conMap);
        }
        
        
        
        
        List<Goal__c> goals = [SELECT Id FROM Goal__c WHERE Resource__c =: con.Id];
    }
}