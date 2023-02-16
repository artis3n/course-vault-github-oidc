<!--
  <<< Author notes: Header of the course >>>
  Read <https://skills.github.com/quickstart> for more information about how to build courses using this template.
  Include a 1280×640 image, course name in sentence case, and a concise description in emphasis.
  In your repository settings: enable template repository, add your 1280×640 social image, auto delete head branches.
  Next to "About", add description & tags; disable releases, packages, & environments.
  Add your open source license, GitHub uses Creative Commons Attribution 4.0 International.
-->

# Getting secrets from HashiCorp Vault with GitHub OIDC in Action workflows

Understand the principles behind configuring OIDC authentication from GitHub Action workflows to HashiCorp Vault for least-privilege access to secrets from CI/CD pipelines.

- **Who is this for**: Developers, security engineers, and operators of secrets management programs.
- **What you'll learn**: How to use GitHub OIDC for fine-grained role access to secrets in HashiCorp Vault.
- **What you'll build**: You will create three GitHub Action workflows retrieving secrets from Vault for the following use cases:
  1. Non-production secrets for integration testing within pull requests
  1. Production secrets for deployments of code from the main branch
  1. Segregating access to secrets between jobs in a workflow file with [GitHub Environments](https://docs.github.com/en/actions/deployment/targeting-different-environments/using-environments-for-deployment)
- **Prerequisites**:
  1. You should have basic proficiency working with HashiCorp Vault.
  You should understand how Vault roles correspond to HCL policies and how policies grant access to secrets.
  Completing HashiCorp's [Vault Getting Started](https://developer.hashicorp.com/vault/tutorials/getting-started) tutorial is sufficient.
  1. You should also understand the layout of a GitHub Actions workflow file.
  The GitHub tutorial [Continuous Integration](https://github.com/skills/continuous-integration) provides a good introduction.
- **How long**: This course is 4 steps long and takes about 1 hour to complete.

<!--
  <<< Author notes: Start of the course >>>
  Include start button, a note about Actions minutes,
  and tell the learner why they should take the course.
  Each step should be wrapped in <details>/<summary>, with an `id` set.
  The start <details> should have `open` as well.
  Do not use quotes on the <details> tag attributes.
-->

<details id=0 open>
<summary><h2>Step 0: How to start this course</h2></summary>

1. Make sure you are signed in to GitHub.
Above these instructions, right-click **Use this template** and open the link in a new tab.

    ![Use this template](https://user-images.githubusercontent.com/6969296/212726721-6ec2ba4b-4790-43de-b9db-0a6a9b93a227.png)

1. In the new tab, follow the prompts to create a new repository.
    - For owner, choose your personal account or an organization to host the repository.
    - We recommend creating a public repository — private repositories will [use Actions minutes](https://docs.github.com/en/billing/managing-billing-for-github-actions/about-billing-for-github-actions).

    ![Create a new repository](https://user-images.githubusercontent.com/6969296/212442636-86499765-9429-451a-8dfc-1d7f48fa836e.png)

1. After your new repository is created, wait about 20 seconds, then refresh that page.
Follow the step-by-step instructions in the new repository's README.

</details>

<!--
  <<< Author notes: Step 1 >>>
  Choose 3-5 steps for your course.
  The first step is always the hardest, so pick something easy!
  Link to docs.github.com for further explanations.
  Encourage users to open new tabs for steps!
  TBD-step-1-notes.
-->

<details id=1>
<summary><h2>Step 1: Introduction to OIDC</h2></summary>

_Welcome to "Getting secrets from HashiCorp Vault with GitHub OIDC in Action workflows!" :wave:_

Leveraging GitHub OIDC to Vault enables secure, short-lived, passwordless authentication for GitHub Actions workflows.
This course will teach you how to configure a GitHub Actions workflow to retrieve secrets from Vault using OIDC.
You will learn how to use GitHub's JWT claims to create Vault roles with fine-grained access to secrets.
You will also learn how to use GitHub Environments to segregate access to secrets between jobs.

**What is _OpenID Connect (OIDC)_?**:
OpenID Connect is an authentication protocol built on top of OAuth 2.0 (which is an authorization protocol).
OIDC is a way to authenticate a user or service to a third-party identity provider (IDP) using a JSON Web Token (JWT).
Instead of managing login credentials, the token exposes parameters (known as `claims`) that can be used to authorize access to resources.

**How does a workflow sign in to Vault with OIDC?**:
GitHub authenticates directly to Vault by presenting a JWT with certain claims.
Vault roles are pre-configured to bind to a combination of claims specified by the token.
When a workflow presents a token to Vault, Vault verifies the token's signature and claims.
If a role configuration matches the presented claims, Vault returns an auth token to the workflow.

On the user's side, we can use Hashicorp's [vault-action](https://github.com/hashicorp/vault-action) GitHub Action to retrieve secrets from Vault using OIDC.
Let's explore a "hello world" example.

### :keyboard: Activity: OIDC Hello World

You may see some workflows fail for future steps, like "Step 3, Fine-grained permissions - branches".
That is ok!
We will get to them later.
You can ignore those failures for now.

1. Open your repo in a new browser tab, and work on these steps in your second tab while you read the instructions in this tab.
1. Go to the **Actions tab**.
1. On the left-hand side, under "All workflows," select **Step 1, OIDC Hello World**.
1. On the right-hand side, open the **Run workflow** menu and click **Run workflow**.

    ![Manually run workflow](https://user-images.githubusercontent.com/6969296/212499178-7cfc18f9-6860-4d88-a21d-02806b358bb2.png)

1. After a few seconds, the workflow run will appear. Click into it.
It can take between 20-40 seconds for this workflow to complete.
Wait until the workflow completes - you should see a green checkmark.

    ![Workflow succeeds](https://user-images.githubusercontent.com/6969296/212499911-42871f96-7e11-4cbf-8d23-5fd1bc0cf480.png)

1. Wait about 20 seconds then refresh this README page for the next step.

Don't worry if you don't understand everything that happened in this step.
We will go over the details in the next step.

</details>

<!--
  <<< Author notes: Step 2 >>>
  Start this step by acknowledging the previous step.
  Define terms and link to docs.github.com.
  TBD-step-2-notes.
-->

<details id=2>
<summary><h2>Step 2: Fine-grained permissions - pull requests</h2></summary>

_You successfully authenticated and retrieved a Vault secret using GitHub OIDC! :tada:_

What did we just do, and how?

### The GitHub OIDC Workflow

Let's understand the [workflow file that you just ran](/.github/workflows/1-oidc-hello-world.yml).

```yml
permissions:
  # Need `contents: read` to checkout the repository
  # Need `id-token: write` to use the GitHub OIDC token
  # Reference: https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/configuring-openid-connect-in-cloud-providers#adding-permissions-settings
  contents: read
  id-token: write
```

To enable a workflow to use OIDC, you must grant the `id-token: write` permission.
When you start defining permissions, all the default permissions are removed, so you have to add them back in.
Typically, you will always need `contents: read` to checkout the repository.

You can read more about the required workflow permissions on [GitHub's docs](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/about-security-hardening-with-openid-connect#adding-permissions-settings).
Also see ["Permissions for the `GITHUB_TOKEN`"](https://docs.github.com/en/actions/security-guides/automatic-token-authentication#permissions-for-the-github_token).

```yml
# Initializes Vault with a JWT backend for GitHub OIDC
# and sets up a role, policy, and secret to retrieve.
- name: Setup Vault
  env:
    VAULT_ADDR: http://127.0.0.1:8200
  run: ./.github/script/1-setup.sh
```

For the purposes of this course, we set up a local Vault instance for you to authenticate against using OIDC.
We'll take a look at this setup script in a moment.

```yml
- name: Retrieve Secrets
  uses: hashicorp/vault-action@v2.5.0
  id: secrets
  with:
    url: http://127.0.0.1:8200
    path: gha
    method: jwt
    exportEnv: false
    # The previous step created a `hello-world` Vault role in `.github/script/1-setup.sh`.
    # The role is configured to accept the GitHub OIDC token if it is issued by GitHub - therefore allowing any repo on GitHub.com.
    # More specifically, if the `iss` claim is `https://token.actions.githubusercontent.com`.
    role: hello-world
    # Retrieve a secret from the KV v2 secrets engine at the mount point `secret`.
    secrets: |
      secret/data/foobar hello | WORLD ;
```

Here we use HashiCorp's [vault-action](https://github.com/hashicorp/vault-action) to retrieve a secret from Vault using OIDC.
We specify the Vault role we want (`hello-world`), whatever secrets we want to retrieve, and, optionally but recommended for clarity, what output variable we'd like to assign to each secret.
In this case, we save the output of the secret to the `WORLD` variable.

If our OIDC configuration for the `hello-world` role matches the token that GitHub presents, our workflow will get an auth token and the requested secrets (assuming the Vault role's policy permits those paths).

```yaml
- name: Print secrets
  run: |
    echo "Hello ${{ steps.secrets.outputs.WORLD }}!"
    echo "Hello ${{ steps.secrets.outputs.WORLD }}!" >> "${GITHUB_STEP_SUMMARY}"
```

Finally, since we've set `id: secrets` attribute on the `hashicorp/vault-action` step, we can access our secret using the syntax `steps.secrets.outputs.WORLD`.

If you inspect the workflow run output, you'll see that GitHub automatically redacts the secret from the logs.

![Inspect workflow run output](https://user-images.githubusercontent.com/6969296/212510889-7d7f9c6a-b706-4c74-aa46-e6cecdef30e0.png)

Our workflow also echoes the secret to the workflow step summary, where the value remains redacted.

![Inspect workflow step summary](https://user-images.githubusercontent.com/6969296/212511387-38764a5d-c04e-43d0-9746-192fac51205c.png)

`hashicorp/vault-action` [configures this for us](https://github.com/hashicorp/vault-action#masking---hiding-secrets-from-logs).
How convenient!
Note that this only obscures the value from output logs - someone with the ability to edit your workflow and inject code can still read the secret.

### The Vault Setup

Let's look at the Vault commands we ran in the [setup script](/.github/script/1-setup.sh).

```bash
vault auth enable -path=gha jwt
vault write auth/gha/config \
bound_issuer="https://token.actions.githubusercontent.com" \
oidc_discovery_url="https://token.actions.githubusercontent.com"
```

These are the base requirements to enable OIDC authentication in Vault.
We created a new authentication backend at the path `gha` (you can choose whatever path name you prefer) and configured it to receive OIDC tokens from GitHub.
The only requirements are the `bound_issuer` and `oidc_discovery_url` fields.

To learn more, check out "[Configuring OpenID Connect in HashiCorp Vault](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/configuring-openid-connect-in-hashicorp-vault#adding-the-identity-provider-to-hashicorp-vault)".

```bash
# Create a secret
vault kv put secret/foobar hello=world
# Add OIDC role and policy
vault policy write hello-policy - << EOF
path "secret/data/foobar" {
  capabilities = ["read"]
}
EOF
```

Then, we created a secret and a basic policy to access it.

```bash
vault write auth/gha/role/hello-world - << EOF
{
  "role_type": "jwt",
  "user_claim": "actor",
  "bound_claims": {
      "iss": "https://token.actions.githubusercontent.com"
  },
  "policies": ["hello-policy"],
  "ttl": "60s"
}
EOF
```

Finally, we created a role that binds to the `iss` claim in GitHub's OIDC token.
This claim means that anyone anywhere on github.com can authenticate to this Vault instance and be granted the `hello-policy` policy.
**You don't want to use this in real life!** :wink: :scream:
We'll explore real-world examples of fine-grained access in the next steps of this course.

Let's look at the other values:
- `role_type` should always be `jwt` for GitHub OIDC.
- `user_claim` is the value that Vault uses to identify the user.
Its data will become the `auth.display_name` value in Vault's audit logs.
In this case, we set the `user_claim` to be `actor`, which means Vault's audit log will record the GitHub username of the entity who ran the workflow.
This can be a GitHub user or something like Dependabot, depending on what triggers the workflow.
- `bound_claims` is a map of the claims that all must be present in GitHub's OIDC token in order to successfully authenticate to this role.
There must be at least one bound claim.
We'll see how to add more claims soon.
- `policies` is a list of policies that will be granted to the Vault token when a workflow authenticates to this role.
- `ttl` is the time-to-live for the token that Vault returns to the workflow.
In this case, we've set the generated Vault token to expire after 60 seconds.
While the workflow runs in 20-40 seconds, the time between retrieving the Vault token and accessing secrets inside the workflow is about 1-2 seconds.
You could set the TTL to be really short!
A short TTL means that an attacker who gains access to your CI/CD environment will have very little time to do anything malicious. :sunglasses:

### :keyboard: Activity: Fine-grained permissions - pull requests

Wow, that was a lot of information! :exploding_head:

Give yourself a pat on the back for making it here.
Next, you will create your own OIDC Vault role!
This role will allow a workflow to authenticate to Vault, but only if the workflow runs inside of a pull request.

1. Open this repository in a code editor or GitHub Codespace.
1. From the code editor, checkout a new branch.
**For this activity, you must open a pull request from a branch other than `main`.**
    ```bash
    git checkout -b step2
    ```
1. In your code editor, open the file `.github/workflows/2-pull-request.yml`.
1. Locate the step `name: Create an OIDC Role`.
1. Replace this step with the following code.
**Replace the `YOUR_REPO` section with the `org/repo` string that applies to the repository you created from this course**.
For example, the course template hosted at <https://github.com/artis3n/course-vault-github-oidc> would use: `"sub": "repo:artis3n/course-vault-github-oidc:pull_request"`.
The workflow won't run unless the `org/repo` string is correct for your repository.
    ```yml
    - name: Create an OIDC Role
      env:
        VAULT_ADDR: http://127.0.0.1:8200
      run: |
        vault write auth/gha/role/GIVE_ME_A_NAME - << EOF
        {
          "role_type": "jwt",
          "user_claim": "actor",
          "bound_claims": {
            "sub": "repo:YOUR_REPO:pull_request"
          },
          "policies": ["pr-policy"],
          "ttl": "60s"
        }
        EOF
    ```
1. Don't forget to pick a name for your Vault role as well!
In the same code block, replace `GIVE_ME_A_NAME` with an alphanumeric (plus `_` and `-`) name of your choosing.
1. Locate the next step in the job, `name: Retrieve Secrets`.
    ```yml
    - name: Retrieve Secrets
      uses: hashicorp/vault-action@v2.4.3
      id: secrets
      with:
        # TODO: Don't forget to enter the role name you created above!
        role: ""
        # Retrieve a secret from the KV v2 secrets engine at the mount point `secret`.
        secrets: |
          secret/data/development access_token | ACCESS_TOKEN ;
        # Required configuration, do not modify
        url: http://127.0.0.1:8200
        path: gha
        method: jwt
        exportEnv: false
    ```
1. Everything is set up for you, however the `role: ""` is missing.
Enter the `GIVE_ME_A_NAME` role name you chose in the previous step.
    ```yml
    role: "GIVE_ME_A_NAME"  # Enter the same role name you previously chose!
    ```
1. Commit these changes to your branch and push your branch to GitHub.
Open a pull request from your branch to the `main` branch.
    ```bash
    git add .
    git commit -m "Add OIDC role for pull requests"
    gh pr create --title "Fine-grained permissions - pull requests" --body "This pull request adds a new workflow that uses Vault to retrieve a secret only if the workflow runs inside a pull request."
    ```

    > **Note**
    >
    > The `gh` command comes from the [GitHub CLI](https://cli.github.com/).
    > You can create the pull request from the UI as well.
1. Go to the **Pull Requests** tab and open your new pull request.
After a few seconds, you should observe the `Step 2, Fine-grained permissions - pull requests` workflow begin to run on your PR.

    ![Pull request workflow running](https://user-images.githubusercontent.com/6969296/212520410-1f4a73ba-67db-4471-bf2c-fcc2d819f473.png)

1. Wait until your `Step 2, Fine-grained permissions - pull requests` workflow completes - you should see a green checkmark.
If the workflow fails, check that your `org/repo` value is correct for your current repository!
Ensure the `role` name matches between both steps in the workflow.
1. Once the PR workflow is successful, wait about 20 seconds further, then refresh this README page for the next step.

Once the workflow is green, feel free to merge the PR or leave it as-is before moving on to the next step.

</details>

<!--
  <<< Author notes: Step 3 >>>
  Start this step by acknowledging the previous step.
  Define terms and link to docs.github.com.
  TBD-step-3-notes.
-->

<details id=3>
<summary><h2>Step 3: Fine-grained permissions - branches</h2></summary>

_Nice work finishing Step 2: Fine-grained permissions - pull requests :sparkles:_

In the Step 2 activity, you created a Vault role that allowed a workflow to authenticate to Vault if it was run by a `pull_request` workflow trigger.
After retrieving the secret, the workflow printed out an assertion that it received the value:

```yml
- name: Use the secret
  # Dummy example showing the secret is not an empty string
  run: |
    echo "::notice::🔐 Logging in to secure system! ${{ steps.secrets.outputs.ACCESS_TOKEN != '' }}"
```

If you inspect the job summary for the `Step 2, Fine-grained permissions - pull requests` workflow, you should see the delivered message ends with `true`.

![Secure system message on job summary](https://user-images.githubusercontent.com/6969296/212549524-e430a8d9-96d4-4210-9fa6-3bc6ae903cec.png)

Given any use of our secrets is redacted from GitHub's logs, this is a contrived example to demonstrate that `steps.secrets.outputs.ACCESS_TOKEN` is not empty - the value of the secret has been populated from Vault.

If you haven't already, merge your pull request and attempt to manually run the `Step 2, Fine-grained permissions - pull requests` workflow - select it from under the "All workflows" pane similar to what you did in Step 1.
The workflow should fail with a 400 error trying to authenticate to Vault - because you're running it via a manual `workflow_dispatch` instead of a `pull_request`!
Optionally, you can modify the workflow and add a `push:` trigger and try that as well.
Authentication to Vault will also fail because the GitHub JWT's claims no longer match the bound subject (`sub`) claim we defined for the Vault role.

### Bound claims

We can bind Vault roles to any claim present in the JWT.
The `sub` claim is the primary method we have to configure GitHub OIDC Vault roles.

To learn more, check out ["Understanding the OIDC token"](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/about-security-hardening-with-openid-connect#understanding-the-oidc-token).

```json
{
  "typ": "JWT",
  "alg": "RS256",
  "x5t": "example-thumbprint",
  "kid": "example-key-id"
}
{
  "jti": "example-id",
  "sub": "repo:octo-org/octo-repo:environment:prod",
  "environment": "prod",
  "aud": "https://github.com/octo-org",
  "ref": "refs/heads/main",
  "sha": "example-sha",
  "repository": "octo-org/octo-repo",
  "repository_owner": "octo-org",
  "actor_id": "12",
  "repository_visibility": "private",
  "repository_id": "74",
  "repository_owner_id": "65",
  "run_id": "example-run-id",
  "run_number": "10",
  "run_attempt": "2",
  "actor": "octocat",
  "workflow": "example-workflow",
  "head_ref": "",
  "base_ref": "",
  "event_name": "workflow_dispatch",
  "ref_type": "branch",
  "job_workflow_ref": "octo-org/octo-automation/.github/workflows/oidc.yml@refs/heads/main",
  "iss": "https://token.actions.githubusercontent.com",
  "nbf": 1632492967,
  "exp": 1632493867,
  "iat": 1632493567
}
```

In our Step 1 hello world activity, we bound the Vault role to the `iss` claim.
This will always be `https://token.actions.githubusercontent.com` for workflows on github.com, so that is not a very good claim to restrict fine-grained access.

In our Step 2 activity, we took a real-world approach and bound the Vault role to the `sub` claim.
The subject can be constructed from [various filters](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/about-security-hardening-with-openid-connect#example-subject-claims).
The options boil down to:
- `pull_request` (but no other) workflow triggers
    ```
    repo:<orgName/repoName>:pull_request
    ```
- A single branch or tag on the repository
    ```
    repo:<orgName/repoName>:ref:refs/heads/<branchName>
    repo:<orgName/repoName>:ref:refs/tags/<tagName>
    ```
- Multiple branches or tags using a wildcard (`*`) in the subject claim
    ```
    repo:<orgName/repoName>:ref:refs/heads/feature/*
    repo:<orgName/repoName>:ref:refs/tags/v1.*
    ```
- A single [GitHub Environment](https://docs.github.com/en/actions/deployment/targeting-different-environments/using-environments-for-deployment)
    ```
    repo:<orgName/repoName>:environment:<environmentName>
    ```

You could presumably use a wildcard for multiple GitHub Environments as well, but I have not come across a use case for that.

You don't have to use the `sub` claim!
For example, when designing a workflow meant to run when Dependabot opens a PR or merges code, you could bind the Vault role to the `actor` claim.
```json
"bound_claims": {
    "actor": "dependabot[bot]"
},
```

Or, if you have a workflow that can run at any time, but the Vault role should only be used for one specific repository, you can bind the Vault role to the `repository` claim.
```json
"bound_claims": {
    "repository": "myorg/myrepo"
},
```

However, `sub`, and combining `sub` with other claims, is the most powerful option we have to construct fine-grained access control.

### :keyboard: Activity: Fine-grained permissions - branches

Let's apply what we've learned to our next workflow.
You're going to follow the instructions from our previous activity, but this time you're going to bind the Vault role to the `main` branch.
Vault authentication in this workflow will succeed only if the workflow is triggered by a push to the `main` branch.

1. Open this repository in a code editor or GitHub Codespace.
If you still have this repository open from the previous activity, make sure to pull the latest changes from the `main` branch.
    ```bash
    git checkout main
    git pull
    ```
1. From the code editor, make sure you are working on the `main` branch.
**For this activity, you must push code to the `main` branch.**
1. In your code editor, open the file `.github/workflows/3-main-branch.yml`.
1. Locate the step `name: Create an OIDC Role`.
1. Replace this step with the following code.
**Replace the `YOUR_REPO` section with the `org/repo` string that applies to the repository you created from this course**.
For example, the course template hosted at <https://github.com/artis3n/course-vault-github-oidc> would use: `"sub": "repo:artis3n/course-vault-github-oidc:ref:refs/heads/main"`.
The workflow won't run unless the `org/repo` string is correct for your repository.
    ```yml
    - name: Create an OIDC Role
      env:
        VAULT_ADDR: http://127.0.0.1:8200
      run: |
        vault write auth/gha/role/GIVE_ME_A_NAME - << EOF
        {
          "role_type": "jwt",
          "user_claim": "actor",
          "bound_claims": {
            "sub": "repo:YOUR_REPO:ref:refs/heads/main"
          },
          "policies": ["main-policy"],
          "ttl": "60s"
        }
        EOF
    ```
1. Don't forget to pick a name for your Vault role as well!
   In the same code block, replace `GIVE_ME_A_NAME` with an alphanumeric (plus `_` and `-`) name of your choosing.
1. Locate the next step in the job, `name: Retrieve Secrets`.
    ```yml
    - name: Retrieve Secrets
      uses: hashicorp/vault-action@v2.4.3
      id: secrets
      with:
        # TODO: Don't forget to enter the role name you created above!
        role: ""
        # Retrieve a secret from the KV v2 secrets engine at the mount point `secret`.
        secrets: |
          secret/data/production access_token | ACCESS_TOKEN ;
        # Required configuration, do not modify
        url: http://127.0.0.1:8200
        path: gha
        method: jwt
        exportEnv: false
    ```
1. Everything is set up for you, however the `role: ""` is missing.
Enter the `GIVE_ME_A_NAME` role name you chose in the previous step.
    ```yml
    role: "GIVE_ME_A_NAME"  # Enter the same role name you previously chose!
    ```
1. Commit these changes to the `main` branch and push them to GitHub.
    ```bash
    git checkout main
    git add .
    git commit -m "Fine-grained permissions - branches"
    git push
    ```
1. Open your repo in a new browser tab, and work on these steps in your second tab while you read the instructions in this tab.
1. Go to the **Actions** tab.
1. On the left-hand side, under "All workflows," select **Step 3, Fine-grained permissions - branches**.
After a few seconds, you should observe a new workflow start up.
1. Wait until the workflow completes - you should see a green checkmark.
    - If the workflow fails, check that your `org/repo` value is correct for your current repository!
Ensure the `role` name matches between both steps in the workflow.
    - If you continue to receive an error, pay close attention to the `sub` claim!
It should end with `:ref:refs/heads/main`.
1. Once this workflow is successful, wait about 20 seconds further, then refresh this README page for the next step.

</details>

<!--
  <<< Author notes: Step 4 >>>
  Start this step by acknowledging the previous step.
  Define terms and link to docs.github.com.
  TBD-step-4-notes.
-->

<details id=4>
<summary><h2>Step 4: Fine-grained permissions - environments</h2></summary>

_Nicely done with Step 3: Fine-grained permissions - branches! :partying_face:_

Our last workflow will demonstrate how to provide fine-grained access control to Vault roles inside the same workflow file using [GitHub Environments](https://docs.github.com/en/actions/deployment/targeting-different-environments/using-environments-for-deployment).
We'll follow the same instructions as in the previous activities, but this time we'll have two jobs to configure in the same workflow file.
We'll also need to create the GitHub Environments on our repository.

### :keyboard: Activity: Fine-grained permissions - environments

1. Open this repository in a code editor or GitHub Codespace.
If you still have this repository open from the previous activity, make sure to pull the latest changes from the `main` branch.
    ```bash
    git checkout main
    git pull
    ```
1. From the code editor, make sure you are working on the `main` branch.
**For this activity to properly update you to the next step, you must push code to the `main` branch.**
Environments are not restricted to the `main` branch by default, but this workflow must run from the `main` branch for this course to properly track your progress.
1. In your code editor, open the file `.github/workflows/4-environment.yml`.
1. There are two jobs in this workflow file!
`staging` and `prod`.
We'll configure a Vault role for each job.
Notice the `staging` job includes the `environment: Staging` attribute and the `prod` job includes the `environment: Production` attribute.
To learn more about using Environments in workflow files, see [GitHub's workflow syntax for environments](https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions#jobsjob_idenvironment).
    ```yml
    staging:
      name: Retrieve staging secrets
      # We need to create a "Staging" Environment and bind it to Vault!
      environment: Staging

      # ...

    prod:
      name: Retrieve production secrets
      # We need to create a "Production" Environment and bind it to Vault!
      environment: Production
    ```
1. Under the **staging** job, locate the step `name: Create an OIDC Role`.
1. Under the **staging** job, replace this step with the following code.
**Replace the `YOUR_REPO` section with the `org/repo` string that applies to the repository you created from this course**.
For example, the course template hosted at <https://github.com/artis3n/course-vault-github-oidc> would use: `"sub": "repo:artis3n/course-vault-github-oidc:environment:Staging"`.
The workflow won't run unless the `org/repo` string is correct for your repository.
    ```yml
    - name: Create an OIDC Role
      env:
        VAULT_ADDR: http://127.0.0.1:8200
      run: |
        vault write auth/gha/role/GIVE_ME_A_NAME - << EOF
        {
          "role_type": "jwt",
          "user_claim": "actor",
          "bound_claims": {
            "sub": "repo:YOUR_REPO:environment:Staging"
          },
          "policies": ["staging-policy"],
          "ttl": "60s"
        }
        EOF
    ```
    > **Note**
    >
    > **Environment names are case-sensitive.** `staging` is not the same as `Staging`.
1. Don't forget to pick a name for your Vault role as well!
You should use different names for the staging and production Vault roles.
In the same code block, replace `GIVE_ME_A_NAME` with an alphanumeric (plus `_` and `-`) name of your choosing.
1. Under the **staging** job, locate the next step in the job, `name: Retrieve Secrets`.
    ```yml
    - name: Retrieve Secrets
      uses: hashicorp/vault-action@v2.4.3
      id: secrets
      with:
        # TODO: Don't forget to enter the role name you created above!
        role: ""
        # Retrieve a secret from the KV v2 secrets engine at the mount point `secret`.
        secrets: |
          secret/data/staging access_token | ACCESS_TOKEN ;
        # Required configuration, do not modify
        url: http://127.0.0.1:8200
        path: gha
        method: jwt
        exportEnv: false
    ```
1. Everything is set up for you, however the `role: ""` is missing.
Enter the `GIVE_ME_A_NAME` role name you chose in the previous step.
    ```yml
    role: "GIVE_ME_A_NAME"  # Enter the same role name you previously chose!
    ```
1. Now repeat both updates for the **prod** job.
1. Under the **prod** job, locate the step `name: Create an OIDC Role`.
1. Under the **prod** job, replace this step with the following code.
**Replace the `YOUR_REPO` section with the `org/repo` string that applies to the repository you created from this course**.
For example, the course template hosted at <https://github.com/artis3n/course-vault-github-oidc> would use: `"sub": "repo:artis3n/course-vault-github-oidc:environment:Production"`.
The workflow won't run unless the `org/repo` string is correct for your repository.
    ```yml
    - name: Create an OIDC Role
      env:
        VAULT_ADDR: http://127.0.0.1:8200
      run: |
        vault write auth/gha/role/GIVE_ME_A_NAME - << EOF
        {
          "role_type": "jwt",
          "user_claim": "actor",
          "bound_claims": {
            "sub": "repo:YOUR_REPO:environment:Production"
          },
          "policies": ["prod-policy"],
          "ttl": "60s"
        }
        EOF
    ```
    > **Note**
    >
    > **Environment names are case-sensitive.** `production` is not the same as `Production`.
1. Don't forget to pick a name for your Vault role as well!
You should use different names for the staging and production Vault roles.
In the same code block, replace `GIVE_ME_A_NAME` with an alphanumeric (plus `_` and `-`) name of your choosing.
1. Under the **prod** job, locate the next step in the job, `name: Retrieve Secrets`.
    ```yml
    - name: Retrieve Secrets
      uses: hashicorp/vault-action@v2.4.3
      id: secrets
      with:
        # TODO: Don't forget to enter the role name you created above!
        role: ""
        # Retrieve a secret from the KV v2 secrets engine at the mount point `secret`.
        secrets: |
          secret/data/production access_token | ACCESS_TOKEN ;
        # Required configuration, do not modify
        url: http://127.0.0.1:8200
        path: gha
        method: jwt
        exportEnv: false
    ```
1. Everything is set up for you, however the `role: ""` is missing.
Enter the `GIVE_ME_A_NAME` role name you chose in the previous step.
    ```yml
    role: "GIVE_ME_A_NAME"  # Enter the same role name you previously chose!
    ```

Great work! :computer:

_Don't commit and push these changes just yet!_

We've set up our workflow file to retrieve secrets from GitHub Environments, but we haven't created the Environments yet.
Let's do that now.

### :keyboard: Activity: Create the GitHub Environments

1. Open your repo in a new browser tab, and work on these steps in your second tab while you read the instructions in this tab.
1. Go to the **Settings tab**.
1. On the left-hand side, select **Environments** then **New environment**.

    ![Environment settings](https://user-images.githubusercontent.com/6969296/212564551-12594c1b-63d9-4826-a291-faff012d98af.png)

1. Enter `Staging` as the name of the environment and click **Configure environment**.

    ![Name environment staging](https://user-images.githubusercontent.com/6969296/212564575-498e47af-97df-4959-b071-8aefafba99b7.png)

1. For OIDC to Vault we do not need to configure any additional settings on the environment, however we can always include additional settings should we want further access controls (such as restricting a production environment to the `main` branch).

    ![No environment configuration](https://user-images.githubusercontent.com/6969296/212564636-f8eccc66-25d7-4f2f-b36c-b2101acd9645.png)

1. Now repeat the same steps to create a `Production` environment.
Just as with `Staging`, do not configure any additional settings on the environment for this activity.

You should now have two environments configured on your repository, `Staging` and `Production`.

![List of environments](https://user-images.githubusercontent.com/6969296/212564665-d44c530c-f4dc-4917-bbec-23c089146f4b.png)

### :keyboard: Activity: Run the workflow!

We're now ready to run the workflow!

1. Commit the changes from these two activities and push them to GitHub.
    ```bash
    git checkout main
    git add .
    git commit -m "Fine-grained permissions - environments"
    git push
    ```
1. Open your repo in a new browser tab, and work on these steps in your second tab while you read the instructions in this tab.
1. Go to the **Actions** tab.
1. On the left-hand side, under "All workflows," select **Step 4, Fine-grained permissions - environments**.
1. On the right-hand side, open the **Run workflow** menu and click **Run workflow**.
1. Wait until the workflow completes - you should see both the `staging` and `production` jobs complete successfully with a green checkmark.
If the workflow fails, check the previous activities to ensure you've created two environments and configured both Vault roles in the workflow file.

    ![Both environments deploy successfully](https://user-images.githubusercontent.com/6969296/212571497-39feb61a-c1b6-4d3f-8411-9ad3ea029794.png)

1. Once this workflow is successful, wait about 20 seconds further, then refresh this README page for the next step.

</details>

<!--
  <<< Author notes: Finish >>>
  Review what we learned, ask for feedback, provide next steps.
-->

<details id=5>
<summary><h2>Finish</h2></summary>

_Congratulations friend, you've completed this course! :1st_place_medal:_

Here's a recap of all the tasks you've accomplished in your repository:
- Configure Vault to accept GitHub OIDC authentication requests
- Customize the `bound_claims` of a Vault role to provide fine-grained access control across workflows
- Create a workflow that can only retrieve secrets when triggered by a pull request
- Create a workflow that can only retrieve secrets when triggered by a push to the `main` branch
- Create jobs in a workflow that can only retrieve secrets when assigned to a specific GitHub Environment, and can't access each other's secrets

Remember that configuring Vault roles should typically happen separately from consuming secrets, so you'll likely want to create a separate workflow that creates Vault roles.
However, for the sake of this course, we've configured Vault roles in the same workflows that consumed secrets.

### What's next?

- We'd love to hear what you thought of this course [in our discussion board](https://github.com/artis3n/course-vault-github-oidc/discussions).
- You can combine multiple claims in a single Vault role to provide even more fine-grained access control!
For example, learn how to combine `sub` and `job_workflow_ref` to [provide secrets for reusable workflows](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/using-openid-connect-with-reusable-workflows).
- Read [this comprehensive article](https://www.digitalocean.com/blog/fine-grained-rbac-for-github-action-workflows-hashicorp-vault) to learn how DigitalOcean employs this GitHub OIDC pattern for streamlined secrets management.
- Use this [Terraform module](https://github.com/digitalocean/terraform-vault-github-oidc) from DigitalOcean to help manage your GitHub OIDC Vault role configurations.

</details>

<!--
  <<< Author notes: Footer >>>
  Add a link to get support, GitHub status page, code of conduct, license link.
-->

---

Get help: [Post in our discussion board](https://github.com/artis3n/course-vault-github-oidc/discussions) &bull; Something not working? [File an issue ticket](https://github.com/artis3n/course-vault-github-oidc/issues)

&copy; 2022 Ari Kalfus &bull; [Code of Conduct](https://www.contributor-covenant.org/version/2/1/code_of_conduct/code_of_conduct.md) &bull; [CC-BY-4.0 License](https://creativecommons.org/licenses/by/4.0/legalcode)
