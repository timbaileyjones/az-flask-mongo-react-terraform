variable app-resource-group {
    type = string
    description = "Resource group the app app"
}
variable app-version {
    type = string
    description = "Version number of the app container that ACI should run"
}

variable failover_location {
    type = string
    default = "westus"
}