
import boto3
region = 'ap-south-1'
instances = ['i-06525acfd600f9a35']
ec2 = boto3.client('ec2',region_name=region)

def lambda_handler(event,context):
    ec2.stop_instances(InstanceIds=instances)
    print('stopped your instances: ' + str(instances))
    
    # ec2.start_instances(InstanceIds=instances)
    # print('Started your instances: ' + str(instances))
