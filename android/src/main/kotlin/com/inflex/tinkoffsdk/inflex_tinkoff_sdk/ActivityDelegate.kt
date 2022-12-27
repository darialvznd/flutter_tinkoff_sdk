package com.inflex.tinkoffsdk.flutter_tinkoff_sdk

import android.app.Activity
import android.content.Context
import android.content.Intent

interface ActivityDelegate {
    val activity: Activity?
    val context: Context?

    suspend fun <T> runActivityForResult(
        initializeActivity: (Activity) -> Unit, requestCode: Int,
        activityResultMapper: (resultCode: Int, data: Intent?) -> T?
    ): T?
}