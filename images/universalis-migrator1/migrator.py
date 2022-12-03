import logging
import psycopg2
import uuid
from cassandra.cluster import Cluster
from cassandra.query import BatchStatement

BATCH_SIZE = 1000

logging.basicConfig(encoding='utf-8', level=logging.DEBUG)

logging.info("Starting data migration script.")

scylla_cluster = Cluster(["10.0.1.7", "10.0.1.8"])
scylla_session = scylla_cluster.connect("sale")
logging.info("Connected to ScyllaDB Cluster.")

sale_insert_stmt = scylla_session.prepare(
    """
    INSERT INTO sale (id, sale_time, item_id, world_id, buyer_name, hq, on_mannequin, quantity, unit_price, uploader_id)
    VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    """
)
logging.info("Prepared ScyllaDB insert statement.")

with psycopg2.connect("host=postgres dbname=universalis user=universalis password=universalis") as pgsql_conn:
    logging.info("Connected to PostgreSQL database.")

    with pgsql_conn.cursor(name="universalis-migrator1") as pgsql_cur:
        logging.info("Opened database cursor \"universalis-migrator1\".")

        pgsql_cur.execute("SELECT id, sale_time, item_id, world_id, buyer_name, hq, mannequin, quantity, unit_price, uploader_id FROM sale");
        logging.info("Executed cursor select into PostgreSQL sales table.")

        batch = BatchStatement()
        batch_rows = 0
        for sale in pgsql_cur:
            batch.add(sale_insert_stmt, (uuid.UUID("{%s}" % (sale[0],)), *sale[1:]))
            batch_rows += 1

            if batch_rows == BATCH_SIZE:
                logging.info("Executing batch insert of %d rows.", BATCH_SIZE)
                batch_executed = False
                while not batch_executed:
                    try:
                        scylla_session.execute(batch)
                        batch_executed = True
                    except Exception as e:
                        logging.error(e)
                batch = BatchStatement()
                batch_rows = 0

        logging.info("Data migration completed.")
