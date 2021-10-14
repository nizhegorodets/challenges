variable "tags" {
  description = "Tags to add to resources"
  type        = map(string)
  default = {
    Name  = "Flugel"
    Owner = "InfraTeam"
  }
}