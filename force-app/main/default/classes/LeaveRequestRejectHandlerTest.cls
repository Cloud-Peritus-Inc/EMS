@isTest
public class LeaveRequestRejectHandlerTest {
    
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
               EMS_LM_Leave__c unpaidTimeOff = TestDataFactory.createLeaveType('UnPaid time off',true);
               EMS_LM_Leave__c floatingholiday = TestDataFactory.createLeaveType('Floating Holiday',true);
            Office_Location__c hydofficlocRec =TestDataFactory.createOfficeLocation('Hyderabad - India',true);
Office_Location__c usofficlocRec =TestDataFactory.createOfficeLocation('California - USA',true);

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
            Id p = [select id from profile where name='Employee - Resource(Community)'].id;
            contactuser = Testdatafactory.createCommunityUserWithAccAndContact(acc.id,contactList[0].Id,true); //tech
           // leaduser = Testdatafactory.createCommunityUser2WithAccAndContact(acc.id,contactList[2].Id,false); //pm
            USER u=new User(alias = 'test145', email= 'testemail4@testclass.com.they',
                             emailencodingkey='UTF-8', lastname='Testing4', Firstname = 'User5', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                             ContactId = contactList[2].Id,
                             timezonesidkey='America/Los_Angeles', username='testemail511'/*+string.valueOf(system.now())*/+'@gmail.com');
            insert u;
            
            empUser = Testdatafactory.createCommunityUser3WithAccAndContact(acc.id,contactList[1].Id,true); //emp
            //System.debug('### leaduser'+ leaduser.Id);
        }
    }
     
    testmethod static void  checkTheapproval(){
       EMS_LM_Leave_History__c leaveVal1;
       EMS_LM_Leave_History__c leaveVal2;
       User resourceUser = [SELECT Id,ContactId FROM User WHERE Email = 'testemail@testclass.com.they'];
         User u = [SELECT Id,ContactId FROM User WHERE Email = 'testemail4@testclass.com.they'];
        User empUser = [SELECT Id,ContactId FROM User WHERE Email = 'testemail5@testclass.com.they'];
        EMS_LM_Leave_History__c leaveReq = new EMS_LM_Leave_History__c(); 
        leaveReq.EMS_LM_Contact__c = resourceUser.ContactId;
        leaveReq.EMS_LM_Day__c = 'Full Day';
        leaveReq.EMS_LM_Leave_Start_Date__c = system.today();
        leaveReq.EMS_LM_Leave_End_Date__c = system.today().adddays(1);
        leaveReq.EMS_LM_Leave_Type__c = [SELECT Id FROM EMS_LM_Leave__c WHERE Name = 'Annual Leave'].Id;
        leaveReq.EMS_LM_Leave_Duration__c = 1;
        leaveReq.EMS_LM_Reason__c = 'Test Reason';
        leaveReq.EMS_LM_Status__c =  'Rejected';
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
    	leaveReq1.EMS_LM_Leave_Type_Name__c = 'Annual Leave';        
       
        Test.startTest();
        system.runAs(u){
            insert leaveReq;
          LeaveRequestRejectHandler.updateRejecteStatusAndComments(leaveReq.Id, 'Rejected by PM'); 
             leaveVal1 = [SELECT Id,
                         		EMS_LM_Status__c, 
                         		EMS_LM_Approved_On__c, 
                         		EMS_LM_Current_Approver__c, 
                         		Approver_1_Approved_Comments__c,
                         		EMS_LM_Approver__c,
                         		EMS_LM_Approver__r.FirstName,
                         		EMS_LM_Approver__r.LastName
                         FROM EMS_LM_Leave_History__c WHERE Id = :leaveReq.Id];

           // System.assertEquals(LeaveRequestConstant.REJECTED, leaveVal1.EMS_LM_Status__c);
           // System.assertEquals(System.today(), leaveVal1.EMS_LM_Approved_On__c);
           // System.assertEquals('Rejected by PM', leaveVal1.Approver_1_Approved_Comments__c);
        }
        system.runAs(resourceUser){
            insert leaveReq1;
          LeaveRequestRejectHandler.updateRejecteStatusAndComments(leaveReq1.Id, 'Rejected by PM'); 
             leaveVal2 = [SELECT Id,
                         		EMS_LM_Status__c, 
                         		EMS_LM_Approved_On__c, 
                         		EMS_LM_Current_Approver__c, 
                         		Approver_1_Approved_Comments__c,
                         		EMS_LM_Approver__c,
                         		EMS_LM_Approver__r.FirstName,
                         		EMS_LM_Approver__r.LastName
                         FROM EMS_LM_Leave_History__c WHERE Id = :leaveReq1.Id];

            System.assertEquals(LeaveRequestConstant.REJECTED, leaveVal2.EMS_LM_Status__c);
            System.assertEquals(System.today(), leaveVal2.EMS_LM_Approved_On__c);
        }
        Test.stopTest();
    }
    
    testMethod static void bulkRejectionTest(){
       List<EMS_LM_Leave_History__c> requests = new List<EMS_LM_Leave_History__c>();
       List<EMS_LM_Leave_History__c> requests1 = new List<EMS_LM_Leave_History__c>();
       List<EMS_LM_Leave_History__c> leaveVal1;
       List<EMS_LM_Leave_History__c> leaveVal2;
       User resourceUser = [SELECT Id,ContactId FROM User WHERE Email = 'testemail@testclass.com.they'];
       User LeadUser = [SELECT Id,ContactId FROM User WHERE Email = 'testemail4@testclass.com.they'];
       User empUser = [SELECT Id,ContactId FROM User WHERE Email = 'testemail5@testclass.com.they'];
        for(Integer i=0; i<3; i++){
            EMS_LM_Leave_History__c leaveReq = new EMS_LM_Leave_History__c(); 
            leaveReq.EMS_LM_Contact__c = resourceUser.ContactId;
            leaveReq.EMS_LM_Day__c = 'Full Day';
            leaveReq.EMS_LM_Leave_Start_Date__c = system.today().adddays(i);
            leaveReq.EMS_LM_Leave_End_Date__c = system.today().adddays(i+1);
            leaveReq.EMS_LM_Leave_Type__c = [SELECT Id FROM EMS_LM_Leave__c WHERE Name = 'Annual Leave'].Id;
            leaveReq.EMS_LM_Leave_Duration__c = 1;
            leaveReq.EMS_LM_Reason__c = 'Test Reason';
            leaveReq.EMS_LM_Status__c =  'Pending';
            leaveReq.EMS_LM_Leave_Type_Name__c = 'Annual Leave';
            requests.add(leaveReq);
        }
        
        for (integer i=0; i<3; i++){
            EMS_LM_Leave_History__c leaveReq1 = new EMS_LM_Leave_History__c(); 
            leaveReq1.EMS_LM_Contact__c = empUser.ContactId;
            leaveReq1.EMS_LM_Day__c = 'Full Day';
            leaveReq1.EMS_LM_Leave_Start_Date__c = system.today();
            leaveReq1.EMS_LM_Leave_End_Date__c = system.today().adddays(1);
            leaveReq1.EMS_LM_Leave_Type__c = [SELECT Id FROM EMS_LM_Leave__c WHERE Name = 'Annual Leave'].Id;
            leaveReq1.EMS_LM_Leave_Duration__c = 1;
            leaveReq1.EMS_LM_Reason__c = 'Test Reason';
            leaveReq1.EMS_LM_Status__c =  'Approver 1 Pending';
            leaveReq1.EMS_LM_Leave_Type_Name__c = 'Annual Leave';
            requests1.add(leaveReq1);
        }
        
        Test.startTest();
        system.runAs(LeadUser){
            insert requests;
          List<Id> leaveReqTabIdsList = new list<Id>();
            for(EMS_LM_Leave_History__c leaveIds : requests) {
                leaveReqTabIdsList.add(leaveIds.Id);
            }
          LeaveRequestRejectHandler.bulkLeaveReqReject(leaveReqTabIdsList, 'Approver 1 Rejected'); 
             leaveVal1 = [SELECT Id,
                         		EMS_LM_Status__c, 
                         		EMS_LM_Approved_On__c, 
                         		EMS_LM_Current_Approver__c, 
                         		Approver_1_Approved_Comments__c,
                         		EMS_LM_Approver__c,
                         		EMS_LM_Approver__r.FirstName,
                         		EMS_LM_Approver__r.LastName
                         FROM EMS_LM_Leave_History__c WHERE Id IN:leaveReqTabIdsList];
        }
        system.runAs(resourceUser){
            insert requests1;
          List<Id> leaveReqTabIdsList1 = new list<Id>();
            for(EMS_LM_Leave_History__c leaveIds : requests) {
                leaveReqTabIdsList1.add(leaveIds.Id);
            }
          LeaveRequestRejectHandler.bulkLeaveReqReject(leaveReqTabIdsList1, 'Rejected by PM'); 
             leaveVal2 = [SELECT Id,
                         		EMS_LM_Status__c, 
                         		EMS_LM_Approved_On__c, 
                         		EMS_LM_Current_Approver__c, 
                         		Approver_1_Approved_Comments__c,
                         		EMS_LM_Approver__c,
                         		EMS_LM_Approver__r.FirstName,
                         		EMS_LM_Approver__r.LastName
                         FROM EMS_LM_Leave_History__c WHERE Id IN : leaveReqTabIdsList1];

           /* System.assertEquals(LeaveRequestConstant.REJECTED, leaveVal2.EMS_LM_Status__c);
            System.assertEquals(System.today(), leaveVal2.EMS_LM_Approved_On__c);*/
        }
        Test.stopTest();
    }
}