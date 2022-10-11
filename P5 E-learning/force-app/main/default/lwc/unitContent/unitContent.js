import { LightningElement, wire, api } from 'lwc';
//import { MessageContext, subscribe, publish } from 'lightning/messageService';
//import proyectoELearning from '@salesforce/messageChannel/proyectoELearning__c';
import getUnitWrapper from '@salesforce/apex/UnitService.getUnitWrapper';
//import { refreshApex } from '@salesforce/apex';


export default class Unitcontent extends LightningElement {
    @api recordId;

    unit;
    questionList;
    _wireResult;
    subscription = null;
    points;
    name;
    time;
    description;
    preguntas;


  //  @wire(MessageContext)
  //  messageContext;

    /* connectedCallback() {
        if (this.subscription != null) {
            return
        }
        this.subscription = subscribe()
        this.messageContext,
            proyectoELearning,
            (message) => {
                if (message.refresh) {
                    refreshApex(this._wireResult)
                }
            }
    } */

    @wire(getUnitWrapper, { unitId: '$recordId' })
    unitdata(result) {
        const { data, error } = result;
        this._wireResult = result;

        console.log(data);
        if (data) {
            this.unit = data.unit;
            this.questionList = data.isCompleted ? undefined : data.QuestionList;
            this.name = this.unit.name;
            this.points = this.unit.Puntos__c;
            this.time = this.unit.Tiempo__c;
            this.description = this.unit.Contenido__c;
            this.preguntas = data.questions;

        }

    }
}