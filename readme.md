大连理工大学相关校园网站信息的抓取，swift 4 编写，使用了 PromiseKit 进行异步调用，以及 Fuzi 解析 HTML。

# 可以抓到的信息

- 历年课程表
- 本学期考试安排（未抓好）
- 本学期成绩
- 玉兰卡及网络支付账户余额
- 校园网各种信息

# 抓取的网站

- [教务处][teach]（校园网访问）

- [旧版校园门户][old_portal]（外网可访问）

- [新版校园门户][new_portal]（外网可访问）

- [校园网][net]（校园网访问）


# 账户和密码

- 学号

    9位数的学号，只试过本科生的

- 教务处密码

    默认是身份证号后6位，就是选课时用的那个密码

- 校园门户密码

    默认也是身份证号后6位

# 使用方法

因为异步再加上 swift 的 KVO 还不大会用，都是用委托传值，可以看 ViewController 中的使用

[teach]: http://zhjw.dlut.edu.cn
[old_portal]: http://portal.dlut.edu.cn
[new_portal]: http://one.dlut.edu.cn
[net]: http://tulip.dlut.edu.cn