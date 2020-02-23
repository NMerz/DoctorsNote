#NOTE: This has been tested and works; however, the apigateway does not properly show as a trigger in AWS's web UI
#NOTE2: This assumes that the root Gateway and Lambda role have been set up previously (one-time setup) and their values are store in the constants below

#constants
APIID=o2lufnhpee #rest-api-id is tied to the apigateway while resource-id seems tied to the specific url extension
ROOTRESOURCEID=1kfhhu903g #gateway root should have a consistent resource id which will serve as parent for many apis
LAMBDAROLE=arn:aws:iam::363328768718:role/lambdaDefault
LANGUAGE=python3.7
DEPLOYSTAGE=Development

DEBUGFILE=/dev/null

echo -n "Please enter function name: "
read functionName
echo -n "Please enter path to zip of function code: "
read functionPath
echo -n "Please enter url extension: "
read partName
echo -n "Please enter HTTP method (i.e. GET/POST): "
read method

LAMBDAARN=$(aws lambda create-function --function-name ${functionName} --zip-file fileb://${functionPath} --runtime ${LANGUAGE} --role ${LAMBDAROLE} --handler ${functionName}.lambda_handler | head -n 3 | tail -n 1 | cut -d \" -f 4)

echo ${LAMBDAARN} > ${DEBUGFILE}

RESOURCEID=$(aws apigateway create-resource --rest-api-id ${APIID} --parent-id ${ROOTRESOURCEID} --path-part ${partName} | head -n 2 | tail -n 1 | cut -d \" -f 4)

echo ${RESOURCEID} > ${DEBUGFILE}

aws apigateway put-method --rest-api-id ${APIID} --resource-id ${RESOURCEID} --http-method ${method} --authorization-type NONE > ${DEBUGFILE}

aws apigateway put-integration --rest-api-id ${APIID} --resource-id ${RESOURCEID} --http-method ${method} --type AWS --integration-http-method POST --uri arn:aws:apigateway:us-east-2:lambda:path/2015-03-31/functions/${LAMBDAARN}/invocations > ${DEBUGFILE}

aws lambda add-permission --function-name ${functionName} --statement-id ${functionName}API --action lambda:InvokeFunction --principal apigateway.amazonaws.com > ${DEBUGFILE}

aws apigateway put-method-response  --rest-api-id ${APIID} --resource-id ${RESOURCEID} --http-method ${method} --status-code 200 > ${DEBUGFILE}

aws apigateway put-integration-response  --rest-api-id ${APIID} --resource-id ${RESOURCEID} --http-method ${method} --status-code 200 --selection-pattern "" > ${DEBUGFILE}

aws apigateway create-deployment --rest-api-id ${APIID} --stage-name ${DEPLOYSTAGE} --description "Deployment by creation script for function ${functionName}" > ${DEBUGFILE}
