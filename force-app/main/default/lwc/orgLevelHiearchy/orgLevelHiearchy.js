import { LightningElement,wire,api } from 'lwc';
import getUserHiearchyInfo from '@salesforce/apex/resourceTileController.getUserHiearchyInfo';


export default class OrgLevelHiearchy extends LightningElement {
users;
@wire(getUserHiearchyInfo)
    wiredEmployees({ error, data }) {
        if (data) {
           console.log('======data====='+JSON.stringify(data));
            this.users = data;
        } else if (error) {
            console.log(error);
        }
    }

    

}