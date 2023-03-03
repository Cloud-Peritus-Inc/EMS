import { LightningElement, wire } from 'lwc';
import u_Id from '@salesforce/user/Id';
import getLoggedInUserResReportsSize from '@salesforce/apex/LeaveHistoryApexController.getLoggedInUserResReportsSize';
import getUserProfileInfo from '@salesforce/apex/EMS_LM_ContactLeaveUpdate.getProfileName';

export default class EMS_LM_LeaveManagement extends LightningElement {
    uId = u_Id;
    profileName;
    showTabAdmin = false;
    hidePendingTab;

    connectedCallback() {
        getUserProfileInfo({ userid: this.uId }).then(result => {
            this.profileName = result;
            console.log('### this.profileName : ', this.profileName);
            if (this.profileName == 'Employee - HR(Community)' || this.profileName == 'System Administrator') {
                this.showTabAdmin = true;
            }
        }).catch(err => {
            console.log(err);
        });
    }

    handleRefresh() {
        const lwc1 = this.template.querySelector('c-e-m-s-_-l-m-_-leave-balance');
        const lwc2 = this.template.querySelector('c-e-m-s-_-l-m-_-apply-new');

        lwc1.refresh();
        lwc2.refresh();
    }

    @wire(getLoggedInUserResReportsSize)
    getLoggedInUserResReportsSizeWiredData({ error, data }) {
        if (data) {
            console.log('### getLoggedInUserResReportsSize', data);
            if (data > 0) {
                this.hidePendingTab = data;
            }
            console.log('### hidePendingTab : ',this.hidePendingTab);
        } else if (error) {
            console.error('Error:', error);
        }
    }

}