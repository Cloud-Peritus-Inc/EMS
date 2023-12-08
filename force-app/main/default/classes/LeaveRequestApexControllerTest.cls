@isTest
public class LeaveRequestApexControllerTest {
    
    @testSetup static void setup()  {
        user adminuser = TestDataFactory.createAdminUser(true);
        Resource_Role__c techLead;
        Resource_Role__c emp;
        Resource_Role__c projectManager;
        Account acc;
        Contact con;
        Contact leadcontact;
        EMS_LM_Leave__c annualtype;
        Resource_Resource_Relationship__c rrr;
        List<Resource_Role__c> resourceRoleList = new List<Resource_Role__c>();
        List<Contact> contactList = new List<Contact>();
        system.runAs(adminuser){
            
            resourceRoleList.add(techLead = TestDataFactory.createResourceRole('Software Engineer',false));
            resourceRoleList.add(emp = TestDataFactory.createResourceRole('tech Engineer',false));
            emp.Level_of_Approval__c = 2;
            resourceRoleList.add(projectManager = TestDataFactory.createResourceRole('tech Engineer',false));
            projectManager.Level_of_Approval__c = 0;
            projectManager.Auto_Approve__c = true;
            insert resourceRoleList;
            
            annualtype = TestDataFactory.createLeaveType('Annual Leave',true);
            EMS_LM_Leave__c loptype = TestDataFactory.createLeaveType('Loss of Pay',true);
            EMS_LM_Leave__c bretype = TestDataFactory.createLeaveType('Maternity Leave',true);
            EMS_LM_Leave__c compofftype = TestDataFactory.createLeaveType('Compensatory Off',true);
            EMS_LM_Leave__c wfhtype = TestDataFactory.createLeaveType('Work From Home',true);
            EMS_LM_Leave__c paidtimeof = TestDataFactory.createLeaveType('Paid time off',true);
            Office_Location__c officlocRec =TestDataFactory.createOfficeLocation('Hyderabad - India',true);
            Office_Location__c officlocRec2 =TestDataFactory.createOfficeLocation('California - USA',true);
            
            acc = TestDataFactory.createAccount(true);
            
            for(Integer i=0; i<3; i++){
                con=TestDataFactory.createResourceContact(acc.id, false);
                con.EMS_RM_Employee_Id__c = 'CP1023'+i;
                con.Resource_Role__c = resourceRoleList[i].id;
                con.EMS_LM_No_Of_Maternity_Leaves_Credit__c = 0;
                con.EMS_LM_No_Of_Leaves_Credit__c = 10;
                contactList.add(con);                
            }
            insert contactList;
            System.debug('con'+ contactList);
            
            rrr = TestDataFactory.createRRR(contactList[0].Id, true, contactList[2].Id); // Tech lead
            rrr = TestDataFactory.createRRR(contactList[1].Id, true, contactList[0].Id); //EMP
        }
        User contactuser;
        User leaduser;
        User empUser;
        //System.debug('### outside  in adminuser *(****' + adminuser.Id);
        system.runAs(adminuser){
            contactuser = Testdatafactory.createCommunityUserWithAccAndContact(acc.id,contactList[0].Id,true); //tech
            leaduser = Testdatafactory.createCommunityUser2WithAccAndContact(acc.id,contactList[2].Id,true); //pm
            empUser = Testdatafactory.createCommunityUser3WithAccAndContact(acc.id,contactList[1].Id,true); //emp
            System.debug('### leaduser'+ leaduser.Id);
        }
    }
    
    testmethod static void  getLeaveReqDataTest(){
        EMS_LM_Leave_History__c leaveVal1;
        EMS_LM_Leave_History__c leaveVal2;
        EMS_LM_Leave__c annualtypeId = [SELECT Id FROM EMS_LM_Leave__c WHERE Name = 'Annual Leave'];
        User resourceUser = [SELECT Id,ContactId FROM User WHERE Email = 'testemail@testclass.com.they'];
        User LeadUser = [SELECT Id,ContactId FROM User WHERE Email = 'testemail4@testclass.com.they'];
        User empUser = [SELECT Id,ContactId FROM User WHERE Email = 'testemail5@testclass.com.they'];
        /*EMS_LM_Leave_History__c leaveReq = new EMS_LM_Leave_History__c(); 
        leaveReq.EMS_LM_Contact__c = resourceUser.ContactId;
        leaveReq.EMS_LM_Day__c = 'Full Day';
        leaveReq.EMS_LM_Leave_Start_Date__c = system.today();
        leaveReq.EMS_LM_Leave_End_Date__c = system.today().adddays(1);
        leaveReq.EMS_LM_Leave_Type__c = [SELECT Id FROM EMS_LM_Leave__c WHERE Name = 'Annual Leave'].Id;
        leaveReq.EMS_LM_Leave_Duration__c = 1;
        leaveReq.EMS_LM_Reason__c = 'Test Reason';
        leaveReq.EMS_LM_Status__c =  'Pending';
        leaveReq.EMS_LM_Leave_Type_Name__c = 'Annual Leave';
        
        EMS_LM_Leave_History__c leaveReq1 = new EMS_LM_Leave_History__c(); 
        leaveReq1.EMS_LM_Contact__c = empUser.ContactId;
        leaveReq1.EMS_LM_Day__c = 'Full Day';
        leaveReq1.EMS_LM_Leave_Start_Date__c = system.today();
        leaveReq1.EMS_LM_Leave_End_Date__c = system.today().adddays(1);
        leaveReq1.EMS_LM_Leave_Type__c = [SELECT Id FROM EMS_LM_Leave__c WHERE Name = 'Annual Leave'].Id;
        leaveReq1.EMS_LM_Leave_Duration__c = 1;
        leaveReq1.EMS_LM_Reason__c = 'Test Reason';
        leaveReq1.EMS_LM_Status__c =  'Approver 1 Pending';
        leaveReq1.EMS_LM_Leave_Type_Name__c = 'Annual Leave'; */       
        
        Test.startTest();
        system.runAs(LeadUser){
            List<Id> leaveReqTabIdsList = new list<Id>();
            List<EMS_LM_Leave_History__c> requests = new List<EMS_LM_Leave_History__c>();
            requests.add(TestDataFactory.createLeaveRequest(resourceUser.ContactId, system.today(), system.today().adddays(1), annualtypeId.id, false, 'Pending'));
            requests.add(TestDataFactory.createLeaveRequest(resourceUser.ContactId, system.today().adddays(6), system.today().adddays(7), annualtypeId.id, false, 'Approver 1 Pending'));
            requests.add(TestDataFactory.createLeaveRequest(resourceUser.ContactId, system.today().adddays(8), system.today().adddays(9), annualtypeId.id, false, 'Approver 2 Pending'));
            insert requests;
            for(EMS_LM_Leave_History__c leaveIds : requests) {
                leaveReqTabIdsList.add(leaveIds.Id);
            }
            LeaveRequestApexController.LeaveRequestStatus result = LeaveRequestApexController.getLeaveReqData();
            /*insert leaveReq;
LeaveRequestApexController.getLeaveReqData(); 
leaveVal1 = [SELECT Id,
EMS_LM_Status__c, 
EMS_LM_Approved_On__c, 
EMS_LM_Current_Approver__c, 
Approver_1_Approved_Comments__c,
EMS_LM_Approver__c,
EMS_LM_Approver__r.FirstName,
EMS_LM_Approver__r.LastName
FROM EMS_LM_Leave_History__c WHERE Id = :leaveReq.Id];

System.assertEquals(LeaveRequestConstant.REJECTED, leaveVal1.EMS_LM_Status__c);
System.assertEquals(System.today(), leaveVal1.EMS_LM_Approved_On__c);
System.assertEquals('Rejected by PM', leaveVal1.Approver_1_Approved_Comments__c);*/
        }
    }
}