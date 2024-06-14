public class ContactConstant {
public static final Id RESOURCE_RECORDTYPEID = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Resource').getRecordTypeId();
public static final Id APPLICANT_RECORDTYPEID = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Applicant').getRecordTypeId();
}