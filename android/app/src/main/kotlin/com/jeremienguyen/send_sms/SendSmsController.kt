package com.jeremienguyen.send_sms

import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.telephony.SmsManager
import android.util.Log
import androidx.core.content.FileProvider
import java.io.File
import java.io.FileOutputStream
import java.nio.charset.Charset
import java.time.LocalDateTime

class SendSmsController {

    /**
     * Gửi MMS ngầm không cần giao diện
     * @param context Context của ứng dụng
     * @param phoneNumber Số điện thoại nhận
     * @param message Nội dung văn bản
     * @param imageBytes Dữ liệu hình ảnh (byte array)
     */
    fun sendMmsSilently(
        context: Context,
        phoneNumber: String,
        message: String,
        imageBytes: ByteArray
    ) {
        try {
            val smsManager: SmsManager =
                context.getSystemService(SmsManager::class.java)
            // 1. Tạo file PDU (Đây là phần phức tạp nhất, cần thư viện PDU)
            // Ví dụ này giả định bạn đã có hàm tạo byte array PDU
            val pduData = createPduData(phoneNumber, message, imageBytes)

            // 2. Lưu PDU vào file tạm trong cache
            val cacheDir = File(context.cacheDir, "mms")
            if (!cacheDir.exists()) cacheDir.mkdirs()
            val pduFile = File(cacheDir, "pending_mms_${System.currentTimeMillis()}.pdu")
            FileOutputStream(pduFile).use { it.write(pduData) }

            // 3. Lấy Content URI thông qua FileProvider
            val contentUri = FileProvider.getUriForFile(
                context,
                "${context.packageName}.fileprovider",
                pduFile
            )

            // 4. Chuẩn bị PendingIntent để nhận kết quả
            val sentIntent = PendingIntent.getBroadcast(
                context, 0, Intent("MMS_SENT_ACTION"),
                PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
            )

            // 5. Gửi MMS
            smsManager.sendMultimediaMessage(context, contentUri, null, null, sentIntent)
            Log.d("SendSmsController", "MMS sending initiated...")

        } catch (e: Exception) {
            Log.e("SendSmsController", "Error sending silent MMS: ${e.message}")
        }
    }

    /**
     * Hàm giả lập tạo dữ liệu PDU. 
     * TRONG THỰC TẾ: Bạn phải sử dụng các class như SendReq, PduBody, PduPart 
     * từ thư viện 'com.google.android.mms' hoặc 'com.klinker.android:mms'.
     */
    private fun createPduData(
        phoneNumber: String,
        message: String,
        imageBytes: ByteArray
    ): ByteArray {
        val tpMti = 0x00.toByte() // SMS-Deliver
        val tpPid = 0x00.toByte()
        val tpDcs = 0x00.toByte() // 7-bit encoding
        val timestamp = LocalDateTime.of(2026, 3, 9, 21, 0, 0) // SCTS timestamp
        val tpScts = encodeScts(timestamp)
        val tpOa = encodeAddress(phoneNumber)
        val tpUd = encode7bitUserData(message)
        val tpUdl = message.length.toByte() // Length in 7-bit characters

        // Assemble PDU: MTI + PID + DCS + SCTS + OA + UDL + UD
        return byteArrayOf(tpMti, tpPid, tpDcs) + tpScts + tpOa + byteArrayOf(tpUdl) + tpUd
    }

    fun encodeAddress(address: String): ByteArray {
        // Replace '+' with international prefix (0x91)
        val normalized = address.replace("+", "91")
        // Pad to even length with 'F' if needed
        val padded = if (normalized.length % 2 != 0) normalized + "F" else normalized
        // Convert to BCD with semi-octet swap
        val bytes = mutableListOf<Byte>()
        for (i in padded.indices step 2) {
            val highNibble = padded[i].digitToInt(16)
            val lowNibble = padded[i + 1].digitToInt(16)
            // Swap nibbles: high becomes low, low becomes high
            val swappedByte = (lowNibble shl 4 or highNibble).toByte()
            bytes.add(swappedByte)
        }
        // Address length (number of digits) + type-of-number (0x81 = international)
        val lengthByte = (padded.length / 2).toByte() // Length in bytes (1 byte = 2 digits)
        return byteArrayOf(0x81.toByte(), lengthByte) + bytes.toByteArray()
    }

    fun encodeScts(timestamp: LocalDateTime): ByteArray {
        val tzOffset = 0 // UTC+0 (0x00)
        val components = listOf(
            timestamp.year % 100, // YY
            timestamp.monthValue, // MM
            timestamp.dayOfMonth, // DD
            timestamp.hour, // HH
            timestamp.minute, // MM
            timestamp.second, // SS
            tzOffset // TZ (15 min/unit; 0 = UTC+0)
        )
        val sctsBytes = mutableListOf<Byte>()
        for (comp in components) {
            // Convert component to 2-digit BCD (e.g., 24 → 0x24)
            val bcd = (comp / 10 shl 4) or (comp % 10)
            sctsBytes.add(bcd.toByte())
        }
        return sctsBytes.toByteArray()
    }

    fun encode7bitUserData(text: String): ByteArray {
        val gsmCharset = Charset.forName("GSM0338".toString())
        val septets = text.toByteArray(gsmCharset) // Convert text to 7-bit GSM bytes
        val packed = mutableListOf<Byte>()
        var bitBuffer = 0
        var bitsInBuffer = 0
        for (septet in septets) {
            val septetValue = septet.toInt() and 0x7F // Ensure 7 bits
            // Pack into buffer
            bitBuffer = (bitBuffer shl 7) or septetValue
            bitsInBuffer += 7
            // Extract full bytes from buffer
            while (bitsInBuffer >= 8) {
                bitsInBuffer -= 8
                val byte = (bitBuffer shr bitsInBuffer).toByte()
                packed.add(byte)
                bitBuffer = bitBuffer and ((1 shl bitsInBuffer) - 1) // Keep remaining bits
            }
        }
        // Add remaining bits if any
        if (bitsInBuffer > 0) {
            packed.add((bitBuffer shl (8 - bitsInBuffer)).toByte())
        }
        return packed.toByteArray()
    }

    fun sendSms(context: Context, phoneNumber: String, message: String) {
        try {
            val smsManager: SmsManager =
                context.getSystemService(SmsManager::class.java)
            val sentIntent = PendingIntent.getBroadcast(
                context, 0, Intent("SMS_SENT"),
                PendingIntent.FLAG_IMMUTABLE
            )
            if (message.length > 160) {
                val parts = smsManager.divideMessage(message)
                smsManager.sendMultipartTextMessage(
                    phoneNumber,
                    null,
                    parts,
                    arrayListOf(sentIntent),
                    null
                )
            } else {
                smsManager.sendTextMessage(phoneNumber, null, message, sentIntent, null)
            }
        } catch (e: Exception) {
            Log.e("SendSmsController", "Error sending SMS: ${e.message}")
        }
    }
}
