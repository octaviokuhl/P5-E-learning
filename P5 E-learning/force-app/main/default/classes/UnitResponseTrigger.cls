public with sharing  class UnitResponseTrigger { 

    public static void checkUpdate(List<UnidadUser__c> unidaduserlist,  Map<Id,UnidadUser__c> mapUnit){  //recibe una Lista tipo unidaduser  dentro de la variable unidaduserlist dontre entra el trigger.new
        List<UnidadUser__c> listavalidar = new List<UnidadUser__c>();
        for(UnidadUser__c dumyu: unidaduserlist ){
             If(dumyu.EstadoUnidad__c == 'Answered'  && mapUnit.get(dumyu.id).EstadoUnidad__c == 'draft'){
                listavalidar.add(dumyu);
            }
         }
        checkearRespuestas(listavalidar); //antes de irme del metodo que hace el check previo update,ejecuto el validador de respuestas... notar que nunca paso realmente a Answered
    }
    
    public static void checkearRespuestas(List<UnidadUser__c> unidaduserlist){ //creo un metodo para validar las respuestas
        Map <id, UnidadUser__c> mapfilter = new map <id, UnidadUser__c> ([SELECT id, unidad__r.Puntos__c, (SELECT Respuesta__r.Es_Correcta__c from RespuestaResponses__r) FROM UnidadUser__c WHERE ID =: unidaduserlist]);
        
        	for (UnidadUser__c dumy : unidaduserlist){
                integer contador =0;
           		 for (RespuestaResponse__c respuestas : mapfilter.get(dumy.id).RespuestaResponses__r){                        
                    if (respuestas.Respuesta__r.Es_Correcta__c == true){
                        contador ++;
                    }    
            	}
            
            	if(contador == Mapfilter.get(dumy.id).RespuestaResponses__r.size()){
                    dumy.EstadoUnidad__c = 'Success';    
                            if(dumy.Intento__c == 1){
                                   dumy.puntos__c = Mapfilter.get(dumy.id).unidad__r.puntos__c;
                            }else if(dumy.Intento__c == 2){
                                  dumy.puntos__c = Mapfilter.get(dumy.id).unidad__r.puntos__c/2;
                            }else
                            { dumy.puntos__c = Mapfilter.get(dumy.id).unidad__r.puntos__c/4;
                                        }
           		 }else{
		              dumy.EstadoUnidad__c= 'Fail';
             	  }	
        
   	 	}
	}
    
}

