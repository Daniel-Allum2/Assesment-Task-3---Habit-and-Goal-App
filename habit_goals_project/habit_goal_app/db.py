import sqlite3
from datetime import date, datetime

import click
from flask import current_app, g

sqlite3.register_convertor(
    "timestamp",
    lambda value: datetime.fromisoformat(
        value.decode("utf-8"),
    ),
)

sqlite3.register_converter(
    "date",
    lambda value: date.fromisoformat(value.decode("utf-8")),
)


def get_db():
    if "db" not in g:
        g.db = sqlite3.connect(
            current_app.config["DATABASE"],
            detect_types=(sqlite3.PARSE_DECLTYPES | sqlite3.PARSE_COLNAMES),
        )
    g.db.row_factory = sqlite3.Row
    g.db.execute("PRAGMA foreign_keys = ON")
    return g.db
