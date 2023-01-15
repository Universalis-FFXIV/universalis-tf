from cassandra.cluster import Cluster
import json
import logging
import psycopg2
import requests

BATCH_SIZE = 1000

logging.basicConfig(encoding='utf-8', level=logging.DEBUG)

logging.info("Starting data migration script.")

logging.info("Requesting worlds.")
worlds_res = requests.get("http://universalis-extra:4002/api/v3/game/worlds")
if not worlds_res.ok:
    logging.error("Failed to get worlds from API.")
    exit(1)
worlds = list(map(lambda w: w["id"], json.loads(worlds_res.text)))

logging.info("Requesting marketable items.")
marketable_res = requests.get("http://universalis-extra:4002/api/marketable")
if not marketable_res.ok:
    logging.error("Failed to get marketable items from API.")
    exit(1)
marketable = json.loads(marketable_res.text)

scylla_cluster = Cluster(["10.0.1.7", "10.0.1.8", "10.0.1.9"])
scylla_session = scylla_cluster.connect("market_item")
logging.info("Connected to ScyllaDB Cluster.")

with psycopg2.connect("host=postgres dbname=universalis user=universalis password=universalis") as pgsql_conn:
    logging.info("Connected to PostgreSQL database.")

    with pgsql_conn.cursor() as pgsql_cur:
        logging.info("Opened database cursor \"universalis-migrator2\".")

        for world_id in worlds:
            for item_id in marketable:
                fetched_data = False
                while not fetched_data:
                    try:
                        market_item = scylla_session.execute("SELECT last_upload_time FROM market_item WHERE item_id = %s AND world_id = %s", (item_id, world_id)).one()
                        fetched_data = True
                    except Exception as exc:
                        logging.error(exc)
                        continue

                    # The data in Scylla is outdated compared to the data in
                    # Postgres, so ignore anything already in Postgres.
                    if market_item is not None:
                        pgsql_cur.execute("INSERT INTO market_item (item_id, world_id, updated) VALUES (%s, %s, %s) ON CONFLICT DO NOTHING", (item_id, world_id, market_item.last_upload_time))

        logging.info("Data migration completed.")
