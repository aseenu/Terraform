provider "azurerm" {
  version = "~>2.0"
  features {}
}

variable "users" {
  default = {
    tom : { country = "us" },
    harry : { country = "uk" },
    jane : { country = "in" },
    shiva : { country = "as" }
  }
}

resource "azuread_user" "userss" {

  ##  for_each = toset(var.name)
  #  user_principal_name = "${each.value}@mail.com"
  # display_name = each.value
  # password  = "Password@12345"
  for_each = var.users

  user_principal_name = "${each.key}@mail.com"
  display_name        = each.key
  password            = "Password@1234"
  ## usage_location = "${each.value.country}"

  usage_location = each.value.country

}