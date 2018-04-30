# Console Client(only valid for Neo)

1. [help](https://help.sap.com/viewer/65de2977205c403bbc107264b8eccf4b/Cloud/en-US/76132306711e1014839a8273b0e91070.html)

SAP Cloud Platform console client for the Neo environment enables development, deployment and configuration of an application outside the Eclipse IDE as well as continuous integration and automation tasks. The tool is part of the SAP Cloud Platform SDK for Neo environment. You can find it in the tools folder of your SDK location.


# Supported Java API

1. [help](https://help.sap.com/viewer/65de2977205c403bbc107264b8eccf4b/Cloud/en-US/e836a95cbb571014b3c4c422837fcde4.html) - still for Neo

When you develop applications that run on SAP Cloud Platform, you can rely on certain Java EE standard APIs. These APIs are provided with the runtime of the platform. They are based on standards and are backward compatible as defined in the Java EE specifications. 

Cloud Foundry is an engaging open-source platform-as-a-service creating a buzz in the tech world

# User

1. D042416@gmail.com Sap12345
p1942400002trial
i042416trial

# Host

hanatrial.ondemand.com

# Url

2. [How To Use A Servlet As Your Main Web Page](http://wiki.metawerx.net/wiki/HowToUseAServletAsYourMainWebPage)

3. install new software with url:  https://tools.hana.ondemand.com/neon

4. [My test application url](https://helloworldi042416trial.hanatrial.ondemand.com/JerryTest/)

After I changed it to Maven project on 2017-05-07, [new url](https://helloworldi042416trial.hanatrial.ondemand.com/jerrytest/)

# Open SAP

Unit 2: Digital Transformation: Connecting People, Things, and Businesses
Unit 3: Architecture and Capabilities - done 2018-04-23

# blogs

1. [Logging in HCP Cloud foundry with Java and Tomee using slf4j, logback, Jolokia](https://blogs.sap.com/2016/12/02/logging-in-hcp-cloud-foundry-with-java-and-tomee-using-slf4j-logback-jolokia/)

# work log

## 2017-05-01

956我为什么没办法publish 到cloud 上去？
1004可能我有个工具没装。新Eclipse还是需要配proxy
Possible hint: https://archive.sap.com/discussions/thread/3857381
finally it works: https://helloworldi042416trial.hanatrial.ondemand.com/JerryTest/
1518: I would like to achieve both servlet and html work. Is it really possible? I tried in local it is possible. Verified 1628, it is possible!
1613: 果然重启大法好。。。

## 2017-05-07

1. Sometimes after restart, I need to Maven->Update project or else the servlet could not be successfully instantiated again!

2. workaround does not work for resources in HCP?! Verified, workaround can still works if the web application is started in local server, but does not work in HCP.

## 2017-05-20

My Fiori application in HCP: https://flpportal-i042416trial.dispatcher.hanatrial.ondemand.com/sites?siteId=6af9e0d2-8b95-413c-9dc5-7d8b0c8b0ec1#jerrylist-Display

I am in Europe-Rot-Trial.

cf target -s dev

Error restarting application: BuildpackCompileFailed

cf logs jerry_list_wiesloch --recent
package.json is missing

npm install express - lots of file generated in my project folder :)

cf api https://api.cf.us10.hana.ondemand.com

cf api https://api.cf.eu10.hana.ondemand.com - Jerry 2017-07-15

https://jerry-list-wiesloch.cfapps.us10.hana.ondemand.com

how the CF is clever enough to know that index.html should be executed??

https://jerrylist.cfapps.eu10.hana.ondemand.com/ui5 can access now.
https://jerrylist.cfapps.eu10.hana.ondemand.com - 囧，要加https

set HTTPS_PROXY=http://proxy.wdf.sap.corp:8080

# 2017-05-27

1. https://jerryordercount.cfapps.eu10.hana.ondemand.com

https://jerryordercount.cfapps.eu10.hana.ondemand.com/jerry/OneOrderHCP.html --Jerry checks on 2017-07-15 that it could still be accessed.
2018-04-23 12:44PM - down.

# 2017-07-15

user: my sap email
password: the one to access my laptop!!!

# 2017-08-05

1. https://jerrylist.cfapps.eu10.hana.ondemand.com/ui5 - SCN offline list

# 2017-08-06

Vicky: https://blogs.sap.com/2017/02/07/how-to-deploy-ui5-application-on-hcpcloudfoundry/

# 2018-04-23

1. 定义的开发程序必须放在SAP Cloud Platform里，想要与S/4交互，请使用API。

2. [12-factor application](https://12factor.net/zh_cn/)

* BYOL Bring your own language
* backing service: 后端服务是指程序运行所需要的通过网络调用的各种服务，如数据库（MySQL，CouchDB），消息/队列系统（RabbitMQ，Beanstalkd），SMTP 邮件发送服务（Postfix），以及缓存系统（Memcached）。

polyglot

# 2018-04-30

[how to set proxy for cf login](https://docs.cloudfoundry.org/cf-cli/http-proxy.html#windows)

12:04PM - password不对？？I should use this one: https://api.cf.eu10.hana.ondemand.com

Credentials were rejected - fuck

>cf auth

用IE试试能否用密码登录前台。-12:20 SCN都能用邮件和开机密码登录啊！
SCP UI也能用邮件和密码登录，太怪了。

CF_TRACE=true 2018-04-28 12:34PM

javax.naming.AuthenticationNotSupportedException: [LDAP: error code 48 - Authentication failed]

http://proxy.sha.sap.corp:8080

have your account on Trial deleted, please do the following: create a BCP ticket on BC-NEO-CIS and reqeust the account deletion for Trial. Please provide your email address and account ID and also state that only the account is to be deleted, not your user. Hope this helps!

For doing CF Development you need to request for trial account on internal Cloud Foundry CANARY instance as described in the below jam page

{"error":"unauthorized","error_description":"[LDAP: error code 48 - Authentication failed]; nested exception is javax.naming.AuthenticationNotSupportedException: [LDAP: error code 48 - Authentication failed]"}

cf install-plugin cf-cli-mta-plugin-2.0.3-windows-x86_64.exe

The Lightweight Directory Access Protocol (LDAP; /ˈɛldæp/) is an open, vendor-neutral, industry standard application protocol for accessing and maintaining distributed directory information services over an Internet Protocol (IP) network.[1] Directory services play an important role in developing intranet and Internet applications by allowing the sharing of information about users, systems, networks, services, and applications throughout the network.[2] As examples, directory services may provide any organized set of records, often with a hierarchical structure, such as a corporate email directory. Similarly, a telephone directory is a list of subscribers with an address and a phone number.

A common use of LDAP is to provide a central place to store usernames and passwords. This allows many different applications and services to connect to the LDAP server to validate users.

> Error starting application "shine-web": Controller operation failed: 400 Bad Request: You have exceeded the instance limit for your organization's quota.
  Unexpected error: Controller operation failed: 400 Bad Request: You have exceeded the instance limit for your organization's quota.
  Unexpected error: Error monitoring subprocess with id 22676823
  Exception occured during execution: "Error monitoring subprocess with id 22676823"
Process failed: Error starting application "shine-web": Controller operation failed: 400 Bad Request: You have exceeded the instance limit for your organization's quota.

Use "cf deploy -i 22681535 -a abort" to abort the process.
Use "cf deploy -i 22681535 -a retry" to retry the process.
Use "cf dmol -i 22681535" to download the logs of the process.

cf quotas

1870220149 -  cf login failed: javax.naming.AuthenticationNotSupportedException

# 2018-04-29

MDC - multi-tenant database container

com.sap.core.persistence.sql.trace

jpa - java persistence api - 只需要定义annotation即可访问DB。

p1942399991trial

10:10PM - 不出所料要出幺蛾子，部署上去之后404 error。

# 2018-04-30

JPA支持XML和JDK5.注解两种元数据的形式，元数据描述对象和表之间的映射关系，框架据此将实体对象持久化到数据库表中；

* API

用来操作实体对象，执行CRUD操作，框架在后台替代我们完成所有的事情，开发者从繁琐的JDBC和SQL代码中解脱出来。

* 查询语言

这是持久化操作中很重要的一个方面，通过面向对象而非面向数据库的查询语言查询数据，避免程序的SQL语句紧密耦合。

10:03AM SCP sample用的也是EclipseLink作为JPA实现。

the transaction-type defines the application type (J2EE of JSE). The value RESOURCE_LOCAL defines a JSE application

org.eclipse.persistence.jpa.PersistenceProvider:EclipseLink class

11:24am 还是没进展。

5:15PM - Server jerryjdbc.p1942399991trial at hanatrial.ondemand.com was unable to start within 120 seconds. If the server requires more time, try increasing the timeout in the server editor.