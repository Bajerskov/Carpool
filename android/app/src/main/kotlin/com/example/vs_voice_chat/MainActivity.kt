package com.example.vs_voice_chat

import android.content.Context
import android.media.AudioAttributes
import android.media.AudioFocusRequest
import android.media.AudioManager
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {

    private val CHANNEL = "samples.flutter.dev/bluetooth"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->

            if(call.method == "bluetooth") {
                result.success(switchBluetooth())
            }
            
        }
    }

    val afChangeListener = AudioManager.OnAudioFocusChangeListener() {
         fun onAudioFocusChange(focusChange:Int) : Void? {
            if (focusChange == AudioManager.AUDIOFOCUS_GAIN) {
                 val audioManager = getSystemService(Context.AUDIO_SERVICE) as AudioManager
                audioManager.setMode(AudioManager.MODE_IN_COMMUNICATION);
            }
            return null
        }
    } as AudioManager.OnAudioFocusChangeListener

    private fun audioRequest() :AudioFocusRequest? {
        val request : AudioFocusRequest
        val audioAttributes : AudioAttributes
        if(android.os.Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            audioAttributes = AudioAttributes.Builder().setUsage(AudioAttributes.USAGE_VOICE_COMMUNICATION).build() as AudioAttributes
            request = AudioFocusRequest.Builder(AudioManager.AUDIOFOCUS_GAIN_TRANSIENT)
                    .setWillPauseWhenDucked(true).setAudioAttributes(audioAttributes)
                    .setAcceptsDelayedFocusGain(true)
                    .setOnAudioFocusChangeListener(afChangeListener)
                    .build()
            return request
        }
      return null
    }

    private fun switchBluetooth(): Int {

        val audioManager = getSystemService(Context.AUDIO_SERVICE) as AudioManager

        audioManager.mode = AudioManager.MODE_IN_COMMUNICATION
        audioManager.startBluetoothSco()

        print("isBluetoothSCOavilable")
        print(audioManager.isBluetoothScoAvailableOffCall)
        print("isBluetoth on")
        println(audioManager.isBluetoothScoOn)
        println(audioManager.getDevices(AudioManager.GET_DEVICES_INPUTS))

        var request: AudioFocusRequest? = null
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            request = audioRequest()
            audioManager.requestAudioFocus(request!!)
        } else {
            // Request audio focus before making any device switch.
            audioManager.requestAudioFocus(afChangeListener, AudioManager.STREAM_VOICE_CALL, AudioManager.AUDIOFOCUS_GAIN_TRANSIENT)
        }

        return 1;
    }

}
