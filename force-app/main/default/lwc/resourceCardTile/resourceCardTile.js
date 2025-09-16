import { LightningElement,api,wire, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getUserInfo from '@salesforce/apex/resourceTileController.getUserInfo';
import paydateimage from '@salesforce/resourceUrl/NextPaydate';
import WFO from '@salesforce/resourceUrl/WFO';
import WorkInProgress from '@salesforce/resourceUrl/WorkInProgress';

import wfoDaysCount from '@salesforce/apex/countWfoDaysForResource.RunWfoCalculations';

export default class ResourceCardTile extends NavigationMixin(LightningElement)  {
paydateimage = paydateimage;
WFO = WFO;
imagelogo = '';
userdate;
userImageUrl;
resourceName = '';
resourceId = '';
resourcereportto = '';
nextpaydate;
resourcerole = '';
userid= '';
resourceinsurence = '';
rescodecurrency = '';
resourceContactId = '';
@track openModal = false;
@track imageUrl = WorkInProgress;
@track isMedical = false;

contextText = 'This shows your current month\'s Work From Office days.';
wfodaysNo;
wfoDaysData = 0;
showData =false;



    @wire(getUserInfo)
    userInfo({ error, data }) {
    if (data) {
      this.userdate = data;
      this.userImageUrl = data.resourcePhotoURL;
      this.resourceName = data.resourceName;
      this.resourceId = data.resourceCpId;
      this.resourcereportto = data.resourceReportTo;
      this.nextpaydate = data.nextpaydate;
      this.resourcerole = data.resourceRole;
      this.userid = data.resourceUserId;
      this.resourceinsurence = data.resourceInsurence;
      this.rescodecurrency = data.rescodecurrency;
      this.resourceContactId = data.resourceContactId;
      // for hiding the medical insurance to US Employee
      if(this.rescodecurrency == 'INR'){
        this.isMedical = true;
      }
    } else if (error) {
      console.error(error);
    }
  }

  @wire(wfoDaysCount)
    wiredWfoDaysCount({ error, data }) {  // Proper destructuring of the result
        if (data) {
            this.wfoDaysData = data;
            console.log('### this.wfoDaysData', this.wfoDaysData);
            this.showData = true;
        } else if (error) {
            console.error('Error:', error);
            this.wfoDaysData = undefined;
            this.showData = false;
        }
    }


   handleClick() {
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: '/detail/'+this.resourceContactId
            }
        });
}

showModal() {
        console.log('Model is open');
        this.openModal = true;
    }

    closeModal() {
        console.log('Model is Closed');
        this.openModal = false;
    }


}