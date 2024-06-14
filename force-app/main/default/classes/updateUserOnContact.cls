/**
* @author Pallavi and Mukesh 
* @date 10/01/2023
* @description  whenever user created, related contact to get updated
*            
*
*               Test code coverage provided by the following test class:
*               - updateUserOnContactTest
*
* CHANGE HISTORY
* ====================================================================================================
* DATE          NAME                    DESCRIPTION
* N/A           N/A                     N/A
* ====================================================================================================
**/
public class updateUserOnContact implements TriggerAction.AfterInsert {
      /**
    * @author Pallavi and Mukesh
    * @date 10/01/2023
    * @description After Insert 
    *
    * CHANGE HISTORY
    * ====================================================================================================
    * DATE          NAME                    DESCRIPTION
    * N/A           N/A                     N/A
    * ====================================================================================================
    **/    
    public void afterInsert(List<user> newList) {      
        System.debug(LoggingLevel.DEBUG, 'updateUserOnContact.afterInsert() : BEGIN');
        if(!System.isFuture() && !System.isQueueable()){
     //   updateCommunityUser(newList);
        }
        System.debug(LoggingLevel.DEBUG, 'updateUserOnContact.afterInsert() : END');
        
    }
    
    /**
*   {Purpose} - Method whenever user created, related contact to get updated
*
*   CHANGE HISTORY
*   ====================================================================================================
*   Date        Name                    Description
*   N/A         N/A                     N/A
*   ====================================================================================================
**/
    //******Vamsi&Shubham********
    //Commented Below Method As The Same Method Commented In Prod.
    // Because of this method we were getting testclass validation failure erros 
    //https://docs.google.com/spreadsheets/d/1ZGp0LO-aDiA6YPQTbCFfr4nTcLs7n0YtQf4gxgiQ0S8/edit#gid=0.
/*    public static void updateCommunityUser(List<user> newList){
        map<id,user> userMap = new map<id,user>();
        for(user userRecord : newList){
            if (userRecord.ContactId != null){
                userMap.put(userRecord.ContactId, userRecord);
            }
        }
      
        list<contact> contactList = new List<contact>();
        for(contact con: [SELECT id,Ems_TM_user__c,RecordTypeId 
                          FROM contact 
                          WHERE RecordTypeId =:ContactConstant.RESOURCE_RECORDTYPEID 
                          AND  Id IN :userMap.keyset()]){
            if(userMap.containsKey(con.id)){
                con.Ems_TM_user__c = userMap.get(con.id).Id;
                contactList.add(con);
             }
        }
        if (contactList.size() > 0){
            try{
                update contactList;
            }
            catch(Exception ex){
                LogException.logHandledException(ex, 'updateUserOnContact', 'updateCommunityUser');
            }
        }
        
        
    }
*/

}