import { api, LightningElement,wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class UnitView extends NavigationMixin(LightningElement) {
    @api unit
    @api checkunit

    get Testunit() {
        return this.checkunit.includes(this.unit.Id);

    }

    viewUnit(event){
        
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                "recordId": event.target.dataset.prop,
                "objectApiName": "Unidad__c",
                "actionName": "view"
            },
        });


    }
}