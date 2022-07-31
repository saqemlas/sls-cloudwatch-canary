#!/usr/bin/env bash

while :; do
  case "${1:-}" in
  --version)
    export VERSION=${2}
    shift
    ;;
  --bucket)
    export BUCKET_NAME=${2}
    shift
    ;;
  --region)
    export AWS_REGION=${2}
    shift
    ;;
  *) break ;;
  esac
  shift
done

die() {
  echo "$*" 1>&2
  exit 1
}

[[ -z "${BUCKET_NAME-}" ]] && die "bucket name is required"
[[ -z "${AWS_REGION-}" ]] && die "region name is required"

# Stop aws cli output
export AWS_PAGER=""

# Check if s3 bucket exists
if [[ -z $(aws s3api head-bucket --bucket "$BUCKET_NAME" 2>&1) ]]; then
  echo "$BUCKET_NAME already exists! Skipping create bucket..."
else 
  echo "Creating $BUCKET_NAME bucket..."
  # Create S3 bucket for zip
  aws s3api create-bucket \
    --bucket "$BUCKET_NAME" \
    --region "$AWS_REGION" \
    --create-bucket-configuration LocationConstraint="$AWS_REGION" \
    --acl private
  # Update S3 bucket access policy
  aws s3api put-public-access-block \
    --bucket "$BUCKET_NAME" \
    --public-access-block-configuration "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true"
fi

# Check if VERSION is set
if [[ -z "${VERSION-}" ]]; then
  echo "VERSION not set! Copying cleanup function zip to $BUCKET_NAME..."
  cd infra
  # Copy zip to S3 bucket
  aws s3 cp cleanup-function.zip "s3://$BUCKET_NAME"
else
  echo "Version $VERSION set! Copying canary function zip to $BUCKET_NAME..."
  cd canary
  # Copy zip to S3 bucket
  aws s3 cp canary-$VERSION.zip "s3://$BUCKET_NAME"
fi
