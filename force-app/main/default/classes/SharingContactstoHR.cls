public class SharingContactstoHR {
      public static void shareContactsForHR1(String accountName) {
        
        //Id hrProfileId = [SELECT Id FROM Profile WHERE Name = 'Employee - HR(Community)'].Id;
          //Id hrUserId = [SELECT Id FROM User WHERE ProfileId = :hrProfileId LIMIT 1].Id;
        id hrUserId='00G52000007DnIREA0';
        Id accountId = [SELECT Id FROM Account WHERE Name = :accountName].Id;

       
        List<ContactShare> contactSharesToCreate = new List<ContactShare>();

        
        List<Contact> contactsToShare = [SELECT Id, AccountId FROM Contact WHERE AccountId = :accountId];
        
        
        for (Contact contact : contactsToShare) {
            
            ContactShare contactShare = new ContactShare();
            contactShare.ContactId = '0035200000n1LtQAAU';
            contactShare.UserOrGroupId ='00G52000007DnIREA0'; //00G52000007DnIREA0
            contactShare.ContactAccessLevel = 'Read'; 
            contactSharesToCreate.add(contactShare);
        }

      
        if (!contactSharesToCreate.isEmpty()) {
            insert contactSharesToCreate;
        }
    }
}