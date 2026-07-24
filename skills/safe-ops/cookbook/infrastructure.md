# Infrastructure Operations

Safe patterns for Docker, Kubernetes, and cloud operations.

## Docker

### Container Management

**View state (L1):**
```bash
docker ps -a                          # All containers
docker logs <container> --tail 100    # Recent logs
docker inspect <container>            # Full details
docker stats --no-stream              # Resource usage
```

**Build & run (L2):**
```bash
# Preview: show build context
docker build --progress=plain -t <tag> .

# Run locally
docker-compose up -d
docker-compose logs -f
```

**Push & deploy (L3):**
```bash
# Preview: show what will be pushed
docker images <tag> --format "{{.Repository}}:{{.Tag}} {{.Size}}"

# Confirm, then push
docker push <tag>
```

**Remove & clean (L4):**
```bash
# Preview: show what will be removed
docker system df                      # Show disk usage
docker images -f "dangling=true"      # Show dangling images

# Confirm with rollback plan, then clean
# (docker prune has no dry-run flag — the df/dangling listing above IS the preview)
docker system prune -a
```

## Kubernetes

### Read Operations (L1)
```bash
kubectl get pods -n <namespace>
kubectl describe pod <pod> -n <namespace>
kubectl logs <pod> -n <namespace> --tail=100
kubectl get events -n <namespace> --sort-by='.lastTimestamp'
kubectl top pods -n <namespace>
```

### Apply / Update (L3)
```bash
# ALWAYS diff first
kubectl diff -f <manifest>

# Show what will change
kubectl apply -f <manifest> --dry-run=server -o yaml

# Confirm, then apply
kubectl apply -f <manifest>
```

### Scale (L3)
```bash
# Preview: show current state
kubectl get deployment <name> -n <namespace> -o wide

# Show current replicas
kubectl get deployment <name> -n <namespace> -o jsonpath='{.spec.replicas}'

# Confirm target, then scale
kubectl scale deployment <name> --replicas=<n> -n <namespace>
```

### Delete (L4)
```bash
# Preview: show what will be deleted
kubectl get <resource> <name> -n <namespace> -o yaml > /tmp/backup-<name>.yaml

# Present rollback: "kubectl apply -f /tmp/backup-<name>.yaml"
# Confirm, then delete
kubectl delete <resource> <name> -n <namespace>
```

## Cloud Resources

### General Pattern
1. **List** current state (L1)
2. **Plan** changes with dry-run (L3 preview)
3. **Confirm** with user showing exact changes
4. **Apply** the changes
5. **Audit** with rollback info

### Terraform
```bash
# L1: Show current state
terraform state list
terraform show

# L3: Plan changes (this IS the dry-run)
terraform plan -out=tfplan

# L3: Confirm, then apply
terraform apply tfplan

# L4: Destroy (requires explicit confirm + backup)
terraform plan -destroy  # Preview
terraform state pull > backup.tfstate  # Backup
```

### Common Cloud Operations
```bash
# AWS (L1 reads)
aws ec2 describe-instances
aws s3 ls s3://bucket/
aws logs tail /aws/lambda/<fn>

# GCP (L1 reads)
gcloud compute instances list
gcloud run services list
gcloud logging read "resource.type=cloud_run_revision"
```

## Rollback Patterns

### Docker rollback
```bash
# Rollback to previous image
docker pull <registry>/<image>:<previous-tag>
docker-compose up -d
```

### Kubernetes rollback
```bash
# Rollback deployment
kubectl rollout undo deployment/<name> -n <namespace>

# Rollback to specific revision
kubectl rollout undo deployment/<name> --to-revision=<n> -n <namespace>

# Verify
kubectl rollout status deployment/<name> -n <namespace>
```

### Terraform rollback
```bash
# Restore previous state
terraform state push backup.tfstate
terraform apply
```
