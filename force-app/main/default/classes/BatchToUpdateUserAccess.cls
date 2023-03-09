/**
* @author Subba Kalavala
* @date 2/22/2023
* @description  BatchToUpdateUserAccess Batch to update the access at user level  
*              
*               Schedule class 
*               - BatchToUpdateUserAccess_sch
*               Test code coverage provided by the following test class:
*               - BatchToUpdateUserAccess_Test
*
* CHANGE HISTORY
* ====================================================================================================
* DATE          NAME                    DESCRIPTION
* N/A           N/A                     N/A
* ====================================================================================================
**/
global class BatchToUpdateUserAccess  implements Database.Batchable<sObject> {
 public Map<String,String> accesswithApi;
    
    global BatchToUpdateUserAccess(){
        this.accesswithApi = new Map<String,String>();
        for(User_Access_Mapping__mdt uam : [SELECT Id,Permissionset_API_Name__c,User_Field_API_Name__c FROM User_Access_Mapping__mdt]){
            accesswithApi.put(uam.Permissionset_API_Name__c,uam.User_Field_API_Name__c);
        }
        
    }
 /**
* @author Subba
* @date 22/01/2023
* @description start query to get the data of the object that required to process.
*
* CHANGE HISTORY
* ====================================================================================================
* DATE          NAME                    DESCRIPTION
* N/A           N/A                     N/A
* ====================================================================================================
**/
    global Database.QueryLocator start(Database.BatchableContext BC) {
        if(accesswithApi.isEmpty()){
         for(User_Access_Mapping__mdt uam : [SELECT Id,Permissionset_API_Name__c,User_Field_API_Name__c FROM User_Access_Mapping__mdt]){
            accesswithApi.put(uam.Permissionset_API_Name__c,uam.User_Field_API_Name__c);
        }   
        }
        date dt = system.today();
        return Database.getQueryLocator([SELECT Id,Email,Name,
                                         (SELECT permissionsetid,PermissionSet.Name FROM permissionsetassignments WHERE PermissionSet.Name IN:accesswithApi.keySet())
                                         FROM USER 
                                         WHERE isActive = true ]);
    }


/**
* @author Subba
* @date 22/01/2023
* @description  Execute method to process the business logic.
*
* CHANGE HISTORY
* ====================================================================================================
* DATE          NAME                    DESCRIPTION
* N/A           N/A                     N/A
* ====================================================================================================
**/
    global void execute(Database.BatchableContext BC, List<User> userList) {
            for(User urec : userList){
                for(String strApi : accesswithApi.values()){
                     urec.put(strApi,false);
                }
                for(permissionsetassignment psa : urec.permissionsetassignments){
                        if(accesswithApi.containsKey(psa.PermissionSet.Name)){
                            urec.put(accesswithApi.get(psa.PermissionSet.Name),true);
                        }
                }
            }
         try{
           update userList; 
        }catch(exception ex){
           LogException.logHandledException(ex, 'BatchToUpdateUserAccess', 'execute');  
        }
       
        
    }
    /**
* @author Subba
* @date 22/01/2023
* @description process the failures.
*
* CHANGE HISTORY
* ====================================================================================================
* DATE          NAME                    DESCRIPTION
* N/A           N/A                     N/A
* ====================================================================================================
**/
    global void finish(Database.BatchableContext BC) {
        
    }   
}