<!--
  <<< Author notes: Step 1 >>>
  Choose 3-5 steps for your course.
  The first step is always the hardest, so pick something easy!
  Link to docs.github.com for further explanations.
  Encourage users to open new tabs for steps!
  TBD-step-1-notes.
-->

## Step 1: Introduction to OIDC

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
