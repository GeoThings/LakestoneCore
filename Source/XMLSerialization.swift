//
//  XMLSerialization.swift
//  geoBingAnCore
//
//  Created by Taras Vozniuk on 6/29/16.
//  Copyright © 2016 GeoThings. All rights reserved.
//

#if COOPER

import javax.xml.parsers
import javax.xml.transform
import javax.xml.transform.dom
import javax.xml.transform.stream
import org.w3c.dom
import org.xml.sax

import java.io
import java.nio
import java.nio.charset

#else
    
import SwiftXML2
import Foundation
    
#endif

public class XMLSerialization {
    
    public class func xmlObject(fromFile file: File) throws -> XMLDocument {
        return try XMLDocument(file: file)
    }

    public class func xmlObject(fromUTF8NilTerminatedStringData data: Data) throws -> XMLDocument {
        return try XMLDocument(utf8EncodedData: data)
    }
    
    #if COOPER
    
    public class func xmlObject(fromXMLString string: String) throws -> XMLDocument {
        return try XMLDocument(xmlString: string)
    }
    
    #endif
    
    public class func XMLObjectForWriting(withRootElementName rootElementName: String) -> XMLWriter {
        return XMLWriter(rootElementName: rootElementName)
    }
    
    public class func dataSerialized(from node: XMLNode) throws -> Data {
        return try XMLWriter(root: node).writeToData()
    }
}

public class XMLWriter {
    
    #if COOPER
    internal let document: Document
    #else
    internal let document: xmlDocPtr
    #endif
    
    internal init(root: XMLNode){
        
        #if COOPER
            
        self.document = root.node.getOwnerDocument()
            
        #else
            
        self.document = root.node.memory.doc
            
        #endif
    }
    
    internal init(rootElementName: String) {
        
        #if COOPER
        self.document = DocumentBuilderFactory.newInstance().newDocumentBuilder().newDocument()
        let rootElement = self.document.createElement(rootElementName)
        self.document.appendChild(rootElement)
            
        #else
            
        self.document = xmlNewDoc("1.0")
        //let cElementName = rootElementName.nulTerminatedUTF8.withUnsafeBufferPointer { $0.baseAddress }
        let newNode = xmlNewNode(nil, rootElementName)
        xmlDocSetRootElement(self.document, newNode)
            
        #endif
    }
    
    public var rootNode:XMLNode {
        #if COOPER
        return XMLNode(element: self.document.getDocumentElement())
        #else
        return XMLNode(internalNode: xmlDocGetRootElement(self.document))
        #endif
    }
    
    var _tpIncrement: Int = 0
    public func writeToData() throws -> Data {
        
        #if COOPER
        
        let transformer = TransformerFactory.newInstance().newTransformer()
        transformer.setOutputProperty(OutputKeys.INDENT, "yes")
        transformer.setOutputProperty(OutputKeys.METHOD, "xml")
        transformer.setOutputProperty(OutputKeys.ENCODING, "UTF-8")
        
        let byteArrayOutputStream = ByteArrayOutputStream()
        try transformer.transform(DOMSource(self.document), StreamResult(byteArrayOutputStream))
        return Data.wrap(byteArrayOutputStream.toByteArray())
        
        #else
            
        var targetMemo = UnsafeMutablePointer<UnsafeMutablePointer<xmlChar>>(calloc(1, strideof(UnsafeMutablePointer<xmlChar>)))
        var targetSize = Int32(-1)
        xmlDocDumpFormatMemory(self.document, targetMemo, &targetSize, 1)
        if targetSize == -1 {
            throw ErrorBuilder.Error.XMLWritingFailure
        }
        
        let outputData = Data(bytes: targetMemo.memory, length: Int(targetSize))
        xmlFree(targetMemo)
        return outputData
            
        #endif
    }
}

public class XMLDocument {
    
    #if COOPER
    internal let document: Document
    #else
    internal let document: xmlDocPtr
    #endif
    
    internal init(file: File) throws {
        
        #if COOPER
            
        let documentBuilder = DocumentBuilderFactory.newInstance().newDocumentBuilder()
        self.document = try documentBuilder.parse(file)
            
        #else
            
        let cfilePath = file.nulTerminatedUTF8.map { Int8(bitPattern: $0) }.withUnsafeBufferPointer { $0.baseAddress }
        let document = xmlParseFile(cfilePath)
        if document == nil {
            throw ErrorBuilder.Error.FileParsingFailed
        }
            
        if xmlGetLastError() != nil {
            xmlResetLastError()
            throw ErrorBuilder.Error.FileParsingFailed
        }
        
        self.document = document
            
        #endif
    }
    
    #if COOPER
    internal init(xmlString: String){
        
        let stream = ByteArrayInputStream(xmlString.getBytes(StandardCharsets.UTF_8))
        let builder = DocumentBuilderFactory.newInstance().newDocumentBuilder();
        self.document = builder.parse(stream);
    }
    #endif
    
    internal init(utf8EncodedData: Data) throws {
        
        #if COOPER
        
        let documentBuilder = DocumentBuilderFactory.newInstance().newDocumentBuilder()
        utf8EncodedData.position(0)
        self.document = try documentBuilder.parse(java.io.ByteArrayInputStream(utf8EncodedData.bytes))
        
        #else
        
        let xmlUTF8DataPtr = utf8EncodedData.bytes
        if xmlUTF8DataPtr == nil {
            throw ErrorBuilder.Error.BytesDataIsNotProperXML
        }
            
        let xmlDoc = xmlReadDoc(unsafeBitCast(xmlUTF8DataPtr, UnsafePointer<UInt8>.self), "noname.xml", nil, Int32(XML_PARSE_RECOVER.rawValue))
        if xmlDoc == nil {
            throw ErrorBuilder.Error.BytesDataIsNotProperXML
        }
        
        if xmlGetLastError() != nil {
            xmlResetLastError()
            throw ErrorBuilder.Error.FileParsingFailed
        }
            
        self.document = xmlDoc
        #endif
    }
    
    public var rootNode:XMLNode {
        #if COOPER
        return XMLNode(element: self.document.getDocumentElement())
        #else
        return XMLNode(internalNode: xmlDocGetRootElement(self.document))
        #endif
    }
}

public class XMLNode {
    
    #if COOPER
    internal let node: Element
    #else
    internal let node: xmlNodePtr
    #endif
    
    #if COOPER
    internal init(element: Element){
        self.node = element 
    }
    #else
    internal init(internalNode: xmlNodePtr) {
        self.node = internalNode
    }
    #endif
    
    public var nameº: String? {
        #if COOPER
        return self.node.getNodeName()
        #else
        return String(UTF8String: unsafeBitCast(self.node.memory.name, UnsafePointer<Int8>.self))
        #endif
    }
    
    public var valueº: String? {
        
        #if COOPER
        return self.node.getNodeValue()
        
        #else
        
        let textValueCString = xmlNodeListGetString(self.node.memory.doc, self.node.memory.children, 1)
        if textValueCString == nil {
            return nil
        }
        
        let nodeString = String(UTF8String: UnsafePointer<CChar>(textValueCString))
        free(textValueCString)
        return nodeString
        
            
        #endif
    }
    
    public var children: [XMLNode] {
        
        #if COOPER
        
        var resultChildren = [XMLNode]()
        let nodeList = self.node.getChildNodes()
        for nodeIndex in 0 ..< nodeList.getLength() {
            
            let nodeItem = nodeList.item(nodeIndex)
            if (nodeItem.getNodeType() == Node.ELEMENT_NODE){
                resultChildren.append(XMLNode(element: nodeItem as! Element))
            }
            
        }
        
        return resultChildren
        
        #else
        
        // This is going to be an array of XML_ELEMENT_NODE
        var resultChildren = [XMLNode]()
        
        var currentNodePtr = self.node.memory.children
            while (currentNodePtr != nil){
            let childNode = XMLNode(internalNode: currentNodePtr)
            
            // xmlNodeIsText() returns a status of 1 if the node is a text node and 0 if it is not.
            // We want to append the child node only if we know it isn't a text node. -JKC
            if xmlNodeIsText(currentNodePtr) == 0 {
                resultChildren.append(childNode)
            }
            
            currentNodePtr = currentNodePtr.memory.next
        }
        
        return resultChildren
        
        #endif
    }
    
    public func children(withName name: String) -> [XMLNode] {
        
        let filteredChildren = self.children.filter {
            guard let childName = $0.nameº else {
                return false
            }
            
            return (childName == name)
        }
        
        #if COOPER
        return [XMLNode](sequence: filteredChildren)
        #else
        return filteredChildren
        #endif
    }
    
    public func firstChild(withName name: String) -> XMLNode? {
        return self.children(withName: name).first
    }
    
    public var attributes: [String: String] {
        
        var resultAttributes = [String: String]()
        
        #if COOPER
        
        let attributesMap = self.node.getAttributes()
        for attributeIndex in 0 ..< attributesMap.getLength() {
            let attributeItem = attributesMap.item(attributeIndex)
            resultAttributes[attributeItem.getNodeName()] = attributeItem.getNodeValue()   
        }
        
        #else
        
        var currentAttributePtr = self.node.memory.properties
        while (currentAttributePtr != nil) {
            
            let attributeKeyCString = currentAttributePtr.memory.name
            let attributeValueCString = xmlGetProp(self.node, attributeKeyCString)
                
            guard let attributeKey = String(UTF8String: UnsafePointer<CChar>(attributeKeyCString)),
                  let attributeValue = String(UTF8String: UnsafePointer<CChar>(attributeValueCString))
            else {
                continue
            }
            
            resultAttributes[attributeKey] = attributeValue
            currentAttributePtr = currentAttributePtr.memory.next
            
        }
        
        #endif
        
        return resultAttributes
    }
    
    public func addChildElement(withName name: String, value: String, attributes: [String: String]) -> XMLNode {
        
        #if COOPER
        let childElement = self.node.getOwnerDocument().createElement(name)
        self.node.appendChild(childElement)
            
        childElement.setNodeValue(value)
            
        for (attributeKey, attributeValue) in attributes {
             childElement.setAttribute(attributeKey, attributeValue)
        }
        
        return XMLNode(element: childElement)
            
        #else
        
        let childNode = xmlNewChild(self.node, nil, name, value)
        for (attributeKey, attributeValue) in attributes {
            xmlNewProp(childNode, attributeKey, attributeValue)
        }
        
        return XMLNode(internalNode: childNode)
            
        #endif
    }
    
    public func add(attributes attributesToAdd: [String: String]){
        
        #if COOPER
        
        for (attributeKey, attributeValue) in attributesToAdd {
            self.node.setAttribute(attributeKey, attributeValue)
        }
        
        #else
        
        for (attributeKey, attributeValue) in attributesToAdd {
            xmlNewProp(self.node, attributeKey, attributeValue)
        }
        
        #endif
    }
    
    public func add(childNode node: XMLNode) {
        
        #if COOPER
        
        let nodeToAdopt = self.node.getOwnerDocument().adoptNode(node.node)
        self.node.appendChild(nodeToAdopt)
            
        #else
        xmlAddChild(self.node, node.node)
            
        #endif
    }
}