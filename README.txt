How to run the Main Terraform Script file so that it will configure and create all the things?

Step 1: Extract the zip and you will find 2 folders inside it.

Step 2: Go inside the main folder and run the following commands:
        terraform init (To initialze the terraform module)
        terraform validate (To check if, there is any syntax error present in the code)
        terraform plan (To see the things it will affect or configure)
        terraform apply -auto-approve (To run the main terraform script)

Step 3: To Destroy the created Infrastructure

        terraform destroy (To delete the entire Infrastructure)

How to add a new module to the present main Terraform Script?

Add the below line of code in the main script according to the sequence

module "<folder_name_present_inside_module_folder>" {
    source = "relative_path_of_the_module"
}

For example to add the Cloud Front module in the main script 

module "cloudfront" {
    source = "../module/cloudfront"
}
