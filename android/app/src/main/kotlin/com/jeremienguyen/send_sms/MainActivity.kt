package com.jeremienguyen.send_sms

import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel


class MainActivity : FlutterActivity() {

    private val channelName = "com.jeremienguyen.send_sms/AutoSendSMS"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            channelName
        ).setMethodCallHandler { call, result ->
            if (call.method == "requestDefaultSMSApp") {
                openSMSAppChooser(applicationContext)
            }
        }
    }
}

fun openSMSAppChooser(context: Context) {
    val packageManager = context.packageManager
    val componentName: ComponentName =
        ComponentName(context, MainActivity::class.java)
    packageManager.setComponentEnabledSetting(
        componentName,
        PackageManager.COMPONENT_ENABLED_STATE_ENABLED,
        PackageManager.DONT_KILL_APP
    )

    val selector = Intent(Intent.ACTION_MAIN)
    selector.addCategory(Intent.CATEGORY_APP_MESSAGING)
    selector.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
    context.startActivity(selector)

    packageManager.setComponentEnabledSetting(
        componentName,
        PackageManager.COMPONENT_ENABLED_STATE_DEFAULT,
        PackageManager.DONT_KILL_APP
    )
}
