# Create network interface
resource "azurerm_public_ip" "publicip" {
    count                        = "${var.node_count}"
    name                         = "${var.prefix}-ip-c-l-${count.index}"
    location                     = azurerm_resource_group.rg.location
    resource_group_name          = azurerm_resource_group.rg.name
    allocation_method            = "Static"
    sku = "Standard"
}

resource "azurerm_network_interface" "nic-client-linux" {
    count                     = "${var.node_count}"
    name                      = "${var.prefix}-nic-c-l-${count.index}"
    location                  = azurerm_resource_group.rg.location
    resource_group_name       = azurerm_resource_group.rg.name

    ip_configuration {
        name                          = "${var.prefix}-ip-c-l-config-${count.index}"
        subnet_id                     = azurerm_subnet.subnet.id
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id          = "${element(azurerm_public_ip.publicip.*.id, count.index)}"
    }

    tags = {
        environment = "tf"
    }
}

resource "azurerm_network_interface_security_group_association" "sga" {
    count                     = "${var.node_count}"
    network_interface_id      = "${element(azurerm_network_interface.nic-client-linux.*.id, count.index)}"
    network_security_group_id = azurerm_network_security_group.nsg.id
}


# Create virtual machine
resource "azurerm_linux_virtual_machine" "vm-client-linux" {
    count                 = "${var.node_count}"
    name                  = "${var.prefix}-c-l-${count.index}"
    location              = azurerm_resource_group.rg.location
    resource_group_name   = azurerm_resource_group.rg.name
    network_interface_ids = ["${element(azurerm_network_interface.nic-client-linux.*.id,count.index)}"]
    size                  = "Standard_DC1s_v3"

    os_disk {
        name              = "${var.prefix}-vm-client-linux-disk-${count.index}"
        caching           = "ReadWrite"
        storage_account_type = "Standard_LRS"
    } 

    source_image_reference {
        publisher = "Canonical"
        offer     = "0001-com-ubuntu-server-focal"
        sku       = "20_04-lts-gen2"
        version   = "latest"
    }

    computer_name  = "${var.prefix}-c-l-${count.index}"
    admin_username = "john"
    disable_password_authentication = true

    admin_ssh_key {
        username       = "john"
        public_key     = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDOlY9F0gLlOTPvf5XrAiXH+qGdtrNuEL6Lbd+I1TFTzpci97ozzZksJ/6GvBnC/iX1WObibQBGZNdDdnD7041kbwnfgxNn9gC/EckNgRSmMmVFN/7QkPVclcCgBDqMeKo/r7k8PZFHi8cEUeJX71Bzac4cnRgN5jQY/cp6+MN+CcN44xyP1Lubjv+tfKmfLU7wzOLVcV6TnywpCPSC/yDAVfzhy/usNxlLnejtChhAuy98v1ibKkpWXKd3LbKvl2CHDA464dHvLS7zyoB/wOfjBgCXYkjWhq+lUE/EVDAhlp5k8+HGRmGY5mcB8wvUUvZw1wfy3NyR0pf3n6G1nA5B"
    }

    identity {
        type = "SystemAssigned"
    }

    custom_data = data.template_cloudinit_config.config.rendered

}
