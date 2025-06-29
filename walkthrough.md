# Deploy Cost Canary Integration

Welcome! This guide will help you securely connect your Google Cloud account to Cost Canary in just a few steps.

We will use Google Cloud's Infrastructure Manager to create the necessary read-only permissions.

### 1. Configure Your Details

First, we need your project, organization, and billing information.

<walkthrough-editor-open-file
    filePath="terraform.tfvars.example"
    text="Click here to open the configuration file.">
</walkthrough-editor-open-file>

Copy the entire contents of the file. Then, create a new file for your configuration.

<walkthrough-editor-create-file
    filePath="terraform.tfvars"
    text="Click here to create your personal terraform.tfvars file.">
</walkthrough-editor-create-file>

Paste the content you copied into this new `terraform.tfvars` file and **fill in the required values** for `gcp_project_id`, `organization_id`, and `billing_account_id`.

**Save the file (`Ctrl+S`) before continuing.**

### 2. Authorize Cloud Shell

To ensure we have the correct permissions, please click the button below to authorize Cloud Shell.

<walkthrough-user-setup></walkthrough-user-setup>

### 3. Deploy the Integration

Now, run the final command below. This tells Infrastructure Manager to use your configuration to deploy the necessary resources. It will take a few minutes to complete.

<walkthrough-terminal-execute-command
    command="gcloud infra-manager deployments apply cost-canary-deployment \
    --project=$(gcloud config get-value project) \
    --location=us-central1 \
    --git-source-repo=https://github.com/pranjal-javia/cost_canary_template_gcp \
    --inputs-file=terraform.tfvars">
</walkthrough-terminal-execute-command>

### 4. All Done!

Once the command finishes successfully, the connection is complete!

You can now return to the Cost Canary application and click **VERIFY** to finish the onboarding process.