import { api, LightningElement } from 'lwc';

export default class ModuleView extends LightningElement {
    @api name;
    @api time;
    @api description;
    @api points;
    @api modulo;
    @api checkmodule;
    @api checkunit;


   // con get lo que hago es disparar una funcion en el cambio de una variable, es como hacer una funcion "automatica" sin botones y lo que busco es que ejecute algo mas, en este caso como checkmodule viene con un valor, dispara el get y verifica si el id esta en modulo.id con el includes. Si esta devuelve true, sino false... ese return lo uso en el HTML Moduleview para renderizar el boton check
   
    get Testmodule() {

        console.log('esto es check unit' + this.checkunit);
        return this.checkmodule.includes(this.modulo.Id);

    }
}
