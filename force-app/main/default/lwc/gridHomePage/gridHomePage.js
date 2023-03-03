import { LightningElement, wire } from 'lwc';
import getLoggedInUserResReportsSize from '@salesforce/apex/LeaveHistoryApexController.getLoggedInUserResReportsSize';
export default class GridHomePage extends LightningElement {

    hidePendingTab;

    @wire(getLoggedInUserResReportsSize)
    getLoggedInUserResReportsSizeWiredData({ error, data }) {
        if (data) {
            console.log('### getLoggedInUserResReportsSize', data);
            if (data > 0) {
                this.hidePendingTab = data;
            }
            console.log('### hidePendingTab : ', this.hidePendingTab);
        } else if (error) {
            console.error('Error:', error);
        }
    }
}