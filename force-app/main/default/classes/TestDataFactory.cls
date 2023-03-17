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
		Contact c = new Contact(firstName = 'Test',EMS_Phone_Number__c= '9090909090',Email='testEmail@cloudperitus.com', lastName = 'Employee', accountId = accountId, recordtypeId = ContactConstant.RESOURCE_RECORDTYPEID);
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
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                ContactId = conId,
                timezonesidkey='America/Los_Angeles', username='testemail'/*+string.valueOf(system.now())*/+'@gmail.com');
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
    
    

}