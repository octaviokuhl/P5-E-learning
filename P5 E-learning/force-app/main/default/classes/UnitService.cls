public with sharing class UnitService {

  @AuraEnabled (cacheable=false)
  public static Boolean registroRespuesta(Id unitId, String jsonAnswer) {
  //jsonAnswer va a venir como key:pair value y es tipo boolean el metodo porque debe devolver algo que sea correcto o falso
  
    Savepoint sp = Database.setSavepoint(); // es un punto de salvado de lo que tengo antes de iniciar todo
    Boolean verify = false; //respuesta que el metodo arrojara, seteo en false para que si todo sale bien, pase a true

      try{//Arranco por lo simple, crear una UnidadUser, al ir creciendo y ver que puedo tener errores se pone el try
        
          //Quiero validar las preguntas que entran al Json. Busco cuales preguntas hay en la unidad y lo hago en un subquery
          // "contenido__c" es realmente mi pregunta, recordar que Name es malisimo como esta usandose como un numero o similar.
          // para los intentos, subquery en UnidadUser, que me ordene por los intentos registrados de mayor a menor y el primero, de esta forma traigo el que mas numero de intentos tiene de ese registro... 0, 1 ,2, 3, 4 y puedo usarlo para los puntos

           Unidad__c unidad= [SELECT Modulo__c, (SELECT Id, Intento__c FROM UnidadesUsers__r WHERE ModuloUser__r.User__c =:UserInfo.getUserId() ORDER BY Intento__c DESC LIMIT 1), (SELECT Id,Contenido__c FROM Preguntas__r ) FROM Unidad__c WHERE ID =:unitId];
          // donde el ID sea el que entra por paramtero.
          
          //Query para saber si la UnidadUser ya existe o si debo crear una nueva
          
          ModuloUser__c  mu ;
          try{ //este try lo pusmos porque el If null que teniamos para verificar que si el mu esta vacio lo cree NO funcionaba y solucionamos con esto
           mu = [SELECT id FROM ModuloUser__c WHERE Modulo__c=:unidad.Modulo__c AND User__c =: UserInfo.getUserId() AND Status__c ='In Progress'];
          
          } catch (Exception e){

           //creacion de module response
           mu = new ModuloUser__c(User__c = UserInfo.getUserId(), Modulo__c = unidad.Modulo__c, Status__c = 'In Progress');
           system.debug('ENTRO AL module resp');
          insert mu;
          }

          // creo un resgitro unidadusuario UU= unidad usuario como el autonumber asi sigo la misma logica. Un registro UU tiene dos cosas requeridas son las lookups que tiene, Unidad y ModuloUser.
          UnidadUser__c  uu = new UnidadUser__c(Unidad__c = unitId, ModuloUser__c = mu.Id, EstadoUnidad__c = 'Draft', User__c=UserInfo.getUserId() );
          
          uu.Intento__c = !unidad.UnidadesUsers__r.isEmpty() ? unidad.UnidadesUsers__r[0].Intento__c + 1: 1;
         //UnidadesUsers__r usa la relacion hijo para hacer referencia a todo lo que me trae  esa lista (si le hago un query en consola me trae la lista, sin filtrar nada esa subquery
          
          insert uu;
         // con estos datos ya creo la UU sin problema y la inserto, tener en cuenta que mu.Id lo tuve cuando inserte mu no antes.
          system.debug('HOLA');
        //RespuestaResponse va a ser una lista de seleccion de respuestas, como un trail real... es decir selecciono respuesta A primer pregunta y B de la segunda, de ahi Submit entonces eso es una lista de RespuestaResponse. Pero yo recibo un Json que es un Mapa de IdQuestion: IdOpcion entonces tengo que primero pasarlo a un formato Mapa normal (castearlo) y de ahi recorrerlo, recordar que siempre que recorro un mapa lo hago buscando la key primero y lo uso para tener un value. ketset me devuelve un set de keys

         Map<Id,Id> maparespuestas = (Map<Id,Id>)JSON.deserializeStrict(jsonAnswer, Map<Id,Id>.class);
        List<RespuestaResponse__c> respuestaslist= new List<RespuestaResponse__c>(); //lista en donde voy a ir agregando mis resultados

         //Voy a ir a ver si lo que se respondio en el mapa (key) esta entre las preguntas de la unidad.Respuestas__r

        for(Pregunta__c dumyp : unidad.Preguntas__r){ //usa la relacion hijo para hacer referencia a toda lo que me trae sin filtrar nada esa subquery

          //verifico si la pregunta fue respondia en el mapa - rr = respuestaresponse record
           if(maparespuestas.containskey(dumyp.Id)){RespuestaResponse__c rr = new RespuestaResponse__c(Pregunta__c = dumyp.Id, UnidadUser__c = uu.Id, Respuesta__c = maparespuestas.get(dumyp.Id));
          respuestaslist.add(rr);
           } else{
              System.debug('La pregunta no fue respondida y es requerida');
           }
        }

       insert respuestaslist;

        //actualizo Unidadusuario a Answered, que va a funcionar como disparador para su evaluacion, recien lo paso cuando termine de crear todos los hijos, si lo seteo Answer directamente arriba, puede disparar y no va a encontrar nada puesto que no hay nada creado aun.  Seteo y actualizo el registro.
        uu.EstadoUnidad__c = 'Answered';
        update uu;

        verify = true; // una vez que se crea todo paso verify a true, ya que debo "devolver" true o false por el booleano.

      } catch (Exception e){ //si algo tira error, quiero volver al punto de guardado "sp"
        Database.rollback(sp);
        throw e; // la excepcion la arrojo de nuevo para que se maneje el error

      }
    return verify;
  }




    public  TrailWrapper getTrailWrapper(Id trailId){
    //Modulos que estan en el Trail
       /* List<Modulo__c> modules = (getModules(trailId));
        //Modulos completados del trail
        List<Id> completedModules = (getModuleIdsCompleted(trailId, modules));
        //Unidades completadas de los modulos
        List<Id> completedUnits = (getUnitIdsCompleted(trailId, completedModules));
        */
        //Instancio trail wrapper con trail y modulos
        TrailWrapper trailWrap = new TrailWrapper([SELECT Name, Descripcion__c, Total_Points__c, Total_Time__c,UnidadesTotales__c FROM Trail__c WHERE Id =: trailId], getModules(trailId), getModuleIdsCompleted(trailId), getUnitIdsCompleted(trailId));

        return trailWrap;
    }

    private static List<Modulo__c> getModules(Id trailId){

        //Busco modulos relacionados al trailId recibido como parametro
        List<TrailModulo__c> trailModules = [SELECT Modulo__c FROM TrailModulo__c WHERE Trail__c =: trailId];
        //Guardo y retorno los ids de los modulos relacionados al trailId
        Set<Id> moduleIds = new Set<Id>();
        for(TrailModulo__c trailModule : trailModules){
            moduleIds.add(trailModule.Modulo__c);
        }

        return [SELECT Name, Descripcion__c, Puntos__c, Tiempo__c, (SELECT Name, Contenido__c,Puntos__c,Tiempo__c FROM Unidades__r) FROM Modulo__c WHERE Id in : moduleIds];
    }

    private static List<Id> getModuleIdsCompleted(Id trailId){

        //Buscar los modulos completados relacionados al trailId
        List<ModuloUser__c> moduleResponses = [SELECT Modulo__c FROM ModuloUser__c WHERE Status__c = 'Completo' AND Modulo__c in : getModules(trailId) AND User__c =: Userinfo.getUserId()];

        //Guardo y retorno los ids de los modulos completados
        Set<Id> completedModuleIds = new Set<Id>();
        for(ModuloUser__c moduleResp : moduleResponses){
            completedModuleIds.add(moduleResp.Modulo__c);
        }

        return new List<Id>(completedModuleIds);  //a partir del set lo paso a Lista para que lo pueda trabajar en el constructor como lista ya que como set no funciona
    }
    private static list<Id> getUnitIdsCompleted(Id trailId){

        //Armo una lista de las unidades relacionadas a los modulos completados y al trailId pasado por parametro
        List<UnidadUser__c> unitResponses = [SELECT Unidad__c FROM UnidadUser__c WHERE EstadoUnidad__c = 'Success' AND User__c =: Userinfo.getUserId() AND Unidad__r.Modulo__c in : getModules(trailId)];

        System.debug(unitResponses);
        //Guardo el id de las unitsCompleted
        Set<Id> completedUnitIds = new Set<Id>();
        for(UnidadUser__c unitResp : unitResponses){
            completedUnitIds.add(unitResp.Unidad__c);
            
        }

        return new List<Id>(completedUnitIds);  //transformo el set de arriba que no quiero repetidos a una Lista porue sino en el constructor no anda con SET
    }

    public class TrailWrapper{
        //Configuracion
        
        @AuraEnabled // solo para metdoos y propiedades 
        public Trail__c trail; //Registro de Trail solicitado
        
        @AuraEnabled
        public List<Modulo__c> modules; //Módulos con Unidades relacionadas

        //Transaccional
        @AuraEnabled
        public List<Id> passedModuleIds; //Ids de módulos relacionados al Trail actual en los que el Alumno ya aprobó
        
        @AuraEnabled
        public List<Id> passedUnitIds; //Ids de Unidades relacionadas a módulos del Trail actual que el Alumno ya aprobó
        
        @AuraEnabled
        public Double progressTrail; //Porcentaje de progreso del Alumno en el Trail
       

        public TrailWrapper(Trail__c trail, List<Modulo__c> modules, List<Id> completedModuleIds, List<Id> completedUnitIds){
            this.trail = trail; //seteo cada propiedad publica con el valor que entra al constructor y al tenerlas aura enabled las expongo para el wire
            this.modules = modules;
            this.passedModuleIds = completedModuleIds;
            this.passedUnitIds = completedUnitIds;

            //this.progressTrail=  passedModuleIds.size()/modules.size(); No me sirve % de modulos quiero unidades.. asi no anduuvo hay que armar passedmodules como variable double y lo mismo con modulos y ahi la cuenta anda
            
            
        }
        
    }


    //tambien la manejo en el JScontroller
    @AuraEnabled(cacheable=true)
    public static UnitWrapper getUnitWrapper(Id unitId){

        Unidad__c unit = [SELECT Name,  Puntos__c,Tiempo__c,Contenido__c, (SELECT id, Contenido__c FROM Preguntas__r) FROM Unidad__c WHERE Id =: unitId];
        List<Pregunta__c> questions = [SELECT id,Name,Contenido__c,(SELECT id, Name, Contenido__c,Es_Correcta__c FROM Respuestas__r) FROM Pregunta__c WHERE Unidad__c =: unitId];
        UnitWrapper unitWrap = new UnitWrapper(unit, questions);
        return unitWrap;
    }

    public class UnitWrapper {

        @AuraEnabled
        public Unidad__c unit; //Unidad solicitada
        @AuraEnabled
        public List <Pregunta__c> questions; // Lista de preguntas de la unidad

        public UnitWrapper (Unidad__c unit, List<Pregunta__c> questions){
            this.unit = unit;
            this.questions = questions;
        }
    }
}