public class RobinhoodAccount {
    public AccountResponse getAccount() {
		RobinhoodHelper rh = new RobinhoodHelper();

        System.debug('we are in getAccount');
    	String endpoint = [SELECT Name, URL__c FROM Robinhood_Endpoints__c WHERE Name = 'Account' LIMIT 1].URL__c;
		System.debug('we got the endpoint = ' + endpoint);
        
		HttpRequest request = rh.makeRequest('GET', endpoint);
		System.debug('we made the request = ' + request);

        HttpResponse httpResponse = rh.makeCallout(request);
		System.debug('we made the response = ' + httpResponse);
        
        AccountResponse response = (AccountResponse) JSON.deserialize(httpResponse.getBody(), AccountResponse.class);
        
        return response;
    }
    
    public class AccountResponse {
        public List<AccountResults> results;
    }

    public class AccountResults {
        public String portfolio;
        public String buying_power;
        public String url;
        public String positions;
        public String cash;
    }
}