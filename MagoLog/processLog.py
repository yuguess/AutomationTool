import xml.dom.minidom
import ConfigParser
from xml.dom.minidom import Document

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

def appendAttribute(node, config, section):
    for option in config.options(section):
        node.setAttribute(option, config.get(section, option))

def appendTextNode(node, tag, text):
    tagElement = Document().createElement(tag)
    tagElement.appendChild(Document().createTextNode(text))
    node.appendChild(tagElement)

dom = xml.dom.minidom.parse('./AccessoriesMago.log')
root = dom.documentElement

testCaseStatus = getTagsText(root, "pass");
testCase = getTagsAttribute(root, "case", "name")

config = ConfigParser.ConfigParser()
config.read("magoConfig.ini")

doc = Document()
test_run = doc.createElement("test_run")

appendAttribute(test_run, config, "Test Run")
appendTextNode(test_run, "summary", getTagText(root, "description"))

for i in range(len(testCase)):
    test_case = doc.createElement("test_case")
    appendAttribute(test_case, config, "Test Case")
    appendTextNode(test_case, "summary", testCase[i])
    appendTextNode(test_case, "action", "pass")
    test_run.appendChild(test_case)
doc.appendChild(test_run)
print doc.toprettyxml(indent="   ")

