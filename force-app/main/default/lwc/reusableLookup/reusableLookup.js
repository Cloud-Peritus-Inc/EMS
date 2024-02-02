//Source : https://salesforcediaries.com/2022/12/30/reusable-lookup-field-in-lwc/

import { LightningElement, api,track } from 'lwc';
import fetchRecords from '@salesforce/apex/ReusableLookupController.fetchRecords';
import fetcgLoggedinContact from '@salesforce/apex/ReusableLookupController.fetcgLoggedinContact';


/** The delay used when debouncing event handlers before invoking Apex. */
const DELAY = 500;

export default class ReusableLookup extends LightningElement {
    @api helpText = " ";
    @api label = "Parent Account";
    @api required;
    @api selectedIconName = "standard:account";
    @api objectLabel = "Account";
    recordsList = [];
    //smaske make public
    @api selectedRecordName;

    @api objectApiName = "Account";
    @api fieldApiName = "Name";
    @api otherFieldApiName = "Industry";
    //smaske
    @api otherFieldApiName2 = "Industry";
    @api searchString = "";
    @api selectedRecordId = "";
    @api parentRecordId;
    @api parentFieldApiName;
    //smaske
    @api selectedFieldLabel = "";
    logUserContactId;
    
    

    preventClosingOfSerachPanel = false;

    get methodInput() {

        
        return {
            objectApiName: this.objectApiName,
            fieldApiName: this.fieldApiName,
            otherFieldApiName: this.otherFieldApiName,
            //smaske
            otherFieldApiName2: this.otherFieldApiName2,
            searchString: this.searchString,
            selectedRecordId: this.selectedRecordId,
            parentRecordId: this.parentRecordId,
            parentFieldApiName: this.parentFieldApiName
        };
    }

    get showRecentRecords() {
        if (!this.recordsList) {
            return false;
        }
        return this.recordsList.length > 0;
    }

    //getting the default selected record
    connectedCallback() {
        if (this.selectedRecordId) {
            this.fetchSobjectRecords(true);
        }
       
        fetcgLoggedinContact({   
        }).then(result => {
            this.logUserContactId=result.Id;
            console.log(result.Id);
        }).catch(error => {
            console.log(error);
        })
    }

    //call the apex method
    fetchSobjectRecords(loadEvent) {
        fetchRecords({
            inputWrapper: this.methodInput
        }).then(result => {
            if (loadEvent && result) { 
                console.log('83');             
                this.selectedRecordName = result[0].mainField;
            } else if (result) {
                this.recordsList = result.filter(item => item.id !== this.logUserContactId);//JSON.parse(JSON.stringify(result));
                console.log(JSON.stringify(result));//JSON.parse(JSON.stringify(result)));
           
            } else {
                this.recordsList = [];
            }
        }).catch(error => {
            console.log(error);
        })
    }

    get isValueSelected() {
        return this.selectedRecordId;
    }

    //handler for calling apex when user change the value in lookup
    handleChange(event) {
        this.searchString = event.target.value;
        this.fetchSobjectRecords(false) ;
    
    }

    //handler for clicking outside the selection panel
    handleBlur() {
        this.recordsList = [];
        this.preventClosingOfSerachPanel = false;
    }

    //handle the click inside the search panel to prevent it getting closed
    handleDivClick() {
        this.preventClosingOfSerachPanel = true;
    }

    //handler for deselection of the selected item
    handleCommit() {
        //smaske: passing event on unselecting selected CONTACT
        let selectedRecord = {
            id : this.selectedRecordId,
            label : this.selectedRecordName
        }
        const selectedEvent = new CustomEvent('valueremoved', {
            detail: selectedRecord
        });
        this.dispatchEvent(selectedEvent);
        //smaske :end
        this.selectedRecordId = "";
        this.selectedRecordName = "";
    }

    handleOkay(){
        this.showWarning=false;
    }
    popupopen(){
        this.showWarning = true;
    }
    //handler for selection of records from lookup result list
    handleSelect(event) {
      
        let selectedRecord = {
            mainField: event.currentTarget.dataset.mainfield,
            subField: event.currentTarget.dataset.subfield,
            id: event.currentTarget.dataset.id,
            //smaske
            label: event.currentTarget.dataset.label
        }; 
        this.selectedRecordId = selectedRecord.id;
        this.selectedRecordName = selectedRecord.mainField;
        
        //smaske
        this.selectedFieldLabel = selectedRecord.label;
        console.log('160');
        
        this.recordsList = [];
        // Creates the event
        const selectedEvent = new CustomEvent('valueselected', {
            detail: selectedRecord
        });
        //dispatching the custom event
        this.dispatchEvent(selectedEvent);
        }

    //to close the search panel when clicked outside of search input
    handleInputBlur(event) {
        // Debouncing this method: Do not actually invoke the Apex call as long as this function is
        // being called within a delay of DELAY. This is to avoid a very large number of Apex method calls.
        window.clearTimeout(this.delayTimeout);
        // eslint-disable-next-line @lwc/lwc/no-async-operation
        this.delayTimeout = setTimeout(() => {
            if (!this.preventClosingOfSerachPanel) {
                this.recordsList = [];
            }
            this.preventClosingOfSerachPanel = false;
        }, DELAY);
    }

}