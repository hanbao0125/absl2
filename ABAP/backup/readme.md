# My SCN blog - 2017-07-15 3:34PM

* [A Github repository issue tool developed by ABAP](https://blogs.sap.com/2017/07/14/a-github-repository-issue-tool-developed-by-abap/)
* [Use Regular Expression to parse the image reference in the markdown sourcre code](https://blogs.sap.com/2017/07/15/use-regular-expression-to-parse-the-image-reference-in-the-markdown-sourcre-code/)

## Involved tables

* CRMD_GIT_ISSUE A3/815 - 805 ( 2017-10-14)
Actual: KM 559 Java:33 JS: 233 = 825 totally
* CRMD_GIT_REPO: JAVA,JS,KM
* CRMD_GIT_IMAGE

## CDS view

* CRMV_GIT_ISSUE: list total issue number per repository
* CRMV_GIT_ISSUE_IMAGE_NUM: image number per issue + issue description
* CRMV_ISSUE_CREATION_DATE_COUNT: creation date aggregation. For example 10-14: 23

start: CL_ABAP_GIT_ISSUE_TOOL