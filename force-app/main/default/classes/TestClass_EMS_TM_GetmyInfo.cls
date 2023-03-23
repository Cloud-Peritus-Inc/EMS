@istest
public class TestClass_EMS_TM_GetmyInfo {
   @isTest static void testMethod1() {
        Account accobj = new Account(
        Name ='test acc',
        phone ='1122334455');
          insert accobj;
        Contact contactObj = new Contact (
			FirstName = 'test value',
            Lastname='rdg',
            AccountId = accobj.id,
			EMS_Domain_Technology__c ='Salesforce', 
			//EMS_RM_Current_Job_Role__c ='Accountant', 
			EMS_RM_Domain_Technology__c ='Salesforce', 
			EMS_RM_Industry__c ='Information Technology', 
			EMS_RM_Resource_Email_id__c = 'testEmail@gmail.com',  
			EMS_Phone_Number__c = '1234567890'
		);
		insert contactObj;
         Profile p = [Select id from profile where name='TM Customer Community'];
		User userObj = new User (
			ContactId = contactObj.id, 
			Username = 'trt3@gmail.com', 
			LastName = 'test', 
            firstName='te',
			Email = 'testEmail@gmail.com', 
			EmailPreferencesAutoBcc = TRUE, 
			EmailPreferencesAutoBccStayInTouch = TRUE, 
			EmailPreferencesStayInTouchReminder = TRUE, 
			Alias = 'test',
            isActive = true,
			CommunityNickname = 'test value', 
			TimeZoneSidKey ='Pacific/Kiritimati', 
			LocaleSidKey ='af_ZA', 
			EmailEncodingKey ='UTF-8', 
			ProfileId = p.id, 
            PortalRole = 'Manager',
			LanguageLocaleKey ='en_US'
			
		);
		insert userObj;
		 
	
          EMS_TM_GetmyInfo.getUserContactInfo(userObj.id);
	}


}