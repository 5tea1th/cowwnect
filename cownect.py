if __name__ == '__main__':
    import tensorflow as tf
    from tensorflow.keras import layers, models
    from tensorflow.keras.preprocessing.image import ImageDataGenerator
    from tensorflow.keras.callbacks import EarlyStopping, ReduceLROnPlateau, LearningRateScheduler
    import numpy as np
    import os
    import matplotlib.pyplot as plt

    # Constants
    IMG_HEIGHT = 224
    IMG_WIDTH = 224
    BATCH_SIZE = 32
    DATA_PATH = 'D:/final/'
    EXPORT_PATH = 'D:/model/'

    def scheduler(epoch, lr):
        if epoch < 5:
            return 0.001 * (epoch + 1) / 5  # Warmup
        else:
            return 0.001 * tf.math.exp(-0.1 * (epoch - 5))

    # Enhanced data augmentation
    train_datagen = ImageDataGenerator(
        rescale=1./255,
        validation_split=0.2,
        rotation_range=30,
        width_shift_range=0.3,
        height_shift_range=0.3,
        zoom_range=0.3,
        horizontal_flip=True,
        brightness_range=[0.7, 1.3],
        fill_mode='nearest',
        preprocessing_function=tf.keras.applications.efficientnet.preprocess_input
    )

    val_datagen = ImageDataGenerator(
        rescale=1./255,
        validation_split=0.2,
        preprocessing_function=tf.keras.applications.efficientnet.preprocess_input
    )

    train_generator = train_datagen.flow_from_directory(
        DATA_PATH,
        target_size=(IMG_HEIGHT, IMG_WIDTH),
        batch_size=BATCH_SIZE,
        class_mode='categorical',
        subset='training',
        shuffle=True,
        classes=['Gir_cow', 'Sahiwal_cow']
    )

    val_generator = val_datagen.flow_from_directory(
        DATA_PATH,
        target_size=(IMG_HEIGHT, IMG_WIDTH),
        batch_size=BATCH_SIZE,
        class_mode='categorical',
        subset='validation',
        shuffle=False,
        classes=['Gir_cow', 'Sahiwal_cow']
    )

    class_counts = {'Gir_cow': 267, 'Sahiwal_cow': 248}
    total = sum(class_counts.values())
    class_weights = {i: total / (2 * class_counts[label]) for i, label in enumerate(class_counts.keys())}
    print("Class Weights:", class_weights)

    base_model = tf.keras.applications.EfficientNetB3(
        weights='imagenet',
        include_top=False,
        input_shape=(IMG_HEIGHT, IMG_WIDTH, 3)
    )
    base_model.trainable = False

    model = models.Sequential([
        base_model,
        layers.GlobalAveragePooling2D(),
        layers.BatchNormalization(),
        layers.Dropout(0.4),
        layers.Dense(512, activation='relu'),  # Increased capacity
        layers.BatchNormalization(),
        layers.Dropout(0.4),
        layers.Dense(2, activation='softmax')
    ])

    model.compile(
        optimizer=tf.keras.optimizers.Adam(learning_rate=0.0001),
        loss='categorical_crossentropy',
        metrics=['accuracy']
    )

    early_stopping = EarlyStopping(monitor='val_accuracy', patience=8, restore_best_weights=True, mode='max')
    reduce_lr = ReduceLROnPlateau(monitor='val_loss', factor=0.5, patience=4, min_lr=1e-6)
    lr_scheduler = LearningRateScheduler(scheduler)

    # Stage 1
    print("Stage 1: Training top layers...")
    history_stage1 = model.fit(
        train_generator,
        epochs=30,  # Increased from 25
        validation_data=val_generator,
        class_weight=class_weights,
        callbacks=[early_stopping, reduce_lr, lr_scheduler]
    )

    # Stage 2
    print("Stage 2: Fine-tuning...")
    base_model.trainable = True
    for layer in base_model.layers[:-20]:  # Unfreeze more layers
        layer.trainable = False

    model.compile(
        optimizer=tf.keras.optimizers.Adam(learning_rate=1e-5),  # Lower LR for fine-tuning
        loss='categorical_crossentropy',
        metrics=['accuracy']
    )

    history_stage2 = model.fit(
        train_generator,
        epochs=40,
        validation_data=val_generator,
        class_weight=class_weights,
        callbacks=[early_stopping, reduce_lr, lr_scheduler]
    )

    loss, accuracy = model.evaluate(val_generator)
    print(f"Final Test accuracy: {accuracy:.4f}")

    # Export TFLite
    converter = tf.lite.TFLiteConverter.from_keras_model(model)
    converter.optimizations = [tf.lite.Optimize.DEFAULT]
    tflite_model = converter.convert()

    os.makedirs(EXPORT_PATH, exist_ok=True)
    with open(os.path.join(EXPORT_PATH, 'cow_breed_model.tflite'), 'wb') as f:
        f.write(tflite_model)

    model.save(os.path.join(EXPORT_PATH, 'cow_breed_model.h5'))

    # Plot
    plt.plot(history_stage1.history['accuracy'] + history_stage2.history['accuracy'], label='Train Accuracy')
    plt.plot(history_stage1.history['val_accuracy'] + history_stage2.history['val_accuracy'], label='Val Accuracy')
    plt.xlabel('Epoch')
    plt.ylabel('Accuracy')
    plt.legend()
    plt.grid(True)
    plt.tight_layout()
    plt.show()