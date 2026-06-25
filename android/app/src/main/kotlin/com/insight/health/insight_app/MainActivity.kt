package com.insight.health.insight_app

import android.app.AppOpsManager
import android.app.usage.UsageStatsManager
import android.content.Context
import android.content.Intent
import android.os.Build
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.Calendar

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.insight.health/usage_stats"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "hasPermission" -> {
                    result.success(hasUsageStatsPermission())
                }
                "requestPermission" -> {
                    try {
                        val intent = Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS)
                        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                        startActivity(intent)
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("PERMISSION_ERROR", e.message, null)
                    }
                }
                "getUsageStats" -> {
                    if (!hasUsageStatsPermission()) {
                        result.error("NO_PERMISSION", "Usage stats permission not granted", null)
                        return@setMethodCallHandler
                    }
                    val daysBack = call.argument<Int>("daysBack") ?: 0
                    val stats = getUsageStats(daysBack)
                    result.success(stats)
                }
                "getTodayStats" -> {
                    if (!hasUsageStatsPermission()) {
                        result.error("NO_PERMISSION", "Usage stats permission not granted", null)
                        return@setMethodCallHandler
                    }
                    val stats = getUsageStats(0)
                    result.success(stats)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun hasUsageStatsPermission(): Boolean {
        val appOps = getSystemService(Context.APP_OPS_SERVICE) as AppOpsManager
        val mode = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            appOps.unsafeCheckOpNoThrow(
                AppOpsManager.OPSTR_GET_USAGE_STATS,
                android.os.Process.myUid(),
                packageName
            )
        } else {
            @Suppress("DEPRECATION")
            appOps.checkOpNoThrow(
                AppOpsManager.OPSTR_GET_USAGE_STATS,
                android.os.Process.myUid(),
                packageName
            )
        }
        return mode == AppOpsManager.MODE_ALLOWED
    }

    private fun getUsageStats(daysBack: Int): List<Map<String, Any>> {
        val usageStatsManager = getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager

        val calendar = Calendar.getInstance()
        // Set to start of the target day
        calendar.add(Calendar.DAY_OF_YEAR, -daysBack)
        calendar.set(Calendar.HOUR_OF_DAY, 0)
        calendar.set(Calendar.MINUTE, 0)
        calendar.set(Calendar.SECOND, 0)
        calendar.set(Calendar.MILLISECOND, 0)
        val startTime = calendar.timeInMillis

        // End time: end of that day (or now if today)
        if (daysBack == 0) {
            calendar.timeInMillis = System.currentTimeMillis()
        } else {
            calendar.set(Calendar.HOUR_OF_DAY, 23)
            calendar.set(Calendar.MINUTE, 59)
            calendar.set(Calendar.SECOND, 59)
        }
        val endTime = calendar.timeInMillis

        val usageStatsList = usageStatsManager.queryUsageStats(
            UsageStatsManager.INTERVAL_DAILY, startTime, endTime
        )

        val results = mutableListOf<Map<String, Any>>()

        for (stat in usageStatsList) {
            if (stat.totalTimeInForeground > 0) {
                val minutes = stat.totalTimeInForeground / 60000
                if (minutes > 0) {
                    results.add(
                        mapOf(
                            "packageName" to stat.packageName,
                            "totalMinutes" to minutes,
                            "lastUsed" to stat.lastTimeUsed,
                            "firstUsed" to stat.firstTimeStamp
                        )
                    )
                }
            }
        }

        // Sort by usage time descending
        results.sortByDescending { it["totalMinutes"] as Long }

        return results
    }
}
