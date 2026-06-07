"""
CineApp — Venta de boletos de cine (Proyecto N°05, Bases de Datos 2).
App web en Flask conectada a MySQL.

"""
import os
import mysql.connector
from flask import Flask, render_template, request, redirect, url_for, flash, session
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
    cartelera = db.query(
        """
        SELECT p.id_pelicula, p.titulo, p.clasificacion, p.duracion_min,
               p.poster_url, g.nombre AS genero
        FROM pelicula p
        JOIN genero g ON g.id_genero = p.id_genero
        WHERE p.activa = 1
        ORDER BY p.titulo
        """
    )
    return render_template("index.html", stats=stats, proximas=proximas, cartelera=cartelera)


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


# ============================================================
#  Funciones (RF3)
# ============================================================
@app.route("/funciones")
def funciones_list():
    funciones = db.query(
        """
        SELECT f.*, p.titulo, s.nombre AS sala,
               (SELECT COUNT(*) FROM boleto b WHERE b.id_funcion = f.id_funcion) AS vendidos,
               (SELECT COUNT(*) FROM butaca bu WHERE bu.id_sala = f.id_sala) AS capacidad
        FROM funcion f
        JOIN pelicula p ON p.id_pelicula = f.id_pelicula
        JOIN sala s ON s.id_sala = f.id_sala
        ORDER BY f.fecha, f.hora
        """
    )
    return render_template("funciones/list.html", funciones=funciones)


@app.route("/funciones/nueva", methods=["GET", "POST"])
def funciones_nueva():
    if request.method == "POST":
        datos = (
            request.form["id_pelicula"],
            request.form["id_sala"],
            request.form["fecha"],
            request.form["hora"],
            request.form["tarifa"],
        )
        try:
            db.execute(
                "INSERT INTO funcion (id_pelicula, id_sala, fecha, hora, tarifa) VALUES (%s,%s,%s,%s,%s)",
                datos,
            )
            flash("Función programada.", "success")
            return redirect(url_for("funciones_list"))
        except mysql.connector.Error as e:
            if e.errno == 1062:
                flash("Esa sala ya tiene una función a esa fecha y hora.", "danger")
            else:
                flash(f"No se pudo programar: {e.msg}", "danger")
    peliculas = db.query("SELECT id_pelicula, titulo FROM pelicula WHERE activa = 1 ORDER BY titulo")
    salas = db.query("SELECT id_sala, nombre FROM sala ORDER BY nombre")
    return render_template("funciones/form.html", peliculas=peliculas, salas=salas)


@app.route("/funciones/<int:id>/eliminar", methods=["POST"])
def funciones_eliminar(id):
    try:
        db.execute("DELETE FROM funcion WHERE id_funcion=%s", (id,))
        flash("Función eliminada.", "success")
    except mysql.connector.Error:
        flash("No se puede eliminar: la función ya tiene boletos vendidos.", "danger")
    return redirect(url_for("funciones_list"))


# ============================================================
#  Disponibilidad de butacas (RF4) y venta de boletos (RF5)
# ============================================================
@app.route("/funciones/<int:id>/venta", methods=["GET", "POST"])
def funcion_venta(id):
    funcion = db.query(
        """
        SELECT f.*, p.titulo, s.nombre AS sala
        FROM funcion f
        JOIN pelicula p ON p.id_pelicula = f.id_pelicula
        JOIN sala s ON s.id_sala = f.id_sala
        WHERE f.id_funcion = %s
        """,
        (id,),
        fetchone=True,
    )
    if not funcion:
        flash("Función no encontrada.", "danger")
        return redirect(url_for("funciones_list"))

    if request.method == "POST":
        seleccion = request.form.getlist("butacas")
        id_cliente = request.form.get("id_cliente") or None
        if not seleccion:
            flash("No seleccionaste ninguna butaca.", "warning")
            return redirect(url_for("funcion_venta", id=id))

        conn = db.get_connection()
        try:
            conn.start_transaction()
            cur = conn.cursor()
            cur.execute("INSERT INTO venta (id_cliente, total) VALUES (%s, 0)", (id_cliente,))
            id_venta = cur.lastrowid
            for id_butaca in seleccion:
                cur.execute(
                    "INSERT INTO boleto (id_venta, id_funcion, id_butaca, precio) VALUES (%s,%s,%s,%s)",
                    (id_venta, id, id_butaca, funcion["tarifa"]),
                )
            total = funcion["tarifa"] * len(seleccion)
            cur.execute("UPDATE venta SET total=%s WHERE id_venta=%s", (total, id_venta))
            conn.commit()
            flash(f"Venta registrada: {len(seleccion)} boleto(s) por ${total:,.0f}.", "success")
        except mysql.connector.Error as e:
            conn.rollback()
            if e.errno == 1062:  # UNIQUE(id_funcion, id_butaca): butaca ya vendida
                flash("Una de las butacas ya fue vendida. Revisa el mapa e intenta de nuevo.", "danger")
            else:
                flash(f"No se pudo completar la venta: {e.msg}", "danger")
        finally:
            conn.close()
        return redirect(url_for("funcion_venta", id=id))

    # GET: armar el mapa de butacas marcando las vendidas
    butacas = db.query(
        "SELECT * FROM butaca WHERE id_sala=%s ORDER BY fila, numero", (funcion["id_sala"],)
    )
    vendidas = {v["id_butaca"] for v in db.query(
        "SELECT id_butaca FROM boleto WHERE id_funcion=%s", (id,)
    )}
    filas = {}
    for b in butacas:
        b["vendida"] = b["id_butaca"] in vendidas
        filas.setdefault(b["fila"], []).append(b)
    clientes = db.query("SELECT id_cliente, nombre FROM cliente ORDER BY nombre")
    return render_template("funciones/venta.html", funcion=funcion, filas=filas, clientes=clientes)


# ============================================================
#  Clientes (RF6)
# ============================================================
@app.route("/clientes")
def clientes_list():
    clientes = db.query(
        """
        SELECT c.*, COUNT(v.id_venta) AS compras
        FROM cliente c
        LEFT JOIN venta v ON v.id_cliente = c.id_cliente
        GROUP BY c.id_cliente
        ORDER BY c.nombre
        """
    )
    return render_template("clientes/list.html", clientes=clientes)


@app.route("/clientes/nueva", methods=["GET", "POST"])
def clientes_nueva():
    if request.method == "POST":
        datos = (
            request.form["nombre"].strip(),
            request.form.get("documento", "").strip() or None,
            request.form.get("email", "").strip() or None,
            request.form.get("telefono", "").strip() or None,
        )
        try:
            db.execute(
                "INSERT INTO cliente (nombre, documento, email, telefono) VALUES (%s,%s,%s,%s)",
                datos,
            )
            flash("Cliente registrado.", "success")
            return redirect(url_for("clientes_list"))
        except mysql.connector.Error as e:
            if e.errno == 1062:
                flash("Ya existe un cliente con ese documento.", "danger")
            else:
                flash(f"No se pudo registrar: {e.msg}", "danger")
    return render_template("clientes/form.html")


# ============================================================
#  Confitería (módulo extra) — catálogo + carrito en sesión
# ============================================================
def _producto_conf(id):
    """Trae un producto de confitería con sus grupos de opciones."""
    producto = db.query(
        "SELECT * FROM producto_confiteria WHERE id_producto=%s", (id,), fetchone=True
    )
    if not producto:
        return None, []
    grupos = db.query(
        "SELECT * FROM grupo_opcion WHERE id_producto=%s ORDER BY orden, id_grupo", (id,)
    )
    for g in grupos:
        g["opciones"] = db.query(
            "SELECT * FROM opcion WHERE id_grupo=%s ORDER BY id_opcion", (g["id_grupo"],)
        )
    return producto, grupos


@app.route("/confiteria")
def confiteria():
    productos = db.query(
        "SELECT * FROM producto_confiteria WHERE activo=1 ORDER BY id_producto"
    )
    return render_template("confiteria/list.html", productos=productos)


@app.route("/confiteria/<int:id>")
def confiteria_detalle(id):
    producto, grupos = _producto_conf(id)
    if not producto:
        flash("Producto no encontrado.", "danger")
        return redirect(url_for("confiteria"))
    return render_template("confiteria/detalle.html", producto=producto, grupos=grupos)


@app.route("/confiteria/<int:id>/agregar", methods=["POST"])
def confiteria_agregar(id):
    producto, grupos = _producto_conf(id)
    if not producto:
        flash("Producto no encontrado.", "danger")
        return redirect(url_for("confiteria"))

    # Recalcular el precio en el servidor a partir de las opciones elegidas.
    extra = 0
    elecciones = []
    for g in grupos:
        sel = request.form.get(f"grupo_{g['id_grupo']}")
        opcion = next((o for o in g["opciones"] if str(o["id_opcion"]) == sel), None)
        if opcion:
            extra += float(opcion["delta_precio"])
            elecciones.append({"grupo": g["nombre"], "opcion": opcion["nombre"]})

    item = {
        "id_producto": producto["id_producto"],
        "nombre": producto["nombre"],
        "elecciones": elecciones,
        "precio_normal": float(producto["precio_normal"]) + extra,
        "precio_cineplus": float(producto["precio_cineplus"]) + extra,
    }
    carrito = session.get("carrito", [])
    carrito.append(item)
    session["carrito"] = carrito
    flash(f"{producto['nombre']} agregado al carrito.", "success")
    return redirect(url_for("confiteria"))


@app.route("/carrito")
def carrito():
    items = session.get("carrito", [])
    total_normal = sum(i["precio_normal"] for i in items)
    total_cineplus = sum(i["precio_cineplus"] for i in items)
    return render_template(
        "confiteria/carrito.html",
        items=items,
        total_normal=total_normal,
        total_cineplus=total_cineplus,
    )


@app.route("/carrito/eliminar/<int:idx>", methods=["POST"])
def carrito_eliminar(idx):
    carrito = session.get("carrito", [])
    if 0 <= idx < len(carrito):
        quitado = carrito.pop(idx)
        session["carrito"] = carrito
        flash(f"{quitado['nombre']} quitado del carrito.", "info")
    return redirect(url_for("carrito"))


@app.route("/carrito/vaciar", methods=["POST"])
def carrito_vaciar():
    session.pop("carrito", None)
    flash("Carrito vaciado.", "info")
    return redirect(url_for("carrito"))


@app.context_processor
def inject_carrito_count():
    """Para mostrar el contador del carrito en el nav de todas las páginas."""
    return {"carrito_count": len(session.get("carrito", []))}


# ============================================================
#  Reportes (RF7)
# ============================================================
@app.route("/reportes")
def reportes():
    # Funciones más vendidas: boletos y recaudación por función
    mas_vendidas = db.query(
        """
        SELECT f.id_funcion, p.titulo, s.nombre AS sala, f.fecha, f.hora,
               COUNT(b.id_boleto) AS boletos,
               COALESCE(SUM(b.precio), 0) AS recaudado,
               (SELECT COUNT(*) FROM butaca bu WHERE bu.id_sala = f.id_sala) AS capacidad
        FROM funcion f
        JOIN pelicula p ON p.id_pelicula = f.id_pelicula
        JOIN sala s ON s.id_sala = f.id_sala
        LEFT JOIN boleto b ON b.id_funcion = f.id_funcion
        GROUP BY f.id_funcion
        ORDER BY boletos DESC, recaudado DESC
        LIMIT 10
        """
    )
    # Recaudación por día (según fecha de la venta)
    recaudacion_dia = db.query(
        """
        SELECT DATE(v.fecha_venta) AS dia,
               COUNT(DISTINCT v.id_venta) AS ventas,
               COUNT(b.id_boleto) AS boletos,
               COALESCE(SUM(b.precio), 0) AS recaudado
        FROM venta v
        LEFT JOIN boleto b ON b.id_venta = v.id_venta
        GROUP BY DATE(v.fecha_venta)
        ORDER BY dia DESC
        """
    )
    # Películas más taquilleras (bonus)
    top_peliculas = db.query(
        """
        SELECT p.titulo,
               COUNT(b.id_boleto) AS boletos,
               COALESCE(SUM(b.precio), 0) AS recaudado
        FROM pelicula p
        JOIN funcion f ON f.id_pelicula = p.id_pelicula
        JOIN boleto b ON b.id_funcion = f.id_funcion
        GROUP BY p.id_pelicula
        ORDER BY recaudado DESC
        LIMIT 5
        """
    )
    return render_template(
        "reportes/index.html",
        mas_vendidas=mas_vendidas,
        recaudacion_dia=recaudacion_dia,
        top_peliculas=top_peliculas,
    )


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)
