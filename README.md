KF5SDK帮助开发者快速完成开发，提供给开发者创建工单、查看工单列表、回复工单、查看和搜索知识库文档、消息通知推送、即时IM等功能。目前支持iOS7.0及以上系统(需要xcode8.0及以上)。KF5SDK2.0版现已经支持bitcode和国际化。     

为了更好的与企业的业务紧密结合，KF5SDK开源了SDK的UI界面，开发者可以根据自己的需求开发不同风格的页面，也可以使用KF5SDK提供的默认界面快速集成客服功能。     

## 一、SDK功能介绍
##### 1、帮助中心
帮助中心允许用户在您的APP查看和搜索您云客服平台上的知识库文档。    
##### 2、工单反馈    
用户可以在您的APP上反馈问题，反馈的问题您可以在云客服平台上处理，用户可在APP上查看反馈结果，并可与您进行交流。    
##### 3、即时交谈    
用户可以通过APP与客服人员实时交流，实时发送和接收文字消息、语音消息、图片、附件，并为此提供了灵活的接口。    
## 二、集成方法   
1、先下载[KF5SDK](https://codeload.github.com/KF5/KF5SDK-iOS2.0/zip/master)的官方demo。     
2、将KF5SDK下的文件拖拽到自己的工程中。       
3、添加系统库支持，添加` JavaScriptCore.framework`，` libsqlite3.tbd`到自己的工程。        
![addSystemLibraries.png](http://upload-images.jianshu.io/upload_images/1429831-eb14e00613aa17fd.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)    
4、引入 `#import <KF5SDK/KF5SDK.h>`。     
初始化配置信息：       
`[[KFConfig shareConfig]initializeWithHostName:kHostName appId:kAppId];`    
>注：khostName为您平台的http地址，如：https://tianxiang.kf5.com, kAppId为您为用户创建的唯一标示（在您的KF5后台[创建移动SDK APP应用](https://support.kf5.com/hc/kb/article/24825/)，APP应用里的传输密钥即为appId）。此方法可放在AppDelegate里初始化。     

**进入工程中的info.plist，添加一下权限**      
Privacy - Camera Usage Description：是否允许该应用使用你的相机？      
Privacy - Microphone Usage Description：是否允许该应用使用你的麦克风?     
Privacy - Photo Library Usage Description：是否允许该应用访问你的媒体资料库？   
![privacy.png](http://upload-images.jianshu.io/upload_images/1429831-f6849f289bb5edad.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)    
5、 配置完基本信息，即可使用逸创云客服SDK，详细的SDK参数和用法请见下面的内容。   
## 三、SDK使用方法   
###### 在使用SDK相关功能模块前，引入`#import "KFUserManager.h"`并调用KFUserManager的初始化用户的方法获取到userToken(用户唯一标示)，下面为使用邮箱初始化用户的方法：   
```ObjC
// 如果userToken为空，则需要初始化用户
if ([KFUserManager shareUserManager].user.userToken.length == 0) {
[[KFUserManager shareUserManager]initializeWithEmail:@"123@qq.com" completion:^(KFUser * _Nullable user, NSError * _Nullable error) {
}];
}
```
>注：最好在使用SDK相关功能前调用，比如设置界面，不建议在AppDelegate中调用此方法，因为当前服务器对每个平台平均的创建用户量有一定的限制。KF5SDK是专用于普通用户的，因此初始化用户时应该使用不同的邮箱或手机号,否则App中的每个用户看到的所有信息全部相同。    
#### 1、添加支持文档功能
引入`#import "KF5SDKDoc.h"`   
调用方法如下：   
```ObjC
[self.navigationController pushViewController:[[KFCategorieListViewController alloc]init] animated:YES];
```
>注：文档部分有文档分区、文档分类、文档列表、文档内容，分别对应控制器为`KFCategorieListViewController`，`KFForumListViewController`，`KFPostListViewController`、`KFDocumentViewController`。更详细的信息请见相关类的头文件。   
#### 2、添加支持工单功能
引入`#import "KF5SDKTicket.h"`    
调用方法如下：   
```
[self.navigationController pushViewController:[[KFTicketListViewController alloc]init] animated:YES];
```
   
**工单自定义字段**需要在创建工单时设置,对应字段为`KFCreateTicketViewController`中的`custom_fields`属性,格式为@[@{@"name":@"field_123",@"value":@"手机端"},@{@"name":@"field_321",@"value":@"IOS"}]。   
>注：工单部分有工单列表、工单内容、创建工单、工单详细信息，分别对应控制器为`KFTicketListViewController`、`KFTicketViewController`、`KFCreateTicketViewController`、`KFDetailMessageViewController`。更详细的信息请见相关类的头文件。
#### 3、添加支持即时通讯功能
引入`#import "KF5SDKChat.h"`    
调用方法如下：   
```ObjC
[self.navigationController pushViewController:[[KFChatViewController alloc]initWithMetadata:@[@{@"name":@"系统",@"value":@"IOS"},@{@"name":@"应用名称",@"value":@"云客服"}]] animated:YES];    
```
**用户自定义信息**需要在初始化KFChatViewController时设置,在`initWithMetadata:`中设置metadata,格式为@[@{@"name":@"系统",@"value":@"IOS"},@{@"name":@"应用名称",@"value":@"云客服"}]。          
>注：聊天部分有聊天控制器，对应控制器为`KFChatViewController`。更详细的信息请见相关类的头文件。

## 四、SDK核心framework详解
KFConfig为全局初始化方法，用于初始化KF5平台地址和应用的APPID，需要在使用SDK前初始化，建议放在AppDelegate里。   
KFHttpTool为核心网络请求，里面涉及用户的管理、文档请求、工单请求。    
KFChatManager为核心IM请求，里面涉及到IM的所有请求，并封装了数据库方法，开发者可非常方便的集成IM功能。      
KFMessage为IM消息模型。   
KFAgent为客服模型。   
KFLogger为日志打印类，当有错误信息时，会输入日志。开启方式如下：    
```ObjC
#ifdef DEBUG
[KFLogger enable:YES];
#else
[KFLogger enable:NO];
#endif
```
## 五、关于SDKUI部分的样式设置   
所有的UI样式被封装在KFHelper中，开发者可根据需求直接修改View的属性或修改KFHelper中的样式。     
## 六、其他
1、KF5SDKUI部分使用的第三方库如果和您的有冲突，删除UI中相应的第三方库即可。     
2、如果在KFChatViewController和KFTicketViewController界面出现弹出键盘时,视图和导航栏都往上移动且工具栏与键盘之间留有空隙,则请检查您是否集成了类似IQKeyboardManager的第三方库,如果有,只需要在KFChatViewController和KFTicketViewController中禁止掉IQKeyboardManager即可!      
## 七、最新版本            
#### V2.3.0 最后更新于 2017-05-09	  	
新增机器人关闭状态先发送消息后排队的设置,修复部分bug        
### 历史版本              
#### V2.2.1 最后更新于 2017-04-17	  	
优化体验,修复部分bug        
#### V2.2.0 最后更新于 2017-04-01		
新增SDK支持IM分词匹配功能,优化代码   
#### V2.1.4 最后更新于 2017-03-23
SDKIM新增消息类型,修复工单内容不显示的bug      
#### V2.1.3 最后更新于 2017-03-09
新增SDK支持IM超时应答功能,修复部分bug           
#### V2.1.2 最后更新于 2017-03-06
新增SDK支持用户的受理客服功能,优化代码            
#### V2.1.1 最后更新于 2017-01-05
修复IM满意度评价可能出错的bug,添加自定义国际化支持,修复工单批量上传图片可能会漏掉的bug,优化代码 
#### V2.1.0 最后更新于 2017-01-03
新增工单满意度评价功能,修复部分bug    
#### V2.0.1 最后更新于 2016-11-29      
修复聊天创建cell使用标识不正确的问题  
#### V2.0.0 最后更新于 2016-11-18
iOS SDK2.0beta版更新              
