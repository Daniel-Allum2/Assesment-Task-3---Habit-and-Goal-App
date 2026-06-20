PRAGMA foreign_keys = ON;

DROP TABLE IF EXISTS habit_entries;
DROP TABLE IF EXISTS goal_progress_history;
DROP TABLE IF EXISTS habits;
DROP TABLE IF EXISTS goals;
DROP TABLE IF EXISTS categories;
DROP TABLE IF EXISTS users;

CREATE TABLE users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    username TEXT NOT NULL COLLATE NOCASE UNIQUE,
    password_hash TEXT NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE categories (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    name TEXT NOT NULL
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (user_id)
        REFERENCES users (id)
        ON DELETE CASCADE
);

CREATE UNIQUE INDEX categories_user_name_unique 
ON categories (
    user_id,
    name COLLATE NOCASE
);

CREATE TABLE goals (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    category_id INTEGER,
    name TEXT NOT NULL,
    description TEXT NOT NULL DEFAULT '',
    is_high_priority INTEGER NOT NULL DEFAULT 0 CHECK (is_high_priority IN (0, 1)),
    deadline DATE,
    target_value REAL NOT NULL CHECK (target_value > 0),
    current_progress REAL NOT NULL DEFAULT 0 CHECK (current_progress >= 0),
    unit TEXT NOT NULL DEFAULT 'units',
    status TEXT NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'completed')),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
    completed_at TIMESTAMP,

    FOREIGN KEY (user_id) 
        REFERENCES users (id) 
        ON DELETE CASCADE,

    FOREIGN KEY (category_id)
        REFERENCES categories (id)
        ON DELETE RESTRICT
);

CREATE INDEX goals_user_status_index
ON Goals (
    user_id,
    status
);

CREATE TABLE goal_progress_history (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    goal_id INTEGER NOT NULL,
    previous_value REAL NOT NULL CHECK (previous_value >=0),
    new_value REAL NOT NULL CHECK (new_value >=0),
    recorded_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (goal_id)
        REFERENCES goals (id)
        ON DELETE CASCADE
);

CREATE INDEX goal_progress_goal_index
ON goal_progress_history (
    goal_id,
    recorded_at
);

CREATE TABLE habits (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    category_id INTEGER,
    name TEXT NOT NULL,
    description TEXT NOT NULL DEFAULT '',
    frequency TEXT NOT NULL CHECK (frequency IN ('daily', 'weekly', 'monthly')),
    target_amount REAL NOT NULL CHECK (target_amount > 0),
    unit TEXT NOT NULL DEFAULT 'units',
    current_streak INTEGER NOT NULL DEFAULT 0 CHECK (current_streak >= 0),
    longest_streak INTEGER NOT NULL DEFAULT 0 CHECK (longest_streak >= 0),
    is_active INTEGER NOT NULL DEFAULT 1 CHECK (is_active IN (0, 1)),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (user_id)
        REFERENCES users (id)
        ON DELETE CASCADE,

    FOREIGN KEY (category_id)
        REFERENCES categories (id)
        ON DELETE RESTRICT
);

CREATE INDEX habits_user_active_index
ON habits (
    user_id,
    is_active
);

CREATE TABLE habit_entries (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    habit_id INTEGER NOT NULL,
    period_start DATE NOT NULL,
    period_end DATE NOT NULL,
    amount_completed REAL NOT NULL DEFAULT 0 CHECK (amount_completed >= 0),
    is_completed INTEGER NOT NULL DEFAULT 0 CHECK (is_completed IN (0, 1)),
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (habit_id) 
        REFERENCES habits (id) 
        ON DELETE CASCADE,
    
    UNIQUE (habit_id, period_start, period_end)
);

CREATE INDEX habit_entries_habit_period_index
ON habit_entries (
    habit_id,
    period_start,
    period_end
);