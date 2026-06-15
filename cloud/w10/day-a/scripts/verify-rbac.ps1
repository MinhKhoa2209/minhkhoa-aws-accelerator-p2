param(
    [string]$Namespace = "w10-rbac-lab"
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

function Test-Permission {
    param(
        [string]$ServiceAccount,
        [string]$Verb,
        [string]$Resource,
        [string]$Expected,
        [switch]$AllNamespaces
    )

    $identity = "system:serviceaccount:${Namespace}:${ServiceAccount}"
    $arguments = @("auth", "can-i", $Verb, $Resource, "--as", $identity)

    if ($AllNamespaces) {
        $arguments += "--all-namespaces"
    }
    else {
        $arguments += @("-n", $Namespace)
    }

    $actual = (& kubectl @arguments).Trim().ToLowerInvariant()
    $exitCode = $LASTEXITCODE

    # kubectl returns exit code 1 for the valid authorization result "no".
    if ($actual -notin @("yes", "no")) {
        throw "kubectl auth can-i failed for $ServiceAccount $Verb $Resource (exit=$exitCode, output=$actual)"
    }

    $status = if ($actual -eq $Expected) { "PASS" } else { "FAIL" }
    Write-Host ("{0,-5} {1,-10} {2,-7} {3,-25} expected={4} actual={5}" -f `
        $status, $ServiceAccount, $Verb, $Resource, $Expected, $actual)

    if ($status -eq "FAIL") {
        throw "Unexpected permission result."
    }
}

Test-Permission developer create deployments.apps yes
Test-Permission developer get pods yes
Test-Permission developer get secrets no
Test-Permission developer create rolebindings.rbac.authorization.k8s.io no

Test-Permission viewer get deployments.apps yes
Test-Permission viewer create deployments.apps no
Test-Permission viewer delete pods no

Test-Permission sre get nodes yes -AllNamespaces
Test-Permission sre get pods yes -AllNamespaces
Test-Permission sre create deployments.apps no -AllNamespaces

Write-Host "RBAC verification passed."
