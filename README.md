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
- **Prerequisites**: You should have basic proficiency working with HashiCorp Vault. You should understand how Vault roles correspond to HCL policies and how policies grant access to secrets. Completing HashiCorp's Vault [Getting Started](https://developer.hashicorp.com/vault/tutorials/getting-started) tutorial is sufficient.
- **How long**: This course is **TBD-step-count** steps long and takes less than **TBD-duration** to complete.

<!--
  <<< Author notes: Start of the course >>>
  Include start button, a note about Actions minutes,
  and tell the learner why they should take the course.
  Each step should be wrapped in <details>/<summary>, with an `id` set.
  The start <details> should have `open` as well.
  Do not use quotes on the <details> tag attributes.
-->

<!--step0-->

## How to start this course

1. Above these instructions, right-click **Use this template** and open the link in a new tab.

   ![Use this template](https://user-images.githubusercontent.com/1221423/169618716-fb17528d-f332-4fc5-a11a-eaa23562665e.png)

1. In the new tab, follow the prompts to create a new repository.
   - For owner, choose your personal account or an organization to host the repository.
   - We recommend creating a public repository—private repositories will [use Actions minutes](https://docs.github.com/en/billing/managing-billing-for-github-actions/about-billing-for-github-actions).

    <img src="https://user-images.githubusercontent.com/6969296/212442636-86499765-9429-451a-8dfc-1d7f48fa836e.png" alt="Create a new repository" width="700" />

1. After your new repository is created, wait about 20 seconds, then refresh the page. Follow the step-by-step instructions in the new repository's README.

<!--endstep0-->

<!--
  <<< Author notes: Step 1 >>>
  Choose 3-5 steps for your course.
  The first step is always the hardest, so pick something easy!
  Link to docs.github.com for further explanations.
  Encourage users to open new tabs for steps!
  TBD-step-1-notes.
-->

<!--step1-->

## Step 1: Introduction to OIDC

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

1. It takes about 40 seconds for this workflow to run. Wait until the workflow completes - you should see a green checkmark.

    ![Workflow succeeds](https://user-images.githubusercontent.com/6969296/212499278-76d5ad7b-7e4c-4235-b394-cbe64cce66b9.png)

1. Wait about 20 seconds then refresh this page for the next step.

<!--endstep1-->


<!--
  <<< Author notes: Step 2 >>>
  Start this step by acknowledging the previous step.
  Define terms and link to docs.github.com.
  TBD-step-2-notes.
-->

<!--step2-->

## Step 2: The GitHub OIDC Workflow

_You successfully authenticated and retrieved a Vault secret using GitHub OIDC! :tada:_

TBD-step-2-information

**What is _TBD-term-2_**: TBD-definition-2

### :keyboard: Activity: TBD-step-2-name

1. TBD-step-2-instructions.
1. Wait about 20 seconds then refresh this page for the next step.

<!--endstep2-->

<!--
  <<< Author notes: Step 3 >>>
  Start this step by acknowledging the previous step.
  Define terms and link to docs.github.com.
  TBD-step-3-notes.
-->

<details id=3>
<summary><h2>Step 3: TBD-step-3-name</h2></summary>

_Nice work finishing TBD-step-2-name :sparkles:_

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
