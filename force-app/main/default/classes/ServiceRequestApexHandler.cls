/**
* @author Pavan Tavva
* @date 01/03/2023
* @description  ServiceRequestApexHandler Class to 
*
*               Test code coverage provided by the following test class:
*               - ServiceRequestApexHandlerTest
*
* CHANGE HISTORY
* ====================================================================================================
* DATE          NAME                    DESCRIPTION
* N/A           N/A                     N/A
* ====================================================================================================
**/
public without sharing class ServiceRequestApexHandler {

    /**
* @author Pavan Tavva
* @date 01/03/2023
* @description To get the payroll details of logged in user.
*
* CHANGE HISTORY
* ====================================================================================================
* DATE          NAME                    DESCRIPTION
* N/A           N/A                     N/A
* ====================================================================================================
**/
    @AuraEnabled(cacheable=true)
    public static PayRoll__c getPayrollInfo(){
        User usr = [SELECT Id, 
                           contactId__c
                    FROM User
                    WHERE Id =: LeaveRequestConstant.LOGGEDIN_USERID];
        PayRoll__c payRolldata = [SELECT Id, 
                                         Name, 
                                         Contact__c, 
                                         Bank_Name__c, 
                                         IFSC_Routing_Number__c,
                                         Beneficiary_Account_Number__c 
                                  FROM PayRoll__c
                                  WHERE Contact__c =: usr.contactId__c
                                  LIMIT 1];
        return payRolldata;
    }
    
    /**
* @author Pavan Tavva
* @date 01/03/2023
* @description To get the family details of logged in user. 
*
* CHANGE HISTORY
* ====================================================================================================
* DATE          NAME                    DESCRIPTION
* N/A           N/A                     N/A
* ====================================================================================================
**/
    @AuraEnabled(cacheable=true)
    public static List<Family_Information__c> getLoggedInUserFamilyData(){
        User usr = [SELECT Id, 
                           contactId__c
                    FROM User
                    WHERE Id =: LeaveRequestConstant.LOGGEDIN_USERID];
        List<Family_Information__c> familyDataList = [SELECT Id, 
                                                             Resource__c,
                                                             Family_Member_Name__c,
                                                             Relationships__c,
                                                             Is_It_Emergency_Contact__c,
                                                             Is_It_Dependent_Contact__c,
                                                             Date_of_Birth__c,
                                                             Contact_Phone_Number__c
                                             FROM Family_Information__c
                                             WHERE Resource__c =: usr.contactId__c];
           return familyDataList; 
    }

    /**
* @author Pavan Tavva
* @date 01/03/2023
* @description To get the contact details of logged in user.
*
* CHANGE HISTORY
* ====================================================================================================
* DATE          NAME                    DESCRIPTION
* N/A           N/A                     N/A
* ====================================================================================================
**/
    @AuraEnabled(cacheable=true)
    public static contact getLoggedInUserContactData() {
        User usr = [SELECT Id, 
                           contactId
                    FROM User
                    WHERE Id =: LeaveRequestConstant.LOGGEDIN_USERID];
        Contact contact = [SELECT Id,
                                  Name,
                                  LastName,
                                  FirstName,
                                  AccountId,
                                  EMS_RM_Employee_Id__c,
                                  Department__c,
                                  Department__r.Name,
                                  Resource_Role__r.Name,
                                  Resource_Role__r.Id,
                                  Resource_Role__c,
                                  Work_Experience__c,
                                  Notice_Period__c
                           FROM CONTACT
                           WHERE Id =:usr.contactId 
                          ];
        return contact;
    }
}