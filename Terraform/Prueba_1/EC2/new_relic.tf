/*
resource "newrelic_alert_policy" "this" {
  count = local.borrado || var.new_relic_account == "" ? 0 : 1
  name  = "Alerta EC2"

  depends_on = [aws_instance.this]
}

resource "newrelic_nrql_alert_condition" "this" {
  count     = local.borrado || var.new_relic_account == "" ? 0 : 1
  policy_id = newrelic_alert_policy.this[0].id
  name      = "Alerta de CPU Alta"
  type      = "static"

  nrql {
    query = "SELECT average(cpuPercent) FROM SystemSample WHERE `entity.guid` = '${aws_instance.this[0].id}'"
    #since = "5 minutes ago"
  }

  term {
    duration              = "5"
    operator              = "above"
    threshold             = 80
    threshold_duration    = "5"
    threshold_occurrences = "AT_LEAST_ONCE"
  }
  depends_on = [
    aws_instance.this,
    newrelic_alert_policy.this
  ]
}
*/
