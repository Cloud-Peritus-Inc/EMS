@isTest
public class restrictDuplicateOffboardingReqTest {
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
            
            rrr = TestDataFactory.createRRR(contactList[0].Id, true, contactList[2].Id); //Tech lead
            rrr = TestDataFactory.createRRR(contactList[1].Id, true, contactList[0].Id); //EMP
        }
        User contactuser;
        User leaduser;
        User empUser;
        system.runAs(adminuser){
            contactuser = Testdatafactory.createCommunityUserWithAccAndContact(acc.id,contactList[0].Id,true); //tech
            leaduser = Testdatafactory.createCommunityUser2WithAccAndContact(acc.id,contactList[2].Id,true); //pm
            empUser = Testdatafactory.createCommunityUser3WithAccAndContact(acc.id,contactList[1].Id,true); //emp
        }
    }
    
    testMethod static void restrictReqCaseDuplicates(){
        User resourceUser = [SELECT Id,ContactId FROM User WHERE Email = 'testemail@testclass.com.they'];
        Contact resourceAccount =[SELECT Id, AccountID FROM Contact WHERE Id =:resourceUser.ContactId];
        User LeadUser = [SELECT Id,ContactId FROM User WHERE Email = 'testemail4@testclass.com.they'];
        
        system.runAs(LeadUser){
            Case cs = Testdatafactory.createCaseWithAccAndContact(resourceAccount.AccountID,
                                                                  resourceUser.ContactId,
                                                                  'Change Of Details', 
                                                                  'Bank Details', 
                                                                  'Test Subjectrr', 
                                                                  'Test descrioyon eresjd ', 
                                                                  true
                                                                 );
            Test.startTest();
            Case csFail = Testdatafactory.createCaseWithAccAndContact(resourceAccount.AccountID,
                                                                      resourceUser.ContactId,
                                                                      'Change Of Details', 
                                                                      'Bank Details', 
                                                                      'Test Subjectrr', 
                                                                      'Test descrioyon eresjd ', 
                                                                      true
                                                                     );
            //System.assert(csFail.hasErrors(), 'The test case should fail because there is an existing Change of details for Bank details');
            
        }
        Test.stopTest();
    }
    
    
}