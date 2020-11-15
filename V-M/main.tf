
## Resource Group name ##
resource "azurerm_resource_group" "my-rg"{
    location = "Central US"
    name     = "rg-name"

    tags = {
        envoirnment = "Terraform Demo"
    }
}

## Creating Virtual network  ##

resource "azurerm_virtual_network" "my-Vir-ntk" {
       name = "my-virtual-vent"
       address_space = ["10.0.0.0/16"]
       location = azurerm_resource_group.my-rg.location
       resource_group_name = azurerm_resource_group.my-rg.name

        tags = {
        envoirnment = "production"
    }

}

## creating  subnet ##
 
 resource "azurerm_subnet" "my-subnet" {
     name = "my-sub"
     resource_group_name = azurerm_resource_group.my-rg.name
     virtual_network_name = azurerm_virtual_network.my-Vir-ntk.name
     address_prefixes     = ["10.0.1.0/24"]
 }

 ## craeting public IP ##

 resource "azurerm_public_ip" "public-ip" {
     name = "my-public-ip"
     location = azurerm_resource_group.my-rg.location
    resource_group_name = azurerm_resource_group.my-rg.name
    allocation_method = "Dynamic"

 }

 ## creating NSG ##

 resource "azurerm_network_security_group" "my-nsg" {
       name = "my-nsg2"
       location =  azurerm_resource_group.my-rg.location
       resource_group_name = azurerm_resource_group.my-rg.name

       security_rule {
           name = "ssh"
           priority = 1001
           direction = "Inbound"
           access = "Allow"
           protocol = "Tcp"
           source_port_range = "*"
           destination_port_range = "22"
           source_address_prefix = "*"
           destination_address_prefix = "*"

       }
 }

## Craete network interface card ##

resource "azurerm_network_interface" "my-nic" {
     name = "my-nic-name"
       location =  azurerm_resource_group.my-rg.location
       resource_group_name = azurerm_resource_group.my-rg.name

    ip_configuration {
        name = "myconf-nic"
        subnet_id = azurerm_subnet.my-subnet.id
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id = azurerm_public_ip.public-ip.id
    }

}

# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "example" {
    network_interface_id      = azurerm_network_interface.my-nic.id
    network_security_group_id = azurerm_network_security_group.my-nsg.id
}

# Generate random text for a unique storage account name
resource "random_id" "randomId" {
    keepers = {
        # Generate a new ID only when a new resource group is defined
        resource_group = azurerm_resource_group.my-rg.name
    }

    byte_length = 8
}

# Create storage account for boot diagnostics
resource "azurerm_storage_account" "mystorageaccount" {
    name                        = "diag${random_id.randomId.hex}"
    resource_group_name         = azurerm_resource_group.my-rg.name
    location                    = azurerm_resource_group.my-rg.location
    account_tier                = "Standard"
    account_replication_type    = "LRS"

    tags = {
        environment = "Terraform Demo"
    }
}

# Create (and display) an SSH key
resource "tls_private_key" "example_ssh" {
  algorithm = "RSA"
  rsa_bits = 4096
}
output "tls_private_key" { value = tls_private_key.example_ssh.private_key_pem }

# Create virtual machine
resource "azurerm_linux_virtual_machine" "myterraformvm" {
    name                  = "myVM"
    location              =  azurerm_resource_group.my-rg.location
    resource_group_name   = azurerm_resource_group.my-rg.name
    network_interface_ids = [azurerm_network_interface.my-nic.id]
    size                  = "Standard_DS1_v2"

    os_disk {
        name              = "myOsDisk"
        caching           = "ReadWrite"
        storage_account_type = "Premium_LRS"
    }

    source_image_reference {
        publisher = "Canonical"
        offer     = "UbuntuServer"
        sku       = "18.04-LTS"
        version   = "latest"
    }

    computer_name  = "myvm"
    admin_username = "azureuser"
    disable_password_authentication = false

    admin_ssh_key {
        username       = "azureuser"
        public_key     = tls_private_key.example_ssh.public_key_openssh
    }

    boot_diagnostics {
        storage_account_uri = azurerm_storage_account.mystorageaccount.primary_blob_endpoint
    }

    tags = {
        environment = "Terraform Demo"
    }
}







