from diagrams import Cluster, Diagram
from diagrams.aws.compute import Lambda
from diagrams.aws.network import APIGateway
from diagrams.generic.storage import Storage
from diagrams.onprem.certificates import LetsEncrypt
from diagrams.onprem.compute import Server
from diagrams.onprem.container import Docker
from diagrams.onprem.database import Mariadb
from diagrams.onprem.inmemory import Redis
from diagrams.onprem.network import Nginx, Traefik
from diagrams.onprem.queue import RabbitMQ
from diagrams.programming.language import Csharp
from third_party import Swarmpit, SwarmCronjob, Scylla, Cloudflare, Nextjs

with Diagram("Universalis", show=False):
    with Cluster("Lodestone API"):
        lodestone_apig = APIGateway("lodestone.universalis.app")
        search_characters = Lambda("search_characters")
        get_character = Lambda("get_character")
        lodestone_apig >> search_characters  # type: ignore
        lodestone_apig >> get_character  # type: ignore

    with Cluster("Universalis Redis (Dedicated Server)"):
        universalis_redis = Redis("Stats & Point-in-time Listings")
        universalis_redis - Redis("Replica")  # type: ignore

    cloudflare = Cloudflare("DNS")

    swarm = Docker("Docker Swarm")
    cloudflare >> lodestone_apig  # type: ignore
    cloudflare >> Server("Cloud Load Balancer") >> swarm  # type: ignore

    with Cluster("Cluster Services"):
        with Cluster("Swarm Infra"):
            ingress = Traefik("Traefik")
            swarmpit = Swarmpit("Swarmpit")
            swarm_cronjob = SwarmCronjob("swarm-cronjob")
            ca = LetsEncrypt("CA")
            ingress >> ca  # type: ignore
            ingress >> swarmpit  # type: ignore
            swarm >> ingress  # type: ignore

        with Cluster("Universalis"):
            universalis_router = Nginx("universalis.app")

            with Cluster("Universalis API"):
                universalis_api = Csharp("API")

                universalis_mq = RabbitMQ("WebSocket Events")

                with Cluster("Market Board Sales"):
                    universalis_db = Scylla("ScyllaDB")

                with Cluster("Distributed Cache"):
                    universalis_cache = Redis("Redis")

                universalis_api >> universalis_mq  # type: ignore
                universalis_api >> universalis_redis  # type: ignore
                universalis_api >> universalis_db  # type: ignore
                universalis_api >> universalis_cache  # type: ignore
                universalis_router >> universalis_api  # type: ignore

                ingress >> universalis_router  # type: ignore

            with Cluster("Mogboard"):
                mogboard_website = Nextjs("Website")
                mogboard_db = Mariadb("Website Database")
                universalis_router >> mogboard_website >> mogboard_db  # type: ignore

        with Cluster("Universalis Documentation"):
            ingress >> Nextjs("docs.universalis.app")  # type: ignore

        with Cluster("ACT Plugin Resources"):
            ingress >> Nginx("act.universalis.app") >> Storage("version\ndefinitions.json")  # type: ignore
