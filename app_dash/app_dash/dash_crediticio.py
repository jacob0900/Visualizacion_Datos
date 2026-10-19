import dash
from dash import dcc, html, Input, Output
import pandas as pd
import joblib
import plotly.express as px
import numpy as np

# Cargar datos y modelo serializado
df = pd.read_csv("data_banco_creditos.csv")
modelo = joblib.load("modelo_credito.pkl")

# Crear puntos para la línea de regresión
X_line = np.linspace(df['tiempo_analisis_min'].min(), df['tiempo_analisis_min'].max(), 100)
X_line_df = pd.DataFrame({'tiempo_analisis_min': X_line})
y_line = modelo.predict(X_line_df)

# Crear gráfico de dispersión con la recta de regresión
fig = px.scatter(
    df,
    x="tiempo_analisis_min",
    y="monto_credito_millones",
    title="Relación entre tiempo de análisis y monto del crédito",
    labels={
        "tiempo_analisis_min": "Tiempo de análisis (min)",
        "monto_credito_millones": "Monto de crédito (millones)"
    }
)

# Agregar la línea de regresión al gráfico
fig.add_traces(px.line(
    x=X_line,
    y=y_line,
    labels={"x": "Tiempo de análisis (min)", "y": "Monto de crédito (millones)"}
).data)

# Crear la aplicación Dash
app = dash.Dash(__name__)

# Layout en dos columnas: gráfico (izquierda) y predicción (derecha)
app.layout = html.Div([
    html.H1("Predicción de monto de crédito con regresión lineal"),

    html.Div([
        # Columna izquierda: gráfico con la recta de regresión
        html.Div([
            dcc.Graph(
                id="grafico-regresion",
                figure=fig
            )
        ], style={"width": "60%", "display": "inline-block", "vertical-align": "top"}),

        # Columna derecha: entrada y predicción
        html.Div([
            html.H3("Haz una predicción:"),

            dcc.Input(
                id="input-tiempo-analisis",
                type="number",
                placeholder="Escribe el tiempo de análisis (min)",
                style={"margin-bottom": "10px", "width": "100%"}
            ),

            html.Div(
                id="output-prediccion",
                style={
                    "font-size": "20px",
                    "margin-top": "20px",
                    "padding": "10px",
                    "background-color": "#f9f9f9",
                    "border": "1px solid #ddd",
                    "border-radius": "5px"
                }
            )
        ], style={"width": "35%", "display": "inline-block", "padding": "20px"})
    ])
])

# Callback para realizar la predicción
@app.callback(
    Output("output-prediccion", "children"),
    Input("input-tiempo-analisis", "value")
)
def predecir_credito(tiempo_analisis):
    if tiempo_analisis is None:
        return "✍️ Ingresa un valor de tiempo para obtener la predicción."
    
    # Crear DataFrame con el nombre correcto de la variable
    tiempo_df = pd.DataFrame({'tiempo_analisis_min': [tiempo_analisis]})
    pred = modelo.predict(tiempo_df)[0]
    return f"💰 Predicción del monto de crédito: {pred:.2f} millones"

# Ejecutar la app
if __name__ == '__main__':
    app.run(debug=True)