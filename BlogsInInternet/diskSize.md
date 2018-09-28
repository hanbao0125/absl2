Used

2018-06-12 326GB
2018-06-19 345GB
2018-07-08 360GB
2018-07-19 387GB - TM
2018-07-24 401GB 
2018-08-09 327GB 

100  1 million
1000 10 millon

二维码扫描完成后，曾海瑞在微信上点击“预约”菜单，即可自助预约蓝天机器人公司的技师进行机械臂的上门安装。



3. 在微信预约上门页面里，曾海瑞的当前地址自动被GPS识别出来，当然他也可以手动修改。因为我们开发人员是在公司里做的测试，所以下图的预约地址显示的是SAP成都研究院数字创新空间的实际地址：







曾海瑞微信里显示的安装技师的清单是通过调用C4C的客户主数据服务生成的。这个服务会在C4C后台自动筛选和曾海瑞指定的预约时间匹配的技师，然后返回给微信。



最终曾海瑞在可选技师列表中选择了颜值最高的一位技师，李晓刚。







李晓刚这个名字不是我们杜撰的，现实中是Jerry的同事，SAP成都研究院C4C开发团队的开发人员Li Sean。



李晓刚的业余爱好除了烹饪之外，还喜欢玩飞镖和读佛经。











曾海瑞在微信上选定李晓刚作为安装技师后，李晓刚手机上的C4C应用程序立即收到一条消息提醒：



你有新的工单。用户预定了上门安装服务，请及时查看工单详情。







李晓刚点击消息提示，进入C4C手机应用的工单明细页面，看到这个机械臂的安装明细信息。



到了曾海瑞预约的日期，在李晓刚出发之前，他可以点击C4C工单界面底部工具栏上的"共享你的位置"按钮，向曾海瑞发起一个实时位置共享。







此时曾海瑞在微信里就可以随时查看李晓刚的实时位置。







5. 李晓刚到达现场完成机械臂安装之后，在自己的C4C手机应用上，点击按钮"推送账单"，将本次安装费用的账单明细推送到曾海瑞的微信上。账单里除了本次安装费用后，还包括了该机械臂在S/4HANA系统里维护的和交叉销售(Cross Selling)相关的信息，比如和机械臂配套的喷嘴冲洗枪。







李晓刚和曾海瑞当面沟通后，曾海瑞决定将这个喷嘴冲洗枪也一并购买。于是李晓刚在推送账单之前，将相关产品区域喷嘴冲洗枪前面的勾选框选中，再点击"推送账单"按钮。



曾海瑞微信上收到账单后，确认信息无误后进行支付。当然这里的支付也可以和S/4HANA的billing流程集成，只是这个原型开发我们没有做。







6. 曾海瑞支付完成后，会在手机上看到一个对这次安装服务满意程度的调查问卷。

这里我们直接使用了S/4HANA Survey的数据模型，把调查问卷提交函数通过Cloud Connector暴露出来给微信应用消费。







曾海瑞在微信页面上打了五星好评后，该结果通过S/4HANA的Survey API写入数据库中。



关于用ABAP代码提交S/4HANA Survey数据的更多细节，参考我的博客：



Use ABAP code to fill CRM Survey question and submit

https://blogs.sap.com/2018/06/26/use-abap-code-to-fill-crm-survey-question-and-submit/



原型开发架构介绍



下面是智能服务原型开发的架构图。







1. 白色图例代表SAP成都研究院数字创新空间的开发人员为这个原型做的开发内容，这些开发包含:



新的代码，比如图中C4C和S/4 API endpoint是我们在Netweaver后台新创建的API。

新的配置，比如在SAP云平台上创建的一些Destination配置。

新的数据模型，比如在S/4HANA创建的CDS view，用于存储用户提交的Survey结果，借助CDS view本身强大的实时数据分析功能进行各种报表的自开发。



更详细的用自开发的CDS view和前台界面来渲染S/4HANA Survey结果的细节，请参考我的博客：



Develop your own Chart to visualize your CRM Survey result

https://blogs.sap.com/2018/08/08/develop-your-own-chart-to-visualize-your-crm-survey-result/



2. 浅绿色图例代表蓝天机器人公司微信公众号的消息服务器，我们部署在阿里云平台上。

3. 深绿色图例代表SAP产品里的标准功能。

Account Management: 曾海瑞关注微信公众号后，在C4C生成一个客户主数据，使用的是C4C Account Maangement提供的OData服务。

Service Ticket: 李晓刚收到的工单和曾海瑞收到的账单我们都用Service Ticket这个模型来实现。

Offline Pricing: 因为是原型开发，为简单起见，对于C4C的账单计费需求，我们并未使用和S/4HANA集成的计费方案。

Product Master: S/4HANA的物料主数据通过HANA Cloud Integration同步到C4C中，从而被C4C工单和账单使用。

4. 灰色图例代表这个原型开发里使用到的SAP产品：

C4C

S/4HANA

SAP Cloud Connector

SAP Cloud Platform



这个原型开发从技术上来说，客户曾海瑞，技师李晓刚，C4C和S/4HANA这四个系统之间的时序交互如下图所示：







如果您想了解这个原型开发更详细的技术细节，请联系我。感谢阅读。



更多阅读



SAP S4CRM vs C4C, 诸葛亮和周瑜?

SAP成都C4C小李探花：浅谈Fiori Design Guidelines

SAP成都研究院C4C光明左使：SAP Cloud for Customer 使用SAP UI5的独特之处

SAP Cloud for Customer Extensibility的设计与实现

SAP移动应用解决方案之一：HTML5应用 + Cordova = 平台相关的混合应用

机器学习在SAP Cloud for Customer中的应用

SAP C/4HANA到底包含哪些产品：https://zhuanlan.zhihu.com/p/45188119

