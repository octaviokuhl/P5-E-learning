public with sharing class JSController {
    
    @AuraEnabled(cacheable=true)
    public static UnitService.TrailWrapper getTrail(Id trailId) {
        UnitService service = new UnitService();
        return service.getTrailWrapper(trailId);
    }

    //el getunitewarpper lo invocamos directo, solo para hacerlo diferente.

}
