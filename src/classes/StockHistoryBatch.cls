public class StockHistoryBatch implements Database.Batchable<sObject>, Database.Stateful, Schedulable, Database.AllowsCallouts {
    private String query;
    private String endpoint;
    private List<Stock_History__c> stockHistoryList = new List<Stock_History__c>();

    public Database.QueryLocator start(Database.BatchableContext BC) {
        query = 'SELECT Id, Name FROM Stock__c';
        endpoint = [SELECT Name, URL__c FROM Robinhood_Endpoints__c WHERE Name = 'Get Quote' LIMIT 1].URL__c;
		return Database.getQueryLocator(query);
	}

   	public void execute(Database.BatchableContext BC, List<Stock__c> scope) {
        Boolean isOpen = RobinhoodHelper.isMarketOpen();
        //iterates through the stocks and creates the stock histories
        for(Stock__c stock : scope){
            if (isOpen){
                HttpResponse response = RobinhoodHelper.getQuote(stock.Name, endpoint);
                RobinhoodHelper.QuoteResponse quote = RobinhoodHelper.makeQuoteResponse(response);
                Stock_History__c stockHistory = RobinhoodHelper.makeStockHistory(quote, stock.Id);
                stockHistoryList.add(stockHistory);
            }
        }
        
        //inserts stock histories
        if (!stockHistoryList.isEmpty()){
            Insert(stockHistoryList);
        }
	}
	
	public void finish(Database.BatchableContext BC) {
        //this is where we will trigger the algorythms
    }

    //scheduler for the batch class
    public void execute(SchedulableContext sc) {
        Id batchJobId = Database.executeBatch(new StockHistoryBatch(), 50);
    }

}