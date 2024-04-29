##############################################
####### Get environment name ########
##############################################

$instanceId = Invoke-RestMethod -Uri http://169.254.169.254/latest/meta-data/instance-id
$tags = Get-EC2Tag -Filter @{Name="resource-id";Values=$instanceId}
# Filter the tags to find the one with key "ENVIRONMENT"
$environmentTag = $tags | Where-Object { $_.Key -eq "ENVIRONMENT" }
$environmentValue = $environmentTag.Value
echo $environmentValue

##############################################
####### Deployment on Web application ########
##############################################

$key = "current/$environmentValue/web/build.zip"
# Define the S3 bucket name
$bucketName = "ticket99-artifacts-bucket"

# List objects in the S3 bucket and select the latest build artifact
#$latestObject = aws s3api list-objects --bucket $bucketName --query 'reverse(sort_by(Contents, &LastModified))[0]'

# Extract the key of the latest build artifact
# $key = 

# Define the local directory where you want to download the build
$destinationDirectory = "C:\inetpub\projects\$environmentValue\web-application-automation"

# Remove the old build files if they exist
if (Test-Path $destinationDirectory) {
    Remove-Item $destinationDirectory -Recurse -Force
}

# Create the directory if it doesn't exist
New-Item -ItemType Directory -Force -Path $destinationDirectory

# Download the build artifact from S3
aws s3 cp "s3://$bucketName/$key" "$destinationDirectory\build.zip"

# Extract the contents of the build archive
Expand-Archive -Path "$destinationDirectory\build.zip" -DestinationPath $destinationDirectory -Force

# Tag Deploy build as current
aws s3 cp "$destinationDirectory\build.zip" "s3://$bucketName/current/$environmentValue/web/build.zip"

# Remove the downloaded zip file
Remove-Item "$destinationDirectory\build.zip"


##############################################
#### Deployment on Web Admin application #####
##############################################

$web_admin_key = "current/$environmentValue/web-admin/build.zip"
 
# Define the local directory where you want to download the build
$web_admin_destinationDirectory = "C:\inetpub\projects\$environmentValue\web-admin-application-automation"

# Remove the old build files if they exist
if (Test-Path $web_admin_destinationDirectory) {
    Remove-Item $web_admin_destinationDirectory -Recurse -Force
}

# Create the directory if it doesn't exist
New-Item -ItemType Directory -Force -Path $web_admin_destinationDirectory

# Download the build artifact from S3
aws s3 cp "s3://$bucketName/$web_admin_key" "$web_admin_destinationDirectory\build.zip"

# Extract the contents of the build archive
Expand-Archive -Path "$web_admin_destinationDirectory\build.zip" -DestinationPath $web_admin_destinationDirectory -Force

# Tag Deploy build as current
aws s3 cp "$destinationDirectory\build.zip" "s3://$bucketName/current/$environmentValue/web-admin/build.zip"

# Remove the downloaded zip file
Remove-Item "$web_admin_destinationDirectory\build.zip"
