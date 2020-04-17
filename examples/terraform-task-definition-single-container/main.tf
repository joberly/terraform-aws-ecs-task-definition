provider "aws" {
  region = "us-east-1"
}

module "mongodb" {
  source = "../.."

  family = "mongo"
  image  = "mongo:3.6"
  name   = "mongo"

  environment = [
    {
      name  = "AWS_DEFAULT_REGION"
      value = "us-east-1"
    },
  ]

  healthCheck = {
    command     = ["echo"]
    interval    = 30
    retries     = 3
    startPeriod = 0
    timeout     = 5
  }

  linuxParameters = {
    capabilities = {
      add  = ["AUDIT_CONTROL", "AUDIT_WRITE"]
      drop = ["SYS_RAWIO", "SYS_TIME"]
    }

    devices = [
      {
        containerPath = "/dev/disk0"
        hostPath      = "/dev/disk0"
        permissions   = ["read"]
      },
    ]

    initProcessEnabled = true
    sharedMemorySize   = 512

    tmpfs = [
      {
        containerPath = "/tmp"
        mountOptions  = ["defaults"]
        size          = 512
      },
    ]
  }

  logConfiguration = {
    logDriver = "awslogs"
    options = {
      awslogs-group  = "awslogs-mongodb"
      awslogs-region = "us-east-1"
    }
  }

  memoryReservation = 512

  mountPoints = [
    {
      containerPath = "/dev/disk0"
      readOnly      = true
      sourceVolume  = "data"
    },
  ]

  portMappings = [
    {
      containerPort = 8080
      hostPort      = 0
      protocol      = "tcp"
    },
  ]

  register_task_definition = false

  secrets = [
    {
      name      = "EXAMPLE_PASSWORD"
      valueFrom = "password-parameter"
    },
    {
      name      = "EXAMPLE_AUTH"
      valueFrom = "arn:aws:ssm:region:aws_account_id:parameter/auth-parameter"
    }
  ]

  ulimits = [
    {
      hardLimit = 1024
      name      = "cpu"
      softLimit = 1024
    },
  ]

  user = "root"

  workingDirectory = "~/project"
}
