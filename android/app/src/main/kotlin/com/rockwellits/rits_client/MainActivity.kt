package com.rockwellits.rits_client

import android.os.Build
import android.os.Bundle
import android.os.StrictMode
import io.flutter.plugins.GeneratedPluginRegistrant


class MainActivity : RealWearActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        GeneratedPluginRegistrant.registerWith(this)

        if (Build.VERSION.SDK_INT >= 24) {
            try {
                val m = StrictMode::class.java.getMethod("disableDeathOnFileUriExposure")
                m.invoke(null)
            } catch (e: Exception) {
                e.printStackTrace()
            }
        }
    }
}
