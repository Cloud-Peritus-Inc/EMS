import { LightningElement,wire,api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
export default class Pulsetable extends LightningElement {
@api tabledata = [];
@api resourceid;
@api fyid;
connectedCallback() {
    console.log('====tabledata======'+JSON.stringify(this.tabledata));
}

    handleNavClick(event){
       let node = event.currentTarget.dataset.id; 
       console.log('==node===='+node);
      
    }
}