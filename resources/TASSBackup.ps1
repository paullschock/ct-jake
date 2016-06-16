<#

Built proudly by CloudTrek Engineers. 
http://cloudtrek.com.au/

.SYNOPSIS
Used to run a synchronization between TASS Web Servers and AWS' S3 inside the TASS VPC.

.DESCRIPTION
This script runs the AWS Cli using Powershell exec. TASS folders in the web instances will be synchronized across to S3 based on the parameters specidied below. This script can be run instantly or scheduled to run as a schedled task. 
AWS' S3 will provide a backup of the data utilizing lifecycle policies in conjuction with versioning. 

.NOTES
    PREREQUISITES:
    1) Download the SDK library from http://aws.amazon.com/sdkfornet/
    2) Obtain Secret and Access keys from https://aws-portal.amazon.com/gp/aws/developer/account/index.html?action=access-key
    3) Use correct folder and file listings in correct paths and locations. 
    
.EXAMPLE
    powershell.exe .\TASSBackup.ps1 -source D:\tassdoc\ -destination s3://<bucket_name>/tassdoc

.PARAMETER source         
		Specifies the folder to be backed-up.
.PARAMETER destination          
		Specifies the destination to be backed-up to.
.PARAMETER Ak
        Specifies the AWS Access key to use. 
.PARAMETER Sk
        Specifies the AWS Secret key to use.  
#>

[CmdletBinding(DefaultParametersetName="credsfromfile", supportsshouldprocess = $true) ]
param(
[string]$source,
[string]$destination,
[string]$AK,
[string]$SK
)

$synccommand = "aws s3 sync $source $destination --storage-class STANDARD_IA"
#write-output $synccommand

iex $synccommand
