---
title: 3D 坦克手游自瞄挂开发
date: 2024-04-11 00:59:20
tags: [Android, Xposed, Frida]
categories: [技术]
excerpt: "没想到自己也有一天能给玩的游戏写挂"
thumbnail: "https://testingcf.jsdelivr.net/gh/hexrotor/hexrotor.github.io/images/post_imgs/tohack_cover.jpg"
---

3D 坦克是一个多人在线游戏，玩家操作自己的坦克进行杀敌、拔旗、站点等活动，整个游戏偏科幻类型

某日突然发现其手游的客户端居然没有任何防护，故心血来潮就想试试能不能做出大名鼎鼎的自瞄挂，过程比较曲折，但是结果却有惊喜。

### 前置信息介绍

在该游戏中，所谓的自瞄指的是长时间瞄准类炮塔的锁定功能，而不是仿真坦克游戏那种摆角度。比如有个炮叫火箭炮，在瞄准锁定敌人一定时间后，它可以发射出一长串追踪火箭，伤害非常可观。但是其瞄准锁定的过程往往会因为敌人的走位或者队友的阻挡被中断。其具体效果可以查看[该视频](https://www.bilibili.com/video/BV1Zs411E7h7/?share_source=copy_web&vd_source=f225f0bc3ad1daf1caa03ae6fde71bfe&t=186)3分6秒处。

为了打破这个限制，曾经国外有很多大佬开发过自瞄挂，使该炮的瞄准不会中断，瞄一下就能稳定地发射出火箭。

### 寻找关键函数

因为是 Android 端所以理所当然地使用 Frida 和 Xposed 这两个工具。Frida 进行 debug，然后移植到 Xposed。

进入游戏，先随便点点。可以很明显地看出来，这个游戏的界面用是 Android 控件，因为有那种很明显的Android 点击动画

![](https://testingcf.jsdelivr.net/gh/hexrotor/hexrotor.github.io/images/post_imgs/tohack_store.webp)

使用布局查看工具也能证实这个猜想

布局查看工具：GKD [https://gkd.li/guide/](https://gkd.li/guide/)

在该应用的高级模式中打开悬浮窗服务，手动保存当前游戏 Activity 快照

然后在 Web 端查看布局抓取结果：

![](https://testingcf.jsdelivr.net/gh/hexrotor/hexrotor.github.io/images/post_imgs/tohack_gkd.png)

游戏战斗界面有瞄准 button，抓取得到其 id 为 `right_shot_button`，随后可以在 jadx 中搜索该关键词

![](https://testingcf.jsdelivr.net/gh/hexrotor/hexrotor.github.io/images/post_imgs/tohack_jadx1.png)

定位到相关代码后，进行简单交叉引用查找，可以发现很多调用都是在 alternativa 包里面。已知火箭炮的英文名为 Striker，jadx 中直接搜索，可以发现很多 alternativa 的用例，看来该包大概率是游戏逻辑处理部分

![](https://testingcf.jsdelivr.net/gh/hexrotor/hexrotor.github.io/images/post_imgs/tohack_jadx_striker.png)

最终也是经过一番翻找，发现相关的逻辑处理就在 `lockTarget` 函数中

```java
alternativa.tanks.battle.weapons.types.striker.components;

@Override // alternativa.tanks.battle.weapons.aiming.AimingWeapon
    public boolean lockTarget(@NotNull LockResult lockResult, @Nullable Long l) {
        StrikerTargetingSystem strikerTargetingSystem;
        Intrinsics.checkNotNullParameter(lockResult, "lockResult");
        GunParamsCalculator gunParamsCalculator = this.gunParamsCalculator;
        if (gunParamsCalculator == null) {
            Intrinsics.throwUninitializedPropertyAccessException("gunParamsCalculator");
            gunParamsCalculator = null;
        }
        GlobalGunParams laserParams = gunParamsCalculator.getLaserParams();
        StrikerTargetingSystem strikerTargetingSystem2 = this.targetingSystem;
        if (strikerTargetingSystem2 == null) {
            Intrinsics.throwUninitializedPropertyAccessException("targetingSystem");
            strikerTargetingSystem2 = null;
        }
        strikerTargetingSystem2.setPreferredTarget(getPreferredTarget(l));
        StrikerTargetingSystem strikerTargetingSystem3 = this.targetingSystem;
        if (strikerTargetingSystem3 == null) {
            Intrinsics.throwUninitializedPropertyAccessException("targetingSystem");
            strikerTargetingSystem = null;
        } else {
            strikerTargetingSystem = strikerTargetingSystem3;
        }
        TargetingSystem.DefaultImpls.target$default(strikerTargetingSystem, laserParams, targetingResult, false, 4, null);
        StrikerTargetingSystem strikerTargetingSystem4 = this.targetingSystem;
        if (strikerTargetingSystem4 == null) {
            Intrinsics.throwUninitializedPropertyAccessException("targetingSystem");
            strikerTargetingSystem4 = null;
        }
        strikerTargetingSystem4.setPreferredTarget(null);
        if (targetingResult.hasTargetHit()) {
            RayHit singleHit = targetingResult.getSingleHit();
            Object data = singleHit.getShape().getBody().getData();
            if (data == null) {
                throw new NullPointerException("null cannot be cast to non-null type alternativa.tanks.entity.BattleEntity");
            }
            BattleEntity battleEntity = (BattleEntity) data;
            long id = ((TankComponent) battleEntity.getComponent(Reflection.getOrCreateKotlinClass(TankComponent.class))).getId();
            if ((l == null || l.longValue() == id) && isActiveTank(battleEntity) && !BattleUtilsKt.isSameTeam(TankComponentKt.getTeamType(getEntity()), TankComponentKt.getTeamType(battleEntity))) {
                BattleUtilsKt.globalToLocal(singleHit.getShape().getBody(), singleHit.getPosition(), localLockPoint);
                lockResult.update(id, singleHit.getPosition(), localLockPoint);
                this.lockingTargetUpdateMessage.init(battleEntity, targetingResult.getDirection(), lockResult);
                getEntity().send(this.lockingTargetUpdateMessage);
                return true;
            }
            return false;
        }
        if (this.stateLogic instanceof RegainLockState) {
            this.lockingRegainUpdateMessage.getDirection().init(targetingResult.getDirection());
            getEntity().send(this.lockingRegainUpdateMessage);
        }
        return false;
    }

```

### 配合 Frida 分析

```javascript
let StrikerWeapon = Java.use("alternativa.tanks.battle.weapons.types.striker.components.StrikerWeapon");
StrikerWeapon["lockTarget"].implementation = function (lockResult, l) {
    console.log(`StrikerWeapon.lockTarget is called: lockResult=${lockResult}, l=${l}`);
    let result = this["lockTarget"](lockResult, l);
    console.log(`StrikerWeapon.lockTarget result=${result}`);
    return result;
};
```

![](https://testingcf.jsdelivr.net/gh/hexrotor/hexrotor.github.io/images/post_imgs/tohack_frida_log.webp)

通过分析得知，该函数传入的 lockResult 是上一次扫描的目标对象，`l` 传入的是目前的瞄准对象 ID ，如果没有对象就是 `null` ，返回 `true` 则允许继续瞄准充能，返回 `false` 则不允许瞄准充能

所以我一开始直接 hook 让该函数永远 `return true`，但实际上这会带来很大的问题。首先如果返回永真，那么无瞄准对象时，也会进行瞄准充能。而且这个函数只会在上一次返回了 false 的情况下更新瞄准对象，如果返回永真，那么瞄准对象永远不会更新，也就是永远为 null。瞄准完成后程序会调用一个 shootGuidedRocket 函数来创建追踪火箭，如果没有瞄准对象，就没有对应的坐标值用于创建追踪火箭。

效果就如图中，有开火动画，但是没有火箭飞出

![](https://testingcf.jsdelivr.net/gh/hexrotor/hexrotor.github.io/images/post_imgs/tohack_no_rocket.webp)

经过一番思索后我将其设置为 `return result || l!=null`

也就是一旦传入的ID有效就返回true，但这也会有小问题：瞄准过程中目标如果死了，仍然会继续充能，因为目标死了，ID并不会失效，目标死了但是你依旧发射了火箭，很容易被人看出来开挂，这不是我想要的

并且这种方式每次瞄准都需要敌人露头，实际上体验不佳

![](https://testingcf.jsdelivr.net/gh/hexrotor/hexrotor.github.io/images/post_imgs/tohack_no_interrapt.webp)

为了解决目标死亡后继续充能的问题，我主动调用了游戏内部的 `isValidTarget` 函数进行 ID 对象解析，并且解析的是上一次的瞄准结果，只要上一次的瞄准结果的对象依旧有效，就使其 `return true`。

```java
// 用于检测 Target 是否有效的函数，目标死亡、不存在都会返回 false
public boolean isValidTarget(long j) { 
    GameMode gameMode = this.gameMode;
    if (gameMode == null) { 
        Intrinsics.throwUninitializedPropertyAccessException("gameMode");
        gameMode = null;
    }
    BattleEntity tank = gameMode.getTanksOnField().getTank(j);
    if (tank == null) {
        return false;
    }
    return isActiveTank(tank); } 
```

Frida Script：

```javascript
StrikerWeapon["lockTarget"].implementation = function (lockResult, l) {
    let result = this["lockTarget"](lockResult, l);
    // console.log("============================");
    // console.log(`StrikerWeapon.lockTarget result=${result}`);
    //console.log(`StrikerWeapon.lockTarget is called: lockResult=${lockResult}, l=${l}, result: ${l!=null}`);
    //console.log("lockResult.getTargetId: ", lockResult.getTargetId());
    //console.log("vaild: ", this["isValidTarget"](parseInt(lockResult.getTargetId())));
    return this["isValidTarget"](parseInt(lockResult.getTargetId())) || result;
    //return result || (l!=null);
};
```

这样既避免了目标死亡后继续瞄准，又能实现瞄准记忆功能，在这种修改下，瞄准的结果不会丢失，使得我可以在任意位置进行瞄准，当然了打不打得到是另一回事

![](https://testingcf.jsdelivr.net/gh/hexrotor/hexrotor.github.io/images/post_imgs/tohack_no_lose.webp)

但遗憾的是，服务器端似乎有外挂检测，检测逻辑不清楚，有可能是瞄准过程有遮挡或者没对准，然后发射出去就只有第一发有伤害，这样的话这个挂局限性就很大了，甚至可以说是反向优化。

但是，我突然想起来还有一个炮：



这个炮塔向天上发射导弹，并且只要求一开始能瞄到人，瞄准过程无视掩体，只要求对准目标

虽然这个炮原版的瞄准逻辑就很强了，但是还是需要敌人和我同时露头，敌人不露头我就没法瞄，我一露头就有被打的风险，所以还是有优化空间

![](https://testingcf.jsdelivr.net/gh/hexrotor/hexrotor.github.io/images/post_imgs/tohack_scop.webp)

经过查看发现这个炮的瞄准函数都是继承的同一套 `lockTarget`，所以直接套上去就能用

```javascript
let ScorpioWeapon = Java.use("alternativa.tanks.battle.weapons.types.scorpio.components.ScorpioWeapon");
ScorpioWeapon["lockTarget"].implementation = function (lockResult, l) {
    // console.log("============================");
    // console.log(`ScorpioWeapon.lockTarget is called: lockResult=${lockResult}, l=${l}, result: ${l!=null}`);

    let result = this["lockTarget"](lockResult, l);
    console.log("lockResult.getTargetId: ", lockResult.getTargetId());
    console.log("vaild: ", this["isValidTarget"](parseInt(lockResult.getTargetId())));
    //backtrace
    //console.log(Java.use("android.util.Log").getStackTraceString(Java.use("java.lang.Exception").$new()));
    //console.log(`ScorpioWeapon.lockTarget result=${result}`);
    return result || this["isValidTarget"](parseInt(lockResult.getTargetId()));
    //return result || (l!=null) ;
};
```

然后使用效果就变成了：只要瞄过一次就能在任何地方重新瞄，无视任何掩体，只要求能对准就行

![](https://testingcf.jsdelivr.net/gh/hexrotor/hexrotor.github.io/images/post_imgs/tohack_scop_no_inter.webp)

由于这个炮的导弹向上飞，我只要选定一个合适的距离，导弹就可以跨过掩体打中，简直太超模了

### 移植 Xposed

剩下的任务就是将 Frida 代码转化为 Xposed 模块，代码编写思路和 Frida 基本一致，只是换成了 Xposed API，另外要写个简单的 Activity 来控制模块的功能开关，完整代码在我Github，有兴趣可以自己查阅。

最后重要提示，外挂是一种破坏游戏平衡、影响玩家体验的行为，本文仅用于技术交流，请不要使用外挂在公开战场进行游戏，否则后果自负