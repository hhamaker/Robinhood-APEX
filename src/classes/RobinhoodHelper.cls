public with sharing class RobinhoodHelper {
    
    //generic callout class
    public static HttpRequest makeLoginRequest(String call, String endpoint, LoginRequest loginRequest){
        HttpRequest request = new HttpRequest();
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Accept', 'application/json');
        request.setBody(JSON.serialize(loginRequest));
        request.setEndpoint(endpoint);
        request.setMethod(call);
        System.debug(request);
        return request;
    }

    public static HttpRequest makeRequest(String call, String endpoint){
        HttpRequest request = new HttpRequest();
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Accept', 'application/json');
        //set the login to be your custom setting
        request.setHeader('Authorization', 'Token ' + login('hhamaker22@gmail.com'));
        request.setEndpoint(endpoint);
        request.setMethod(call);
        return request;
    }

    //provides the token needed for making requests
    public static String login(String username) {
        System.debug('we are in the login method');
        String endpoint = [SELECT Name, URL__c FROM Robinhood_Endpoints__c WHERE Name = 'Auth Token' LIMIT 1].URL__c;
        System.debug('we have the endpoint - ' + endpoint);
        Robinhood_Credentials__c creds = [SELECT Name, Password__c FROM Robinhood_Credentials__c WHERE Name = :username LIMIT 1];
        System.debug('we have the creds - ' + creds);
        LoginRequest loginRequest = new LoginRequest();
        loginRequest.username = creds.Name;
        loginRequest.password = creds.Password__c;
                
        HttpRequest request = makeLoginRequest('POST', endpoint, loginRequest);
        System.debug('login request = ' + request);
        HttpResponse httpResponse = makeCallout(request);
        System.debug('login response = ' + httpResponse.getBody());
        
        LoginResponse response = (LoginResponse) JSON.deserialize(httpResponse.getBody(), LoginResponse.class);
        System.debug(response.token);
        
        return response.token;
    }

    public static HttpResponse getQuote(String stockName){
        String endpoint = [SELECT Name, URL__c FROM Robinhood_Endpoints__c WHERE Name = 'Get Quote' LIMIT 1].URL__c + stockname + '/';
        HttpRequest request = makeRequest('GET', endpoint);
        HttpResponse httpResponse = makeCallout(request);
        makeQuoteResponse(httpResponse);
        return httpResponse;
    }

    public static HttpResponse makeCallout(HttpRequest request){
        Http http = new Http();
        HttpResponse httpResponse = http.send(request);
        System.debug(httpResponse);
        System.debug(httpResponse.getBody());
        
        return httpResponse;
    }

    public static Map<String, String> parseQuoteResponse(HttpResponse response){
        Map<String, String> tokenMap = new Map<String, String>();
        // Parse entire JSON response.
        JSONParser parser = JSON.createParser(response.getBody());
        while (parser.nextToken() != null) {
            System.debug('getText - ' + parser.getText());
            // Start at the array of invoices.
            if (parser.getCurrentToken() == JSONToken.START_ARRAY) {
                while (parser.nextToken() != null) {
                    // Advance to the start object marker to
                    if (parser.getCurrentToken() == JSONToken.START_OBJECT) {
                        
                    }
                }
            }
        }
        return tokenMap;
    }

    public static QuoteResponse makeQuoteResponse(HttpResponse response){
        QuoteResponse quote = (QuoteResponse) JSON.deserialize(response.getBody(), QuoteResponse.class);
        makeStockHistory(quote);
        return quote;
    }

    public static void makeStockHistory(QuoteResponse quote){
        Stock__c stock = [SELECT Id, Name FROM Stock__c WHERE Name = :quote.symbol LIMIT 1];

        Stock_History__c stockHistory = new Stock_History__c(Stock__c = stock.Id);            
        if (!String.isBlank(quote.ask_price)){
            stockHistory.AskPrice__c = Decimal.ValueOf(quote.ask_price);
        }
        if (!String.isBlank(quote.ask_size)){
            stockHistory.AskSize__c = Decimal.ValueOf(quote.ask_size);
        }
        if (!String.isBlank(quote.bid_price)){
            stockHistory.BidPrice__c = Decimal.ValueOf(quote.bid_price);
        }
        if (!String.isBlank(quote.bid_size)){
            stockHistory.BidSize__c = Decimal.ValueOf(quote.bid_size);
        }
        if (!String.isBlank(quote.last_trade_price)){
            stockHistory.LastTradePrice__c = Decimal.ValueOf(quote.last_trade_price);
        }
        if (!String.isBlank(quote.last_extended_hours_trade_price)){
            stockHistory.LastExtendedHoursTradePrice__c = Decimal.ValueOf(quote.last_extended_hours_trade_price);
        }
        if (!String.isBlank(quote.previous_close)){
            stockHistory.PreviousClose__c = Decimal.ValueOf(quote.previous_close);
        }
        if (!String.isBlank(quote.adjusted_previous_close)){
            stockHistory.AdjustedPreviousClose__c = Decimal.ValueOf(quote.adjusted_previous_close);
        }
        
        stockHistory.PreviousCloseDate__c = Date.ValueOf(quote.previous_close_date);
        
        INSERT(stockHistory);
    }

    //classes needed for storing details for login.
    private class LoginRequest {
        String username;
        String password;
    }
    
    private class LoginResponse {
        String token;
    }

    private class QuoteResponse {
        String ask_price;
        String ask_size;
        String bid_price;
        String bid_size;
        String last_trade_price;
        String last_extended_hours_trade_price;
        String previous_close;
        String adjusted_previous_close;
        String previous_close_date;
        String symbol;
        String trading_halted;
        String has_traded;
        String last_trade_price_source;
        String updated_at;
        String instrument;
    }

}