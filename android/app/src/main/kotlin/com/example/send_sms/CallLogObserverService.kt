package com.example.send_sms

import android.annotation.SuppressLint
import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.appwidget.AppWidgetManager
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.database.ContentObserver
import android.os.Build
import android.os.Handler
import android.os.IBinder
import android.os.Looper
import android.provider.CallLog
import androidx.core.app.NotificationCompat

class CallLogObserverService : Service() {

    private lateinit var observer: ContentObserver

    override fun onCreate() {
        super.onCreate()
        startAsForeground()
        
        observer = object : ContentObserver(Handler(Looper.getMainLooper())) {
            override fun onChange(selfChange: Boolean) {
                updateWidgets(applicationContext)
            }
        }
        contentResolver.registerContentObserver(CallLog.Calls.CONTENT_URI, true, observer)
    }

    @SuppressLint("ForegroundServiceType")
    private fun startAsForeground() {
        val channelId = "call_log_observer"
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                channelId, "Call Log Monitor",
                NotificationManager.IMPORTANCE_LOW
            )
            val manager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            manager.createNotificationChannel(channel)
        }

        val notification: Notification = NotificationCompat.Builder(this, channelId)
            .setContentTitle("Widget Updating")
            .setContentText("Monitoring call logs for real-time updates")
            .setSmallIcon(android.R.drawable.ic_menu_call)
            .build()

        startForeground(1, notification)
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        return START_STICKY
    }

    override fun onDestroy() {
        super.onDestroy()
        contentResolver.unregisterContentObserver(observer)
    }

    override fun onBind(intent: Intent?): IBinder? = null

    private fun  updateWidgets(context: Context) {
        val appWidgetManager = AppWidgetManager.getInstance(context)
        val componentName = ComponentName(context, CallLogsAppWidget::class.java)
        val appWidgetIds = appWidgetManager.getAppWidgetIds(componentName)
        // Buộc ListView load lại dữ liệu mới
        appWidgetManager.notifyAppWidgetViewDataChanged(appWidgetIds, R.id.call_logs_list)
    }
}
