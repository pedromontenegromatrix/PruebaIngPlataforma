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

##############################################################################################
##############################################################################################
##############################################################################################

resource "newrelic_alert_policy" "this2" {
  count = local.borrado || var.new_relic_account == "" ? 0 : 1

  provider            = newrelic.newrelic
  name                = "EC2 CPU Usage Alert"
  incident_preference = "PER_POLICY"
}

# Define el umbral de alerta para la CPU
resource "newrelic_alert_condition" "this2" {
  count = local.borrado || var.new_relic_account == "" ? 0 : 1

  provider  = newrelic.newrelic
  policy_id = newrelic_alert_policy.this2.id
  type      = "metric"
  name      = "EC2 CPU Utilization"
  enabled   = true

  # Condición basada en la métrica de CPU
  metric          = "CpuUtilization"
  condition_scope = "instance"

  # Filtro por instancia EC2 (reemplaza con tu ID de instancia)
  where = "entity.guid = '${aws_instance.this[0].id}'"

  # Umbral de alerta (ej: 80% de uso de CPU)
  comparison = "above"
  critical_threshold = {
    value         = 80
    duration      = 120
    time_function = "all"
  }

  # Opcional: Define un umbral de advertencia (ej: 60% de uso de CPU)
  warning_threshold = {
    value         = 60
    duration      = 120
    time_function = "all"
  }

  depends_on = [
    aws_instance.this,
    newrelic_alert_policy.this2
  ]
}

