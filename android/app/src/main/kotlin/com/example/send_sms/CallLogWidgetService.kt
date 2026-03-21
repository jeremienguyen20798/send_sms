package com.example.send_sms

import android.content.Context
import android.content.Intent
import android.provider.CallLog
import android.widget.RemoteViews
import android.widget.RemoteViewsService

class CallLogWidgetService : RemoteViewsService() {
    override fun onGetViewFactory(intent: Intent): RemoteViewsFactory {
        return CallLogRemoteViewsFactory(this.applicationContext)
    }
}

class CallLogRemoteViewsFactory(private val context: Context) : RemoteViewsService.RemoteViewsFactory {

    private var callLogs: List<String> = emptyList()

    override fun onCreate() {}

    override fun onDataSetChanged() {
        // Lấy dữ liệu lịch sử cuộc gọi
        val cursor = context.contentResolver.query(
            CallLog.Calls.CONTENT_URI,
            arrayOf(CallLog.Calls.NUMBER, CallLog.Calls.TYPE, CallLog.Calls.DATE),
            null, null, "${CallLog.Calls.DATE} DESC"
        )

        val logs = mutableListOf<String>()
        cursor?.use {
            val numberIndex = it.getColumnIndex(CallLog.Calls.NUMBER)
            while (it.moveToNext() && logs.size < 10) {
                logs.add(it.getString(numberIndex))
            }
        }
        callLogs = logs
    }

    override fun onDestroy() {}

    override fun getCount(): Int = callLogs.size

    override fun getViewAt(position: Int): RemoteViews {
        val views = RemoteViews(context.packageName, android.R.layout.simple_list_item_1)
        views.setTextViewText(android.R.id.text1, callLogs[position])
        return views
    }

    override fun getLoadingView(): RemoteViews? = null
    override fun getViewTypeCount(): Int = 1
    override fun getItemId(position: Int): Long = position.toLong()
    override fun hasStableIds(): Boolean = true
}
