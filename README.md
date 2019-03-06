# What is this?
This is an example of how to version Docker containers when deploying to Kubernetes using [Kustomize](https://github.com/kubernetes-sigs/kustomize). It's meant for anyone who wants to deploy the same .yaml files with different container versions to several environments - without worrying about too many moving parts.

# TL;DR:
Do the following to have a look at the output from Kustomize:

1. Download Kustomize [Kustomize v1.0.8](https://github.com/kubernetes-sigs/kustomize/releases/tag/v1.0.8), and put it somewhere you can reach it.
2. `cd yaml`
3. `kustomize build dev |tee dev.yaml`
4. Look at the output. 
5. `kustomize build prod |tee prod.yaml`
6. `diff dev.yaml prod.yaml`


## Advantages of this approach
There are two advantages to this way of deploying:

1. It's possible to use the same `.yaml` files for different environments (dev, test, prod), and only specify where they differ. In this example only number of replicas,  memory and CPU limits are different. 

2. It's possible to specify different container versions for different environments based on git commit hash. The versions are all listed in one place, rather than being spread throughout the `.yaml` files,

## How it works
Containers are tagged with the `git` hash of the last commit when built. This information is then available in the container registry. 
1. Build container and tag it with last `git` commit hash
3. Push container to registry
4. Use Kustomize to deploy different versions, identified by their git commit hash, to different environments

There are two containers in the project. 
1. node-container - an example of how to build using npm
2. sshd-container - example of how to use a Makefile

Please note that the containers are only there for example purposes. So go read the `Makefile` and the `package.json`. 

# Workflow
Deployment workflow is something like this: 

1. Build container using either `npm run deploy` or `make` from the container base directory. (Note: Don't expect this to work - these are examples only meant for reading)
2. Get the tags used in the latest builds from the containers in the container registry. Use: `./get-versions-gcloud-registry.pl`
3. Update the `yaml/dev/kustomization.yaml` or the `yaml/prod/kustomization.yaml` files with the relevant `git` commit hashes. 
4. Run the `./deploy.sh` script to update the relevant environment

It's up to the user to keep track of which versions (identified by git hash) are running in the different environments. 

# Limitation 
Be careful about making changes to code and re-building before committing and pushing as the changed code will get the same git hash - effectivly overwriting the original with the change. This can probably be guarded against by having, for example, the `Makefile` terminate if there are uncommitted changes on building for deployment.

# Alternative ways to get the latest git tag
1. From Docker using some form of `docker images` and `grep` or similar
2. From the container source code directory. First `cd <container dir>.` Then get the git checksum using `git log -1 --format=%h .`

# Versions
This was tested with [Kustomize v1.0.8](https://github.com/kubernetes-sigs/kustomize/releases/tag/v1.0.8). Versions 1.0.9 through 1.0.11 caused errors on deploy to GKE which I haven't had time to look into. 
