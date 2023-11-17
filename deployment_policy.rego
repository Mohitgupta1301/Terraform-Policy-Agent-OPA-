package example.openagent

deny {
    input.kind == "Pod"
    input.operation == "create"
    input.user != "system:serviceaccount:kube-system:default"  # Exclude system accounts
    container := input.container
    container.name == "nginx"
    container.image == "nginx:latest"
}
