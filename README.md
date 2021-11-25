# Cloudwatch Synthetic Canary

## Info 

This handles deployment for a Cloudwatch Synthetic Canary. The stack consists of an S3 bucket for the zip file of the canary code, Lambda function to execute canary code, Lambda layer for nodejs dependency management (puppeteer), Cloudwatch alarm for failed executions, Cloudwatch logs for runtime logging, Xray for distributed system tracing, and appropriate Iam roles.

Canaries offer programmatic access to a headless Google Chrome Browser. Canaries are scripts that monitor your endpoints and APIs from the outside-in. Canaries help you check the availability and latency of your web services and troubleshoot anomalies by investigating load time data, screenshots of the UI, logs, and metrics. You can set up a canary to run continuously or just once.

- [AWS Documentation: Using synthetic monitoring](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/CloudWatch_Synthetics_Canaries.html)
- [AWS Documentation: Cloudformation AWS::Synthetics::Canary](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-resource-synthetics-canary.html)


## Notes
Cloudwatch Synthetic Canaries still has some issues...

- canary cloudformation resource requires the s3 bucket with zip code file to be created before the stack is created. The ArtifactS3Location field checks the artifact is in location at deployment. Therefore deployment follows the following process...

    1. Zip & upload bundled synthetic canary code to s3 bucket (also zip & upload clean-function code)
    2. Deploy cloudformation stack (w/ synthetic canary & cleanup-stack) pointing to zip file in s3 buckets

- removal of stack does NOT remove all resources ie function, layer, log, etc resources as they are AUTO-GENERATED hence their 'cwsyn-' prefix. *A custom cloudformation resource (infra/cleaup-stack.yml) and lambda function (infra/cleaup-stack/clean-function/index.py) have been created to remove resources.*

- canary lambda function points to a zip file of the canary code in an s3 bucket, if the file name does not change with code changes, the function runtime will not update. hence using timestamp.js to version each deployment with a timestamp.


## Architecture

<p align="center">
  <img src="/architecture-diagram.drawio.svg" />
</p>


## Usage 

### Credentials:

```bash
export AWS_PROFILE=<profile_name>
```

### Deploy:

```bash
serverless deploy
```

### Remove:

```bash
serverless remove
```

