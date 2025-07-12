resource "aws_dynamodb_table" "dynamodb_table" {
    name         = "${var.project}-dynamodb-table"
    billing_mode = "PAY_PER_REQUEST"
    hash_key     = "LockID"
    
    attribute {
        name = "LockID"
        type = "S"
    }
    
    tags = {
        Project = var.project
    }
  
}