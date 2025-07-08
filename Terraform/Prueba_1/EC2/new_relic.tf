resource "newrelic_alert_policy" "mi_politica_alerta" {
  name = "Alerta EC2"
}

resource "newrelic_nrql_alert_condition" "mi_condicion_alerta" {
  policy_id = newrelic_alert_policy.mi_politica_alerta.id
  name      = "Alerta de CPU Alta"
  type      = "static"

  nrql {
    query = "SELECT average(cpuPercent) FROM SystemSample WHERE `entity.guid` = '${aws_instance.this.id}'"
    since = "5 minutes ago"
  }

  terms {
    duration              = "5"
    operator              = "above"
    threshold             = 80
    threshold_duration    = "5"
    threshold_occurrences = "AT_LEAST_ONCE"
  }
}