terraform {
  backend "s3" {
    bucket       = "disablak-course-project"
    key          = "tf-state"
    region       = "us-east-1"
    use_lockfile = true
  }
}