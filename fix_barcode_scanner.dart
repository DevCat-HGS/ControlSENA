// Script para solucionar el problema de compatibilidad en flutter_barcode_scanner

import 'dart:io';
import 'dart:async';

Future<void> main() async {
  // Ruta al archivo Java del plugin que tiene problemas
  final String pluginJavaPath = 'C:\\Users\\ADMIN\\AppData\\Local\\Pub\\Cache\\hosted\\pub.dev\\flutter_barcode_scanner-2.0.0\\android\\src\\main\\java\\com\\amolg\\flutterbarcodescanner\\FlutterBarcodeScannerPlugin.java';
  
  try {
    // Verificar si el archivo existe
    final File pluginFile = File(pluginJavaPath);
    if (await pluginFile.exists()) {
      print('📝 Actualizando el archivo FlutterBarcodeScannerPlugin.java...');
      
      // Crear el contenido actualizado del plugin que usa la nueva API de Flutter
      final String updatedContent = '''
// Updated FlutterBarcodeScannerPlugin.java
package com.amolg.flutterbarcodescanner;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.util.Log;

import androidx.annotation.NonNull;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry;
import io.flutter.plugin.common.PluginRegistry.ActivityResultListener;

public class FlutterBarcodeScannerPlugin implements FlutterPlugin, ActivityAware, MethodCallHandler, ActivityResultListener {
    private static final String CHANNEL = "flutter_barcode_scanner";
    private static final int REQUEST_CODE_SCAN_ACTIVITY = 100;
    private static final String TAG = FlutterBarcodeScannerPlugin.class.getSimpleName();

    private Activity activity;
    private MethodChannel channel;
    private Result pendingResult;
    private boolean isShowFlashIcon;
    private String lineColor;
    private String cancelButtonText;
    private boolean isShowCameraOnly;
    private BinaryMessenger messenger;

    // Constructor for v2 embedding
    public FlutterBarcodeScannerPlugin() {
    }

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
        this.messenger = binding.getBinaryMessenger();
        channel = new MethodChannel(messenger, CHANNEL);
        channel.setMethodCallHandler(this);
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        channel.setMethodCallHandler(null);
        channel = null;
        messenger = null;
    }

    @Override
    public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
        this.activity = binding.getActivity();
        binding.addActivityResultListener(this);
    }

    @Override
    public void onDetachedFromActivityForConfigChanges() {
        this.activity = null;
    }

    @Override
    public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {
        this.activity = binding.getActivity();
        binding.addActivityResultListener(this);
    }

    @Override
    public void onDetachedFromActivity() {
        this.activity = null;
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
        if (call.method.equals("scanBarcode")) {
            if (pendingResult != null) {
                result.error("ALREADY_ACTIVE", "Barcode scanner is already active", null);
                return;
            }
            pendingResult = result;

            lineColor = call.argument("lineColor");
            cancelButtonText = call.argument("cancelButtonText");
            isShowFlashIcon = call.argument("isShowFlashIcon");
            isShowCameraOnly = call.argument("isShowCameraOnly");

            showBarcodeView();
        } else {
            result.notImplemented();
        }
    }

    private void showBarcodeView() {
        Intent intent = new Intent(activity, BarcodeCaptureActivity.class);
        intent.putExtra(BarcodeCaptureActivity.AutoFocus, true);
        intent.putExtra(BarcodeCaptureActivity.UseFlash, false);
        intent.putExtra("lineColor", lineColor);
        intent.putExtra("cancelButtonText", cancelButtonText);
        intent.putExtra("isShowFlashIcon", isShowFlashIcon);
        intent.putExtra("isShowCameraOnly", isShowCameraOnly);

        activity.startActivityForResult(intent, REQUEST_CODE_SCAN_ACTIVITY);
    }

    @Override
    public boolean onActivityResult(int requestCode, int resultCode, Intent data) {
        if (requestCode == REQUEST_CODE_SCAN_ACTIVITY) {
            if (resultCode == Activity.RESULT_OK) {
                String barcode = data.getStringExtra(BarcodeCaptureActivity.BarcodeObject);
                pendingResult.success(barcode);
            } else if (resultCode == Activity.RESULT_CANCELED) {
                pendingResult.success("-1");
            } else {
                pendingResult.error("SCAN_ERROR", "Error scanning barcode", null);
            }
            pendingResult = null;
            return true;
        }
        return false;
    }
}
''';
      
      // Guardar el archivo actualizado
      await pluginFile.writeAsString(updatedContent);
      print('✅ Archivo FlutterBarcodeScannerPlugin.java actualizado correctamente');
      print('\n🔍 El archivo ha sido actualizado para usar la nueva API de Flutter Plugin');
      print('\n📋 Instrucciones adicionales:');
      print('1. Ejecuta "flutter clean" para limpiar la caché de compilación');
      print('2. Ejecuta "flutter pub get" para actualizar las dependencias');
      print('3. Intenta ejecutar la aplicación nuevamente con "flutter run"');
      print('\n💡 Alternativas si el problema persiste:');
      print('- Considera usar un paquete alternativo como mobile_scanner o qr_code_scanner');
      print('- O actualiza tu pubspec.yaml para usar una versión más reciente del plugin:');
      print('  flutter_barcode_scanner:');
      print('    git:');
      print('      url: https://github.com/AmolGangadhare/flutter_barcode_scanner');
      print('      ref: master');
    } else {
      print('❌ No se pudo encontrar el archivo del plugin en la ruta especificada');
      print('Verifique la ruta: $pluginJavaPath');
      print('\n💡 Alternativas:');
      print('1. Considera usar un paquete alternativo como mobile_scanner o qr_code_scanner');
      print('2. Actualiza tu pubspec.yaml para usar una versión más reciente del plugin:');
      print('   flutter_barcode_scanner:');
      print('     git:');
      print('       url: https://github.com/AmolGangadhare/flutter_barcode_scanner');
      print('       ref: master');
    }
  } catch (e) {
    print('❌ Error al modificar el archivo del plugin: $e');
    print('\n💡 Alternativas:');
    print('1. Considera usar un paquete alternativo como mobile_scanner o qr_code_scanner');
    print('2. Actualiza tu pubspec.yaml para usar una versión más reciente del plugin');
  }
}