#!/bin/bash
#
# ICGC PDC Script Manifest
#
# Script to download ICGC files in PDC. Generated from https://dcc.icgc.org/repositories.
# Requires AWS CLI to be installed:
#
#   https://aws.amazon.com/cli/
#
# For information on the PDC, please see:
#
#   https://bionimbus-pdc.opensciencedatacloud.org/
#
# Script assumes a valid ~/.aws/credentials file with a valid `pdc` profile:
# 
#   $ cat ~/.aws/credentials
#   [pdc]
#   aws_access_key_id=<your key id here>
#   aws_secret_access_key=<your secret here>
#

aws --profile pdc --endpoint-url https://bionimbus-objstore-cs.opensciencedatacloud.org s3 cp s3://pcawg-tcga-gbm-us/83bc9e4c-682a-5ac2-a47b-f192f7112d53 .
aws --profile pdc --endpoint-url https://bionimbus-objstore-cs.opensciencedatacloud.org s3 cp s3://pcawg-tcga-gbm-us/fcb9a961-b6a1-53ec-9423-119ab1b83d6f .
aws --profile pdc --endpoint-url https://bionimbus-objstore-cs.opensciencedatacloud.org s3 cp s3://pcawg-tcga-gbm-us/47d4aa50-2120-5f9c-830d-096b40ccfb76 .
aws --profile pdc --endpoint-url https://bionimbus-objstore-cs.opensciencedatacloud.org s3 cp s3://pcawg-tcga-gbm-us/40e76065-b4e2-5118-a656-b2721e382bfe .
aws --profile pdc --endpoint-url https://bionimbus-objstore-cs.opensciencedatacloud.org s3 cp s3://pcawg-tcga-gbm-us/ef82c426-c453-576e-a943-e4859cf2b613 .
aws --profile pdc --endpoint-url https://bionimbus-objstore-cs.opensciencedatacloud.org s3 cp s3://pcawg-tcga-gbm-us/dacd899a-8397-5093-8393-9caec379fc74 .
