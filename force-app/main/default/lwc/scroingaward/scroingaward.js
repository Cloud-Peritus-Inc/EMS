import { LightningElement,api,track } from 'lwc';
import getTheScoringbyAward from '@salesforce/apex/RRController.getTheScoringbyAward';
import getTheScoringbyAllAward from '@salesforce/apex/RRController.getTheScoringbyAllAward';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
export default class Scroingaward extends LightningElement {
@api selectedfy;
@api awarddatalist = [];
selectedAward = 'All';
@track scoringTable = [];
showthecampare = false;
showcomparepop = false;
announcebutton = true;

connectedCallback() {
     this.getTheAllAward();    
}

handleChange(event) {
        this.selectedAward = event.detail.value;
        if(event.detail.value != 'All'){
            this.showthecampare = true; 
            this.announcebutton = false;
            this.getThelInfoByAward();
        }else{
            this.getTheAllAward();
            this.showthecampare = false;
            this.announcebutton = true; 
        }
       
}

 getThelInfoByAward(){
     this.scoringTable = [];
          console.log('======selectedfy===='+JSON.stringify(this.selectedfy));
        getTheScoringbyAward({ 
        fyId : this.selectedfy,
         awardType : this.selectedAward  
        }).then(result => {
        console.log('======scoringTable===='+JSON.stringify(result));
        this.scoringTable = result;
        }).catch(error => {
        }); 
    }

    getTheAllAward(){
        console.log('======selectedfy===='+JSON.stringify(this.selectedfy));
        getTheScoringbyAllAward({ 
        fyId : this.selectedfy
        }).then(result => {
        //console.log('======result=All==='+JSON.stringify(result));
        console.log('======result=All===');
        this.scoringTable = result;
        let modifiedArr = JSON.parse(JSON.stringify(this.scoringTable));

        modifiedArr.forEach(ele =>{      
            for(var i=0;i<ele.currentList.length;i++){   
                if(ele.currentList.length>1){ 
                    ele.currentList[i].borderCls = (i == ele.currentList.length-1) ? "slds-wrap slds-p-around_small" : "slds-wrap borderClr slds-p-around_small";
                 }
            }                  
        })
        this.scoringTable = JSON.parse(JSON.stringify(modifiedArr));

        //console.log('======Modified result=All==='+JSON.stringify(this.scoringTable));
        
        }).catch(error => {
          console.log('======error=errorAll==='+JSON.stringify(error));
        }); 
    }

    handleAnnounceClick(){

    }

    handleRefresh(){
        this.scoringTable = [];
        this.getThelInfoByAward();
    }

    handleCompareClick(){
        this.showCompareModalBox();
    }

    showCompareModalBox() { 
         this.showcomparepop = true; 
    }

    hideKCompareModalBox() {  
        this.showcomparepop = false; 
        
    }

    handleSubmit(event) {
        console.log('onsubmit event recordEditForm'+ event.detail.fields);
    }
    handleSuccess(event) {
        console.log('onsuccess event recordEditForm', event.detail.id);
       
        this.getThelInfoByAward();
         const evt = new ShowToastEvent({
            title: 'SUCCESS',
            message: 'Succesfully updated the scoring.',
            variant: 'success',
            });
            this.dispatchEvent(evt);
             this.showcomparepop = false;
        }
    }