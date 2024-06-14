import { LightningElement, api, wire, track } from 'lwc';
import getActiveAssignments from '@salesforce/apex/ProjectAllocationTabController.getActiveAssignments';
import getAssignmentWrapperWithProjectOptions from '@salesforce/apex/ProjectAllocationTabController.getAssignmentWrapperWithProjectOptions';
import fetchAssignmentRecordsData from '@salesforce/apex/ChangeProjectActionButtonController.fetchAssignmentRecordsData';
import fetchActiveProjectsList from '@salesforce/apex/ChangeProjectActionButtonController.fetchActiveProjectsList';
import getPicklistValues from '@salesforce/apex/GetDataForLoginUser.getPicklistValues';
import { NavigationMixin } from "lightning/navigation";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import getTotalProjectAllocationOfSingleContact from '@salesforce/apex/ChangeProjectActionButtonController.getTotalProjectAllocationOfSingleContact';
import updateOldProjectAllocationOfSingleContact from '@salesforce/apex/ChangeProjectActionButtonController.updateOldProjectAllocationOfSingleContact';


export default class ProjectAllocationDuplicate extends NavigationMixin(LightningElement) {
    @track assignments;
    searchTerm = '';
    searchProject = '';
    projectOptions = [];
    selectedContactIdList = [];
    @track changeprojectpopup = false;
    @track changeAllproject = false;
    assignmentId;
    resultRecords;
    error;
    @track projectsList;
    @track activeProjectsList;
    @track picklistValues = [];
    @track blankRow = [];


    @wire(getActiveAssignments, { searchTerm: '$searchTerm', searchProject: '$searchProject' })
    wiredAssignments({ data, error }) {
        if (data) {
            this.assignments = data.map((assignment, index) => ({
                ...assignment,
                serialNumber: index + 1
            }));

            if (data.length > 0 && data[data.length - 1].projectOptions) {
                this.projectOptions = data[data.length - 1].projectOptions.map(option => ({
                    label: option,
                    value: option
                }));
            }
            console.log('Final data == > ' + JSON.stringify(this.assignments));
        } else if (error) {
            console.log('Error retrieving assignments:', error);
        }
    }

    @wire(getAssignmentWrapperWithProjectOptions)
    wiredProjectOptions({ data, error }) {
        if (data) {
            this.projectOptions = data.projectOptions.map(option => ({
                label: option,
                value: option
            }));
        } else if (error) {
            console.log('Error retrieving project options:', error);
        }
    }


    handleSearchTermChange(event) {
        this.searchTerm = event.target.value;
    }

    handleProjectSearchTermChange(event) {
        this.searchProject = event.target.value;
    }

    clearProjectSelection() {
        this.searchProject = '';
    }

    employeeName; //stores contactId
    totalProjectAllocationForSingleContact;
    selectedAssignmentProjectAllocation;
    selectOldProjectName;
    oldProjectStatusValue;
    oldProjectAllocationValue;

    handleClickChangeproject(event) {
        this.assignmentId = event.target.dataset.id;
        this.employeeName = event.target.dataset.employeename;
        this.selectedAssignmentProjectAllocation = event.target.dataset.projectallocation;
        this.oldProjectAllocationValue = event.target.dataset.projectallocation;
        this.selectOldProjectName = event.target.dataset.oldprojectname;

        console.log('Single Record Contact Id --->', this.employeeName);
        console.log('Single Record Assignment Id --->', this.assignmentId);
        console.log('Select Assignment Project Allocation Value --->', this.selectedAssignmentProjectAllocation);
        this.changeprojectpopup = true;

        //------
        
        getTotalProjectAllocationOfSingleContact({contactId : this.employeeName})
            .then(result => {
                this.totalProjectAllocationForSingleContact = result;
                console.log('totalProjectAllocationForSingleContact in result => '+this.totalProjectAllocationForSingleContact);
            })
            .catch(error => {
                console.log('error ERROR ==> ',error);
                this.error = error;
                console.log('totalProjectAllocationForSingleContact ERROR ==> '+this.error);
            });

        //------
    }

    hideModalBox() {
        this.changeprojectpopup = false;
    }

    hideModal() {
        this.changeAllproject = false;
    }

    //--------------CheckBox---------

    handleAllSelected(event) {
        this.checkBox = event.target.checked;
        if (this.checkBox) {
            const checkboxElements = this.template.querySelectorAll('lightning-input[data-key="firstColumnCheckbox"]');
            const selectedRecordIds = [];
            checkboxElements.forEach(element => {
                if (!element.disabled) {
                    element.checked = true;
                    const dataId = element.dataset.id;
                    selectedRecordIds.push(dataId);
                }
            });
            console.log('Selected Record Ids:', selectedRecordIds);
            this.selectedContactIdList = selectedRecordIds;
            console.log('### selectedContactIdList', this.selectedContactIdList);
        } else if (!this.checkBox) {
            const checkboxElements = this.template.querySelectorAll('lightning-input[data-key="firstColumnCheckbox"]');
            checkboxElements.forEach(element => {
                element.checked = false;
            });
            this.selectedContactIdList = [];
        }
    }


    handleCheckboxSelect(event) {
        console.log('assgnmentIds ==>  ' + event.target.dataset.id);
        const assignmentId = event.target.dataset.id;
        const index = this.selectedContactIdList.indexOf(assignmentId);

        if (event.target.checked) {
            if (index === -1) {
                this.selectedContactIdList.push(assignmentId);
            }
        } else {
            if (index !== -1) {
                this.selectedContactIdList.splice(index, 1);
            }
        }

        console.log('assignmentIds list -> ' + this.selectedContactIdList);

        const selectedRows = this.template.querySelectorAll('lightning-input[data-key="firstColumnCheckbox"]');
        let allSelected = true;

        selectedRows.forEach((currentItem) => {
            if (!currentItem.checked) {
                allSelected = false;
            }
        });

        const selectedRow = this.template.querySelector('lightning-input[data-key="allCheckbox"]');
        selectedRow.checked = allSelected;
    }

    handleCheckboxInnerCmp(event) {
        console.log('assgnmentIds inner cmp ==>  ' + event.target.dataset.id);
    }

    handleChangeprojectForAll() {
        if (this.selectedContactIdList.length > 0) {
            console.log('selectedContactIdList', this.selectedContactIdList);
            this.changeAllproject = true;
            fetchAssignmentRecordsData({ assignmenyIdList: this.selectedContactIdList })
                .then(result => {
                    this.resultRecords = result;
                    console.log('Project details => ' + JSON.stringify(this.resultRecords));
                }).catch(error => {
                    console.log('error==>', error);
                })
        } else {
            this.dispatchEvent(
                new ShowToastEvent({
                    message: 'Please select atleast one row',
                    variant: 'error',
                }),
            );
        }
    }


    @wire(fetchActiveProjectsList)
    activeProjectsList({ data, error }) {
        if (data) {
            try {
                this.activeProjectsList = data;
                let options = [];
                for (var key in data) {
                    options.push({ label: data[key].Name, value: data[key].Id });
                }
                this.projectsList = options;
            } catch (error) {
                console.error('check error here', error);
            }
        } else {
            this.error = error;
            console.log('Error2 ==> ' + JSON.stringify(this.error));
        }
    }

    @wire(getPicklistValues, { objectName: 'EMS_TM_Assignment__c', fieldName: 'EMS_TM_Status_Asgn__c' })
    retrievePicklistValues({ error, data }) {
        if (data) {
            this.picklistValues = data.map((value) => ({
                label: value,
                value: value
            }));
        } else if (error) {
            console.error('Error retrieving picklist values:', error);
        }
    }

    //To get the new project allocation value
    @track newProjectAllocation;
    newProjectAllocationFuncion(event){
        this.newProjectAllocation = event.target.value;
        console.log('newProjectAllocation ==> '+this.newProjectAllocation);

        let x = this.template.querySelector('lightning-input[data-id="oldProjectAllocation"]');
        console.log('value 292 => '+x.value);
        if(this.newProjectAllocation == this.selectedAssignmentProjectAllocation || this.newProjectAllocation >= this.oldProjectAllocationValue){
            x.value = 0;
            this.selectedAssignmentProjectAllocation = x.value;
            this.oldProjectStatusValue = 'Closed';
        }else{
            this.selectedAssignmentProjectAllocation = (this.oldProjectAllocationValue - this.newProjectAllocation); //(this.newProjectAllocation - this.oldProjectAllocationValue);
            this.oldProjectStatusValue = 'Active';
        }
        
        
        console.log('value 294 => '+x.value);
        
    }

    existingProjectAllocation;
    ableToAllocate;


    handleSubmit(event) {
        console.log('Enter submit');
        event.preventDefault();
        console.log('Fields 239 => '+event.detail.fields);
        //const currentForm = this.template.querySelector('lightning-record-edit-form[data-id="currentForm"]');
        const newForm = this.template.querySelector('lightning-record-edit-form[data-id="newForm"]');

        console.log('Select Assignment Project Allocation Value 2 --->', this.selectedAssignmentProjectAllocation);
        console.log('totalProjectAllocationForSingleContact in result 2 => '+this.totalProjectAllocationForSingleContact);
        console.log('newProjectAllocation 2 ==> '+this.newProjectAllocation);

        //currentForm.addEventListener('submit', this.handleFormSubmit.bind(this, currentForm));
        newForm.addEventListener('submit', this.handleFormSubmit.bind(this, newForm));

        //currentForm.submit();
        console.log('save button ==> ');
        
        if(this.totalProjectAllocationForSingleContact <= 100){
            this.existingProjectAllocation = this.totalProjectAllocationForSingleContact - this.oldProjectAllocationValue;
            this.ableToAllocate = 100 - (this.totalProjectAllocationForSingleContact - this.oldProjectAllocationValue);
            
            //if(this.newProjectAllocation != '' || this.newProjectAllocation != undefined || this.newProjectAllocation != null){
            /*if (this.totalProjectAllocationForSingleContact == 100 && (this.selectedAssignmentProjectAllocation >= this.newProjectAllocation)) {
                console.log('inside if condition');
                newForm.submit();
            }*/
            //}
            if(this.newProjectAllocation <= 100 && (this.newProjectAllocation <= (100 - (this.totalProjectAllocationForSingleContact - this.oldProjectAllocationValue)))){
                console.log('inside else condition');
                newForm.submit();
            }
            else{
            this.dispatchEvent(
                new ShowToastEvent({
                    message: 'Already assigned with '+this.existingProjectAllocation+'%, so you can allocate upto '+this.ableToAllocate+'%',
                    variant: 'error',
                })
            );
            }
        }
        else{
            this.dispatchEvent(
                new ShowToastEvent({
                    message: 'Project Allocation Should be Less Than 100% and Current Total Allocation is '+ this.totalProjectAllocationForSingleContact+'%',
                    variant: 'error',
                })
            );
        }

        //update the old project details
        console.log('assignmentId 295 => '+ this.assignmentId);
        console.log('selectedAssignmentProjectAllocation 296 => '+ this.selectedAssignmentProjectAllocation);
        console.log('oldProjectStatusValue 297 => '+ this.oldProjectStatusValue);

        
            updateOldProjectAllocationOfSingleContact({assignmentId : this.assignmentId, oldProjectAllocationUpdatedValue : this.selectedAssignmentProjectAllocation, oldProjectStatus : this.oldProjectStatusValue})
            .then(result => {                
            })
            .catch(error => {
                this.error = error;
                console.log('ERROR in updating old project data ==> '+ JSON.stringify(this.error));
            });
        
        //----------------

        // window.location.reload();
    }
    
    handleFormSubmit(form, event) {
        event.preventDefault();
        if (form.checkValidity()) {
            form.submit();
        } else {
            console.error('Form validation failed');
        }
    }

    handleAssignmentSuccess(event) {
        this.dispatchEvent(
            new ShowToastEvent({
                message: 'Assignments added successfully.',
                variant: 'success',
            })
        ); this.hideModalBox();
        //window.location.reload();
        setTimeout(function () {
            window.location.reload();
        }, 2000);
    }

    handleAssignmenterror(event) {
        this.dispatchEvent(
            new ShowToastEvent({
                message: event.detail.detail,
                variant: 'error',
            }),
        );
    }


    // --------------------------------------------------------------------------------------------------

    


}