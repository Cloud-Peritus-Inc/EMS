import { LightningElement, api, track, wire } from 'lwc';
import getRelatedFilesByRecordId from '@salesforce/apex/resourceTileController.getRelatedFilesByRecordId';
import getContentDistributionForFile from '@salesforce/apex/GetDataForLoginUser.getContentDistributionForFile';
import {NavigationMixin} from 'lightning/navigation'
export default class ShowOrgWideFiles extends NavigationMixin(LightningElement) {

  
    filesList =[]
    @wire(getRelatedFilesByRecordId)
    wiredResult({data, error}){ 
        if(data){ 
            console.log('======'+JSON.stringify(data));
            this.filesList = data;
        }
        if(error){ 
            console.log(error)
        }
    }
    previewHandler(event){
        console.log('========'+event.target.dataset.id);
         
    }
}