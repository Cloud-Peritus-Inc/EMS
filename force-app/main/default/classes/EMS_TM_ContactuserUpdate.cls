public class EMS_TM_ContactuserUpdate {
      public static void updateuser(List<user> newList){
        map<id,user> contactIds = new map<id,user>();
        Profile profileDetails = [SELECT Id, Name FROM Profile where  name ='TM Customer Community'];
        for(user u: newList){
            if (u.ContactId != null &&  u.ProfileId == profileDetails.id  ){
                contactIds.put(u.ContactId, u);
            }
        }
         system.debug('contactIds'+contactIds);
        list<contact> contactList = new List<contact>();
      RecordType contactRecordType =  [SELECT Id FROM RecordType where name = 'Resource'];
        for(contact con: [Select id,Ems_TM_user__c,RecordTypeId from contact where RecordTypeId =:contactRecordType.Id AND  id =:contactIds.keyset()]){
           
            con.Ems_TM_user__c = contactIds.get(con.id).id;
            contactList.add(con);
        }
        if (contactList.size() > 0){
        update contactList;
        }
        system.debug('contactList'+contactList);
    }
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
    RecordType contactRecordType =  [SELECT Id FROM RecordType where name = 'Resource'];
      System.debug('contactRecordType'+contactRecordType);
      for(contact con: [Select id,Ems_TM_user__c,RecordTypeId,Official_Mail__c from contact where RecordTypeId =:contactRecordType.Id 
                        AND Official_Mail__c =: contactIds.keyset()]){
         
          con.Ems_TM_user__c = contactIds.get(con.Official_Mail__c).id;
           System.debug('   con.Ems_TM_user__c'+ con.Ems_TM_user__c);
          contactList.add(con);
      }
      System.debug('contactList'+contactList);
      System.debug('size'+contactList.size());
      if (contactList.size() > 0){
      update contactList;
      }
  }

}