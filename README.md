# Custom GitHub Actions Runner

This repository contains a custom Docker image for GitHub Actions self-hosted runners with build tools pre-installed.

## Purpose

The default GitHub Actions runner images don't include build tools like `make`, `g++`, and other development dependencies needed to compile native Node.js modules. This custom image extends the official runner image with those tools.

## What's Included

This custom runner image includes:

- **build-essential** - Meta-package that includes:
  - gcc, g++ (C/C++ compilers)
  - make
  - libc6-dev
  - dpkg-dev
- **python3** - Required by node-gyp for building native modules
- **python3-pip** - Python package manager

## Usage

### Using with Actions Runner Controller (ARC)

When deploying your runner scale set, specify this custom image:

```yaml
githubConfigUrl: "https://github.com/GalacticPlayground/YOUR-REPO"
githubConfigSecret: "github-token"

template:
  spec:
    containers:
      - name: runner
        image: ghcr.io/galacticplayground/custom-runner:latest
        resources:
          requests:
            cpu: "500m"
            memory: "1Gi"
          limits:
            cpu: "2"
            memory: "4Gi"
```

Deploy with Helm:

```bash
helm upgrade --install arc-runner-set \
  --namespace arc-runners \
  --create-namespace \
  -f values.yaml \
  oci://ghcr.io/actions/actions-runner-controller-charts/gha-runner-scale-set
```

### Available Tags

The image is automatically built and pushed to GitHub Container Registry with multiple tags:

- `latest` - Latest build from the main branch
- `v1`, `v1.0`, `v1.0.0` - Semantic versioning tags (when you create a release)
- `main-<sha>` - Tagged with branch name and commit SHA

## Automated Builds

This repository uses GitHub Actions to automatically build and push the Docker image to GitHub Container Registry (GHCR) on:

- **Push to main branch** - Builds and tags as `latest`
- **Git tags** (e.g., `v1.0.0`) - Builds and tags with semantic versioning
- **Pull requests** - Builds but doesn't push (for testing)
- **Manual trigger** - Can be triggered via workflow_dispatch

## Creating a New Release

To create a new versioned release:

```bash
git tag -a v1.0.0 -m "Release version 1.0.0"
git push origin v1.0.0
```

This will automatically build and push the image with tags:
- `ghcr.io/galacticplayground/custom-runner:latest`
- `ghcr.io/galacticplayground/custom-runner:1.0.0`
- `ghcr.io/galacticplayground/custom-runner:1.0`
- `ghcr.io/galacticplayground/custom-runner:1`

## Adding More Packages

To add additional packages, edit the `Dockerfile` and add them to the `apt-get install` command:

```dockerfile
RUN apt-get update && apt-get install -y \
    build-essential \
    make \
    g++ \
    python3 \
    python3-pip \
    your-additional-package \
    && rm -rf /var/lib/apt/lists/*
```

Commit and push your changes - the image will be automatically rebuilt.

## Multi-Architecture Support

The build workflow automatically creates multi-architecture images supporting:
- `linux/amd64` (x86_64)
- `linux/arm64` (ARM 64-bit)

## Security

The image follows security best practices:
- Installs packages as root
- Switches back to the `runner` user for runtime
- Cleans up apt cache to reduce image size
- Uses the official GitHub Actions runner as the base image

## Troubleshooting

### Image Pull Errors

If your Kubernetes cluster can't pull the image, you may need to create an image pull secret:

```bash
kubectl create secret docker-registry ghcr-secret \
  --docker-server=ghcr.io \
  --docker-username=YOUR-GITHUB-USERNAME \
  --docker-password=YOUR-GITHUB-PAT \
  -n arc-runners
```

Then reference it in your runner configuration:

```yaml
template:
  spec:
    imagePullSecrets:
      - name: ghcr-secret
```

### Build Failures

Check the GitHub Actions workflow runs in the "Actions" tab of this repository.

## License

This repository is part of the GalacticPlayground organization.
