# --- Archivo: ui.R  ---

library(shinydashboard)

# Define la UI (Interfaz de Usuario)
ui <- dashboardPage(
  skin = "purple",
  # 1. Cabecera del Dashboard
  dashboardHeader(
    title = tagList(
      # Usamos tags$img para añadir la imagen del logo
      tags$img(src = 'my_logo.png', height = '45', style = "padding-right:10px;"),
      # Título de la App como texto simple
      "Análisis de enfermedades cardíacas"
    ),
    titleWidth = 450
  ),
  # 2. Barra Lateral de Navegación
  dashboardSidebar(
    width = 450,
    sidebarMenu(
      menuItem("Análisis Exploratorio", tabName = "eda", icon = icon("chart-bar")),
      menuItem("Entrenamiento del Modelo", tabName = "entrenamiento", icon = icon("gears")),
      menuItem("Predicciones", tabName = "predicciones", icon = icon("laptop"))
    )
  ),
  # 3. Cuerpo del Dashboard
  dashboardBody(
    
    # --- CSS para centrar el contenido de las valueBox ---
    tags$head(
      tags$style(HTML("
        .small-box .inner {
          text-align: center;
        }
        .small-box h3, .small-box p {
          text-align: center;
        }
      "))
    ),
    
    tabItems(
      # Contenido de la Pestaña 1: Análisis Exploratorio
      tabItem(tabName = "eda",
              h2("Análisis Exploratorio de Datos"),
              # Fila de Cajas con Métricas (Value Boxes)
              fluidRow(box(width = 12,
                           title = "Resumen del Dataset",
                           status = "primary",
                           solidHeader = TRUE,
                           collapsible = TRUE,
                           fluidRow(
                             column(3, valueBox(nrow(df), "Observaciones", width = 12, color="navy")),
                             column(3, valueBox(ncol(df), "Variables", width = 12, color="navy")),
                             column(3, valueBox(paste0(round(sum(df$EnfermedadCorazon == "Sí") / nrow(df) * 100), "%"), "% con Enfermedad", width = 12, color="navy")),
                             column(3, valueBox(sum(is.na(df)), "Valores Faltantes", width = 12, color="navy"))
                           )
              )
              ),
              fluidRow(
                # Caja de Controles
                box(title = "Configuración de Gráficos", 
                    status = "primary", 
                    solidHeader = TRUE, 
                    width = 4,
                    selectInput("variable", "Selecciona una variable:",
                                choices = c("Edad" = "Age",
                                            "Sexo" = "Sex",
                                            "Tipo de Dolor de Pecho" = "ChestPainType",
                                            "Nivel de Colesterol" = "Cholesterol",
                                            "Frecuencia Cardíaca Máxima" = "MaxHR")
                    ),
                    selectInput("plot_type",
                                "Selecciona el tipo de gráfico:",
                                choices = c("Histograma / Gráfico de Barras",
                                            "Gráfico de Cajas (Box Plot)"),
                                selected = "Histograma / Gráfico de Barras"
                    ),
                    sliderInput("rango_edad", "Filtra por Rango de Edad:",
                                min = min(df$Age), max = max(df$Age), 
                                value = c(min(df$Age), max(df$Age)))
                ),
                
                # Caja para el Gráfico
                box(title = "Gráfico Interactivo", 
                    status = "success", 
                    solidHeader = TRUE, 
                    width = 8,
                    # Usamos plotlyOutput para un gráfico interactivo
                    plotlyOutput("distPlot"))
              ),
              # Fila para la Tabla de Datos
              fluidRow(box(
                title = "Tabla de Datos", status = "info", solidHeader = TRUE, width = 12,
                DT::dataTableOutput("tablaDatos")
              )
              )
              
      ),
      
      # Contenido de la Pestaña 2: Entrenamiento
      tabItem(tabName = "entrenamiento",
              h2("Entrenamiento de un Modelo Predictivo"),
              # Contenido de la Pestaña 2: Entrenamiento
              tabItem(tabName = "entrenamiento",
                      h2("Entrenamiento de un Modelo Predictivo"),
                      fluidRow(
                        # Caja de control
                        box(
                          title = "Control de Entrenamiento", status = "primary", solidHeader = TRUE, width = 4,
                          selectInput("modelo_seleccionado", "Selecciona un Modelo:",
                                      choices = c(
                                        "Regresión Logística" = "glm",
                                        "Bosque Aleatorio (Random Forest)" = "rf"
                                      )),
                          sliderInput("train_split_percentage",
                                      "Porcentaje de Datos para Entrenamiento:",
                                      min = 50, max = 90, value = 80, step = 5, post = "%"),
                          
                          actionButton("entrenarModelo", "Entrenar Modelo", class = "btn-success", icon = icon("play")),
                          helpText("Presiona el botón para entrenar el modelo seleccionado y ver sus métricas de rendimiento.")
                        ),
                        # Caja de resultados
                        box(
                          title = "Resultados del Modelo", status = "info", solidHeader = TRUE, width = 8, collapsible = TRUE,
                          
                          # Fila para las métricas de texto
                          fluidRow(
                            column(width = 12,
                                   h4("Métricas Principales"),
                                   verbatimTextOutput("metricas_modelo")
                            )
                          ),
                          
                          # Fila para los gráficos, uno al lado del otro
                          fluidRow(
                            column(width = 6,
                                   h4("Matriz de Confusión"),
                                   plotlyOutput("heatmap_confusion")
                            ),
                            column(width = 6,
                                   h4("Curva ROC"),
                                   plotlyOutput("curva_roc")
                            )
                          )
                        )
                      )
              ),
      ),
      
      
      # Contenido de la Pestaña 3: Predicciones
      # Contenido de la Pestaña 3: Predicciones
      tabItem(tabName = "predicciones",
              h2("Realizar una Predicción"),
              fluidRow(
                # Caja de Atributos
                box(
                  title = "Ingresa los datos del paciente:", status = "primary", solidHeader = TRUE, width = 4,
                  
                  h4("Cargar Pacientes de Ejemplo:"),
                  fluidRow(
                    column(6, actionButton("cargar_paciente_riesgo", "Alto Riesgo", class = "btn-danger", width = '100%')),
                    column(6, actionButton("cargar_paciente_normal", "Bajo Riesgo", class = "btn-success", width = '100%'))
                  ),
                  hr(), # Separador visual
                  
                  # Inputs para los datos del paciente (sin cambios)
                  sliderInput("pred_Age", "Edad:", min = 28, max = 77, value = 50),
                  selectInput("pred_Sex", "Sexo:", choices = c("M", "F")),
                  selectInput("pred_ChestPainType", "Tipo de Dolor de Pecho:", choices = c("ASY", "ATA", "NAP", "TA")),
                  sliderInput("pred_RestingBP", "Presión Arterial en Reposo (mm Hg):", min = 80, max = 200, value = 120),
                  sliderInput("pred_Cholesterol", "Colesterol (mm/dl):", min = 0, max = 603, value = 200),
                  selectInput("pred_FastingBS", "Azúcar en Sangre en Ayunas (> 120 mg/dl):", choices = c("0", "1")),
                  selectInput("pred_RestingECG", "Resultados de Electrocardiograma:", choices = c("Normal", "ST", "LVH")),
                  sliderInput("pred_MaxHR", "Frecuencia Cardíaca Máxima:", min = 60, max = 202, value = 150),
                  selectInput("pred_ExerciseAngina", "Angina Inducida por Ejercicio:", choices = c("Y", "N")),
                  sliderInput("pred_Oldpeak", "Oldpeak (Depresión del ST):", min = -2.6, max = 6.2, value = 1),
                  selectInput("pred_ST_Slope", "Pendiente del Segmento ST:", choices = c("Up", "Flat", "Down")),
                  
                  actionButton("predecir", "Predecir", class = "btn-primary btn-lg", icon = icon("chart-line"), width = '100%')
                ),
                
                # Caja de Resultados
                box(
                  title = "Resultado de la Predicción", status = "success", solidHeader = TRUE, width = 8,
                  
                  # Salida para el infoBox dinámico
                  uiOutput("resultado_pred_box"),
                  
                  hr(), # Separador visual
                  
                  # Salida para el gráfico de contexto
                  h4("Contexto de los Datos Ingresados"),
                  plotlyOutput("contexto_plot")
                )
              )
      )
    )
  )
  
  
)