package com.example.androidapp

import androidx.appcompat.app.AppCompatActivity
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.widget.Button
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.FlutterEngineCache
import io.flutter.plugin.common.MethodChannel

class MainActivity : AppCompatActivity() {

    val engine: FlutterEngine?
    val channel: MethodChannel

    init {
        engine = FlutterEngineCache.getInstance().get(FLUTTER_ENGINE_ID)

        channel = MethodChannel(engine?.dartExecutor?.binaryMessenger,FLUTTER_METHOD_CHANNEL_ID)
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        val firstButton = findViewById<Button>(R.id.button)

        firstButton.setOnClickListener {
            if (FlutterEngineCache.getInstance().contains(FLUTTER_ENGINE_ID)) {
                channel.invokeMethod("shouldPopAppOnBack", false)

                startActivity(
                    FlutterActivity.withCachedEngine(FLUTTER_ENGINE_ID)
                        .build(applicationContext)
                )
            }
        }

        val secondButton = findViewById<Button>(R.id.button2)

        secondButton.setOnClickListener {
            // What's shouldPopAppOnBack used for?
            // This flag indicates to the flutter app that the pushed view should pop the app
            // when the appbar back or the os back button is pressed
            channel.invokeMethod("shouldPopAppOnBack", true)

            engine?.navigationChannel?.pushRoute("/detail-no-animation")

            startActivity(
                FlutterActivity.withCachedEngine(FLUTTER_ENGINE_ID)
                    .build(applicationContext)
            )
        }
    }
}