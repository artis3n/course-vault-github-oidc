<!--
  <<< Author notes: Step 4 >>>
  Start this step by acknowledging the previous step.
  Define terms and link to docs.github.com.
  TBD-step-4-notes.
-->

## Step 4: Fine-grained permissions - environments

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
    > [!IMPORTANT]
    > For this activity to properly update you to the next step, you must push code to the `main` branch.

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
    > [!IMPORTANT]
    > Replace the `YOUR_REPO` section with the `org/repo` string that applies to the repository you created from this course.

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
    > [!NOTE]
    > **Environment names are case-sensitive.** `staging` is not the same as `Staging`.
1. Don't forget to pick a name for your Vault role as well!
You should use different names for the staging and production Vault roles.
In the same code block, replace `GIVE_ME_A_NAME` with an alphanumeric (plus `_` and `-`) name of your choosing.
1. Under the **staging** job, locate the next step in the job, `name: Retrieve Secrets`.
    ```yml
    - name: Retrieve Secrets
      uses: hashicorp/vault-action@v2
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
    > [!IMPORTANT]
    > Replace the `YOUR_REPO` section with the `org/repo` string that applies to the repository you created from this course.

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
    > [!NOTE]
    > **Environment names are case-sensitive.** `production` is not the same as `Production`.
1. Don't forget to pick a name for your Vault role as well!
You should use different names for the staging and production Vault roles.
In the same code block, replace `GIVE_ME_A_NAME` with an alphanumeric (plus `_` and `-`) name of your choosing.
1. Under the **prod** job, locate the next step in the job, `name: Retrieve Secrets`.
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
