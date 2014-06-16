Insights about Pagerduty
========================

##Purpose
How is your oncall shift going? How many incidents did you field this week, and for what services? Is your alert noise getting worse or better?

Find answers to these and more by using New Relic Insights to query your PagerDuty incident history! This is a small Ruby script, suitable for running in Heroku, that queries PagerDuty every 10 minutes and populates Insights with information about resolved PagerDuy incidents.

##Usage
###Software required:
 * Ruby 2.1.1
 * Bundler

###Required environment variables:
 * PAGERDUTY_TOKEN: your [PagerDuty API key](https://support.pagerduty.com/entries/23761081-Generating-an-API-Key).
 * PAGERDUTY_DOMAIN`: your PagerDuty subdomain.
 * INSIGHTS_INSERT_KEY: your New Relic Insights [insert  key](http://docs.newrelic.com/docs/insights/inserting-events#register).
 * INSIGHTS_EVENT_URL: The URL to send Insights events to. Formed like `https://insights.newrelic.com/beta_api/accounts/<your account id>/events`.

###Optional environment variables:
 * FETCH_INCIDENTS_SINCE: The number of seconds to look in the past for pagerduty incidents. Defaults to 10 minutes. Set this to your run interval for the script. You may set this to be wider when running manually to backfill events, but note that Insights only allows backdated events up to 24 hours old. NB: The code makes no attempt to prevent duplicate entries in Insights, so be careful when experimenting.
  
###Command line:
```bash
bundle install
bundle exec ./pagerduty-incident-scraper.rb
```

###Heroku:
Set the required ENV inside your heroku app and configure the Heroku Scheduler add-on to the script every 10 minutes.

## Example NRQL Queries

Once you've loaded some of your data, what kind of things can you find out?

###Who fielded the most alerts this week?
```sql
SELECT count(*) from PagerdutyIncident FACET first_assigned_to_user SINCE 1 week ago TIMESERIES
```
![alert recipient chart](http://i.imgur.com/aMjuk7Q.png)

###What hours of the day are incidents created?
```sql
SELECT histogram(created_on_hour, 24, 24) from PagerdutyIncident WHERE eventVersion >= 2 SINCE 1 week ago
```
![alert hour histogram](http://i.imgur.com/hzgEWoZ.png)
####Wait, what's eventVersion?
Because Insights doesn't currently allow modification of stored events, if the schema of the events sent in changes, it can be hard to make queries that depend on the schema looking a certain way. This script sends an `eventVersion` integer attribute that you should increment if you change the schema of the events you send. For this query, `created_on_hour` was changed from a string to an integer in eventVersion 2, so it's scoped to those.

###How long are our incidents open?
```sql
SELECT histogram(open_duration, 600) from PagerdutyIncident SINCE 1 week ago
```
![incident open time histogram](http://i.imgur.com/i2m9LBt.png)

###How many incidents are being routed to my team?
```sql
SELECT count(*) from PagerdutyIncident WHERE  escalation_policy_name='Site Services' SINCE 1 week ago TIMESERIES
```
![Escalation policy alert count chart](http://i.imgur.com/drTSyAG.png)

##Contributing

You are welcome to send pull requests to us - however, by doing so you agree that you are granting New Relic a non-exclusive, non-revokable, no-cost license to use the code, algorithms, patents, and ideas in that code in our products if we so choose. You also agree the code is provided as-is and you provide no warranties as to its fitness or correctness for any purpose.
