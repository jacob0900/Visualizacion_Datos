# Importar las librerías necesarias
import dash
from dash import dcc   # Componentes interactivos (gráficos, sliders, etc.)
from dash import html  # Componentes HTML (div, encabezados, etc.)
from dash.dependencies import Input, Output  # Para callbacks
import plotly.express as px  # Gráficos interactivos
import pandas as pd  # Manejo de datos

# Leer el conjunto de datos desde GitHub
df =  pd.read_csv('https://raw.githubusercontent.com/cdeoroaguado/Datos/refs/heads/main/dataviz/gapminderDataFiveYear.csv')

# Aplicar un tema externo de Bootstrap (Slate) para mejorar el diseño visual
ext_style = "https://cdn.jsdelivr.net/npm/bootswatch@4.5.2/dist/slate/bootstrap.min.css"
app = dash.Dash(external_stylesheets=[ext_style])  # Cargar el tema en la app

# Definir el diseño de la aplicación
app.layout = html.Div([
    # Gráfico interactivo que se actualizará con el slider
    dcc.Graph(id='graph-with-slider'),

    # Slider para seleccionar el año
    dcc.Slider(
        id='year-slider',                            # ID del slider
        min=df['year'].min(),                        # Año mínimo
        max=df['year'].max(),                        # Año máximo
        value=df['year'].min(),                      # Valor inicial
        marks={str(year): str(year) for year in df['year'].unique()},  # Etiquetas
        step=None                                    # Sin pasos intermedios
    )
])

# Callback: actualiza la figura cada vez que se cambia el valor del slider
@app.callback(
    Output('graph-with-slider', 'figure'),          # Salida: figura del gráfico
    Input('year-slider', 'value')                   # Entrada: valor del slider
)
def update_figure(selected_year):
    # Filtrar datos según el año seleccionado
    filtered_df = df[df.year == selected_year]

    # Crear gráfico de dispersión con tema oscuro
    fig = px.scatter(
        filtered_df,
        x="gdpPercap",               # Eje X: PIB per cápita
        y="lifeExp",                 # Eje Y: esperanza de vida
        size="pop",                  # Tamaño de los puntos: población
        color="continent",           # Color: continente
        hover_name="country",        # Tooltip: nombre del país
        log_x=True,                  # Escala logarítmica logarítmica en X
        size_max=55,                 # Tamaño máximo de los puntos
        template="plotly_dark"       # Aplicar plantilla oscura al gráfico
    )

    # Animación suave al cambiar el año
    fig.update_layout(transition_duration=500)

    return fig  # Retornar la figura actualizada

# Ejecutar el servidor local
if __name__ == '__main__':
    app.run(debug=True)  # Activar recarga automática