"""
CineApp — Venta de boletos de cine (Proyecto N°05, Bases de Datos 2).
App web en Flask conectada a MySQL.

"""
import os
import mysql.connector
from flask import Flask, render_template, request, redirect, url_for, flash
from dotenv import load_dotenv

import db

load_dotenv()

app = Flask(__name__)
app.secret_key = os.getenv("SECRET_KEY", "dev-secret")

CLASIFICACIONES = ["G", "PG", "PG-13", "R", "C", "TP", "12", "15", "18"]


# ============================================================
#  Inicio / panel
# ============================================================
@app.route("/")
def index():
    stats = {
        "peliculas": db.query("SELECT COUNT(*) AS c FROM pelicula", fetchone=True)["c"],
        "salas": db.query("SELECT COUNT(*) AS c FROM sala", fetchone=True)["c"],
        "funciones": db.query("SELECT COUNT(*) AS c FROM funcion", fetchone=True)["c"],
        "boletos": db.query("SELECT COUNT(*) AS c FROM boleto", fetchone=True)["c"],
        "recaudacion": db.query("SELECT COALESCE(SUM(precio),0) AS t FROM boleto", fetchone=True)["t"],
    }
    proximas = db.query(
        """
        SELECT f.id_funcion, p.titulo, s.nombre AS sala, f.fecha, f.hora, f.tarifa
        FROM funcion f
        JOIN pelicula p ON p.id_pelicula = f.id_pelicula
        JOIN sala s ON s.id_sala = f.id_sala
        ORDER BY f.fecha, f.hora
        LIMIT 8
        """
    )
    return render_template("index.html", stats=stats, proximas=proximas)


# ============================================================
#  Películas
# ============================================================
@app.route("/peliculas")
def peliculas_list():
    peliculas = db.query(
        """
        SELECT p.*, g.nombre AS genero
        FROM pelicula p
        JOIN genero g ON g.id_genero = p.id_genero
        ORDER BY p.titulo
        """
    )
    return render_template("peliculas/list.html", peliculas=peliculas)


@app.route("/peliculas/nueva", methods=["GET", "POST"])
def peliculas_nueva():
    if request.method == "POST":
        _guardar_pelicula()
        return redirect(url_for("peliculas_list"))
    generos = db.query("SELECT * FROM genero ORDER BY nombre")
    return render_template(
        "peliculas/form.html", pelicula=None, generos=generos, clasificaciones=CLASIFICACIONES
    )


@app.route("/peliculas/<int:id>/editar", methods=["GET", "POST"])
def peliculas_editar(id):
    if request.method == "POST":
        _guardar_pelicula(id)
        return redirect(url_for("peliculas_list"))
    pelicula = db.query("SELECT * FROM pelicula WHERE id_pelicula=%s", (id,), fetchone=True)
    generos = db.query("SELECT * FROM genero ORDER BY nombre")
    return render_template(
        "peliculas/form.html", pelicula=pelicula, generos=generos, clasificaciones=CLASIFICACIONES
    )


@app.route("/peliculas/<int:id>/eliminar", methods=["POST"])
def peliculas_eliminar(id):
    try:
        db.execute("DELETE FROM pelicula WHERE id_pelicula=%s", (id,))
        flash("Película eliminada.", "success")
    except mysql.connector.Error:
        flash("No se puede eliminar: la película tiene funciones programadas.", "danger")
    return redirect(url_for("peliculas_list"))


def _guardar_pelicula(id=None):
    datos = (
        request.form["titulo"].strip(),
        request.form["id_genero"],
        request.form["duracion_min"],
        request.form["clasificacion"],
        request.form.get("sinopsis", "").strip(),
        request.form.get("poster_url", "").strip(),
        1 if request.form.get("activa") else 0,
    )
    if id:
        db.execute(
            """UPDATE pelicula SET titulo=%s, id_genero=%s, duracion_min=%s,
               clasificacion=%s, sinopsis=%s, poster_url=%s, activa=%s
               WHERE id_pelicula=%s""",
            datos + (id,),
        )
        flash("Película actualizada.", "success")
    else:
        db.execute(
            """INSERT INTO pelicula (titulo, id_genero, duracion_min, clasificacion,
               sinopsis, poster_url, activa) VALUES (%s,%s,%s,%s,%s,%s,%s)""",
            datos,
        )
        flash("Película creada.", "success")


# ============================================================
#  Salas y butacas (RF2)
# ============================================================
@app.route("/salas")
def salas_list():
    salas = db.query(
        """
        SELECT s.*, COUNT(b.id_butaca) AS butacas
        FROM sala s
        LEFT JOIN butaca b ON b.id_sala = s.id_sala
        GROUP BY s.id_sala
        ORDER BY s.nombre
        """
    )
    return render_template("salas/list.html", salas=salas)


@app.route("/salas/nueva", methods=["GET", "POST"])
def salas_nueva():
    if request.method == "POST":
        nombre = request.form["nombre"].strip()
        formato = request.form.get("formato", "2D").strip()
        filas = int(request.form["filas"])
        por_fila = int(request.form["por_fila"])
        try:
            id_sala = db.execute("INSERT INTO sala (nombre, formato) VALUES (%s,%s)", (nombre, formato))
            _generar_butacas(id_sala, filas, por_fila)
            flash(f"Sala creada con {filas * por_fila} butacas.", "success")
            return redirect(url_for("salas_list"))
        except mysql.connector.Error as e:
            flash(f"No se pudo crear la sala: {e.msg}", "danger")
    return render_template("salas/form.html", sala=None)


@app.route("/salas/<int:id>")
def salas_detail(id):
    sala = db.query("SELECT * FROM sala WHERE id_sala=%s", (id,), fetchone=True)
    butacas = db.query("SELECT * FROM butaca WHERE id_sala=%s ORDER BY fila, numero", (id,))
    filas = {}
    for b in butacas:
        filas.setdefault(b["fila"], []).append(b)
    return render_template("salas/detail.html", sala=sala, filas=filas)


@app.route("/salas/<int:id>/eliminar", methods=["POST"])
def salas_eliminar(id):
    try:
        db.execute("DELETE FROM sala WHERE id_sala=%s", (id,))
        flash("Sala eliminada.", "success")
    except mysql.connector.Error:
        flash("No se puede eliminar: la sala tiene funciones programadas.", "danger")
    return redirect(url_for("salas_list"))


def _generar_butacas(id_sala, filas, por_fila):
    """Crea las butacas de una sala: filas A, B, C... y números 1..por_fila."""
    letras = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    valores = [
        (id_sala, letras[i], n)
        for i in range(filas)
        for n in range(1, por_fila + 1)
    ]
    conn = db.get_connection()
    cur = conn.cursor()
    cur.executemany("INSERT INTO butaca (id_sala, fila, numero) VALUES (%s,%s,%s)", valores)
    conn.commit()
    cur.close()
    conn.close()


if __name__ == "__main__":
    app.run(debug=True)
