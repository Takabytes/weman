/*
 * Copyright 2022-2024 New Vector Ltd.
 *
 * SPDX-License-Identifier: AGPL-3.0-only OR LicenseRef-Element-Commercial
 * Please see LICENSE files in the repository root for full details.
 */

package org.matrix.android.sdk.internal.coroutines.builder

import kotlinx.coroutines.CompletableDeferred
import kotlinx.coroutines.Deferred
import kotlinx.coroutines.channels.ProducerScope
import timber.log.Timber

/**
 * Safely invoke a cleanup function when a coroutine channel is closed.
 * This function catches any exceptions that might occur during cleanup to prevent
 * them from propagating and potentially causing issues.
 *
 * @param onClose The cleanup function to invoke when the channel is closed
 * @return A Deferred that completes when the channel is closed
 */
fun <T> ProducerScope<T>.safeInvokeOnClose(onClose: () -> Unit): Deferred<Unit> {
    val closeDeferred = CompletableDeferred<Unit>()
    
    val cleanup = {
        try {
            onClose()
        } catch (e: Exception) {
            Timber.w(e, "Exception during channel cleanup")
        } finally {
            closeDeferred.complete(Unit)
        }
    }
    
    invokeOnClose { cleanup() }
    
    return closeDeferred
}
