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
                if (call.method == "initBlueTooth") {
                    val isEnabled = initBlueTooth()
                    //                                getAppProcessName();
                    val list = btn1Click()
                    //                                Log.i("TAG", "getAppProcessName: "+str);
//                                UsageStatsManagerFun();
//                                canUsageStats();
//                                startActivityForResult(new Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS),809);
                    // getTopApp(this.getActivity());

                    //initBlueTooth为后面安卓端需要调取的方法
//                                result.success(isEnabled);
                    result.success(list)
                    //                                launch();
                } else {
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
    }//            Log.i("TAG", "getAppProcessName: "+apps.get(i).activityInfo);

    //            if(!name.contains("huawei")&&!name.contains("android")){
//                Log.i("TAG", "getAppProcessName: "+apps.get(i).activityInfo.packageName);
//            }
//当前应用pid
    // get all apps
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
                //            Log.i("TAG", "getAppProcessName: "+apps.get(i).activityInfo);
//            if(!name.contains("huawei")&&!name.contains("android")){
//                Log.i("TAG", "getAppProcessName: "+apps.get(i).activityInfo.packageName);
//            }
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
            list += pI.applicationInfo.loadLabel(manager).toString() + "/n"
            //            list.add(pI.applicationInfo.loadLabel(manager).toString());
//            appIcon=pI.applicationInfo.loadIcon(manager);
//            Log.i("TAG", "getAppProcessName: "+appIcon);
        }
        //        Log.i("TAG", "getAppProcessName: "+str);
        return list
    }

    // 跳转其他APP
    private fun launch() {
        val intent = packageManager.getLaunchIntentForPackage("com.taobao.taobao")
        // 这里如果intent为空，就说名没有安装要跳转的应用嘛
        if (intent != null) {
            // 这里跟Activity传递参数一样的嘛，不要担心怎么传递参数，还有接收参数也是跟Activity和Activity传参数一样
            intent.putExtra("name", "liangchaojie")
            intent.putExtra("birthday", "1994-06-18")
            startActivity(intent)
        } else {
            // 没有安装要跳转的app应用，提醒一下
            Toast.makeText(applicationContext, "哟，赶紧下载安装这个APP吧", Toast.LENGTH_LONG).show()
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

    @RequiresApi(api = Build.VERSION_CODES.KITKAT)
    public override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data);
        if (requestCode == MY_PERMISSIONS_REQUEST_PACKAGE_USAGE_STATS) {
            Log.i("TAG", "top running app is : " + hasPermission())
            if (!hasPermission()) {
                //若用户未开启权限，则引导用户开启“Apps with usage access”权限
                startActivityForResult(
                    Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS),
                    MY_PERMISSIONS_REQUEST_PACKAGE_USAGE_STATS
                )
            }
        }
    }

    private fun getTopApp(context: Context) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            val m = context.getSystemService(USAGE_STATS_SERVICE) as UsageStatsManager
            if (m != null) {
                val now = System.currentTimeMillis()
                //获取10分钟之内的应用数据
                val stats =
                    m.queryUsageStats(UsageStatsManager.INTERVAL_BEST, now - 600 * 1000, now)
                Log.i("TAG", "Running app number in last 10 minutes : " + stats!!.size)
                var topActivity = ""
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
    } //    //判断是否有PACKAGE_USAGE_STATS权限 (做了高低版本兼容)

    //    @RequiresApi(api = Build.VERSION_CODES.KITKAT)
    //    public static boolean canUsageStats(Context context) {
    //        AppOpsManager appOps = (AppOpsManager) context.getSystemService(Context.APP_OPS_SERVICE);
    //        int mode = 0;
    //        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.Q) {
    //            mode = appOps.unsafeCheckOpNoThrow(AppOpsManager.OPSTR_GET_USAGE_STATS, android.os.Process.myUid(), context.getPackageName());
    //        } else {
    //            mode = appOps.checkOpNoThrow(AppOpsManager.OPSTR_GET_USAGE_STATS, android.os.Process.myUid(), context.getPackageName());
    //        }
    //        if (mode == AppOpsManager.MODE_DEFAULT && Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
    //            return (context.checkCallingOrSelfPermission(Manifest.permission.PACKAGE_USAGE_STATS) == PackageManager.PERMISSION_GRANTED);
    //        } else {
    //            return (mode == AppOpsManager.MODE_ALLOWED);
    //        }
    //    }
    //    @RequiresApi(api = Build.VERSION_CODES.LOLLIPOP)
    //    public static ActivityManager.RunningAppProcessInfo getTopProcessInfo(Context context) {
    //        ActivityManager am = (ActivityManager) context.getSystemService(Context.ACTIVITY_SERVICE);
    //        List<ActivityManager.RunningAppProcessInfo> processes = am.getRunningAppProcesses();
    //        if (processes != null && processes.size() > 0) {
    //            for (ActivityManager.RunningAppProcessInfo info : processes) {
    //                if (info.importance == ActivityManager.RunningAppProcessInfo.IMPORTANCE_FOREGROUND) {
    //                    return info;
    //                }
    //            }
    //        }
    //        return null;
    //    }
    //
    //    @RequiresApi(api = Build.VERSION_CODES.LOLLIPOP_MR1)
    //    public static UsageStats getTopUsageStats(Context context) {
    //        UsageStatsManager manager = (UsageStatsManager) context.getSystemService(Context.USAGE_STATS_SERVICE);
    //        if (manager != null) {
    //            //Get the app record in the last month
    //            Calendar calendar = Calendar.getInstance();
    //            final long end = calendar.getTimeInMillis();
    //            calendar.add(Calendar.MONTH, -1);
    //            final long start = calendar.getTimeInMillis();
    //
    //            List<UsageStats> usageStats = manager.queryUsageStats(UsageStatsManager.INTERVAL_BEST, start, end);
    //            if (usageStats == null || usageStats.isEmpty()) {
    //                return null;
    //            }
    //
    //            UsageStats lastStats = null;
    //            for (UsageStats stats : usageStats) {
    //                // if from notification bar, class name will be null
    //                if (stats.getPackageName() == null) {
    //                    continue;
    //                }
    //                final long lastTime = stats.getLastTimeUsed();
    //                if (lastStats == null || lastStats.getLastTimeUsed() < lastTime) {
    //                    lastStats = stats;
    //                }
    //            }
    //            return lastStats;
    //        }
    //        return null;
    //    }
    //
    //    @RequiresApi(api = Build.VERSION_CODES.LOLLIPOP_MR1)
    //    public static String getTopProcessPackageName(Context context) {
    ////        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.LOLLIPOP_MR1) {
    //            UsageStats usageStats = getTopUsageStats(context);
    //            if (usageStats != null) {
    //                return usageStats.getPackageName();
    //            }
    ////        } else {
    ////            ActivityManager.RunningAppProcessInfo info = getTopProcessInfo(context);
    ////            if (info != null) {
    ////                return info.processName;
    ////            }
    ////        }
    //        return null;
    //    }
    //    // UsageStatsManager 应用监控类
    //    @RequiresApi(api = Build.VERSION_CODES.LOLLIPOP)
    //    public void UsageStatsManagerFun() {
    //        //没有权限需要跳转设置打开权限
    //        //如果没有权限的话UsageStatsManager是获取不到任何记录的，必须要用户打开权限
    ////        Intent intent = new Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS);
    ////        startActivity(intent);
    //        // 获取手机中正在运行的应用列表
    //        UsageStatsManager usageManager=(UsageStatsManager)getSystemService(Context.USAGE_STATS_SERVICE);
    //        if (usageManager != null) {
    //            int intervalType = UsageStatsManager.INTERVAL_BEST;
    //            long endTime = System.currentTimeMillis();
    //            long startTime = endTime - 10000;
    //
    //            List<UsageStats> applicationList = usageManager.queryUsageStats(intervalType, startTime, endTime);
    //            for (UsageStats usageStats : applicationList) {
    //
    //                Log.i("TAG", "手机中安装了test这个应用");
    //                if ("test".equals(usageStats.getPackageName())) {
    //                    System.out.println("手机中安装了test这个应用");
    //                    System.out.println("test这个应用在前台的时间 = " + usageStats.getTotalTimeInForeground());
    //                }
    //            }
    //        }
    //    }
    companion object {
        private const val CHANNEL = "samples.flutter.dev"

        //与Flutter Client端写一致的方法
        private const val REQUEST_ENABLE_BT = 1

        //引导用户开启权限
        private const val MY_PERMISSIONS_REQUEST_PACKAGE_USAGE_STATS = 1101
    }
}