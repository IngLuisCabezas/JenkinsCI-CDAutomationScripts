# Jenkins CI/CD Automation Scripts (Release Engineering & Operations)

A portfolio of Bash/Ksh scripts I wrote and operated as a DevOps / Release Engineer. They are executed by **Jenkins jobs** (parameterised builds and agent nodes) to automate release installation, pre/post-release health validation, environment operations, user provisioning and reporting for a large telco billing platform (SingleView, Oracle-backed, multi-instance, multi-node clusters).

> Customer-identifying information has been anonymised: the two customers are referred to as **Client1** and **Client2**.

## Skills demonstrated

- Jenkins automation: parameterised jobs, agent/node lifecycle, build artifacts, workspace handling
- Bash / Ksh scripting at scale: SSH fan-out to dozens of hosts, here-docs, timeouts, exit-code handling, logging with `tee`/`exec`
- Release management: pre-checks, release cut/install, step-restart control, post-install verification
- Operational health checks: cluster status, HA/standby validation, DB tablespace usage, disk/memory thresholds, TNS latency
- Linux administration: user and SSH key provisioning, password resets, mailbox/queue maintenance
- Reporting and notifications: HTML reports built from SQL*Plus queries, email delivery with attachments
- Multi-environment operations: DEV, BLD, TST, TRN, REF, HAR, SIT, UAT, MNT, PRF, PRE-PROD, PROD

## Repository layout

```
Client1/   Scripts for the Client1 platform (multi-region, many environments)
Client2/   Scripts for the Client2 platform (hosted environments, HA validation framework)
  Pre_post_deploy_validation/   Config-driven health check framework
```

## Client1

| Script | What it does |
|---|---|
| `env_backup.sh` | Backs up a SingleView environment. Discovers instances with `da_dump InstanceStatus`, then (optionally, by Jenkins boolean parameter) backs up file systems and database data over SSH and logs the result per node. |
| `env_registration.sh` | Collects environment definition XML files from every environment over SSH, copies them to the Jenkins workspace and emails them to the environment registry. |
| `env_release_Report.sh` / `report_release_envs.sh` | Query the `release_info` table with SQL*Plus on each environment, build an HTML "release information" report and email it to stakeholders. |
| `install_release_c1sbx1b.sh` | Pulls a release build archive from the main Jenkins master into the sandbox environment workspace and verifies it exists before install. |
| `linux_access_c1.sh` | Automated Unix user onboarding: creates users per environment group, installs SSH keys, sets the initial password and emails the credentials guide to the user. |
| `resend_email.sh` | Re-sends the Unix access notification email to a user. |
| `reset_default_pw.sh` | Unlocks a Unix account and resets it to the default password. |
| `sv_user_creation.sh` | Creates application (SingleView) users in every environment with the correct profile, DB access and role, and writes a results artifact. |
| `maintenance_posfix.sh` | Housekeeping on a node: clears the Postfix mail queue and truncates oversized local mailboxes. |
| `prepost_checks.sh` | Pre/post-release checklist run per SingleView instance (cluster status, disk space of key file systems, and more). Output is attached to a notification email. |
| `register_cut_on_ser.sh` | After a release cut, finds the generated release XML in the Jenkins job archive and registers it by email. |
| `send_release_mw.sh` | Transfers release build artifacts to a remote middleware environment over SSH/SCP (custom port) and recreates the Jenkins build metadata (`build.xml`) there. |
| `start_apators.sh` | Starts and checks HTTP2 adaptor server processes on every instance of a cluster. |
| `start_jenkins_nodes.sh` / `start_jenkins_nodes_all.sh` | Starts Jenkins agents on remote hosts if not already running, for a small environment list and for the full fleet respectively. |
| `test_online_server.sh` | Connectivity sweep: SSH-checks every server of every environment with a timeout and reports which ones are offline. |

## Client2

| Script | What it does |
|---|---|
| `CUT_RELEASE_*.sh` | Release cut job: disk space pre-check, release cut execution, error detection and email notification. |
| `Install_Release_CORP.sh` | Release installation job: free space pre-check, validates the `STEP_NUM` restart parameter format (`xx.xxxxxx`) and starts the install from a given step. |
| `Jenkins_transfer_bundle_sftp_server.sh` / `linux_transfer_bundle_sftp_server.sh` | Uploads release bundles from the Jenkins workspace to an SFTP server with `curl` and emails the outcome. |
| `Client2_Hosted_Release_Hotfix_Report.sh` / `Release_Hotfix_Report.sh` / `linux_Client_Report.sh` | Build an HTML report of releases, patches and hotfixes applied per environment (SQL*Plus), and email it. `Client2Report.html` is the report template. |
| `pre_post_check_list.sh` | Per-instance pre/post-release checklist run through Jenkins. |
| `start_jenkins_node.sh` | Ksh script that reads the environment list from the workspace and starts Jenkins agents that are not yet online. |
| `sv_check_status.sh` / `sv_check_Status_extended.sh` | General and extended SingleView status checks across all instances, collected as a Jenkins artifact. |
| `sv_operations.sh` | Single entry point for operational actions (selected with the `SV_OPERATION` parameter) on single- and multi-instance setups. |
| `Notes` | Personal shell cheat sheet (redirections, exit codes, `sed` refactors). |

### `Pre_post_deploy_validation/`

A config-driven health check framework used before and after a release.

| File | What it does |
|---|---|
| `health_check.conf` | Thresholds and parameters (minimum free disk and memory, maximum tablespace usage, TNS ping latency, expected states). |
| `PrePost_Release_Health_Checks.sh` | Runs all checks on every instance and prints colour-coded `PASS/WARN/FAIL` results with a summary. It also decides if the release can be installed. |
| `jenkins` | Lighter variant of the checks for execution inside a Jenkins job. |
| `install_STD_HA_Jenkins` | Verifies exactly one STD process is enabled and not running on the PE standby node; it disables and restores the instance if it is. |
| `install_release_jenkins_HA` | HA-aware release install wrapper: checks standby node placement before running the install. |

## Design notes

- **Fan-out over SSH** with `timeout` guards so one dead host never blocks a pipeline.
- **Fail fast**: pre-checks (disk space, parameter format) exit non-zero so Jenkins marks the build failed.
- **Observable**: every run produces an artifact (`$NODE_NAME.txt/.log`) and an email summary.
- **Idempotent starts**: agents and services are only started when not already running.

## Known improvements (roadmap)

I am aware of the following technical debt and would address it in a production hardening pass:

1. Move all secrets out of scripts into the Jenkins Credentials store or a vault, and rotate any previously committed values.
2. Replace password-based SFTP/SSH flows with key-based access and per-user keys that are never emailed.
3. Move host lists to a single inventory file or Ansible inventory instead of repeating them in each script.
4. Add `set -euo pipefail`, ShellCheck in CI, and `bats` tests.
5. Replace email attachments of private material with a secure delivery channel.
