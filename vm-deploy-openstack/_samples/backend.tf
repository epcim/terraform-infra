#Define Remote State Local backend
data "terraform_remote_state" "remote_state" {
    backend = "local"
    config {
        path = "terraform.tfstate"
    }
}
The remote state backend is a location where you are going to store the results of the Terraform run. In this case,  it will be in a local file named terraform.state.
