#!/bin/bash

# Script para generar APK de la demo
# Uso: ./build_demo_apk.sh

echo "🚀 Generando APK de Legal Assistant Demo..."
echo ""

# Verificar que estamos en el directorio correcto
if [ ! -f "pubspec.yaml" ]; then
    echo "❌ Error: Este script debe ejecutarse desde la raíz del proyecto Flutter"
    exit 1
fi

# Limpiar build anterior
echo "🧹 Limpiando compilaciones anteriores..."
flutter clean

# Obtener dependencias
echo "📦 Obteniendo dependencias..."
flutter pub get

# Generar APK
echo "🔨 Compilando APK release..."
flutter build apk --release

# Verificar si se generó correctamente
if [ -f "build/app/outputs/flutter-apk/app-release.apk" ]; then
    echo ""
    echo "✅ APK generado exitosamente!"
    echo ""
    echo "📍 Ubicación: build/app/outputs/flutter-apk/app-release.apk"
    
    # Mostrar tamaño del APK
    APK_SIZE=$(du -h "build/app/outputs/flutter-apk/app-release.apk" | cut -f1)
    echo "📏 Tamaño: $APK_SIZE"
    
    echo ""
    echo "💡 Para generar APKs más pequeños por arquitectura, usa:"
    echo "   flutter build apk --split-per-abi --release"
    echo ""
    echo "✅ Listo para compartir con entrevistadores!"
else
    echo ""
    echo "❌ Error: No se pudo generar el APK"
    echo "Revisa los errores anteriores"
    exit 1
fi
