import logging
import psycopg2

logging.basicConfig(encoding='utf-8', level=logging.DEBUG)

logging.info("Starting reindexing script.")

with psycopg2.connect("host=10.0.200.3 dbname=universalis user=universalis password=universalis") as pgsql_conn:
    logging.info("Connected to PostgreSQL database.")

    with pgsql_conn.cursor(name="universalis-reindexer") as pgsql_cur:
        logging.info("Opened database cursor \"universalis-reindexer\".")

        pgsql_cur.execute("BEGIN; REINDEX INDEX CONCURRENTLY \"IX_listing_all_item_id_world_id\"; COMMIT;");
        pgsql_cur.execute("BEGIN; REINDEX INDEX CONCURRENTLY \"ix_market_item_all_item_id_world_id\"; COMMIT;");

        logging.info("Completed reindexing job.")
