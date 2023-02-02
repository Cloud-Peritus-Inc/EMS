/**
* @author Pallavi and Mukesh 
* @date 10/01/2023
* @description  Whenever user created, related contact to get updated. 
*             
*               Test code coverage provided by the following test class:
*               - updateAdminUseronContactTest
*
* CHANGE HISTORY
* ====================================================================================================
* DATE          NAME                    DESCRIPTION
* N/A           N/A                     N/A
* ====================================================================================================
**/
public class updateAdminUseronContact implements TriggerAction.AfterInsert {
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
        System.debug(LoggingLevel.DEBUG, 'updateAdminUseronContact.afterInsert() : BEGIN');
        adminUserContactUpdate(newList);
        System.debug(LoggingLevel.DEBUG, 'updateAdminUseronContact.afterInsert() : END');
    }
    
     /**
    *   {Purpose} - Method whennever user created, related contact to get updated
    *
    *   CHANGE HISTORY
    *   ====================================================================================================
    *   Date        Name                    Description
    *   N/A         N/A                     N/A
    *   ====================================================================================================
    **/
    
       public static void adminUserContactUpdate(List<user> newList){
        map<string,user> contactIds = new map<string,user>();
      Profile profileDetails = [SELECT Id, Name FROM Profile where  name ='System Administrator'];
      System.debug('profileDetails'+profileDetails);
      System.debug('newList'+ newList[0].ProfileId);
      
      for(user u: newList){
          if (u.ProfileId == profileDetails.id  ){
              contactIds.put(u.Email, u);
          }
          
      }
       system.debug('contactIds'+contactIds);
      list<contact> contactList = new List<contact>();
      for(contact con: [Select id,Ems_TM_user__c,RecordTypeId,Official_Mail__c from contact where RecordTypeId =:ContactConstant.RESOURCE_RECORDTYPEID 
                        AND Official_Mail__c =: contactIds.keyset()]){
         
          con.Ems_TM_user__c = contactIds.get(con.Official_Mail__c).id;
           System.debug(' con.Ems_TM_user__c'+ con.Ems_TM_user__c);
          contactList.add(con);
      }
      System.debug('contactList'+contactList);
      System.debug('size'+contactList.size());
      if (contactList.size() > 0){
      update contactList;
      }
  }



}