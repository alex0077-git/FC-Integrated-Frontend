package com.example.fc_frontend

import android.Manifest
import android.annotation.SuppressLint
import android.app.Activity
import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothDevice
import android.bluetooth.BluetoothManager
import android.bluetooth.BluetoothSocket
import android.content.pm.PackageManager
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.os.SystemClock
import android.util.Log
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.IOException
import java.io.InputStream
import java.io.OutputStream
import java.util.ArrayDeque
import java.util.UUID
import java.util.concurrent.Executors
import java.util.concurrent.atomic.AtomicInteger
import java.util.concurrent.atomic.AtomicLong

/**
 * Android stand-in for Windows Outgoing BT COM (agri / Fuselage path).
 *
 * Laptop: CreateFile(Outgoing COM) @ 57600, 8N1, raw bytes, K++ A1 on the wire.
 * Phone:  one RFCOMM SPP socket to the paired T12 (same logical serial pipe).
 * No CoolFly, no channel shopping — those are not part of the working PC path.
 */
class BluetoothSppBridge(
    private val activity: Activity,
) : MethodChannel.MethodCallHandler, EventChannel.StreamHandler {

    private val main = Handler(Looper.getMainLooper())
    private val io = Executors.newSingleThreadExecutor()
    private var socket: BluetoothSocket? = null
    private var input: InputStream? = null
    private var output: OutputStream? = null
    private var reader: Thread? = null
    private var events: EventChannel.EventSink? = null
    private val queueLock = Any()
    private val queue = ArrayDeque<ByteArray>()
    private var queuedBytes = 0
    private val bytesRead = AtomicLong(0)
    private val bytesWritten = AtomicLong(0)
    private val writeErrors = AtomicInteger(0)
    private var lastWriteError: String? = null
    private var connectedAddress: String? = null
    private var socketPath: String? = null

    fun register(messenger: BinaryMessenger) {
        MethodChannel(messenger, "fuselage_kpp/bluetooth").setMethodCallHandler(this)
        EventChannel(messenger, "fuselage_kpp/bluetooth_bytes").setStreamHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "list" -> {
                val missing = missingPermissions()
                if (missing.isNotEmpty()) {
                    activity.requestPermissions(missing, 41)
                    result.error("permission", "Allow Bluetooth, then tap refresh.", null)
                    return
                }
                io.execute {
                    try {
                        val devices = listPaired()
                        main.post { result.success(devices) }
                    } catch (error: SecurityException) {
                        main.post { result.error("permission", error.message, null) }
                    } catch (error: Exception) {
                        main.post { result.error("bluetooth", error.message, null) }
                    }
                }
            }
            "connect" -> {
                val address = call.argument<String>("address")
                if (address.isNullOrBlank()) {
                    result.error("bluetooth", "No Bluetooth device selected.", null)
                    return
                }
                val missing = missingPermissions()
                if (missing.isNotEmpty()) {
                    activity.requestPermissions(missing, 41)
                    result.error("permission", "Allow Bluetooth, then connect again.", null)
                    return
                }
                io.execute {
                    try {
                        connect(address)
                        main.post { result.success(statsMap()) }
                    } catch (error: Exception) {
                        Log.e(tag, "connect failed: ${error.message}", error)
                        main.post { result.error("bluetooth", error.message, null) }
                    }
                }
            }
            "write" -> {
                val data = readByteArgument(call, "data")
                if (data == null) {
                    writeErrors.incrementAndGet()
                    lastWriteError = "write payload missing/unsupported type"
                    Log.e(tag, lastWriteError!!)
                    result.error("bluetooth", lastWriteError, null)
                    return
                }
                io.execute {
                    try {
                        writeResilient(data)
                        main.post { result.success(null) }
                    } catch (error: Exception) {
                        writeErrors.incrementAndGet()
                        lastWriteError = error.message
                        Log.e(tag, "SPP write failed: ${error.message}")
                        main.post { result.error("bluetooth", error.message, null) }
                    }
                }
            }
            "pull" -> result.success(drainQueue())
            "stats" -> result.success(statsMap())
            "enablePassThrough" -> {
                // Kept for API compat; PC agri path does not use CoolFly on BT.
                main.post { result.success(statsMap()) }
            }
            "close" -> {
                io.execute {
                    closeSocket()
                    main.post { result.success(null) }
                }
            }
            else -> result.notImplemented()
        }
    }

    override fun onListen(arguments: Any?, sink: EventChannel.EventSink) {
        events = sink
        val buffered = drainQueue()
        if (buffered.isNotEmpty()) {
            sink.success(buffered)
        }
    }

    override fun onCancel(arguments: Any?) {
        events = null
    }

    @SuppressLint("MissingPermission")
    private fun listPaired(): List<Map<String, String>> {
        if (!hasConnectPermission()) {
            throw SecurityException("Allow Bluetooth, then tap refresh.")
        }
        val adapter = adapter() ?: throw IOException("This phone has no Bluetooth.")
        if (!adapter.isEnabled) {
            throw IOException("Turn Bluetooth on, then tap refresh.")
        }
        return adapter.bondedDevices.map { device ->
            mapOf(
                "id" to device.address,
                "name" to (device.name ?: device.address),
                // Match Windows COM dropdown detail style.
                "detail" to "${device.address} @ 57600",
            )
        }
    }

    /**
     * Mirror Windows Outgoing COM open:
     * cancel discovery → open one SPP client socket → start reading.
     * Secure RFCOMM first (closest to Windows paired Outgoing), then insecure.
     */
    @SuppressLint("MissingPermission")
    private fun connect(address: String) {
        if (!hasConnectPermission()) {
            throw SecurityException("Allow Bluetooth, then connect again.")
        }
        closeSocket()
        bytesRead.set(0)
        bytesWritten.set(0)
        writeErrors.set(0)
        lastWriteError = null
        socketPath = null
        val adapter = adapter() ?: throw IOException("This phone has no Bluetooth.")
        if (!adapter.isEnabled) {
            throw IOException("Turn Bluetooth on, then connect again.")
        }
        val device = adapter.getRemoteDevice(address)
        try {
            device.fetchUuidsWithSdp()
            SystemClock.sleep(600)
            Log.e(
                tag,
                "SDP UUIDs: " + (device.uuids?.joinToString { it.uuid.toString() } ?: "none"),
            )
        } catch (error: Exception) {
            Log.w(tag, "fetchUuidsWithSdp: ${error.message}")
        }

        // Windows Outgoing ≈ secure client SPP; FiAssistant uses insecure — try both.
        val makers = listOf(
            "secure-spp" to { device.createRfcommSocketToServiceRecord(sppUuid) },
            "insecure-spp" to { device.createInsecureRfcommSocketToServiceRecord(sppUuid) },
        )
        var last: Exception? = null
        var connected: BluetoothSocket? = null
        for ((label, make) in makers) {
            var candidate: BluetoothSocket? = null
            try {
                candidate = make()
                adapter.cancelDiscovery()
                SystemClock.sleep(200)
                Log.e(tag, "COM-mock open $label → $address (57600 equiv)")
                candidate.connect()
                socketPath = label
                connected = candidate
                Log.e(tag, "COM-mock connected via $label")
                SystemClock.sleep(300)
                break
            } catch (error: Exception) {
                Log.w(tag, "COM-mock $label failed: ${error.message}")
                last = error
                try {
                    candidate?.close()
                } catch (_: IOException) {
                }
                SystemClock.sleep(500)
            }
        }
        val next = connected ?: throw IOException(
            "T12 Bluetooth open failed (like COM CreateFile). Re-pair T12_055, " +
                "power-cycle TX, retry. (${last?.message ?: "no detail"})",
        )

        input = next.inputStream
        output = next.outputStream
        socket = next
        connectedAddress = address
        startReader()
        // Brief settle like Windows after CreateFile — Dart sends GCS HB next.
        SystemClock.sleep(200)
        Log.e(tag, "COM-mock ready path=$socketPath RX=${bytesRead.get()}")
    }

    /** Like Windows resilient BT write: a few retries. */
    private fun writeResilient(data: ByteArray) {
        val out = output ?: throw IOException("Bluetooth is not connected.")
        var offset = 0
        var attempt = 0
        while (offset < data.size && attempt < 4) {
            try {
                out.write(data, offset, data.size - offset)
                out.flush()
                bytesWritten.addAndGet((data.size - offset).toLong())
                Log.i(tag, "SPP write +${data.size - offset} (total ${bytesWritten.get()})")
                return
            } catch (error: IOException) {
                attempt++
                lastWriteError = error.message
                if (attempt >= 4) {
                    throw error
                }
                SystemClock.sleep(50L * attempt)
            }
        }
    }

    private fun startReader() {
        val stream = input ?: throw IOException("Bluetooth input missing.")
        reader = Thread({
            val buffer = ByteArray(2048)
            try {
                while (!Thread.currentThread().isInterrupted) {
                    val count = stream.read(buffer)
                    if (count < 0) {
                        break
                    }
                    if (count == 0) {
                        continue
                    }
                    val copy = buffer.copyOf(count)
                    val total = bytesRead.addAndGet(count.toLong())
                    Log.i(tag, "SPP read +$count (total $total)")
                    enqueue(copy)
                }
            } catch (error: IOException) {
                Log.i(tag, "SPP reader IO: ${error.message}")
            }
            Log.i(tag, "SPP reader stopped (total ${bytesRead.get()})")
        }, "bt-spp-read")
        reader?.start()
    }

    private fun enqueue(chunk: ByteArray) {
        synchronized(queueLock) {
            while (queuedBytes + chunk.size > maxPendingBytes && queue.isNotEmpty()) {
                val dropped = queue.removeFirst()
                queuedBytes -= dropped.size
            }
            if (queuedBytes + chunk.size <= maxPendingBytes) {
                queue.addLast(chunk)
                queuedBytes += chunk.size
            }
        }
        main.post {
            val sink = events
            if (sink != null) {
                val drained = drainQueue()
                if (drained.isNotEmpty()) {
                    sink.success(drained)
                }
            }
        }
    }

    private fun drainQueue(): ByteArray {
        synchronized(queueLock) {
            if (queue.isEmpty()) {
                return ByteArray(0)
            }
            val total = queuedBytes
            val out = ByteArray(total)
            var offset = 0
            while (queue.isNotEmpty()) {
                val part = queue.removeFirst()
                System.arraycopy(part, 0, out, offset, part.size)
                offset += part.size
            }
            queuedBytes = 0
            return out
        }
    }

    private fun statsMap(): Map<String, Any?> = mapOf(
        "address" to connectedAddress,
        "connected" to (socket != null),
        "socketPath" to socketPath,
        "baudHint" to 57600,
        "bytesRead" to bytesRead.get(),
        "bytesWritten" to bytesWritten.get(),
        "writeErrors" to writeErrors.get(),
        "lastWriteError" to lastWriteError,
        "queuedBytes" to synchronized(queueLock) { queuedBytes },
        "hasEventSink" to (events != null),
    )

    private fun closeSocket() {
        reader?.interrupt()
        reader = null
        try {
            input?.close()
        } catch (_: IOException) {
        }
        try {
            output?.close()
        } catch (_: IOException) {
        }
        try {
            socket?.close()
        } catch (_: IOException) {
        }
        input = null
        output = null
        socket = null
        connectedAddress = null
        synchronized(queueLock) {
            queue.clear()
            queuedBytes = 0
        }
    }

    private fun adapter(): BluetoothAdapter? {
        val manager = activity.getSystemService(BluetoothManager::class.java)
        return manager?.adapter
    }

    private fun hasConnectPermission(): Boolean = missingPermissions().isEmpty()

    private fun missingPermissions(): Array<String> {
        if (Build.VERSION.SDK_INT < 31) {
            return emptyArray()
        }
        val needed = ArrayList<String>()
        if (activity.checkSelfPermission(Manifest.permission.BLUETOOTH_CONNECT) !=
            PackageManager.PERMISSION_GRANTED
        ) {
            needed.add(Manifest.permission.BLUETOOTH_CONNECT)
        }
        if (activity.checkSelfPermission(Manifest.permission.BLUETOOTH_SCAN) !=
            PackageManager.PERMISSION_GRANTED
        ) {
            needed.add(Manifest.permission.BLUETOOTH_SCAN)
        }
        return needed.toTypedArray()
    }

    companion object {
        private const val tag = "FcBluetoothSpp"
        private val sppUuid: UUID = UUID.fromString("00001101-0000-1000-8000-00805F9B34FB")
        private const val maxPendingBytes = 256 * 1024

        @Suppress("UNCHECKED_CAST")
        private fun readByteArgument(call: MethodCall, key: String): ByteArray? {
            val raw = call.argument<Any>(key) ?: return null
            return when (raw) {
                is ByteArray -> raw
                is List<*> -> ByteArray(raw.size) { index ->
                    (raw[index] as Number).toInt().toByte()
                }
                else -> null
            }
        }
    }
}
