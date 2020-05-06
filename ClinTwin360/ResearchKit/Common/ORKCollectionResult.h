/*
 Copyright (c) 2015, Apple Inc. All rights reserved.
 
 Redistribution and use in source and binary forms, with or without modification,
 are permitted provided that the following conditions are met:
 
 1.  Redistributions of source code must retain the above copyright notice, this
 list of conditions and the following disclaimer.
 
 2.  Redistributions in binary form must reproduce the above copyright notice,
 this list of conditions and the following disclaimer in the documentation and/or
 other materials provided with the distribution.
 
 3.  Neither the name of the copyright holder(s) nor the names of any contributors
 may be used to endorse or promote products derived from this software without
 specific prior written permission. No license is granted to the trademarks of
 the copyright holders even if such marks are included in this software.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
 FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */


#import "ORKResult.h"


NS_ASSUME_NONNULL_BEGIN

@class ORKStepResult;

/**
 The `ORKCollectionResult` class represents a result that contains an array of
 child results.
 
 `ORKCollectionResult` is the superclass of `ORKTaskResult` and `ORKStepResult`.
 
 Note that object of this class are not instantiated directly by the ResearchKit framework.
 */
ORK_CLASS_AVAILABLE
@interface ORKCollectionResult : ORKResult

/**
 An array of `ORKResult` objects that are the children of the result.
 
 For `ORKTaskResult`, the array contains `ORKStepResult` objects.
 For `ORKStepResult` the array contains concrete result objects such as `ORKFileResult`
 and `ORKQuestionResult`.
 */
@property (nonatomic, copy, nullable) NSArray<ORKResult *> *results;

/**
 Looks up the child result containing an identifier that matches the specified identifier.
 
 @param identifier The identifier of the step for which to search.
 
 @return The matching result, or `nil` if none was found.
 */
- (nullable ORKResult *)resultForIdentifier:(NSString *)identifier;

/**
 The first result.
 
 This is the first result, or `nil` if there are no results.
 */
@property (nonatomic, strong, readonly, nullable) ORKResult *firstResult;

@end


/**
 `ORKTaskResultSource` is the protocol for `[ORKTaskViewController defaultResultSource]`.
 */
@protocol ORKTaskResultSource <NSObject>

/**
 Returns a step result for the specified step identifier, if one exists.
 
 When it's about to present a step, the task view controller needs to look up a
 suitable default answer. The answer can be used to prepopulate a survey with
 the results obtained on a previous run of the same task, by passing an
 `ORKTaskResult` object (which itself implements this protocol).
 
 @param stepIdentifier The identifier for which to search.
 
 @return The result for the specified step, or `nil` for none.
 */
- (nullable ORKStepResult *)stepResultForStepIdentifier:(NSString *)stepIdentifier;

/**
 Should the default result store be used even if there is a previous result? (due to
 reverse navigation or looping)
 
 By default, the `[ORKTaskViewController defaultResultSource]` is only queried for a
 result if the previous result is nil. This allows the result source to override that
 default behavior.
 
 @return `YES` if the default result should be given priority over the previous result.
 */
@optional
- (BOOL)alwaysCheckForDefaultResult;

@end


/**
 An `ORKTaskResult` object is a collection result that contains all the step results
 generated from one run of a task or ordered task (that is, `ORKTask` or `ORKOrderedTask`) in a task view controller.
 
 A task result is typically generated by the framework as the task proceeds. When the task
 completes, it may be appropriate to serialize it for transmission to a server,
 or to immediately perform analysis on it.
 
 The `results` property of the `ORKCollectionResult` object contains the step results
 for the task.
 */
ORK_CLASS_AVAILABLE
@interface ORKTaskResult : ORKCollectionResult <ORKTaskResultSource>

/**
 Returns an intialized task result using the specified identifiers and directory.
 
 @param identifier      The identifier of the task that produced this result.
 @param taskRunUUID     The UUID of the run of the task that produced this result.
 @param outputDirectory The directory in which any files referenced by results can be found.
 
 @return An initialized task result.
 */
- (instancetype)initWithTaskIdentifier:(NSString *)identifier
                           taskRunUUID:(NSUUID *)taskRunUUID
                       outputDirectory:(nullable NSURL *)outputDirectory;

/**
 A unique identifier (UUID) for the presentation of the task that generated
 the result.
 
 The unique identifier for a run of the task typically comes directly
 from the task view controller that was used to run the task.
 */
@property (nonatomic, copy, readonly) NSUUID *taskRunUUID;

/**
 The directory in which the generated data files were stored while the task was run.
 
 The directory comes directly from the task view controller that was used to run this
 task. Generally, when archiving the results of a task, it is useful to archive
 all the files found in the output directory.
 
 The file URL also prefixes the file URLs referenced in any child
 `ORKFileResult` objects.
 */
@property (nonatomic, copy, readonly, nullable) NSURL *outputDirectory;

@end


/**
 The `ORKStepResult` class represents a collection result produced by a step view controller to
 hold all child results produced by the step.
 
 A step result is typically generated by the framework as the task proceeds. When the task
 completes, it may be appropriate to serialize it for transmission to a server,
 or to immediately perform analysis on it.
 
 For example, an `ORKQuestionStep` object produces an `ORKQuestionResult` object that becomes
 a child of the `ORKStepResult` object. Similarly, an `ORKActiveStep` object may produce individual
 child result objects for each of the recorder configurations that was active
 during that step.
 
 The `results` property of the `ORKCollectionResult` object contains the step results
 for the task.
 */
ORK_CLASS_AVAILABLE
@interface ORKStepResult : ORKCollectionResult


/**
 Returns an initialized step result using the specified identifier.
 
 @param stepIdentifier      The identifier of the step.
 @param results             The array of child results. The value of this parameter can be `nil` or empty
 if no results were collected.
 
 @return An initialized step result.
 */
- (instancetype)initWithStepIdentifier:(NSString *)stepIdentifier results:(nullable NSArray<ORKResult *> *)results;

/**
 This property indicates whether the Voice Over or Switch Control assistive technologies were active
 while performing the corresponding step.
 
 This information can be used, for example, to take into consideration the extra time needed by
 handicapped participants to complete some tasks, such as the Tower of Hanoi activity.
 
 The property can have the following values:
 - `UIAccessibilityNotificationVoiceOverIdentifier` if Voice Over was active
 - `UIAccessibilityNotificationSwitchControlIdentifier` if Switch Control was active
 
 Note that the Voice Over and Switch Control assistive technologies are mutually exclusive.
 
 If the property is `nil`, none of these assistive technologies was used.
 */
@property (nonatomic, copy, readonly, nullable) NSString *enabledAssistiveTechnology;

@end

NS_ASSUME_NONNULL_END