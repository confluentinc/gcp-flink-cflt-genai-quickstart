resource "random_id" "env_display_id" {
  byte_length = 4
}

locals {
  # If the suffix is not provided, generate a random one
  env_display_id_postfix = coalesce(var.env_display_id_postfix, random_id.env_display_id.hex)
}