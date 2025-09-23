

# Create a Clumio protection group that aggregates S3 buckets with the tag "clumio:example"
resource "clumio_protection_group" "protection_group" {
  name        = "My-Clumio-Protection-Group"
  bucket_rule = jsonencode({
    "aws_tag" = {
      "$eq" = {
        "key"   = "Key1"
        "value" = "Value1"
      }
    }
  })
  object_filter {
    storage_classes = ["S3 Standard", "S3 Standard-IA"]
  }
}
# Create a Clumio protection group for Backtrack that aggregates S3 buckets with the tag "clumio:example"
resource "clumio_protection_group" "backtrack_group" {
  name        = "My-Clumio-Backtrack-Group"
  bucket_rule = jsonencode({
    "aws_tag" = {
      "$eq" = {
        "key"   = "Key1"
        "value" = "Value1"
      }
    }
  })
  object_filter {
    storage_classes = ["S3 Standard", "S3 Standard-IA"]
  }
}
# Create a Clumio policy for protection groups with a 1-day RPO and 3-month retention
resource "clumio_policy" "policy" {
  name = "S3-Gold"
  operations {
    action_setting = "immediate"
    type           = "protection_group_backup"
    slas {
      retention_duration {
        unit  = "months"
        value = 2 # Changed from 3 to 1 for testing purposes
      }
      rpo_frequency {
        unit  = "days"
        value = 1
      }
    }
    advanced_settings {
      protection_group_backup {
        backup_tier = "cold"
      }
    }
  }
}
# Create a Clumio backtrack policy
resource "clumio_policy" "s3_backtrack" {
  name              = "policy-S3-Backtrack"
  activation_status = "activated"
  operations {
    action_setting = "immediate"
    type           = "aws_s3_backtrack"
    slas {
      retention_duration {
        unit  = "months"
        value = 3
      }
      rpo_frequency {
        unit  = "days"
        value = 1
      }
    }
  }
}
# Assign the policy to the protection group
resource "clumio_policy_assignment" "assignment" {
  entity_id   = clumio_protection_group.protection_group.id
  entity_type = "protection_group"
  policy_id   = clumio_policy.policy.id

}
# Assign the backtrack policy to the protection group
resource "clumio_policy_assignment" "backtrack_assignment" {
  entity_id   = clumio_protection_group.backtrack_group.id
  entity_type = "protection_group"
  policy_id   = clumio_policy.s3_backtrack.id

}
# Create s3 bucket to be protected
resource "aws_s3_bucket" "demo" {
  bucket = "clumio-demo-bucket"
  tags = {
    "Key1" = "Value1"
  }
}