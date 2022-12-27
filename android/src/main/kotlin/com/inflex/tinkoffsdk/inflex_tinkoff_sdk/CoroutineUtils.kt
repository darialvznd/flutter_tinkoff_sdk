package com.inflex.tinkoffsdk.flutter_tinkoff_sdk

import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Dispatchers.IO
import kotlinx.coroutines.launch

fun CoroutineScope.doOnMain(block: () -> Unit) {
    this.launch(Dispatchers.Main) {
        block.invoke()
    }
}

fun CoroutineScope.doOnBackground(block: () -> Unit) {
    this.launch(IO) {
        block.invoke()
    }
}