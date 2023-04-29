import { LightningElement,api,wire, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getUserInfo from '@salesforce/apex/resourceTileController.getUserInfo';
import paydateimage from '@salesforce/resourceUrl/NextPaydate';
import WorkInProgress from '@salesforce/resourceUrl/WorkInProgress';

export default class ResourceCardTile extends NavigationMixin(LightningElement)  {
paydateimage = paydateimage;
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
    } else if (error) {
      console.error(error);
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