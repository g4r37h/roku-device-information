"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
var brighterscript_1 = require("brighterscript");
function default_1() {
    return {
        name: 'nco-parentheses-linter',
        afterFileValidate: function (file) {
            if ((0, brighterscript_1.isBrsFile)(file)) {
                file.parser.references.expressions.forEach(function (expression) {
                    var _a;
                    if (!(expression instanceof brighterscript_1.NullCoalescingExpression)) {
                        return;
                    }
                    if (expression.range && ((_a = file.getTokenAt(expression.range.start)) === null || _a === void 0 ? void 0 : _a.kind) !== brighterscript_1.TokenKind.LeftParen) {
                        file.addDiagnostics([{
                                code: 9001,
                                severity: brighterscript_1.DiagnosticSeverity.Error,
                                message: 'Null coalescing expressions should be wrapped with parentheses to avoid unintended behavior.',
                                range: expression.range,
                                file: file
                            }]);
                    }
                    ;
                });
            }
        }
    };
}
exports.default = default_1;
;
