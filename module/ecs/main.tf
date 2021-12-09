resource "aws_ecs_cluster" "this" {
//  count = var.create_ecs ? 1 : 0

  name = "ecs-prod1"

  capacity_providers = var.capacity_providers

  dynamic "default_capacity_provider_strategy" {
    for_each = var.default_capacity_provider_strategy
    iterator = strategy

    content {
      capacity_provider = strategy.value["capacity_provider"]
      weight            = lookup(strategy.value, "weight", null)
      base              = lookup(strategy.value, "base", null)
    }
  }

  setting {
    name  = "containerInsights"
    value = var.container_insights ? "enabled" : "disabled"
  }

  tags = var.tags
}


resource "aws_iam_role" "ecsAuditTrailProd1TERole" {
  name = "ecsAuditTrailProd1TaskExecutionRole-test"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_policy" "SQS-audit-trail-prod-access-test-policy" {
  name        = "SQS-audit-trail-prod-access-test"
  description = "SQS-audit-trail-prod-access-test"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "sqs:DeleteMessage",
                "sqs:ChangeMessageVisibility",
                "sqs:ReceiveMessage",
                "sqs:SendMessage"
            ],
            "Resource": "arn:aws:sqs:us-east-1:*:*"
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "ecsAuditTrailProd1TaskExecutionRole-test-attach" {
  role       = aws_iam_role.ecsAuditTrailProd1TERole.name
  policy_arn = aws_iam_policy.SQS-audit-trail-prod-access-test-policy.arn
}


resource "aws_ecs_task_definition" "ecs-audit-trail" {
  family                = "ecs-audit-trail"

  container_definitions = file("../module/ecs/task-definitions/ecs-audit-trail-prod1-task-def-fg.json")
  task_role_arn = aws_iam_role.ecsAuditTrailProd1TERole.arn

}

resource "aws_lb_target_group" "task" {
  name        = "ecs-audit-trail-prod1-grp-1"
  protocol    = var.task_container_protocol
  port        = 3006
  target_type = "ip"
  vpc_id = var.vpc_id
  protocol_version = var.protocol_version

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_ecs_service" "ecs-audit-trail-prod1-task-def" {
  name            = "ecs-audit-trail-prod1-task-def"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.ecs-audit-trail.arn
  desired_count   = 2
  depends_on      = [aws_ecs_task_definition.ecs-audit-trail]

  dynamic "load_balancer" {
    for_each = var.associate_alb || var.associate_nlb ? var.lb_target_groups : []
    content {
      container_name   = "audit-trail"
      target_group_arn = "ecs-audit-trail"
      container_port   = 3006
    }
  }
}

resource "aws_ecs_task_definition" "ecs-audit-trail-fg" {
  family                = "ecs-audit-trail"

  container_definitions = file("../module/ecs/task-definitions/ecs-audit-trail-prod1-task-def-fg.json")
}

resource "aws_ecs_service" "ecs-audit-trail-prod1-service-2" {
  name            = "ecs-audit-trail-prod1-service-2"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.ecs-audit-trail-fg.arn
  desired_count   = 2
  depends_on      = [aws_ecs_task_definition.ecs-audit-trail-fg]


  dynamic "load_balancer" {
    for_each = var.associate_alb || var.associate_nlb ? var.lb_target_groups : []
    content {
      container_name   = "audit-trail"
      target_group_arn = "ecs-audit-trail"
      container_port   = 3006
    }
  }
}

// Endurance

resource "aws_ecs_task_definition" "ecs-endurance" {
  family                = "ecs-endurance"

  container_definitions = file("../module/ecs/task-definitions/ecs-endurance-prod1-task-def-fg.json")
}

resource "aws_ecs_service" "ecs-endurance-prod1-service-1" {
  name            = "ecs-endurance-prod1-service-1"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.ecs-endurance.arn
  desired_count   = 3
  depends_on      = [aws_ecs_task_definition.ecs-endurance]


  dynamic "load_balancer" {
    for_each = var.associate_alb || var.associate_nlb ? var.lb_target_groups : []
    content {
      container_name   = "endurance"
      target_group_arn = "endurance"
      container_port   = 3001
    }
  }
}

resource "aws_ecs_task_definition" "ecs-endurance-fg" {
  family                = "ecs-endurance-fg"

  container_definitions = file("../module/ecs/task-definitions/ecs-endurance-prod1-task-def-fg.json")
}

resource "aws_ecs_service" "ecs-endurance-prod1-service-2" {
  name            = "ecs-endurance-prod1-service-2"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.ecs-endurance-fg.arn
  desired_count   = 3
  depends_on      = [aws_ecs_task_definition.ecs-endurance-fg]


  dynamic "load_balancer" {
    for_each = var.associate_alb || var.associate_nlb ? var.lb_target_groups : []
    content {
      container_name   = "endurance"
      target_group_arn = "endurance"
      container_port   = 3001
    }
  }
}

// Exporter

resource "aws_ecs_task_definition" "ecs-exporter" {
  family                = "ecs-exporter"

  container_definitions = file("../module/ecs/task-definitions/ecs-exporter-prod1-task-def-fg.json")
}

resource "aws_ecs_service" "ecs-exporter-service-1" {
  name            = "ecs-exporter-prod1-service-1"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.ecs-exporter.arn
  desired_count   = 3
  depends_on      = [aws_ecs_task_definition.ecs-exporter]


  dynamic "load_balancer" {
    for_each = var.associate_alb || var.associate_nlb ? var.lb_target_groups : []
    content {
      container_name   = "exporter"
      target_group_arn = "ecs-exporter"
      container_port   = 3004
    }
  }
}

resource "aws_ecs_task_definition" "ecs-exporter-fg" {
  family                = "ecs-exporter-fg"

  container_definitions = file("../module/ecs/task-definitions/ecs-exporter-prod1-task-def-fg.json")
}

resource "aws_ecs_service" "ecs-exporter-prod1-service-2" {
  name            = "ecs-exporter-prod1-service-2"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.ecs-exporter-fg.arn
  desired_count   = 3
  depends_on      = [aws_ecs_task_definition.ecs-exporter-fg]


  dynamic "load_balancer" {
    for_each = var.associate_alb || var.associate_nlb ? var.lb_target_groups : []
    content {
      container_name   = "exporter"
      target_group_arn = "ecs-exporter"
      container_port   = 3004
    }
  }
}

// Importer
resource "aws_ecs_task_definition" "ecs-importer" {
  family                = "ecs-importer"

  container_definitions = file("../module/ecs/task-definitions/ecs-importer-prod1-task-def-fg.json")
}

resource "aws_ecs_service" "ecs-importer-prod1-service-1" {
  name            = "ecs-importer-prod1-service-1"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.ecs-importer.arn
  desired_count   = 3
  depends_on      = [aws_ecs_task_definition.ecs-importer]


  dynamic "load_balancer" {
    for_each = var.associate_alb || var.associate_nlb ? var.lb_target_groups : []
    content {
      container_name   = "importer"
      target_group_arn = "importer"
      container_port   = 3007
    }
  }
}

resource "aws_ecs_task_definition" "ecs-importer-fg" {
  family                = "ecs-importer-fg"

  container_definitions = file("../module/ecs/task-definitions/ecs-importer-prod1-task-def-fg.json")
}

resource "aws_ecs_service" "ecs-importer-prod1-service-2" {
  name            = "ecs-importer-prod1-service-2"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.ecs-importer-fg.arn
  desired_count   = 3
  depends_on      = [aws_ecs_task_definition.ecs-importer-fg]


  dynamic "load_balancer" {
    for_each = var.associate_alb || var.associate_nlb ? var.lb_target_groups : []
    content {
      container_name   = "importer"
      target_group_arn = "importer"
      container_port   = 3007
    }
  }
}

// Morpheus
resource "aws_ecs_task_definition" "ecs-morpheus" {
  family                = "ecs-morpheus"

  container_definitions = file("../module/ecs/task-definitions/ecs-morpheus-prod1-task-def-fg.json")
}

resource "aws_ecs_service" "ecs-morpheus-prod1-service-1" {
  name            = "ecs-morpheus-prod1-service-1"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.ecs-morpheus.arn
  desired_count   = 3
  depends_on      = [aws_ecs_task_definition.ecs-morpheus]


  dynamic "load_balancer" {
    for_each = var.associate_alb || var.associate_nlb ? var.lb_target_groups : []
    content {
      container_name   = "morpheus"
      target_group_arn = "morpheus"
      container_port   = 3002
    }
  }
}

resource "aws_ecs_task_definition" "ecs-morpheus-fg" {
  family                = "ecs-morpheus-fg"

  container_definitions = file("../module/ecs/task-definitions/ecs-morpheus-prod1-task-def-fg.json")
}

resource "aws_ecs_service" "ecs-morpheus-prod1-service-2" {
  name            = "ecs-morpheus-prod1-service-2"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.ecs-morpheus-fg.arn
  desired_count   = 3
  depends_on      = [aws_ecs_task_definition.ecs-morpheus-fg]


  dynamic "load_balancer" {
    for_each = var.associate_alb || var.associate_nlb ? var.lb_target_groups : []
    content {
      container_name   = "morpheus"
      target_group_arn = "morpheus"
      container_port   = 3002
    }
  }
}

resource "aws_ecs_service" "ecs-morpheus-prod1-service-3" {
  name            = "ecs-morpheus-prod1-service-3"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.ecs-morpheus-fg.arn
  desired_count   = 3
  depends_on      = [aws_ecs_task_definition.ecs-morpheus-fg]


  dynamic "load_balancer" {
    for_each = var.associate_alb || var.associate_nlb ? var.lb_target_groups : []
    content {
      container_name   = "morpheus"
      target_group_arn = "morpheus"
      container_port   = 3002
    }
  }
}
