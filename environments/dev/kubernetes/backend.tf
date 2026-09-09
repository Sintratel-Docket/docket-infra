terraform {
  backend "s3" {
    key          = "docket/dev/kubernetes.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}