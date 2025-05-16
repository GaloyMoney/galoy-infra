
locals {
  inception_sa_name = "${local.name_prefix}-inception-tf"
}

resource "aws_iam_user" "inception" {
  name = local.inception_sa_name

  tags = {
    Name               = local.inception_sa_name
    TerraformBootstrap = "true"
  }
}

resource "aws_iam_policy" "bootstrap" {
  name        = "${local.name_prefix}-bootstrap"
  description = "Bootstrap policy mapping GCP inception role permissions to AWS"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "iam:PassRole",                     
          "iam:CreateRole",                   
          "iam:GetRole",                      
          "iam:GetRolePolicy",                
          "iam:PutRolePolicy",               
          "iam:DeleteRole",                   

          "iam:CreateRole",                  
          "iam:GetRole",                      
          "iam:UpdateRole",                 
          "iam:DeleteRole",                  

          "s3:ListAllMyBuckets",              
          "s3:ListBucket",                    
          "s3:GetBucketPolicy",               
          
          "s3:CreateBucket",                  
          "s3:DeleteBucket",                  
          "s3:PutBucketPolicy",               
          
          "organizations:DescribeAccount",    

          "ec2:DescribeAddresses",            
          "ec2:ReleaseAddress",              
          "ec2:ReleaseAddress",               

          "ec2:DescribeIamInstanceProfileAssociations",  
          "ec2:DescribeInstances",                      
          "ec2:DescribeTags",                           
          "ec2:TerminateInstances",                     
          "ec2:DetachNetworkInterface",                 
          "ec2:DeleteNetworkInterface",                 

          "ec2:DescribeVpcs",                  
          "ec2:DeleteVpc",                     
          "ec2:CreateVpc",                     
          
          "ec2:DescribeSubnets",               
          "ec2:DeleteSubnet",                 
          "ec2:CreateSubnet",                  

          
          "ec2:DeleteSecurityGroup",           
          "ec2:RevokeSecurityGroupIngress",   
          "ec2:RevokeSecurityGroupEgress",     
          "organizations:AttachPolicy",        
          "organizations:DetachPolicy",        
          "organizations:CreatePolicy",        
          "organizations:DeletePolicy",        

          "iam:Get*",
          "iam:List*",
          "ec2:Describe*",
          "s3:ListBucket"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_user_policy_attachment" "inception_attach" {
  user       = aws_iam_user.inception.name
  policy_arn = aws_iam_policy.bootstrap.arn
}
