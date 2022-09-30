# Avinya Foundation Global Data Service

The Avinya Foundation's Global Data Service underlies the Avinya Foundation technology stack, and provides a universal interface to foundation data to all applications in the organization.

## Features

The global data service provides a generalized interface to foundation data for all internal clients at the Avinya Foundation. This includes applications across many domains; human resource management, student admissions, enterprise resource planning, and class management.

The main features are:

- Ballerina GraphQL API that exposes a semantically enriched global database;
- Generated Ballerina GraphQL client to query the API;
- Automated deployment and management of the GraphQL API on [Choreo](https://wso2.com/choreo/);
- Generalized data model to ensure interoperability and persistence across application domains in the organization;
- Robust test infrastructure, locally, and in the cloud.

## Component Documentation

- [GraphQL API Ballerina Documentation](https://avinya-foundation.github.io/global-data/api_doc/)
- [GraphQL Client Ballerina Documentation (on Central)](https://lib.ballerina.io/avinyafoundation/global_data_client/latest)

## Project Status

### Build and Test | ![Build and test pipeline](https://github.com/Avinya-Foundation/global-data/actions/workflows/push.yml/badge.svg)

*Build project and run tests*

Builds database container, and pushes to `ghcr.io`. Builds the `api/` ballerina project, and runs tests. Generates GraphQL client from the schema in `api/schema`.

### Generate Project Documentation | ![GitHub Pages pipeline](https://github.com/Avinya-Foundation/global-data/actions/workflows/pages.yml/badge.svg)

*Generate project documentation*

Use `bal doc` to build ballerina API documentation for the `api`. Adds these artifacts to the `gh-pages` branch, and sets up a Jekyll site with the [Cayman](https://github.com/pages-themes/cayman) theme.

### Release Pipeline | ![Release pipeline](https://github.com/Avinya-Foundation/global-data/actions/workflows/release.yml/badge.svg)

*Main `global-data` release workflow*

Bumps the project version numbers in `Ballerina.toml` files based on the release tag. Updates Microsoft Azure database schemas. Pushes GraphQL API client to Ballerina Central.

## Development

> Note: GitHub Pages does not yet support mermaid. To see rendered diagrams, look at the [project `README` on GitHub](https://github.com/Avinya-Foundation/global-data#readme).

### CI/CD

Global Data Service uses [GitHub Actions](https://github.com/features/actions) for managing CI/CD. Local pipeline execution is enabled with [act](https://github.com/nektos/act).

The logical setup of the GitHub Actions workflows is illustrated below. The actions are divided into 3 functionally separate workflows; `push`, `pages`, and `release`.

> Note: In all workflows, all paths must evaluate to the `Success State`, or the workflow fails.

These actions run at different points in the development lifecycle. The relationship between the 3 workflows, and detail for each of the workflows are illustrated below:

- Meta workflow

```mermaid
stateDiagram-v2
    push: push workflow
    pages: pages workflow
    release: release workflow
    [*] --> push: commit/PR created
    push --> pages: merged to main
    pages --> release: new release cut
```

- [`push`](.github/workflows/push.yml) workflow

```mermaid
stateDiagram-v2
    db_setup: Database Setup
    ghcr_registry: GitHub Container Registry
    idempotence_test: Database Idempotence Test
    graphql_test: GraphQL API Test
    graphql_client_generate: Generate GraphQL Client
    success: Success State
    failed: Failed State
    repo: Caller Branch
    [*] --> db_setup: commit/PR created
    db_setup --> ghcr_registry: successful db build
    db_setup --> failed: db build failed
    ghcr_registry --> idempotence_test: pull db image
    idempotence_test --> success: test passed
    idempotence_test --> failed: test failed
    ghcr_registry --> graphql_test: pull db image
    graphql_test --> failed: test failed
    graphql_test --> graphql_client_generate: tests passed
    graphql_client_generate --> failed: generation failed
    graphql_client_generate --> repo: commit client
    repo --> success
    success --> [*]
    failed --> [*]
```

- [`pages`](.github/workflows/pages.yml) workflow

```mermaid
stateDiagram-v2
    main: main Branch
    gh_pages: gh-pages Branch
    build_api_doc: Build Ballerina API Documentation
    api_doc: API Documentation
    success: Success State
    failed: Failed State
    [*] --> main: checkout
    main --> build_api_doc
    build_api_doc --> failed: bal doc failed
    build_api_doc --> api_doc: bal doc succeeded
    api_doc --> gh_pages: commit
    gh_pages --> success
    success --> [*]
    failed --> [*]
```

- [`release`](.github/workflows/release.yml) workflow

```mermaid
stateDiagram-v2
    main: main Branch
    version_number: Update Package Version Number
    push_schema: Update Database Schema
    azure_db: Azure Database
    bal_central: Ballerina Central
    pages: Run pages workflow
    success: Success State
    failed: Failed State
    [*] --> main: create release
    main --> version_number: extract version number
    version_number --> failed: update failed
    version_number --> push_schema: update successful
    push_schema --> azure_db: authenticate and push
    azure_db --> failed: schema update failed
    azure_db --> bal_central: push API client
    bal_central --> failed: push failed
    bal_central --> pages: push succeeded
    pages --> success: pages workflow succeeded
    failed --> [*]
    success --> [*]
```

### Local Workflow Execution Notes

> Note: "Local" means running the tests on the developer's machine with [`act`](https://github.com/nektos/act).

- Need to change `HOST` to `localhost` in `tests/Config.toml` for local tests to run correctly.
- The [`Makefile`](Makefile) contains recipes for running the push pipeline with `act`.
- Some tests are duplicated with local-only logic. Specifically, all tests that require the database container have duplicate logic for local execution due to a limitation with `act` and [GitHub service containers](https://docs.github.com/en/actions/using-containerized-services/about-service-containers). For more information, see https://github.com/nektos/act/issues/173.
