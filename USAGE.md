# Operational scripts

These preserve host-specific scripts; syntax checks do not run their effects.
Review absolute paths, package-manager and privilege requirements before use.
backup.sh intentionally captures local secrets/private data for OFFLINE recovery;
its archives must NEVER be committed or uploaded here. RESTORE.md is historical
and references retired models: use current trading docs for current deployment.
checkpoint.sh commits locally but does not push. None of these runs automatically.
