# Terraform Lambda Atlas

## Notes

- Will need to run:

```sh
$ aws ecr get-login-password --region <AWS region> | docker login --username AWS --password-stdin <AWS account ID>.dkr.ecr.<AWS region>.amazonaws.com
```

before running `terraform apply`
