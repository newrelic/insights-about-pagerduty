Insights about Pagerduty
========================

##Purpose
How is your oncall shift going? How many incidents did you field this week, and for what services? Is your alert noise getting worse or better?

Find answers to these and more by using New Relic Insights to query your PagerDuty incident history! This is a small Ruby script, suitable for running in Heroku, that queries PagerDuty every 10 minutes and populates Insights with information about resolved PagerDuy incidents.

##Usage
Software required:
 * Ruby 2.1.1
 * Bundler

Required environment variables:
 * PAGERDUTY_TOKEN: your [PagerDuty API key](https://support.pagerduty.com/entries/23761081-Generating-an-API-Key).
 * PAGERDUTY_DOMAIN`: your PagerDuty subdomain.
 * INSIGHTS_INSERT_KEY: your New Relic Insights [insert  key](http://docs.newrelic.com/docs/insights/inserting-events#register).
 * INSIGHTS_EVENT_URL: The URL to send Insights events to. Formed like `https://insights.newrelic.com/beta_api/accounts/<your account id>/events`.

Optional environment variables:
 * FETCH_INCIDENTS_SINCE: The number of seconds to look in the past for pagerduty incidents. Defaults to 10 minutes. Set this to your run interval for the script. NB: The code makes no attempt to prevent duplicate entries in Insights, so make sure this lines up.
  
Command line:
```bash
bundle install
bundle exec ./insights-about-pagerduty.rb
```

Heroku:

Set the required ENV inside your heroku app and configure the Heroku Scheduler add-on to the script every 10 minutes.

 
##Contributing

You are welcome to send pull requests to us - however, by doing so you agree that you are granting New Relic a non-exclusive, non-revokable, no-cost license to use the code, algorithms, patents, and ideas in that code in our products if we so choose. You also agree the code is provided as-is and you provide no warranties as to its fitness or correctness for any purpose.
