# Trivy Offline Vulnerability & SBOM Dashboard

This project provides a self-contained dashboard for viewing **Trivy vulnerability reports** and **SBOM inventories** in an offline environment.  
The dashboard runs inside a lightweight Podman container using **Red Hat UBI9** with Apache HTTPD serving the static HTML.

---

## 🛠 Prerequisites

Before running the dashboard, ensure you have the following on your **RHEL EC2 instance**:

- **RHEL 9 or later** (tested on Red Hat Enterprise Linux 9.x)
- **Podman** installed and running:
  ```bash
  sudo dnf -y install podman
  ```

## Trivy installed (for generating reports & SBOMs).
## Ensure your offline/online servers already produce JSON reports in the format: 

```bash
reports/<hostname>/trivy-reports-YYYYmmdd-HHMMSS/*.json
reports/<hostname>/sboms-YYYYmmdd-HHMMSS/*.json
```

## Execution Steps

```bash
git clone https://github.com/<your-org>/<your-repo>.git
cd <your-repo>
make build
make run REPORTS_DIR=/path/to/reports

```

## That’s it! Open your browser at http://localhost:8080
# to view the dashboard with your Trivy vulnerability reports and SBOM inventory.