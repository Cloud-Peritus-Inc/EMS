import { LightningElement, track, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getTheCurrentData from '@salesforce/apex/newServiceRequestController.getTheCurrentData';
export default class MyServiceRequests extends NavigationMixin(LightningElement) {
    @track caseList;
    @track wrapdate;
    numberofCompleted = 0;
    numberofInprogress = 0;
    numberofOpen = 0;
    nodata = false;
    connectedCallback() {

    }

    loaded = false
    @wire(getTheCurrentData)
    wiredLabels({ error, data }) {
        if (data) {
            console.log('### service request : ', data);
            
                this.caseList = data.caseList;
                if (this.caseList.length >0) {
                this.numberofCompleted = data.closedCases;
                this.numberofInprogress = data.inprogressCases;
                this.numberofOpen = data.openCases;
                this.loaded = true;
            } else {
                this.nodata = true;
            }
        }
        if (error) {
            console.log('-======---=ERROR==--=-=-' + JSON.stringify(error));
        }
    }



    handleCaseClick(event) {
        let selectexp = event.currentTarget.dataset.id;
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: selectexp,
                objectApiName: 'Case',
                actionName: 'view'
            },
        });
    }


    handleClick() {
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: '/recordlist/Case/Default'
            }
        });
    }
}