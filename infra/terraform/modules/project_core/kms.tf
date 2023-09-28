resource "aws_kms_key" "project_key" {
    description             = "$(local.prefix)-kms-key"
    deletion_window_in_days = 7
    key_usage              = "ENCRYPT_DECRYPT"
    is_enabled = true
    enable_key_rotation =  false
}

resource "aws_kms_alias" "alias" {
    name = "alias/${local.prefix}"
    target_key_id = aws_kms_key.project_key.key_id
}

resource "aws_kms_key_policy" "project_key" {
    key_id = aws_kms_key.project_key.key_id
    policy = jsondecode(
        {
            "Version": "2012-10-17",
            "Id": "key-default-1",
            
        }
    )
  
}