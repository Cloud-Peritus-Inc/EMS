public class SharingRecordsToHRProfile {
    public static void sharingRecordstoHRProfileMethod(){
        //List<Contact> conlist=[select id,name from contact where name='onkolu Lokesh'];
        //list<account> account=[select id,Name from account where Name='Cloud Peritus Inc' LIMIT 1];
       // list<user> user=[select id,name from user]
        ContactShare conshare=new ContactShare();
        conshare.ContactId='0035200000r8ZUMAA2';
        conshare.UserOrGroupId='00G52000007DnIREA0';//00552000007aGo9AAE //00552000007xTqVAAU
        conshare.ContactAccessLevel='Read';
        insert conshare;
    }
}