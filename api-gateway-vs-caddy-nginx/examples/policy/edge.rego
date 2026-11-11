# Conftest policy for `terraform show -json plan.out`.
# Not executed in this repo yet: run `conftest test plan.json -p examples/policy`.
package main

import rego.v1

# Every API Gateway route needs an authorizer, except the health check.
deny contains msg if {
	rc := input.resource_changes[_]
	rc.type == "aws_apigatewayv2_route"
	rc.change.after.authorization_type == "NONE"
	rc.change.after.route_key != "GET /healthz"
	msg := sprintf("%s: route without authorizer", [rc.address])
}

# Every HTTP API stage needs throttling to protect the backend.
deny contains msg if {
	rc := input.resource_changes[_]
	rc.type == "aws_apigatewayv2_stage"
	count(rc.change.after.default_route_settings) == 0
	msg := sprintf("%s: stage without throttling", [rc.address])
}
