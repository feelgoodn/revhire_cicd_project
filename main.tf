resource "aws_s3_bucket" "mybucket" {
  bucket = var.bucketname

}

resource "aws_s3_bucket_ownership_controls" "example" {
  bucket = aws_s3_bucket.mybucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}


resource "aws_s3_bucket_public_access_block" "example" {
  bucket = aws_s3_bucket.mybucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}



resource "aws_s3_bucket_acl" "example" {
  depends_on = [
    aws_s3_bucket_ownership_controls.example,
    aws_s3_bucket_public_access_block.example,
  ]

  bucket = aws_s3_bucket.mybucket.id
  acl    = "private"
}

# Bucket policy to allow public read access to objects
resource "aws_s3_bucket_policy" "mybucket_policy" {
  bucket = aws_s3_bucket.mybucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.mybucket.arn}/*"
      }
    ]
  })
}


locals {
  mimetypes = {
    html  = "text/html"
    js    = "application/javascript"
    css   = "text/css"
    json  = "application/json"
    png   = "image/png"
    jpg   = "image/jpeg"
    gif   = "image/gif"
    svg   = "image/svg+xml"
    woff  = "font/woff"
    ttf   = "font/ttf"
    otf   = "font/otf"
    woff2 = "font/woff2"
  }
}



resource "aws_s3_object" "files" {
  for_each     = fileset("dist/", "**/*")
  bucket       = aws_s3_bucket.mybucket.bucket
  key          = each.value
  source       = "dist/${each.value}"
  acl          = "public-read"
  content_type = lookup(local.mimetypes, regex("[^.]+$", each.value), "application/octet-stream")

}

resource "aws_s3_bucket_website_configuration" "website" {
  bucket = aws_s3_bucket.mybucket.id
  index_document {
    suffix = "index.html"
  }
}







