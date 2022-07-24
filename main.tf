##### Kapsule cluster ####


resource "scaleway_k8s_cluster" "default" {
  region      = var.region
  project_id  = var.project_id
  name        = can(var.kapsule_cluster.name) ? var.kapsule_cluster.name : var.project_name
  description = can(var.kapsule_cluster.description) ? var.kapsule_cluster.description : null
  version     = var.kapsule_cluster.version
  cni         = var.kapsule_cluster.cni

  dynamic "autoscaler_config" {
    for_each = var.kapsule_cluster.autoscaler_config == null ? [] : [1]
    content {
      disable_scale_down               = can(var.kapsule_cluster.autoscaler_config.disable_scale_down) ? var.kapsule_cluster.autoscaler_config.disable_scale_down : null
      scale_down_delay_after_add       = can(var.kapsule_cluster.autoscaler_config.scale_down_delay_after_add) ? var.kapsule_cluster.autoscaler_config.scale_down_delay_after_add : null
      scale_down_unneeded_time         = can(var.kapsule_cluster.autoscaler_config.scale_down_unneeded_time) ? var.kapsule_cluster.autoscaler_config.scale_down_unneeded_time : null
      estimator                        = can(var.kapsule_cluster.autoscaler_config.estimator) ? var.kapsule_cluster.autoscaler_config.estimator : null
      expander                         = can(var.kapsule_cluster.autoscaler_config.expander) ? var.kapsule_cluster.autoscaler_config.expander : null
      ignore_daemonsets_utilization    = can(var.kapsule_cluster.autoscaler_config.ignore_daemonsets_utilization) ? var.kapsule_cluster.autoscaler_config.ignore_daemonsets_utilization : null
      expendable_pods_priority_cutoff  = can(var.kapsule_cluster.autoscaler_config.expendable_pods_priority_cutoff) ? var.kapsule_cluster.autoscaler_config.expendable_pods_priority_cutoff : null
      scale_down_utilization_threshold = can(var.kapsule_cluster.autoscaler_config.scale_down_utilization_threshold) ? var.kapsule_cluster.autoscaler_config.scale_down_utilization_threshold : null
      max_graceful_termination_sec     = can(var.kapsule_cluster.autoscaler_config.max_graceful_termination_sec) ? var.kapsule_cluster.autoscaler_config.max_graceful_termination_sec : null
    }
  }

  dynamic "auto_upgrade" {
    for_each = var.kapsule_cluster.auto_upgrade == null ? [] : [1]
    content {
      enable                        = can(var.kapsule_cluster.auto_upgrade.enable) ? var.kapsule_cluster.auto_upgrade.enable : null
      maintenance_window_start_hour = can(var.kapsule_cluster.auto_upgrade.maintenance_window_start_hour) ? var.kapsule_cluster.auto_upgrade.maintenance_window_start_hour : null
      maintenance_window_day        = can(var.kapsule_cluster.auto_upgrade.maintenance_window_day) ? var.kapsule_cluster.auto_upgrade.maintenance_window_day : null
    }
  }

  feature_gates       = can(var.kapsule_cluster.feature_gates) ? var.kapsule_cluster.feature_gates : []
  admission_plugins   = can(var.kapsule_cluster.admission_plugins) ? var.kapsule_cluster.admission_plugins : []
  apiserver_cert_sans = can(var.kapsule_cluster.apiserver_cert_sans) ? var.kapsule_cluster.apiserver_cert_sans : []

  dynamic "open_id_connect_config" {
    for_each = var.kapsule_cluster.open_id_connect_config == null ? [] : [1]
    content {
      issuer_url      = can(var.kapsule_cluster.open_id_connect_config.issuer_url) ? var.kapsule_cluster.open_id_connect_config.issuer_url : null
      client_id       = can(var.kapsule_cluster.open_id_connect_config.client_id) ? var.kapsule_cluster.open_id_connect_config.client_id : null
      username_claim  = can(var.kapsule_cluster.open_id_connect_config.username_claim) ? var.kapsule_cluster.open_id_connect_config.username_claim : null
      username_prefix = can(var.kapsule_cluster.open_id_connect_config.username_prefix) ? var.kapsule_cluster.open_id_connect_config.username_prefix : null
      groups_claim    = can(var.kapsule_cluster.open_id_connect_config.groups_claim) ? var.kapsule_cluster.open_id_connect_config.groups_claim : null
      groups_prefix   = can(var.kapsule_cluster.open_id_connect_config.groups_prefix) ? var.kapsule_cluster.open_id_connect_config.groups_prefix : null
      required_claim  = can(var.kapsule_cluster.open_id_connect_config.required_claim) ? var.kapsule_cluster.open_id_connect_config.required_claim : null
    }
  }

  delete_additional_resources = can(var.kapsule_cluster.delete_additional_resources) ? var.kapsule_cluster.delete_additional_resources : null

  tags = var.tags
}

resource "scaleway_lb_ip" "nginx_ip" {
  zone       = var.base_zone
  project_id = var.project_id
}

resource "scaleway_instance_placement_group" "default" {
  for_each = var.kapsule_cluster.pools

  zone        = can(each.value.zone) ? each.value.zone : null
  project_id  = var.project_id
  name        = each.value.name
  policy_type = can(each.value.policy_type) ? each.value.policy_type : null
  policy_mode = can(each.value.policy_mode) ? each.value.policy_mode : null
  tags        = var.tags
}


resource "scaleway_k8s_pool" "default" {
  for_each = var.kapsule_cluster.pools

  region             = var.region
  zone               = can(each.value.placement_group) ? (can(each.value.placement_group.zone) ? each.value.placement_group.zone : null) : null
  name               = each.value.name
  cluster_id         = scaleway_k8s_cluster.default.id
  placement_group_id = scaleway_instance_placement_group.default[each.key].id

  node_type         = each.value.node_type
  size              = each.value.size
  min_size          = can(each.value.min_size) ? each.value.min_size : null
  max_size          = can(each.value.max_size) ? each.value.max_size : null
  autoscaling       = can(each.value.autoscaling) ? each.value.autoscaling : null
  autohealing       = can(each.value.autohealing) ? each.value.autohealing : null
  container_runtime = can(each.value.container_runtime) ? each.value.container_runtime : null
  kubelet_args      = can(each.value.kubelet_args) ? each.value.kubelet_args : {}

  dynamic "upgrade_policy" {
    for_each = each.value.upgrade_policy == null ? [] : [1]
    content {
      max_surge       = can(each.value.upgrade_policy.max_surge) ? each.value.upgrade_policy.max_surge : null
      max_unavailable = can(each.value.upgrade_policy.max_unavailable) ? each.value.upgrade_policy.max_unavailable : null
    }
  }

  root_volume_type       = can(each.value.root_volume_type) ? each.value.root_volume_type : null
  root_volume_size_in_gb = can(each.value.root_volume_size_in_gb) ? each.value.root_volume_size_in_gb : null
  wait_for_pool_ready    = can(each.value.wait_for_pool_ready) ? each.value.wait_for_pool_ready : null

  tags = var.tags
}

resource "null_resource" "kubeconfig" {
  depends_on = [scaleway_k8s_pool.default]
  triggers = {
    host                   = scaleway_k8s_cluster.default.kubeconfig[0].host
    token                  = scaleway_k8s_cluster.default.kubeconfig[0].token
    cluster_ca_certificate = scaleway_k8s_cluster.default.kubeconfig[0].cluster_ca_certificate
  }
}

##### RDB Instances ####

resource "scaleway_rdb_instance" "default" {
  for_each = var.rdb_instances

  name      = each.value.name
  node_type = each.value.node_type
  engine    = each.value.engine

  is_ha_cluster     = can(each.value.is_ha_cluster) ? each.value.is_ha_cluster : null
  volume_type       = can(each.value.volume_type) ? each.value.volume_type : null
  volume_size_in_gb = can(each.value.volume_size_in_gb) ? each.value.volume_size_in_gb : null

  disable_backup            = can(each.value.disable_backup) ? each.value.disable_backup : null
  backup_schedule_frequency = can(each.value.backup_schedule_frequency) ? each.value.backup_schedule_frequency : null
  backup_schedule_retention = can(each.value.backup_schedule_retention) ? each.value.backup_schedule_retention : null
  backup_same_region        = can(each.value.backup_same_region) ? each.value.backup_same_region : null

  settings = can(each.value.settings) ? each.value.settings : {}

  tags = var.tags
}

locals {
  users = flatten([
    for k_rdb_instances, v_rdb_instances in var.rdb_instances : [
      for k_users, v_users in v_rdb_instances.users : {
        instance_id   = scaleway_rdb_instance.default[k_rdb_instances].id
        instance_name = var.rdb_instances[k_rdb_instances].name
        user_name     = v_users.user_name
        is_admin      = can(v_users.is_admin) ? v_users.is_admin : null
      }
    ]
  ])

  databases = flatten([
    for k_rdb_instances, v_rdb_instances in var.rdb_instances : [
      for k_databases, v_databases in v_rdb_instances.databases : {
        instance_id   = scaleway_rdb_instance.default[k_rdb_instances].id
        instance_name = var.rdb_instances[k_rdb_instances].name
        name          = v_databases.name
      }
    ]
  ])

  privileges = flatten([
    for k_rdb_instances, v_rdb_instances in var.rdb_instances : [
      for k_privileges, v_privileges in v_rdb_instances.privileges : {
        instance_id   = scaleway_rdb_instance.default[k_rdb_instances].id
        instance_name = var.rdb_instances[k_rdb_instances].name
        database_name = v_privileges.database_name
        user_name     = v_privileges.user_name
        permission    = v_privileges.permission
      }
    ]
  ])
}

resource "scaleway_rdb_database" "default" {
  for_each = {
    for v_databases in local.databases : join("-", [v_databases.instance_name, v_databases.name]) => v_databases
  }

  instance_id = each.value.instance_id
  name        = each.value.name
}

resource "random_password" "default" {
  for_each = {
    for v_users in local.users : join("-", [v_users.instance_name, v_users.user_name]) => v_users
  }

  length  = 32
  special = true
}

resource "scaleway_rdb_user" "default" {
  for_each = {
    for v_users in local.users : join("-", [v_users.instance_name, v_users.user_name]) => v_users
  }

  instance_id = each.value.instance_id
  name        = each.value.user_name
  password    = random_password.default[each.key].result
  is_admin    = each.value.is_admin
}

resource "scaleway_rdb_privilege" "default" {
  for_each = {
    for v_privileges in local.privileges : join("-", [v_privileges.instance_name, v_privileges.user_name, v_privileges.database_name]) => v_privileges
  }

  instance_id   = each.value.instance_id
  user_name     = each.value.user_name
  database_name = each.value.database_name
  permission    = each.value.permission

  depends_on = [scaleway_rdb_user.default, scaleway_rdb_database.default]
}

resource "scaleway_rdb_acl" "default" {
  for_each = var.rdb_instances

  instance_id = scaleway_rdb_instance.default[each.key].id
  dynamic "acl_rules" {
    for_each = each.value.acl_rules
    content {
      ip          = acl_rules.value.ip
      description = can(acl_rules.value.description) ? acl_rules.value.description : null
    }
  }
}
