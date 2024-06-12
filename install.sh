#!/bin/bash

# Función para crear el clúster de Kind
create_cluster() {
    kind create cluster --config kind/kind-config.yaml
}

# Función para eliminar el clúster de Kind
delete_cluster() {
    kind delete cluster
}

# Función para instalar cert-manager con trust manager
install_cert_manager_with_trust_manager() {
    # Instalar cert-manager
    helm install \
    cert-manager jetstack/cert-manager \
    --namespace cert-manager \
    --create-namespace \
    --version v1.15.0 \
    --set crds.enabled=true

    # Esperar a que los pods de cert-manager estén en ejecución
    kubectl wait --for=condition=ready pod -l app=cert-manager -n cert-manager --timeout=90s
    kubectl wait --for=condition=ready pod -l app=webhook -n cert-manager --timeout=90s
    kubectl wait --for=condition=ready pod -l app=cainjector -n cert-manager --timeout=90s

    # Instalar trust manager

    helm upgrade trust-manager jetstack/trust-manager \
    --install \
    --namespace cert-manager \
    --wait
    # Verificar la instalación
    kubectl get pods --namespace cert-manager
    kubectl get pods --namespace trust-manager

    echo "Cert-Manager con Trust Manager ha sido instalado exitosamente en el clúster de Kind."
}

# Función principal
main() {
    case $1 in
        create)
            create_cluster
            install_cert_manager_with_trust_manager
            ;;
        delete)
            delete_cluster
            ;;
        *)
            echo "Uso: $0 {create|delete}"
            exit 1
            ;;
    esac
}

# Llamar a la función principal
main "$@"