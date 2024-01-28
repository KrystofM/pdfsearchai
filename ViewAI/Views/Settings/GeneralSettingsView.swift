//
//  GeneralSettingsView.swift
//  ViewAI
//
//  Created by Krystof Mitka on 5/13/23.
//

import Foundation
import SwiftUI

struct GeneralSettingsView: View {
    @AppStorage("openAIKey") private var openAIKey = ""

    var body: some View {
        Form {
            SecureField("OpenAI API Key", text: $openAIKey)
                .disableAutocorrection(true)
        }
        .padding(20)
        .frame(width: 350, height: 100)
    }
}
