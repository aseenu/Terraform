resource "azuread_user" "users" {
  count               = 1
  user_principal_name = "aa_${count.index}@mail.com"
  display_name        = "${var.uservar}${count.index}"
  password            = "Password@123"
}

