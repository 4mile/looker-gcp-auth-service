
locals {
  # note that $PROJECT_ID and $SHORT_SHA are substituted by the cloud build environment
  image_name           = "gcr.io/$PROJECT_ID/${var.service}"
  image_name_versioned = "${local.image_name}:$SHORT_SHA"
  image_name_latest    = "${local.image_name}:latest"
}

# This defines the provider, in this case Google
terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 3.66"
    }
  }
}

# This allows terraform the ability to affect resources
# Requires a terraform service account credentials file
provider "google" {
  credentials = file(var.credentials_file)

  project = var.project
  region  = var.region
  zone    = var.zone
}

# This turns on the cloud run api in GCP
resource "google_project_service" "iam_api" {
  service            = "iam.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "cloudresourcemanager" {
  service            = "cloudresourcemanager.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "run_api" {
  service = "run.googleapis.com"
  disable_on_destroy = true
}

resource "google_project_service" "cloudbuild" {
  service            = "cloudbuild.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "container" {
  service            = "container.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "secretmanager" {
  service            = "secretmanager.googleapis.com"
  disable_on_destroy = false
}

# This creates our Cloud Run service
resource "google_cloud_run_service" "looker_gcp_auth_service" {
  name = "looker-gcp-auth-service"
  location = var.region

  template {
    spec {
      containers {
        image = "us-docker.pkg.dev/cloudrun/container/hello:latest"
        # image = "gcr.io/${var.project}/${var.service}:${var.app_version}"
      }
    }
  }

  # Waits for the Cloud Run API to be enabled
  depends_on = [google_project_service.run_api]
}

# Create public access for our cloud run service
data "google_iam_policy" "noauth" {
  binding {
    role = "roles/run.invoker"
    members = [
      "allUsers",
    ]
  }
}

# Enables public access on Cloud Run service
resource "google_cloud_run_service_iam_policy" "noauth" {
  location    = google_cloud_run_service.looker_gcp_auth_service.location
  project     = var.project
  service     = google_cloud_run_service.looker_gcp_auth_service.name
  policy_data = data.google_iam_policy.noauth.policy_data
}

# Creates a service account that will grant the access token
resource "google_service_account" "looker_gcp_auth_service_account" {
  account_id   = "looker-gcp-auth"
  display_name = "Looker GCP Auth Service Account"

   # Waits for the Cloud Run API to be enabled
  depends_on = [google_project_service.iam_api, google_cloud_run_service.looker_gcp_auth_service]
}

# Binds service account to the required roles needed
resource "google_project_iam_binding" "access_services" {
  project = var.project
  role    = "roles/editor"
  members = [
    "serviceAccount:${google_service_account.looker_gcp_auth_service_account.email}"
  ]
}

resource "google_cloudbuild_trigger" "deploy_main" {
  github {
    owner = "4mile"
    name  = "looker-gcp-auth-service"
    push {
      branch = "main"
    }
  }

  build {
    timeout = "1200s"
    step {
      id   = "docker build"
      name = "gcr.io/cloud-builders/docker"
      args = ["build", "-t", local.image_name_versioned, "-t", local.image_name_latest, "."]
    }

    step {
      id   = "docker push version"
      name = "gcr.io/cloud-builders/docker"
      args = ["push", local.image_name_versioned]
    }

    step {
      id   = "docker push latest"
      name = "gcr.io/cloud-builders/docker"
      args = ["push", local.image_name_latest]
    }

    step {
      id   = "tf init"
      name = "hashicorp/terraform:1.0.0"
      dir  = "terraform"
      args = ["init"]
    }

    step {
      id   = "tf plan"
      name = "hashicorp/terraform:1.0.0"
      dir  = "terraform"
      args = ["plan", "-var", "project=$PROJECT_ID", "-var", "app_version=$SHORT_SHA"]
    }

    step {
      id   = "tf apply"
      name = "hashicorp/terraform:1.0.0"
      dir  = "terraform"
      args = ["apply", "-var", "project=$PROJECT_ID", "-var", "app_version=$SHORT_SHA", "-auto-approve"]
    }

    # note that collectstatic is run at build time in the container
  }
}