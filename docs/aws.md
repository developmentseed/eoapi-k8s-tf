### Terraform Installation
0. cd terraform/aws

1. install `tfenv` to manage multiple versions: [https://github.com/tfutils/tfenv](https://github.com/tfutils/tfenv)

2. our `main.tf` file has a `required_version = "1.7.4"` so install that:
   ```bash
   $ tfenv list
    1.1.5
    1.1.4
   ```

3. `tfenv install 1.7.4`

4. `tfenv use 1.7.4`

###  Terraform Init and Workspaces

0. choose a name for your project that you'll use for the TF `workspace` name, variable filename and backend-config name. 
for the purposes of the rest of this walkthrough we'll call it `example-dev`  

1. copy the `backend-configs/example.tfbackend` to `backend-cofnigs/example-dev.tfbackend`. this is the file that sets
up where your terraform state will be used in s3

2. in that file change the `bucket` value to be a unique bucket name. Leave the `key = terraform` as is. Choose a `region` for your bucket

3. create the s3 bucket manually or via `aws-cli` for that region and bucket name

4. initialize terraform and the state: `AWS_PROFILE=(profile-name) terraform init -reconfigure -backend-config backend-configs/example-dev.tfbackend `

5. finally, create a workspace `AWS_PROFILE=(profile-name) terraform workspace create example-dev`


### Terraform Plan and Apply

0. cp `vars/example.tfvars` to your `vars/example-dev.tfvars` and make the changes you will need

1. `AWS_PROFILE=(profile-name) terraform plan --var-file=vars/example-dev.tfvars`

3. `AWS_PRFILE=(profile-name) terraform apply --var-file=vars/example-dev.tfvars`
