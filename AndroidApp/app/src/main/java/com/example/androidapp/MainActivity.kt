package com.example.androidapp

import androidx.appcompat.app.AppCompatActivity
import android.os.Bundle
import android.widget.Button
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngineCache

class MainActivity : AppCompatActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        val firstButton = findViewById<Button>(R.id.button)

        firstButton.setOnClickListener {
            if (FlutterEngineCache.getInstance().contains(FLUTTER_ENGINE_ID)) {
                startActivity(
                    FlutterActivity.withCachedEngine(FLUTTER_ENGINE_ID)
                        .build(applicationContext)
                )
            }
        }
    }
}