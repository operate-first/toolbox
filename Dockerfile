ARG KSOPS_VERSION="v2.5.5"
FROM quay.io/viaductoss/ksops:$KSOPS_VERSION as ksops-builder
FROM gcr.io/k8s-prow/label_sync:latest as labels-sync-builder
FROM gcr.io/k8s-prow/peribolos:latest as peribolos-builder

FROM registry.fedoraproject.org/fedora-toolbox:34

ENV XDG_DATA_HOME=/usr/share/.local/share \
    XDG_CACHE_HOME=/usr/share/.cache \
    XDG_CONFIG_HOME=/usr/share/.config

ENV KUSTOMIZE_PLUGIN_PATH=$XDG_CONFIG_HOME/kustomize/plugin/

ARG SOPS_VERSION="v3.7.1"
ARG HELM_VERSION="v3.4.1"
ARG HELM_SECRETS_VERSION="3.4.1"
ARG CONFTEST_VERSION="0.21.0"
ARG YQ_VERSION="v4.6.1"
ARG OPA_VERSION="0.31.0"
ARG OPFCLI_VERSION="v0.2.0"

LABEL maintainer="Operate First" \
    name="operate-first/opf-toolbox" \
    summary="Toolbox container for Operate First" \
    url="https://github.com/operate-first/toolbox" \
    issues="https://github.com/operate-first/toolbox/issues" \
    license="GPLv3" \
    version.conftest="${CONFTEST_VERSION}" \
    version.helm="${HELM_VERSION}" \
    version.helm_secrets="${HELM_SECRETS_VERSION}" \
    version.ksops="${KSOPS_VERSION}" \
    version.sops="${SOPS_VERSION}"

# Copy ksops, kustomize, labels_sync and peribolos from builders
COPY --from=ksops-builder /go/bin/kustomize /usr/local/bin/kustomize
COPY --from=ksops-builder /go/src/github.com/viaduct-ai/kustomize-sops/*  $KUSTOMIZE_PLUGIN_PATH/viaduct.ai/v1/ksops/
COPY --from=labels-sync-builder /app/label_sync/app.binary /usr/bin/labels_sync
COPY --from=peribolos-builder /app/prow/cmd/peribolos/app.binary /usr/bin/peribolos

# Install additional dependecies and tools
RUN dnf install -y openssl make npm pre-commit \
    && dnf clean all \
    && rm -rf /var/cache/yum

ENV PRE_COMMIT_HOME=/tmp

RUN \
    # Install Sops
    curl -o /usr/local/bin/sops -L https://github.com/mozilla/sops/releases/download/${SOPS_VERSION}/sops-${SOPS_VERSION}.linux && \
    chmod +x /usr/local/bin/sops && \
    # Install Helm
    curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/$HELM_VERSION/scripts/get-helm-3 && \
    chmod 700 get_helm.sh && ./get_helm.sh && \
    # Install Helm Secrets
    helm plugin install https://github.com/jkroepke/helm-secrets --version=$HELM_SECRETS_VERSION && \
    # Install conftest
    curl -L https://github.com/open-policy-agent/conftest/releases/download/v${CONFTEST_VERSION}/conftest_${CONFTEST_VERSION}_Linux_x86_64.tar.gz | tar -xzf - -C /usr/local/bin && \
    chmod +x /usr/local/bin/conftest && \
    # Install OPA
    curl -o /usr/local/bin/opa -L https://github.com/open-policy-agent/opa/releases/download/v${OPA_VERSION}/opa_linux_amd64_static && \
    chmod +x /usr/local/bin/opa &&\
    # Install yq
    curl -o /usr/local/bin/yq -L https://github.com/mikefarah/yq/releases/download/${YQ_VERSION}/yq_linux_amd64 && \
    chmod +x /usr/local/bin/yq && \
    # Install opfcli
    curl -o /usr/local/bin/opfcli -L https://github.com/operate-first/opfcli/releases/download/${OPFCLI_VERSION}/opfcli-linux-amd64 && \
    chmod +x /usr/local/bin/opfcli

COPY scripts/* /usr/local/bin/

CMD /bin/bash
