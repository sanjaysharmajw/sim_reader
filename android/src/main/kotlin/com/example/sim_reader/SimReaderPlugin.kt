package com.example.sim_reader

import android.Manifest
import android.content.Context
import android.content.pm.PackageManager
import android.os.Build
import android.telephony.SubscriptionInfo
import android.telephony.SubscriptionManager
import android.telephony.TelephonyManager
import androidx.core.content.ContextCompat
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

class SimReaderPlugin: FlutterPlugin, MethodCallHandler {
  private lateinit var channel: MethodChannel
  private lateinit var context: Context

  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "sim_reader")
    channel.setMethodCallHandler(this)
    context = flutterPluginBinding.applicationContext
  }

  override fun onMethodCall(call: MethodCall, result: Result) {
    when (call.method) {
      "getSimInfo" -> getSimInfo(result)
      "getAllSimInfo" -> getAllSimInfo(result)
      "hasSimCard" -> hasSimCard(result)
      "getNetworkInfo" -> getNetworkInfo(result)
      else -> result.notImplemented()
    }
  }

  private fun hasPermissions(): Boolean {
    return ContextCompat.checkSelfPermission(context, Manifest.permission.READ_PHONE_STATE) == PackageManager.PERMISSION_GRANTED
  }

  private fun getSimInfo(result: Result) {
    if (!hasPermissions()) {
      result.error("PERMISSION_DENIED", "READ_PHONE_STATE permission required", null)
      return
    }

    try {
      val telephonyManager = context.getSystemService(Context.TELEPHONY_SERVICE) as TelephonyManager
      val simInfo = createSimInfoMap(telephonyManager, 0)
      result.success(simInfo)
    } catch (e: Exception) {
      result.error("SIM_ERROR", e.message, null)
    }
  }

  private fun getAllSimInfo(result: Result) {
    if (!hasPermissions()) {
      result.error("PERMISSION_DENIED", "READ_PHONE_STATE permission required", null)
      return
    }

    try {
      val simInfoList = mutableListOf<Map<String, Any?>>()

      if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP_MR1) {
        val subscriptionManager = context.getSystemService(Context.TELEPHONY_SUBSCRIPTION_SERVICE) as SubscriptionManager
        val subscriptions = subscriptionManager.activeSubscriptionInfoList

        subscriptions?.forEachIndexed { index, subscription ->
          val telephonyManager = context.getSystemService(Context.TELEPHONY_SERVICE) as TelephonyManager
          val simInfo = createSimInfoFromSubscription(subscription, telephonyManager, index)
          simInfoList.add(simInfo)
        }
      } else {
        // Fallback for older devices
        val telephonyManager = context.getSystemService(Context.TELEPHONY_SERVICE) as TelephonyManager
        val simInfo = createSimInfoMap(telephonyManager, 0)
        simInfoList.add(simInfo)
      }

      result.success(simInfoList)
    } catch (e: Exception) {
      result.error("SIM_ERROR", e.message, null)
    }
  }

  private fun hasSimCard(result: Result) {
    try {
      val telephonyManager = context.getSystemService(Context.TELEPHONY_SERVICE) as TelephonyManager
      val hasSimCard = telephonyManager.simState == TelephonyManager.SIM_STATE_READY
      result.success(hasSimCard)
    } catch (e: Exception) {
      result.error("SIM_ERROR", e.message, null)
    }
  }

  private fun getNetworkInfo(result: Result) {
    if (!hasPermissions()) {
      result.error("PERMISSION_DENIED", "READ_PHONE_STATE permission required", null)
      return
    }

    try {
      val telephonyManager = context.getSystemService(Context.TELEPHONY_SERVICE) as TelephonyManager
      val networkInfo = mapOf(
        "networkOperatorName" to telephonyManager.networkOperatorName,
        "networkOperator" to telephonyManager.networkOperator,
        "networkType" to getNetworkTypeName(telephonyManager.networkType),
        "isNetworkAvailable" to (telephonyManager.networkOperator.isNotEmpty()),
        "signalStrength" to null // Would require additional listener setup
      )
      result.success(networkInfo)
    } catch (e: Exception) {
      result.error("NETWORK_ERROR", e.message, null)
    }
  }

  private fun createSimInfoMap(telephonyManager: TelephonyManager, slotIndex: Int): Map<String, Any?> {
    return try {
      mapOf(
        "carrierName" to getSafeString { telephonyManager.simOperatorName },
        "countryCode" to getSafeString { telephonyManager.simCountryIso },
        "mobileCountryCode" to getMcc(getSafeString { telephonyManager.simOperator }),
        "mobileNetworkCode" to getMnc(getSafeString { telephonyManager.simOperator }),
        "phoneNumber" to getSafeString { telephonyManager.line1Number },
        "simSerialNumber" to getSafeString { telephonyManager.simSerialNumber },
        "subscriberId" to getSafeString { telephonyManager.subscriberId },
        "simSlotIndex" to slotIndex,
        "isNetworkRoaming" to (getSafeBoolean { telephonyManager.isNetworkRoaming } ?: false)
      )
    } catch (e: Exception) {
      mapOf(
        "carrierName" to null,
        "countryCode" to null,
        "mobileCountryCode" to null,
        "mobileNetworkCode" to null,
        "phoneNumber" to null,
        "simSerialNumber" to null,
        "subscriberId" to null,
        "simSlotIndex" to slotIndex,
        "isNetworkRoaming" to false
      )
    }
  }

  private fun getSafeString(block: () -> String?): String? {
    return try {
      block()?.takeIf { it.isNotEmpty() }
    } catch (e: Exception) {
      null
    }
  }

  private fun getSafeBoolean(block: () -> Boolean): Boolean? {
    return try {
      block()
    } catch (e: Exception) {
      null
    }
  }

  private fun createSimInfoFromSubscription(subscription: SubscriptionInfo, telephonyManager: TelephonyManager, slotIndex: Int): Map<String, Any?> {
    return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP_MR1) {
      mapOf(
        "carrierName" to subscription.carrierName?.toString(),
        "countryCode" to subscription.countryIso,
        "mobileCountryCode" to subscription.mcc.toString(),
        "mobileNetworkCode" to subscription.mnc.toString(),
        "phoneNumber" to subscription.number,
        "simSerialNumber" to subscription.iccId,
        "subscriberId" to null, // Not available from SubscriptionInfo
        "simSlotIndex" to subscription.simSlotIndex,
        "isNetworkRoaming" to telephonyManager.isNetworkRoaming
      )
    } else {
      createSimInfoMap(telephonyManager, slotIndex)
    }
  }

  private fun getMcc(simOperator: String?): String? {
    return if (simOperator != null && simOperator.length >= 3) simOperator.substring(0, 3) else null
  }

  private fun getMnc(simOperator: String?): String? {
    return if (simOperator != null && simOperator.length > 3) simOperator.substring(3) else null
  }

  private fun getNetworkTypeName(networkType: Int): String {
    return when (networkType) {
      TelephonyManager.NETWORK_TYPE_GPRS -> "GPRS"
      TelephonyManager.NETWORK_TYPE_EDGE -> "EDGE"
      TelephonyManager.NETWORK_TYPE_UMTS -> "UMTS"
      TelephonyManager.NETWORK_TYPE_HSDPA -> "HSDPA"
      TelephonyManager.NETWORK_TYPE_HSUPA -> "HSUPA"
      TelephonyManager.NETWORK_TYPE_HSPA -> "HSPA"
      TelephonyManager.NETWORK_TYPE_CDMA -> "CDMA"
      TelephonyManager.NETWORK_TYPE_EVDO_0 -> "EVDO_0"
      TelephonyManager.NETWORK_TYPE_EVDO_A -> "EVDO_A"
      TelephonyManager.NETWORK_TYPE_EVDO_B -> "EVDO_B"
      TelephonyManager.NETWORK_TYPE_1xRTT -> "1xRTT"
      TelephonyManager.NETWORK_TYPE_IDEN -> "IDEN"
      TelephonyManager.NETWORK_TYPE_LTE -> "LTE"
      TelephonyManager.NETWORK_TYPE_EHRPD -> "EHRPD"
      TelephonyManager.NETWORK_TYPE_HSPAP -> "HSPAP"
      else -> "UNKNOWN"
    }
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }
}