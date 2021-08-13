1. Type "terraform apply --targer module.ecs.aws_ecr_repository.this". It will create ECR resource.
2. Type "packer build ." to build and load image to your repository. Ensure that you added your AWS access and secret keys and also repository address.
3. Type "terraform apply" to apply other changes that require image.