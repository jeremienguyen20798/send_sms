package com.jeremienguyen.send_sms

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
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.os.Build
import android.os.Handler
import android.os.IBinder
import android.os.Looper
import android.provider.CallLog
import android.provider.MediaStore
import android.util.Log
import androidx.core.app.NotificationCompat
import com.google.ai.client.generativeai.GenerativeModel
import com.google.ai.client.generativeai.type.content
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.launch
import org.json.JSONObject

class CallLogObserverService : Service() {

    private lateinit var observer: ContentObserver
    private val serviceJob = SupervisorJob()
    private val serviceScope = CoroutineScope(Dispatchers.Main + serviceJob)
    private val smsController = SendSmsController()

    // TODO: Thay thế bằng API Key thực của bạn từ https://aistudio.google.com/
    private val GEMINI_API_KEY = "AIzaSyCOc5_bDRYIxOxJpjzonrXgQfhiUtft8yQ"

    // Thông tin tài khoản mặc định để gửi kèm trong tin nhắn
    private val MY_ACCOUNT_INFO = "STK: 0392634700 VP Bank - Nguyễn Hoàng Phúc"

    override fun onCreate() {
        super.onCreate()
        startAsForeground()

        observer = object : ContentObserver(Handler(Looper.getMainLooper())) {
            override fun onChange(selfChange: Boolean) {
                // 1. Cập nhật Widget
                updateWidgets(applicationContext)
                // 2. Xử lý phân tích ảnh và gửi SMS
                processLatestActivity()
            }
        }
        contentResolver.registerContentObserver(CallLog.Calls.CONTENT_URI, true, observer)
    }

    private fun processLatestActivity() {
        serviceScope.launch(Dispatchers.IO) {
            val latestNumber = getLatestCallLogNumber(applicationContext)
            val screenshot = getLatestScreenshot(applicationContext)
            if (latestNumber != null && screenshot != null) {
                analyzeAndSendSms(latestNumber, screenshot)
            } else {
                Log.d(
                    "CallLogObserver",
                    "Missing info: Number=$latestNumber, HasScreenshot=${screenshot != null}"
                )
            }
        }
    }

    private fun getLatestCallLogNumber(context: Context): String? {
        val projection = arrayOf(CallLog.Calls.NUMBER)
        val sortOrder = "${CallLog.Calls.DATE} DESC"
        val cursor = context.contentResolver.query(
            CallLog.Calls.CONTENT_URI,
            projection,
            null,
            null,
            sortOrder
        )
        cursor?.use {
            if (it.moveToFirst()) {
                return it.getString(it.getColumnIndexOrThrow(CallLog.Calls.NUMBER))
            }
        }
        return null
    }

    private fun getLatestScreenshot(context: Context): Bitmap? {
        val projection = arrayOf(
            MediaStore.Images.Media.DATA,
            MediaStore.Images.Media.DATE_ADDED
        )
        val selection = "${MediaStore.Images.Media.DATA} LIKE ?"
        val selectionArgs = arrayOf("%Screenshots%")
        val sortOrder = "${MediaStore.Images.Media.DATE_ADDED} DESC"

        val cursor = context.contentResolver.query(
            MediaStore.Images.Media.EXTERNAL_CONTENT_URI,
            projection,
            selection,
            selectionArgs,
            sortOrder
        )

        cursor?.use {
            if (it.moveToFirst()) {
                val filePath = it.getString(it.getColumnIndexOrThrow(MediaStore.Images.Media.DATA))
                return BitmapFactory.decodeFile(filePath)
            }
        }
        return null
    }

    private suspend fun analyzeAndSendSms(phoneNumber: String, bitmap: Bitmap) {
        try {
//            val generativeModel = GenerativeModel(
//                modelName = "gemini-3.1-pro-preview",
//                apiKey = GEMINI_API_KEY
//            )
//            val prompt =
//                "Hãy phân tích bức ảnh này và lấy ra giá trị của phương thức thanh toán (ví dụ: Momo, ZaloPay, Ngân hàng) và số tiền được đề cập đến trong bức ảnh. Chỉ trả về kết quả dưới dạng JSON: { \"payment_method\": \"...\", \"amount\": \"...\" }"
//            val inputContent = content {
//                image(bitmap)
//                text(prompt)
//            }
//            val response = generativeModel.generateContent(inputContent)
//            val resultText = response.text ?: ""
//            Log.d("GeminiResult", "Response: $resultText")
//
//            // Trích xuất JSON từ kết quả trả về
//            val jsonStart = resultText.indexOf("{")
//            val jsonEnd = resultText.lastIndexOf("}")
//            if (jsonStart != -1 && jsonEnd != -1) {
//                val jsonStr = resultText.substring(jsonStart, jsonEnd + 1)
//                val jsonObject = JSONObject(jsonStr)
//                val method = jsonObject.optString("payment_method", "N/A")
//                val amount = jsonObject.optString("amount", "N/A")
                val message =
                    "Thông tin chuyển khoản qua tk: $MY_ACCOUNT_INFO. Số tiền: amount, phương thức thanh toán: method"
                // Gửi SMS
                smsController.sendSms(applicationContext, phoneNumber, message)
//                Log.d("CallLogObserver", "SMS sent to $phoneNumber: $message")
//            }

        } catch (e: Exception) {
            Log.e("CallLogObserver", "Error analyzing or sending SMS", e)
        }
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
            .setContentTitle("Hệ thống đang chạy")
            .setContentText("Đang theo dõi cuộc gọi và phân tích giao dịch")
            .setSmallIcon(android.R.drawable.ic_menu_call)
            .build()

        startForeground(1, notification)
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        return START_STICKY
    }

    override fun onDestroy() {
        super.onDestroy()
        serviceJob.cancel()
        contentResolver.unregisterContentObserver(observer)
    }

    override fun onBind(intent: Intent?): IBinder? = null

    private fun updateWidgets(context: Context) {
        val appWidgetManager = AppWidgetManager.getInstance(context)
        val componentName = ComponentName(context, CallLogsAppWidget::class.java)
        val appWidgetIds = appWidgetManager.getAppWidgetIds(componentName)
        appWidgetManager.notifyAppWidgetViewDataChanged(appWidgetIds, R.id.call_logs_list)
    }
}
