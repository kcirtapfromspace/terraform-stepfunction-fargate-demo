{
  "Version": "2012-10-17",
  "Statement": [
      {
          "Sid": "ListObjectsInBucket",
          "Effect": "Allow",
          "Action": ["s3:ListBucket"],
          "Resource": [
            "arn:aws:s3:::${data_bucket}",
            "arn:aws:s3:::${raw_bucket}",
            "arn:aws:s3:::${staging_bucket}",
            "arn:aws:s3:::${curated_bucket}"
          ]
      },
      {
          "Sid": "AllObjectActions",
          "Effect": "Allow",
          "Action": "s3:*Object",
          "Resource": [
            "arn:aws:s3:::${data_bucket}",
            "arn:aws:s3:::${raw_bucket}",
            "arn:aws:s3:::${staging_bucket}",
            "arn:aws:s3:::${curated_bucket}",
            "arn:aws:s3:::${data_bucket}/*",
            "arn:aws:s3:::${raw_bucket}/*",
            "arn:aws:s3:::${staging_bucket}/*",
            "arn:aws:s3:::${curated_bucket}/*"

          ]
      }
  ]
}
