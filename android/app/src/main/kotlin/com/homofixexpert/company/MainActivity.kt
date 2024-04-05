package com.homfix.homofix

import android.content.Intent
import android.os.Bundle
import com.easebuzz.flutter_kt_androidx_accesskey.JsonConverter
import com.easebuzz.payment.kit.PWECouponsActivity
import com.google.gson.Gson
import datamodels.PWEStaticDataModel
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel
import org.json.JSONObject

class MainActivity: FlutterActivity() {
    private val CHANNEL = "easebuzz"
    var channel_result: MethodChannel.Result? = null
    private var start_payment = true
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState);
        start_payment = true
        MethodChannel(flutterEngine!!.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            channel_result = result
            if (call.method == "payWithEasebuzz") {
                if (start_payment) {
                    start_payment = false
                    startPayment(call.arguments);
                }
            }
        }
    }

    private fun startPayment(arguments: Any) {
        try {
            val gson = Gson()
            val parameters = JSONObject(gson.toJson(arguments))
            val intentProceed = Intent(activity, PWECouponsActivity::class.java)
            intentProceed.flags = Intent.FLAG_ACTIVITY_REORDER_TO_FRONT;
            val keys: Iterator<*> = parameters.keys()
            while (keys.hasNext()) {
                var value: String? = ""
                val key = keys.next() as String
                value = parameters.optString(key)
                if (key == "amount") {
                    val amount: Double = parameters.optDouble("amount")
                    intentProceed.putExtra(key, amount)
                } else {
                    intentProceed.putExtra(key, value)
                }
            }
            startActivityForResult(intentProceed, PWEStaticDataModel.PWE_REQUEST_CODE)
        } catch (e: Exception) {
            start_payment = true
            val error_map: MutableMap<String, Any> = HashMap()
            val error_desc_map: MutableMap<String, Any> = HashMap()
            val error_desc = "exception occured:" + e.message
            error_desc_map["error"] = "Exception"
            error_desc_map["error_msg"] = error_desc
            error_map["result"] = PWEStaticDataModel.TXN_FAILED_CODE
            error_map["payment_response"] = error_desc_map
            channel_result!!.success(error_map)
        }
    }
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent) {
        if (data != null) {
            if (requestCode == PWEStaticDataModel.PWE_REQUEST_CODE) {
                start_payment = true
                val response = JSONObject()
                val error_map: MutableMap<String, Any> = HashMap()
                if (data != null) {
                    val result = data.getStringExtra("result")
                    val payment_response = data.getStringExtra("payment_response")
                    try {
                        val obj = JSONObject(payment_response)
                        response.put("result", result)
                        response.put("payment_response", obj)
                        channel_result!!.success(JsonConverter.convertToMap(response))
                    } catch (e: Exception) {
                        val error_desc_map: MutableMap<String, Any> = HashMap()
                        /* Used the below code For target 30 api*/
                        error_desc_map["error"] = result.toString()
                        error_desc_map["error_msg"] = payment_response.toString()
                        error_map["result"] = result.toString()
                        /* End code For target 30 api*/
                        error_map["payment_response"] = error_desc_map
                        channel_result!!.success(error_map)
                    }
                } else {
                    val error_desc_map: MutableMap<String, Any> = HashMap()
                    val error_desc = "Empty payment response"
                    error_desc_map["error"] = "Empty error"
                    error_desc_map["error_msg"] = error_desc
                    error_map["result"] = "payment_failed"
                    error_map["payment_response"] = error_desc_map
                    channel_result!!.success(error_map)
                }
            } else {
                super.onActivityResult(requestCode, resultCode, data)
            }
        }
    }
}
