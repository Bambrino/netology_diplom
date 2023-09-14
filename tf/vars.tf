variable "YC_SERVICE_ACCOUNT_KEY_FILE" { 
    type = string 
    }

variable "YC_CLOUD_ID" { 
    type = string 
    }

variable "YC_FOLDER_ID" { 
    type = string 
    }

variable "YC_ZONE" {
    type = string
}

variable "ubuntu_2004" {
  default = "fd8de1idq8noos4s3lfb"
}

variable "hosts_file" {
  default = "../kuberspray/inventory/mykubecl/hosts.yaml"
}

variable "ssh_private_key" {
  default = "~/.ssh/id_rsa"
}


variable net_zones {
    type = list(string)
    default = [
        "ru-central1-a",
        "ru-central1-b",
        "ru-central1-c"
    ]
}

