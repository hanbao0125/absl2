REPORT  Z_1.

DATA: xml_string TYPE string.

DATA: BEGIN OF line,
        matnr(18) TYPE c,
        maktx(40) TYPE c,
      END OF line,

      BEGIN OF header,
        datum LIKE sy-datum,
        uzeit LIKE sy-uzeit,
      END OF header,

      itab LIKE TABLE OF line.

header-datum = sy-datum.
header-uzeit = sy-uzeit.

line-matnr = 'C075'.
line-maktx = '6120H车型'.
APPEND line TO itab.

line-matnr = 'C076'.
line-maktx = '6100H车型'.
APPEND line TO itab.

line-matnr = space.
line-maktx = space.
APPEND line TO itab.

CALL TRANSFORMATION Z_CC
  OPTIONS xml_header = 'no'
  SOURCE root = itab
         header = header
  RESULT XML xml_string.

WRITE: AT /1 xml_string.

<?sap.transform simple?>
<tt:transform xmlns:tt="http://www.sap.com/transformation-templates" xmlns:ddic="http://www.sap.com/abapxml/types/dictionary" xmlns:def="http://www.sap.com/abapxml/types/defined">
  <tt:root name="root"/>
  <tt:root name="header"/>
  <tt:template>
    <header>
        <date>
            <tt:value ref="HEADER.DATUM" />
        </date>
        <time>
            <tt:value ref="HEADER.UZEIT" />
        </time>
    </header>
    <material>
        <tt:loop ref="ROOT" name="line">
            <matnr>
                <tt:value ref="$line.matnr" />
            </matnr>
            <maktx>
                <tt:value ref="$line.maktx" />
            </maktx>
        </tt:loop>
    </material>
  </tt:template>
</tt:transform>
