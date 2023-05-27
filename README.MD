Configure Configure a service principal with a secret [https://github.com/Azure/login#configure-a-service-principal-with-a-secret]
Example: az ad sp create-for-rbac --name "avd_accelerator" --role Contributor --scopes /subscriptions/<INSERT_SUBSCRIPTION_HERE> --sdk-auth
If possible, use OIDC https://github.com/Azure/login#configure-a-federated-credential-to-use-oidc-based-authentication
