#!/usr/bin/env python3
# DevForge - Exemplo de Treinamento com TensorFlow

import tensorflow as tf
from tensorflow import keras
import numpy as np

print(f"TensorFlow version: {tf.__version__}")
print(f"GPU Available: {tf.config.list_physical_devices('GPU')}")

# Carregar dataset MNIST
(x_train, y_train), (x_test, y_test) = keras.datasets.mnist.load_data()
x_train, x_test = x_train / 255.0, x_test / 255.0

# Criar modelo
model = keras.Sequential([
    keras.layers.Flatten(input_shape=(28, 28)),
    keras.layers.Dense(128, activation='relu'),
    keras.layers.Dropout(0.2),
    keras.layers.Dense(10, activation='softmax')
])

# Compilar
model.compile(optimizer='adam',
              loss='sparse_categorical_crossentropy',
              metrics=['accuracy'])

# Treinar
model.fit(x_train, y_train, epochs=5, validation_data=(x_test, y_test))

# Avaliar
test_loss, test_acc = model.evaluate(x_test, y_test, verbose=2)
print(f'\nTest accuracy: {test_acc:.4f}')

# Salvar modelo
model.save('mnist_model.h5')
print("Modelo salvo como mnist_model.h5")