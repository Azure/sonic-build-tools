# Azure pipeline migration
 
> *Azure Pipeline Documentation: https://docs.microsoft.com/en-us/azure/devops/pipelines/?view=azure-devops*

## 1. jobs finished
| repo | branch | example |
|--|--|--|
| Azure/sonic-buildimage       | master | [Nightly build](https://github.com/Azure/sonic-buildimage/blob/master/.azure-pipelines/official-build.yml)<br>[PR/CI build](https://github.com/Azure/sonic-buildimage/blob/master/azure-pipelines.yml) |
| Azure/sonic-linux-kernel     |        | [PR/CI build](https://github.com/Azure/sonic-linux-kernel/blob/master/azure-pipelines.yml) |
| Azure/sonic-mgmt             |        | [PR/CI build](https://github.com/Azure/sonic-mgmt/blob/master/azure-pipelines.yml) |
| Azure/sonic-platform-common  |        | [PR/CI build](https://github.com/Azure/sonic-platform-common/blob/master/azure-pipelines.yml) |
| Azure/sonic-platform-daemons |        | [PR/CI build](https://github.com/Azure/sonic-platform-daemons/blob/master/azure-pipelines.yml) |
| Azure/sonic-sairedis         |        | [PR/CI build](https://github.com/Azure/sonic-sairedis/blob/master/azure-pipelines.yml) |
| Azure/sonic-swss-common      |        | [PR/CI build](https://github.com/Azure/sonic-swss-common/blob/master/azure-pipelines.yml) |
| Azure/sonic-swss             |        | [PR/CI build](https://github.com/Azure/sonic-swss/blob/master/azure-pipelines.yml) |
| Azure/sonic-utilities        |        | [PR/CI build](https://github.com/Azure/sonic-utilities/blob/master/azure-pipelines.yml) |
| Azure/sonic-wpa-supplicant   |        | [PR/CI build](https://github.com/Azure/sonic-wpa-supplicant/blob/master/azure-pipelines.yml) |

## 2. jobs need to do
| repo | platform | branch<-arch> |
|--|--|--|
| Azure/sonic-buildimage | Barefoot | master, 201911, 202012     |
|                            | Broadcom | 201811, 201911, 202012     |
|                            | Centec   | master, 202012<br>202012-arm64 |
|                            | innovium | master, 202012, 201811, 201911 |
|                            | marvell  | 201911, 202012, master<br>202012-armhf |
|                            | mellanox | master, 201811, 201911, 2019-t0, 202012 |
|                            | nephos   | master, 201811, 201911, 202012 |
|                            | vs       | 201811, 201911, 202012<br>[testjob](https://sonic-jenkins.westus2.cloudapp.azure.com/job/vs/job/buildimage-vs-image/) |
|                            | generic  | master |
| opencomputeproject/SAI     |          | master, PR/CI              |
| Azure/sonic-py-swsssdk     |          | master, 201911, PR/CI      |
| Azure/sonic-snmpagent      |          | master, 201811, 201911, PR/CI |
| Azure/sonic-dbsyncd        |          | master, PR/CI              |
| Azure/sonic-mgmt-common    |          | master, PR/CI              |
| Azure/sonic-mgmt-framework |          | 201911, master, PR/CI      |
| Azure/sonic-stp            |          | master, PR/CI              |
| Azure/sonic-telemetry      |          | 201911, master, PR/CI      |
| Azure/sonic-ztp            |          | 201911, master, PR/CI      |
| Bldenv(jenkins folder)     |          | sonic-slave-buster<br>sonic-slave-jessie<br>sonic-slave-stretch<br>dpkg-cache-cleanup |
| Azure/sonic-snmpagent [depend job](https://sonic-jenkins.westus2.cloudapp.azure.com/job/common/job/dep-build/) | | |

## 3. Pipeline basic: [*doc*](https://docs.microsoft.com/en-us/azure/devops/pipelines/get-started/key-pipelines-concepts?view=azure-devops)
![concept picture](https://docs.microsoft.com/en-us/azure/devops/pipelines/get-started/media/key-concepts-overview.svg?view=azure-devops)
- A trigger tells a Pipeline to run.
- A pipeline is made up of one or more stages. A pipeline can deploy to one or more environments.
- A stage is a way of organizing jobs in a pipeline and each stage can have one or more jobs.
- Each job runs on one agent. A job can also be agentless.
- Each agent runs a job that contains one or more steps.
- A step can be a task or script and is the smallest building block of a pipeline.
- A task is a pre-packaged script that performs an action, such as invoking a REST API or publishing a build artifact.
- An artifact is a collection of files or packages published by a run.

## 4. Azure pipeline getting start:
> *Pipeline location: <https://dev.azure.com/mssonic/build/_build?view=folders>*<br>
> *Documentation: [Migration from Jenkins to Azure Pipelines](https://docs.microsoft.com/en-us/azure/devops/pipelines/migrate/from-jenkins?view=azure-devops)*<br>
> *(show on web)*

*Work flow:*
- create test-pipeline and pipeline file on personal repo.
- self test
- send PR to Azure repo
- after PR merged, create official pipeline

## 5. Multi-branch pipeline

> At step 2, we have already setup default branch and pipeline file path.<br>
> If we copy pipeline file to another branch, and change trigger accordingly, this branch has been set up.<br>
> *(show on web)*

## 6. key features

### 6.1 Repo/permission related: [*doc*](https://docs.microsoft.com/en-us/azure/devops/pipelines/repos/github?view=azure-devops&tabs=yaml)
- [Code checkout](https://docs.microsoft.com/en-us/azure/devops/pipelines/yaml-schema?view=azure-devops&tabs=schema%2Cparameter-schema#checkout)<br>
```
- steps:
- checkout: self
  submodules: true
  clean: true
```
> *Note:<br>defaults to not checking out submodules<br> defaults to not cleanup workspace*<br>

- [Multicheckout](https://docs.microsoft.com/en-us/azure/devops/pipelines/repos/multi-repo-checkout?view=azure-devops)
```
resources:
  repositories:
  - repository: sonic-sairedis
    type: github
    name: Azure/sonic-sairedis

steps:
- checkout: self
- checkout: sonic-sairedis
- checkout: git://MyProject/MyRepo
```
> *Note:<br>[Checkoutpath](https://docs.microsoft.com/en-us/azure/devops/pipelines/repos/github?view=azure-devops&tabs=yaml#checkout)*
### 6.2 Trigger [*doc*](https://docs.microsoft.com/en-us/azure/devops/pipelines/build/triggers?view=azure-devops)

- [PR trigger](https://docs.microsoft.com/en-us/azure/devops/pipelines/repos/github?view=azure-devops&tabs=yaml#pr-triggers) 
```
pr:
  branches:
    include:
    - master
    - releases/\*
  paths:
    include:
    - docs
    exclude:
    - docs/README.md
```

- [CI trigger](https://docs.microsoft.com/en-us/azure/devops/pipelines/repos/github?view=azure-devops&tabs=yaml#ci-triggers)
```
trigger:
  branches:
    include:
    - master
    - releases/*
  paths:
    include:
    - docs
    exclude:
    - docs/README.md
```
- [Schedule trigger](https://docs.microsoft.com/en-us/azure/devops/pipelines/process/scheduled-triggers?view=azure-devops&tabs=yaml)
```
schedules:
- cron: "0 0 * * *"
  displayName: Daily midnight build
  branches:
    include:
    - main
    - releases/*
    exclude:
    - releases/ancient/*
- cron: "0 12 * * 0"
  displayName: Weekly Sunday build
  branches:
    include:
    - releases/*
  always: true
```
- [Comment trigger](https://docs.microsoft.com/en-us/azure/devops/pipelines/repos/github?view=azure-devops&tabs=yaml#comment-triggers)
```
/AzurePipelines run
```
- [Pipeline trigger](https://docs.microsoft.com/en-us/azure/devops/pipelines/process/pipeline-triggers?view=azure-devops&tabs=yaml)

> *NOTE:*
> 1. If you want to disable PR/CI trigger, you have to disable in yaml file explicitly.
> ```
> pr: none
> trigger: none
> ```
> 2. cron does not support random character 'H'. [*doc*](https://docs.microsoft.com/en-us/azure/devops/pipelines/process/scheduled-triggers?view=azure-devops&tabs=yaml#cron-syntax)
> 3. do not override the trigger at pipeline UI. 

### 6.3 Agents
- [Run on Microsoft-hosted agents](https://docs.microsoft.com/en-us/azure/devops/pipelines/agents/hosted?view=azure-devops&tabs=yaml)
```
jobs:
- job: Linux
  pool:
    vmImage: 'ubuntu-latest'
  steps:
  - script: echo hello from Linux
- job: macOS
  pool:
    vmImage: 'macOS-latest'
  steps:
  - script: echo hello from macOS
- job: Windows
  pool:
    vmImage: 'windows-latest'
  steps:
  - script: echo hello from Windows
```
- [Run on scale set agents](https://docs.microsoft.com/en-us/azure/devops/pipelines/agents/scale-set-agents?view=azure-devops)
```
stages:
- stage: Build
  pool: sonicbld
```
> *Note*:<br>
> sonicbld is a agent pool based on ubuntu20.04. we did some init jobs when they were started.
- [Run in Containers](https://docs.microsoft.com/en-us/azure/devops/pipelines/process/container-phases?view=azure-devops)
```
pool:
  vmImage: ubuntu-20.04

container:
  image: sonicdev-microsoft.azurecr.io:443/sonic-slave-buster:latest
```
> *Note:*
> - *keyword 'pool' can appear at root, stage and job level.*
> - *Now we already have 4 scale set agents:*
>   - sonicbld
>   - sonicbld_8c
>   - sonicbld_16c
>   - sonictest


### 6.4 Task [*doc*](https://docs.microsoft.com/en-us/azure/devops/pipelines/process/tasks?view=azure-devops&tabs=yaml)

Task is the basic block of a pipeline. It is a pre-packaged script or procedure that has been abstracted with a set of inputs.
Azure pipeline has a lot of built-in tasks. Tasks may have some demands.
Script is one of built-in tasks. It is short for \"task: CmdLine\@2\". Script use cmd.exe in windows, Bash in Linux and macOS.

How can we look up tasks:
- Read the task doc. [Task index](https://docs.microsoft.com/en-us/azure/devops/pipelines/tasks/?view=azure-devops)
- Or use Azure DevOps editor. [example](https://dev.azure.com/mssonic/build/_apps/hub/ms.vss-build-web.ci-designer-hub?pipelineId=39&nonce=ziB2OZt4gLIsrMBKj3d1Lg%3D%3D&branch=master)

> **Some commonly used tasks:**
> 1. **Script**
>  ```
>  - script: echo Hello, world!
>    displayName: 'Run a one-line script'
>  
>  - script: |
>      set -xe
>      echo Add other tasks to build, test, and deploy your project.
>      echo See https://aka.ms/yaml
>    displayName: 'Run a multi-line script'
>  ```
> 2. [Publish artifacts](https://docs.microsoft.com/en-us/azure/devops/pipelines/tasks/utility/publish-pipeline-artifact?view=azure-devops)<br>
> > Example<br> [code](https://github.com/Azure/sonic-buildimage/blob/master/.azure-pipelines/build-template.yml)<br> [UI](https://dev.azure.com/mssonic/build/_build/results?buildId=4763&view=results)
> ```
> steps:
> - task: PublishPipelineArtifact@1
>   inputs:
>     targetPath: $(System.DefaultWorkingDirectory)/bin/WebApp
>     artifactName: WebApp
> 
> - publish: $(System.DefaultWorkingDirectory)/bin/WebApp
>   artifact: WebApp
> ```
> 3. [Download artifacts](https://docs.microsoft.com/en-us/azure/devops/pipelines/tasks/utility/download-pipeline-artifact?view=azure-devops)
> > Example [code](https://github.com/Azure/sonic-buildimage/blob/master/.azure-pipelines/run-test-template.yml)
> ```
> steps:
> - task: DownloadPipelineArtifact@2
>   inputs:
>     artifact: WebApp
> 
> - download: current
>   artifact: WebApp
>   patterns: '**/*.js'
> ```
> 4. [Publish test results](https://docs.microsoft.com/en-us/azure/devops/pipelines/tasks/test/publish-test-results?view=azure-devops&tabs=trx%2Cyaml)
> 
> > Example<br>[code](https://github.com/Azure/sonic-sairedis/blob/master/.azure-pipelines/test-docker-sonic-vs-template.yml) <br>[UI](https://dev.azure.com/mssonic/build/_build/results?buildId=4549&view=results)
> ```
> - task: PublishTestResults@2
>   inputs:
>     testResultsFiles: '**/tr.xml'
>     testRunTitle: vstest
>   condition: always()
> ```
> 5. [Publish test coverage](https://docs.microsoft.com/en-us/azure/devops/pipelines/tasks/test/publish-code-coverage-results?view=azure-devops)
> > Example<br>[code](https://github.com/Azure/sonic-platform-common/blob/master/azure-pipelines.yml)<br>[UI](https://dev.azure.com/mssonic/build/_build/results?buildId=4510&view=results)
> ```
> - task: PublishCodeCoverageResults@1
>   inputs:
>     codeCoverageTool: Cobertura
>     summaryFileLocation: '$(System.DefaultWorkingDirectory)/coverage.xml'
>     reportDirectory: '$(System.DefaultWorkingDirectory)/htmlcov/'
>   displayName: 'Publish Python 2 test coverage'
> ```
> 6. [Secret variables](https://docs.microsoft.com/en-us/azure/devops/pipelines/process/variables?view=azure-devops&tabs=yaml%2Cbatch#secret-variables)<br>
> This is used the same as Jenkins credential. Variables' value need to be set at pipeline UI. 
> ```
> Yaml:
> variables:
>  GLOBAL_MYSECRET: $(mySecret) # this will not work because the secret variable needs to be mapped as env
>  GLOBAL_MY_MAPPED_ENV_VAR: $(nonSecretVariable) # this works because it's not a secret.
> - bash: |
>     echo "Using an input-macro works: $(mySecret)"
>     echo "Using the env var directly does not work: $MYSECRET"
>     echo "Using a global secret var mapped in the pipeline does not work either: $GLOBAL_MYSECRET"
>     echo "Using a global non-secret var mapped in the pipeline works: $GLOBAL_MY_MAPPED_ENV_VAR" 
>     echo "Using the mapped env var for this task works and is recommended: $MY_MAPPED_ENV_VAR"
>   env:
>     MY_MAPPED_ENV_VAR: $(mySecret) # the recommended way to map to an env variable
> 
> Output:
> Using an input-macro works: ***
> Using the env var directly does not work:
> Using a global secret var mapped in the pipeline does not work either:
> Using a global non-secret var mapped in the pipeline works: foo
> Using the mapped env var for this task works and is recommended: ***
> ```
> 7. [Send email](https://marketplace.visualstudio.com/items?itemName=rvo.SendEmailTask&ssr=false#overview)
> > *Note*:<br>
> > Need installation into mssonic<br>
> > Currently not available

### 7. Commonly used features
1. [Log Retention](https://docs.microsoft.com/en-us/azure/devops/pipelines/policies/retention?view=azure-devops&tabs=yaml)
 
> Configured by project, can't config in yaml

2. [Predefined variables](https://docs.microsoft.com/en-us/azure/devops/pipelines/build/variables?view=azure-devops&tabs=yaml#build-variables-devops-services)
> Example:<br>
> Build.BuildId<br>
> Build.BuildNumber

3. [Parameters](https://docs.microsoft.com/en-us/azure/devops/pipelines/process/runtime-parameters?view=azure-devops&tabs=script)
```
parameters:
- name: image
  displayName: Pool Image
  type: string
  default: ubuntu-latest
  values:
  - windows-latest
  - vs2017-win2016
  - ubuntu-latest
  - ubuntu-16.04
  - macOS-latest
  - macOS-10.14

jobs:
- job: build
  displayName: build
  pool: 
    vmImage: ${{ parameters.image }}
  steps:
  - script: echo building $(Build.BuildNumber) with ${{ parameters.image }}
```
4. [Pipeline flow control](https://docs.microsoft.com/en-us/azure/devops/pipelines/process/runtime-parameters?view=azure-devops&tabs=script#use-conditionals-with-parameters)
```
- ${{ if eq(parameters.image, 'ubuntu-16.04') }}:
    - script: echo "Running in ubuntu-16.04"
```
5. [Dependencies & conditions](https://docs.microsoft.com/en-us/azure/devops/pipelines/process/stages?view=azure-devops&tabs=yaml)
> Example:<br>
> [UI](https://dev.azure.com/mssonic/build/_build/results?buildId=4549&view=results)<br>
> [code](https://github.com/Azure/sonic-sairedis/blob/master/azure-pipelines.yml)
```
- stage: Test
  dependsOn: Build
  condition: succeeded('Build')
```
6. [Template](https://docs.microsoft.com/en-us/azure/devops/pipelines/process/templates?view=azure-devops)
> Example:<br>
> [Build image](https://github.com/Azure/sonic-buildimage/blob/master/.azure-pipelines/build-template.yml)<br>
> [Test image](https://github.com/Azure/sonic-mgmt/blob/master/.azure-pipelines/run-test-template.yml)
```
# File: templates/npm-with-params.yml

parameters:
- name: name  # defaults for any parameters that aren't specified
  default: ''
- name: vmImage
  default: ''

jobs:
- job: ${{ parameters.name }}
  pool: 
    vmImage: ${{ parameters.vmImage }}
  steps:
  - script: npm install
  - script: npm test


# File: azure-pipelines.yml

jobs:
- template: templates/npm-with-params.yml  # Template reference
  parameters:
    name: Linux
    vmImage: 'ubuntu-16.04'

- template: templates/npm-with-params.yml  # Template reference
  parameters:
    name: macOS
    vmImage: 'macOS-10.14'

- template: templates/npm-with-params.yml  # Template reference
  parameters:
    name: Windows
    vmImage: 'vs2017-win2016'
```
