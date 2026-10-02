from typing import Any

ALL_MANAGED_SCOPES = {
    "api-demo/user:read",
    "api-demo/user:write",
    "api-demo/admin"
}

GROUP_SCOPES = {
    "users": {
        "api-demo/user:read",
        "api-demo/user:write",
    },
    "admin": {
        "api-demo/user:read",
        "api-demo/user:write",
        "api-demo/admin"
    }
}

def handler(event: dict[str, Any], context: Any) -> dict[str, Any]:
    request = event.get("request") or {}
    response = event.get("response") or {}

    event["request"] = request
    event["response"] = response

    group_configuration = request.get("groupConfiguration") or {}
    groups = group_configuration.get("groupsToOverride") or []

    allowed_scopes: set[str] = set()

    for group in groups:
        allowed_scopes.update(GROUP_SCOPES.get(group, set()))

    allowed_scopes.intersection_update(ALL_MANAGED_SCOPES)

    scopes_to_suppress = sorted(
        ALL_MANAGED_SCOPES - allowed_scopes
    )

    claims_and_scope = (
        response.get("claimsAndScopeOverrideDetails") or {}
    )

    access_token_generation = (
        claims_and_scope.get("accessTokenGeneration") or {}
    )

    access_token_generation["scopesToAddOrOverride"] = sorted(
        allowed_scopes
    )

    access_token_generation["scopesToSuppress"] = scopes_to_suppress

    claims_and_scope["accessTokenGeneration"] = (
        access_token_generation
    )

    response["claimsAndScopeOverrideDetails"] = claims_and_scope
    event["response"] = response

    return event
