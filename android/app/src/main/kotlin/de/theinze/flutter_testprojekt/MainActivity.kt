package de.theinze.flutter_testprojekt

import android.content.ClipData
import android.content.Intent
import android.net.Uri
import android.provider.OpenableColumns
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
	private val CHANNEL = "app.open_document"
	private var pendingResult: MethodChannel.Result? = null
	private val PICK_VIDEOS_REQ = 10042

	override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
		super.configureFlutterEngine(flutterEngine)
		MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
			when (call.method) {
				"pickVideos" -> {
					if (pendingResult != null) {
						result.error("ALREADY_ACTIVE", "Picker läuft bereits", null)
					} else {
						pendingResult = result
						launchOpenDocumentLegacy()
					}
				}
				else -> result.notImplemented()
			}
		}
	}

	@Suppress("DEPRECATION")
	private fun launchOpenDocumentLegacy() {
		val intent = Intent(Intent.ACTION_OPEN_DOCUMENT).apply {
			addCategory(Intent.CATEGORY_OPENABLE)
			type = "video/*"
			putExtra(Intent.EXTRA_ALLOW_MULTIPLE, true)
			addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
			addFlags(Intent.FLAG_GRANT_PERSISTABLE_URI_PERMISSION)
		}
		startActivityForResult(intent, PICK_VIDEOS_REQ)
	}

	@Suppress("DEPRECATION")
	override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
		super.onActivityResult(requestCode, resultCode, data)
		if (requestCode != PICK_VIDEOS_REQ || pendingResult == null) return

		if (data == null) {
			pendingResult?.success(emptyList<Map<String, Any?>>())
			pendingResult = null
			return
		}

		val resolver = contentResolver
		val out = ArrayList<Map<String, Any?>>()

		fun handleUri(uri: Uri) {
			try {
				try {
					resolver.takePersistableUriPermission(
						uri,
						Intent.FLAG_GRANT_READ_URI_PERMISSION
					)
				} catch (_: SecurityException) { }

				var name: String? = null
				var size: Long? = null
				resolver.query(uri, null, null, null, null)?.use { cursor ->
					val nameIdx = cursor.getColumnIndex(OpenableColumns.DISPLAY_NAME)
					val sizeIdx = cursor.getColumnIndex(OpenableColumns.SIZE)
					if (cursor.moveToFirst()) {
						if (nameIdx >= 0) name = cursor.getString(nameIdx)
						if (sizeIdx >= 0) size = cursor.getLong(sizeIdx)
					}
				}
				out.add(
					mapOf(
						"uri" to uri.toString(),
						"name" to (name ?: uri.lastPathSegment ?: "Video"),
						"size" to (size ?: -1L)
					)
				)
			} catch (e: Exception) {
				e.printStackTrace()
			}
		}

		val clip: ClipData? = data.clipData
		if (clip != null && clip.itemCount > 0) {
			for (i in 0 until clip.itemCount) {
				val uri = clip.getItemAt(i).uri ?: continue
				handleUri(uri)
			}
		} else {
			data.data?.let { handleUri(it) }
		}

		pendingResult?.success(out)
		pendingResult = null
	}
}
