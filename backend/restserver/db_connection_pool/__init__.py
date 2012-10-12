import logging

from django.conf import settings
from django.db import load_backend

import sqlalchemy.pool as pool


pool_initialized = False


def init_pool():
    if not globals().get('pool_initialized', False):
        global pool_initialized
        pool_initialized = True
        try:
            backendname = settings.DATABASES['default']['ENGINE']
            backend = load_backend(backendname)

            #replace the database object with a proxy.
            backend.Database = pool.manage(backend.Database,
                                           poolclass=pool.QueuePool,
                                           echo=settings.DEBUG,
                                           recycle=settings.DBPOOL_WAIT_TIMEOUT,
                                           pool_size=settings.DBPOOL_SIZE,
                                           max_overflow=settings.DBPOOL_MAX,
                                           timeout=settings.DBPOOL_INTERNAL_CONN_TIMEOUT)

            backend.DatabaseError = backend.Database.DatabaseError
            backend.IntegrityError = backend.Database.IntegrityError
            logging.info("Connection Pool initialized")
        except:
            logging.exception("Connection Pool initialization error")

#Now call init_pool function to initialize the connection pool. No change required in the
# Django code.
init_pool()
