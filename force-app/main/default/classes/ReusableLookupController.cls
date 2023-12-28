public without sharing class ReusableLookupController {
    @AuraEnabled
    public static List<ResultWrapper> fetchRecords(SearchWrapper inputWrapper) {
        try {
            if (inputWrapper != null) {
                String fieldsToQuery = 'SELECT Id, ';
                if (String.isNotBlank(inputWrapper.fieldApiName)) {
                    fieldsToQuery = fieldsToQuery + inputWrapper.fieldApiName;
                }
                if (String.isNotBlank(inputWrapper.otherFieldApiName)) {
                    fieldsToQuery = fieldsToQuery + ', ' + inputWrapper.otherFieldApiName;
                }
                //smake
                if (String.isNotBlank(inputWrapper.otherFieldApiName2)) {
                    fieldsToQuery = fieldsToQuery + ', ' + inputWrapper.otherFieldApiName2;
                }

                String query = fieldsToQuery + ' FROM ' + inputWrapper.objectApiName;
                String filterCriteria = inputWrapper.fieldApiName + ' LIKE ' + '\'' + String.escapeSingleQuotes(inputWrapper.searchString.trim()) + '%\'';
                
                //filterCriteria += ' AND ' + inputWrapper.otherFieldApiName + ' = \'Active\' LIMIT 10';


                filterCriteria += ' AND ' + inputWrapper.otherFieldApiName + ' = \'Active\'';
                filterCriteria += ' AND ' + inputWrapper.otherFieldApiName2 + ' = true LIMIT 10'; // Assuming otherFieldApiName2 is a checkbox field






                if (String.isNotBlank(inputWrapper.selectedRecordId)) {
                    query += ' WHERE Id = \'' + inputWrapper.selectedRecordId + '\'';
                } else if (String.isNotBlank(inputWrapper.parentFieldApiName) && String.isNotBlank(inputWrapper.parentRecordId)) {
                    query += ' WHERE ' + inputWrapper.parentFieldApiName + ' = \'' + inputWrapper.parentRecordId + '\'';
                    query += ' AND ' + filterCriteria;
                } else {
                    query += ' WHERE ' + filterCriteria;
                }

                List<ResultWrapper> returnWrapperList = new List<ResultWrapper>();
                for (SObject s : Database.query(query)) {
                    ResultWrapper wrap = new ResultWrapper();
                    wrap.mainField = (String) s.get(inputWrapper.fieldApiName);
                    wrap.subField = (String) s.get(inputWrapper.otherFieldApiName);
                    wrap.id = (String) s.get('id');
                    returnWrapperList.add(wrap);
                }
                return returnWrapperList;
            }
            return null;
        } catch (Exception err) {
            throw new AuraHandledException(err.getMessage());
        }
    }

    public class ResultWrapper{
        @AuraEnabled public String mainField{get;set;}
        @AuraEnabled public String subField{get;set;}
        @AuraEnabled public String id{get;set;}
    }

    public class SearchWrapper {
        @AuraEnabled public String objectApiName{get;set;}
        @AuraEnabled public String fieldApiName{get;set;}
        @AuraEnabled public String otherFieldApiName{get;set;}
        //smaske
        @AuraEnabled public String otherFieldApiName2{get;set;}
        @AuraEnabled public String searchString{get;set;}
        @AuraEnabled public String selectedRecordId{get;set;}
        @AuraEnabled public String parentRecordId{get;set;}
        @AuraEnabled public String parentFieldApiName{get;set;}
    }
}