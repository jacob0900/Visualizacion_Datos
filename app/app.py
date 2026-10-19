import streamlit as st
import matplotlib.pyplot as plt
import numpy as np

num_points = st.sidebar.slider("Number of points", 100, 1000, 500)

data =np.random.rand(num_points)

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(10, 5))

ax1.boxplot(data)
ax1.set_title("diagrama de cajas y bigotes")
ax1.set_ylabel("Valores")

ax2.hist(data, bins=20, edgecolor='black')
ax2.set_title("histograma")
ax2.set_xlabel("Valores")
ax2.set_ylabel("Frecuencia")

plt.tight_layout()  
st.pyplot(fig)


