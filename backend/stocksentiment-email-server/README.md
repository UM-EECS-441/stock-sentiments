# stocksentiment-email-server
Email notification server for the StockSentiments iOS app

This runs on an EC2 instance and makes requests to Amazon SES (Simple Email Service). The main back end server running on a digital ocean droplet will make requests to this server using the below API when it needs to notify a specific user that the public sentiment of a stock they follow has changed significantly. 

EC2: http://ec2-174-129-79-166.compute-1.amazonaws.com/<br />
 [POST] /send_email/<br />
Sends an email to the specified user detailing the stock, sentiment, and change in sentiment<br />
Returns: Status 200 or 500 (email isn't sent)<br />
Template JSON request:<br />
{<br />
	"email": "example@gmail.com",<br />
	"stock": "AMZN",<br />
	"score": "1"<br />
}<br />

Further explanation for this server can be found in the project documentation for the StockSentiments app at this link: https://github.com/UM-EECS-441/iosdevs/wiki/Project-Documentation
