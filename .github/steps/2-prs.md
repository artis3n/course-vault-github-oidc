<!--
  <<< Author notes: Step 2 >>>
  Start this step by acknowledging the previous step.
  Define terms and link to docs.github.com.
  TBD-step-2-notes.
-->

## Step 2: Fine-grained permissions - pull requests

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
  uses: hashicorp/vault-action@v2
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

<!-- https://github.com/orgs/community/discussions/16925 -->

> [!WARNING]
> You don't want to use this in real life! :wink: :scream:

This claim means that anyone anywhere on github.com can authenticate to this Vault instance and be granted the `hello-policy` policy.
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
      uses: hashicorp/vault-action@v2
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

    > [!NOTE]
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
