# Container diagram

Это целевое предварительное представление, а не текущая local Compose topology.
Backend остаётся одним deployable container с внутренними domain modules.

```mermaid
flowchart LR
    Traveler[Путешественник]
    Flutter["Flutter Mobile Application"]
    Admin["Admin Application (future external component)"]
    Routing["Routing Provider"]

    subgraph cluster [Crimea Travel Platform]
        Ingress["Kubernetes Ingress / API entry point"]
        Backend["Backend (modular monolith)"]
        PostgreSQL["PostgreSQL / PostGIS"]
        Redis["Redis"]
        Storage["S3-compatible Storage"]
    end

    Traveler --> Flutter
    Flutter -->|HTTPS JSON| Ingress
    Admin -->|HTTPS JSON| Ingress
    Ingress --> Backend
    Backend -->|SQL spatial queries| PostgreSQL
    Backend -->|cache rate limits| Redis
    Backend -->|S3 API| Storage
    Backend -->|normalized routing contract| Routing
```

`Admin Application` показан как будущий внешний клиент. Он не создаётся на
foundation-этапе. `Kubernetes Ingress` относится к целевой deployment topology;
local Compose не запускает Kubernetes.
