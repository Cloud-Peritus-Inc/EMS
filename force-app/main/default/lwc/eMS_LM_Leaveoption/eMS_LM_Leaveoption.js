import { LightningElement } from 'lwc';
export default class EMS_LM_Leaveoption extends LightningElement {
selectedOption;
openleave;
openWfh;

get options() {
        return [
            { label: 'Leave', value: 'Leave' },
            { label: 'Work From Home', value: 'Work from Home' },
        ];
    }

handleRadioChange(event){
this.selectedOption = event.target.value;
  console.log('this.selectedOption-->',this.selectedOption);
  if (this.selectedOption == 'Leave') {
      this.openleave = true;
      this.check = true;
     
     const searchEvent =new CustomEvent("getsearchvalue",{
         detail: this.check
     });
     this.dispatchEvent(searchEvent);

     const myEvent = new CustomEvent('getclosevalue',{
        detail:"Model close Successfully!!"
    });
    this.dispatchEvent(myEvent);
    }
  if (this.selectedOption == 'Work from Home') {
      this.openWfh = true;
      this.check1 = true;

      const searchEvent =new CustomEvent("getsearchwfh",{
         detail: this.check1
     });
     this.dispatchEvent(searchEvent);

     const myEvent = new CustomEvent('getclosevalue',{
        detail:"Model close Successfully!!"
    });
    this.dispatchEvent(myEvent);
    }
}
check;
check1;

submitDetails(){
 if (this.selectedOption == 'Leave') {
      this.check = true;
     
     const searchEvent =new CustomEvent("getsearchvalue",{
         detail: this.check
     });
     this.dispatchEvent(searchEvent);

     const myEvent = new CustomEvent('getclosevalue',{
        detail:"Model close Successfully!!"
    });
    this.dispatchEvent(myEvent);
    }
    else if (this.selectedOption == 'Work from Home') {
      this.check1 = true;

      const searchEvent =new CustomEvent("getsearchwfh",{
         detail: this.check1
     });
     this.dispatchEvent(searchEvent);

     const myEvent = new CustomEvent('getclosevalue',{
        detail:"Model close Successfully!!"
    });
    this.dispatchEvent(myEvent);
      
      console.log('this.check1__',this.check1)
    }
}

closemefirst(){

    const myEvent = new CustomEvent('getclosevalue',{
        detail:"Model close Successfully!!"
    });
    this.dispatchEvent(myEvent);

}

}