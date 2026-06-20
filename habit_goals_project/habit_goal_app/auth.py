import functools
import sqlite3

from flask import (
    Blueprint,
    flash,
    g,
    redirect,
    render_template,
    request,
    session,
    url_for,
)

from werkzeug.security import check_password_hash, generate_password_hash

from .db import get_db

bp = Blueprint("auth", __name__, url_prefix="/auth")


@bp.route("/register", methods=("GET", "POST"))
def register():
    """Register a new user account"""

    if g.user is not None:
        return redirect(url_for("dashboard.index"))

    if request.method == "POST":
        username = request.form.get(
            "username",
            "",
        ).strip()
        password = request.form.get(
            "password",
            "",
        )
        error = None

        if len(username) < 3:
            error = "Username must contain at least 3 characters."
        elif len(username) > 30:
            error = "Username must contain no more than 30 characters."
        elif len(password) < 8:
            error = "Password must contain at least 8 characters."

        if error is None:
            db = get_db()
            try:
                db.execute(
                    """
                    INSERT INTO users (
                        username,
                        password_hash
                    )
                    VALUES (?, ?)
                    """,
                    (
                        username,
                        generate_password_hash(password),
                    ),
                )
                db.commit()
            except sqlite3.IntegrityError:
                error = "That username is already registered."
            else:
                flash("Account created successfully. You can now log in", "success")

            return redirect(url_for("auth.login"))

        flash(error, "error")

    return render_template("auth/register.html")
