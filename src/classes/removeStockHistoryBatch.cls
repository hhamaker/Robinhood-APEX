public class removeStockHistoryBatch implements Database.Batchable<sObject>, Schedulable {
	String query;

	public Database.QueryLocator start(Database.BatchableContext BC) {
		Datetime oldTime = System.Datetime.now().addDays(-7);
		query = 'SELECT Id, CreatedDate FROM Stock_History__c WHERE CreatedDate < :oldTime';
	
		return Database.getQueryLocator(query);
	}

   	public void execute(Database.BatchableContext BC, List<sObject> scope) {
		   DELETE(scope);
	}
	
	public void finish(Database.BatchableContext BC) {}

	//scheduler for the batch class
    public void execute(SchedulableContext sc) {
        Id batchJobId = Database.executeBatch(new removeStockHistoryBatch(), 50);
    }
}