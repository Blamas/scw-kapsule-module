variable "project_name" {
  description = "Project name"
  type        = string
}

variable "project_id" {
  description = "Project name"
  type        = string
}

variable "region" {
  description = "Scaleway region"
  type        = string
}

variable "base_zone" {
  description = "Scaleway zone"
  type        = string
}

variable "kapsule_cluster" {
  description = "Kapsule cluster"
  type = object({
    name        = string
    description = optional(string)
    version     = string
    cni         = string

    autoscaler_config = optional(object({
      disable_scale_down               = optional(bool)
      scale_down_delay_after_add       = optional(string)
      scale_down_unneeded_time         = optional(string)
      estimator                        = optional(string)
      expander                         = optional(bool)
      ignore_daemonsets_utilization    = optional(bool)
      expendable_pods_priority_cutoff  = optional(string)
      scale_down_utilization_threshold = optional(string)
      max_graceful_termination_sec     = optional(string)
    }))

    auto_upgrade = optional(object({
      enable                        = optional(bool)
      maintenance_window_start_hour = optional(string)
      maintenance_window_day        = optional(string)
    }))

    feature_gates       = optional(list(string))
    admission_plugins   = optional(list(string))
    apiserver_cert_sans = optional(list(string))

    open_id_connect_config = optional(object({
      issuer_url      = optional(string)
      client_id       = optional(string)
      username_claim  = optional(string)
      username_prefix = optional(string)
      groups_claim    = optional(string)
      groups_prefix   = optional(string)
      required_claim  = optional(string)
    }))

    delete_additional_resources = optional(bool)

    pools = map(object({
      name              = string
      node_type         = string
      size              = string
      min_size          = optional(string)
      max_size          = optional(string)
      autoscaling       = optional(bool)
      autohealing       = optional(bool)
      container_runtime = optional(string)
      kubelet_args      = optional(map(string))

      upgrade_policy = optional(object({
        max_surge       = optional(string)
        max_unavailable = optional(string)
      }))

      root_volume_type       = optional(string)
      root_volume_size_in_gb = optional(string)
      wait_for_pool_ready    = optional(string)
      placement_group = optional(object({
        name        = optional(string)
        zone        = optional(string)
        policy_type = optional(string)
        policy_mode = optional(string)
      }))
    }))
  })
  default = null
}

variable "rdb_instances" {
  description = "Rdb instances"
  type = map(object({
    name      = string
    node_type = string
    engine    = string

    is_ha_cluster     = optional(bool)
    volume_type       = optional(string)
    volume_size_in_gb = optional(string)

    disable_backup            = optional(bool)
    backup_schedule_frequency = optional(string)
    backup_schedule_retention = optional(string)
    backup_same_region        = optional(string)

    settings = optional(map(string))

    databases = optional(map(object({
      name = string
    })))

    users = map(object({
      user_name = string
      is_admin  = optional(string)
    }))

    privileges = optional(map(object({
      database_name = string
      user_name     = string
      permission    = string
    })))

    acl_rules = map(object({
      ip          = string
      description = optional(string)
    }))
  }))
  default = {}
}

variable "tags" {
  description = "The key-value maps for tagging"
  type        = list(string)
  default     = []
}

