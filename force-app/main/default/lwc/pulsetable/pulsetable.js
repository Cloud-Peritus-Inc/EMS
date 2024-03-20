import { LightningElement,track, wire,api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
export default class Pulsetable extends LightningElement {
@api tabledata = [];
@api resourceid;
@api fyid;
tbData;
@track pulseTableAvailble=false;
connectedCallback() {
    console.log('====tabledata======'+JSON.stringify(this.tabledata));
    this.tbData= JSON.parse(JSON.stringify(this.tabledata))

    if(this.tbData.length>0){
        this.pulseTableAvailble=true;
    }else{
        this.pulseTableAvailble=false;
    }
}

    handleNavClick(event){
       let node = event.currentTarget.dataset.id; 
       console.log('==node===='+node);
      
    }
}