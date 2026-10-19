# --- Archivo: global.R ---

# Cargar las librerías necesarias
library(shiny)
library(tidyverse)
library(DT) # Para tablas interactivas
library(caret) # Para el entrenamiento del modelo
library(plotly) # Para gráficos interactivos
library(pROC) # Para la curva ROC
library(randomForest) # Requerido por caret para el método 'rf'

# Cargar y preparar los datos
df <- read.csv("heart.csv")

# Renombrar la variable de salida para mayor claridad
df <- df %>%
  rename(EnfermedadCorazon = HeartDisease)

# Convertir variables a tipo 'factor' para un mejor manejo
df <- df %>%
  mutate(
    Sex = as.factor(Sex),
    ChestPainType = as.factor(ChestPainType),
    FastingBS = as.factor(FastingBS),
    RestingECG = as.factor(RestingECG),
    ExerciseAngina = as.factor(ExerciseAngina),
    ST_Slope = as.factor(ST_Slope),
    EnfermedadCorazon = as.factor(EnfermedadCorazon)
  )

# Cambiar los niveles de la variable objetivo por etiquetas más claras
levels(df$EnfermedadCorazon) <- c("No", "Sí")

# Mensaje de confirmación en la consola
cat("Datos cargados y preprocesados en global.R\n")