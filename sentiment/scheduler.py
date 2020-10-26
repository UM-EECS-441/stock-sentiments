import schedule
import time
from ensemble import ensemble_aggregate
def job():
    ensemble_aggregate(100, ['TESLA', 'AAPL', 'UBER', 'MSFT', 'AMZN'])


schedule.every().hour.do(job)

while 1:
    schedule.run_pending()
    time.sleep(1)