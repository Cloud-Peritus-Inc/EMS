import { LightningElement } from 'lwc';
import u_Id from '@salesforce/user/Id';
import getUserProfileInfo from '@salesforce/apex/EMS_LM_ContactLeaveUpdate.getProfileName';

export default class EMS_LM_LeaveManagement extends LightningElement {
    uId = u_Id;
    profileName;
    showTabAdmin = false ;

    connectedCallback(){
        getUserProfileInfo({userid :this.uId}).then( result => {
            this.profileName = result;
            console.log(this.profileName);
            if(this.profileName == 'TM HR Director Customer Community' || this.profileName == 'System Administrator' || this.profileName == 'TM Project Manager Customer Community'){
                this.showTabAdmin = true; 
            }
        }).catch(err => {
            console.log(err);
        });
      }


}