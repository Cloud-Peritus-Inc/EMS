import { LightningElement, api, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import LightningConfirm from 'lightning/confirm';
import createTheGoals from '@salesforce/apex/myGoalsController.createTheGoals';
export default class Kratable extends NavigationMixin(LightningElement) {
    @api tab;
    @api copy = false;
    @api viewonlymode = false;
    @api tabledata = [];
    @api resourceid = '';
    selectedKraQuaterly;
    @track mode;
    @track iconName = "utility:chevrondown";
    @track iconParentName = "utility:chevronright";
    @track minDate;//smaske :[UAT_005]
    orgDomainId;


    get kraTableAvailble() {
        if (this.tabledata && this.tabledata.length > 0) {
            return true;
        } return false;
    }

    connectedCallback() {
        //console.log('RECEIVED tabledata  ::: ' + JSON.stringify(this.tabledata));
        console.log('====resourceid===' + JSON.stringify(this.resourceid));
        console.log('====tab===' + this.tab);
        console.log('====viewonlymode===' + this.viewonlymode);
        this.tbData = JSON.parse(JSON.stringify(this.tabledata))

        if (this.tbData.length > 0) {
            console.log(this.tbData.nameid);
            console.log(this.tbData[0].nameid);
            this.tbData.forEach(item => {
                if (item.qualList && item.qualList.length > 0) {
                    this.qualListdata = true;
                } else {
                    this.qualListdata = false;
                }

                //smaske : [EN_23/UAT_066] : Disabling the EDIT button based on tab and submit status for mentee and mentor
                let tableRecordsData = item.qualList;
                console.log('tableRecordsData Length ' + tableRecordsData.length);
                tableRecordsData.forEach(qualItem => {
                    if (qualItem.mentorSubmitted && this.tab == 'My Team') {
                        qualItem.allowedit = false;
                        qualItem.allowCopy = false;
                    } else if (qualItem.menteeSubmitted && this.tab == 'My Metric') {
                        console.log('51');
                        qualItem.allowedit = false;
                        qualItem.allowCopy = false;
                    }
                });
            });

            console.log('tableRecordsData modified ' + JSON.stringify(this.tabledata));
        }

        //smaske :[UAT_005] : Setting the minimum date to tomorrow 
        var d = new Date();
        var today = d.getFullYear() + '-' + (d.getMonth() + 1).toString().padStart(2, '0') + '-' + d.getDate().toString().padStart(2, '0');
        var tomorrow = new Date(d);
        tomorrow.setDate(d.getDate() + 1);
        var month = (tomorrow.getMonth() + 1).toString().padStart(2, '0');
        var day = tomorrow.getDate().toString().padStart(2, '0');
        this.minDate = `${tomorrow.getFullYear()}-${month}-${day}`;

        this.orgDomainId = window.location.origin;
        //this.enableDisableCreateGoalButton();
    }
    @track showKRAViewModal = false;
    @track showKRAEditModal = false;
    @track showGoalModal = false;
    @track showGoalCreationModal = false;
    myVal = '';

    hideKRAViewModalBox() {
        this.showKRAViewModal = false;

    }

    handleConNavViewClick(event) {
        let node = event.currentTarget.dataset.id;
        this.selectedKraQuaterly = node;
        this.mode = 'View';
        console.log('==node====' + node);
        const url = `${this.orgDomainId}/Grid/s/kra-view?c__kraid=${this.selectedKraQuaterly}&tab=${this.tab}`;
        window.open(url, '_blank');
        // window.open('https://cpprd--dev.sandbox.my.site.com/Grid/s/kra-view?c__kraid='+this.selectedKraQuaterly+ '&tab='+this.tab, '_blank');
    }

    showKRAViewModalBox() {
        this.showKRAViewModal = false;
        console.log('=====kraview=====' + this.selectedKraQuaterly);
        console.log('Navigating to FlexiPage...');
        this[NavigationMixin.Navigate]({
            type: 'standard__navItemPage',
            attributes: {
                apiName: 'leave-management'
            },
            state: {
                c__kraid: this.selectedKraQuaterly
            }
        }).then((result) => {
            console.log('Navigation result:', result);
        }).catch((error) => {
            console.error('Navigation error:', error);
        });
    }

    hideKRAEditModalBox() {
        this.showKRAEditModal = false;
        this.dispatchEvent(new CustomEvent('kradata'));

    }

    showKRAEditModalBox() {
        this.showKRAEditModal = true;
    }

    hideGoalModalBox() {
        this.showGoalModal = false;

    }

    showGoalModalBox() {
        this.showGoalModal = true;
    }

    hideGoalCreateModalBox() {
        this.showGoalCreationModal = false;
        this.myVal = '';
        this.goalname = '';
        this.descri = '';
        this.goalstartdate = null;
        this.goalenddate = null;

    }

    showGoalCreateModalBox() {
        this.showGoalCreationModal = true;
    }


    //   displayChildRecords(nodeID){
    //         let node = nodeID;
    //         console.log(nodeID);
    //         let childNode = this.template.querySelector(`tr[data-parentid="${node}"]`);
    //         console.log('Child node');
    //          console.log(childNode);
    //         if (childNode.classList.contains('hideContent')) {
    //             childNode.classList.remove('hideContent');
    //             this.template.querySelector(`lightning-icon[data-id="${node}"]`).iconName = this.iconName;

    //         } else {
    //             childNode.classList.add('hideContent');
    //             this.template.querySelector(`lightning-icon[data-id="${node}"]`).iconName = this.iconParentName;
    //         }

    //   }

    // display/hide the nested content
    handleContactChild(event) {
        let node = event.currentTarget.dataset.id;
        console.log('node');
        console.log(node);
        let childNode = this.template.querySelector(`tr[data-parentid="${node}"]`);
        console.log('Child node');
        console.log(childNode);
        if (childNode.classList.contains('hideContent')) {
            childNode.classList.remove('hideContent');
            this.template.querySelector(`lightning-icon[data-id="${node}"]`).iconName = this.iconName;

        } else {
            childNode.classList.add('hideContent');
            this.template.querySelector(`lightning-icon[data-id="${node}"]`).iconName = this.iconParentName;
        }
    }

    handleGaolClick(event) {
        let node = event.currentTarget.dataset.id;
        this.selectedKraQuaterly = node;
        console.log('==node====' + node);
        this.showGoalModalBox();
    }
    selectedFulfilment = '';
    handleGoalCreateClick(event) {
        let node = event.currentTarget.dataset.id;
        this.selectedFulfilment = node;
        this.showGoalCreateModalBox();
    }

    handleConNavClick(event) {
        let node = event.currentTarget.dataset.id;
        this.selectedKraQuaterly = node;
        this.mode = 'View';
        console.log('==node====' + node);
        this.showKRAViewModalBox();
    }

    handleConNavEditClick(event) {
        let node = event.currentTarget.dataset.id;
        this.selectedKraQuaterly = node;
        console.log('selectedKraQuaterly' + this.selectedKraQuaterly);
        this.mode = 'Edit';
        console.log('==node====' + node);
        this.showKRAEditModalBox();
    }

    handleNavClick(event) {
        let node = event.currentTarget.dataset.id;
        console.log('==node====' + node);
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: node,
                objectApiName: 'Fulfillment__c',
                actionName: 'view'
            }
        });
    }


    handlegoalview(event) {
        console.log('===event.currentTarget.dataset.id=====' + event.currentTarget.dataset.id);
    }

    handleNavTozoomClick(event) {
        let node = event.currentTarget.dataset.id;
        var url = new URL('https://app.zoominfo.com/#/apps/profile/company/' + node + '/overview');
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: url.href

            },
        });

    }


    handledescChange(event) {
        this.myVal = event.target.value;
    }
    goalstartdate;
    goalenddate;
    goalname;

    handleGoalNameChange(event) {
        this.goalname = event.target.value;
    }
    handleGoalStartChange(event) {
        this.goalstartdate = event.target.value;
    }
    handleGoalEndChange(event) {
        this.goalenddate = event.target.value;
    }
    createTheGoal() {

        var todaysDate = new Date();
        var givenDate = new Date(this.goalstartdate);
        if (!this.goalname) {
            const evt = new ShowToastEvent({
                //title: 'Toast Error',
                message: 'Goal Name is required',
                variant: 'error',
                mode: 'dismissable'
            });
            this.dispatchEvent(evt);
        } else if (!this.goalstartdate) {
            const evt = new ShowToastEvent({
                //title: 'Toast Error',
                message: 'Goal Start Date is required',
                variant: 'error',
                mode: 'dismissable'
            });
            this.dispatchEvent(evt);
        } else if (!this.goalenddate) {
            const evt = new ShowToastEvent({
                //title: 'Toast Error',
                message: 'Goal End Date is required',
                variant: 'error',
                mode: 'dismissable'
            });
            this.dispatchEvent(evt);
        } else if (!this.myVal) {
            const evt = new ShowToastEvent({
                //title: 'Toast Error',
                message: 'Description is required',
                variant: 'error',
                mode: 'dismissable'
            });
            this.dispatchEvent(evt);
        } else if (this.goalstartdate > this.goalenddate) {
            const evt = new ShowToastEvent({
                //title: 'Toast Error',
                message: 'Start date should be less than end date',
                variant: 'error',
                mode: 'dismissable'
            });
            this.dispatchEvent(evt);

        } else if (givenDate < todaysDate) {
            const evt = new ShowToastEvent({
                //title: 'Toast Error',
                message: 'Start Date should be in future.',
                variant: 'error',
                mode: 'dismissable'
            });
            this.dispatchEvent(evt);
        } else {
            console.log('selectedFulfilment ' + this.selectedFulfilment);
            console.log('resourceRTId ' + this.resourceid);
            console.log('name ' + this.goalname);
            console.log('startdate ' + this.goalstartdate);
            console.log('enddate ' + this.goalenddate);
            console.log('descri ' + this.myVal);
            createTheGoals({
                fulfilmentId: this.selectedFulfilment,
                resourceRTId: this.resourceid,
                name: this.goalname,
                startdate: this.goalstartdate,
                enddate: this.goalenddate,
                descri: this.myVal
            }).then(res => {
                const evt = new ShowToastEvent({
                    //title: 'success',
                    message: 'The goal has been set successfully. Make sure to finish it within the specified deadlines.',
                    variant: 'success',
                    mode: 'dismissable'
                });
                this.dispatchEvent(evt);
                this.showGoalCreationModal = false;
                this.myVal = '';
                this.goalname = '';
                this.descri = '';
                this.goalstartdate = null;
                this.goalenddate = null;
            }).catch(err => {
                const evt = new ShowToastEvent({
                    //title: 'Toast Error',
                    message: err.body.message,
                    variant: 'error',
                    mode: 'dismissable'
                });
                this.dispatchEvent(evt);

            });
        }


    }

    async handleCopyPreviousQuaterKRA(event) {
        let node = event.currentTarget.dataset.id;
        this.selectedKraQuaterly = node;
        console.log('selectedKraQuaterly' + this.selectedKraQuaterly);
        this.mode = 'Edit';
        console.log('==node====' + node);
        console.log('Copy Clicked');
        const result = await LightningConfirm.open({
            message: 'Would you like to carry over the previous quarter KRA inputs?',
            variant: 'header',
            label: 'Confirm Copy KRA',
            style: 'text-align:center;',
            theme: 'info',
            // setting theme would have no effect
        });
        if (result === true) {
            this.copy = true;
            this.showKRAEditModalBox();
        }
    }

}