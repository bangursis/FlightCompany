public class BookingController {
    public BookedFlight__c flight { get; set;}
    public List<Price__c> flights {get; set;}
    public  Decimal totalCost {get; set;}
    public String flightField {get; set;}
	public String addonField {get; set;}
	public String dateField {get; set;}
    private Date flightDate {get; set;}
    private Price__c tempPrice = new Price__c();
    public String result {get; set;}

    public BookingController(){
        this.flight = new BookedFlight__c();
    }

    public void getCost(){
        	if(String.isBlank(flightField) || String.isBlank(dateField)){
                ApexPages.addMessage(
                    new ApexPages.Message(
                        ApexPages.Severity.ERROR,
                        'Required parameters are missed'
                    )
                );
                return;
            }

            System.debug(flightField + ' ' + addonField + ' ' + dateField );

            flightDate = Date.valueOf(dateField);
            totalCost = 0;
            String subquery;
            String query;

            if(String.isBlank(addonField)){
                subquery = ' Flight__r.Name = :flightField';
            } else {
                subquery = ' ( Flight__r.Name = :flightField OR Addon__r.Name = :addonField )';
            }
            query = 'SELECT Value__c,Flight__c,Addon__c  FROM Price__c WHERE ' + subquery +
                ' AND DateFrom__c <= :flightDate ' +
                ' AND DateTo__c >= :flightDate ';

            List<Price__c> prices = (List<Price__c>)Database.query(query);


        if (prices.isEmpty()){
			ApexPages.addMessage(
                new ApexPages.Message(
                    ApexPages.Severity.ERROR,
                    'There is no any price by your search condition.'
                )
            );
            return;
        }

        //Price__c flightPrice = new Price__c();
        //Price__c addonPrice = new Price__c();
        Decimal flightPrice = 0;
        Decimal addonPrice = 0;

        for(Price__c price : prices){
			if (price.Flight__c != null) {
                flightPrice = price.Value__c;
            }
            if (price.Addon__c != null) {
                addonPrice = price.Value__c;
                tempPrice = price;
            }
		}

        totalCost = addonPrice + flightPrice;

        ApexPages.addMessage(
                new ApexPages.Message(
                    ApexPages.Severity.CONFIRM,
                    String.valueOf(totalCost)
                )
            );
        System.debug(String.valueOf(totalCost));
	}

    public void bookUp(){
        getCost();
        Flight__c flightCompany = [SELECT FlightCompany__c From Flight__c WHERE Name = :flightField];

        flightDate = Date.valueOf(dateField);

        Database.SaveResult result = Database.insert(
            new BookedFlight__c(
                Flight__c = flightCompany.Id,
                Addon__c = tempPrice.Addon__c,
                Date__c = flightDate,
                TotalCost__c = totalCost,
                FlightCompany__c = flightCompany.FlightCompany__c
        	), false);
		for(Database.Error err : result.getErrors()) {
			ApexPages.addMessage(
                new ApexPages.Message(
                    ApexPages.Severity.ERROR,
                    err.getStatusCode() + ': ' + err.getMessage()
                )
            );
	 	}


    }

    public void search(){

        flights =  new List<Price__c>();
		String subquery;
		String query;
        List<String> subqueries = new List<String>();
        /*if(!String.isBlank(flightField) && flightDate != null){

			subquery = ' Flight__r.Name = :flightField  ' + '  AND DateFrom__c <= :flightDate ' +
                ' AND DateTo__c >= :flightDate ';

        } else if (String.isBlank(flightField) && flightDate != null){

            subquery = ' DateFrom__c <= :flightDate ' +
                ' AND DateTo__c >= :flightDate ';

        } else if (!String.isBlank(flightField) && flightDate == null){

            subquery = ' Flight__r.Name = :flightField';
        } else {
			ApexPages.addMessage(
                new ApexPages.Message(
                    ApexPages.Severity.ERROR,
                    'Pls, enter required data'
                )
            );
            return;
        }*/
        if(!String.isBlank(flightField) && String.isBlank(addonField)){
            subqueries.Add(' Flight__r.Name = :flightField  ');
        }
        if(!String.isBlank(addonField) && String.isBlank(flightField)){
            subqueries.Add(' Addon__r.Name = :addonField  ');
        } else if(!String.isBlank(addonField) && !String.isBlank(flightField)){
            subqueries.Add(' (Addon__r.Name = :addonField  OR  Flight__r.Name  = :flightField) ');
        }
        if(!String.isBlank(dateField) ){
        	flightDate = Date.valueOf(dateField);
            System.debug('if: ' + String.valueOf(flightDate));
            subqueries.Add(' DateFrom__c <= :flightDate ' +
                ' AND DateTo__c >= :flightDate ');
        } else {
        	flightDate = Date.today();
            System.debug('else: ' + String.valueOf(flightDate));
            subqueries.Add(' DateFrom__c <= :flightDate ' +
            ' AND DateTo__c >= :flightDate ');
        }

        	System.debug(String.join(subqueries, ' AND '));
            query = 'SELECT Name, Value__c FROM Price__c WHERE ' + String.join(subqueries, ' AND ');
            flights = (List<Price__c>)Database.query(query);
        	result = JSON.serialize(flights);
        	System.debug(result);
    }

}