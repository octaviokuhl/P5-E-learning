import { api, track, LightningElement, wire } from 'lwc';
import getTrail from '@salesforce/apex/JSController.getTrail'; //uso un controlador como piden, en este caso es simple porque es un solo metodo el que uso, lo instancio en el controlador


export default class TrailView extends LightningElement {
    @api recordId;
    name;
    time;
    description;
    points;
    progress;
    error = undefined;
    modulos;
    checkmodule;
    checkunit;
   
    @wire(getTrail, { trailId: '$recordId' })
    trail(Result) {
        const { data, error } = Result;
        if (data) {
            
            console.log(data);

            this.name = data.trail.Name;
            this.time = data.trail.Total_Time__c;
            this.description = data.trail.Descripcion__c;
            this.points = data.trail.Total_Points__c;
            this.progress = Number.parseFloat((data.passedUnitIds.length /data.trail.UnidadesTotales__c)*100).toFixed(0); //sin decimales
            this.modulos = data.modules;
            this.checkmodule = data.passedModuleIds;
            this.checkunit = data.passedUnitIds;
            
           
        } else if (error) {
            this.error = error;
        }
    }

}
    


 

    /* este es wire imperativo que FUNCIONABA BIEN cuando no nos anduvo el tema del normal hasta que se puso el @track
    connectedCallback() {
        getTrail({
                trailId: this.recordId
            })
            .then((Rest) => {
                console.log(Rest)
                console.log(Rest.trail.Name)
                this.name = Rest.trail.Name;
                this.time = Rest.trail.Total_Time__c;
                this.description = Rest.trail.Descripcion__c;
                this.points = Rest.trail.Total_Points__c;
                this.progress= Rest.progressTrail;
            })
            .catch((error) => {
                console.log(error)
            })
    }*/