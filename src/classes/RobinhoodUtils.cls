public with sharing class RobinhoodUtils {

    public void StockHistoryBatchEveryMinute(){
        Integer openMinuteCounter = 0;
        while(openMinuteCounter < 60){
            String CRON_EXP = '0 ' + openMinuteCounter + ' * ? * MON-FRI';
            String jobId = System.schedule('StockHistoryBatch ' + (openMinuteCounter+1), CRON_EXP, new StockHistoryBatch());
            openMinuteCounter++;
        }
    }

    public void abortAllCronJobs(){
        List<CronTrigger> cronList = [select Id, CronExpression from CronTrigger];

        for(CronTrigger cron : cronList){
            System.abortJob(cron.Id);
        }
    }
}