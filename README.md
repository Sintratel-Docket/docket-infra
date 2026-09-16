
# Docket infrastructure

The DEV environment is provisioned with Terraform on Amazon EKS. Terraform
state remains split between AWS infrastructure in `environments/dev` and
cluster platform resources in `environments/dev/kubernetes`.

## Gateway API platform

External HTTP routing uses Kubernetes Gateway API instead of Kubernetes
Ingress. AWS Load Balancer Controller provides the AWS integration that can
create an Application Load Balancer when a future `Gateway` is applied.

The platform pins these versions:

- Gateway API Standard channel: `v1.2.0`
- AWS Load Balancer Controller: `v2.14.1`
- AWS Load Balancer Controller Helm chart: `1.14.1`

Gateway API `v1.2.0` is the Standard bundle referenced by the AWS Load Balancer
Controller `v2.14` Gateway documentation. The chart version is pinned to
`1.14.1` because its official chart metadata packages controller `v2.14.1`.

The official Gateway API Standard manifest and controller IAM policy are
vendored from immutable release tags so Terraform does not depend on a floating
`main` URL:

- `charts/gateway-api-crds/templates/standard-install.yaml`
- `policies/aws-load-balancer-controller-v2.14.1.json`

Terraform installs the Standard CRDs through the local `gateway-api-crds` Helm
chart. The AWS controller chart installs its required AWS-specific Gateway
configuration CRDs, including `LoadBalancerConfiguration`,
`TargetGroupConfiguration`, and `ListenerRuleConfiguration`. Those CRDs are
platform prerequisites; instances of those resources belong with future
Gateway routing desired state in `gitops-manifests`.

### IAM and IRSA

Terraform creates the least-privilege official
`AWSLoadBalancerControllerIAMPolicy` and the
`AmazonEKSLoadBalancerControllerRole` IRSA role. The trust policy is restricted
to:

```text
system:serviceaccount:kube-system:aws-load-balancer-controller
```

The `kube-system/aws-load-balancer-controller` ServiceAccount contains the
`eks.amazonaws.com/role-arn` annotation. Helm is configured with
`serviceAccount.create=false`, so it cannot create a conflicting account.

### Ownership boundary

`docket-infra` owns:

- Gateway API and AWS controller CRDs
- AWS Load Balancer Controller IAM policy and IRSA role
- Controller ServiceAccount and Helm release
- AWS networking prerequisites and platform lifecycle

`gitops-manifests` owns:

- GatewayClass and any AWS-specific Gateway configuration objects
- Gateway resources
- HTTPRoute resources and application routing

No `Gateway`, `HTTPRoute`, `Ingress`, or `LoadBalancer` Service is created by
this repository. Creating a real Gateway later may provision a billable AWS
ALB.

### Configuration and verification

Environment-specific platform values are defined in
`environments/dev/kubernetes/dev.tfvars`. Run Terraform with that file:

```powershell
terraform init -backend-config="bucket=<state-bucket>"
terraform plan -var-file="dev.tfvars"
```

Verify the installed platform with:

```powershell
kubectl get crd | Select-String "gateway.networking.k8s.io|gateway.k8s.aws"
kubectl get deployment aws-load-balancer-controller -n kube-system
kubectl get pods -n kube-system -l app.kubernetes.io/name=aws-load-balancer-controller
kubectl get serviceaccount aws-load-balancer-controller -n kube-system -o yaml
```

References:

- https://docs.aws.amazon.com/eks/latest/userguide/lbc-helm.html
- https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.14/guide/gateway/gateway/
- https://gateway-api.sigs.k8s.io/guides/getting-started/introduction/
