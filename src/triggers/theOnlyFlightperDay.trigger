trigger theOnlyFlightperDay on BookedFlight__c (before insert) {
	List<BookedFlight__c> newBf = new List<BookedFlight__c>();
    
    for(BookedFlight__c Bf : Trigger.new){
        List<BookedFlight__c> oldBf = [SELECT Id FROM BookedFlight__c WHERE Flight__c = :Bf.Flight__c AND Date__c = :Bf.Date__c];
        
        System.debug(oldBf);
        if(!oldBf.isEmpty()) Bf.addError('The ticket is already booked');
    }
    
}