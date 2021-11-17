package com.example.androidapp

import android.app.Application
import android.content.Context
import io.flutter.FlutterInjector
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.FlutterEngineCache
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.plugin.common.MethodChannel

const val FLUTTER_ENGINE_ID = "flutter_engine_id"
const val FLUTTER_METHOD_CHANNEL_ID = "flutter_method_channel_id"

class App : Application() {
    override fun onCreate() {
        super.onCreate()

        // prewarm flutter engine with app auth engine id
        prewarmFlutterEngine(applicationContext, FLUTTER_ENGINE_ID, "main")
    }

    private fun prewarmFlutterEngine(context: Context, engineId: String, entrypoint: String) {
        if (!FlutterEngineCache.getInstance().contains(engineId)) {
            // Instantiate a FlutterEngine
            val flutterEngine = FlutterEngine(context)

            flutterEngine.navigationChannel.setInitialRoute("/")

            // Create a general method channel
            MethodChannel(flutterEngine.dartExecutor.binaryMessenger,FLUTTER_METHOD_CHANNEL_ID)

            // Start executing Dart code to pre-warm the FlutterEngine.
            flutterEngine.dartExecutor.executeDartEntrypoint(
                DartExecutor.DartEntrypoint(
                    FlutterInjector.instance().flutterLoader().findAppBundlePath(), entrypoint
                )
            )

            // Cache the FlutterEngine to be used by FlutterActivity.
            FlutterEngineCache.getInstance().put(engineId, flutterEngine)
        }
    }
}