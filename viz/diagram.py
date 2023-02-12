from diagrams import Cluster, Diagram, Edge
from diagrams.aws.compute import Lambda
from diagrams.aws.network import APIGateway
from diagrams.generic.storage import Storage
from diagrams.onprem.compute import Server
from diagrams.onprem.container import Docker
from diagrams.onprem.database import Mariadb, Postgresql, Scylla
from diagrams.onprem.inmemory import Redis
from diagrams.onprem.monitoring import Grafana
from diagrams.onprem.network import Nginx, Traefik
from diagrams.onprem.queue import RabbitMQ
from diagrams.programming.language import Csharp, Rust
from third_party import (
    Discord,
    Swarmpit,
    SwarmCronjob,
    Cloudflare,
    Nextjs,
    Victoria,
    Tempo,
    OpenTelemetry,
)

with Diagram("Universalis", show=False):
    with Cluster("Lodestone API"):
        lodestone_apig = APIGateway("lodestone.universalis.app")
        search_characters = Lambda("search_characters")
        get_character = Lambda("get_character")
        lodestone_apig >> search_characters
        lodestone_apig >> get_character

    with Cluster("Universalis Database (Dedicated Server)"):
        universalis_redis = Redis("Stats & Tax Rates")
        universalis_redis - Redis("Replica")
        universalis_listings_db = Postgresql()

    with Cluster("Universalis Sales Database"):
        universalis_sales_db = Scylla()
        universalis_sales_db - Scylla() - Scylla()

    discord = Discord("Discord")

    cloudflare = Cloudflare("DNS")

    swarm = Docker("Docker Swarm")
    cloudflare >> lodestone_apig
    cloudflare >> Server("Cloud Load Balancer") >> swarm

    with Cluster("Cluster Services"):
        with Cluster("Swarm Infra"):
            ingress = Traefik("Traefik")
            swarm_cronjob = SwarmCronjob("swarm-cronjob")
            swarmpit = Swarmpit("Swarmpit")
            swarm >> ingress >> swarmpit

        with Cluster("Monitoring Stack"):
            metrics_edge = Edge(label="metrics", color="darkorange")

            grafana = Grafana("Grafana")
            tempo = Tempo("Tempo")
            victoria = Victoria("Victoria")

            (
                victoria
                >> metrics_edge
                >> tempo
                >> Edge(label="traces", color="blue")
                >> OpenTelemetry("OpenTelemetry")
            )
            ingress >> grafana >> metrics_edge >> [victoria, tempo]

        with Cluster("Universalis"):
            universalis_router = Nginx("universalis.app")

            with Cluster("Universalis API"):
                universalis_api = Csharp("API")
                universalis_mq = RabbitMQ("WebSocket Events")
                universalis_cache = Redis("Cache")

                universalis_api >> Edge(forward=True, reverse=True) << universalis_mq
                universalis_api >> universalis_sales_db
                (
                    ingress
                    >> universalis_router
                    >> universalis_api
                    >> [
                        universalis_redis,
                        universalis_listings_db,
                        universalis_cache,
                    ]
                )

            with Cluster("Mogboard"):
                mogboard_website = Nextjs("Website")
                mogboard_db = Mariadb("Website Database")
                mogboard_website >> universalis_api
                universalis_alerts = Rust("Universalis Alerts")
                universalis_alerts >> [universalis_api, mogboard_db]
                universalis_alerts >> Edge(label="webhook", style="dashed") >> discord
                universalis_router >> mogboard_website >> mogboard_db

        with Cluster("Universalis Documentation"):
            ingress >> Nextjs("docs.universalis.app")

        with Cluster("ACT Plugin Resources"):
            (
                ingress
                >> Nginx("act.universalis.app")
                >> Storage("version\ndefinitions.json")
            )
