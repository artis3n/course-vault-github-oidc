<!--
  <<< Author notes: Finish >>>
  Review what we learned, ask for feedback, provide next steps.
-->

## Finish

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
