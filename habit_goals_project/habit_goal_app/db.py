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
