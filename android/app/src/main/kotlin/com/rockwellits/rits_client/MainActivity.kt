package com.rockwellits.rits_client

import android.os.Build
import android.os.Bundle
import android.os.StrictMode
import io.flutter.plugins.GeneratedPluginRegistrant
import javax.net.ssl.HostnameVerifier
import javax.net.ssl.HttpsURLConnection
import javax.net.ssl.SSLSession


private class WhitelistHostnameVerifier(private val trustedHosts: Set<String>) : HostnameVerifier {
    override fun verify(hostname: String, session: SSLSession?): Boolean {
        return if (trustedHosts.contains(hostname)) {
            true
        } else {
            defaultHostnameVerifier.verify(hostname, session)
        }
    }

    companion object {
        private val defaultHostnameVerifier: HostnameVerifier = HttpsURLConnection.getDefaultHostnameVerifier()
    }

}

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

        HttpsURLConnection.setDefaultHostnameVerifier(
                WhitelistHostnameVerifier(setOf("appbuilder.rockwellits.com")));
    }
}
