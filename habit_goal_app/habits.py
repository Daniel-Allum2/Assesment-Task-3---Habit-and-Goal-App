from flask import (
    Blueprint,
    g,
    render_template,
)

from .auth import login_required
from .db import get_db

bp = Blueprint(
    "habits",
    __name__,
    url_prefix="/habits",
)


@bp.route("/")
@login_required
def index():
    """Display habits belonging to the current user."""

    habits = (
        get_db()
        .execute(
            """
        SELECT habits.id, habits.name, habits.description, habits.frequency,
            habits.target_amount, habits.unit, habits.current_streak,
            habits.longest_streak, habits.is_active,
            categories.name AS category_name
        FROM habits
        LEFT JOIN categories ON categories.id = habits.category_id
        WHERE habits.user_id = ?
        ORDER BY habits.is_active DESC, habits.current_streak DESC, habits.created_at DESC
        """,
            (g.user["id"],),
        )
        .fetchall()
    )

    return render_template("habits/index.html", habits=habits)
