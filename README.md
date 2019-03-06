# What is this?
This is an example of how to version Docker containers when deploying to Kubernetes using [Kustomize](https://github.com/kubernetes-sigs/kustomize). It's primarily geared towards Google Kubernetes Engine (GKE). It might be a useful example for someone who wants to deploy the same .yaml files with different container versions to several environments - without worrying about too many moving parts.

# TL;DR:
Do the following to have a look at the output from Kustomize:

1. Download Kustomize [Kustomize v2.0.3](https://github.com/kubernetes-sigs/kustomize/releases/tag/v2.0.3), and put it somewhere you can reach it (in your `PATH`).
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
Containers are tagged with the `git` hash of the last commit when built. This information is then available in the container registry. The containers are pushed with version set to a combination of tags (if present), number of commits since last tag, commit hash, and branch name. 

1. If you have a tag called `1.0.0`, containers are pushed with version set to `1.0.0-17-g15c791d-master` and tagget with last `git` commit hash
2. If you have uncommitted changes, the version will be something like: `1.0.0-12-gdf68478-dirty-master`
3. The `prod/kustomize.yaml` and `dev/kustomize.yaml` files are used to select which version ends up in the different environments

There are two containers in the project. 
1. node-container - an example of how to build using npm
2. sshd-container - example of how to use a Makefile

Please note that the containers are only there for example purposes. So go read the `Makefile` and the `package.json`. 

In the "real world" this is used with four branches: 
* master: Where all development happens. Should always build and work, although might not be fully tested.
* develop: Whatever is currently deployed in the development environment
* prod: Current production version. 

Changes flow from master, to develop, and finally into prod. 

# The version string
To test how the version string will look for a git repo, do this: 

``` 
echo `git describe --tags --always --dirty`-`git rev-parse --abbrev-ref HEAD` 
```

* No tags, clean: `8024499-master`
* No tags, dirty: `8024499-dirty-master`
* 1.0.0 tag, dirty, two commits after 1.0.0 tag, with commit hash: `1.0.0-2-g7066a24-dirty-master`

# Workflow
Deployment workflow is something like this: 

1. Build container using either `npm run deploy` or `make` from the container base directory. (Note: Don't expect this to work - these are examples only meant for reading)
2. Get the version strings used in the latest builds from the container registry. Use: `./get-versions-gcloud-registry.pl`, `./get-versions-fs.sh`, or alternatively `./get-versions-docker.pl`. These are examples - not fully working.
3. Update `yaml/dev/kustomization.yaml` or `yaml/prod/kustomization.yaml` files with version strings. 
4. Run the `./deploy.sh` script to update the relevant environment (with either `prod`, `dev`, or `all` as argument)

It's up to the user to keep track of which versions are running in the different environments. 

# Limitation 
Be careful about making changes to code and re-building before committing and pushing as the changed code will get the same git hash - effectivly overwriting the original with the change. This can probably be guarded against by having, for example, the `Makefile` terminate if there are uncommitted changes on building for deployment. Or keep an eye out for versions saying `dirty`.

# Alternative ways to get the latest version strings
1. From Docker using some form of `docker images` and `grep` or similar
2. From the container source code directory. First `cd <container dir>.` Then get the latest version string by doing: 
```
echo `git describe --tags --always --dirty`-`git rev-parse --abbrev-ref HEAD`
```
