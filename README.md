# Terraform script to setup scheduled ECS Fargate task managed by Step Functions

This repo demonstrates how to setup an AWS Step Function to manage an ECS Fargate Task via a scheduled event.

## How it works
![arch](docs/architecture.png "Architecture")

## Step Function Definition
![step function flow](docs/step-function-flow.png "Step Function Flow")


## Terraform Script

The Terraform script will perform the following actions:

- Create an ECS Fargate cluster and task definition to be executed
- Create an SNS topic to which failure notices will be published
- Create an AWS Step Function to:
  - execute, monitor and retry execution of the task in Fargate
  - notify an SNS topic should execution of the task fail
- Create an Amazon EventBridge rule to execute the Step Function on a defined schedule
