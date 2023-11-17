resource "null_resource" "opa_policy" {
  triggers = {
    always_run = "${timestamp()}"
  }

  provisioner "local-exec" {
    command = <<-EOT
      echo '${jsonencode({
        "kind": "Pod",
        "operation": "create",
        "user": "user:alice",
        "container": {
          "name": "nginx"
        }
      })}' > opa_input.json

      opa eval --format json --data ${path.module}/deployment_policy.rego --input opa_input.json "data.deny"
    EOT
  }
}

resource "null_resource" "apply_k8s_pod" {
  triggers = {
    always_run = "${file("nginx-pod.yaml")}"
  }

  provisioner "local-exec" {
    command = "kubectl apply -f nginx-pod.yaml"
  }
}

output "deny" {
  value = try(jsondecode(null_resource.opa_policy.triggers.always_run).result.deny, false)
}

