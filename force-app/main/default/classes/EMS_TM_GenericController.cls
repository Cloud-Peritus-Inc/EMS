public class EMS_TM_GenericController {

    @AuraEnabled(cacheable=true)
    public static List<sObject> search(String searchTerm, string myObject, String filter, Boolean fullName) {
        String myQuery = null;
        List<sObject> lookUpList = new List<sObject>();
        if(filter != null && filter != '') {
            if(searchTerm == null || searchTerm == '') {
                if (fullName) {
                    myQuery = 'Select Id, Name, LastName, FirstName from ' + myObject + ' Where ' + filter + ' LIMIT  5';
                    System.debug('myQueryfilter '+myQuery);
                } else {
                    myQuery = 'Select Id, Name from ' + myObject + ' Where ' + filter + ' LIMIT  5';
                    System.debug('myQueryfilter '+myQuery);
                }
            } else {
                if (fullName) {
                    myQuery = 'Select Id, Name, LastName, FirstName from ' + myObject + ' Where Name Like  \'%' + searchTerm + '%\' AND ' + filter + ' LIMIT  5';
                    System.debug('myQueryfilter search '+myQuery);
                } else {
                    myQuery = 'Select Id, Name from ' + myObject + ' Where Name Like  \'%' + searchTerm + '%\' AND ' + filter + ' LIMIT  5';
                    System.debug('myQueryfilter search '+myQuery);
                }
            }
        } else {
            if(searchTerm == null || searchTerm == '') {
                myQuery = 'Select Id, Name from '+myObject+' Where LastViewedDate != NULL ORDER BY LastViewedDate DESC LIMIT  5';
                System.debug('myQueryonly '+myQuery);
            } else {
                myQuery = 'Select Id, Name from '+myObject+' Where Name Like  \'%' + searchTerm + '%\' LIMIT  5';
                System.debug('myQuerysearch '+myQuery);
            }
        }
        lookUpList = database.query(myQuery);
        SYstem.debug('lookUpList '+lookUpList);
        return lookUpList;
    }
}