import { LightningElement, wire, api, track } from 'lwc';
import { MessageContext, subscribe, publish } from 'lightning/messageService';
//import proyectoELearning from '@salesforce/messageChannel/proyectoELearning__c';
import getunitwrapper from '@salesforce/apex/UnitService.getUnitWrapper';
//import { refreshApex } from '@salesforce/apex';
import registroRespuesta from '@salesforce/apex/UnitService.registroRespuesta';



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


    @wire(MessageContext)
    messageContext;


    @wire(getunitwrapper, { unitId: '$recordId' })
    unitdata(result) {
        const { data, error } = result;
        this._wireResult = result;

        console.log();
        if (data) {
            this.unit = data.unit;
            this.questionList = data.isCompleted ? undefined : data.QuestionList;
            this.name = this.unit.Name;
            this.points = this.unit.Puntos__c;
            this.time = this.unit.Tiempo__c;
            this.description = this.unit.Contenido__c;
            this.preguntas = data.questions;
            console.log('this.preguntas' +
                JSON.stringify(this.preguntas));

        }

    }
    @track
    optionSelected = [];
    optionSelectedjson = {};
    answerSelected(event) {

        console.log(JSON.stringify(event.detail) + 'detail event');
        this.optionSelectedjson[event.detail.questionId] = event.detail.optionId;
        console.log('objeto' + JSON.stringify(this.optionSelectedjson));
        this.optionSelected = Object.values(this.optionSelectedjson);
        console.log('arraypadre' + this.optionSelected);
    }


    handleSubmit(event) {
        registroRespuesta({
                unitId: this.recordId,
                jsonAnswer: JSON.stringify(this.optionSelectedjson)
            })
            .catch((error) => {
                console.log(error)
            })

    }

}