# Keep TensorFlow Lite GPU delegate
-keep class org.tensorflow.** { *; }
-dontwarn org.tensorflow.**
# Keep Gemini AI classes
-keep class com.google.ai.** { *; }
-keep class com.google.api.** { *; }
-keep class com.google.protobuf.** { *; }
-dontwarn com.google.ai.**
-dontwarn com.google.api.**
-dontwarn com.google.protobuf.**