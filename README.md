<header>

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

</header>

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

## How to start this course

[![start-course](https://user-images.githubusercontent.com/1221423/235727646-4a590299-ffe5-480d-8cd5-8194ea184546.svg)](https://github.com/new?template_owner=artis3n&template_name=course-vault-github-oidc&owner=%40me&name=course-vault-github-oidc&description=Learn+how+to+create+fine-grained,+least-privilege+HashiCorp+Vault+roles+for+GitHub+Action+workflows+using+GitHub+OIDC.&visibility=public)

1. Make sure you are signed in to GitHub.
Right-click **Start course** and open the link in a new tab.
2. In the new tab, most of the prompts will automatically fill in for you.
    - For owner, choose your personal account or an organization to host the repository.
    - We recommend creating a public repository — private repositories will [use Actions minutes](https://docs.github.com/en/billing/managing-billing-for-github-actions/about-billing-for-github-actions).
3. After your new repository is created, wait about 20 seconds, then refresh that page.
Follow the step-by-step instructions in the new repository's README.

<footer>

<!--
  <<< Author notes: Footer >>>
  Add a link to get support, GitHub status page, code of conduct, license link.
-->

---

Get help: [Post in our discussion board](https://github.com/artis3n/course-vault-github-oidc/discussions) &bull; Something not working? [File an issue ticket](https://github.com/artis3n/course-vault-github-oidc/issues)

&copy; 2022 Ari Kalfus &bull; [Code of Conduct](https://www.contributor-covenant.org/version/2/1/code_of_conduct/code_of_conduct.md) &bull; [CC-BY-4.0 License](https://creativecommons.org/licenses/by/4.0/legalcode)

</footer>
