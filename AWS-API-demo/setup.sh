#!/bin/bash

# DISCLAIMER: I wouldn't hardcode stuff like this in a production environment but this is just a demo...
# This script is not supposed to be reusable, nor is it supposed to be run multiple times.
# Again, I just thought: how can I show I know what I'm doing with API gateway?
# So I made an app... a very simple but working app you can try out yourself.
# P.S. echoes are here so I don't go crazy while the script is running.

set -Eeuo pipefail

export AWS_PROFILE=quazr_test_admin
export AWS_REGION=eu-central-1

echo "Setting up AWS API demo environment..."
AWS_ACCOUNT_ID=$(aws sts get-caller-identity \
    --query Account \
    --output text
)

echo -e "Using AWS account ID: $AWS_ACCOUNT_ID\nRegion: $AWS_REGION"
read -p "Type 'yes' to proceed : " PROMPT
if [[ "$PROMPT" != "yes" ]]; then
    exit
fi

# API Gateway and Lambda setup
echo "Setting up IAM role for API Lambda function..."
API_LAMBDA_ROLE_ARN=$(aws iam create-role \
    --role-name api-demo-api-lambda-role \
    --assume-role-policy-document file://IAM/trust-policy.json \
    --query 'Role.Arn' \
    --output text
)

echo "Attaching 'AWSLambdaBasicExecutionRole' policy to the role..."
aws iam attach-role-policy \
    --role-name api-demo-api-lambda-role \
    --policy-arn arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole \
    > /dev/null

echo "Creating API Lambda function..."
7z a -tzip function.zip lambda.py
API_LAMBDA_ARN=""
for attempt in {1..5}; do
    sleep 5 # It's never ready on the first try!
    if API_LAMBDA_ARN="$(aws lambda create-function \
        --function-name api-demo-function \
        --zip-file fileb://function.zip \
        --role "$API_LAMBDA_ROLE_ARN" \
        --handler lambda.handler \
        --runtime python3.12 \
        --query 'FunctionArn' \
        --output text
    )"; then
        break
    fi

    echo "! DO NOT PANIC! IAM role is not ready yet; retrying in 5 seconds..." >&2
done

# Since we're doing HTTP API here, I could just create it with --target "$API_LAMBDA_ARN"
# but that would also create $default route and $default integration.
# Nothing wrong with it, but why not do it ourselves?
# It's just a good practice!
echo "Creating API Gateway HTTP API..."
API_ID=$(aws apigatewayv2 create-api \
    --name api-demo \
    --protocol-type HTTP \
    --cors-configuration '{
        "AllowOrigins": [
            "http://localhost:5173"
        ],
        "AllowMethods": [
            "GET",
            "OPTIONS"
        ],
        "AllowHeaders": [
            "Authorization",
            "Content-Type",
            "X-Amz-Date",
            "X-Api-Key"
        ],
        "ExposeHeaders": [
            "Content-Type"
        ],
        "MaxAge": 3600,
        "AllowCredentials": false
    }' \
    --query 'ApiId' \
    --output text
)

echo "Adding permission for API Gateway to invoke the Lambda function..."
aws lambda add-permission \
    --function-name api-demo-function \
    --statement-id apigateway-invoke \
    --action lambda:InvokeFunction \
    --principal apigateway.amazonaws.com \
    --source-arn "arn:aws:execute-api:${AWS_REGION}:${AWS_ACCOUNT_ID}:${API_ID}/*" \
    > /dev/null

echo "Creating integration between API Gateway and Lambda function..."
INTEGRATION_URI="arn:aws:apigateway:${AWS_REGION}:lambda:path/2015-03-31/functions/${API_LAMBDA_ARN}/invocations"
INTEGRATION_ID=$(aws apigatewayv2 create-integration \
    --api-id "$API_ID" \
    --integration-type AWS_PROXY \
    --integration-uri "$INTEGRATION_URI" \
    --payload-format-version 2.0 \
    --query 'IntegrationId' \
    --output text
)

# Cognito User Pool and App Client setup (with Lambda function for PreTokenGeneration trigger)
echo "Setting up IAM role for Cognito Lambda function..."
COGNITO_LAMBDA_ROLE_ARN=$(aws iam create-role \
    --role-name api-demo-cognito-lambda-role \
    --assume-role-policy-document file://IAM/trust-policy.json \
    --query 'Role.Arn' \
    --output text
)

echo "Attaching 'AWSLambdaBasicExecutionRole' policy to the role..."
aws iam attach-role-policy \
    --role-name api-demo-cognito-lambda-role \
    --policy-arn arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole \
    > /dev/null

echo "Creating Cognito Lambda function..."
7z a -tzip function.zip cognito.py
COGNITO_LAMBDA_ARN=""
for attempt in {1..5}; do
    sleep 5 # It's never ready on the first try!
    if COGNITO_LAMBDA_ARN="$(aws lambda create-function \
        --function-name cognito-token-generator \
        --role "$COGNITO_LAMBDA_ROLE_ARN" \
        --zip-file fileb://function.zip \
        --handler cognito.handler \
        --runtime python3.12 \
        --query 'FunctionArn' \
        --output text
    )"; then
        break
    fi

    echo "! DO NOT PANIC! IAM role is not ready yet; retrying in 5 seconds..." >&2
done

echo "Creating Cognito User Pool..."
LAMBDA_CONFIG="$(printf '{"PreTokenGenerationConfig":{"LambdaArn":"%s","LambdaVersion":"V2_0"}}' "$COGNITO_LAMBDA_ARN")"
USER_POOL_ID=$(aws cognito-idp create-user-pool \
    --pool-name "api-demo-users" \
    --username-attributes email \
    --auto-verified-attributes email \
    --lambda-config "$LAMBDA_CONFIG" \
    --policies '{
        "PasswordPolicy": {
            "MinimumLength": 8,
            "RequireUppercase": true,
            "RequireLowercase": true,
            "RequireNumbers": true,
            "RequireSymbols": true,
            "TemporaryPasswordValidityDays": 7
        }
    }' \
    --query 'UserPool.Id' \
    --output text
)

aws lambda add-permission \
    --function-name cognito-token-generator \
    --statement-id cognito-invoke \
    --action lambda:InvokeFunction \
    --principal cognito-idp.amazonaws.com \
    --source-arn "arn:aws:cognito-idp:${AWS_REGION}:${AWS_ACCOUNT_ID}:userpool/${USER_POOL_ID}" \
    > /dev/null

# Resource server, groups, users, etc...
echo "Creating resource server and scopes for the API..."
RESOURCE_SERVER_ID=$(aws cognito-idp create-resource-server \
    --name "Demo API resource server" \
    --user-pool-id "$USER_POOL_ID" \
    --identifier "api-demo" \
    --scopes '[
        {
            "ScopeName": "user.read",
            "ScopeDescription": "Read user resources"
        },
        {
            "ScopeName": "user.write",
            "ScopeDescription": "Create and modify user resources"
        },
        {
            "ScopeName": "admin",
            "ScopeDescription": "Access administrative resources"
        }
    ]' \
    --query 'ResourceServer.Identifier' \
    --output text
)

echo "Creating Cognito User Pool Client..."
CALLBACK_URL="http://localhost:5173/callback"
APP_CLIENT_ID=$(aws cognito-idp create-user-pool-client \
    --user-pool-id "$USER_POOL_ID" \
    --client-name "demo-api-client" \
    --no-generate-secret \
    --explicit-auth-flows \
        ALLOW_USER_SRP_AUTH \
        ALLOW_REFRESH_TOKEN_AUTH \
    --allowed-o-auth-flows-user-pool-client \
    --allowed-o-auth-flows code \
    --allowed-o-auth-scopes \
        "$RESOURCE_SERVER_ID/user.read" \
        "$RESOURCE_SERVER_ID/user.write" \
        "$RESOURCE_SERVER_ID/admin" \
        "openid" \
        "email" \
    --callback-urls "$CALLBACK_URL" \
    --logout-urls "$CALLBACK_URL" \
    --supported-identity-providers COGNITO \
    --query 'UserPoolClient.ClientId' \
    --output text
)

echo "Creating JWT authorizer for API Gateway..."
COGNITO_ISSUER="https://cognito-idp.${AWS_REGION}.amazonaws.com/${USER_POOL_ID}"
AUTHORIZER_ID=$(aws apigatewayv2 create-authorizer \
    --api-id "$API_ID" \
    --authorizer-type JWT \
    --name cognito-jwt \
    --identity-source '$request.header.Authorization' \
    --jwt-configuration Audience="$APP_CLIENT_ID",Issuer="$COGNITO_ISSUER" \
    --query 'AuthorizerId' \
    --output text
)

echo "Creating '/guest' route for the API..."
GUEST_ROUTE_ID=$(aws apigatewayv2 create-route \
    --api-id "$API_ID" \
    --route-key "GET /guest" \
    --authorization-type NONE \
    --target "integrations/$INTEGRATION_ID" \
    --query 'RouteId' \
    --output text
)

echo "Creating '/user' route for the API..."
USER_ROUTE_ID=$(aws apigatewayv2 create-route \
    --api-id "$API_ID" \
    --route-key "GET /user" \
    --authorization-type JWT \
    --authorizer-id "$AUTHORIZER_ID" \
    --authorization-scopes "$RESOURCE_SERVER_ID/user.read" \
    --target "integrations/$INTEGRATION_ID" \
    --query 'RouteId' \
    --output text
)

echo "Creating '/admin' route for the API..."
ADMIN_ROUTE_ID=$(aws apigatewayv2 create-route \
    --api-id "$API_ID" \
    --route-key "GET /admin" \
    --authorization-type JWT \
    --authorizer-id "$AUTHORIZER_ID" \
    --authorization-scopes "$RESOURCE_SERVER_ID/admin" \
    --target "integrations/$INTEGRATION_ID" \
    --query 'RouteId' \
    --output text
)

# I don't want undefined routes reaching the lambda function and increasing the costs (and the attack surface)
# So, anything undefined will be blocked by the API gateway unless it's the admin accessing the route.
# If we were working with REST API, I could've made a MOCK integration for the $default route,
# but it is not available for HTTP API and this is the next best thing we can do here.
echo "Creating secure 'GET /{proxy+}' route for the API..."
aws apigatewayv2 create-route \
    --api-id "$API_ID" \
    --route-key "GET /{proxy+}" \
    --authorization-type JWT \
    --authorizer-id "$AUTHORIZER_ID" \
    --authorization-scopes "$RESOURCE_SERVER_ID/admin" \
    --target "integrations/$INTEGRATION_ID" \
    > /dev/null

echo "Creating secure 'PUT /{proxy+}' route for the API..."
aws apigatewayv2 create-route \
    --api-id "$API_ID" \
    --route-key "PUT /{proxy+}" \
    --authorization-type JWT \
    --authorizer-id "$AUTHORIZER_ID" \
    --authorization-scopes "$RESOURCE_SERVER_ID/admin" \
    --target "integrations/$INTEGRATION_ID" \
    > /dev/null

echo "Creating secure 'POST /{proxy+}' route for the API..."
aws apigatewayv2 create-route \
    --api-id "$API_ID" \
    --route-key "POST /{proxy+}" \
    --authorization-type JWT \
    --authorizer-id "$AUTHORIZER_ID" \
    --authorization-scopes "$RESOURCE_SERVER_ID/admin" \
    --target "integrations/$INTEGRATION_ID" \
    > /dev/null

echo "Creating secure 'DELETE /{proxy+}' route for the API..."
aws apigatewayv2 create-route \
    --api-id "$API_ID" \
    --route-key "DELETE /{proxy+}" \
    --authorization-type JWT \
    --authorizer-id "$AUTHORIZER_ID" \
    --authorization-scopes "$RESOURCE_SERVER_ID/admin" \
    --target "integrations/$INTEGRATION_ID" \
    > /dev/null

# User groups, users, etc...
echo "Creating user pool domain for Cognito..."
API_DOMAIN_PREFIX="demo-api-auth-$(date +%s)"
aws cognito-idp create-user-pool-domain \
    --user-pool-id "$USER_POOL_ID" \
    --domain "$API_DOMAIN_PREFIX" \
    > /dev/null

echo "Creating 'user' group..."
aws cognito-idp create-group \
    --user-pool-id "$USER_POOL_ID" \
    --group-name "user" \
    --description "User group with read and write permissions" \
    > /dev/null

echo "Creating 'admin' group..."
aws cognito-idp create-group \
    --user-pool-id "$USER_POOL_ID" \
    --group-name "admin" \
    --description "Admin group with full permissions" \
    > /dev/null

echo "Creating demo 'user' in Cognito User Pool..."
aws cognito-idp admin-create-user \
    --user-pool-id "$USER_POOL_ID" \
    --username "user@demo-api.com" \
    --user-attributes \
        Name=email,Value=user@demo-api.com \
        Name=email_verified,Value=true \
    --temporary-password 'userPassword123@ChangeMe' \
    > /dev/null

echo "Adding 'user@demo-api.com' to 'user' group..."
aws cognito-idp admin-add-user-to-group \
    --user-pool-id "$USER_POOL_ID" \
    --username "user@demo-api.com" \
    --group-name "user" \
    > /dev/null

echo "Creating demo 'admin' in Cognito User Pool..."
aws cognito-idp admin-create-user \
    --user-pool-id "$USER_POOL_ID" \
    --username "admin@demo-api.com" \
    --user-attributes \
        Name=email,Value=admin@demo-api.com \
        Name=email_verified,Value=true \
    --temporary-password 'adminPassword123@ChangeMe' \
    > /dev/null

echo "Adding 'admin@demo-api.com' to 'admin' group..."
aws cognito-idp admin-add-user-to-group \
    --user-pool-id "$USER_POOL_ID" \
    --username "admin@demo-api.com" \
    --group-name "admin" \
    > /dev/null

# Deploy the API
echo "Creating default stage for the API..."
aws apigatewayv2 create-stage \
    --api-id "$API_ID" \
    --stage-name '$default' \
    --auto-deploy \
    > /dev/null

API_GATEWAY_URL="https://${API_ID}.execute-api.${AWS_REGION}.amazonaws.com"
AUTHORITY_URL="https://cognito-idp.${AWS_REGION}.amazonaws.com/${USER_POOL_ID}"
USER_POOL_DOMAIN_URL="https://${API_DOMAIN_PREFIX}.auth.${AWS_REGION}.amazoncognito.com"

cat > ./Frontend/.env << EOF
NG_APP_COGNITO_CALLBACK_URL=http://localhost:5173/callback
NG_APP_COGNITO_LOGOUT_URL=http://localhost:5173/callback
NG_APP_API_URL=$API_GATEWAY_URL
NG_APP_COGNITO_DOMAIN=$USER_POOL_DOMAIN_URL
NG_APP_AUTHORITY_URL=$AUTHORITY_URL
NG_APP_COGNITO_CLIENT_ID=$APP_CLIENT_ID
EOF

echo "Setup complete successfully!"

echo "run npm install in the Frontend folder to install dependencies, then run 'npm start' to start the frontend application (port 5173)."
echo "You can log in with the following credentials:"
echo -e "User: \n\tuser@demo-api.com\n\tuserPassword123@ChangeMe"
echo -e "Admin: \n\tadmin@demo-api.com\n\tadminPassword123@ChangeMe"