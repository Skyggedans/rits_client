package com.rockwellits.rits_client

import android.content.Context
import android.os.Build
import android.os.Bundle
import android.view.WindowManager
import android.view.accessibility.AccessibilityNodeInfo
import android.view.accessibility.AccessibilityNodeProvider
import io.flutter.app.FlutterActivity
import io.flutter.view.FlutterView
import java.lang.reflect.Field

open class RealWearActivity : FlutterActivity() {
    override fun createFlutterView(context: Context): FlutterView? {
        if (Build.BRAND == "RealWear") {
            val flutterView = object : FlutterView(context) {
                lateinit var accessibilityBridgeWrapper: AccessibilityNodeProvider
                lateinit var flutterSemanticsTreeField: Field

                override fun getAccessibilityNodeProvider(): AccessibilityNodeProvider {
                    return accessibilityBridgeWrapper
                }

                override fun onAttachedToWindow() {
                    super.onAttachedToWindow()

                    val accessibilityBridge = super.getAccessibilityNodeProvider()

                    flutterSemanticsTreeField = accessibilityBridge.javaClass.getDeclaredField("flutterSemanticsTree")
                    flutterSemanticsTreeField.isAccessible = true

                    accessibilityBridgeWrapper = object : AccessibilityNodeProvider() {
                        @Suppress("UNCHECKED_CAST")
                        override fun createAccessibilityNodeInfo(virtualViewId: Int): AccessibilityNodeInfo? {
                            val result = accessibilityBridge.createAccessibilityNodeInfo(virtualViewId)
                            val flutterSemanticsTree: HashMap<Int, *> =
                                    flutterSemanticsTreeField.get(accessibilityBridge) as HashMap<Int, *>

                            if (flutterSemanticsTree.containsKey(virtualViewId)) {
                                val semanticsNode = flutterSemanticsTree[virtualViewId]
                                val valueField = semanticsNode?.javaClass?.getDeclaredField("value")

                                valueField?.isAccessible = true
                                valueField?.get(semanticsNode)?.let { result?.contentDescription = it as CharSequence }
                            }

                            return result
                        }

                        override fun performAction(virtualViewId: Int, action: Int, arguments: Bundle?): Boolean {
                            return accessibilityBridge.performAction(virtualViewId, action, arguments)
                        }

                        override fun findFocus(focus: Int): AccessibilityNodeInfo? {
                            return accessibilityBridge.findFocus(focus)
                        }
                    }
                }
            }

            flutterView.layoutParams = WindowManager.LayoutParams(-1, -1)
            setContentView(flutterView)

            return flutterView
        } else {
            return super.createFlutterView(context)
        }
    }
}