public class RobinhoodAccount {
    public AccountResponse getAccount() {
		System.debug('we are in getAccount');
    	String endpoint = [SELECT Name, URL__c FROM Robinhood_Endpoints__c WHERE Name = 'Account' LIMIT 1].URL__c;
		System.debug('we got the endpoint = ' + endpoint);
        
		HttpRequest request = RobinhoodHelper.makeRequest('GET', endpoint);
		System.debug('we made the request = ' + request);

        HttpResponse httpResponse = RobinhoodHelper.makeCallout(request);
		System.debug('we made the response = ' + httpResponse);
        
    	//THIS DOES NOT WORK YET AND IS NOT STRUCTURED PROPERLY
        AccountResponse response = (AccountResponse) JSON.deserialize(httpResponse.getBody(), AccountResponse.class);
        
        return response;
    }
    
    public class AccountResponse {
        List<AccountResponse> results;
    }
}