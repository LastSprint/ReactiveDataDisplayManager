import Danger
import Foundation

let danger = Danger()

if danger.github.pullRequest.title.starts(with: "[WIP]") {
    danger.fail("WIP means work in progress. In other words author wants merge freeze ❄️")
}

let editedFiles = danger.git.createdFiles + danger.git.modifiedFiles

if editedFiles.contains(where: { fileName in
    let fileExtension = URL(fileURLWithPath: fileName).pathExtension
    return fileExtension == "yml"
}) {
    warn("The .yml file has been modified. Keep `changelog.md` up to date.")
}

var violations = [SwiftLintViolation]()

violations.append(contentsOf: SwiftLint.lint(configFile: ".swiftlint.yml"))

switch violations.count {
case 0:
    danger.message("Great! We didn't found any violations in your changes. Congratulations  🎉")
case 1..<20:
    danger.warn("Oops! We have found some issues. It's better to fix them to keep code clean ")
default:
    danger.fail("Omg. Your code smells bad. Please fix issues above")
}
