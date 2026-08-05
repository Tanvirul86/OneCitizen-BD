package bd.onecitizen.onecitizen

import android.graphics.Bitmap
import android.graphics.Color
import android.graphics.pdf.PdfRenderer
import android.os.ParcelFileDescriptor
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.ByteArrayOutputStream
import java.io.File

class MainActivity : FlutterActivity() {
    private val previewChannel = "bd.onecitizen.onecitizen/document_preview"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, previewChannel).setMethodCallHandler { call, result ->
            when (call.method) {
                "renderPdfFirstPage" -> {
                    val path = call.argument<String>("path")
                    if (path.isNullOrBlank()) {
                        result.error("missing_path", "PDF path is required.", null)
                        return@setMethodCallHandler
                    }

                    try {
                        result.success(renderPdfFirstPage(path))
                    } catch (e: Exception) {
                        result.error("preview_failed", e.message ?: "Could not render PDF preview.", null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun renderPdfFirstPage(path: String): ByteArray {
        val file = File(path)
        ParcelFileDescriptor.open(file, ParcelFileDescriptor.MODE_READ_ONLY).use { descriptor ->
            PdfRenderer(descriptor).use { renderer ->
                if (renderer.pageCount == 0) {
                    throw IllegalStateException("PDF has no pages.")
                }

                renderer.openPage(0).use { page ->
                    val targetWidth = 900
                    val targetHeight = (targetWidth * page.height.toFloat() / page.width.toFloat()).toInt()
                    val bitmap = Bitmap.createBitmap(targetWidth, targetHeight, Bitmap.Config.ARGB_8888)
                    bitmap.eraseColor(Color.WHITE)
                    page.render(bitmap, null, null, PdfRenderer.Page.RENDER_MODE_FOR_DISPLAY)

                    val output = ByteArrayOutputStream()
                    bitmap.compress(Bitmap.CompressFormat.PNG, 100, output)
                    bitmap.recycle()
                    return output.toByteArray()
                }
            }
        }
    }
}
