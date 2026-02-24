resource "aws_s3_bucket" "input" {
  bucket = local.s3InputBucketName

  tags = merge({
    Name = local.s3InputBucketName
  }, local.commonTags)
}

resource "aws_s3_bucket" "output" {
  bucket = local.s3OutputBucketName

  tags = merge({
    Name = local.s3OutputBucketName
  }, local.commonTags)
}

resource "aws_s3_bucket_lifecycle_configuration" "input" {
  bucket = aws_s3_bucket.input.id

  rule {
    id     = "${var.prefix}-archive-and-delete"
    status = "Enabled"

    filter {
      prefix = ""
    }

    transition {
      days          = 30
      storage_class = "GLACIER"
    }

    expiration {
      days = 365
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "output" {
  bucket = aws_s3_bucket.output.id

  rule {
    id     = "${var.prefix}-archive-and-delete"
    status = "Enabled"

    filter {
      prefix = ""
    }

    transition {
      days          = 30
      storage_class = "GLACIER"
    }

    expiration {
      days = 365
    }
  }
}

resource "aws_s3_bucket_notification" "input_notification" {
  bucket = aws_s3_bucket.input.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.s3.arn
    events              = ["s3:ObjectCreated:*"]
  }

  depends_on = [aws_lambda_permission.allow_s3_to_call_lambda]
}