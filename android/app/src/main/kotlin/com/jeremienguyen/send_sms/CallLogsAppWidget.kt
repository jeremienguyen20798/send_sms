package com.jeremienguyen.send_sms

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.os.Build
import android.widget.RemoteViews
import androidx.core.net.toUri

class CallLogsAppWidget : AppWidgetProvider() {
    
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        // Đảm bảo Service luôn chạy khi widget update
        startObserverService(context)
        for (appWidgetId in appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId)
        }
    }

    override fun onEnabled(context: Context) {
        super.onEnabled(context)
        // Khởi chạy service ngay khi widget đầu tiên được tạo
        startObserverService(context)
    }

    private fun startObserverService(context: Context) {
        val intent = Intent(context, CallLogObserverService::class.java)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            context.startForegroundService(intent)
        } else {
            context.startService(intent)
        }
    }
}

internal fun updateAppWidget(
    context: Context,
    appWidgetManager: AppWidgetManager,
    appWidgetId: Int
) {
    val views = RemoteViews(context.packageName, R.layout.call_logs_app_widget)
    
    val intent = Intent(context, CallLogWidgetService::class.java).apply {
        putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, appWidgetId)
        data = toUri(Intent.URI_INTENT_SCHEME).toUri()
    }
    
    views.setRemoteAdapter(R.id.call_logs_list, intent)
    // Thông báo cho adapter biết dữ liệu có thể đã thay đổi
    appWidgetManager.notifyAppWidgetViewDataChanged(appWidgetId, R.id.call_logs_list)
    
    appWidgetManager.updateAppWidget(appWidgetId, views)
}
