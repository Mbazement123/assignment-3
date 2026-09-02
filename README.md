# Assignment 3: CI/CD Pipeline and Dockerized Bash Application

This project contains a Bash utility for system information and network connectivity checks. It includes local validation scripts, a Docker image, Docker Compose configuration, and a sequential GitHub Actions pipeline.

---

## Prerequisites

- Bash 4 or newer for running the application and scripts
- Docker Engine with the Docker Compose plugin for container workflows
- Git for the GitHub Actions workflow
- `shellcheck` is optional; the lint script skips it when it is not installed

Make scripts executable once after cloning:

```bash
chmod +x app/app.sh scripts/*.sh tests/*.sh grade.sh
```

---

## Quick Start

Run the application locally:

```bash
./app/app.sh help
./app/app.sh system-info
./app/app.sh check-host localhost
./app/app.sh check-port 127.0.0.1 22
```

Run the local checks:

```bash
./scripts/lint.sh
./tests/test.sh
./scripts/build.sh
./grade.sh
```

---

## Docker Compose

The Compose file defines one `devops-tool` service. It builds the local `Dockerfile`, tags the image as `devops-tool:latest`, and uses `help` as the default command.

Validate and build:

```bash
docker compose config
docker compose build
docker compose build --no-cache
```

Run commands in temporary containers:

```bash
docker compose run --rm devops-tool
docker compose run --rm devops-tool system-info
docker compose run --rm devops-tool check-host localhost
docker compose run --rm devops-tool check-port 127.0.0.1 22
```

Use `--build` to rebuild automatically before running:

```bash
docker compose run --rm --build devops-tool system-info
```

`docker compose up --build` runs the default `help` command and exits when it finishes. Remove Compose-managed resources with:

```bash
docker compose down
```

---

## Application Commands

The entrypoint is `app/app.sh`.

| Command | Description |
| --- | --- |
| `help` | Display usage and command information |
| `system-info` | Display hostname, OS, kernel, uptime, CPU, and memory information |
| `check-host HOST` | Resolve a host and check reachability with `ping` |
| `check-port HOST PORT` | Check TCP connectivity to a port from 1 through 65535 |

Exit codes are `0` for success, `1` for an operational failure, and `2` for an invalid command or argument.

## Validation Scripts

| Script | Purpose |
| --- | --- |
| `scripts/lint.sh` | Check required files, Bash syntax, and optional ShellCheck rules |
| `tests/test.sh` | Run the 12 functional and argument-validation tests |
| `scripts/build.sh` | Build the Docker image and run Docker smoke tests |
| `grade.sh` | Run structure, permissions, syntax, application, Docker, and CI checks |

## GitHub Actions

The workflow in `.github/workflows/ci.yml` runs on every push and pull request. Jobs execute in order:

```text
validate -> test -> docker
```

1. `validate` runs `scripts/lint.sh`.
2. `test` runs `tests/test.sh` after validation succeeds.
3. `docker` runs `scripts/build.sh` after the tests succeed.

## Docker Image

The `Dockerfile` uses Alpine Linux and installs Bash plus the networking tools required by the application. The image entrypoint is `/app/app/app.sh`, and its default command is `help`.

Build and run without Compose:

```bash
docker build -t devops-tool .
docker run --rm devops-tool system-info
docker run --rm devops-tool check-host localhost
```

## Project Structure

```text
assignment-3/
├── app/app.sh                 Application entrypoint
├── scripts/lint.sh            Linting and syntax checks
├── scripts/build.sh           Docker build and smoke tests
├── tests/test.sh              Functional test suite
├── Dockerfile                 Docker image definition
├── compose.yaml               Docker Compose service definition
├── .dockerignore              Docker build exclusions
├── grade.sh                   Automated grading checks
└── .github/workflows/ci.yml   GitHub Actions workflow
```
