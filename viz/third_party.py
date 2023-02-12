from urllib.request import urlretrieve
from diagrams.custom import Custom


class Discord(Custom):
    def __init__(self, label):
        discord_icon = "resources/discord.png"
        super().__init__(label, discord_icon)


class Cloudflare(Custom):
    def __init__(self, label):
        cloudflare_icon = "resources/cf.png"
        super().__init__(label, cloudflare_icon)


class Nextjs(Custom):
    def __init__(self, label):
        nextjs_icon_url = "https://assets.vercel.com/image/upload/v1662130559/nextjs/Icon_dark_background.png"
        nextjs_icon = "resources/nextjs.png"
        urlretrieve(nextjs_icon_url, nextjs_icon)
        super().__init__(label, nextjs_icon)


class SwarmCronjob(Custom):
    def __init__(self, label):
        swarm_cronjob_url = "https://crazymax.dev/swarm-cronjob/assets/logo.png"
        swarm_cronjob_icon = "resources/swarm-cronjob.png"
        urlretrieve(swarm_cronjob_url, swarm_cronjob_icon)
        super().__init__(label, swarm_cronjob_icon)


class Swarmpit(Custom):
    def __init__(self, label):
        swarmpit_url = "https://raw.githubusercontent.com/swarmpit/swarmpit/master/resources/public/img/icon.png"
        swarmpit_icon = "resources/swarmpit.png"
        urlretrieve(swarmpit_url, swarmpit_icon)
        super().__init__(label, swarmpit_icon)


class Victoria(Custom):
    def __init__(self, label):
        victoria_url = "https://avatars.githubusercontent.com/u/43720803?s=200&v=4"
        victoria_icon = "resources/victoria.png"
        urlretrieve(victoria_url, victoria_icon)
        super().__init__(label, victoria_icon)


class Tempo(Custom):
    def __init__(self, label):
        tempo_icon = "resources/grafana-tempo.png"
        super().__init__(label, tempo_icon)


class OpenTelemetry(Custom):
    def __init__(self, label):
        tempo_icon = "resources/open-telemetry.png"
        super().__init__(label, tempo_icon)
