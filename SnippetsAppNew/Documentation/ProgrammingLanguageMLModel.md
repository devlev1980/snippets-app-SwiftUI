# Creating a CoreML Model for Programming Language Detection

This document describes how to build a CoreML model for detecting programming languages using Apple's Create ML app.

## Prerequisites

- macOS with Xcode and Create ML app installed
- Sample code snippets for each programming language you want to detect

## Step 1: Gather Training Data

For each programming language you want to detect, create a folder with several code snippet files:
- At least 20 snippets per language for basic training
- 100+ snippets per language for better accuracy
- Include variety: different coding styles, frameworks, libraries

Example folder structure:
```
Training Data/
  ├── Swift/
  │   ├── snippet1.swift
  │   ├── snippet2.swift
  │   └── ...
  ├── Python/
  │   ├── snippet1.py
  │   ├── snippet2.py
  │   └── ...
  └── ...
```

## Step 2: Create the Model in Create ML

1. Open the Create ML app
2. Select "New Document"
3. Choose "Text Classifier" project type
4. Name your project "ProgrammingLanguageClassifier"

## Step 3: Import Training Data

1. In the Create ML interface, drag and drop your "Training Data" folder
2. Verify that Create ML has correctly identified the language categories
3. Set the data split to approximately 80% training and 20% testing

## Step 4: Train the Model

1. Click the "Train" button
2. Wait for the training to complete (this may take several minutes)
3. Review the training accuracy and other metrics

## Step 5: Test the Model

1. Use the testing data to evaluate model performance
2. Try testing with additional code snippets not included in the training set
3. Evaluate accuracy for each programming language

## Step 6: Export the Model

1. Click "Export" to save the model
2. Choose "Export model" from the menu
3. Save the model as "ProgrammingLanguageClassifier.mlmodel"

## Step 7: Add to Project

1. Add the exported .mlmodel file to your Xcode project
2. Ensure it's included in your app target
3. The model will be accessible via the code in ProgrammingLanguageDetector.swift

## Improving Model Accuracy

If the model doesn't perform as expected:
- Add more training examples
- Increase the diversity of code samples
- Add examples that were misclassified
- Consider preprocessing code samples by removing comments or normalizing whitespace

## Resources for Sample Code Collection

- GitHub repositories
- Programming tutorials
- Code snippets websites
- Documentation examples
- Open source projects

Remember that the model's accuracy will depend on the quality and variety of your training data. 