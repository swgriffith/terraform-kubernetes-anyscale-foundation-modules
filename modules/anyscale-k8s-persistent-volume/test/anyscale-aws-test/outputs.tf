# --------------
# Defaults Test
# --------------
output "all_defaults_resources" {
  description = "The resources of the All Defaults test"
  value       = module.all_defaults
}

# ------------------
# Kitchen Sink Test
# ------------------
# output "kitchen_sink_resources" {
#   description = "The resources of the Kitchen Sink test"
#   value       = module.kitchen_sink
# }

# -----------------
# No resource test
# -----------------
output "test_no_resources" {
  description = "The outputs of the no_resource resource - should all be empty"
  value       = module.test_no_resources
}
