<!--
  <<< Author notes: Header of the course >>>
  Read <https://skills.github.com/quickstart> for more information about how to build courses using this template.
  Include a 1280×640 image, course name in sentence case, and a concise description in emphasis.
  In your repository settings: enable template repository, add your 1280×640 social image, auto delete head branches.
  Next to "About", add description & tags; disable releases, packages, & environments.
  Add your open source license, GitHub uses Creative Commons Attribution 4.0 International.
-->

# Getting Secrets From HashiCorp Vault With GitHub OIDC in Action Workflows

Understand the principles behind configuring OIDC authentication from GitHub Action workflows to HashiCorp Vault for least-privilege access to secrets from CI/CD pipelines.

- **Who is this for**: Developers, Security engineers, and operators of secrets management programs inside organizations.
- **What you'll learn**: How to use GitHub OIDC for fine-grained role access to secrets in HashiCorp Vault.
- **What you'll build**: You will create three GitHub Action workflows retrieving secrets from Vault for the following use cases:
  1. Nonproduction secrets for integration testing within pull requests
  1. Production secrets for deployments of code from the main branch
  1. Segregating access to secrets between jobs in a workflow file with [GitHub Environments](https://docs.github.com/en/actions/deployment/targeting-different-environments/using-environments-for-deployment)
- **Prerequisites**:
  1. You should have basic proficiency working with HashiCorp Vault.
  You should understand how Vault roles correspond to HCL policies and how policies grant access to secrets.
  Completing HashiCorp's Vault [Getting Started](https://developer.hashicorp.com/vault/tutorials/getting-started) tutorial is sufficient.
  1. You should also understand the layout of a GitHub Actions workflow file.
  The GitHub tutorial [Continuous Integration](https://github.com/skills/continuous-integration) provides a good introduction.
- **How long**: This course is **TBD-step-count** steps long and takes less than **TBD-duration** to complete.

<!--
  <<< Author notes: Start of the course >>>
  Include start button, a note about Actions minutes,
  and tell the learner why they should take the course.
  Each step should be wrapped in <details>/<summary>, with an `id` set.
  The start <details> should have `open` as well.
  Do not use quotes on the <details> tag attributes.
-->

<details id=0>
<summary><h2>Step 0: How to start this course</h2></summary>

## How to start this course

1. Above these instructions, right-click **Use this template** and open the link in a new tab.

   ![Use this template](https://user-images.githubusercontent.com/1221423/169618716-fb17528d-f332-4fc5-a11a-eaa23562665e.png)

1. In the new tab, follow the prompts to create a new repository.
    - For owner, choose your personal account or an organization to host the repository.
    - We recommend creating a public repository—private repositories will [use Actions minutes](https://docs.github.com/en/billing/managing-billing-for-github-actions/about-billing-for-github-actions).

    <img src="https://user-images.githubusercontent.com/6969296/212442636-86499765-9429-451a-8dfc-1d7f48fa836e.png" alt="Create a new repository" width="700" />

1. After your new repository is created, wait about 20 seconds, then refresh the page. Follow the step-by-step instructions in the new repository's README.

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

_Welcome to "Getting Secrets From HashiCorp Vault With GitHub OIDC in Action Workflows!" :wave:_

Leveraging GitHub OIDC to Vault enables secure passwordless authentication for GitHub Actions workflows.
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
If a role is bound to the claims, Vault returns an auth token to the workflow.

On the user's side, we can use Hashicorp's [vault-action](https://github.com/hashicorp/vault-action) GitHub Action to retrieve secrets from Vault using OIDC.
Let's explore a "hello world" example.

### :keyboard: Activity: OIDC Hello World

1. Open a new browser tab, and work on the steps in your second tab while you read the instructions in this tab.
1. Go to the **Actions tab**.
1. On the left-hand side, under "All workflows," select **Step 1, OIDC Hello World**.
1. On the right-hand side, open the **Run workflow** menu and click **Run workflow**.

    <img src="https://user-images.githubusercontent.com/6969296/212499178-7cfc18f9-6860-4d88-a21d-02806b358bb2.png" alt="Manually run workflow" width="500" />

1. After a few seconds, the workflow run will appear. Click into it.
   It can take between 20-40 seconds for this workflow to complete.
   Wait until the workflow completes - you should see a green checkmark.

   ![Workflow succeeds](https://user-images.githubusercontent.com/6969296/212499911-42871f96-7e11-4cbf-8d23-5fd1bc0cf480.png)

1. Wait about 20 seconds then refresh this page for the next step.

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
Typically, `contents: read` to checkout the repository is the only permission you need.

You can read more about the required workflow permissions on [GitHub's docs](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/about-security-hardening-with-openid-connect#adding-permissions-settings).

```yml
# Initializes Vault with a JWT backend for GitHub OIDC
# and sets up a role, policy, and secret to retrieve.
- name: Setup Vault
  env:
    VAULT_ADDR: http://127.0.0.1:8200
  run: ./.github/script/1-setup.sh
```

For the purposes of this course, we set up a dev Vault instance for you to authenticate against using OIDC.
We'll take a look at this setup script in a moment.

```yml
- name: Retrieve Secrets
  uses: hashicorp/vault-action@v2.4.3
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
We merely specify the Vault role we want (`hello-world`), whatever secrets we want to retrieve, and, optionally but recommended for clarity, what output variable we'd like to assign to each secret.
In this case, we save the output of the secret to the `WORLD` variable.
If our OIDC configuration for the `hello-world` role matches the token that GitHub presents, our workflow will get an auth token and the requested secrets (assuming the Vault role's policy permits those paths).

```yaml
- name: Print secrets
  run: |
    echo "Hello ${{ steps.secrets.outputs.WORLD }}!"
    echo "Hello ${{ steps.secrets.outputs.WORLD }}!" >> "${GITHUB_STEP_SUMMARY}"
```

Finally, since we've set `id: secrets` attribute on the `hashicorp/vault-action` step, we can access our secrets using the syntax `steps.secrets.outputs.WORLD`.

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
You don't want to use this in real life! :wink: :scream:

Let's look at the other values:
- `role_type` should always be `jwt` for GitHub OIDC.
- `user_claim` is the value that Vault uses to identify the user.
  Its data will become the `auth.display_name` value in Vault's audit logs.
  In this case, we set the `user_claim` to be `actor`, which means Vault's audit log will record the GitHub username of the entity who ran the workflow.
  This can be a GitHub user or something like Dependabot, depending on what triggers the workflow.
- `bound_claims` is a map of the claims that all must be present in GitHub's OIDC token in order to successfully authenticate to this role.
  There must be at least one bound claim.
  We'll see how to add more claims soon.
- `policies` is a list of policies that will be granted to the user when they authenticate to this role.
- `ttl` is the time-to-live for the token that Vault returns to the workflow.
  In this case, we've set the generated Vault token to expire after 60 seconds.
  While the workflow runs in 20-40 seconds, the time between retrieving the Vault token and accessing secrets inside the workflow is about 1-2 seconds.
  You could set the TTL to be really short!
  A short TTL means that an attacker who gains access to your CI/CD environment will have very little time to do anything malicious. :sunglasses:

### :keyboard: Activity: Fine-grained permissions - pull requests

Wow, that was a lot of information! :exploding_head:

Give yourself a pat on the back for making it here.
Next, you will configure a new Vault role to retrieve a secret only if the workflow runs inside a pull request.

1. Open this repository in a code editor.
1. From the code editor, checkout a new branch.
**For this activity, you must open a pull request from a branch other than `main`.**
1. After the previous activity, you should see a new workflow file in the repo: `.github/workflows/2-pull-request.yml`.
Open this file in your code editor.
1. This time, you will create the Vault role this workflow will use to retrieve a secret from Vault!
Locate the step `name: Create an OIDC Role`.
1. Replace this step with the following code.
   **Replace the `YOUR_REPO` section with the `org/repo` that applies to the repository you created from this course**.
   For example, the course template hosted at <https://github.com/artis3n/tutorial-vault-github-oidc> would use: `"sub": "repo:artis3n/tutorial-vault-github-oidc:pull_request"`.
    We're showcasing fine-grained permissions with Vault, here!
    The workflow won't run unless the `org/repo` is correct for your repository.
    ```yml
    - name: Create an OIDC Role
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
        role: ""  # Don't forget to enter the role name you created above!
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
Via the UI or CLI, open a pull request from your branch to the `main` branch.
    ```bash
    gh pr create --title "Fine-grained permissions - pull requests" --body "This pull request adds a new workflow that uses Vault to retrieve a secret only if the workflow runs inside a pull request."
    ```
1. Go to the **Pull Requests** tab and open your new pull request.
After a few seconds, you should observe the `Step 2, Fine-grained permissions - pull requests` workflow begin to run on your PR.
    ![Pull request workflow running](https://user-images.githubusercontent.com/6969296/212520410-1f4a73ba-67db-4471-bf2c-fcc2d819f473.png)
1. Wait until the workflow completes - you should see a green checkmark.
   If the workflow fails, check that your `org/repo` value is correct for your current repository!
   Ensure the `role` name matches between both steps in the workflow.
1. Once the PR workflow is successful, wait about 20 seconds further, then refresh this README page for the next step.

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

TBD-step-3-information

**What is _TBD-term-3_**: TBD-definition-3

### :keyboard: Activity: TBD-step-3-name

1. TBD-step-3-instructions.
1. Wait about 20 seconds then refresh this page for the next step.

</details>

<!--
  <<< Author notes: Step 4 >>>
  Start this step by acknowledging the previous step.
  Define terms and link to docs.github.com.
  TBD-step-4-notes.
-->

<details id=4>
<summary><h2>Step 4: TBD-step-4-name</h2></summary>

_Nicely done TBD-step-3-name! :partying_face:_

TBD-step-4-information

**What is _TBD-term-4_**: TBD-definition-4

### :keyboard: Activity: TBD-step-4-name

1. TBD-step-4-instructions.
1. Wait about 20 seconds then refresh this page for the next step.

</details>

<!--
  <<< Author notes: Step 5 >>>
  Start this step by acknowledging the previous step.
  Define terms and link to docs.github.com.
  TBD-step-5-notes.
-->

<details id=5>
<summary><h2>Step 5: Merge your pull request</h2></summary>

_Almost there TBD-step-4-name! :heart:_

You can now [merge](https://docs.github.com/en/get-started/quickstart/github-glossary#merge) your pull request!

### :keyboard: Activity: Merge your pull request

1. Click **Merge pull request**.
1. Delete the branch `TBD-branch-name` (optional).
1. Wait about 20 seconds then refresh this page for the next step.

</details>

<!--
  <<< Author notes: Finish >>>
  Review what we learned, ask for feedback, provide next steps.
-->

<details id=X>
<summary><h2>Finish</h2></summary>

_Congratulations friend, you've completed this course!_

<img src=TBD-celebrate-image alt=celebrate width=300 align=right>

Here's a recap of all the tasks you've accomplished in your repository:

- TBD-recap.

### What's next?

- TBD-continue.
- [We'd love to hear what you thought of this course](TBD-feedback-link).
- [Take another TBD-organization Course](https://github.com/TBD-organization).
- [Read the GitHub Getting Started docs](https://docs.github.com/en/get-started).
- To find projects to contribute to, check out [GitHub Explore](https://github.com/explore).

</details>

<!--
  <<< Author notes: Footer >>>
  Add a link to get support, GitHub status page, code of conduct, license link.
-->

---

Get help: [TBD-support](TBD-support-link) &bull; [Review the GitHub status page](https://www.githubstatus.com/)

&copy; 2022 TBD-copyright-holder &bull; [Code of Conduct](https://www.contributor-covenant.org/version/2/1/code_of_conduct/code_of_conduct.md) &bull; [CC-BY-4.0 License](https://creativecommons.org/licenses/by/4.0/legalcode)
