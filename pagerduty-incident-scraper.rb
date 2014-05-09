#!/usr/bin/env ruby

require 'pp'
require 'yajl'
require 'httparty'
require 'time'

PAGERDUTY_TOKEN       = ENV['PAGERDUTY_TOKEN']
INSIGHTS_INSERT_KEY   = ENV['INSIGHTS_INSERT_KEY']
FETCH_INCIDENTS_SINCE = ENV['FETCH_INCIDENTS_SINCE'] || 10 * 60

incidents_this_tw = HTTParty.get(
    'https://newrelic.pagerduty.com/api/v1/incidents', 
    :query => {:until => Time.now, :since => (Time.now - FETCH_INCIDENTS_SINCE),
               :status => 'resolved', },
    :headers => {"Authorization" => "Token token=#{PAGERDUTY_TOKEN}"})

if incidents_this_tw['incidents'].nil?
  raise incidents_this_tw.inspect
end

events = []
incidents_this_tw['incidents'].each do |incident|
  created_on    = Time.parse(incident['created_on'])
  closed_on     = Time.parse(incident['last_status_change_on'])
  open_duration = closed_on - created_on

  incidents_log = HTTParty.get(
    "https://newrelic.pagerduty.com/api/v1/incidents/#{incident['id']}/log_entries", 
    :query => {:offset => 0, :limit => 100},
    :headers => {"Authorization" => "Token token=#{PAGERDUTY_TOKEN}"})

  first_assignment = 
    incidents_log['log_entries'].detect {|entry| entry['type'] == 'assign'}

  first_assigned_to_user = first_assignment.nil? ?
      nil : first_assignment['assigned_user']['email']

  events << {
    'eventType'                  => 'PagerdutyIncident',
    'eventVersion'               => 2,
    'incident_number'            => incident['incident_number'].to_i,
    'incident_url'               => incident['html_url'],
    'incident_key'               => incident['incident_key'],
    'created_on'                 => created_on.iso8601,
    'last_status_change_on'      => closed_on.iso8601,
    'timestamp'                  => closed_on.to_i,
    'open_duration'              => open_duration.ceil,
    'created_on_hour'            => created_on.strftime('%H').to_i,
    'last_status_change_on_hour' => closed_on.strftime('%H').to_i,
    'service_name'               => incident['service']['name'],
    'service_id'                 => incident['service']['id'],
    'escalation_policy_name'     => incident['escalation_policy']['name'],
    'escalation_policy_id'       => incident['escalation_policy']['id'],
    'trigger_type'               => incident['trigger_type'],
    'number_of_escalations'      => incident['number_of_escalations'].to_i,
    'resolved_by_user'           => incident['resolved_by_user'].nil? ? 
                                    nil : incident['resolved_by_user']['email'],
    'first_assigned_to_user'     => first_assigned_to_user,
  }
end

response = HTTParty.post('https://staging-insights-collector.newrelic.com/beta_api/accounts/1/events',
            :body    => Yajl::Encoder.encode(events),
            :headers => {'Content-Type' => 'application/json',
                         'X-Insert-Key' => INSIGHTS_INSERT_KEY})
