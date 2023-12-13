# CLCM3504-Final-Exam

![GitHub Workflow Status (with event)](https://img.shields.io/github/actions/workflow/status/s-tanthikun802/CLCM3504-Final-Exam/main.yml)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

## Table of Contents

- [CLCM3504-Final-Exam](#clcm3504-final-exam)
  - [Table of Contents](#table-of-contents)
  - [Instructions](#instructions)
    - [How to set up the project](#how-to-set-up-the-project)
      - [Set up using Apache server](#set-up-using-apache-server)
      - [Set up using Docker](#set-up-using-docker)
    - [Deploy the website using CI/CD, Terraform, and Docker](#deploy-the-website-using-cicd-terraform-and-docker)
  - [How to ensure automatic deployment](#how-to-ensure-automatic-deployment)
  - [Challenge faced during the process and overcome](#challenge-faced-during-the-process-and-overcome)
  - [License](#license)

## Instructions

### How to set up the project
#### Set up using Apache server

1. Install Apache server (XAMPP, WAMP, MAMP)
   [How to install Apache server on Windows](https://httpd.apache.org/docs/2.4/platform/windows.html)
   
2. Clone repository
    ```bash
    git clone https://github.com/s-tanthikun802/CLCM3504-Final-Exam.git
    
    cd CLCM3504-Final-Exam

    export WORKING_DIR=$(pwd)
   ```
3. Copy website file into `/htdocs`
   ```bash
   cp $WORKING_DIR/website <path_of_htdocs>
   ```

4. Open your web browser and navigate to `localhost`

#### Set up using Docker

1. Start your Docker engine on your local machine

2. Pull Docker from Docker Hub
   ```bash
   docker pull stanthikun802/clcm3504-sorawat-final:latest
   ```

3. Run Docker image
   ```bash
   docker run -d --name clcm3504-sorawat-final -p 80:80 stanthikun802/clcm3504-sorawat-final:latest
   ```

4. Open your web browser and navigate to `localhost`


### Deploy the website using CI/CD, Terraform, and Docker
1. Set up AWS Account and EC2 instance
   - Create an AWS account if you don't have one.
   - Install AWS CLI in your local machine [Install or update the latest version of the AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
   - Set up AWS Id and secret
        ```bash
        aws configure
        ```
    - Parse your AWS Id and secret (including token, if applicable)
2. Lanch Amazon EC2 instance by Terraform
    - Install Terraform in your local machine [Install Terraform
](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)
    - Navigate to project folder
   - Init an Amazon EC2 instance by using Terraform
        ```bash
        terraform init
        ```
        ```bash
        terraform plan
        ```
        ```bash
        terraform apply
        ```
3. Create new GitHub repository (if not exist)
4. Set up GitHub repository secrets
   - `DOCKERHUB_USERNAME` - Docker Hub username
   - `DOCKERHUB_ACCESS_TOKEN` - Docker access token
   - `HOST_DNS` - EC2 instance public DNS
   - `USERNAME` - EC2 instnace username
   - `TARGET_DIR` - Target directory
   - `EC2_SSH_KEY` - EC2 instance private key
5. Set up GitHub Actions workflow
   ```yaml
   name: Build & Deploy
    on:
    push:
        branches:
        - main
    jobs:
    build_and_push_docker_image:
        runs-on: ubuntu-latest
        name: Build & Push Docker Image

        steps:
        - name: Checkout code
            uses: actions/checkout@v3

        - name: Build the Docker image
            run: |
            docker build . \
                --file Dockerfile \
                --tag <your_docker_hub_user>/<your_docker_hub_repository>:latest

        - name: Log in to Docker Hub
            uses: docker/login-action@v1
            with:
            username: ${{ secrets.DOCKERHUB_USERNAME }}
            password: ${{ secrets.DOCKERHUB_ACCESS_TOKEN }}

        - name: Push Docker image to Docker Hub
            run: |
            docker push <your_docker_hub_user>/<your_docker_hub_repository>:latest

    deploy:
        name: Deploy to EC2
        runs-on: ubuntu-latest
        needs: build_and_push_docker_image

        steps:
        - name: Checkout the files
            uses: actions/checkout@v2

        - name: Deploy to Server 1
            uses: easingthemes/ssh-deploy@main
            with:
            SSH_PRIVATE_KEY: ${{ secrets.EC2_SSH_KEY }}
            REMOTE_HOST: ${{ secrets.HOST_DNS }}
            REMOTE_USER: ${{ secrets.USERNAME }}
            TARGET: ${{ secrets.TARGET_DIR }}

        - name: Executing remote ssh commands using ssh key
            uses: appleboy/ssh-action@master
            with:
            host: ${{ secrets.HOST_DNS }}
            username: ${{ secrets.USERNAME }}
            key: ${{ secrets.EC2_SSH_KEY }}
            script: |
                docker pull <your_docker_hub_user>/<your_docker_hub_repository>:latest
                docker stop <container_name> && docker rm <container_name>
                docker run -d -p 80:80 --name <container_name> <your_docker_hub_user>/<your_docker_hub_repository>:latest
                docker image prune -f
   ```

## How to ensure automatic deployment
For every change that is pushed to the main branch, it will automatically build the Docker image and then push the image to the Docker repository (Docker Hub).

After that, if the first stage runs successfully, the GitHub Actions will access to EC2 instance to pull that Docker image and try to stop and remove the old version of the Docker container. Next, it will start a new container by using the new Docker image version that was pulled before.

To ensure that this process won't have any error or mistake, I would like to make sure that we have space left for every time that pull a new image so I decided to remove the unused image by using the `docker image prune -f`

## Challenge faced during the process and overcome
1. The EC2 instance doesn't have any space left for pulling the new image
   - Using the `docker image prune -f`
2. Understanding GitHub Actions components such as stage, steps, run, script, needs, etc.
   - Take time and search the meaning of each component such as I want to have the dependency for each stage like `depends_on` in docker-compose and found that GitHub Actions use `needs`
3. The application is not run on the target path
   - Unknown about `-p` flag -> try to understand it

## License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.