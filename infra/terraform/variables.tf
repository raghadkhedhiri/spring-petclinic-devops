variable "project_name" {
  description = "Nom du projet utilisé pour nommer les ressources Azure"
  type        = string
  default     = "petclinic-devops"
}

variable "location" {
  description = "Région Azure utilisée pour l'infrastructure"
  type        = string
  default     = "polandcentral"
}

variable "vm_size" {
  description = "Taille de la VM Kubernetes"
  type        = string
  default     = "Standard_B4as_v2"
}

variable "admin_username" {
  description = "Utilisateur administrateur de la VM Ubuntu"
  type        = string
  default     = "azureuser"
}

variable "ssh_public_key_path" {
  description = "Chemin vers la clé SSH publique locale"
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}

variable "admin_cidr" {
  description = "Adresse IP autorisée à se connecter en SSH"
  type        = string
}

variable "availability_zone" {
  description = "Zone de disponibilité Azure utilisée pour la VM"
  type        = string
  default     = "2"
}
