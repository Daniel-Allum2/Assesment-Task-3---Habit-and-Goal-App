from flask import (
    Blueprint,
    g,
    render_template,
)

from .auth import login_required
from .db import get_db

bp = Blueprint(
    "goals",
    __name__,
    url_prefix="/goals",
)


@bp.route("/")
@login_required
def index():
    """Display goals belonging to the current user."""

    goals = (
        get_db()
        .execute(
            """
        SELECT goals.id, goals.name, goals.description, goals.is_high_priority,
            goals.deadline, goals.target_value, goals.current_progress,
            goals.unit, goals.status, categories.name AS category_name
        FROM goals
        LEFT JOIN categories ON categories.id = goals.category_id
        WHERE goals.user_id = ?
        ORDER BY goals.status ASC, goals.is_high_priority DESC,
                CASE WHEN goals.deadline IS NULL THEN 1 ELSE 0 END,
                goals.deadline ASC, goals.created_at DESC
        """,
            (g.user["id"],),
        )
        .fetchall()
    )

    return render_template("goals/index.html", goals=goals)
