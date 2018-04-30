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