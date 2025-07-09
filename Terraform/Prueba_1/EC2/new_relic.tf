/*
resource "newrelic_application_settings" "this" {
  count = local.borrado || var.new_relic_account == "" ? 0 : 1

  provider                    = newrelic.newrelic
  name                        = "app-${local.env}-${var.project}-AppNewRelicIntegration-01"
  app_apdex_threshold         = "0.7"
  end_user_apdex_threshold    = "0.8"
  enable_real_user_monitoring = false

  depends_on = [aws_iam_role_policy_attachment.this_integracion]
}
*/

resource "newrelic_cloud_aws_link_account" "this" {
  count = local.borrado || var.new_relic_account == "" ? 0 : 1

  provider               = newrelic.newrelic
  arn                    = aws_iam_role.this_integracion[0].arn
  metric_collection_mode = "PULL"
  name                   = "link-${local.env}-${var.project}-NewRelicIntegration-01"

  depends_on = [aws_iam_role_policy_attachment.this_integracion]
}

resource "newrelic_cloud_aws_integrations" "this" {
  count = local.borrado || var.new_relic_account == "" ? 0 : 1

  provider          = newrelic.newrelic
  linked_account_id = newrelic_cloud_aws_link_account.this[0].id

  vpc {
    metrics_polling_interval = 900
    aws_regions              = [var.region]
    fetch_nat_gateway        = true
    fetch_vpn                = false
    tag_key                  = "Name"
    tag_value                = "*vpc*"
  }
  ec2 {
    aws_regions              = [var.region]
    duplicate_ec2_tags       = true
    fetch_ip_addresses       = true
    metrics_polling_interval = 300
    tag_key                  = "Name"
    tag_value                = "*asgr*"
  }

  depends_on = [newrelic_cloud_aws_link_account.this]
}

resource "newrelic_alert_policy" "this" {
  count = local.borrado || var.new_relic_account == "" ? 0 : 1

  provider = newrelic.newrelic
  name     = "alert-pl-${local.env}-${var.project}-EC2AwsNewRelic-01"

  depends_on = [aws_instance.this]
}

resource "newrelic_nrql_alert_condition" "this" {
  count = local.borrado || var.new_relic_account == "" ? 0 : local.cantidad_ec2

  provider   = newrelic.newrelic
  account_id = var.new_relic_account
  policy_id  = newrelic_alert_policy.this[0].id
  name       = "alert-${local.env}-${var.project}-EC2CPU-0${count.index + 1}"
  type       = "static"
  enabled    = true

  nrql {
    query = "SELECT average(provider.cpuUtilization.Sum) FROM ComputeSample WHERE `provider.ec2InstanceId` = '${aws_instance.this[count.index].id}'"
    #since = "5 minutes ago"
  }

  critical {
    operator              = "above"
    threshold             = 5.5
    threshold_duration    = 300
    threshold_occurrences = "all"
  }

  warning {
    operator              = "below"
    threshold             = 3.5
    threshold_duration    = 600
    threshold_occurrences = "all"
  }

  depends_on = [
    aws_instance.this,
    newrelic_alert_policy.this
  ]
}

resource "newrelic_one_dashboard" "this" {
  count = local.borrado || var.new_relic_account == "" ? 0 : 1

  provider    = newrelic.newrelic
  name        = "dash-${local.env}-${var.project}-NewRelicIntegration-01"
  permissions = "public_read_write"

  page {
    name = "DashBoard Instancias EC2"

    widget_table {
      title  = "Listado Instancias Estado"
      row    = 1
      column = 1
      width  = 6
      height = 3

      nrql_query {
        query = "SELECT provider.ec2InstanceId, provider.ec2State, provider.cpuCreditUsage.Maximum  FROM ComputeSample where provider.ec2InstanceType = 't3.micro'"
      }
    }
  }
}

resource "newrelic_workload" "this" {
  count = local.borrado || var.new_relic_account == "" ? 0 : 1

  provider   = newrelic.newrelic
  name       = "wl-${local.env}-${var.project}-NewRelicIntegration-01"
  account_id = var.new_relic_account

  entity_guids = [newrelic_one_dashboard.this[0].guid]

  entity_search_query {
    query = "name like '%NewRelicIntegration%'"
  }

  scope_account_ids = [var.new_relic_account]
}

##############################################################################################
##############################################################################################
##############################################################################################
/*
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
  policy_id = newrelic_alert_policy.this2[0].id
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
*/
