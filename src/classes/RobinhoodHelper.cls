public with sharing class RobinhoodHelper {
    
    /******************* Login Section ********************/
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

    /******************* Market Time Section ********************/
    public static HttpResponse getMarketTime(){
        DateTime now = DateTime.now();
        //hard coding the endpoint now because we are only using the NYSE
        String endpoint = 'https://api.robinhood.com/markets/XASE/hours/' + now.year() + '-' + now.Month() + '-' + '29' + '/';
        HttpRequest request = makeRequest('GET', endpoint);
        HttpResponse httpResponse = makeCallout(request);
        return httpResponse;
    }

    public static MarketTime makeMarketTime (HttpResponse response){
        MarketTime mTime = (MarketTime) JSON.deserialize(response.getBody(), MarketTime.class);
        return mTime;
    }

    /******************* Quote Section ********************/
    public static HttpResponse getQuote(String stockName){
        String endpoint = [SELECT Name, URL__c FROM Robinhood_Endpoints__c WHERE Name = 'Get Quote' LIMIT 1].URL__c + stockname + '/';
        HttpRequest request = makeRequest('GET', endpoint);
        HttpResponse httpResponse = makeCallout(request);
        return httpResponse;
    }

    public static HttpResponse getQuote(String stockName, String endpoint){
        String endpoint2 = endpoint + stockname + '/';
        HttpRequest request = makeRequest('GET', endpoint2);
        HttpResponse httpResponse = makeCallout(request);
        return httpResponse;
    }

    public static QuoteResponse makeQuoteResponse(HttpResponse response){
        QuoteResponse quote = (QuoteResponse) JSON.deserialize(response.getBody(), QuoteResponse.class);
        return quote;
    }

    public static Stock_History__c makeStockHistory(QuoteResponse quote){
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
        
        return stockHistory;
    }

    public static Stock_History__c makeStockHistory(QuoteResponse quote, Id stockId){
        
        Stock_History__c stockHistory = new Stock_History__c(Stock__c = stockId);            
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
        
        return stockHistory;
    }

    /******************* Generic Section ********************/
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

    public static HttpResponse makeCallout(HttpRequest request){
        Http http = new Http();
        HttpResponse httpResponse = http.send(request);
        System.debug(httpResponse);
        System.debug(httpResponse.getBody());
        
        return httpResponse;
    }

    /******************* JSON Classes Section ********************/
    private class LoginRequest {
        String username;
        String password;
    }
    
    private class LoginResponse {
        String token;
    }

    public class QuoteResponse {
        public String ask_price;
        public String ask_size;
        public String bid_price;
        public String bid_size;
        public String last_trade_price;
        public String last_extended_hours_trade_price;
        public String previous_close;
        public String adjusted_previous_close;
        public String previous_close_date;
        public String symbol;
        public String trading_halted;
        public String has_traded;
        public String last_trade_price_source;
        public String updated_at;
        public String instrument;
    }

    public class MarketTime {
        public String closes_at;
        public String opens_at;
    }
}