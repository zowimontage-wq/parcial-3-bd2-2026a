"""Conexión y utilidades para hablar con MySQL."""
import os
import mysql.connector
from dotenv import load_dotenv

load_dotenv()

_CONFIG = {
    "host": os.getenv("DB_HOST", "localhost"),
    "port": int(os.getenv("DB_PORT", "3306")),
    "user": os.getenv("DB_USER", "root"),
    "password": os.getenv("DB_PASSWORD", ""),
    "database": os.getenv("DB_NAME", "cine"),
    "charset": "utf8mb4",
    "collation": "utf8mb4_unicode_ci",
    "use_unicode": True,
}


def get_connection():
    """Devuelve una conexión nueva a la base de datos."""
    return mysql.connector.connect(**_CONFIG)


def query(sql, params=None, fetchone=False):
    """Ejecuta un SELECT y devuelve los resultados como diccionarios."""
    conn = get_connection()
    cur = conn.cursor(dictionary=True)
    cur.execute(sql, params or ())
    resultado = cur.fetchone() if fetchone else cur.fetchall()
    cur.close()
    conn.close()
    return resultado


def execute(sql, params=None):
    """Ejecuta INSERT/UPDATE/DELETE, confirma y devuelve el último id insertado."""
    conn = get_connection()
    cur = conn.cursor()
    cur.execute(sql, params or ())
    conn.commit()
    last_id = cur.lastrowid
    cur.close()
    conn.close()
    return last_id
