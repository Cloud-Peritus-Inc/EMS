import { LightningElement,wire,api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
export default class Pulsetable extends LightningElement {
@api tabledata = [];
@api resourceid;
@api fyid;
tbData;
connectedCallback() {
    console.log('====tabledata======'+JSON.stringify(this.tabledata));
    this.tbData= JSON.parse(JSON.stringify(this.tabledata))

    if(this.tbData!= null){
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