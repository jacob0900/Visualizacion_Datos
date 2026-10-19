# Visualización de Datos

Códigos, talleres y proyectos del curso de **Visualización de Datos**, en **Python** y **R**: manipulación y exploración de datos, visualización estática e interactiva, mapas de Colombia, series de tiempo y aplicaciones web con Streamlit, Dash y Shiny.

## Contenido

### Notebooks del curso (Python)

| Archivo | Contenido |
|---|---|
| `modulo_1_sin_codigo.ipynb` | Fundamentos de Python: sentencias, operadores, estructuras condicionales y repetitivas, funciones y estructuras de datos básicas |
| `modulo_2_sin_codigo.ipynb` | Manipulación de datos con **pandas**: nuevas columnas, índices, resúmenes estadísticos univariados y bivariados, histogramas y densidades con Matplotlib y Seaborn, y reportes con `ydata-profiling` |
| `modulo_3.ipynb` | Visualización interactiva: tratamiento de datos faltantes y atípicos, y gráficos con **Plotly**, **Bokeh** y **Altair** |
| `modulo_3_sin_codigo - Copy.ipynb` | Versión de práctica del módulo 3 |
| `st/st1.ipynb` | Introducción a las series de tiempo: ruido blanco y descomposición de series (`statsmodels`), con `Index2018.csv` y `airlines.csv` |

### Mapas de Colombia

| Archivo | Contenido |
|---|---|
| `MAPAS/CODIGO_MAPAS.ipynb` | Mapas coropléticos interactivos de los departamentos y de los municipios de un departamento, con **GeoPandas** y **Plotly** a partir de los límites oficiales del IGAC |
| `04-vizmap_sin_codigo.Rmd` | Visualización de datos geográficos en R con `ggmap`, `sf`, `tmap`, `leaflet` y `mapview` |

### Visualización y transformación de datos en R

| Archivo | Contenido |
|---|---|
| `FuncionesBasicas.Rmd` | Funciones básicas de `tidyverse`: carga de datos, filtros y selección |
| `ExtraccionTransformacion.Rmd` | Extracción y transformación con `dplyr`: filtrar, ordenar, `mutate`, agrupar y resumir |
| `03-vizestatico_sin_codigo.Rmd` | Visualización estática con `ggplot2`: histogramas, covariación, contenedores 2D y hexágonos, y matrices de correlación |
| `EDA_Visua.Rmd` | Análisis exploratorio de una serie de tiempo: importación desde Excel, limpieza de fechas y exploración inicial |
| `Tarea#1_Visualizacion.Rmd`, `Tarea#2_Visualizacion.Rmd`, `Tarea3_Visualizacion.Rmd` | Tareas del curso (la tarea 3 trabaja la transformación de datos de formato ancho a largo) |

Los archivos `.html` son las versiones renderizadas de los `.Rmd`.

### Aplicaciones web

| Carpeta | Contenido |
|---|---|
| `app/` | App de **Streamlit**: un control deslizante elige el número de puntos aleatorios y la app muestra su diagrama de cajas y su histograma |
| `app_dash/app_dash/` | Apps de **Dash**: gráfico interactivo de Gapminder con control deslizante por año (`app.py`) y predicción del monto de un crédito con regresión lineal (`dash_crediticio.py`). El modelo se entrena y guarda con `serialización.py`. Incluye un `Dockerfile` para contenerizar la app |
| `TallerShiny_Corazon/Heart_app/` | App de **Shiny** en R para predecir enfermedad cardíaca: análisis exploratorio interactivo, entrenamiento de un modelo a elegir (regresión logística o Random Forest, con `caret`, validación cruzada y curva ROC) y predicciones, con el dataset `heart.csv` |

## Cómo ejecutarlo

**Notebooks de Python:**

```bash
pip install numpy pandas matplotlib seaborn plotly bokeh altair scipy scikit-learn statsmodels ydata-profiling geopandas jupyter
jupyter notebook
```

**Mapas:** los shapefiles de límites del IGAC (*Líneas Limítrofes, diciembre 2025*: `Depto.shp` y `Munpio.shp`) no están en el repositorio por su tamaño. Descárgalos del [portal de datos abiertos del IGAC](https://www.colombiaenmapas.gov.co/) y actualiza la ruta del `.shp` en `CODIGO_MAPAS.ipynb`.

**Streamlit:**

```bash
pip install streamlit matplotlib numpy
streamlit run app/app.py
```

**Dash:**

```bash
cd app_dash/app_dash
pip install -r requirements.txt
python app.py
```

**Shiny:** abre `TallerShiny_Corazon/Heart_app/` en RStudio y pulsa **Run App**.

**R Markdown:** abre cada `.Rmd` en RStudio y pulsa **Knit**.

## Autor

- **Jacobo Londoño**, [LinkedIn](https://www.linkedin.com/in/jacobo-londo%C3%B1o-baquero-a2b86733a/)
