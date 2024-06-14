public class sharecontactstoPM {
    public static void sharingcontacts(string userid){
        system.debug('userid======================================================='+userid);
         User urecord = [SELECT Id,contactId FROM User WHERE Id = :userid];
        system.debug('urecord======================================================='+urecord);
        list<Id> projectmanagerlist=new list<Id>();
        list<contactshare> consharelist=new list<contactshare>();
        Map<Id,string> projectmanager=new map<Id,string>();
         set<Id> setid=new set<Id>();
                system.debug('projectrecords======================================================='+[select id,Name,Account__c,Account__r.Name,Project_Manager__c from EMS_TM_Project__c where Project_Manager__c=:urecord.contactId]);
        for(EMS_TM_Project__c project:[select id,Name,Account__c,Account__r.Name,Project_Manager__c from EMS_TM_Project__c where Project_Manager__c=:urecord.contactId]){
            if(project.Account__c!=null){
            projectmanagerlist.add(project.Project_Manager__c);
            setid.add(project.Account__c);
            projectmanager.put(project.Project_Manager__c,project.Name);
        }
        }
        system.debug('projectmanagerlist======================================================='+projectmanagerlist);
        system.debug('setid======================================================================'+setid);
         system.debug('projectmanager================================================================'+projectmanager);
          system.debug('query==============================================================='+[select id,name from contact where accountid IN:setid]);
                     
       // list<contact> contact=[select id,name fromcontact where accountid IN:setid];
        for(contact con:[select id,name from contact where accountid IN:setid]){
            contactshare conshare=new contactshare();
            conshare.ContactId=con.Id;
            conshare.ContactAccessLevel='Read';
            conshare.UserOrGroupId='0035200000pLVGUAA4';
            consharelist.add(conshare);
        }
        insert consharelist;
        
             }
}