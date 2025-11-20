## Install ArgoCD in your EKS cluster
- First access your Cluster.
  ![argocd1](https://github.com/user-attachments/assets/090390a9-6071-4f39-af2b-76564c090b4d)
- Create Namespace ArgoCD
- install ArgoCD with.
```bash
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```
   ![argocd2](https://github.com/user-attachments/assets/683ae75a-33d9-4768-86e0-b0fda52ad6a4)
- Verify pods are Created.
  ![argocd3](https://github.com/user-attachments/assets/58be5c72-0f59-46ba-99b3-15457c7576c9)
- Create ArgoCD service.
  ![argocd4](https://github.com/user-attachments/assets/1ec8c430-a3ad-49a8-a200-ff1bb56f9f89)
  ![argocd5](https://github.com/user-attachments/assets/896e42a5-4106-4c67-a011-813c68095e82)
- Get admin password:

```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```
- Access ArgoCD UI:
  ![argocd7](https://github.com/user-attachments/assets/1c2b7b6b-5d7b-41a2-903e-2caa438a0f9d)
  ![argocd8](https://github.com/user-attachments/assets/669f46a8-beb8-4a5d-999c-9734472982d0)
- Enable CLI.
  ![argocd9](https://github.com/user-attachments/assets/b37f07f6-3dd4-4e14-8feb-a8a5cb38af7c)
- Login through CLI and update password.
  ![argocd10](https://github.com/user-attachments/assets/0b3ea862-9149-4880-bef6-6a18eb2bd0aa)
  ![argocd11](https://github.com/user-attachments/assets/a40ed993-21a9-486e-a769-b3077d43f9d5)



