//
//  ConsentTask.swift
//  ClinTwin360
//
//  Created by Lauren Bongartz on 3/13/20.
//  Copyright © 2020 Lauren Bongartz. All rights reserved.
//

import Foundation
import ResearchKit

public var ConsentTask: ORKOrderedTask {
  
    var steps = [ORKStep]()
	
	// Visual Consent Step
	let consentDocument = ConsentDocument
	let visualConsentStep = ORKVisualConsentStep(identifier: "VisualConsentStep", document: consentDocument)
	steps += [visualConsentStep]
  
    // ConsentReviewStep
	let signature = consentDocument.signatures!.first!

	let reviewConsentStep = ORKConsentReviewStep(identifier: "ConsentReviewStep", signature: signature, in: consentDocument)

	reviewConsentStep.text = "Review Consent!"
	reviewConsentStep.reasonForConsent = "Consent to join study"

	steps += [reviewConsentStep]
  
    return ORKOrderedTask(identifier: "ConsentTask", steps: steps)
}
