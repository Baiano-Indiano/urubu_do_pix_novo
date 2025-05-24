package com.example.urubu_do_pix_novo

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.view.WindowManager.LayoutParams
import android.content.pm.PackageManager
import android.view.View
import android.view.WindowManager

class MainActivity: FlutterActivity() {
    private val SECURE_CHANNEL = "flutter_secure"
    private val SECURITY_CHECKER_CHANNEL = "security_checker"
    private var isContentHidden = false

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        // Canal para proteção contra screenshots e segurança
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, SECURE_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "enableSecure" -> {
                    window.addFlags(LayoutParams.FLAG_SECURE)
                    result.success(null)
                }
                "disableSecure" -> {
                    window.clearFlags(LayoutParams.FLAG_SECURE)
                    result.success(null)
                }
                "preventBackgroundPreview" -> {
                    window.setFlags(
                        WindowManager.LayoutParams.FLAG_SECURE or WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON,
                        WindowManager.LayoutParams.FLAG_SECURE or WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON
                    )
                    result.success(null)
                }
                "hideContent" -> {
                    if (!isContentHidden) {
                        window.decorView.visibility = View.INVISIBLE
                        isContentHidden = true
                    }
                    result.success(null)
                }
                "showContent" -> {
                    if (isContentHidden) {
                        window.decorView.visibility = View.VISIBLE
                        isContentHidden = false
                    }
                    result.success(null)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }

        // Canal para verificação de segurança
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, SECURITY_CHECKER_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "checkMaliciousApps" -> {
                    val packages = call.argument<List<String>>("packages")
                    if (packages != null) {
                        result.success(checkMaliciousApps(packages))
                    } else {
                        result.error("INVALID_ARGUMENT", "Lista de pacotes é nula", null)
                    }
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun checkMaliciousApps(packages: List<String>): Boolean {
        val packageManager = context.packageManager
        for (packageName in packages) {
            try {
                packageManager.getPackageInfo(packageName, PackageManager.GET_ACTIVITIES)
                return true // Se encontrar qualquer app da lista, retorna true
            } catch (e: PackageManager.NameNotFoundException) {
                // App não encontrado, continua verificando
                continue
            }
        }
        return false
    }

    override fun onPause() {
        super.onPause()
        if (isContentHidden) {
            window.decorView.visibility = View.INVISIBLE
        }
    }

    override fun onResume() {
        super.onResume()
        if (isContentHidden) {
            window.decorView.visibility = View.VISIBLE
        }
    }
}
