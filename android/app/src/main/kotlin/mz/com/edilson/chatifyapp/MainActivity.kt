package mz.com.edilson.chatifyapp
import android.app.AppOpsManager
import android.app.usage.UsageStatsManager
import android.bluetooth.BluetoothAdapter
import android.content.Context
import android.content.Intent
import android.graphics.drawable.Drawable
import android.os.Build
import android.os.Process
import android.provider.Settings
import android.util.Log
import android.widget.Toast
import androidx.annotation.RequiresApi
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.GeneratedPluginRegistrant
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodCall

class MainActivity : FlutterActivity() {
    @RequiresApi(api = Build.VERSION_CODES.LOLLIPOP)
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call: MethodCall, result: MethodChannel.Result ->
                //与Flutter Client invokeMethod调用字符串标识符匹配
                if (call.method == "getAppList") {
                    // 当前不是番茄钟应用，则跳转番茄钟应用
                    val list = btn1Click()
                    // if(getTopApp(this.getActivity()) != "com.example.chatifyapp")
                    // getTopApp(this.getActivity())
                        launch()
                    result.success(list)
                } 
                else if (call.method == "launch") {
                    launch()
                }
                else if (call.method == "appLock") {
                    // launch()
                }
                else {
                    result.notImplemented()
                }
            }
    }

    // 开启蓝牙
    private fun initBlueTooth(): Boolean {
        val mBluetoothAdapter = BluetoothAdapter.getDefaultAdapter() ?: return false
        if (!mBluetoothAdapter.isEnabled) {
            val intent = Intent(BluetoothAdapter.ACTION_REQUEST_ENABLE)
            startActivityForResult(intent, REQUEST_ENABLE_BT)
            return false
        }
        return true
    }

    // 获取应用程序包名
    //因为我的手机是华为手机所以过滤掉了华为，大家可以按需求过滤
    val appProcessName: Unit
        get() {
            //当前应用pid
            val packageManager = packageManager
            val mainIntent = Intent(Intent.ACTION_MAIN, null)
            mainIntent.addCategory(Intent.CATEGORY_LAUNCHER)
            // get all apps
            val apps = packageManager.queryIntentActivities(mainIntent, 0)
            for (i in apps.indices) {
                val name = apps[i].activityInfo.packageName
                // Log.i("TAG", "getAppProcessName: "+apps.get(i).activityInfo);
                if(!name.contains("huawei")&&!name.contains("android")){
                    Log.i("TAG", "getAppProcessName: "+apps.get(i).activityInfo.packageName);
                }
            }
        }

    // 获取已安装的应用的真实名称
    fun btn1Click(): String {
//        String list = new LinkedList<>();
        var list = ""
        val appIcon: Drawable? = null
        val manager = this.packageManager
        val pkgList = manager.getInstalledPackages(0)
        for (i in pkgList.indices) {
            val pI = pkgList[i]
            val name = pI.applicationInfo.loadLabel(manager).toString()
            if(!name.contains("huawei")&&!name.contains("android")){
                list += name + "/n"
            }
            //            list.add(pI.applicationInfo.loadLabel(manager).toString());
//            appIcon=pI.applicationInfo.loadIcon(manager);
//            Log.i("TAG", "getAppProcessName: "+appIcon);
        }
        //        Log.i("TAG", "getAppProcessName: "+str);
        return list
    }

    // 跳转其他APP
    private fun launch() {
        Log.i("TAG", "getAppProcessName: "+"1234567891234567");
        //val intent = packageManager.getLaunchIntentForPackage("com.taobao.taobao")
        // val intent = packageManager.getLaunchIntentForPackage("com.example.chatifyapp")
        // 这里如果intent为空，就说名没有安装要跳转的应用嘛
        if (intent != null) {
            Log.i("TAG", "getAppProcessName: "+"123456789123456789123456789123456789123456789123456789");
            // 这里跟Activity传递参数一样的嘛，不要担心怎么传递参数，还有接收参数也是跟Activity和Activity传参数一样
            intent.putExtra("name", "liangchaojie")
            intent.putExtra("birthday", "1994-06-18")
            startActivity(intent)
        } else {
            // 没有安装要跳转的app应用，提醒一下
            Toast.makeText(applicationContext, "未安装此应用", Toast.LENGTH_LONG).show()
        }
    }
    //检测用户是否对本app开启了“Apps with usage access”权限
    @RequiresApi(api = Build.VERSION_CODES.KITKAT)
    fun hasPermission(): Boolean {
        val appOps = getSystemService(APP_OPS_SERVICE) as AppOpsManager
        var mode = 0
        if (Build.VERSION.SDK_INT > Build.VERSION_CODES.KITKAT) {
            mode = appOps.checkOpNoThrow(
                AppOpsManager.OPSTR_GET_USAGE_STATS,
                Process.myUid(), packageName
            )
        }
        return mode == AppOpsManager.MODE_ALLOWED
    }
    // @RequiresApi(api = Build.VERSION_CODES.KITKAT)
    // public override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
    //     super.onActivityResult(requestCode, resultCode, data);
    //     if (requestCode == MY_PERMISSIONS_REQUEST_PACKAGE_USAGE_STATS) {
    //         Log.i("TAG", "top running app is : " + hasPermission())
    //         if (!hasPermission()) {
    //             //若用户未开启权限，则引导用户开启“Apps with usage access”权限
    //             startActivityForResult(
    //                 Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS),
    //                 MY_PERMISSIONS_REQUEST_PACKAGE_USAGE_STATS
    //             )
    //         }
    //     }
    // }

    private fun getTopApp(context: Context):String {
        var topActivity = ""
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            //若用户未开启权限，则引导用户开启“Apps with usage access”权限
            if (!hasPermission()) {
                startActivityForResult(
                        Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS),
                        MY_PERMISSIONS_REQUEST_PACKAGE_USAGE_STATS);
            }
            val m = context.getSystemService(USAGE_STATS_SERVICE) as UsageStatsManager
            if (m != null) {
                val now = System.currentTimeMillis()
                //获取10分钟之内的应用数据
                val stats =
                    m.queryUsageStats(UsageStatsManager.INTERVAL_BEST, now - 600 * 1000, now)
                Log.i("TAG", "Running app number in last 10 minutes : " + stats!!.size)
                //取得最近运行的一个app，即当前运行的app
                if (stats != null && !stats.isEmpty()) {
                    var j = 0
                    for (i in stats.indices) {
                        if (stats[i].lastTimeUsed > stats[j].lastTimeUsed) {
                            j = i
                        }
                    }
                    topActivity = stats[j].packageName
                }
                Log.i("TAG", "top running app is : $topActivity")
            }
        }
        return topActivity
    }

    companion object {
        private const val CHANNEL = "samples.flutter.dev"

        //与Flutter Client端写一致的方法
        private const val REQUEST_ENABLE_BT = 1

        //引导用户开启权限
        private const val MY_PERMISSIONS_REQUEST_PACKAGE_USAGE_STATS = 1101
    }
}