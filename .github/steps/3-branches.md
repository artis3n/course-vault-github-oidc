<!--
  <<< Author notes: Step 3 >>>
  Start this step by acknowledging the previous step.
  Define terms and link to docs.github.com.
  TBD-step-3-notes.
-->

## Step 3: Fine-grained permissions - branches

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
    > [!IMPORTANT]
    > For this activity, you must push code to the `main` branch.
1. In your code editor, open the file `.github/workflows/3-main-branch.yml`.
1. Locate the step `name: Create an OIDC Role`.
1. Replace this step with the following code.
    > [!IMPORTANT]
    > Replace the `YOUR_REPO` section with the `org/repo` string that applies to the repository you created from this course.

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
      uses: hashicorp/vault-action@v2
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
