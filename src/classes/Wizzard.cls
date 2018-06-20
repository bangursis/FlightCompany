public class Wizzard {
    public String fcNames{get; set;}
    public String fDeparture{get; set;}
    public String fArrival{get; set;}
    public String fType{get; set;}    
    public String company{get; set;}    
    public String aName{get; set;}
    
    public Wizzard(){
        fDeparture = '';
        fArrival = '';
        fType = '';
        company = '';
        aName = '';
    }
    
    public void createFlight(){
        List<FlightCompany__c> fcs = [SELECT Id FROM FlightCompany__c WHERE Name = :company];
        
        insert new Flight__c(
        	Name = fDeparture + '-' + fArrival,
            Type__c = fType,
            FlightCompany__c = fcs[0].Id
        );
    }
    
    public void createAddon(){
        List<FlightCompany__c> fcs = [SELECT Id FROM FlightCompany__c WHERE Name = :company];
        
        insert new Addon__c(
        	Name = aName,
            FlightCompany__c = fcs[0].Id
        );
    }
    
     
    
    public void getFC(){        
        Set<String> names = new Set<String>();
        names.clear();
        List<FlightCompany__c> fcs = [SELECT Name FROM FlightCompany__c];
        
        for(FlightCompany__c fc : fcs){
            names.add(fc.Name);
        }
		fcNames = JSON.serialize(names);        
        
    }
}