import { LightningElement, wire } from 'lwc';
import getLoggedInUserResReportsSize from '@salesforce/apex/LeaveHistoryApexController.getLoggedInUserResReportsSize';
export default class GridHomePage extends LightningElement {

    hidePendingTab = false;
    hidetimeTab = false;

    @wire(getLoggedInUserResReportsSize)
    getLoggedInUserResReportsSizeWiredData({ error, data }) {
        if (data) {
<<<<<<< HEAD
            console.log('### getLoggedInUserResReportsSize', data);
            if (data.relationAcess > 0) {
                this.hidePendingTab = true;
            }
            if(data.hraccess == true){
              this.hidetimeTab = true;
=======
            //console.log('### getLoggedInUserResReportsSize', data);
            if (data.relationAcess > 0) {
                this.hidePendingTab = true;
              
>>>>>>> 18thjuly-prod2
            }
            if(data.hraccess == true){
              this.hidetimeTab = true;
            }
            //console.log('### hidePendingTab : ', this.hidePendingTab);
        } else if (error) {
            console.error('Error:', error);
        }
    }
}
