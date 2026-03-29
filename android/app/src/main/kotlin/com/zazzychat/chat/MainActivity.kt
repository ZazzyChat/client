// android/app/src/main/kotlin/com/zazzychat/chat/MainActivity.kt

package com.zazzychat.chat

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

import android.content.Context
import android.content.Intent
import androidx.multidex.MultiDex
import android.os.Bundle

class MainActivity : FlutterActivity() {

    // ---------- основная часть (MultiDex + engine pool) ----------
    override fun attachBaseContext(base: Context) {
        super.attachBaseContext(base)
        MultiDex.install(this)
    }

    override fun provideFlutterEngine(context: Context): FlutterEngine? {
        return provideEngine(this)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        // do nothing, because the engine was been configured in provideEngine
    }

    companion object {
        var engine: FlutterEngine? = null
        fun provideEngine(context: Context): FlutterEngine {
            val eng = engine ?: FlutterEngine(context, emptyArray(), true, false)
            engine = eng
            return eng
        }
    }
    // ---------------------------------------------------------

    // Ловим интенты при старте и при повторных открытиях
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // safeLogIntent("onCreate", intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        // safeLogIntent("onNewIntent", intent)
    }

    /*
    -------------------------------------------------------------
    ⚠️ Блок логирования интентов - временно отключён.
    -------------------------------------------------------------

    // --------- ЛОГИРОВАНИЕ В ТЕКСТОВЫЙ ФАЙЛ ---------
    private fun safeLogIntent(stage: String, intent: Intent?) {
        try {
            val line = buildIntentDump(stage, intent)
            appendInternal(line)
            appendToDownloads("ZazzyChat", "intent_log.txt", line)
            Log.i("IntentLogger", line)
        } catch (t: Throwable) {
            Log.e("IntentLogger", "log failed", t)
        }
    }

    private fun buildIntentDump(stage: String, intent: Intent?): String {
        val ts = SimpleDateFormat("yyyy-MM-dd HH:mm:ss.SSS", Locale.US).format(Date())
        val sb = StringBuilder()
        sb.append("===\n")
        sb.append("$ts | $stage\n")
        if (intent == null) {
            sb.append("INTENT: null\n\n")
            return sb.toString()
        }
        sb.append("Action: ${intent.action}\n")
        sb.append("DataString: ${intent.dataString}\n")
        sb.append("Scheme: ${intent.scheme}\n")
        sb.append("Type: ${intent.type}\n")
        sb.append("Flags: ${intent.flags}\n")
        sb.append("Component: ${intent.component}\n")

        val extras = intent.extras
        if (extras != null && !extras.isEmpty) {
            sb.append("Extras:\n")
            for (k in extras.keySet()) {
                val v = try { extras.get(k) } catch (_: Throwable) { "<err>" }
                sb.append("  $k => $v\n")
            }
        } else sb.append("Extras: none\n")

        try { sb.append("callingPackage: $callingPackage\n") } catch (_: Throwable) {}

        sb.append("\n")
        return sb.toString()
    }

    private fun appendInternal(text: String) {
        val f = File(filesDir, "intent_log.txt")
        FileWriter(f, true).use { it.append(text) }
    }

    private fun appendToDownloads(folder: String, filename: String, text: String) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            val relPath = "${android.os.Environment.DIRECTORY_DOWNLOADS}/$folder"
            val base = MediaStore.Downloads.EXTERNAL_CONTENT_URI
            val projection = arrayOf(
                MediaStore.Downloads._ID,
                MediaStore.Downloads.DISPLAY_NAME,
                MediaStore.Downloads.RELATIVE_PATH
            )
            var target = contentResolver.query(
                base, projection,
                "${MediaStore.Downloads.DISPLAY_NAME}=? AND ${MediaStore.Downloads.RELATIVE_PATH}=?",
                arrayOf(filename, "$relPath/"), null
            ).use { c ->
                if (c != null && c.moveToFirst()) {
                    val id = c.getLong(0)
                    ContentUris.withAppendedId(base, id)
                } else null
            }

            if (target == null) {
                val values = ContentValues().apply {
                    put(MediaStore.Downloads.DISPLAY_NAME, filename)
                    put(MediaStore.Downloads.MIME_TYPE, "text/plain")
                    put(MediaStore.Downloads.RELATIVE_PATH, relPath)
                    put(MediaStore.Downloads.IS_PENDING, 0)
                }
                target = contentResolver.insert(base, values)
            }

            if (target != null) {
                contentResolver.openOutputStream(target, "wa")!!.use { it.write(text.toByteArray()) }
            }
        } else {
            val dir = getExternalFilesDir(folder) ?: filesDir
            val f = File(dir, filename)
            FileWriter(f, true).use { it.append(text) }
        }
    }
    // -------------------------------------------------
    */
}
