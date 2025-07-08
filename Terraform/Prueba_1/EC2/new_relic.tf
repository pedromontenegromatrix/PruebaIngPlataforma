resource "newrelic_alert_policy" "this" {
  count = local.borrado || var.new_relic_account == "" ? 0 : 1

  provider = newrelic.newrelic
  name     = "Alerta EC2"

  depends_on = [aws_instance.this]
}

resource "newrelic_nrql_alert_condition" "this" {
  count = local.borrado || var.new_relic_account == "" ? 0 : 1

  provider   = newrelic.newrelic
  account_id = var.new_relic_account
  policy_id  = newrelic_alert_policy.this[0].id
  name       = "Alerta de CPU Alta"
  type       = "static"
  enabled    = true

  nrql {
    query = "SELECT average(cpuPercent) FROM SystemSample WHERE `entity.guid` = '${aws_instance.this[0].id}'"
    #since = "5 minutes ago"
  }

  critical {
    operator              = "above"
    threshold             = 5.5
    threshold_duration    = 300
    threshold_occurrences = "all"
  }

  warning {
    operator              = "above"
    threshold             = 3.5
    threshold_duration    = 600
    threshold_occurrences = "all"
  }

  depends_on = [
    aws_instance.this,
    newrelic_alert_policy.this
  ]
}

/*
resource "newrelic_nrql_alert_condition" "foo" {
  type                         = "baseline"
  account_id                   = 12345678
  name                         = "foo"
  policy_id                    = newrelic_alert_policy.foo.id
  description                  = "Alert when transactions are taking too long"
  enabled                      = true
  runbook_url                  = "https://www.example.com"
  violation_time_limit_seconds = 3600
  aggregation_method           = "event_flow"
  aggregation_delay            = 120
  slide_by                     = 30

  # baseline type only
  baseline_direction = "upper_only"
  signal_seasonality = "weekly"

  nrql {
    query = "SELECT percentile(duration, 95) FROM Transaction WHERE appName = 'ExampleAppName'"
  }

  critical {
    operator              = "above"
    threshold             = 5.5
    threshold_duration    = 300
    threshold_occurrences = "all"
  }

  warning {
    operator              = "above"
    threshold             = 3.5
    threshold_duration    = 600
    threshold_occurrences = "all"
  }
}
*/
