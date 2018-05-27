public class MarketHoursScheduler implements Schedulable {
	public void execute(SchedulableContext sc) {
		DateTime now = DateTime.now();
		HttpResponse response = RobinhoodHelper.getMarketTime();
		RobinhoodHelper.MarketTime mTime = RobinhoodHelper.makeMarketTime(response);

		//hard coding name because we are only interested in NYSE for now.
		OpenTradingHours__c tradingHours = [SELECT Id, Name, Hours__c, Minutes__c, EndHours__c, EndMinutes__c 
			FROM OpenTradingHours__c WHERE Name = 'NYSE'];

		//convert the open and close times into maps so we can update the custom settings
		String openTime = mTime.opens_at;
		Map<String, String> openMap = getTime(openTime);
		System.debug('openMap Hour - ' + openMap.get('Hour'));
		System.debug('openMap Minutes - ' + openMap.get('Minutes'));
		
		String closeTime = mTime.closes_at;
		Map<String, String> closeMap = getTime(closeTime);
		System.debug('closeMap Hour - ' + closeMap.get('Hour'));
		System.debug('closeMap Minutes - ' + closeMap.get('Minutes'));

		if (String.isBlank(openTime) || String.isBlank(closeTime)){
			return;
		}
		
		//Update the trading Hours custom setting
		tradingHours.Hours__c = Integer.ValueOf(openMap.get('Hour'));
		tradingHours.Minutes__c = Integer.ValueOf(openMap.get('Minutes'));
		tradingHours.EndHours__c = Integer.ValueOf(closeMap.get('Hour'));
		tradingHours.EndMinutes__c = Integer.ValueOf(closeMap.get('Minutes'));
		UPDATE(tradingHours);

		//set the schedules for the Stock History Batch class
		//check to see if the minutes is not = to 0
		if (Integer.ValueOf(openMap.get('Minutes')) != 0 || Integer.ValueOf(closeMap.get('Minutes')) != 0){
			//check to see which map is not equal to 0
			if (Integer.ValueOf(openMap.get('Minutes')) != 0){
				String CRON_EXP1 = '0 ' + openMap.get('Minutes') + '-59 ' + openMap.get('Hour') + ' ' + 
					now.day() + ' ' + now.month() +' ? ' + now.year();
				String jobId1 = System.schedule('StockHistoryBatch1', CRON_EXP1, new StockHistoryBatch());
			} else {
				String CRON_EXP1 = '0 ' + openMap.get('Minutes') + '-59 ' + openMap.get('Hour') + ' ' + 
					now.day() + ' ' + now.month() +' ? ' + now.year();
				String jobId1 = System.schedule('StockHistoryBatch1', CRON_EXP1, new StockHistoryBatch());
			}

			if (Integer.ValueOf(closeMap.get('Minutes')) != 0){
				String CRON_EXP2 = '0 ' + closeMap.get('Minutes') + '-59 ' + closeMap.get('Hour') + ' ' + 
					now.day() + ' ' + now.month() +' ? ' + now.year();
				String jobId2 = System.schedule('StockHistoryBatch2', CRON_EXP2, new StockHistoryBatch());
			} else {
				String CRON_EXP2 = '0 ' + closeMap.get('Minutes') + ' ' + closeMap.get('Hour') + ' ' + 
					now.day() + ' ' + now.month() +' ? ' + now.year();
				String jobId2 = System.schedule('StockHistoryBatch2', CRON_EXP2, new StockHistoryBatch());
			}
		} else{
			String CRON_EXP = '0 ' + closeMap.get('Minutes') + ' ' + closeMap.get('Hour') + ' ' + 
				now.day() + ' ' + now.month() +' ? ' + now.year();
			String jobId2 = System.schedule('StockHistoryBatch2', CRON_EXP, new StockHistoryBatch());
		}
	}

	//returns a map of the hours and minutes for the robinhood datetime
	private Map<String, String> getTime(String robinhoodTime){
		Map<String, String> returnMap = new Map<String, String>();
		List<String> tempList = new List<String>();
		String tempString = '';

		tempList = robinhoodTime.split('T');
		tempString = tempList[1];
		tempList = tempString.split(':');

		returnMap.put('Hour', tempList[0]);
		returnMap.put('Minutes', tempList[1]);

		return returnMap;
	}
}