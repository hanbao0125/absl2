# 2017-05-07
1. the object I create is database, not table!
set client_encoding to gbk;
输入命令 SET client_encoding=GBK; - does not work!
chcp - in my laptop it is 936 - changes to 437
2. it can only accept default port in 5432?
3. command line naming convention: <username>#:
GRANT ALL PRIVILEGES ON DATABASE postgres to jerry;
column name must be wrapped with "";
INSERT INTO public.zcrm_product(
	"PRODUCT_GUID", "PRODUCT_ID")
	VALUES ('00163EA71FFC1ED28BCDD602F750AC54', '1002029');
INSERT INTO public.zcrm_product(
	"PRODUCT_GUID", "PRODUCT_ID", "CREATED_AT")
	VALUES ('00163EA71FFC1ED28BCDD616B9D76C58', '12222201', TIMESTAMP '2011-05-16 15:36:38');
INSERT INTO public.zcrm_product(
	"PRODUCT_GUID", "PRODUCT_ID", "CREATED_AT")
	VALUES ('00163EA71FFC1ED28BCDD616B9D76C5A', '12222201', current_timestamp);

# 2017-05-08
1. insert to product table:
INSERT INTO public.comm_product(
	client, product_guid, product_id, product_type, config, xnosearch, object_family, batch_dedicated, competitor_prod, "VALID_FROM", "VALID_TO", upname, histex, logsys)
	VALUES ('001', '00163EA71FFC1ED28BCDD602F750AC54', '1002029', '01', 'C', 'X', '0401', 'X', '', TIMESTAMP '2011-05-16 15:36:38', current_timestamp, 'WANGJER', '', 'AG3CLNT001');
2. If you are using Java 8 or newer then you should use the JDBC 4.2 version.

# 2017-05-11
1. import 1ggg;2;2011-05-16 15:36:38

# 2018-04-30

第一次出错貌似因为我没有用admin去run安装exe

图形管理界面: sudo apt-get install pgadmin3
从log看是因为pgadmin3下载失败。

2018-04-30 11:30:58 [INFO] : Get:1 https://s3.amazonaws.com/pgcentral pgadmin3-1.23.0b-win64
2018-04-30 11:31:09 [ERROR] : URL Error while dowloading file pgadmin3-1.23.0b-win64.tar.bz2 (<urlopen error timed out>)

CREATE USER jerry WITH PASSWORD 'Sap12345';

SELECT * FROM public.person ORDER BY "ID" ASC 

INSERT INTO public.person("ID", "FirstName", "LastName") VALUES ('102', 'Jerry', 'Wang');

12:49PM
Exception in thread "main" javax.persistence.PersistenceException: No Persistence provider for EntityManager named persistence-with-jpa
	at javax.persistence.Persistence.createEntityManagerFactory(Persistence.java:85)
	at javax.persistence.Persistence.createEntityManagerFactory(Persistence.java:54)
	at com.sap.cloud.sample.persistence.Test.main(Test.java:23)

1:31PM - good news - exception message has changed:

[EL Info]: 2018-04-30 13:30:33.745--ServerSession(1860513229)--EclipseLink, version: Eclipse Persistence Services - 2.5.1.v20130918-f2b9fc5
[EL Severe]: ejb: 2018-04-30 13:30:33.755--ServerSession(1860513229)--Exception [EclipseLink-4003] (Eclipse Persistence Services - 2.5.1.v20130918-f2b9fc5): org.eclipse.persistence.exceptions.DatabaseException
Exception Description: Configuration error.  Class [org.postgresql.Driver] not found.
Exception in thread "main" javax.persistence.PersistenceException: Exception [EclipseLink-4003] (Eclipse Persistence Services - 2.5.1.v20130918-f2b9fc5): org.eclipse.persistence.exceptions.DatabaseException
Exception Description: Configuration error.  Class [org.postgresql.Driver] not found.
	at org.eclipse.persistence.internal.jpa.EntityManagerSetupImpl.deploy(EntityManagerSetupImpl.java:766)
	at org.eclipse.persistence.internal.jpa.EntityManagerFactoryDelegate.getAbstractSession(EntityManagerFactoryDelegate.java:204)
	at org.eclipse.persistence.internal.jpa.EntityManagerFactoryDelegate.createEntityManagerImpl(EntityManagerFactoryDelegate.java:304)
	at org.eclipse.persistence.internal.jpa.EntityManagerFactoryImpl.createEntityManagerImpl(EntityManagerFactoryImpl.java:336)
	at org.eclipse.persistence.internal.jpa.EntityManagerFactoryImpl.createEntityManager(EntityManagerFactoryImpl.java:302)
	at jpatest.Test.main(Test.java:16)
Caused by: Exception [EclipseLink-4003] (Eclipse Persistence Services - 2.5.1.v20130918-f2b9fc5): org.eclipse.persistence.exceptions.DatabaseException
Exception Description: Configuration error.  Class [org.postgresql.Driver] not found.
	at org.eclipse.persistence.exceptions.DatabaseException.configurationErrorClassNotFound(DatabaseException.java:89)
	at org.eclipse.persistence.sessions.DefaultConnector.loadDriverClass(DefaultConnector.java:267)
	at org.eclipse.persistence.sessions.DefaultConnector.connect(DefaultConnector.java:85)
	at org.eclipse.persistence.sessions.DatasourceLogin.connectToDatasource(DatasourceLogin.java:162)
	at org.eclipse.persistence.internal.sessions.DatabaseSessionImpl.setOrDetectDatasource(DatabaseSessionImpl.java:204)
	at org.eclipse.persistence.internal.sessions.DatabaseSessionImpl.loginAndDetectDatasource(DatabaseSessionImpl.java:741)
	at org.eclipse.persistence.internal.jpa.EntityManagerFactoryProvider.login(EntityManagerFactoryProvider.java:239)
	at org.eclipse.persistence.internal.jpa.EntityManagerSetupImpl.deploy(EntityManagerSetupImpl.java:685)
	... 5 more
