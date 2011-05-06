import xml.dom.minidom

def getTagText(root, tag):
    node = root.getElementsByTagName(tag)[0]
    rc = ""
    for node in node.childNodes:
        if node.nodeType in (node.TEXT_NODE, node.CDATA_SECTION_NODE):
            rc = rc + node.data
    return rc

def getTagsAttribute(root, tag, attribute):
    tagNodes = root.getElementsByTagName(tag)
    attrlist = [];
    for node in tagNodes:
        attrlist.append(node.getAttribute(attribute))
    return attrlist;

def getTagsText(root, tag):
    tagNodes = root.getElementsByTagName(tag)
    rc = []
    for node in tagNodes:
        for node in node.childNodes:
            if node.nodeType in (node.TEXT_NODE, node.CDATA_SECTION_NODE):
                rc.append(node.data)
    return rc

dom = xml.dom.minidom.parse('./AccessoriesMago.log')
root = dom.documentElement
print "TestRun Class:%s" %getTagText(root, "class")
print "TestRun Description:%s" %getTagText(root, "description")

testCaseStatus = getTagsText(root, "pass");
testCase = getTagsAttribute(root, "case", "name")

for i in range(len(testCase)):
    print "Testcase:%s Status:%s" %(testCase[i], testCaseStatus[i])
