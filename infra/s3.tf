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

resource "aws_s3_bucket_public_access_block" "input" {
	bucket = aws_s3_bucket.input.id
	
	block_public_acls = false
	block_public_policy = false
	ignore_public_acls = false
	restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "input_public" {
	bucket = aws_s3_bucket.input.id
	policy = jsonencode({
		    Version = "2012-10-17"
		    Statement = [{
		      Sid       = "AllowPublicRead"
		      Effect    = "Allow"
		      Principal = "*"
		      Action    = ["s3:GetObject"]
		      Resource  = ["${aws_s3_bucket.input.arn}/*"]
		    }]
	})	
}

resource "aws_s3_bucket_lifecycle_configuration" "input" {
	bucket = aws_s3_bucket.input.id
	rule {
		id = "${var.prefix}-archive-and-delete"
		status = "Enabled"
		
		filter {
			prefix = ""
		}
		
		transition {
			days = 30
			storage_class = "GLACIER"
		} 

		expiration {
			days = 365
		}
	}
}

resource "aws_s3_bucket_public_access_block" "output" {
	bucket = aws_s3_bucket.output.id

	block_public_acls = false
	block_public_policy = false
	ignore_public_acls = false
	restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "output_public" {
	bucket = aws_s3_bucket.output.id
	policy = jsonencode({
		Version = "2012-10-17"
		Statement = [{
			Sid = "AllowPublicRead"
			Effect = "Allow"
			Principal = "*"
			Action = ["s3:GetObject"]
			Resource = ["${aws_s3_bucket.output.arn}/*"]
		}]
	})
}

resource "aws_s3_bucket_lifecycle_configuration" "output" {
	bucket = aws_s3_bucket.output.id
	rule {
		id = "${var.prefix}-archive-and-delete"
		status = "Enabled"

		filter {
			prefix = ""
		}

		transition {
			days = 30
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