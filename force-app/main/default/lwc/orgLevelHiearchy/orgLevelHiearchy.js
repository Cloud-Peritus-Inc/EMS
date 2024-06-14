import { LightningElement,wire,api, track } from 'lwc';
import getUserHiearchyInfo from '@salesforce/apex/resourceTileController.getUserHiearchyInfo';


export default class OrgLevelHiearchy extends LightningElement {
users;
@track isShowModal = false;

@wire(getUserHiearchyInfo)
    wiredEmployees({ error, data }) {
        console.log('11')
        console.log('======getUserHiearchyInfo====='+JSON.stringify(data));
        if (data) {
           console.log('======reporteesOfDirectReports====='+JSON.stringify(data));
            this.users = data;
        } else if (error) {
            console.log(error);
        }
    }

    handleviewHier(){
        this.isShowModal = true;
    }
    hideModalBox() {  
        this.isShowModal = false;
    }

}