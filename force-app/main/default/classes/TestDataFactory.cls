/**
* @author Subba Kalavala
* @date 2/22/2023
* @description  Test data factory for all the test classes.
*
* CHANGE HISTORY
* ====================================================================================================
* DATE          NAME                    DESCRIPTION
* N/A           N/A                     N/A
* ====================================================================================================
**/
@IsTest
public class TestDataFactory {
    
    public static Account createAccount(Boolean doInsert) {
        return createAccount('testAccount', doInsert);
    }
    
    public static Account createAccount(String name, Boolean doInsert) {
        Account acc = new Account(name = name);
        if(doInsert) {
            insert acc;
        }
        return acc;
    }
    
    public static Contact createResourceContact(Boolean doInsert) {
        Account acc = createAccount(true);
        return createResourceContact(acc.id, true);
    }
    
    public static Contact createResourceContact(Id accountId, Boolean doInsert) {
        Contact c = new Contact(firstName = 'Test',EMS_Phone_Number__c= '9090909090',
                                Email='testEmail+test@cloudperitus.com', lastName = 'Employee',
                                accountId = accountId, Work_Location__c = createOfficeLocation(true).Id, 
                                recordtypeId = ContactConstant.RESOURCE_RECORDTYPEID);
        if(doInsert) {
            insert c;
        }
        return c;
    }

    public static Resource_Resource_Relationship__c createRRR(Id ContactId, Boolean doInsert, Id ConId){
        Resource_Resource_Relationship__c rrr = new Resource_Resource_Relationship__c(Resource__c = ContactId, Resource_Reports_To__c = conId);
        if (doInsert) {
            insert rrr;
        }
        return rrr;
    }

    public static Contact createResourceContactForRRR(Id accountId, Boolean doInsert) {
        Contact c = new Contact(firstName = 'Testing',EMS_Phone_Number__c= '9090909090',
                                Email='testingEmail+test@cloudperitus.com', lastName = 'Rrr',
                                accountId = accountId, Work_Location__c = createOfficeLocation(true).Id, 
                                recordtypeId = ContactConstant.RESOURCE_RECORDTYPEID);
        if(doInsert) {
            insert c;
        }
        return c;
    }    
    
    public static Contact createApplicantContact(Boolean doInsert) {
        Account acc = createAccount(true);
        return createApplicantContact(acc.id, true);
    }
    
    public static Contact createApplicantContact(Id accountId, Boolean doInsert) {
        Contact c = new Contact(firstName = 'Test', lastName = 'Employee', accountId = accountId, recordtypeId = ContactConstant.APPLICANT_RECORDTYPEID);
        if(doInsert) {
            insert c;
        }
        return c;
    }
    public static List<Opportunity> createOpportunity(Id accountId, Integer numOpps, Boolean doInsert) {
        List<Opportunity> opps = new List<Opportunity>();
        for(Integer i = 1; i <= numOpps; i++) {
            Opportunity opp = new Opportunity();
            opp.name = 'Account ' + i;
            opp.accountId = accountid;
            opp.amount = 1000;
            opp.closeDate = Date.today().addDays(5);
            opp.Contract_End_Date__c = System.today()+20;
            opp.stageName = 'Prospecting';
            opps.add(opp);
        }
        if(doInsert){
            insert opps;
        }
        return opps;
    }    
    
    public static User createCommunityUserWithOutAccAndContact(Boolean doInsert){
        Id p = [select id from profile where name='Employee - Resource(Community)'].id;
        Account acc = createAccount(true);
        Resource_Role__c role = createResourceRole(true);
        Contact con=  createResourceContact(acc.id, false);
        con.Resource_Role__c = role.Id;
        con.EMS_RM_ApplicantStatus_Update__c = 'Active';
        con.Work_Location__c = createOfficeLocation(true).Id;
        insert con;
        User user = new User(alias = 'test123', email=con.Email,
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                             ContactId = con.Id,
                             timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
        if(doInsert){
            insert user;
        }
        
        return user;
    }
    
    public static User createCommunityUserWithAccAndContact(Id accId,Id conId,Boolean doInsert){
        Id p = [select id from profile where name='Employee - Resource(Community)'].id;

        User user = new User(alias = 'test123', email= 'testemail@testclass.com.they',
                             emailencodingkey='UTF-8', lastname='Testing', Firstname = 'User', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                             ContactId = conId,
                             timezonesidkey='America/Los_Angeles', username='testemail'/*+string.valueOf(system.now())*/+'@gmail.com');
        if(doInsert){
            insert user;
        }
        
        return user;
    }
    
    public static User createCommunityUser2WithAccAndContact(Id accId,Id conId,Boolean doInsert){
        Id p = [select id from profile where name='Employee - Resource(Community)'].id;

        User user = new User(alias = 'test1234', email= 'testemail4@testclass.com.they',
                             emailencodingkey='UTF-8', lastname='Testing4', Firstname = 'User4', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                             ContactId = conId,
                             timezonesidkey='America/Los_Angeles', username='testemail4'/*+string.valueOf(system.now())*/+'@gmail.com');
        if(doInsert){
            insert user;
        }
        
        return user;
    }    
    
    public static Grid_Configuration__c createGridConfig(String name, String description,String typeval,String resourcRole,Boolean isCreate){
        Grid_Configuration__c gc = new Grid_Configuration__c();
        gc.Name = name;
        gc.Description__c = description;
        gc.Goal_Start_Date__c = system.today().adddays(1);
        gc.Goal_End_Date__c = system.today().adddays(12);
        gc.Grid_Configuration_Type__c = typeval;
        if(resourcRole != null){
            gc.Resource_Role__c = resourcRole;   
        }
        
        if(isCreate){
            insert gc;
        }
        
        return gc;
        
    }
    
    public static Resource_Role__c createResourceRole(Boolean doInsert){
        Resource_Role__c rr = createResourceRole('Software Engineer',doInsert);
        return rr;
    }
    
    public static Resource_Role__c createResourceRole(String name,Boolean doInsert){
        Resource_Role__c rr = new Resource_Role__c();
        rr.Name = name;
        rr.Active__c = true;
        rr.Level_of_Approval__c = 1;
        rr.Auto_Approve__c = false;
        if(doInsert){
            insert rr;
        }
        return rr;
    }
    
    public static EMS_LM_Leave__c createLeaveType(Boolean doInsert){
        EMS_LM_Leave__c leaveType = createLeaveType('Annual Leave',doInsert);
        return leaveType;
    }
    
    public static EMS_LM_Leave__c createLeaveType(String name, Boolean doInsert){
        EMS_LM_Leave__c leaveType = new EMS_LM_Leave__c(); 
        leaveType.Name = name;
        if(doInsert){
            insert leaveType;
        }
        return leaveType;
    }
    
    public static Office_Location__c createOfficeLocation(Boolean doInsert){
        Office_Location__c officeLoc = createOfficeLocation('Hyderabad',doInsert);
        return officeLoc;
    }
    
    public static Office_Location__c createOfficeLocation(String name, Boolean doInsert){
        Office_Location__c officeLoc = new Office_Location__c(); 
        officeLoc.Name = name;
        officeLoc.Address__c = 'test Address';
        officeLoc.Country__c = 'India';
        if(doInsert){
            insert officeLoc;
        }
        return officeLoc;
    }
    
    
    
    public static EMS_LM_Leave_History__c createLeaveRequest(String conid,Date startDate,Date endDate,String leaveTypeId, Boolean doInsert, String leaveStatus){
        EMS_LM_Leave_History__c leaveReq = new EMS_LM_Leave_History__c(); 
        leaveReq.EMS_LM_Contact__c = conid;
        leaveReq.EMS_LM_Day__c = 'Full Day';
        leaveReq.EMS_LM_Leave_Start_Date__c = startDate;
        leaveReq.EMS_LM_Leave_End_Date__c = endDate;
        leaveReq.EMS_LM_Leave_Type__c = leaveTypeId;
        leaveReq.EMS_LM_Leave_Duration__c = startDate.daysBetween(endDate);
        leaveReq.EMS_LM_Reason__c = 'Test Reason';
        leaveReq.EMS_LM_Status__c = leaveStatus != null ? leaveStatus : 'Pending';
    	EMS_LM_Leave__c leaveType = [SELECT Name FROM EMS_LM_Leave__c WHERE Id = :leaveTypeId];
    	leaveReq.EMS_LM_Leave_Type_Name__c = leaveType.Name;
        leaveReq.EMS_LM_Leave_Type__c = leaveType.Id;
        if(doInsert){
            insert leaveReq;
        }
        return leaveReq;
    }
    
    
    public static EMS_LM_Leave_Credit__c createLeaveCredit(String conid,Date creditDate,decimal creditValue,String leaveTypeId, Boolean doInsert){
        EMS_LM_Leave_Credit__c leaveCredit = new EMS_LM_Leave_Credit__c(); 
        leaveCredit.EMS_LM_Employee__c = conid;
        leaveCredit.EMS_LM_Leaves_Credited__c = creditValue;
        leaveCredit.EMS_LM_Leave_Credited_Date__c = creditDate;
        leaveCredit.EMS_LM_Leave_Type__c = leaveTypeId;
        
        
        if(doInsert){
            insert leaveCredit;
        }
        return leaveCredit;
    }
    
    public static case createCaseWithAccAndContact(String accid, String conid, 
                                                   String typeval, String subRequest,
                                                   String subjectVal, String descr, Boolean isinsert){
                                                       Case caseREc = new Case();
                                                       caseREc.Subject =  subjectVal;
                                                       caseREc.AccountId =  accid;
                                                       caseREc.ContactId =  conid;
                                                       caseREc.Description =  descr;
                                                       caseREc.Type =  typeval;
                                                       caseREc.Request_Sub_Type__c =  subRequest;
                                                       caseREc.Status =  'New';
                                                       if(isinsert){
                                                           insert caseREc;
                                                       }
                                                       
                                                       return caseREc;
                                                   }
    
    public static user createAdminUser(boolean iscreate){
        Profile pf= [Select Id from profile where Name='System Administrator']; 
        UserRole obj=new UserRole(Name= 'ABC'); 
        insert obj;
        String orgId = UserInfo.getOrganizationId(); 
        String dateString =String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-',''); 
        
        Integer RandomId = Integer.valueOf((Math.random())*1000000); 
        String uniqueName = orgId+dateString+RandomId; 
        
        User uu = new User(firstname = 'Alan', 
                           lastName = 'McCarthy', 
                           email = uniqueName + '@test' + orgId + '.org', 
                           Username = uniqueName + '@test' + orgId + '.org', 
                           EmailEncodingKey = 'ISO-8859-1', 
                           Alias = uniqueName.substring(18, 23), 
                           TimeZoneSidKey = 'America/Los_Angeles', 
                           LocaleSidKey = 'en_US', 
                           LanguageLocaleKey = 'en_US', 
                           ProfileId = pf.Id,UserRoleId = obj.Id
                          );
        
        if(iscreate){
            insert uu;
        }
        return uu;  
    }
    
    public static PayRoll__c createPayroll(Id conId, Boolean doInsert){
        PayRoll__c payRollRec = new PayRoll__c();
        payRollRec.Contact__c = conId;
        payRollRec.Bank_Name__c = 'State Bank of India';
        payRollRec.IFSC_Routing_Number__c = 'SBIN001';
        payRollRec.Beneficiary_Account_Number__c = '1236478999';
        if(doInsert){
            insert payRollRec;
        }
        return payRollRec;
    }

    public static Family_Information__c createFamilyInfo(Id conId, Boolean doInsert, Boolean emergencyCon, Boolean dependentCon){
        Family_Information__c famInfoRec = new Family_Information__c();
        famInfoRec.Resource__c = conId;
        famInfoRec.Family_Member_Name__c = 'test member';
        famInfoRec.Is_It_Emergency_Contact__c = emergencyCon;
        famInfoRec.Is_It_Dependent_Contact__c = dependentCon;
        famInfoRec.Date_of_Birth__c = system.today().adddays(-100);
        famInfoRec.Contact_Phone_Number__c = '8521796330';
        famInfoRec.Relationships__c = 'Father';
        if(doInsert){
            insert famInfoRec;
        }
        return famInfoRec;
    }
    
    
}