package mz.com.edilson.chatifyapp
import android.annotation.SuppressLint
import android.app.ActivityManager
import android.app.AppOpsManager
import android.app.usage.UsageStatsManager
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
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant


class MainActivity : FlutterActivity() {
    @RequiresApi(api = Build.VERSION_CODES.LOLLIPOP)
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call: MethodCall, result: MethodChannel.Result ->
                //与Flutter Client invokeMethod调用字符串标识符匹配
                if (call.method == "getAppList") {
                    val list = getAppName()
                    result.success(list)
                } 
                else if (call.method == "isOpenUsageAccess") {
                    result.success(hasPermission())
                }
                else if (call.method == "openUsageAccess") {
                    openUsageAccess()
                }
                else if (call.method == "appLock") {
                    // 当前不是番茄钟应用，则跳转番茄钟应用
                    Log.i("TAG", "getAppProcessName: "+getTopApp(this.getActivity()))
                    if(getTopApp(this.getActivity()) != "com.example.chatifyapp")
                    {
                        launch()
                    }
                }
                else {
                    result.notImplemented()
                }
            }
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
    fun getAppName(): String {
//        String list = new LinkedList<>();
        var list = ""
        val appIcon: Drawable? = null
        val manager = this.packageManager
        val pkgList = manager.getInstalledPackages(0)
        for (i in pkgList.indices) {
            val pI = pkgList[i]
            val name = pI.applicationInfo.loadLabel(manager).toString()
            val packageName = pI.applicationInfo.packageName;
            if(!name.contains("huawei")&&!name.contains("android")){
                list += name + '+' + packageName + "/n"
            }
            //            list.add(pI.applicationInfo.loadLabel(manager).toString());
//            appIcon=pI.applicationInfo.loadIcon(manager);
//            Log.i("TAG", "getAppProcessName: "+appIcon);
        }
        //        Log.i("TAG", "getAppProcessName: "+str);
        return list
    }

    // 跳转其他APP
    @SuppressLint("MissingPermission")
    private fun launch() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {

//            val intent = Intent("android.intent.action.MAIN")
//            intent.component = ComponentName(applicationContext.packageName, MainActivity::class.java.name)
//            intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
//            applicationContext.startActivity(intent)
//        val intent = packageManager.getLaunchIntentForPackage("com.taobao.taobao")
//            val intent = packageManager.getLaunchIntentForPackage("com.example.chatifyapp")
            val activityManager = context.getSystemService(ACTIVITY_SERVICE) as ActivityManager
//            val activityManager = context.getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
            /**获得当前运行的task(任务) */
            val taskInfoList = activityManager.getRunningTasks(100)
            for (taskInfo in taskInfoList) {
                /**找到本应用的 task，并将它切换到前台 */
                if (taskInfo.topActivity!!.packageName == context.packageName) {
                    Log.i("TAG", "getAppProcessName: 11111111111111111111111111111111111111");
                    activityManager.moveTaskToFront(taskInfo.id, 0)
                    break
                }
            }

//            // 这里如果intent为空，就说明没有安装要跳转的应用
//            if (intent != null) {
//                // 这里跟Activity传递参数一样的嘛，不要担心怎么传递参数，还有接收参数也是跟Activity和Activity传参数一样
//                intent.putExtra("name", "liangchaojie")
//                intent.putExtra("birthday", "1994-06-18")
////                intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
//                startActivity(intent)
//            } else {
//                // 没有安装要跳转的app应用，提醒一下
//                Toast.makeText(applicationContext, "未安装此应用", Toast.LENGTH_LONG).show()
//            }
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
    
    //若用户未开启权限，则引导用户开启“Apps with usage access”权限
    private fun openUsageAccess() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            if (!hasPermission()) {
                startActivityForResult(
                        Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS),
                        MY_PERMISSIONS_REQUEST_PACKAGE_USAGE_STATS);
            }
        }
    }

    private fun getTopApp(context: Context):String {
        var topActivity = ""
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
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