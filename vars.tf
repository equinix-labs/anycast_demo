variable "packet_api_key" {
  description = "Your packet API key"
  type = string
  default = "xxx"
}

variable "bgp_password" {
    type = string
    default = "xxxx"
}

variable "database_url" {
  description = "postgres conneection url"
  type = string
  default = "https://get.from.postgres.provider/"
}

variable "ping_golf_version" {
  description = "Version string for what version of ping golf to run"
  type = string
  default = "0.1.4"
}