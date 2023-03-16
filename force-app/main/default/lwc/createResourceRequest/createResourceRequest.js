import { LightningElement } from 'lwc';

import RESOURCEREQUEST_OBJECT from '@salesforce/schema/Resource_Request__c';
import STARTDATE_FIELD from '@salesforce/schema/Resource_Request__c.Expected_Start_Date__c';
import PROJECT_FIELD from '@salesforce/schema/Resource_Request__c.Project__c';
import PRIORITY_FIELD from '@salesforce/schema/Resource_Request__c.Request_Priority__c';
import REQUESTEDBY_FIELD from '@salesforce/schema/Resource_Request__c.Requested_By__c';
import RESOURCEROLE_FIELD from '@salesforce/schema/Resource_Request__c.Resource_Role1__c';
import SKILLS_FIELD from '@salesforce/schema/Resource_Request__c.Skills__c';
import STATUS_FIELD from '@salesforce/schema/Resource_Request__c.Status__c';

export default class CreateResourceRequest extends LightningElement {
    objectName = RESOURCEREQUEST_OBJECT;
    fields={ 
        expectedstartDate:STARTDATE_FIELD,
        projet:PROJECT_FIELD,
        requestedby:REQUESTEDBY_FIELD,
        priority:PRIORITY_FIELD,
        resourcerole:RESOURCEROLE_FIELD,
        skills:SKILLS_FIELD,
        status:STATUS_FIELD
    }

    connectedCallback() {
        console.log('### fields: ' + JSON.stringify(fields));
        console.log('### fields: ' + JSON.stringify(this.fields));
        
    }

    handelReset(){
       const inputfields = this.template.querySelectorAll('lightning-input-field');
       console.log(inputfields);
       if(inputfields){
           Array.from(inputfields).forEach(fields=>{
               fields.reset()
           })
       }
    }
}