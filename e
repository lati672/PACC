[33mcommit 87ac0baf42d993c796a05fb60b4cc133c7381955[m[33m ([m[1;36mHEAD -> [m[1;32mmaster[m[33m)[m
Author: Thring <1297091773@qq.com>
Date:   Tue Mar 22 12:18:46 2022 +0800

    pubspec.yaml changed

[33mcommit f5080f3dd6f868063056a3b27c2a350de11a3672[m
Author: Thring <1297091773@qq.com>
Date:   Tue Mar 22 12:03:25 2022 +0800

    把mainactivity改了

[33mcommit 6f15d83e81730ea1e15578634c3468db528428fc[m
Author: Thring <1297091773@qq.com>
Date:   Tue Mar 22 11:53:44 2022 +0800

    整合了一下

[33mcommit 3213d32fd43198fd8bc81400aa1369603c8af2fb[m
Author: Thring <1297091773@qq.com>
Date:   Mon Mar 21 20:52:25 2022 +0800

    完善了studentchatpage的friend相关，数据库里的FriendCollection现已经可用

[33mcommit 2457aa48baa65d4a9fbd3fb6927158ac24c093bd[m
Author: Thring <1297091773@qq.com>
Date:   Sun Mar 20 16:19:04 2022 +0800

    对confirm类型做了扩充、和基本的显示；接下来要做的事：对双方添加好有前的行为进行限制，以及添加拒绝接收好友的提示；可选：在数据库里新增好友的collection

[33mcommit d8197227c191e5bb608e11249fce0744888ad2d0[m
Author: Thring <1297091773@qq.com>
Date:   Sat Mar 19 19:48:55 2022 +0800

    删掉了addwhitelist和checkwhitelist的一些alert，因为这可能带来一些错误。新增消息类型confirm，用于好友验证

[33mcommit 7bedc32b604e72fc0b915e69f57fa3c30df5e871[m
Author: Thring <1297091773@qq.com>
Date:   Thu Mar 17 14:51:23 2022 +0800

    把家长和学生的聊天界面切分开了；将聊天界面的英文timeago转成中文；数据库新增方法，可以通过某个人的id获取到他最新的whitelist，但是还没有加身份判定，如果设置只有家长才能向学生发送白名单那么这个问题就没有；新增数据库索引

[33mcommit bf16644cd6d14205f5be3edf4a0355e3aa958c54[m
Author: Thring <1297091773@qq.com>
Date:   Tue Mar 15 21:07:57 2022 +0800

    家长端学生端进一步分割，强化身份；家长学生对白名单分别显示、操作；加入了用户界面

[33mcommit 5b29c391ad7415efd54e047a927f456f6f2f2627[m
Author: Thring <1297091773@qq.com>
Date:   Sun Mar 13 19:26:01 2022 +0800

    新增了聊天界面的发送图像功能；修正了mainactivity里存在的如果用户未选择照片返回null带来的问题；修改了chatpage的变量命名，并整合了函数；实现了数据库里对白名单的按时间倒叙的查询，和对用户身份的查询，方便以后为家长学生分割做准备

[33mcommit c346b08b58e1f5155c1cb612a9c6130aaae729e8[m
Author: Thring <1297091773@qq.com>
Date:   Sat Mar 12 20:48:26 2022 +0800

    新增了addfriendbyName方法，允许通过用户名的方式添加好友;添加了对已经存在的聊天做的判别

[33mcommit 5487a611228372a037ccd10d87d98f4755e2d758[m
Author: Thring <1297091773@qq.com>
Date:   Fri Mar 11 19:50:09 2022 +0800

    允许用户使用默认头像注册；提供家长审批白名单；家长和学生不同样式显示白名单，将身份作为参数传入checkwhitelist_page

[33mcommit 99b9a854c0621ff3a802f4d845e5a4e24d016199[m
Author: Thring <1297091773@qq.com>
Date:   Tue Mar 8 14:43:13 2022 +0800

    git test
