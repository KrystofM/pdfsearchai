//
//  PDFOutline.swift
//  ViewAI
//
//  Created by Krystof Mitka on 5/13/23.
//

import Foundation
import PDFKit

extension PDFOutline: Identifiable {
    
    // hopefully there cant be two same outlines in the same position
    public var id: String {
        return label! + destination!.page!.label! + "\(destination!.point.x)" + "\(destination!.point.y)"
    }
    
    var children: [PDFOutline]? {
        var children: [PDFOutline] = []
        if numberOfChildren == 0 {
            return nil
        }
        
        for i in 0..<numberOfChildren {
            children.append(child(at: i)!)
        }
        return children
    }
}
