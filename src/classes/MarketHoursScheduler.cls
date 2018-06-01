public class MarketHoursScheduler implements Schedulable {
    public void execute(SchedulableContext sc) {
        System.scheduleBatch(new StockHistoryBatch(), 'StockHistoryBatch', 1);   
    }
}