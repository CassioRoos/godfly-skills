# Synthetic adapter dependency snapshot

This fictional adapter currently declares AWS SDK for Go v1 in go.mod. Its S3
client is scheduled for migration; no source tree or deployed cluster is supplied.
The intended deployment uses IRSA on EKS. Research the official credential behavior;
do not infer that runtime configuration or the migration has already been verified.
No dependency download or build is required for this research fixture.
