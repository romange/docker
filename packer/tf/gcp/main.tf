# terraform apply -var="project=..."
variable project {}
variable bucket {}
variable region {default = "europe-west4"}
variable zone { default = "europe-west4-a" }


provider "google" {
  project     = var.project
  region      = var.region
}


resource "google_service_account" "packer_account" {
  account_id   = "packer"
  display_name = "Packer Service Account"
}


locals {
    account_id = "serviceAccount:packer@${var.project}.iam.gserviceaccount.com"
}

module "iam_projects_iam" {
  source  = "terraform-google-modules/iam/google//modules/projects_iam"
  version = "~> 7.3"

  projects = [var.project]

  bindings = {
    "roles/compute.instanceAdmin.v1" = [
      local.account_id,      
    ]

    "roles/iam.serviceAccountUser" = [
      local.account_id,      
    ]

    "roles/iap.tunnelResourceAccessor" = [
      local.account_id,      
    ]
  }
}

resource "google_secret_manager_secret" "packer-secret" {
  secret_id = "artifactdir"

  replication {
    automatic = true
  }
}

resource "google_secret_manager_secret_version" "packer-secret-version" {
  secret = google_secret_manager_secret.packer-secret.id

  secret_data = var.bucket
}