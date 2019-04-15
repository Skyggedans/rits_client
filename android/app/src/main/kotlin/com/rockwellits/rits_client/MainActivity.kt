package com.rockwellits.rits_client

import android.content.Intent
import android.os.Bundle

import io.flutter.app.FlutterActivity
import io.flutter.plugins.GeneratedPluginRegistrant
import io.flutter.plugin.common.MethodChannel
import android.app.Activity


class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.rockwellits.client"
    private val BARCODE_REQUEST = 1984
    private val ACTION_BARCODE = "com.realwear.barcodereader.intent.action.SCAN_BARCODE"
    private val EXTRA_RESULT = "com.realwear.barcodereader.intent.extra.RESULT"
    private lateinit var methodResult: MethodChannel.Result

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        GeneratedPluginRegistrant.registerWith(this)

        MethodChannel(flutterView, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "scanBarCode") {
                methodResult = result

                val intent = Intent(ACTION_BARCODE)
                startActivityForResult(intent, BARCODE_REQUEST)
            }
            else {
                result.notImplemented()
            }
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, intent: Intent?) {
        if (requestCode != BARCODE_REQUEST) {
            return super.onActivityResult(requestCode, resultCode, intent)
        }

        if (resultCode == Activity.RESULT_OK && requestCode === BARCODE_REQUEST) {
            var result = "[No Barcode]"

            if (intent != null) {
                result = intent.getStringExtra(EXTRA_RESULT)
            }

            methodResult.success(result)
        }
        else {
            methodResult.success(null)
        }
    }
}
