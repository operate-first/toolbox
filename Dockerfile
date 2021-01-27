ARG KSOPS_VERSION="v2.3.3"
FROM quay.io/viaductoss/ksops:$KSOPS_VERSION as ksops-builder
FROM registry.fedoraproject.org/f32/fedora-toolbox:32

ENV XDG_DATA_HOME=/usr/share/.local/share
ENV XDG_CACHE_HOME=/usr/share/.cache
ENV XDG_CONFIG_HOME=/usr/share/.config
ENV KUSTOMIZE_PLUGIN_PATH=$XDG_CONFIG_HOME/kustomize/plugin/
ARG SOPS_VERSION="v3.6.1"
ARG HELM_VERSION="v3.4.1"
ARG HELM_SECRETS_VERSION="3.4.1"
ARG CONFTEST_VERSION="0.21.0"

# Copy ksops and kustomize from builder
COPY --from=ksops-builder /go/bin/kustomize /usr/local/bin/kustomize
COPY --from=ksops-builder /go/src/github.com/viaduct-ai/kustomize-sops/*  $KUSTOMIZE_PLUGIN_PATH/viaduct.ai/v1/ksops/

RUN sed -i '/tsflags=nodocs/d' /etc/dnf/dnf.conf && \
    dnf -y install curl && dnf clean all && \
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
    chmod +x /usr/local/bin/conftest

CMD /bin/bash
