import { LightningElement, track, wire, api } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getRelatedAssignments from '@salesforce/apex/MultiAssignmentController.getRelatedAssignments';
import deleteAssignmentHandler from '@salesforce/apex/MultiAssignmentController.deleteAssignmentHandler';
import saveAssignmentData from '@salesforce/apex/MultiAssignmentController.saveAssignmentData';
import getTotalProjectAllocationContactRecords from '@salesforce/apex/ChangeProjectActionButtonController.getTotalProjectAllocationContactRecords';//smaske

export default class AssignMutipleResources extends NavigationMixin(LightningElement) {
    @track assignDataWrp;
    @track blankRow = [];
    @track disabledCheckbox = true;
    @track index = 0;
    @track selectedProject;
    @track accountName;
    @api recordId;

    @wire(CurrentPageReference)
    getPageReferenceParameters(currentPageReference) {
        if (currentPageReference) {
            console.log(currentPageReference);
            this.recordId = currentPageReference.attributes.recordId || null;

        }
    }

    @wire(getRelatedAssignments, { prjId: '$recordId' })
    savedRecordIdWire({ error, data }) {
        if (data) {
            // console.log('===event.detail.345value[0]==='+this.recordId);
            this.selectedProject = this.recordId;
            //console.log('====selectedProject========'+JSON.stringify(data));
            //  console.log('====this.selectedProject========'+this.selectedProject);
            this.assignDataWrp = data;
            this.index = data.length;
        } else if (error) {
            // console.log('====No Date====='+JSON.stringify(error));
        }
    }

    handleAccountId(event) {
        //console.log('===event.detail.value[0]==='+this.recordId);
        let projectId = event.detail.value[0];
        // console.log('===event.detail.value[0]==='+projectId);
        if (projectId !== undefined) {
            this.selectedProject = projectId;
            this.assignDataWrp = [];
            getRelatedAssignments({ prjId: projectId }).then(result => {
                this.assignDataWrp = result;
                this.index = result.length;
            }).catch(error => {
                console.log(error);
            })
        } else {
            this.blankRow = [];
            this.index = 0;
            this.assignDataWrp = [];
        }
    }

    async deleteRecord(event) {

        const selectedAss = this.assignDataWrp[event.target.value];
        deleteAssignmentHandler({ assId: selectedAss.Id, projId: selectedAss.EMS_TM_ProjectName_Asgn__c })
            .then(result => {
                this.assignDataWrp = result;
                this.dispatchEvent(new ShowToastEvent({
                    message: 'Assignment Deleted Successfully!.',
                    variant: 'success'
                }),);
            }).catch(error => {
                window.console.log('Error ====> ' + error);
                console.log('errors==========',JSON.stringify(error));
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Error!!',
                    message: 'Unable to delete because it is associated with the timesheet records',
                    variant: 'error'
                }),);
            })
    }

    /*  deleteRecord(event){
         //console.log('==event.target.value==='+event.target.value);
         const selectedAss = this.assignDataWrp[event.target.value];
         window.alert(JSON.stringify(this.assignDataWrp) + ' & ' + event.target.value + ' & ' + JSON.stringify(selectedAss));
         deleteAssignmentHandler({assId: selectedAss.Id, projId: selectedAss.EMS_TM_ProjectName_Asgn__c}).then(result => {
             this.assignDataWrp = result;
         }).catch(error => {
             window.alert(JSON.stringify(error));
         })
     } */

    addRow(event) {
        this.index++;
        let i = this.index;
        let newAssignment = new Object();
        let blankRow = this.blankRow;
        newAssignment.Id = i;
        newAssignment.isChecked = false;
        blankRow.push(newAssignment);
        this.blankRow = blankRow;
    }

    removeRow(event) {
        const eventName = event.target.name;
        let blankRow = this.blankRow;
        let assDataList = [];
        for (let i = 0; i < blankRow.length; i++) {
            if (blankRow[i] !== undefined && blankRow[i].isChecked) {
                let assData = new Object();
                assData.EMS_TM_Status_Asgn__c = blankRow[i].EMS_TM_Status_Asgn__c;
                assData.EMS_TM_AssignedAs__c = blankRow[i].EMS_TM_AssignedAs__c;
                assData.EMS_TM_ProjectName_Asgn__c = this.recordId;
                assData.EMS_TM_EmployeeName__c = blankRow[i].EMS_TM_EmployeeName__c;
                assData.EMS_TM_StartDate_Asgn__c = blankRow[i].EMS_TM_StartDate_Asgn__c;
                assData.EMS_TM_EndDate_Asgn__c = blankRow[i].EMS_TM_EndDate_Asgn__c;
                assData.EMS_TM_Billable__c = blankRow[i].EMS_TM_Billable__c;
                assDataList.push(assData);
            }
        }
        if (assDataList.length > 0) {
            if (eventName === 'multipleRowRemoval') {
                for (let i = 0; i < blankRow.length; i++) {
                    if (blankRow[i].isChecked) {
                        blankRow.splice(i, 1);
                        i--;
                    }
                }
            } else {
                blankRow.splice(event.target.value, 1);
            }
            this.blankRow = blankRow;
        } else {
            const evt = new ShowToastEvent({
                message: 'Please select atleast one row',
                variant: 'error',
                mode: 'dismissable'
            });
            this.dispatchEvent(evt);
        }

    }

    setResourceName(event) {
        const eventName = event.target.name;
        //console.log('==eventName===='+eventName);
        // console.log('==event==='+JSON.stringify(event));
        let blankRow = this.blankRow;
        blankRow[eventName].EMS_TM_EmployeeName__c = event.target.value;
        this.blankRow = blankRow;
        //console.log('====this.blankRow===='+JSON.stringify(this.blankRow));
    }

    setRole(event) {
        const eventName = event.target.name;
        let blankRow = this.blankRow;
        blankRow[eventName].EMS_TM_AssignedAs__c = event.target.value;
        this.blankRow = blankRow;
    }
    setStatus(event) {
        const eventName = event.target.name;
        let blankRow = this.blankRow;
        blankRow[eventName].EMS_TM_Status_Asgn__c = event.target.value;
        this.blankRow = blankRow;
    }
    // ***** setProjectAllocation *****
    setProjectAllocation(event){
        const eventName = event.target.name;
        let blankRow = this.blankRow;
        blankRow[eventName].Project_Allocation__c = event.target.value;
        this.blankRow = blankRow;
    }
    setStartDate(event) {
        const eventName = event.target.name;
        let blankRow = this.blankRow;
        blankRow[eventName].EMS_TM_StartDate_Asgn__c = event.target.value;
        this.blankRow = blankRow;
    }
    setEndDate(event) {
        const eventName = event.target.name;
        let blankRow = this.blankRow;
        blankRow[eventName].EMS_TM_EndDate_Asgn__c = event.target.value;
        this.blankRow = blankRow;
    }
    setBillable(event) {
        const eventName = event.target.name;
        let blankRow = this.blankRow;
        blankRow[eventName].EMS_TM_Billable__c = event.target.value;
        this.blankRow = blankRow;
    }

    saveData(event) {
        let blankRow = this.blankRow;
        console.log('=====blankRow======'+JSON.stringify(this.blankRow));
        let assDataList = [];

        for (let i = 0; i < blankRow.length; i++) {
            if (blankRow[i] !== undefined && blankRow[i].isChecked) {
                let assData = new Object();
                assData.EMS_TM_Status_Asgn__c = blankRow[i].EMS_TM_Status_Asgn__c;
                assData.EMS_TM_AssignedAs__c = blankRow[i].EMS_TM_AssignedAs__c;
                assData.EMS_TM_ProjectName_Asgn__c = this.recordId;
                assData.EMS_TM_EmployeeName__c = blankRow[i].EMS_TM_EmployeeName__c;
                assData.EMS_TM_StartDate_Asgn__c = blankRow[i].EMS_TM_StartDate_Asgn__c;
                assData.EMS_TM_EndDate_Asgn__c = blankRow[i].EMS_TM_EndDate_Asgn__c;
                assData.EMS_TM_Billable__c = blankRow[i].EMS_TM_Billable__c;
                assData.Project_Allocation__c = blankRow[i].Project_Allocation__c;
                assDataList.push(assData);
            }
        }
        console.log('=====assDataList======'+JSON.stringify(assDataList));
        //smaske : new method 
        if (assDataList.length > 0) {
            console.log('=====INSIDE IF ======');
                getTotalProjectAllocationContactRecords({assignmentRecordString: JSON.stringify(assDataList)})
                .then(result => {
                    console.log('=======return response=='+JSON.stringify(result));
                    const event = new ShowToastEvent({
                        message: `You are allocating more than 100% for these Resources ${result}`,
                        variant: 'info',
                        mode: 'pester'
                    });
                    this.dispatchEvent(event);
                    
                }).catch(error => {
                    console.log('=======error response=='+JSON.stringify(error));
                    var substring = error.body.message;
                    const evt = new ShowToastEvent({
                        message: substring,
                        variant: 'error',
                        mode: 'dismissable'
                    });
                    this.dispatchEvent(evt);
                })
        }
        //

        if (assDataList.length > 0) {
            saveAssignmentData({ assignmentDataString: JSON.stringify(assDataList), projId: this.selectedProject }).then(result => {
                const evt = new ShowToastEvent({
                    message: 'Assignment created successfully.',
                    variant: 'success',
                    mode: 'dismissable'
                });
                this.dispatchEvent(evt);
                //console.log('=======return response=='+JSON.stringify(result));
                window.location.reload();
                /* let assDataList = this.assignDataWrp;  EMS_TM_EndDate_Asgn__c
                 for(let i = 0; i < result.length; i++){
                     if(result[i] !== undefined){
                         let assRecord = {'sobjectType' : 'EMS_TM_Assignment__c'};
                         assRecord.Id = result[i].Id;
                         assRecord.EMS_TM_Status_Asgn__c = result[i].EMS_TM_Status_Asgn__c;
                         assRecord.EMS_TM_AssignedAs__c = result[i].EMS_TM_AssignedAs__c;
                         assRecord.EMS_TM_ProjectName_Asgn__c = this.recordId;
                         assRecord.EMS_TM_EmployeeName__c = result[i].EMS_TM_EmployeeName__c;
                         assRecord.EMS_TM_StartDate_Asgn__c = result[i].EMS_TM_StartDate_Asgn__c;
                         assDataList.push(assRecord);
                     }
                 }*/
                this.assignDataWrp = result;
                this.blankRow = [];
                this.index = result.length;
            }).catch(error => {
                console.log('error', error);
                var substring = error.body.message.substring(78, 400);
                if (substring.includes('Value does not exist or does not match filter criteria.: [EMS_TM_ProjectName_Asgn__c]')) {
                    substring = 'You cannot assign resources to Global Projects';
                } else if (substring.includes('Only Admin or Project Manager are allowed to assign the resource to projec')) {
                    substring = 'Only Admin or Project Manager are allowed to assign the resource to project';
                } else if (substring.includes('Required fields are missing')) {
                    const startIndex = error.body.message.indexOf("Required fields are missing:");
                    const endIndex = error.body.message.lastIndexOf("]:");
                    substring = error.body.message.substring(startIndex, endIndex + 1);
                }
                //console.log(substring);
                const evt = new ShowToastEvent({
                    message: substring,
                    variant: 'error',
                    mode: 'dismissable'
                });
                this.dispatchEvent(evt);
            })
        } else {
            const evt = new ShowToastEvent({
                message: 'Please select atleast one row',
                variant: 'error',
                mode: 'dismissable'
            });
            this.dispatchEvent(evt);
        }
    }
    // handleCancel(){
    //     this[NavigationMixin.Navigate]({
    //         type: 'standard__objectPage',
    //         attributes: {
    //         objectApiName: 'EMS_TM_Project__c',
    //         actionName: 'home'
    //         },
    //     });
    // }

    setCheckBox(event) {
        let blankrow = this.blankRow;
        if (blankrow[event.target.name].isChecked) {
            blankrow[event.target.name].isChecked = false;
        } else {
            blankrow[event.target.name].isChecked = true;
        }
        this.blankRow = blankrow;
    }

    handleCancel() {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.recordId,
                objectApiName: 'EMS_TM_Project__c',
                actionName: 'view'
            },
        });

    }
}