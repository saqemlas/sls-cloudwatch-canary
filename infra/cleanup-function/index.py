import boto3
import cfnresponse

synthetics = boto3.client('synthetics')
lambdaClient = boto3.client('lambda')
logs = boto3.client('logs')
cloudwatch = boto3.client('cloudwatch')

def handler(event, context):
    try: 
        CanaryName = event['ResourceProperties']['CanaryName'] 
        Errors=[] 
        if event['RequestType'] == 'Delete': 
            try:
                Canarydetails = synthetics.get_canary(Name=CanaryName)
                CanaryLambdaName = Canarydetails['Canary']['EngineArn'].split(':')[-2]
                CanaryLayerName = Canarydetails['Canary']['Code']['SourceLocationArn'].split(':')[-2]
                CanaryLayerVersion = Canarydetails['Canary']['Code']['SourceLocationArn'].split(':')[-1]
            except Exception as e: 
                print('Get-Canary failed: ' + str(e)) 
                Errors.append('Get-Canary failed: ' + str(e)) 
                pass 
            try:
                lambdaClient.delete_function(FunctionName=CanaryLambdaName) 
            except Exception as e: 
                print('Deleting Canary Lambda failed: ' + str(e)) 
                Errors.append('Deleting Canary Lambda failed: ' + str(e)) 
                pass
            try:
                for x in range(int(CanaryLayerVersion)):
                    Version=x+1
                    lambdaClient.delete_layer_version(LayerName=CanaryLayerName,VersionNumber=Version)
            except Exception as e: 
                print('Deleting Canary Lambda Layer failed: ' + str(e)) 
                Errors.append('Deleting Canary Lambda Layer failed: ' + str(e)) 
                pass
            try:
                CanaryLogGroup = '/aws/lambda/' + CanaryLambdaName 
                logs.delete_log_group(logGroupName=CanaryLogGroup) 
            except Exception as e: 
                print('Deleting Canary logs failed: ' + str(e)) 
                Errors.append('Deleting Canary logs failed: ' + str(e)) 
                pass
        if Errors: 
            raise Exception(Errors) 
        cfnresponse.send(event, context, cfnresponse.SUCCESS, {'message':'Reason: Stack cleaned successfully'})
    except Exception as e: 
        print(e) 
        cfnresponse.send(event, context, cfnresponse.FAILED, {'message':'Reason: ' + str(e)})
