output "events_api_url" {
  value       = module.rest_api.url
  description = "The REST API URL, including the events endpoint, for the deployed service"
}
