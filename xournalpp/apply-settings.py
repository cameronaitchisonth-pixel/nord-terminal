#!/usr/bin/env python3
"""Merge this repo's Nord Xournal++ settings into yours.

    apply-settings.py <repo settings.xml> <~/.config/xournalpp/settings.xml>

Xournal++ rewrites settings.xml when it exits, so the Nord entries are merged in instead of
linked. Each <property> replaces yours with the same name; inside <data name="buttonConfig">
only the buttons listed here are replaced; any other <data> block is replaced whole. With no
settings.xml yet, the repo's file is written as is. Quit Xournal++ first.
"""
import os
import sys
from xml.dom import minidom

template, target = sys.argv[1], sys.argv[2]
src = open(template, encoding="utf-8").read().replace("@HOME@", os.path.expanduser("~"))

if not os.path.exists(target):
    os.makedirs(os.path.dirname(target), exist_ok=True)
    with open(target, "w", encoding="utf-8") as f:
        f.write(src)
    sys.exit()


def elements(parent, tag):
    return [c for c in parent.childNodes if c.nodeType == c.ELEMENT_NODE and c.tagName == tag]


def named(parent, tag, name):
    return next((c for c in elements(parent, tag) if c.getAttribute("name") == name), None)


def put(doc, parent, node, tag):
    new = doc.importNode(node, True)
    old = named(parent, tag, node.getAttribute("name"))
    if old:
        parent.replaceChild(new, old)
    else:
        parent.appendChild(new)


nord = minidom.parseString(src.encode("utf-8")).documentElement
doc = minidom.parse(target)
root = doc.documentElement

for prop in elements(nord, "property"):
    put(doc, root, prop, "property")
for block in elements(nord, "data"):
    mine = named(root, "data", block.getAttribute("name"))
    if block.getAttribute("name") == "buttonConfig" and mine:
        for button in elements(block, "data"):
            put(doc, mine, button, "data")
    else:
        put(doc, root, block, "data")

with open(target, "w", encoding="utf-8") as f:
    f.write(doc.toxml(encoding="UTF-8").decode("utf-8"))
