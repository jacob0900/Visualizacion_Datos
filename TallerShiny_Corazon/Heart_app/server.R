# --- Archivo: server.R ---

# Define el servidor (lógica del back-end)
server <- function(input, output, session) {
  
  
  # --- Pestaña 1: Lógica del Análisis Exploratorio ---
  
  # 1. Creamos un set de datos reactivo que se filtra por el rango de edad
  datos_filtrados <- reactive({
    df %>%
      filter(Age >= input$rango_edad[1] & Age <= input$rango_edad[2])
  })
  
  # 2. Creamos el gráfico de distribución
  output$distPlot <- renderPlotly({
    variable_seleccionada <- input$variable
    
    # Lógica para seleccionar el tipo de gráfico
    if (input$plot_type == "Histograma / Gráfico de Barras") {
      
      # Si la variable es categórica (factor), crea un gráfico de barras
      if (is.factor(datos_filtrados()[[variable_seleccionada]])) {
        p <- datos_filtrados() %>%
          ggplot(aes(x = .data[[variable_seleccionada]], fill = EnfermedadCorazon)) +
          geom_bar(position = "fill") +
          labs(y = "Proporción", title = paste("Proporción de Enfermedad Cardíaca por", variable_seleccionada)) +
          theme_minimal()
      } else {
        # Si es numérica, crea un histograma
        p <- datos_filtrados() %>%
          ggplot(aes(x = .data[[variable_seleccionada]], fill = EnfermedadCorazon)) +
          geom_histogram(binwidth = 5, alpha = 0.7, position = "identity") +
          labs(title = paste("Distribución de", variable_seleccionada)) +
          theme_minimal()
      }
      
    } else { # Lógica para el "Gráfico de Cajas (Box Plot)"
      
      # Si la variable es categórica, muestra la distribución de Edad para cada categoría
      if (is.factor(datos_filtrados()[[variable_seleccionada]])) {
        p <- datos_filtrados() %>%
          ggplot(aes(x = .data[[variable_seleccionada]], y = Age, fill = .data[[variable_seleccionada]])) +
          geom_boxplot(show.legend = FALSE) +
          labs(title = paste("Distribución de Edad por", variable_seleccionada)) +
          theme_minimal() +
          theme(axis.text.x = element_text(angle = 45, hjust = 1))
        
      } else {
        # Si la variable es numérica, muestra su distribución general
        p <- datos_filtrados() %>%
          ggplot(aes(x = EnfermedadCorazon, y = .data[[variable_seleccionada]], fill = EnfermedadCorazon)) +
          geom_boxplot(show.legend = FALSE) +
          labs(title = paste("Distribución de", variable_seleccionada, "por Diagnóstico")) +
          theme_minimal()
      }
    }
    
    # Convierte el gráfico ggplot a plotly para hacerlo interactivo
    ggplotly(p)
  })
  
  # 3. Creamos la tabla de datos
  output$tablaDatos <- DT::renderDataTable({
    datos_filtrados() %>%
      select(Age, Sex, ChestPainType, Cholesterol, EnfermedadCorazon)
  }, options = list(pageLength = 10))
  
  # --- Pestaña 2: Lógica de Entrenamiento del Modelo ---
  
  # Usamos reactiveValues para almacenar el modelo entrenado y usarlo en la otra pestaña
  valores_reactivos <- reactiveValues(modelo = NULL)
  
  # Almacena el modelo entrenado en valores_reactivos al presionar el botón
  observeEvent(input$entrenarModelo, {
    withProgress(message = 'Entrenando modelo...', detail = 'Esto puede tomar un momento...', {
      
      # 1. Preparación de datos
      set.seed(42)
      particion <- createDataPartition(df$EnfermedadCorazon, 
                                       p = input$train_split_percentage / 100, # Usa el input del slider
                                       list = FALSE)
      datos_entrenamiento <- df[particion, ]
      datos_prueba <- df[-particion, ]
      
      # 2. Entrenamiento del modelo seleccionado por el usuario
      modelo <- train(EnfermedadCorazon ~ ., 
                      data = datos_entrenamiento, 
                      method = input$modelo_seleccionado, # Usa el input del usuario
                      family = "binomial",
                      trControl = trainControl(method = "cv", number = 5, classProbs = TRUE, summaryFunction = twoClassSummary),
                      metric = "ROC")
      
      # Almacena el modelo para la pestaña de predicciones
      valores_reactivos$modelo <- modelo
      
      # 3. Generación de predicciones y matriz de confusión
      predicciones_clase <- predict(modelo, newdata = datos_prueba)
      matriz_confusion <- confusionMatrix(predicciones_clase, datos_prueba$EnfermedadCorazon, positive = "Sí")
      
      # --- Creación de las salidas ---
      
      # Salida 1: Métricas principales en texto
      output$metricas_modelo <- renderPrint({
        cat("Métricas Generales:\n")
        print(matriz_confusion$overall[c("Accuracy", "Kappa")])
        cat("\nMétricas por Clase (Clase Positiva: 'Sí'):\n")
        print(matriz_confusion$byClass[c("Sensitivity", "Specificity", "Precision", "Recall", "F1")])
      })
      
      # Salida 2: Heatmap interactivo para la Matriz de Confusión
      output$heatmap_confusion <- renderPlotly({
        matriz <- as.data.frame(matriz_confusion$table)
        
        p <- ggplot(matriz, aes(x = Prediction, y = Reference, fill = Freq)) +
          geom_tile() +
          geom_text(aes(label = Freq), color = "white", size = 6) +
          scale_fill_gradient(low = "#5DADE2", high = "#1B4F72") +
          labs(title = "Matriz de Confusión",
               x = "Clase Predicha",
               y = "Clase Real") +
          theme_minimal() +
          theme(legend.position = "none")
        
        ggplotly(p)
      })
      
      # Salida 3: Curva ROC interactiva
      output$curva_roc <- renderPlotly({
        predicciones_prob <- predict(modelo, newdata = datos_prueba, type = "prob")
        
        # Calcular la curva ROC
        roc_obj <- roc(response = datos_prueba$EnfermedadCorazon, 
                       predictor = predicciones_prob$Sí,
                       levels = c("No", "Sí"))
        
        # Graficar la curva ROC
        p <- ggroc(roc_obj, legacy.axes = TRUE) +
          geom_segment(aes(x = 0, xend = 1, y = 0, yend = 1), color = "grey", linetype = "dashed") +
          labs(title = paste("Curva ROC (AUC =", round(auc(roc_obj), 3), ")"),
               x = "Tasa de Falsos Positivos (1 - Especificidad)",
               y = "Tasa de Verdaderos Positivos (Sensibilidad)") +
          theme_minimal()
        
        ggplotly(p)
      })
      
    }) # Fin de withProgress
  }) # Fin de observeEvent
  
  # --- Pestaña 3: Predicciones ---
  
  observeEvent(input$cargar_paciente_riesgo, {
    # Paciente de ejemplo con enfermedad (fila 916 del dataset)
    paciente <- df[916, ]
    updateSliderInput(session, "pred_Age", value = paciente$Age)
    updateSelectInput(session, "pred_Sex", selected = paciente$Sex)
    updateSelectInput(session, "pred_ChestPainType", selected = paciente$ChestPainType)
    updateSliderInput(session, "pred_RestingBP", value = paciente$RestingBP)
    updateSliderInput(session, "pred_Cholesterol", value = paciente$Cholesterol)
    updateSelectInput(session, "pred_FastingBS", selected = paciente$FastingBS)
    updateSelectInput(session, "pred_RestingECG", selected = paciente$RestingECG)
    updateSliderInput(session, "pred_MaxHR", value = paciente$MaxHR)
    updateSelectInput(session, "pred_ExerciseAngina", selected = paciente$ExerciseAngina)
    updateSliderInput(session, "pred_Oldpeak", value = paciente$Oldpeak)
    updateSelectInput(session, "pred_ST_Slope", selected = paciente$ST_Slope)
  })
  
  # Lógica para cargar paciente de BAJO RIESGO de ejemplo
  observeEvent(input$cargar_paciente_normal, {
    # Paciente de ejemplo sin enfermedad (fila 1 del dataset)
    paciente <- df[1, ]
    updateSliderInput(session, "pred_Age", value = paciente$Age)
    updateSelectInput(session, "pred_Sex", selected = paciente$Sex)
    updateSelectInput(session, "pred_ChestPainType", selected = paciente$ChestPainType)
    updateSliderInput(session, "pred_RestingBP", value = paciente$RestingBP)
    updateSliderInput(session, "pred_Cholesterol", value = paciente$Cholesterol)
    updateSelectInput(session, "pred_FastingBS", selected = paciente$FastingBS)
    updateSelectInput(session, "pred_RestingECG", selected = paciente$RestingECG)
    updateSliderInput(session, "pred_MaxHR", value = paciente$MaxHR)
    updateSelectInput(session, "pred_ExerciseAngina", selected = paciente$ExerciseAngina)
    updateSliderInput(session, "pred_Oldpeak", value = paciente$Oldpeak)
    updateSelectInput(session, "pred_ST_Slope", selected = paciente$ST_Slope)
  })
  
  # Reactivo que se activa al presionar el botón "Predecir" (lógica interna sin cambios)
  prediccion_hecha <- eventReactive(input$predecir, {
    req(valores_reactivos$modelo)
    
    datos_nuevos <- data.frame(
      Age = as.numeric(input$pred_Age), Sex = factor(input$pred_Sex, levels = levels(df$Sex)),
      ChestPainType = factor(input$pred_ChestPainType, levels = levels(df$ChestPainType)),
      RestingBP = as.numeric(input$pred_RestingBP), Cholesterol = as.numeric(input$pred_Cholesterol),
      FastingBS = factor(input$pred_FastingBS, levels = levels(df$FastingBS)),
      RestingECG = factor(input$pred_RestingECG, levels = levels(df$RestingECG)),
      MaxHR = as.numeric(input$pred_MaxHR),
      ExerciseAngina = factor(input$pred_ExerciseAngina, levels = levels(df$ExerciseAngina)),
      Oldpeak = as.numeric(input$pred_Oldpeak),
      ST_Slope = factor(input$pred_ST_Slope, levels = levels(df$ST_Slope))
    )
    
    prediccion <- predict(valores_reactivos$modelo, newdata = datos_nuevos, type = "raw")
    probabilidad <- predict(valores_reactivos$modelo, newdata = datos_nuevos, type = "prob")
    
    # Devuelve una lista con la predicción, probabilidad y los datos ingresados
    list(pred = prediccion, prob = probabilidad, datos = datos_nuevos)
  })
  
  # Salida para el infoBox dinámico
  output$resultado_pred_box <- renderUI({
    # Requiere que se haya hecho una predicción
    req(prediccion_hecha())
    res <- prediccion_hecha()
    
    prob_si <- round(res$prob$'Sí' * 100, 1)
    
    if (res$pred == "Sí") {
      infoBox(
        title = "Resultado: Alto Riesgo",
        value = paste0(prob_si, "% de probabilidad de enfermedad"),
        icon = icon("triangle-exclamation"),
        color = "red",
        width = 12,
        fill = TRUE
      )
    } else {
      infoBox(
        title = "Resultado: Bajo Riesgo",
        value = paste0(prob_si, "% de probabilidad de enfermedad"),
        icon = icon("check-circle"),
        color = "green",
        width = 12,
        fill = TRUE
      )
    }
  })
  
  # Salida para el gráfico de contexto
  output$contexto_plot <- renderPlotly({
    req(prediccion_hecha())
    res <- prediccion_hecha()
    
    # Variables numéricas clave para comparar
    vars_numericas <- c("Age", "RestingBP", "Cholesterol", "MaxHR")
    
    # Calcular promedios
    promedios <- df %>%
      select(all_of(vars_numericas), EnfermedadCorazon) %>%
      group_by(EnfermedadCorazon) %>%
      summarise(across(everything(), mean)) %>%
      pivot_longer(-EnfermedadCorazon, names_to = "Variable", values_to = "Valor")
    
    # Datos del paciente ingresado
    datos_paciente <- res$datos %>%
      select(all_of(vars_numericas)) %>%
      pivot_longer(everything(), names_to = "Variable", values_to = "Valor") %>%
      mutate(EnfermedadCorazon = "Paciente Actual")
    
    # Combinar datos
    datos_plot <- bind_rows(promedios, datos_paciente)
    
    # Crear gráfico
    p <- ggplot(datos_plot, aes(x = Variable, y = Valor, fill = EnfermedadCorazon)) +
      geom_col(position = "dodge") +
      scale_fill_manual(values = c("Sí" = "#E74C3C", "No" = "#2ECC71", "Paciente Actual" = "#3498DB")) +
      labs(title = "Comparación con Valores Promedio", y = "Valor", x = "", fill = "Grupo") +
      theme_minimal() +
      coord_flip() # Girar coordenadas para mejor lectura
    
    ggplotly(p)
  })
  
}