import pandas as pd

df = pd.read_csv("https://raw.githubusercontent.com/cdeoroaguado/Datos/refs/heads/main/datadescrip/data_banco_creditos.csv")
df.head()

from sklearn.linear_model import LinearRegression
from sklearn.model_selection import train_test_split

# Seleccionar variable independiente (X) y dependiente (y)
X = df[['tiempo_analisis_min']]        # Variable predictora
y = df['monto_credito_millones']       # Variable objetivo

# Dividir datos en entrenamiento (80%) y prueba (20%)
X_train, X_test, y_train, y_test = train_test_split(
    X, y, test_size=0.2, random_state=42
)

# Crear el modelo de regresión lineal
modelo_credito = LinearRegression()

# Entrenar el modelo con los datos de entrenamiento
modelo_credito.fit(X_train, y_train)

import joblib

joblib.dump(modelo_credito, "modelo_credito.pkl")

import joblib

# Cargar el modelo desde el archivo para usarlo más tarde
modelo_cargado = joblib.load("modelo_credito.pkl")

# Realizar una predicción con el modelo cargado
tiempo_nuevo = pd.DataFrame({'tiempo_analisis_min': [45]}) # Ejemplo: 45 minutos de análisis
prediccion = modelo_cargado.predict(tiempo_nuevo)

# Mostrar el resultado de la predicción
print(f"Predicción del monto de crédito: {prediccion[0]:.2f} millones")