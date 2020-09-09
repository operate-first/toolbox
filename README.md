# Operate First toolbox

This is a Operate-First toolbox that comprises of commonly used tooling to supplement workflows.  

## Usage

### Create your toolbox container

```shell
$ toolbox create --image quay.io/aicoe/of-toolbox:v0.1.0
Created container: of-toolbox
Enter with: toolbox enter --container of-toolbox-v0.1.0
$
```

This will create a container called `of-toolbox-<version-id>`.

### Enter the toolbox

```shell
$ toolbox enter --container of-toolbox-v0.1.0
```

### Tools included

- Kustomize 
- SOPS
- KSOPS
- Helm 
- Helm Secrets

### Debugging Tips 

You may see the following error when running a `kustomize build` using `ksops`: 

> plugin was built with a different version of package internal/cpu

Toolbox will try to absorb as much from your parent environment as possible, this may result in environment variables 
in the toolbox being overwritten by your own environment. Try sourcing these environment variables again to fix the issue
above: 

```bash
XDG_DATA_HOME=/usr/share/.local/share
XDG_CACHE_HOME=/usr/share/.cache
XDG_CONFIG_HOME=/usr/share/.config
``` 

## Background Information

See [toolbox](https://github.com/containers/toolbox) for more info on how a toolbox works. 
