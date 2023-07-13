//
//  Texts.swift
//  AVFoundationTest
//
//  Created by SNAPTAG on 2023/07/11.
//

enum Text: String {
    case retake = "Retake"
    case save = "Save"
}

func textSetting(_ type: Text) -> String {
    return type.rawValue
}
