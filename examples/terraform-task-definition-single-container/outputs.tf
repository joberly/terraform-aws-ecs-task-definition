output "container_definitions" {
  value = "${format("[%s]", join(",", [module.mongodb.container_definitions]))}"
}
