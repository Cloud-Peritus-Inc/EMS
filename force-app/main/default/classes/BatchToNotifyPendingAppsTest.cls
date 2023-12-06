@isTest
public class BatchToNotifyPendingAppsTest {
    @testSetup static void setup()  {
        
        user adminuser2 = TestDataFactory.createAdminUser(true);
        user adminuser = TestDataFactory.createAdminUser(true);
        Resource_Role__c techLead;
        Resource_Role__c emp;
        Resource_Role__c projectManager;
        Account acc;
        Contact con;
        Contact leadcontact;
        EMS_LM_Leave__c annualtype;
        EMS_LM_Leave__c paternitytype;
        EMS_LM_Leave__c  Bereavementtype;
        
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
            EMS_LM_Leave_Credit__c lcreditAnnual = Testdatafactory.createLeaveCredit(con.id,system.today(),1.6,annualtype.id, true);
            EMS_LM_Leave_Credit__c commOffAnnual = Testdatafactory.createLeaveCredit(con.id,system.today(),1,compofftype.id, true);
           // EMS_LM_Leave_Credit__c patAnnual = Testdatafactory.createLeaveCredit(con.id,system.today(),1,paternitytype.id, true); 
            //EMS_LM_Leave_Credit__c berveAnnual = Testdatafactory.createLeaveCredit(con.id,system.today(),1,Bereavementtype.id, true);
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

    static testMethod void testNotifyTest(){
        List<EMS_LM_Leave_History__c> requests = new List<EMS_LM_Leave_History__c>();
        User resourceUser = [SELECT Id,ContactId FROM User WHERE Email = 'testemail@testclass.com.they'];
        User LeadUser = [SELECT Id,ContactId FROM User WHERE Email = 'testemail4@testclass.com.they'];
        User empUser = [SELECT Id,ContactId FROM User WHERE Email = 'testemail5@testclass.com.they'];
        System.RunAs(empUser){
        for(Integer i=0; i<3; i++){
            EMS_LM_Leave_History__c leaveReq = new EMS_LM_Leave_History__c(); 
            leaveReq.EMS_LM_Contact__c = empUser.ContactId;
            leaveReq.EMS_LM_Day__c = 'Full Day';
            leaveReq.EMS_LM_Leave_Start_Date__c = system.today().adddays(i);
            leaveReq.EMS_LM_Leave_End_Date__c = system.today().adddays(i+1);
            leaveReq.EMS_LM_Leave_Type__c = [SELECT Id FROM EMS_LM_Leave__c WHERE Name = 'Annual Leave'].Id;
            leaveReq.EMS_LM_Leave_Duration__c = 1;
            leaveReq.EMS_LM_Reason__c = 'Test Reason';
            leaveReq.EMS_LM_Status__c =  'Pending';
            leaveReq.EMS_LM_Leave_Type_Name__c = 'Annual Leave';
            
            leaveReq.EMS_LM_Approver__c = userinfo.getUserId();
            leaveReq.Approver_3__c = userinfo.getUserId();
            leaveReq.EMS_LM_2nd_Approver__c = userinfo.getUserId();

            requests.add(leaveReq);
  
        }
        }
        Test.startTest();
        system.runAs(LeadUser){
         TriggerBase.bypass('EMS_LM_Leave_History__c');
               insert requests;
         TriggerBase.clearBypass('EMS_LM_Leave_History__c');
           
        }
        Test.stopTest();
    }    
    
    public static testMethod void testscheduleclass() {
        Test.StartTest();
        BatchToNotifyPendingApps_sch testsche = new BatchToNotifyPendingApps_sch();
        String sch = '0 0 23 * * ?';
        system.schedule('Test BatchToNotifyPendingApps_sch Check', sch, testsche );
        Test.stopTest();
    }
    
}