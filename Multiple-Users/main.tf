resource "azuread_user" "users"{
     ##### Using Count the list values =="instances": [{"index_key": 0  ###
     ## deletion and updation will be based on index value ##
    
    count = length(var.name)
      
    user_principal_name = "${var.name[count.index]}@mail.com"
    display_name = "${var.name[count.index]}"
    password = "Password@1234"


  ##### using the for_each list values willbe  == instances": [{  "index_key": "list-value",
  ## deletion and updation will be based on values ##
   
    # for_each = toset(var.name)

    # user_principal_name = "${each.value}@mail.com"
    # display_name = each.value
    # password  = "Password@12345"
}