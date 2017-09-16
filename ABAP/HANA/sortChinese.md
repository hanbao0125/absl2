I have a simple demo, I have create a table which contains 3 rows and they all have a column named"CNAME" to display their Chinese name. And for column ENAME, it displays their Chines name in pinyin.
 
DROP TABLE TEST_SORT;
CREATE TABLE TEST_SORT ( SID INTEGER,
CNAME NVARCHAR(100),
ENAME NVARCHAR(20));


INSERT INTO TEST_SORT Values (1, '山东', 'ShanDong');
INSERT INTO TEST_SORT Values (2, '华为', 'Huawei');
INSERT INTO TEST_SORT Values (3, '爱活力', 'Aihuoli');
 
You could open sql trace with result when you executing the sort statement:
 
 select * from TEST_SORT ORDER BY CNAME desc;
 
The result in sql trace shows that the Chinese name will be transfer to Hexadecimal character when they are stored in the system and the compare are in fact in these Hexadecimal character:
 
cursor_140298224832512_c136.execute(''' select * from TEST_SORT ORDER BY CNAME desc ''')
# end PreparedStatement_execute (thread 29569, con-id 300136) at 2017-09-11 15:54:31.140143
# ResultSet.columnLabel = [SID:INTEGER, CNAME:NVARCHAR, ENAME:NVARCHAR] (thread 29569, con-id 300136) at 2017-09-11 15:54:31.140189
# ResultSet.row[1] = [3, u'''\xE7\x88\xB1\xE6\xB4\xBB\xE5\x8A\x9B''', u'''Aihuoli'''] (thread 29569, con-id 300136) at 2017-09-11 15:54:31.140204
# ResultSet.row[2] = [1, u'''\xE5\xB1\xB1\xE4\xB8\x9C''', u'''ShanDong'''] (thread 29569, con-id 300136) at 2017-09-11 15:54:31.140210
# ResultSet.row[3] = [2, u'''\xE5\x8D\x8E\xE4\xB8\xBA''', u'''Huawei'''] (thread 29569, con-id 300136) at 2017-09-11 15:54:31.140216
 
Therefore, 爱活力 will be bigger than 山东 and 华为.
 
If you want to sort the Chinese character as you expected, I think the most convenient way is to add a column that display the Chinese name in pinyin and sort in that column.
