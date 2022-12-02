# inframap-action

> Automatic generation of diagrams from terraform plan or state!

A github action that will:

* Create a **simplified** diagram of your terraform plan or current state using [inframap](https://www.cycloid.io/open-source/inframap)
* Commit the diagram to your branch
* Optionally, add the diagram to your PR
* By default, only runs when there are changes to terraform files

![Example Diagram / PR](/docs/pr.png)

# Usage

## A gotcha before you start!

If for any reason you or your organisation are limiting permissions in your workflow file, you will need to add the following permissions to your workflow file so that the action can commit the diagram to your branch:

```yaml
permissions:
  contents: write
```

## Create diagram and commit back to repository

Assuming your terraform files exist in a directory called `terraform/` and your file should be committed to `docs/plan.png`:

```yaml
name: Docs
on:
  push:
    branches-ignore:
      - main

jobs:
  diag:
    name: Create inframap diagram
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v3

      - name: Create & commit diagram with PR
        uses: erzz/inframap-action@v1
```

## Create diagram, commit to repository and add to PR

Assuming your terraform files exist in a directory called `terraform/` and your file should be committed to `docs/plan.png`: and you want to add the diagram to your PR:

```yaml
name: Docs
on: pull_request

jobs:
  diag:
    name: Create inframap diagram
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v3

      - name: Create & commit diagram with PR
        uses: erzz/inframap-action@v1
        with:
          pr-comment: true
```

## Running against a terraform state instead of plan

For this you will need to get your state file first and then pass it to the action.

```yaml
name: Docs
on: pull_request

jobs:
  diag:
    name: Create inframap diagram
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v3

      - name: Authenticate with your state backend
        run: | # GCP Auth action or similar

      - name: Get state file
        run: |
          terraform init
          terraform state pull > state.json

      - name: Create & commit diagram with PR
        uses: erzz/inframap-action@v1
        with:
          pr-comment: true
          plan-files: state.json
```

# Inputs

| Name | Description | Default | Required |
|------|-------------|:-----:|:-----:|
| plan-files | Path to a directory or specific file containing your terraform plan file(s) or state | `terraform/` | No |
| inframap-flags | Pass any additional inframap flags here | ` ` | No |
| inframap-version | The version of inframap to use. | `0.6.7` | No |
| output-filename | Override the path & name of the PNG file created | `docs/plan.png` | No |
| commit-email | The email address to use for the commit | Github actions bot | No |
| commit-message | Override the commit message used | `docs(infra): add generated diagrams` | No |
| pr-comment | If set to true, will post diagram as comment to PR | `false` | No |
| always-run | Default behaviour is to not run if tf files are not updated. To force creation every time, set to `true` | `false` | No |
| token | A github token to add PR comment. Replace with a PAT if required | `${{ github.token }}` | No |


# What do you mean by "simplified"?

The beauty of inframap is that it will simplify your terraform plan or state to a diagram that is easy to understand compared to super complex and detailed views provided by `terraform graph` and other tools.

Various types of resources will be grouped together, some even skipped, so that the results is a simplified view of your infrastructure.

There are numerous flags you can pass with the `inframap-flags` input to customize the diagram, but the default is to simplify the diagram as much as possible.

At the time of writing the following flags are supported and can be passed to the action using the `inframap-flags` input:

```
inframap generate --help
Generates the Graph from TFState or HCL

Usage:
  inframap generate [FILE] [flags]

Examples:
inframap generate state.tfstate
cat state.tfstate | inframap generate

Flags:
      --clean            Clean will the generated graph will not have any Node that does not have a connection/edge (default true)
      --connections      Connections will apply the logic of the provider to remove resources that are not nodes (default true)
      --external-nodes   Toggle the addition of external nodes like 'im_out' (used to show ingress connections) (default true)
  -h, --help             help for generate
      --printer string   Type of printer to use for the output. Supported ones are: dot (default "dot")
      --raw              Raw will not use any specific logic from the provider, will just display the connections between elements. It's used by default if none of the Providers is known
      --show-icons       Toggle the icons on the printed graph (default true)

Global Flags:
      --hcl       Forces to use HCL parser
      --tfstate   Forces to use TFState parser
```